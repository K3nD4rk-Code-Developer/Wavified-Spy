local TS = require(script.Parent.include.RuntimeLib)
local logger = TS.import(script, script.Parent, "reducers", "remote-log")
local store = TS.import(script, script.Parent, "store")
local getFunctionScript = TS.import(script, script.Parent, "utils", "function-util").getFunctionScript
local getInstanceId = TS.import(script, script.Parent, "utils", "instance-util").getInstanceId
local makeSelectRemoteLog = TS.import(script, script.Parent, "reducers", "remote-log", "selectors").makeSelectRemoteLog

local CALLER_STACK_LEVEL = if KRNL_LOADED then 6 else 4

local FireServer = Instance.new("RemoteEvent").FireServer
local InvokeServer = Instance.new("RemoteFunction").InvokeServer
local BindableEvent_Fire = Instance.new("BindableEvent").Fire
local BindableFunction_Invoke = Instance.new("BindableFunction").Invoke
local IsA = game.IsA

local refs = {}
local selectRemoteLog = makeSelectRemoteLog()

-- Actor hook support
local actorHooksEnabled = false
local actorCommChannel = nil

if not hookfunction then
	return
end

if not getcallingscript then
	function getcallingscript()
		return nil
	end
end

if not checkcaller then
	function checkcaller()
		return false
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

		-- Check if this type should be shown based on individual type filters
		if self:IsA("RemoteEvent") and not store.isShowRemoteEvents() then
			return
		end

		if self:IsA("RemoteFunction") and not store.isShowRemoteFunctions() then
			return
		end

		if self:IsA("BindableEvent") and not store.isShowBindableEvents() then
			return
		end

		if self:IsA("BindableFunction") and not store.isShowBindableFunctions() then
			return
		end

		-- Filter out executor calls (when checkcaller returns true)
		if store.isNoExecutor() and checkcaller() then
			return
		end

		local callingScript = getcallingscript()
		local script = callingScript or (callback and getFunctionScript(callback))

		if store.isNoActors() and isFromActor(script, callback) then
			return
		end

		local isActor = isFromActor(script, callback)

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

refs.BindableEvent_Fire = hookfunction(BindableEvent_Fire, function(self, ...)
	if self and store.isActive() and typeof(self) == "Instance" and self:IsA("BindableEvent") then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the bindable from firing
		end

		onReceive(self, { ... })
	end
	return refs.BindableEvent_Fire(self, ...)
end)

refs.BindableFunction_Invoke = hookfunction(BindableFunction_Invoke, function(self, ...)
	if self and store.isActive() and typeof(self) == "Instance" and self:IsA("BindableFunction") then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the bindable from invoking
		end

		onReceive(self, { ... })
	end
	return refs.BindableFunction_Invoke(self, ...)
end)

-- Incoming Signal Hooks (OnClientEvent / OnClientInvoke)
-- This catches server-to-client communications

local wrappedConnections = setmetatable({}, { __mode = "k" })
local wrappedExistingConnections = setmetatable({}, { __mode = "k" })

local function onIncomingReceive(remote, params, callingScript, callback)
	task.defer(function()
		if not store.isActive() then
			return
		end

		local remoteId = getInstanceId(remote)

		-- Check if logging is allowed
		if not store.isRemoteAllowed(remoteId) then
			return
		end

		-- Check type filters
		if remote:IsA("RemoteEvent") and not store.isShowRemoteEvents() then
			return
		end
		if remote:IsA("RemoteFunction") and not store.isShowRemoteFunctions() then
			return
		end

		-- Filter out executor calls
		if store.isNoExecutor() and checkcaller() then
			return
		end

		local isActor = isFromActor(callingScript, callback)
		if store.isNoActors() and isActor then
			return
		end

		local signal = logger.createIncomingSignal(remote, callingScript, callback, params, isActor)

		if store.get(function(state)
			return selectRemoteLog(state, remoteId)
		end) then
			store.dispatch(logger.pushIncomingSignal(remoteId, signal))
		else
			local remoteLog = logger.createRemoteLog(remote, nil, signal)
			store.dispatch(logger.pushRemoteLog(remoteLog))
		end
	end)
end

local function wrapCallback(remote, originalCallback, callingScript)
	if not originalCallback or type(originalCallback) ~= "function" then
		return originalCallback
	end

	return function(...)
		onIncomingReceive(remote, { ... }, callingScript, originalCallback)
		return originalCallback(...)
	end
end

