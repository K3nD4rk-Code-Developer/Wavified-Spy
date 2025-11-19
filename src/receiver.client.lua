local TS = require(script.Parent.include.RuntimeLib)
local logger = TS.import(script, script.Parent, "reducers", "remote-log")
local store = TS.import(script, script.Parent, "store")
local getFunctionScript = TS.import(script, script.Parent, "utils", "function-util").getFunctionScript
local getInstanceId = TS.import(script, script.Parent, "utils", "instance-util").getInstanceId
local makeSelectRemoteLog = TS.import(script, script.Parent, "reducers", "remote-log", "selectors").makeSelectRemoteLog

local CALLER_STACK_LEVEL = if KRNL_LOADED then 6 else 4

-- ExtraData for tracking execution context (Actor vs Main thread)
local ExtraData = nil

local FireServer = Instance.new("RemoteEvent").FireServer
local InvokeServer = Instance.new("RemoteFunction").InvokeServer
local IsA = game.IsA

local refs = {}
local selectRemoteLog = makeSelectRemoteLog()

if not hookfunction then
	return
end

if not getcallingscript then
	function getcallingscript()
		return nil
	end
end

local function isFromActor(script, callback)
	-- Check if the script has an Actor ancestor
	if script then
		local parent = script.Parent
		while parent do
			if parent:IsA("Actor") then
				return true
			end
			parent = parent.Parent
		end
	end

	-- Check if the callback function's environment indicates it's in an actor
	if callback and type(callback) == "function" then
		local success, env = pcall(function()
			return getfenv(callback)
		end)

		if success and env then
			local envScript = rawget(env, "script")
			if envScript and envScript ~= script then
				-- Recursively check the environment's script
				local parent = envScript.Parent
				while parent do
					if parent:IsA("Actor") then
						return true
					end
					parent = parent.Parent
				end
			end
		end
	end

	return false
end

local function onReceive(self, params, returns)
	local traceback = {}
	local callback = debug.info(CALLER_STACK_LEVEL, "f")

	local level, fn = 4, callback

	while fn do
		table.insert(traceback, fn)
		level = level + 1
		fn = debug.info(level, "f")
	end

	task.defer(function()
		local remoteId = getInstanceId(self)

		-- Check if logging is allowed (paused or blocked remotes should not be logged)
		if not store.isRemoteAllowed(remoteId) then
			return
		end

		local script = getcallingscript() or (callback and getFunctionScript(callback))

		-- Check if actor detection is disabled and the calling script is from an actor
		if store.isNoActors() and isFromActor(script, callback) then
			return
		end

		-- Determine if this call is from an actor (either ExtraData.IsActor or legacy detection)
		local isActor = (ExtraData and ExtraData.IsActor) or isFromActor(script, callback)

		local signal = logger.createOutgoingSignal(self, script, callback, traceback, params, returns, isActor)

		if store.get(function(state)
			return selectRemoteLog(state, remoteId)
		end) then
			store.dispatch(logger.pushOutgoingSignal(remoteId, signal))
		else
			local remoteLog = logger.createRemoteLog(self, signal)
			store.dispatch(logger.pushRemoteLog(remoteLog))
		end
	end)
end

-- Hooks

refs.FireServer = hookfunction(FireServer, function(self, ...)
	if self and store.isActive() and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the remote from firing
		end

		onReceive(self, { ... })
	end
	return refs.FireServer(self, ...)
end)

refs.InvokeServer = hookfunction(InvokeServer, function(self, ...)
	if self and store.isActive() and typeof(self) == "Instance" and self:IsA("RemoteFunction") then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the remote from firing
		end

		onReceive(self, { ... })
	end
	return refs.InvokeServer(self, ...)
end)

refs.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()

	if
		(store.isActive() and method == "FireServer" and IsA(self, "RemoteEvent")) or
		(store.isActive() and method == "InvokeServer" and IsA(self, "RemoteFunction"))
	then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the remote from firing
		end

		onReceive(self, { ... })
	end

	return refs.__namecall(self, ...)
end)

