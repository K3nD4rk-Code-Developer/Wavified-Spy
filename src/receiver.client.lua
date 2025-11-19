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

		local parts = {}
		local current = instance
		while current and current.Parent ~= game do
			table.insert(parts, 1, formatName(current.Name))
			current = current.Parent
		end

		-- Add the service name
		if instance:IsDescendantOf(game) then
			for _, service in ipairs(game:GetChildren()) do
				if instance:IsDescendantOf(service) then
					local path = table.concat(parts, "")
					return "game:GetService('" .. service.ClassName .. "')" .. path
				end
			end
		end

		return table.concat(parts, "")
	end

	local modulePath = getInstancePath(moduleRoot)
	print(`[Wavified-Spy] Generated actor module path: {modulePath}`)

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
		else
			warn("[Wavified-Spy Actor] Failed to resolve primary module path: " .. tostring(result))

			-- Try fallback locations
			local fallbacks = {
				function() return game:GetService("ReplicatedStorage"):FindFirstChild("TS", true) end,
				function() return game:GetService("ReplicatedStorage"):FindFirstChild("RemoteSpy", true) end,
				function() return game:GetService("ReplicatedStorage"):FindFirstChild("Wavified-Spy", true) end,
			}

			for _, fallback in ipairs(fallbacks) do
				local ok, module = pcall(fallback)
				if ok and module then
					moduleRoot = module
					warn("[Wavified-Spy Actor] Using fallback module: " .. tostring(module:GetFullName()))
					break
				end
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
	runOnActors()
	monitorNewActors()
end)