-- Hook __index to track OnClientEvent/OnClientInvoke signal accesses
refs.__index = hookmetamethod(game, "__index", newcclosure(function(self, key)
	local value = refs.__index(self, key)

	-- Check if accessing OnClientEvent or OnClientInvoke
	if store.isActive() and typeof(self) == "Instance" then
		if (key == "OnClientEvent" and self:IsA("RemoteEvent")) or
		   (key == "OnClientInvoke" and self:IsA("RemoteFunction")) then
			-- Track the signal for Connect interception
			if typeof(value) == "RBXScriptSignal" and not wrappedConnections[value] then
				wrappedConnections[value] = { remote = self, signalType = key }
			end
		end
	end

	return value
end))

-- Combined __namecall hook for both outgoing signals and Connect wrapping
refs.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = { ... }

	-- Check if this is a Connect call on a tracked signal (for incoming)
	if method == "Connect" and typeof(self) == "RBXScriptSignal" then
		local signalInfo = wrappedConnections[self]
		if signalInfo and store.isActive() then
			local callback = args[1]
			if callback and type(callback) == "function" then
				local callingScript = getcallingscript()
				args[1] = wrapCallback(signalInfo.remote, callback, callingScript)
				return refs.__namecall(self, unpack(args))
			end
		end
	end

	-- Handle outgoing signals (FireServer, InvokeServer, etc.)
	if
		(store.isActive() and method == "FireServer" and IsA(self, "RemoteEvent")) or
		(store.isActive() and method == "InvokeServer" and IsA(self, "RemoteFunction")) or
		(store.isActive() and method == "Fire" and IsA(self, "BindableEvent")) or
		(store.isActive() and method == "Invoke" and IsA(self, "BindableFunction"))
	then
		local remoteId = getInstanceId(self)

		-- Check if remote is blocked BEFORE firing (paused remotes should still fire)
		if store.isRemoteBlocked(remoteId) then
			return -- Block the remote from firing
		end

		onReceive(self, args)
	end

	return refs.__namecall(self, ...)
end))

-- Hook existing connections on remotes (for connections made before spy loaded)
local function hookExistingConnections()
	if not getconnections then return end

	local function processRemote(remote)
		local signalName = remote:IsA("RemoteEvent") and "OnClientEvent" or "OnClientInvoke"
		local signal = remote[signalName]

		if not signal then return end

		local connections = getconnections(signal)
		if not connections then return end

		for _, connection in connections do
			if connection and connection.Function and not wrappedExistingConnections[connection] then
				wrappedExistingConnections[connection] = true

				local originalFunc = connection.Function
				local wrappedFunc = wrapCallback(remote, originalFunc, nil)

				-- Replace the connection's function if possible
				if connection.Disable and connection.Enable then
					-- Some executors allow modifying connection.Function directly
					pcall(function()
						connection.Function = wrappedFunc
					end)
				end
			end
		end
	end

	-- Find all RemoteEvents and RemoteFunctions
	local function scanDescendants(parent)
		for _, child in parent:GetDescendants() do
			if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
				pcall(processRemote, child)
			end
		end
	end

	pcall(scanDescendants, game)
end

-- Hook firesignal if available (used to replay OnClientEvent)
if firesignal then
	local originalFiresignal = firesignal
	firesignal = newcclosure(function(signal, ...)
		local args = { ... }

		-- Try to get the remote from the signal
		if typeof(signal) == "RBXScriptSignal" then
			local signalInfo = wrappedConnections[signal]
			if signalInfo and store.isActive() then
				onIncomingReceive(signalInfo.remote, args, nil, nil)
			end
		end

		return originalFiresignal(signal, ...)
	end)
end

-- Initialize existing connection hooks
task.defer(hookExistingConnections)

-- Actor Hook System
-- This catches remotes fired from Actor scripts (parallel Luau contexts)

local function onActorReceive(remote, params, callingScript)
	task.defer(function()
		if not store.isActive() then
			return
		end

		local remoteId = getInstanceId(remote)

		-- Check if logging is allowed
		if not store.isRemoteAllowed(remoteId) then
			return
		end

		-- Check type filters
		if remote:IsA("RemoteEvent") and not store.isShowRemoteEvents() then
			return
		end
		if remote:IsA("RemoteFunction") and not store.isShowRemoteFunctions() then
			return
		end
		if remote:IsA("BindableEvent") and not store.isShowBindableEvents() then
			return
		end
		if remote:IsA("BindableFunction") and not store.isShowBindableFunctions() then
			return
		end

		-- Filter out actor calls if NoActors is enabled
		if store.isNoActors() then
			return
		end

		local signal = logger.createOutgoingSignal(remote, callingScript, nil, {}, params, nil, true)

		if store.get(function(state)
			return selectRemoteLog(state, remoteId)
		end) then
			store.dispatch(logger.pushOutgoingSignal(remoteId, signal))
		else
			local remoteLog = logger.createRemoteLog(remote, signal)
			store.dispatch(logger.pushRemoteLog(remoteLog))
		end
	end)