-- Actor Detection System
local function generateActorCode()
	-- This generates a self-contained script that runs in each Actor
	-- The script sets ExtraData.IsActor = true and sets up the same hooks

	-- Get the path to the module root dynamically
	local moduleRoot = script.Parent
	local function getInstancePath(instance)
		local function isValidIdentifier(name)
			-- Check if name is a valid Lua identifier (no spaces, dashes, etc.)
			return name:match("^[%a_][%w_]*$") ~= nil
		end

		local function formatName(name)
			-- Use bracket notation for names with special characters
			if isValidIdentifier(name) then
				return "." .. name
			else
				return '["' .. name:gsub('"', '\\"') .. '"]'
			end
		end

		-- First, verify the instance is in the game tree
		if not instance:IsDescendantOf(game) then
			-- Not in game tree - this is normal for executor environments
			return nil
		end

		-- Find the service this instance belongs to
		local service = nil
		for _, svc in ipairs(game:GetChildren()) do
			if instance:IsDescendantOf(svc) then
				service = svc
				break
			end
		end

		if not service then
			-- Couldn't find service - return nil to trigger fallback
			return nil
		end

		-- Build path from service to instance
		local parts = {}
		local current = instance
		while current and current ~= service do
			table.insert(parts, 1, formatName(current.Name))
			current = current.Parent
		end

		-- Build final path
		local path = table.concat(parts, "")
		return "game:GetService('" .. service.ClassName .. "')" .. path
	end

	local modulePath = getInstancePath(moduleRoot)

	if not modulePath then
		print("[Wavified-Spy] Module not in game tree, will use fallback search in actors")
		-- Use a placeholder that will fail and trigger fallback search
		modulePath = "nil"
	else
		print(`[Wavified-Spy] Generated actor module path: {modulePath}`)
	end

	local actorCode = string.format([[
		-- Actor Context Marker
		local ExtraData = { IsActor = true }

		-- Get required functions
		local hookfunction = hookfunction
		local hookmetamethod = hookmetamethod
		local getnamecallmethod = getnamecallmethod
		local getcallingscript = getcallingscript

		if not hookfunction then return end

		if not getcallingscript then
			function getcallingscript()
				return nil
			end
		end

		-- Import necessary modules using dynamic path
		local moduleRoot
		local success, result = pcall(function()
			return %s
		end)

		if success and result then
			moduleRoot = result
			print("[Wavified-Spy Actor] Module loaded from path: " .. tostring(moduleRoot:GetFullName()))
		else
			-- Try fallback locations (common for executor environments)
			print("[Wavified-Spy Actor] Primary path failed, searching for module...")

			local searchLocations = {
				game:GetService("ReplicatedStorage"),
				game:GetService("ReplicatedFirst"),
				game:GetService("StarterPlayer"),
			}

			local searchNames = {"TS", "RemoteSpy", "Wavified-Spy", "WavifiedSpy"}

			for _, location in ipairs(searchLocations) do
				for _, name in ipairs(searchNames) do
					local ok, module = pcall(function()
						return location:FindFirstChild(name, true)
					end)
					if ok and module and module:FindFirstChild("include") then
						moduleRoot = module
						print("[Wavified-Spy Actor] Found module: " .. tostring(module:GetFullName()))
						break
					end
				end
				if moduleRoot then break end
			end
		end

		if not moduleRoot then
			warn("[Wavified-Spy Actor] Module root is nil after all attempts")
			return
		end

		local success2, TS = pcall(function()
			return require(moduleRoot.include.RuntimeLib)
		end)

		if not success2 then
			warn("[Wavified-Spy Actor] Failed to load RuntimeLib from " .. tostring(moduleRoot) .. ": " .. tostring(TS))
			return
		end

		local logger = TS.import(moduleRoot, moduleRoot, "reducers", "remote-log")
		local store = TS.import(moduleRoot, moduleRoot, "store")
		local getFunctionScript = TS.import(moduleRoot, moduleRoot, "utils", "function-util").getFunctionScript
		local getInstanceId = TS.import(moduleRoot, moduleRoot, "utils", "instance-util").getInstanceId
		local makeSelectRemoteLog = TS.import(moduleRoot, moduleRoot, "reducers", "remote-log", "selectors").makeSelectRemoteLog

		local CALLER_STACK_LEVEL = if KRNL_LOADED then 6 else 4
		local FireServer = Instance.new("RemoteEvent").FireServer
		local InvokeServer = Instance.new("RemoteFunction").InvokeServer
		local IsA = game.IsA
		local refs = {}
		local selectRemoteLog = makeSelectRemoteLog()

		local function onReceive(self, params, returns)
			local traceback = {}
			local callback = debug.info(CALLER_STACK_LEVEL, "f")
			local level, fn = 4, callback

			while fn do
				table.insert(traceback, fn)
				level = level + 1
				fn = debug.info(level, "f")
			end

			task.defer(function()
				local remoteId = getInstanceId(self)
				if not store.isRemoteAllowed(remoteId) then return end

				local script = getcallingscript() or (callback and getFunctionScript(callback))

				-- Pass ExtraData.IsActor = true to signal
				local signal = logger.createOutgoingSignal(self, script, callback, traceback, params, returns, true)

				if store.get(function(state)
					return selectRemoteLog(state, remoteId)
				end) then
					store.dispatch(logger.pushOutgoingSignal(remoteId, signal))
				else
					local remoteLog = logger.createRemoteLog(self, signal)
					store.dispatch(logger.pushRemoteLog(remoteLog))
				end
			end)
		end

		-- Hook FireServer
		refs.FireServer = hookfunction(FireServer, function(self, ...)
			if self and store.isActive() and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
				local remoteId = getInstanceId(self)
				if store.isRemoteBlocked(remoteId) then return end
				onReceive(self, { ... })
			end
			return refs.FireServer(self, ...)
		end)

		-- Hook InvokeServer
		refs.InvokeServer = hookfunction(InvokeServer, function(self, ...)
			if self and store.isActive() and typeof(self) == "Instance" and self:IsA("RemoteFunction") then
				local remoteId = getInstanceId(self)
				if store.isRemoteBlocked(remoteId) then return end
				onReceive(self, { ... })
			end
			return refs.InvokeServer(self, ...)
		end)

		-- Hook __namecall
		refs.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			if (store.isActive() and method == "FireServer" and IsA(self, "RemoteEvent")) or
			   (store.isActive() and method == "InvokeServer" and IsA(self, "RemoteFunction")) then
				local remoteId = getInstanceId(self)
				if store.isRemoteBlocked(remoteId) then return end
				onReceive(self, { ... })
			end
			return refs.__namecall(self, ...)
		end)
	]], modulePath)

	return actorCode
