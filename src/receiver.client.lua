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

		local callingScript = getcallingscript()
		local script = callingScript or (callback and getFunctionScript(callback))

		if store.isNoActors() and isFromActor(script, callback) then
			return
		end

		-- Filter out executor calls (when getcallingscript returns nil)
		if store.isNoExecutor() and callingScript == nil then
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

refs.__namecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()

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

		onReceive(self, { ... })
	end

	return refs.__namecall(self, ...)
end)