end

local function generateActorHookCode(channelId)
	return [[
		local channelId = ]] .. channelId .. [[

		local commChannel = game:GetService("ReplicatedStorage"):FindFirstChild("__WAVIFIED_ACTOR_COMM_" .. channelId)
		if not commChannel then return end

		local refs = {}
		local FireServer = Instance.new("RemoteEvent").FireServer
		local InvokeServer = Instance.new("RemoteFunction").InvokeServer
		local BindableEvent_Fire = Instance.new("BindableEvent").Fire
		local BindableFunction_Invoke = Instance.new("BindableFunction").Invoke

		local function sendToMain(remote, method, args)
			pcall(function()
				commChannel:Fire(remote, method, args, script)
			end)
		end

		if hookfunction then
			refs.FireServer = hookfunction(FireServer, function(self, ...)
				if self and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
					sendToMain(self, "FireServer", {...})
				end
				return refs.FireServer(self, ...)
			end)

			refs.InvokeServer = hookfunction(InvokeServer, function(self, ...)
				if self and typeof(self) == "Instance" and self:IsA("RemoteFunction") then
					sendToMain(self, "InvokeServer", {...})
				end
				return refs.InvokeServer(self, ...)
			end)

			refs.BindableEvent_Fire = hookfunction(BindableEvent_Fire, function(self, ...)
				if self and typeof(self) == "Instance" and self:IsA("BindableEvent") then
					sendToMain(self, "Fire", {...})
				end
				return refs.BindableEvent_Fire(self, ...)
			end)

			refs.BindableFunction_Invoke = hookfunction(BindableFunction_Invoke, function(self, ...)
				if self and typeof(self) == "Instance" and self:IsA("BindableFunction") then
					sendToMain(self, "Invoke", {...})
				end
				return refs.BindableFunction_Invoke(self, ...)
			end)
		end

		if hookmetamethod then
			refs.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				if typeof(self) == "Instance" then
					if (method == "FireServer" and self:IsA("RemoteEvent")) or
					   (method == "InvokeServer" and self:IsA("RemoteFunction")) or
					   (method == "Fire" and self:IsA("BindableEvent")) or
					   (method == "Invoke" and self:IsA("BindableFunction")) then
						sendToMain(self, method, {...})
					end
				end
				return refs.__namecall(self, ...)
			end)
		end
	]]
end

local function initActorHooks()
	-- Check if executor supports actor functions
	if not getactors or not run_on_actor then
		return false
	end

	-- Generate unique channel ID
	local channelId = math.random(100000, 999999)

	-- Create communication channel in ReplicatedStorage
	actorCommChannel = Instance.new("BindableEvent")
	actorCommChannel.Name = "__WAVIFIED_ACTOR_COMM_" .. channelId
	actorCommChannel.Parent = game:GetService("ReplicatedStorage")

	-- Listen for actor hook data
	actorCommChannel.Event:Connect(function(remote, method, args, callingScript)
		if typeof(remote) == "Instance" then
			onActorReceive(remote, args, callingScript)
		end
	end)

	-- Generate hook code once
	local actorCode = generateActorHookCode(channelId)

	-- Track which actors we've already hooked
	local hookedActors = {}

	-- Function to hook a single actor
	local function hookActor(actor)
		if hookedActors[actor] then return end
		hookedActors[actor] = true
		pcall(run_on_actor, actor, actorCode)
	end

	-- Hook all existing actors
	local actors = getactors()
	if actors then
		for _, actor in actors do
			hookActor(actor)
		end
	end

	-- Watch for newly created actors in common locations
	local function watchForActors(parent)
		if not parent then return end

		pcall(function()
			parent.DescendantAdded:Connect(function(descendant)
				if descendant:IsA("Actor") then
					task.defer(function()
						hookActor(descendant)
					end)
				end
			end)
		end)
	end

	-- Watch common actor spawn locations
	watchForActors(game:GetService("Workspace"))
	watchForActors(game:GetService("ReplicatedStorage"))
	watchForActors(game:GetService("ReplicatedFirst"))
	pcall(function()
		watchForActors(game:GetService("Players").LocalPlayer)
	end)

	-- Periodically check for new actors (backup method)
	task.spawn(function()
		while actorHooksEnabled do
			task.wait(2)
			local currentActors = getactors and getactors()
			if currentActors then
				for _, actor in currentActors do
					hookActor(actor)
				end
			end
		end
	end)

	actorHooksEnabled = true
	return true
end

-- Initialize actor hooks
task.defer(function()
	local success = initActorHooks()
	if success then
		print("[Wavified-Spy] Actor hooks initialized successfully")
	end
end)