end

local function runOnActors()
	-- Check if executor supports actor functions
	if not getactors or not run_on_actor then
		warn("[Wavified-Spy] Executor does not support actor detection (missing getactors or run_on_actor)")
		return
	end

	local actors = getactors()
	if not actors then
		warn("[Wavified-Spy] getactors() returned nil")
		return
	end

	if #actors == 0 then
		print("[Wavified-Spy] No actors found in game")
		return
	end

	print(`[Wavified-Spy] Found {#actors} actor(s), initializing hooks...`)

	local actorCode = generateActorCode()

	if not actorCode or actorCode == "" then
		warn("[Wavified-Spy] Failed to generate actor code, aborting actor detection")
		return
	end

	local successCount = 0

	-- Run the actor code in each Actor's context
	for _, actor in ipairs(actors) do
		local success, err = pcall(run_on_actor, actor, actorCode)
		if success then
			successCount = successCount + 1
			print(`[Wavified-Spy] ✓ Actor initialized: {actor:GetFullName()}`)
		else
			warn(`[Wavified-Spy] ✗ Failed to initialize actor {actor:GetFullName()}: {err}`)
		end
	end

	print(`[Wavified-Spy] Actor detection initialized: {successCount}/{#actors} actors hooked`)
end

-- Monitor for new actors being added
local function monitorNewActors()
	if not getactors or not run_on_actor then
		return
	end

	game.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Actor") then
			task.defer(function()
				local actorCode = generateActorCode()
				if not actorCode or actorCode == "" then
					warn("[Wavified-Spy] Failed to generate actor code for new actor")
					return
				end
				local success, err = pcall(run_on_actor, descendant, actorCode)
				if success then
					print(`[Wavified-Spy] ✓ New actor initialized: {descendant:GetFullName()}`)
				else
					warn(`[Wavified-Spy] ✗ Failed to initialize new actor {descendant:GetFullName()}: {err}`)
				end
			end)
		end
	end)
end

-- Initialize actor detection
task.defer(function()
	print("[Wavified-Spy] Initializing actor detection...")
	runOnActors()
	monitorNewActors()
end)
