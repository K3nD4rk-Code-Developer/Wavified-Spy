local instanceFromId = {}
local idFromInstance = {}

local modules = {}
local currentlyLoading = {}

local function loadModule(object, caller)
	local module = modules[object]

	if module.isLoaded then
		return module.data
	end

	if caller then
		currentlyLoading[caller] = object

		local currentObject = object
		local depth = 0

		while currentObject do
			depth = depth + 1
			currentObject = currentlyLoading[currentObject]
	
			if currentObject == object then
				local str = currentObject:GetFullName()
	
				for _ = 1, depth do
					currentObject = currentlyLoading[currentObject]
					str = str .. "  ⇒ " .. currentObject:GetFullName()
				end
	
				error("Failed to load '" .. object:GetFullName() .. "'! Detected a circular dependency chain: " .. str, 2)
			end
		end
	end

	local data = module.fn()

	if currentlyLoading[caller] == object then
		currentlyLoading[caller] = nil
	end

	module.data = data
	module.isLoaded = true

	return data
end

local function start()
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	for object in pairs(modules) do
		if object:IsA("LocalScript") and not object.Disabled then
			task.defer(loadModule, object)
		end
	end
end

local globalMt = {
	__index = getfenv(0),
	__metatable = "This metatable is locked",
}

local function _env(id)
	local object = instanceFromId[id]

	return setmetatable({
		script = object,
		require = function (target)
			if modules[target] and target:IsA("ModuleScript") then
				return loadModule(target, object)
			else
				return require(target)
			end
		end,
	}, globalMt)
end

local function _module(name, className, path, parent, fn)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = instanceFromId[parent]

	instanceFromId[path] = instance
	idFromInstance[instance] = path

	modules[instance] = {
		fn = fn,
		isLoaded = false,
		value = nil,
	}
end

local function _instance(name, className, path, parent)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = instanceFromId[parent]

	instanceFromId[path] = instance
	idFromInstance[instance] = path
end


_instance("RemoteSpy", "Folder", "RemoteSpy", nil)

_module("acrylic", "LocalScript", "RemoteSpy.acrylic", "RemoteSpy", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.include.RuntimeLib)
local Make = TS.import(script, TS.getModule(script, "@rbxts", "make"))
local IS_ACRYLIC_ENABLED = TS.import(script, script.Parent, "constants").IS_ACRYLIC_ENABLED
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local Lighting = _services.Lighting
local Workspace = _services.Workspace
local changed = TS.import(script, script.Parent, "store").changed
local selectIsClosing = TS.import(script, script.Parent, "reducers", "action-bar").selectIsClosing
local baseEffect = Make("DepthOfFieldEffect", {
	FarIntensity = 0,
	InFocusRadius = 0.1,
	NearIntensity = 1,
})
local depthOfFieldDefaults = {}
local function enable()
	for effect in pairs(depthOfFieldDefaults) do
		effect.Enabled = false
	end
	baseEffect.Parent = Lighting
end
local function disable()
	for effect, defaults in pairs(depthOfFieldDefaults) do
		effect.Enabled = defaults.enabled
	end
	baseEffect.Parent = nil
end
local function registerDefaults()
	local register = function(object)
		if object:IsA("DepthOfFieldEffect") then
			local _arg1 = {
				enabled = object.Enabled,
			}
			depthOfFieldDefaults[object] = _arg1
		end
	end
	local _exp = Lighting:GetChildren()
	for _k, _v in ipairs(_exp) do
		register(_v, _k - 1, _exp)
	end
	local _result = Workspace.CurrentCamera
	if _result ~= nil then
		local _exp_1 = _result:GetChildren()
		for _k, _v in ipairs(_exp_1) do
			register(_v, _k - 1, _exp_1)
		end
	end
end
if IS_ACRYLIC_ENABLED then
	registerDefaults()
	enable()
	changed(selectIsClosing, function(active)
		return active and disable()
	end)
end
 end, _env("RemoteSpy.acrylic"))() end)

_module("app", "LocalScript", "RemoteSpy.app", "RemoteSpy", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local StoreProvider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").src).StoreProvider
local App = TS.import(script, script.Parent, "components", "App").default
local IS_LOADED = TS.import(script, script.Parent, "constants").IS_LOADED
local _store = TS.import(script, script.Parent, "store")
local changed = _store.changed
local configureStore = _store.configureStore
local _global_util = TS.import(script, script.Parent, "utils", "global-util")
local getGlobal = _global_util.getGlobal
local setGlobal = _global_util.setGlobal
local selectIsClosing = TS.import(script, script.Parent, "reducers", "action-bar").selectIsClosing
if getGlobal(IS_LOADED) == true then
	error("The global " .. (IS_LOADED .. " is already defined."))
end
local store = configureStore()
local tree = Roact.mount(Roact.createElement(StoreProvider, {
	store = store,
}, {
	Roact.createElement(App),
}))
changed(selectIsClosing, function(active)
	if active then
		Roact.unmount(tree)
		setGlobal(IS_LOADED, false)
		task.defer(function()
			return store:destruct()
		end)
	end
end)
setGlobal(IS_LOADED, true)
 end, _env("RemoteSpy.app"))() end)

_instance("components", "Folder", "RemoteSpy.components", "RemoteSpy")

_module("Acrylic", "ModuleScript", "RemoteSpy.components.Acrylic", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Acrylic = TS.import(script, script, "Acrylic").default
local AcrylicPaint = TS.import(script, script, "AcrylicPaint").default
local default = {
	Blur = Acrylic,
	Paint = AcrylicPaint,
}
return {
	default = default,
}
 end, _env("RemoteSpy.components.Acrylic"))() end)

_module("Acrylic", "ModuleScript", "RemoteSpy.components.Acrylic.Acrylic", "RemoteSpy.components.Acrylic", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local AcrylicBlur = TS.import(script, script.Parent, "AcrylicBlur").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local IS_ACRYLIC_ENABLED = TS.import(script, script.Parent.Parent.Parent, "constants").IS_ACRYLIC_ENABLED
local function Acrylic(_param)
	local distance = _param.distance
	if not IS_ACRYLIC_ENABLED then
		return Roact.createFragment()
	end
	return Roact.createElement(AcrylicBlur, {
		distance = distance,
	})
end
return {
	default = Acrylic,
}
 end, _env("RemoteSpy.components.Acrylic.Acrylic"))() end)

_module("AcrylicBlur", "ModuleScript", "RemoteSpy.components.Acrylic.AcrylicBlur", "RemoteSpy.components.Acrylic", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
local createAcrylic = TS.import(script, script.Parent, "create-acrylic").createAcrylic
local _utils = TS.import(script, script.Parent, "utils")
local getOffset = _utils.getOffset
local viewportPointToWorld = _utils.viewportPointToWorld
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useCallback = _roact_hooked.useCallback
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useMutable = _roact_hooked.useMutable
local withHooksPure = _roact_hooked.withHooksPure
local function AcrylicBlur(_param)
	local distance = _param.distance
	if distance == nil then
		distance = 0.001
	end
	local positions = useMutable({
		topLeft = Vector2.zero,
		topRight = Vector2.zero,
		bottomRight = Vector2.zero,
	})
	local model = useMemo(function()
		local model = createAcrylic()
		model.Parent = Workspace
		return model
	end, {})
	useEffect(function()
		return function()
			return model:Destroy()
		end
	end, {})
	local updatePositions = useCallback(function(size, position)
		local _object = {
			topLeft = position,
		}
		local _left = "topRight"
		local _vector2 = Vector2.new(size.X, 0)
		_object[_left] = position + _vector2
		_object.bottomRight = position + size
		positions.current = _object
	end, { distance })
	local render = useCallback(function()
		local _result = Workspace.CurrentCamera
		if _result ~= nil then
			_result = _result.CFrame
		end
		local _condition = _result
		if _condition == nil then
			_condition = CFrame.new()
		end
		local camera = _condition
		local _binding = positions.current
		local topLeft = _binding.topLeft
		local topRight = _binding.topRight
		local bottomRight = _binding.bottomRight
		local topLeft3D = viewportPointToWorld(topLeft, distance)
		local topRight3D = viewportPointToWorld(topRight, distance)
		local bottomRight3D = viewportPointToWorld(bottomRight, distance)
		local width = (topRight3D - topLeft3D).Magnitude
		local height = (topRight3D - bottomRight3D).Magnitude
		model.CFrame = CFrame.fromMatrix((topLeft3D + bottomRight3D) / 2, camera.XVector, camera.YVector, camera.ZVector)
		model.Mesh.Scale = Vector3.new(width, height, 0)
	end, { distance })
	local onChange = useCallback(function(rbx)
		local offset = getOffset()
		local _absoluteSize = rbx.AbsoluteSize
		local _vector2 = Vector2.new(offset, offset)
		local size = _absoluteSize - _vector2
		local _absolutePosition = rbx.AbsolutePosition
		local _vector2_1 = Vector2.new(offset / 2, offset / 2)
		local position = _absolutePosition + _vector2_1
		updatePositions(size, position)
		task.spawn(render)
	end, {})
	useEffect(function()
		local camera = Workspace.CurrentCamera
		local cframeChanged = camera:GetPropertyChangedSignal("CFrame"):Connect(render)
		local fovChanged = camera:GetPropertyChangedSignal("FieldOfView"):Connect(render)
		local screenChanged = camera:GetPropertyChangedSignal("ViewportSize"):Connect(render)
		task.spawn(render)
		return function()
			cframeChanged:Disconnect()
			fovChanged:Disconnect()
			screenChanged:Disconnect()
		end
	end, { render })
	return Roact.createElement("Frame", {
		[Roact.Change.AbsoluteSize] = onChange,
		[Roact.Change.AbsolutePosition] = onChange,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	})
end
local default = withHooksPure(AcrylicBlur)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Acrylic.AcrylicBlur"))() end)

_module("AcrylicPaint", "ModuleScript", "RemoteSpy.components.Acrylic.AcrylicPaint", "RemoteSpy.components.Acrylic", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function AcrylicPaint()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromHex("#FFFFFF"),
		BackgroundTransparency = 0.9,
		BorderSizePixel = 0,
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromHex("#1C1F28"),
			BackgroundTransparency = 0.4,
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
		Roact.createElement("Frame", {
			BackgroundColor3 = Color3.fromHex("#FFFFFF"),
			BackgroundTransparency = 0.4,
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			Roact.createElement("UIGradient", {
				Color = ColorSequence.new(Color3.fromHex("#252221"), Color3.fromHex("#171515")),
				Rotation = 90,
			}),
		}),
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://98449888558787",
			ImageTransparency = 0.7,
			ImageColor3 = Color3.new(0.13, 0.13, 0.13),
			ScaleType = "Stretch",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
		}),
		Roact.createElement(Container, {}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 8),
			}),
			Roact.createElement("UIStroke", {
				Color = Color3.fromHex("#606060"),
				Transparency = 0.5,
				Thickness = 1,
			}),
		}),
	})
end
return {
	default = AcrylicPaint,
}
 end, _env("RemoteSpy.components.Acrylic.AcrylicPaint"))() end)

_module("create-acrylic", "ModuleScript", "RemoteSpy.components.Acrylic.create-acrylic", "RemoteSpy.components.Acrylic", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Make = TS.import(script, TS.getModule(script, "@rbxts", "make"))
local function createAcrylic()
	return Make("Part", {
		Name = "Body",
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanCollide = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.999,
		Children = { Make("SpecialMesh", {
			MeshType = Enum.MeshType.Brick,
			Offset = Vector3.new(0, 0, -0.000001),
		}) },
	})
end
return {
	createAcrylic = createAcrylic,
}
 end, _env("RemoteSpy.components.Acrylic.create-acrylic"))() end)

_module("utils", "ModuleScript", "RemoteSpy.components.Acrylic.utils", "RemoteSpy.components.Acrylic", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
local map = TS.import(script, script.Parent.Parent.Parent, "utils", "number-util").map
local function viewportPointToWorld(location, distance)
	local unitRay = Workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
	local _origin = unitRay.Origin
	local _arg0 = unitRay.Direction * distance
	return _origin + _arg0
end
local function getOffset()
	return map(Workspace.CurrentCamera.ViewportSize.Y, 0, 2560, 8, 56)
end
return {
	viewportPointToWorld = viewportPointToWorld,
	getOffset = getOffset,
}
 end, _env("RemoteSpy.components.Acrylic.utils"))() end)

_module("ActionBar", "ModuleScript", "RemoteSpy.components.ActionBar", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "ActionBar").default
return exports
 end, _env("RemoteSpy.components.ActionBar"))() end)

_module("ActionBar", "ModuleScript", "RemoteSpy.components.ActionBar.ActionBar", "RemoteSpy.components.ActionBar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local ActionBarEffects = TS.import(script, script.Parent, "ActionBarEffects").default
local ActionButton = TS.import(script, script.Parent, "ActionButton").default
local ActionLine = TS.import(script, script.Parent, "ActionLine").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function ActionBar()
	return Roact.createFragment({
		Roact.createElement("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.92,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 83),
			BorderSizePixel = 0,
		}),
		Roact.createElement(ActionBarEffects),
		Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 36),
			Position = UDim2.new(0, 0, 0, 42),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.8,
			ScrollingDirection = Enum.ScrollingDirection.X,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			ElasticBehavior = Enum.ElasticBehavior.Never,
		}, {
			Roact.createElement(ActionButton, {
				layoutOrder = 1,
				id = "navigatePrevious",
				icon = "rbxassetid://9887696242",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 2,
				id = "navigateNext",
				icon = "rbxassetid://9887978919",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 3,
				id = "pause",
				icon = "rbxassetid://12200106191",
				caption = "Pause",
			}),
			Roact.createElement(ActionLine, {
				order = 4,
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 5,
				id = "copy",
				icon = "rbxassetid://9887696628",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 6,
				id = "save",
				icon = "rbxassetid://9932819855",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 7,
				id = "delete",
				icon = "rbxassetid://9887696922",
			}),
			Roact.createElement(ActionLine, {
				order = 8,
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 9,
				id = "traceback",
				icon = "rbxassetid://9887697255",
				caption = "Traceback",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 10,
				id = "copyPath",
				icon = "rbxassetid://9887697099",
				caption = "Copy Path",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 11,
				id = "copyScript",
				icon = "rbxassetid://9887697099",
				caption = "Generate",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 12,
				id = "viewScript",
				icon = "rbxassetid://9887697255",
				caption = "View Script",
			}),
			Roact.createElement(ActionLine, {
				order = 13,
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 14,
				id = "pauseRemote",
				icon = "rbxassetid://12200106191",
				caption = "Pause Remote",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 15,
				id = "blockRemote",
				icon = "rbxassetid://9887696922",
				caption = "Block Remote",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 16,
				id = "blockAll",
				icon = "rbxassetid://9887696922",
				caption = "Block All",
			}),
			Roact.createElement(ActionButton, {
				layoutOrder = 17,
				id = "runRemote",
				icon = "rbxassetid://9887978919",
				caption = "Run Remote",
			}),
			Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 1),
				FillDirection = "Horizontal",
				HorizontalAlignment = "Left",
				VerticalAlignment = "Center",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 3),
			}),
		}),
	})
end
return {
	default = ActionBar,
}
 end, _env("RemoteSpy.components.ActionBar.ActionBar"))() end)

_module("ActionBarEffects", "ModuleScript", "RemoteSpy.components.ActionBar.ActionBarEffects", "RemoteSpy.components.ActionBar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local TabType = _tab_group.TabType
local deleteTab = _tab_group.deleteTab
local pushTab = _tab_group.pushTab
local selectActiveTab = _tab_group.selectActiveTab
local selectTabs = _tab_group.selectTabs
local setActiveTab = _tab_group.setActiveTab
local _utils = TS.import(script, script.Parent, "utils")
local codifyOutgoingSignal = _utils.codifyOutgoingSignal
local stringifyRemote = _utils.stringifyRemote
local _instance_util = TS.import(script, script.Parent.Parent.Parent, "utils", "instance-util")
local getInstanceFromId = _instance_util.getInstanceFromId
local getInstancePath = _instance_util.getInstancePath
local _remote_log = TS.import(script, script.Parent.Parent.Parent, "reducers", "remote-log")
local makeSelectRemoteLog = _remote_log.makeSelectRemoteLog
local removeOutgoingSignal = _remote_log.removeOutgoingSignal
local selectRemoteIdSelected = _remote_log.selectRemoteIdSelected
local selectSignalSelected = _remote_log.selectSignalSelected
local togglePaused = _remote_log.togglePaused
local selectRemoteLogIds = _remote_log.selectRemoteLogIds
local setRemoteSelected = _remote_log.setRemoteSelected
local toggleRemotePaused = _remote_log.toggleRemotePaused
local toggleRemoteBlocked = _remote_log.toggleRemoteBlocked
local toggleBlockAllRemotes = _remote_log.toggleBlockAllRemotes
local selectPaused = _remote_log.selectPaused
local selectPausedRemotes = _remote_log.selectPausedRemotes
local selectBlockedRemotes = _remote_log.selectBlockedRemotes
local selectPathNotation = _remote_log.selectPathNotation
local selectRemotesMultiSelected = _remote_log.selectRemotesMultiSelected
local selectRemoteLogs = _remote_log.selectRemoteLogs
local selectInspectionResultSelected = _remote_log.selectInspectionResultSelected
local removeRemoteLog = TS.import(script, script.Parent.Parent.Parent, "reducers", "remote-log").removeRemoteLog
local _action_bar = TS.import(script, script.Parent.Parent.Parent, "reducers", "action-bar")
local setActionEnabled = _action_bar.setActionEnabled
local setActionCaption = _action_bar.setActionCaption
local _script = TS.import(script, script.Parent.Parent.Parent, "reducers", "script")
local setScript = _script.setScript
local removeScript = _script.removeScript
local useActionEffect = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-action-effect").useActionEffect
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local withHooksPure = _roact_hooked.withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local useRootStore = _use_root_store.useRootStore
local genScript = TS.import(script, script.Parent.Parent.Parent, "utils", "gen-script").genScript
local notify = TS.import(script, script.Parent.Parent.Parent, "utils", "notify").notify
local generateUniqueScriptName = TS.import(script, script.Parent.Parent.Parent, "utils", "script-tab-util").generateUniqueScriptName
local createTabColumn = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group", "utils").createTabColumn
local HttpService = TS.import(script, TS.getModule(script, "@rbxts", "services")).HttpService
local setTracebackCallStack = TS.import(script, script.Parent.Parent.Parent, "reducers", "traceback").setTracebackCallStack
local selectRemoteLog = makeSelectRemoteLog()
local function ActionBarEffects()
	local store = useRootStore()
	local dispatch = useRootDispatch()
	local currentTab = useRootSelector(selectActiveTab)
	local remoteId = useRootSelector(selectRemoteIdSelected)
	local remote = useRootSelector(function(state)
		return if remoteId ~= nil then selectRemoteLog(state, remoteId) else nil
	end)
	local signal = useRootSelector(selectSignalSelected)
	local tabs = useRootSelector(selectTabs)
	local pathNotation = useRootSelector(selectPathNotation)
	local multiSelected = useRootSelector(selectRemotesMultiSelected)
	local inspectionResult = useRootSelector(selectInspectionResultSelected)
	useEffect(function()
		if signal then
			dispatch(setTracebackCallStack(signal.traceback))
		end
	end, { signal })
	useActionEffect("copy", function()
		if remote then
			local _result = setclipboard
			if _result ~= nil then
				_result(getInstancePath(remote.object))
			end
			notify("Copied remote path to clipboard")
		elseif signal then
			local _result = setclipboard
			if _result ~= nil then
				_result(codifyOutgoingSignal(signal))
			end
			notify("Copied signal to clipboard")
		end
	end)
	useActionEffect("copyPath", function()
		local _result = remote
		if _result ~= nil then
			_result = _result.object
		end
		local _condition = _result
		if _condition == nil then
			_condition = (currentTab and getInstanceFromId(currentTab.id))
		end
		local object = _condition
		if object then
			local _result_1 = setclipboard
			if _result_1 ~= nil then
				_result_1(getInstancePath(object))
			end
		end
	end)
	useActionEffect("save", function()
		if remote then
			local remoteName = string.gsub(string.sub(getInstancePath(remote.object), -66, -1), "[^a-zA-Z0-9]+", "_")
			local fileName = remoteName .. ".txt"
			local fileContents = stringifyRemote(remote)
			local _result = writefile
			if _result ~= nil then
				_result(fileName, fileContents)
			end
			notify("Saved to " .. fileName)
		elseif signal then
			local remote = selectRemoteLog(store:getState(), signal.remoteId)
			local _outgoing = remote.outgoing
			local _arg0 = function(s)
				return s.id == signal.id
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result = -1
			for _i, _v in ipairs(_outgoing) do
				if _arg0(_v, _i - 1, _outgoing) == true then
					_result = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			local signalOrder = _result
			local remoteName = string.gsub(string.sub(getInstancePath(remote.object), -66, -1), "[^a-zA-Z0-9]+", "_")
			local fileName = remoteName .. ("_Signal" .. (tostring(signalOrder + 1) .. ".txt"))
			local fileContents = stringifyRemote(remote, function(s)
				return signal.id == s.id
			end)
			local _result_1 = writefile
			if _result_1 ~= nil then
				_result_1(fileName, fileContents)
			end
			notify("Saved to " .. fileName)
		end
	end)
	local remoteIds
	useActionEffect("delete", function()
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in pairs(multiSelected) do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size > 0 then
			local _arg0 = function(id)
				dispatch(removeRemoteLog(id))
				dispatch(deleteTab(id))
			end
			for _v in pairs(multiSelected) do
				_arg0(_v, _v, multiSelected)
			end
			-- ▼ ReadonlySet.size ▼
			local _size_1 = 0
			for _ in pairs(multiSelected) do
				_size_1 += 1
			end
			-- ▲ ReadonlySet.size ▲
			notify("Deleted " .. (tostring(_size_1) .. " remotes"))
		elseif remote then
			dispatch(removeRemoteLog(remote.id))
			dispatch(deleteTab(remote.id))
			notify("Deleted remote")
		elseif signal then
			dispatch(removeOutgoingSignal(signal.remoteId, signal.id))
			notify("Deleted signal")
		else
			local _result = currentTab
			if _result ~= nil then
				_result = _result.type
			end
			if _result == TabType.Script then
				dispatch(removeScript(currentTab.id))
				dispatch(deleteTab(currentTab.id))
				notify("Deleted script")
			else
				local _result_1 = currentTab
				if _result_1 ~= nil then
					_result_1 = _result_1.type
				end
				local _condition = _result_1 == TabType.Home
				if _condition then
					_condition = not remote and not signal
				end
				if _condition then
					local allRemoteIds = remoteIds
					if #allRemoteIds > 0 then
						local _arg0 = function(id)
							dispatch(removeRemoteLog(id))
							dispatch(deleteTab(id))
						end
						for _k, _v in ipairs(allRemoteIds) do
							_arg0(_v, _k - 1, allRemoteIds)
						end
						notify("Deleted all " .. (tostring(#allRemoteIds) .. " remotes"))
					end
				elseif currentTab and (currentTab.type ~= TabType.Home and (currentTab.type ~= TabType.Settings and currentTab.type ~= TabType.Inspection)) then
					dispatch(deleteTab(currentTab.id))
					notify("Closed tab")
				end
			end
		end
	end)
	useActionEffect("copyScript", function()
		local _result = currentTab
		if _result ~= nil then
			_result = _result.type
		end
		local _condition = _result == TabType.Script
		if _condition then
			_condition = currentTab.scriptContent
		end
		if _condition ~= "" and _condition then
			local _result_1 = setclipboard
			if _result_1 ~= nil then
				_result_1(currentTab.scriptContent)
			end
		elseif signal then
			local paramEntries = {}
			for key, value in pairs(signal.parameters) do
				local _arg0 = { key, value }
				table.insert(paramEntries, _arg0)
			end
			local _arg0 = function(a, b)
				return a[1] < b[1]
			end
			table.sort(paramEntries, _arg0)
			local _arg0_1 = function(_param)
				local _ = _param[1]
				local value = _param[2]
				return value
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#paramEntries)
			for _k, _v in ipairs(paramEntries) do
				_newValue[_k] = _arg0_1(_v, _k - 1, paramEntries)
			end
			-- ▲ ReadonlyArray.map ▲
			local parameters = _newValue
			local scriptText = genScript(signal.remote, parameters, pathNotation)
			local _result_1 = setclipboard
			if _result_1 ~= nil then
				_result_1(scriptText)
			end
			local baseName = signal.name
			local uniqueName = generateUniqueScriptName(baseName, tabs)
			local scriptId = HttpService:GenerateGUID(false)
			local tab = createTabColumn(scriptId, uniqueName, TabType.Script, true)
			dispatch(pushTab(tab))
			dispatch(setActiveTab(scriptId))
			dispatch(setScript(scriptId, {
				id = scriptId,
				name = uniqueName,
				content = scriptText,
				signalId = signal.id,
				remoteId = signal.remoteId,
			}))
			notify("Copied script to clipboard and opened in viewer")
		end
	end)
	useActionEffect("viewScript", function()
		local _result = inspectionResult
		if _result ~= nil then
			_result = _result.rawScript
		end
		if _result then
			local scriptText = ""
			if decompile ~= nil then
				local success = { pcall(function()
					scriptText = decompile(inspectionResult.rawScript)
				end) }
				if not success[1] then
					scriptText = "-- Failed to decompile script\n-- " .. tostring(success[2])
					notify("Failed to decompile script", 3, true)
				end
			else
				scriptText = "-- decompile() function not available"
			end
			local baseName = inspectionResult.name
			local uniqueName = generateUniqueScriptName(baseName, tabs)
			local scriptId = HttpService:GenerateGUID(false)
			local tab = createTabColumn(scriptId, uniqueName, TabType.Script, true)
			dispatch(pushTab(tab))
			dispatch(setActiveTab(scriptId))
			dispatch(setScript(scriptId, {
				id = scriptId,
				name = uniqueName,
				content = scriptText,
			}))
			notify("Opened " .. (uniqueName .. " in script viewer"))
		elseif signal then
			local scriptText = ""
			if signal.caller ~= nil and decompile ~= nil then
				local caller = signal.caller
				local success = { pcall(function()
					scriptText = decompile(caller)
				end) }
				if not success[1] then
					scriptText = "-- Failed to decompile script\n-- " .. tostring(success[2])
					notify("Failed to decompile script", 3, true)
				end
			elseif signal.caller == nil then
				scriptText = "-- No caller script found"
			else
				scriptText = "-- decompile() function not available"
			end
			local _result_1 = signal.caller
			if _result_1 ~= nil then
				_result_1 = _result_1.Name
			end
			local _condition = _result_1
			if _condition == nil then
				_condition = "Script"
			end
			local baseName = _condition
			local uniqueName = generateUniqueScriptName(baseName, tabs)
			local scriptId = HttpService:GenerateGUID(false)
			local tab = createTabColumn(scriptId, uniqueName, TabType.Script, true)
			dispatch(pushTab(tab))
			dispatch(setActiveTab(scriptId))
			dispatch(setScript(scriptId, {
				id = scriptId,
				name = uniqueName,
				content = scriptText,
			}))
			notify("Opened " .. (uniqueName .. " in script viewer"))
		end
	end)
	useActionEffect("traceback", function()
		if signal then
			dispatch(setTracebackCallStack(signal.traceback))
		end
	end)
	useActionEffect("pause", function()
		dispatch(togglePaused())
	end)
	remoteIds = useRootSelector(selectRemoteLogIds)
	local paused = useRootSelector(selectPaused)
	local pausedRemotes = useRootSelector(selectPausedRemotes)
	local blockedRemotes = useRootSelector(selectBlockedRemotes)
	useActionEffect("navigatePrevious", function()
		if remoteId ~= nil then
			local currentIndex = (table.find(remoteIds, remoteId) or 0) - 1
			if currentIndex > 0 then
				dispatch(setRemoteSelected(remoteIds[currentIndex - 1 + 1]))
			end
		elseif #remoteIds > 0 then
			dispatch(setRemoteSelected(remoteIds[#remoteIds - 1 + 1]))
		end
	end)
	useActionEffect("navigateNext", function()
		if remoteId ~= nil then
			local currentIndex = (table.find(remoteIds, remoteId) or 0) - 1
			if currentIndex < #remoteIds - 1 then
				dispatch(setRemoteSelected(remoteIds[currentIndex + 1 + 1]))
			end
		elseif #remoteIds > 0 then
			dispatch(setRemoteSelected(remoteIds[1]))
		end
	end)
	useActionEffect("pauseRemote", function()
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in pairs(multiSelected) do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size > 0 then
			local _arg0 = function(id)
				dispatch(toggleRemotePaused(id))
			end
			for _v in pairs(multiSelected) do
				_arg0(_v, _v, multiSelected)
			end
			-- ▼ ReadonlySet.size ▼
			local _size_1 = 0
			for _ in pairs(multiSelected) do
				_size_1 += 1
			end
			-- ▲ ReadonlySet.size ▲
			notify("Toggled pause for " .. (tostring(_size_1) .. " remotes"))
		else
			local _condition = remoteId
			if _condition == nil then
				_condition = (if currentTab and (currentTab.type == TabType.Event or (currentTab.type == TabType.Function or (currentTab.type == TabType.BindableEvent or currentTab.type == TabType.BindableFunction))) then currentTab.id else nil)
			end
			local targetId = _condition
			if targetId ~= nil then
				dispatch(toggleRemotePaused(targetId))
				local isPaused = pausedRemotes[targetId] ~= nil
				notify(if isPaused then "Unpaused remote" else "Paused remote")
			end
		end
	end)
	useActionEffect("blockRemote", function()
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in pairs(multiSelected) do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		if _size > 0 then
			local _arg0 = function(id)
				dispatch(toggleRemoteBlocked(id))
			end
			for _v in pairs(multiSelected) do
				_arg0(_v, _v, multiSelected)
			end
			-- ▼ ReadonlySet.size ▼
			local _size_1 = 0
			for _ in pairs(multiSelected) do
				_size_1 += 1
			end
			-- ▲ ReadonlySet.size ▲
			notify("Toggled block for " .. (tostring(_size_1) .. " remotes"))
		else
			local _condition = remoteId
			if _condition == nil then
				_condition = (if currentTab and (currentTab.type == TabType.Event or (currentTab.type == TabType.Function or (currentTab.type == TabType.BindableEvent or currentTab.type == TabType.BindableFunction))) then currentTab.id else nil)
			end
			local targetId = _condition
			if targetId ~= nil then
				dispatch(toggleRemoteBlocked(targetId))
				local isBlocked = blockedRemotes[targetId] ~= nil
				notify(if isBlocked then "Unblocked remote" else "Blocked remote")
			end
		end
	end)
	useActionEffect("blockAll", function()
		dispatch(toggleBlockAllRemotes())
		notify("Toggled block all remotes")
	end)
	useActionEffect("runRemote", function()
		local scriptText
		local signalToRun = signal
		local _result = currentTab
		if _result ~= nil then
			_result = _result.type
		end
		if _result == TabType.Script then
			local scriptData = store:getState().script.scripts[currentTab.id]
			local _result_1 = scriptData
			if _result_1 ~= nil then
				_result_1 = _result_1.content
			end
			if _result_1 ~= "" and _result_1 then
				scriptText = scriptData.content
				local _condition = scriptData.signalId
				if _condition ~= "" and _condition then
					_condition = scriptData.remoteId
				end
				if _condition ~= "" and _condition then
					local remoteLog = selectRemoteLog(store:getState(), scriptData.remoteId)
					local _result_2 = remoteLog
					if _result_2 ~= nil then
						local _outgoing = _result_2.outgoing
						local _arg0 = function(s)
							return s.id == scriptData.signalId
						end
						-- ▼ ReadonlyArray.find ▼
						local _result_3
						for _i, _v in ipairs(_outgoing) do
							if _arg0(_v, _i - 1, _outgoing) == true then
								_result_3 = _v
								break
							end
						end
						-- ▲ ReadonlyArray.find ▲
						_result_2 = _result_3
					end
					signalToRun = _result_2
				end
			end
		end
		if not (scriptText ~= "" and scriptText) and signalToRun then
			local paramEntries = {}
			for key, value in pairs(signalToRun.parameters) do
				local _arg0 = { key, value }
				table.insert(paramEntries, _arg0)
			end
			local _arg0 = function(a, b)
				return a[1] < b[1]
			end
			table.sort(paramEntries, _arg0)
			local _arg0_1 = function(_param)
				local _ = _param[1]
				local value = _param[2]
				return value
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#paramEntries)
			for _k, _v in ipairs(paramEntries) do
				_newValue[_k] = _arg0_1(_v, _k - 1, paramEntries)
			end
			-- ▲ ReadonlyArray.map ▲
			local parameters = _newValue
			scriptText = genScript(signalToRun.remote, parameters, pathNotation)
		end
		if scriptText ~= "" and scriptText then
			if loadstring then
				local func, err = loadstring(scriptText)
				if func then
					local success, result = pcall(func)
					if not success then
						notify("Failed to run remote: " .. tostring(result), 3, true)
					else
						notify("Executed remote successfully")
					end
				else
					notify("Failed to load remote script: " .. tostring(err), 3, true)
				end
			else
				notify("loadstring function not available", 3, true)
			end
		end
	end)
	useEffect(function()
		local isRemoteTab = not not (currentTab and (currentTab.type == TabType.Event or (currentTab.type == TabType.Function or (currentTab.type == TabType.BindableEvent or currentTab.type == TabType.BindableFunction))))
		local remoteEnabled = remoteId ~= nil or isRemoteTab
		local _condition = signal ~= nil
		if _condition then
			local _result = currentTab
			if _result ~= nil then
				_result = _result.id
			end
			_condition = _result == signal.remoteId
		end
		local signalEnabled = _condition
		local _result = currentTab
		if _result ~= nil then
			_result = _result.type
		end
		local isHome = _result == TabType.Home
		local _result_1 = currentTab
		if _result_1 ~= nil then
			_result_1 = _result_1.type
		end
		local isScript = _result_1 == TabType.Script
		local _result_2 = currentTab
		if _result_2 ~= nil then
			_result_2 = _result_2.type
		end
		local isSettings = _result_2 == TabType.Settings
		local _result_3 = currentTab
		if _result_3 ~= nil then
			_result_3 = _result_3.type
		end
		local isInspection = _result_3 == TabType.Inspection
		-- ▼ ReadonlySet.size ▼
		local _size = 0
		for _ in pairs(multiSelected) do
			_size += 1
		end
		-- ▲ ReadonlySet.size ▲
		local hasMultiSelect = _size > 0
		local _condition_1 = isScript
		if _condition_1 then
			local _result_4 = currentTab
			if _result_4 ~= nil then
				_result_4 = _result_4.id
			end
			_condition_1 = _result_4
		end
		local _result_4
		if _condition_1 ~= "" and _condition_1 then
			local _result_5 = store:getState().script.scripts[currentTab.id]
			if _result_5 ~= nil then
				_result_5 = _result_5.signalId
			end
			_result_4 = _result_5 ~= nil
		else
			_result_4 = false
		end
		local scriptHasSignal = _result_4
		local hasRemotesToDelete = isHome and #remoteIds > 0
		local canDelete = hasMultiSelect or (remoteEnabled or (signalEnabled or (hasRemotesToDelete or not not (currentTab and (not isHome and (not isSettings and not isInspection))))))
		dispatch(setActionEnabled("copy", remoteEnabled or signalEnabled))
		dispatch(setActionEnabled("save", remoteEnabled or signalEnabled))
		dispatch(setActionEnabled("delete", canDelete))
		dispatch(setActionEnabled("traceback", signalEnabled))
		dispatch(setActionEnabled("copyPath", remoteEnabled or not isHome))
		dispatch(setActionEnabled("copyScript", signalEnabled))
		local _condition_2 = signalEnabled
		if not _condition_2 then
			local _condition_3 = isInspection
			if _condition_3 then
				local _result_5 = inspectionResult
				if _result_5 ~= nil then
					_result_5 = _result_5.rawScript
				end
				_condition_3 = _result_5 ~= nil
			end
			_condition_2 = _condition_3
		end
		dispatch(setActionEnabled("viewScript", _condition_2))
		dispatch(setActionEnabled("pauseRemote", hasMultiSelect or remoteEnabled))
		dispatch(setActionEnabled("blockRemote", hasMultiSelect or remoteEnabled))
		dispatch(setActionEnabled("runRemote", signalEnabled or scriptHasSignal))
	end, { remoteId == nil, signal, currentTab, multiSelected, inspectionResult })
	local allLogs = useRootSelector(selectRemoteLogs)
	useEffect(function()
		dispatch(setActionCaption("pause", if paused then "Resume" else "Pause"))
		local _condition = remoteId
		if _condition == nil then
			_condition = (if currentTab and (currentTab.type == TabType.Event or (currentTab.type == TabType.Function or (currentTab.type == TabType.BindableEvent or currentTab.type == TabType.BindableFunction))) then currentTab.id else nil)
		end
		local currentRemoteId = _condition
		if currentRemoteId ~= nil then
			local isRemotePaused = pausedRemotes[currentRemoteId] ~= nil
			dispatch(setActionCaption("pauseRemote", if isRemotePaused then "Resume Remote" else "Pause Remote"))
		else
			dispatch(setActionCaption("pauseRemote", "Pause Remote"))
		end
		if currentRemoteId ~= nil then
			local isRemoteBlocked = blockedRemotes[currentRemoteId] ~= nil
			dispatch(setActionCaption("blockRemote", if isRemoteBlocked then "Unblock Remote" else "Block Remote"))
		else
			dispatch(setActionCaption("blockRemote", "Block Remote"))
		end
		local _condition_1 = #allLogs > 0
		if _condition_1 then
			local _arg0 = function(log)
				local _id = log.id
				return blockedRemotes[_id] ~= nil
			end
			-- ▼ ReadonlyArray.every ▼
			local _result = true
			for _k, _v in ipairs(allLogs) do
				if not _arg0(_v, _k - 1, allLogs) then
					_result = false
					break
				end
			end
			-- ▲ ReadonlyArray.every ▲
			_condition_1 = _result
		end
		local allBlocked = _condition_1
		dispatch(setActionCaption("blockAll", if allBlocked then "Unblock All" else "Block All"))
	end, { paused, pausedRemotes, blockedRemotes, remoteId, currentTab, allLogs })
	return Roact.createFragment()
end
local default = withHooksPure(ActionBarEffects)
return {
	default = default,
}
 end, _env("RemoteSpy.components.ActionBar.ActionBarEffects"))() end)

_module("ActionButton", "ModuleScript", "RemoteSpy.components.ActionBar.ActionButton", "RemoteSpy.components.ActionBar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent, "Button").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _action_bar = TS.import(script, script.Parent.Parent.Parent, "reducers", "action-bar")
local activateAction = _action_bar.activateAction
local selectActionById = _action_bar.selectActionById
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local TextService = TS.import(script, TS.getModule(script, "@rbxts", "services")).TextService
local useGroupMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useGroupMotor
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local MARGIN = 10
local BUTTON_DEFAULT = { Spring.new(1, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local BUTTON_HOVERED = { Spring.new(0.94, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local BUTTON_PRESSED = { Instant.new(0.96), Instant.new(0.2) }
local function ActionButton(_param)
	local id = _param.id
	local icon = _param.icon
	local caption = _param.caption
	local layoutOrder = _param.layoutOrder
	local dispatch = useRootDispatch()
	local actionState = useRootSelector(function(state)
		return selectActionById(state, id)
	end)
	local _binding = useGroupMotor({ 1, 0 })
	local transparency = _binding[1]
	local setGoal = _binding[2]
	local backgroundTransparency = if actionState.disabled then 1 else transparency:map(function(t)
		return t[1]
	end)
	local foregroundTransparency = if actionState.disabled then 0.5 else transparency:map(function(t)
		return t[2]
	end)
	local _condition = actionState.caption
	if _condition == nil then
		_condition = caption
	end
	local displayCaption = _condition
	local textSize = useMemo(function()
		return if displayCaption ~= nil then TextService:GetTextSize(displayCaption, 11, "Gotham", Vector2.new(150, 36)) else Vector2.new()
	end, { displayCaption })
	local _attributes = {
		layoutOrder = layoutOrder,
		onClick = function()
			setGoal(BUTTON_HOVERED)
			local _ = not actionState.disabled and (not actionState.active and dispatch(activateAction(id)))
		end,
		onPress = function()
			return setGoal(BUTTON_PRESSED)
		end,
		onHover = function()
			return setGoal(BUTTON_HOVERED)
		end,
		onHoverEnd = function()
			return setGoal(BUTTON_DEFAULT)
		end,
		active = not actionState.disabled,
		size = UDim2.new(0, if displayCaption ~= nil then textSize.X + (if icon ~= nil then 16 + MARGIN * 3 else MARGIN * 2) else 36, 0, 36),
		transparency = backgroundTransparency,
		cornerRadius = UDim.new(0, 4),
	}
	local _children = {}
	local _length = #_children
	local _child = icon ~= nil and (Roact.createElement("ImageLabel", {
		Image = icon,
		ImageTransparency = foregroundTransparency,
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, MARGIN, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
	}))
	if _child then
		_children[_length + 1] = _child
	end
	_length = #_children
	local _child_1 = displayCaption ~= nil and (Roact.createElement("TextLabel", {
		Text = displayCaption,
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = foregroundTransparency,
		TextSize = 11,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, if icon ~= nil then MARGIN * 2 + 16 else MARGIN, 0, 0),
		BackgroundTransparency = 1,
	}))
	if _child_1 then
		_children[_length + 1] = _child_1
	end
	return Roact.createElement(Button, _attributes, _children)
end
local default = withHooksPure(ActionButton)
return {
	default = default,
}
 end, _env("RemoteSpy.components.ActionBar.ActionButton"))() end)

_module("ActionLine", "ModuleScript", "RemoteSpy.components.ActionBar.ActionLine", "RemoteSpy.components.ActionBar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function ActionLine(_param)
	local order = _param.order
	return Roact.createElement(Container, {
		size = UDim2.new(0, 13, 0, 32),
		order = order,
	}, {
		Roact.createElement("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.92,
			Size = UDim2.new(0, 1, 0, 24),
			Position = UDim2.new(0, 6, 0, 4),
			BorderSizePixel = 0,
		}),
	})
end
return {
	default = ActionLine,
}
 end, _env("RemoteSpy.components.ActionBar.ActionLine"))() end)

_module("utils", "ModuleScript", "RemoteSpy.components.ActionBar.utils", "RemoteSpy.components.ActionBar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local stringifySignalTraceback = TS.import(script, script.Parent.Parent.Parent, "reducers", "remote-log").stringifySignalTraceback
local codifyTable = TS.import(script, script.Parent.Parent.Parent, "utils", "codify").codifyTable
local _function_util = TS.import(script, script.Parent.Parent.Parent, "utils", "function-util")
local describeFunction = _function_util.describeFunction
local stringifyFunctionSignature = _function_util.stringifyFunctionSignature
local getInstancePath = TS.import(script, script.Parent.Parent.Parent, "utils", "instance-util").getInstancePath
local line = "-----------------------------------------------------"
local stringifyOutgoingSignal
local function stringifyRemote(remote, filter)
	local lines = {}
	local _arg0 = "Remote name: " .. remote.object.Name
	table.insert(lines, _arg0)
	local _arg0_1 = "Remote type: " .. remote.object.ClassName
	table.insert(lines, _arg0_1)
	local _arg0_2 = "Remote location: " .. getInstancePath(remote.object)
	table.insert(lines, _arg0_2)
	local _outgoing = remote.outgoing
	local _arg0_3 = function(signal, index)
		if if filter then filter(signal) else true then
			local _arg0_4 = line .. "\n" .. stringifyOutgoingSignal(signal, index)
			table.insert(lines, _arg0_4)
		end
	end
	for _k, _v in ipairs(_outgoing) do
		_arg0_3(_v, _k - 1, _outgoing)
	end
	return table.concat(lines, "\n")
end
function stringifyOutgoingSignal(signal, index)
	local lines = {}
	local description = describeFunction(signal.callback)
	if index ~= nil then
		local _arg0 = "(OUTGOING SIGNAL " .. (tostring(index + 1) .. ")")
		table.insert(lines, _arg0)
	end
	local _arg0 = "Calling script: " .. (if signal.caller then signal.caller.Name else "Not called from a script")
	table.insert(lines, _arg0)
	local _arg0_1 = "Remote name: " .. signal.name
	table.insert(lines, _arg0_1)
	local _arg0_2 = "Remote location: " .. signal.pathFmt
	table.insert(lines, _arg0_2)
	local _arg0_3 = "Remote parameters: " .. codifyTable(signal.parameters)
	table.insert(lines, _arg0_3)
	local _arg0_4 = "Function signature: " .. stringifyFunctionSignature(signal.callback)
	table.insert(lines, _arg0_4)
	local _arg0_5 = "Function source: " .. description.source
	table.insert(lines, _arg0_5)
	table.insert(lines, "Function traceback:")
	for _, line in ipairs(stringifySignalTraceback(signal)) do
		local _arg0_6 = "	" .. line
		table.insert(lines, _arg0_6)
	end
	return table.concat(lines, "\n")
end
local function codifyOutgoingSignal(signal)
	local lines = {}
	local _arg0 = "local remote = " .. signal.pathFmt
	table.insert(lines, _arg0)
	local _arg0_1 = "local arguments = " .. codifyTable(signal.parameters)
	table.insert(lines, _arg0_1)
	if signal.remote:IsA("RemoteEvent") then
		table.insert(lines, "remote:FireServer(unpack(arguments))")
	else
		table.insert(lines, "local results = remote:InvokeServer(unpack(arguments))")
	end
	return table.concat(lines, "\n\n")
end
return {
	stringifyRemote = stringifyRemote,
	stringifyOutgoingSignal = stringifyOutgoingSignal,
	codifyOutgoingSignal = codifyOutgoingSignal,
}
 end, _env("RemoteSpy.components.ActionBar.utils"))() end)

_module("App", "ModuleScript", "RemoteSpy.components.App", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "App").default
return exports
 end, _env("RemoteSpy.components.App"))() end)

_module("App", "ModuleScript", "RemoteSpy.components.App.App", "RemoteSpy.components.App", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local KeybindListener = TS.import(script, script.Parent.Parent, "KeybindListener").default
local MainWindow = TS.import(script, script.Parent.Parent, "MainWindow").default
local SettingsPersistence = TS.import(script, script.Parent.Parent, "SettingsPersistence").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function App()
	return Roact.createFragment({
		Roact.createElement(KeybindListener),
		Roact.createElement(MainWindow),
		Roact.createElement(SettingsPersistence),
	})
end
return {
	default = App,
}
 end, _env("RemoteSpy.components.App.App"))() end)

_module("App.story", "ModuleScript", "RemoteSpy.components.App.App.story", "RemoteSpy.components.App", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local App = TS.import(script, script.Parent, "App").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local StoreProvider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").src).StoreProvider
local configureStore = TS.import(script, script.Parent.Parent.Parent, "store").configureStore
local _remote_log = TS.import(script, script.Parent.Parent.Parent, "reducers", "remote-log")
local createOutgoingSignal = _remote_log.createOutgoingSignal
local createRemoteLog = _remote_log.createRemoteLog
local pushOutgoingSignal = _remote_log.pushOutgoingSignal
local pushRemoteLog = _remote_log.pushRemoteLog
local getInstanceId = TS.import(script, script.Parent.Parent.Parent, "utils", "instance-util").getInstanceId
local useRootDispatch = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootDispatch
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local rng = Random.new()
local function testFn(x, y)
end
local function testFnCaller(x, ...)
	local args = { ... }
	testFn()
end
local function topLevelCaller(x, y, z)
	testFnCaller()
end
local Dispatcher = withHooksPure(function()
	local dispatch = useRootDispatch()
	local names = { "SendMessage", "UpdateCameraLook", "TryGetValue", "GetEnumerator", "ToString", "RequestStoreState", "ReallyLongNameForSomeReason \n ☆*: .｡. o(≧▽≦)o .｡.:*☆ \n Lol", "PurchaseProduct", "IsMessaging", "TestDispatcher", "RequestAction" }
	for _, name in ipairs(names) do
		local className = if rng:NextInteger(0, 1) == 1 then "RemoteEvent" else "RemoteFunction"
		local remote = {
			Name = name,
			ClassName = className,
			Parent = game:GetService("ReplicatedStorage"),
			IsA = function(self, name)
				return className == name
			end,
			GetFullName = function(self)
				return "ReplicatedStorage." .. name
			end,
		}
		dispatch(pushRemoteLog(createRemoteLog(remote)))
		local max = rng:NextInteger(-3, 30)
		do
			local i = 0
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i < max) then
					break
				end
				if i < 0 then
					break
				end
				local signal = createOutgoingSignal(remote, nil, testFn, { testFn, testFnCaller, topLevelCaller }, { "Hello", rng:NextInteger(100, 1000), {
					message = "Hello, world!",
					receivers = {},
				}, rng:NextInteger(100, 1000), game:GetService("Workspace") })
				dispatch(pushOutgoingSignal(getInstanceId(remote), signal))
			end
		end
	end
	return Roact.createFragment()
end)
return function(target)
	local handle = Roact.mount(Roact.createElement(StoreProvider, {
		store = configureStore(),
	}, {
		Roact.createElement(Dispatcher),
		Roact.createElement(App),
	}), target, "App")
	return function()
		Roact.unmount(handle)
	end
end
 end, _env("RemoteSpy.components.App.App.story"))() end)

_module("Button", "ModuleScript", "RemoteSpy.components.Button", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function Button(props)
	local _attributes = {
		[Roact.Event.Activated] = props.onClick,
		[Roact.Event.MouseButton1Down] = props.onPress,
		[Roact.Event.MouseButton1Up] = props.onRelease,
		[Roact.Event.MouseEnter] = props.onHover,
		[Roact.Event.MouseLeave] = props.onHoverEnd,
		Active = props.active,
		BackgroundColor3 = props.background or Color3.new(1, 1, 1),
	}
	local _condition = props.transparency
	if _condition == nil then
		_condition = 1
	end
	_attributes.BackgroundTransparency = _condition
	_attributes.Size = props.size
	_attributes.Position = props.position
	_attributes.AnchorPoint = props.anchorPoint
	_attributes.ZIndex = props.zIndex
	_attributes.LayoutOrder = props.layoutOrder
	_attributes.Text = ""
	_attributes.BorderSizePixel = 0
	_attributes.AutoButtonColor = false
	local _children = {}
	local _length = #_children
	local _child = props[Roact.Children]
	if _child then
		for _k, _v in pairs(_child) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	_length = #_children
	local _child_1 = props.cornerRadius and Roact.createElement("UICorner", {
		CornerRadius = props.cornerRadius,
	})
	if _child_1 then
		_children[_length + 1] = _child_1
	end
	return Roact.createElement("TextButton", _attributes, _children)
end
return {
	default = Button,
}
 end, _env("RemoteSpy.components.Button"))() end)

_module("Container", "ModuleScript", "RemoteSpy.components.Container", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function Container(_param)
	local size = _param.size
	if size == nil then
		size = UDim2.new(1, 0, 1, 0)
	end
	local position = _param.position
	local anchorPoint = _param.anchorPoint
	local order = _param.order
	local clipChildren = _param.clipChildren
	local children = _param[Roact.Children]
	local _attributes = {
		Size = size,
		Position = position,
		AnchorPoint = anchorPoint,
		LayoutOrder = order,
		ClipsDescendants = clipChildren,
		BackgroundTransparency = 1,
	}
	local _children = {}
	local _length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement("Frame", _attributes, _children)
end
return {
	default = Container,
}
 end, _env("RemoteSpy.components.Container"))() end)

_module("KeybindListener", "ModuleScript", "RemoteSpy.components.KeybindListener", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "KeybindListener").default
return exports
 end, _env("RemoteSpy.components.KeybindListener"))() end)

_module("KeybindListener", "ModuleScript", "RemoteSpy.components.KeybindListener.KeybindListener", "RemoteSpy.components.KeybindListener", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local selectToggleKey = TS.import(script, script.Parent.Parent.Parent, "reducers", "ui").selectToggleKey
local toggleUIVisibility = TS.import(script, script.Parent.Parent.Parent, "reducers", "ui").toggleUIVisibility
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local withHooksPure = _roact_hooked.withHooksPure
local useEffect = _roact_hooked.useEffect
local function KeybindListener()
	local dispatch = useRootDispatch()
	local toggleKey = useRootSelector(selectToggleKey)
	useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return nil
			end
			if input.KeyCode == toggleKey then
				dispatch(toggleUIVisibility())
			end
		end)
		return function()
			connection:Disconnect()
		end
	end, { toggleKey })
	return nil
end
local default = withHooksPure(KeybindListener)
return {
	default = default,
}
 end, _env("RemoteSpy.components.KeybindListener.KeybindListener"))() end)

_module("MainWindow", "ModuleScript", "RemoteSpy.components.MainWindow", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "MainWindow").default
return exports
 end, _env("RemoteSpy.components.MainWindow"))() end)

_module("MainWindow", "ModuleScript", "RemoteSpy.components.MainWindow.MainWindow", "RemoteSpy.components.MainWindow", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Acrylic = TS.import(script, script.Parent.Parent, "Acrylic").default
local ActionBar = TS.import(script, script.Parent.Parent, "ActionBar").default
local Pages = TS.import(script, script.Parent.Parent, "Pages").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Root = TS.import(script, script.Parent.Parent, "Root").default
local SidePanel = TS.import(script, script.Parent.Parent, "SidePanel").default
local Tabs = TS.import(script, script.Parent.Parent, "Tabs").default
local Window = TS.import(script, script.Parent.Parent, "Window").default
local activateAction = TS.import(script, script.Parent.Parent.Parent, "reducers", "action-bar").activateAction
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local selectUIVisible = TS.import(script, script.Parent.Parent.Parent, "reducers", "ui").selectUIVisible
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local function MainWindow()
	local dispatch = useRootDispatch()
	local visible = useRootSelector(selectUIVisible)
	return Roact.createElement(Root, {
		enabled = visible,
	}, {
		Roact.createElement(Window.Root, {
			initialSize = UDim2.new(0, 1000, 0, 600),
			initialPosition = UDim2.new(0.5, -540, 0.5, -350),
		}, {
			Roact.createElement(Window.DropShadow),
			Roact.createElement(Acrylic.Paint),
			Roact.createElement(ActionBar),
			Roact.createElement(SidePanel),
			Roact.createElement(Tabs),
			Roact.createElement(Pages),
			Roact.createElement(Window.TitleBar, {
				onClose = function()
					return dispatch(activateAction("close"))
				end,
				caption = '<font color="#FFFFFF">Wavified Spy</font>    <font color="#B2B2B2">' .. ("1.0.0 Alpha" .. "</font>"),
				captionTransparency = 0.1,
				icon = "rbxassetid://133291240952158",
			}),
			Roact.createElement(Window.Resize, {
				minSize = Vector2.new(650, 450),
			}),
		}),
	})
end
local default = withHooksPure(MainWindow)
return {
	default = default,
}
 end, _env("RemoteSpy.components.MainWindow.MainWindow"))() end)

_module("MainWindow.story", "ModuleScript", "RemoteSpy.components.MainWindow.MainWindow.story", "RemoteSpy.components.MainWindow", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local MainWindow = TS.import(script, script.Parent, "MainWindow").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local StoreProvider = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").src).StoreProvider
local configureStore = TS.import(script, script.Parent.Parent.Parent, "store").configureStore
return function(target)
	local handle = Roact.mount(Roact.createElement(StoreProvider, {
		store = configureStore(),
	}, {
		Roact.createElement(MainWindow),
	}), target, "MainWindow")
	return function()
		Roact.unmount(handle)
	end
end
 end, _env("RemoteSpy.components.MainWindow.MainWindow.story"))() end)

_module("Pages", "ModuleScript", "RemoteSpy.components.Pages", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Pages").default
return exports
 end, _env("RemoteSpy.components.Pages"))() end)

_module("Home", "ModuleScript", "RemoteSpy.components.Pages.Home", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Home").default
return exports
 end, _env("RemoteSpy.components.Pages.Home"))() end)

_module("Home", "ModuleScript", "RemoteSpy.components.Pages.Home.Home", "RemoteSpy.components.Pages.Home", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Row = TS.import(script, script.Parent, "Row").default
local Selection = TS.import(script, script.Parent.Parent.Parent, "Selection").default
local arrayToMap = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).arrayToMap
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local selectRemoteIdSelected = _remote_log.selectRemoteIdSelected
local selectRemoteLogIds = _remote_log.selectRemoteLogIds
local selectRemotesMultiSelected = _remote_log.selectRemotesMultiSelected
local _remote_log_1 = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local setRemoteSelected = _remote_log_1.setRemoteSelected
local toggleRemoteMultiSelected = _remote_log_1.toggleRemoteMultiSelected
local clearMultiSelection = _remote_log_1.clearMultiSelection
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local withHooksPure = _roact_hooked.withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local function Home(_param)
	local pageSelected = _param.pageSelected
	local dispatch = useRootDispatch()
	local remoteLogIds = useRootSelector(selectRemoteLogIds)
	local selection = useRootSelector(selectRemoteIdSelected)
	local multiSelected = useRootSelector(selectRemotesMultiSelected)
	useEffect(function()
		local _value = not pageSelected and selection
		if _value ~= "" and _value then
			dispatch(setRemoteSelected(nil))
		end
		local _condition = not pageSelected
		if _condition then
			-- ▼ ReadonlySet.size ▼
			local _size = 0
			for _ in pairs(multiSelected) do
				_size += 1
			end
			-- ▲ ReadonlySet.size ▲
			_condition = _size > 0
		end
		if _condition then
			dispatch(clearMultiSelection())
		end
	end, { pageSelected })
	useEffect(function()
		if selection ~= nil and not (table.find(remoteLogIds, selection) ~= nil) then
			dispatch(setRemoteSelected(nil))
		end
	end, { remoteLogIds })
	local selectionOrder = if selection ~= nil then (table.find(remoteLogIds, selection) or 0) - 1 else -1
	local _attributes = {
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, (#remoteLogIds + 1) * (64 + 4)),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
		}),
		Roact.createElement(Selection, {
			height = 64,
			offset = if selectionOrder ~= -1 then selectionOrder * (64 + 4) else nil,
			hasSelection = selection ~= nil,
		}),
	}
	local _length = #_children
	for _k, _v in pairs(arrayToMap(remoteLogIds, function(id, order)
		return { id, Roact.createElement(Row, {
			id = id,
			order = order,
			selected = selection == id,
			multiSelected = multiSelected[id] ~= nil,
			onClick = function()
				local isCtrlHeld = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
				if isCtrlHeld then
					dispatch(toggleRemoteMultiSelected(id))
				else
					if selection ~= id then
						dispatch(setRemoteSelected(id))
					else
						dispatch(setRemoteSelected(nil))
					end
					-- ▼ ReadonlySet.size ▼
					local _0 = 0
					for _1 in pairs(multiSelected) do
						_0 += 1
					end
					-- ▲ ReadonlySet.size ▲
					if _0 > 0 then
						dispatch(clearMultiSelection())
					end
				end
			end,
		}) }
	end)) do
		_children[_k] = _v
	end
	return Roact.createElement("ScrollingFrame", _attributes, _children)
end
local default = withHooksPure(Home)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Home.Home"))() end)

_module("Row", "ModuleScript", "RemoteSpy.components.Pages.Home.Row", "RemoteSpy.components.Pages.Home", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent, "Button").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local _tab_group = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "tab-group")
local TabType = _tab_group.TabType
local createTabColumn = _tab_group.createTabColumn
local pushTab = _tab_group.pushTab
local selectTab = _tab_group.selectTab
local setActiveTab = _tab_group.setActiveTab
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local getInstancePath = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "instance-util").getInstancePath
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local makeSelectRemoteLogObject = _remote_log.makeSelectRemoteLogObject
local makeSelectRemoteLogOutgoing = _remote_log.makeSelectRemoteLogOutgoing
local makeSelectRemoteLogType = _remote_log.makeSelectRemoteLogType
local multiply = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "number-util").multiply
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useCallback = _roact_hooked.useCallback
local useMemo = _roact_hooked.useMemo
local useMutable = _roact_hooked.useMutable
local withHooksPure = _roact_hooked.withHooksPure
local _roact_hooked_plus = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out)
local useGroupMotor = _roact_hooked_plus.useGroupMotor
local useSpring = _roact_hooked_plus.useSpring
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootSelector = _use_root_store.useRootSelector
local useRootStore = _use_root_store.useRootStore
local ROW_DEFAULT = { Spring.new(1, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local ROW_HOVERED = { Spring.new(0.95, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local ROW_PRESSED = { Instant.new(0.97), Instant.new(0.2) }
local function Row(_param)
	local onClick = _param.onClick
	local id = _param.id
	local order = _param.order
	local selected = _param.selected
	local multiSelected = _param.multiSelected
	local store = useRootStore()
	local selectType = useMemo(makeSelectRemoteLogType, {})
	local remoteType = useRootSelector(function(state)
		return selectType(state, id)
	end)
	local selectObject = useMemo(makeSelectRemoteLogObject, {})
	local remoteObject = useRootSelector(function(state)
		return selectObject(state, id)
	end)
	local selectOutgoing = useMemo(makeSelectRemoteLogOutgoing, {})
	local outgoing = useRootSelector(function(state)
		return selectOutgoing(state, id)
	end)
	local _binding = useGroupMotor({ 1, 0 })
	local transparency = _binding[1]
	local setGoal = _binding[2]
	local backgroundTransparency = transparency:map(function(t)
		return t[1]
	end)
	local foregroundTransparency = transparency:map(function(t)
		return t[2]
	end)
	local highlight = useSpring(if selected then 0.95 else 1, {
		frequency = 6,
	})
	local yOffset = useSpring(order * (64 + 4), {
		frequency = 6,
	})
	local lastClickTime = useMutable(0)
	local openOnDoubleClick = useCallback(function()
		if not remoteObject then
			return nil
		end
		local now = tick()
		if now - lastClickTime.current > 0.3 then
			lastClickTime.current = now
			return false
		end
		lastClickTime.current = now
		if selectTab(store:getState(), id) == nil then
			local tab = createTabColumn(id, remoteObject.Name, remoteType)
			store:dispatch(pushTab(tab))
		end
		store:dispatch(setActiveTab(id))
		return true
	end, { id })
	if not remoteObject then
		return Roact.createFragment()
	end
	local _attributes = {
		onClick = function()
			setGoal(ROW_HOVERED)
			local _ = (not openOnDoubleClick() or selected) and onClick()
		end,
		onPress = function()
			return setGoal(ROW_PRESSED)
		end,
		onHover = function()
			return setGoal(ROW_HOVERED)
		end,
		onHoverEnd = function()
			return setGoal(ROW_DEFAULT)
		end,
		size = UDim2.new(1, 0, 0, 64),
		position = yOffset:map(function(y)
			return UDim2.new(0, 0, 0, y)
		end),
		transparency = backgroundTransparency,
		cornerRadius = UDim.new(0, 4),
		layoutOrder = order,
	}
	local _children = {
		Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = highlight,
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
		}),
	}
	local _length = #_children
	local _child = multiSelected and (Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Roact.createElement("UIStroke", {
			Color = Color3.fromRGB(0, 170, 255),
			Thickness = 2,
		}),
	}))
	if _child then
		_children[_length + 1] = _child
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement("ImageLabel", {
		Image = if remoteType == TabType.Event then "rbxassetid://111467142036224" elseif remoteType == TabType.Function then "rbxassetid://104664672211257" elseif remoteType == TabType.BindableEvent then "rbxassetid://76270109328460" elseif remoteType == TabType.BindableFunction then "rbxassetid://87985191222737" else "",
		ImageTransparency = foregroundTransparency,
		Size = UDim2.new(0, 24, 0, 24),
		Position = UDim2.new(0, 18, 0, 20),
		BackgroundTransparency = 1,
	})
	_children[_length + 2] = Roact.createElement("TextLabel", {
		Text = formatEscapes(if outgoing and #outgoing > 0 then remoteObject.Name .. (" • " .. tostring(#outgoing)) else remoteObject.Name),
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = foregroundTransparency,
		TextSize = 13,
		TextXAlignment = "Left",
		TextYAlignment = "Bottom",
		Size = UDim2.new(1, -100, 0, 12),
		Position = UDim2.new(0, 58, 0, 18),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 1) }),
		}),
	})
	_children[_length + 3] = Roact.createElement("TextLabel", {
		Text = formatEscapes(getInstancePath(remoteObject)),
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = foregroundTransparency:map(function(t)
			return multiply(t, 0.2)
		end),
		TextSize = 11,
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		Size = UDim2.new(1, -100, 0, 12),
		Position = UDim2.new(0, 58, 0, 39),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("UIGradient", {
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 1) }),
		}),
	})
	_children[_length + 4] = Roact.createElement("ImageLabel", {
		Image = "rbxassetid://9913448173",
		ImageTransparency = foregroundTransparency,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -18, 0, 24),
		BackgroundTransparency = 1,
	})
	return Roact.createElement(Button, _attributes, _children)
end
local default = withHooksPure(Row)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Home.Row"))() end)

_module("Inspection", "ModuleScript", "RemoteSpy.components.Pages.Inspection", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Inspection").default
return exports
 end, _env("RemoteSpy.components.Pages.Inspection"))() end)

_module("Inspection", "ModuleScript", "RemoteSpy.components.Pages.Inspection.Inspection", "RemoteSpy.components.Pages.Inspection", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent, "Button").default
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local withHooksPure = _roact_hooked.withHooksPure
local useState = _roact_hooked.useState
local useEffect = _roact_hooked.useEffect
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local selectInspectionResultSelected = _remote_log.selectInspectionResultSelected
local selectMaxInspectionResults = _remote_log.selectMaxInspectionResults
local setInspectionResultSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log", "actions").setInspectionResultSelected
local useSingleMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useSingleMotor
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Spring = _flipper.Spring
local Instant = _flipper.Instant
local ScannerType
do
	local _inverse = {}
	ScannerType = setmetatable({}, {
		__index = _inverse,
	})
	ScannerType.None = "none"
	_inverse.none = "None"
	ScannerType.Upvalue = "upvalue"
	_inverse.upvalue = "Upvalue"
	ScannerType.Constant = "constant"
	_inverse.constant = "Constant"
	ScannerType.Script = "script"
	_inverse.script = "Script"
	ScannerType.Module = "module"
	_inverse.module = "Module"
	ScannerType.Closure = "closure"
	_inverse.closure = "Closure"
end
local SCANNER_DEFAULT = Spring.new(0, {
	frequency = 6,
})
local SCANNER_HOVERED = Spring.new(0.05, {
	frequency = 6,
})
local SCANNER_PRESSED = Instant.new(0.08)
local SCANNER_SELECTED = Spring.new(0.12, {
	frequency = 6,
})
local ScannerButton = withHooksPure(function(_param)
	local scanner = _param.scanner
	local isSelected = _param.isSelected
	local onClick = _param.onClick
	local _binding = useSingleMotor(if isSelected then 0.12 else 0)
	local background = _binding[1]
	local setBackground = _binding[2]
	useEffect(function()
		if isSelected then
			setBackground(SCANNER_SELECTED)
		else
			setBackground(SCANNER_DEFAULT)
		end
	end, { isSelected })
	local _attributes = {
		onClick = onClick,
		onPress = function()
			return setBackground(SCANNER_PRESSED)
		end,
		onHover = function()
			return not isSelected and setBackground(SCANNER_HOVERED)
		end,
		onHoverEnd = function()
			return not isSelected and setBackground(SCANNER_DEFAULT)
		end,
		size = UDim2.new(0.32, 0, 0, 64),
		background = background:map(function(value)
			return Color3.new(value, value, value)
		end),
		transparency = 0,
		cornerRadius = UDim.new(0, 10),
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
		Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 10),
		}),
		Roact.createElement("ImageLabel", {
			Image = scanner.icon,
			Size = UDim2.new(0, 32, 0, 32),
			BackgroundTransparency = 1,
			ImageColor3 = Color3.new(1, 1, 1),
		}),
		Roact.createElement("Frame", {
			Size = UDim2.new(1, -42, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, 3),
			}),
			Roact.createElement("TextLabel", {
				Text = scanner.name,
				TextSize = 13,
				Font = "GothamBold",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 16),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				TextTruncate = "AtEnd",
			}),
			Roact.createElement("TextLabel", {
				Text = scanner.desc,
				TextSize = 10,
				Font = "Gotham",
				TextColor3 = Color3.new(0.7, 0.7, 0.7),
				Size = UDim2.new(1, 0, 0, 13),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
				TextTruncate = "AtEnd",
			}),
		}),
	}
	local _length = #_children
	local _child = isSelected and Roact.createElement("UIStroke", {
		Color = Color3.new(0.5, 0.7, 1),
		Thickness = 2,
		Transparency = 0,
	})
	if _child then
		_children[_length + 1] = _child
	end
	return Roact.createFragment({
		[scanner.type] = Roact.createElement(Button, _attributes, _children),
	})
end)
local RESULT_DEFAULT = Spring.new(0.08, {
	frequency = 6,
})
local RESULT_HOVERED = Spring.new(0.10, {
	frequency = 6,
})
local RESULT_PRESSED = Instant.new(0.12)
local RESULT_SELECTED = Spring.new(0.14, {
	frequency = 6,
})
local ResultItem = withHooksPure(function(_param)
	local result = _param.result
	local isSelected = _param.isSelected
	local onClick = _param.onClick
	local _binding = useSingleMotor(if isSelected then 0.14 else 0.08)
	local background = _binding[1]
	local setBackground = _binding[2]
	useEffect(function()
		if isSelected then
			setBackground(RESULT_SELECTED)
		else
			setBackground(RESULT_DEFAULT)
		end
	end, { isSelected })
	local _attributes = {
		onClick = onClick,
		onPress = function()
			return setBackground(RESULT_PRESSED)
		end,
		onHover = function()
			return not isSelected and setBackground(RESULT_HOVERED)
		end,
		onHoverEnd = function()
			return not isSelected and setBackground(RESULT_DEFAULT)
		end,
		size = UDim2.new(1, -6, 0, 64),
		background = background:map(function(value)
			return Color3.new(value, value, value)
		end),
		transparency = 0,
		cornerRadius = UDim.new(0, 8),
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 12),
		}),
		Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 4),
		}),
		Roact.createElement("TextLabel", {
			Text = result.name,
			TextSize = 14,
			Font = "GothamBold",
			TextColor3 = Color3.new(1, 1, 1),
			Size = UDim2.new(1, 0, 0, 17),
			BackgroundTransparency = 1,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			TextTruncate = "AtEnd",
		}),
	}
	local _length = #_children
	local _attributes_1 = {}
	local _exp = result.type
	local _condition = result.value
	if _condition == nil then
		_condition = "no path"
	end
	_attributes_1.Text = _exp .. (" • " .. _condition)
	_attributes_1.TextSize = 11
	_attributes_1.Font = "Gotham"
	_attributes_1.TextColor3 = Color3.new(0.7, 0.75, 0.8)
	_attributes_1.Size = UDim2.new(1, 0, 0, 14)
	_attributes_1.BackgroundTransparency = 1
	_attributes_1.TextXAlignment = "Left"
	_attributes_1.TextYAlignment = "Center"
	_attributes_1.TextTruncate = "AtEnd"
	_children[_length + 1] = Roact.createElement("TextLabel", _attributes_1)
	local _child = result.details ~= nil and (Roact.createElement("TextLabel", {
		Text = result.details,
		TextSize = 10,
		Font = "Code",
		TextColor3 = Color3.new(0.5, 0.5, 0.5),
		Size = UDim2.new(1, 0, 0, 13),
		BackgroundTransparency = 1,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		TextTruncate = "AtEnd",
	}))
	if _child then
		_children[_length + 2] = _child
	end
	_length = #_children
	local _child_1 = isSelected and Roact.createElement("UIStroke", {
		Color = Color3.new(0.5, 0.7, 1),
		Thickness = 2,
		Transparency = 0,
	})
	if _child_1 then
		_children[_length + 1] = _child_1
	end
	return Roact.createFragment({
		[result.id] = Roact.createElement(Button, _attributes, _children),
	})
end)
local function Inspection()
	local dispatch = useRootDispatch()
	local maxResults = useRootSelector(selectMaxInspectionResults)
	local selectedResult = useRootSelector(selectInspectionResultSelected)
	local selectedScanner, setSelectedScanner = useState(ScannerType.None)
	local scanResults, setScanResults = useState({})
	local isScanning, setIsScanning = useState(false)
	local searchQuery, setSearchQuery = useState("")
	local handleScan = function(scannerType)
		setIsScanning(true)
		setSelectedScanner(scannerType)
		dispatch(setInspectionResultSelected(nil))
		local results = {}
		TS.try(function()
			repeat
				if scannerType == (ScannerType.Upvalue) then
					if getgc and getupvalues then
						local gc = getgc()
						local count = 0
						for _, item in ipairs(gc) do
							if typeof(item) == "function" then
								local func = item
								local upvalues = getupvalues(func)
								local _condition = upvalues
								if _condition then
									-- ▼ ReadonlyMap.size ▼
									local _size = 0
									for _1 in pairs(upvalues) do
										_size += 1
									end
									-- ▲ ReadonlyMap.size ▲
									_condition = _size > 0
								end
								if _condition then
									local _info = getinfo
									if _info ~= nil then
										_info = _info(func)
									end
									local info = _info
									local upvalueList = ""
									local _arg0 = function(value, key)
										upvalueList ..= key .. (": " .. (typeof(value) .. ", "))
									end
									for _k, _v in pairs(upvalues) do
										_arg0(_v, _k, upvalues)
									end
									local _object = {
										id = "upvalue_" .. tostring(count),
									}
									local _left = "name"
									local _result = info
									if _result ~= nil then
										_result = _result.name
									end
									local _condition_1 = _result
									if _condition_1 == nil then
										_condition_1 = "Function_" .. tostring(count)
									end
									_object[_left] = _condition_1
									_object.type = "Function with Upvalues"
									local _left_1 = "value"
									-- ▼ ReadonlyMap.size ▼
									local _size = 0
									for _1 in pairs(upvalues) do
										_size += 1
									end
									-- ▲ ReadonlyMap.size ▲
									_object[_left_1] = tostring(_size) .. " upvalues"
									_object.details = upvalueList
									_object.rawFunc = func
									_object.rawUpvalues = upvalues
									_object.rawInfo = info
									table.insert(results, _object)
									count += 1
									if count >= maxResults then
										break
									end
								end
							end
						end
					end
					break
				end
				if scannerType == (ScannerType.Constant) then
					if getgc and getconstants then
						local gc = getgc()
						local count = 0
						for _, item in ipairs(gc) do
							if typeof(item) == "function" then
								local func = item
								local constants = getconstants(func)
								if constants and #constants > 0 then
									local _info = getinfo
									if _info ~= nil then
										_info = _info(func)
									end
									local info = _info
									local constantList = ""
									for _1, value in ipairs(constants) do
										constantList ..= tostring(value) .. ", "
									end
									local _object = {
										id = "constant_" .. tostring(count),
									}
									local _left = "name"
									local _result = info
									if _result ~= nil then
										_result = _result.name
									end
									local _condition = _result
									if _condition == nil then
										_condition = "Function_" .. tostring(count)
									end
									_object[_left] = _condition
									_object.type = "Function with Constants"
									_object.value = tostring(#constants) .. " constants"
									local _left_1 = "details"
									local _constantList = constantList
									local _arg1 = math.min(100, #constantList)
									_object[_left_1] = string.sub(_constantList, 1, _arg1)
									_object.rawFunc = func
									_object.rawConstants = constants
									_object.rawInfo = info
									table.insert(results, _object)
									count += 1
									if count >= maxResults then
										break
									end
								end
							end
						end
					end
					break
				end
				if scannerType == (ScannerType.Script) then
					if getgc then
						local gc = getgc()
						local count = 0
						for _, item in ipairs(gc) do
							if typeof(item) == "Instance" then
								local inst = item
								if inst:IsA("LuaSourceContainer") then
									local _object = {
										id = "script_" .. tostring(count),
										name = inst.Name,
										type = inst.ClassName,
										value = inst:GetFullName(),
									}
									local _left = "details"
									local _result = inst.Parent
									if _result ~= nil then
										_result = _result.Name
									end
									local _condition = _result
									if _condition == nil then
										_condition = "nil"
									end
									_object[_left] = "Parent: " .. _condition
									_object.rawScript = inst
									table.insert(results, _object)
									count += 1
									if count >= maxResults then
										break
									end
								end
							end
						end
					end
					break
				end
				if scannerType == (ScannerType.Module) then
					if getgc then
						local gc = getgc()
						local count = 0
						for _, item in ipairs(gc) do
							if typeof(item) == "Instance" then
								local inst = item
								if inst:IsA("ModuleScript") then
									local _object = {
										id = "module_" .. tostring(count),
										name = inst.Name,
										type = "ModuleScript",
										value = inst:GetFullName(),
									}
									local _left = "details"
									local _result = inst.Parent
									if _result ~= nil then
										_result = _result.Name
									end
									local _condition = _result
									if _condition == nil then
										_condition = "nil"
									end
									_object[_left] = "Parent: " .. _condition
									_object.rawScript = inst
									table.insert(results, _object)
									count += 1
									if count >= maxResults then
										break
									end
								end
							end
						end
					end
					break
				end
				if scannerType == (ScannerType.Closure) then
					if getgc and getinfo then
						local gc = getgc()
						local count = 0
						for _, item in ipairs(gc) do
							if typeof(item) == "function" then
								local func = item
								local info = getinfo(func)
								if info then
									local _upvalues = getupvalues
									if _upvalues ~= nil then
										_upvalues = _upvalues(func)
									end
									local upvalues = _upvalues
									local _constants = getconstants
									if _constants ~= nil then
										_constants = _constants(func)
									end
									local constants = _constants
									local _object = {
										id = "closure_" .. tostring(count),
									}
									local _left = "name"
									local _condition = info.name
									if _condition == nil then
										_condition = "Closure_" .. tostring(count)
									end
									_object[_left] = _condition
									local _left_1 = "type"
									local _condition_1 = info.what
									if _condition_1 == nil then
										_condition_1 = "Lua"
									end
									_object[_left_1] = _condition_1
									local _left_2 = "value"
									local _condition_2 = info.short_src
									if _condition_2 == nil then
										_condition_2 = "unknown"
									end
									_object[_left_2] = _condition_2
									local _left_3 = "details"
									local _condition_3 = info.nups
									if _condition_3 == nil then
										_condition_3 = 0
									end
									local _condition_4 = info.linedefined
									if _condition_4 == nil then
										_condition_4 = "?"
									end
									local _condition_5 = info.lastlinedefined
									if _condition_5 == nil then
										_condition_5 = "?"
									end
									_object[_left_3] = "Upvalues: " .. (tostring(_condition_3) .. (", Lines: " .. (tostring(_condition_4) .. ("-" .. tostring(_condition_5)))))
									_object.rawFunc = func
									_object.rawInfo = info
									_object.rawUpvalues = upvalues
									_object.rawConstants = constants
									table.insert(results, _object)
									count += 1
									if count >= maxResults then
										break
									end
								end
							end
						end
					end
					break
				end
			until true
		end, function(error)
			local _arg0 = {
				id = "error",
				name = "Error",
				type = "Error",
				value = tostring(error),
				details = "Failed to scan",
			}
			table.insert(results, _arg0)
		end)
		setScanResults(results)
		setIsScanning(false)
	end
	local _arg0 = function(result)
		if searchQuery == "" then
			return true
		end
		local query = string.lower(searchQuery)
		local nameMatch = (string.find(string.lower(result.name), query)) ~= nil
		local typeMatch = (string.find(string.lower(result.type), query)) ~= nil
		local valueMatch = result.value ~= nil and (string.find(string.lower(result.value), query)) ~= nil
		return nameMatch or (typeMatch or valueMatch)
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(scanResults) do
		if _arg0(_v, _k - 1, scanResults) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local filteredResults = _newValue
	local scannerInfo = { {
		type = ScannerType.Upvalue,
		name = "Upvalue Scanner",
		icon = "rbxassetid://119937429331234",
		desc = "Examine function upvalues",
	}, {
		type = ScannerType.Constant,
		name = "Constant Scanner",
		icon = "rbxassetid://86206500190741",
		desc = "View function constants",
	}, {
		type = ScannerType.Script,
		name = "Script Scanner",
		icon = "rbxassetid://132151602895952",
		desc = "Find script instances",
	}, {
		type = ScannerType.Module,
		name = "Module Scanner",
		icon = "rbxassetid://95437669844684",
		desc = "Discover modules",
	}, {
		type = ScannerType.Closure,
		name = "Closure Spy",
		icon = "rbxassetid://107082546858208",
		desc = "Monitor closures",
	} }
	local _children = {}
	local _length_1 = #_children
	local _attributes = {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 1,
		ScrollBarImageTransparency = 0.6,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}
	local _children_1 = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			PaddingTop = UDim.new(0, 20),
			PaddingBottom = UDim.new(0, 20),
		}),
		Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			Padding = UDim.new(0, 18),
		}),
		Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 70),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 6),
			}),
			Roact.createElement("TextLabel", {
				Text = "Runtime Inspection",
				TextSize = 26,
				Font = "GothamBold",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Center",
			}),
			Roact.createElement("TextLabel", {
				Text = "Select a scanner to begin analyzing runtime data",
				TextSize = 13,
				Font = "Gotham",
				TextColor3 = Color3.new(0.6, 0.6, 0.6),
				Size = UDim2.new(1, 0, 0, 32),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextWrapped = true,
			}),
		}),
	}
	local _length_2 = #_children_1
	local _arg0_1 = function(scanner)
		return Roact.createFragment({
			[scanner.type] = Roact.createElement(ScannerButton, {
				scanner = scanner,
				isSelected = selectedScanner == scanner.type,
				onClick = function()
					return handleScan(scanner.type)
				end,
			}),
		})
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue_1 = table.create(#scannerInfo)
	for _k, _v in ipairs(scannerInfo) do
		_newValue_1[_k] = _arg0_1(_v, _k - 1, scannerInfo)
	end
	-- ▲ ReadonlyArray.map ▲
	local _attributes_1 = {
		Size = UDim2.new(1, 0, 0, 140),
		BackgroundTransparency = 1,
	}
	local _children_2 = {
		Roact.createElement("UIGridLayout", {
			CellSize = UDim2.new(0.32, 0, 0, 64),
			CellPadding = UDim2.new(0.01, 0, 0, 12),
		}),
	}
	local _length_3 = #_children_2
	for _k, _v in ipairs(_newValue_1) do
		_children_2[_length_3 + _k] = _v
	end
	_children_1[_length_2 + 1] = Roact.createElement("Frame", _attributes_1, _children_2)
	local _condition = selectedScanner ~= ScannerType.None
	if _condition then
		local _result
		if isScanning then
			_result = (Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 80),
				BackgroundColor3 = Color3.new(0.08, 0.08, 0.08),
				BorderSizePixel = 0,
			}, {
				Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 10),
				}),
				Roact.createElement("TextLabel", {
					Text = "Scanning garbage collector...",
					TextSize = 15,
					Font = "GothamBold",
					TextColor3 = Color3.new(0.5, 0.7, 1),
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextXAlignment = "Center",
					TextYAlignment = "Center",
				}),
			}))
		else
			local _result_1
			if #filteredResults == 0 then
				_result_1 = (Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 100),
					BackgroundColor3 = Color3.new(0.08, 0.08, 0.08),
					BorderSizePixel = 0,
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 10),
					}),
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 6),
					}),
					Roact.createElement("TextLabel", {
						Text = "No Results",
						TextSize = 17,
						Font = "GothamBold",
						TextColor3 = Color3.new(0.8, 0.4, 0.4),
						Size = UDim2.new(1, 0, 0, 22),
						BackgroundTransparency = 1,
						TextXAlignment = "Center",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "Try a different scanner or search term",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.5, 0.5, 0.5),
						Size = UDim2.new(1, 0, 0, 16),
						BackgroundTransparency = 1,
						TextXAlignment = "Center",
						TextYAlignment = "Center",
					}),
				}))
			else
				local _arg0_2 = function(result)
					local _attributes_2 = {
						result = result,
					}
					local _result_2 = selectedResult
					if _result_2 ~= nil then
						_result_2 = _result_2.id
					end
					_attributes_2.isSelected = _result_2 == result.id
					_attributes_2.onClick = function()
						return dispatch(setInspectionResultSelected(result))
					end
					return Roact.createFragment({
						[result.id] = Roact.createElement(ResultItem, _attributes_2),
					})
				end
				-- ▼ ReadonlyArray.map ▼
				local _newValue_2 = table.create(#filteredResults)
				for _k, _v in ipairs(filteredResults) do
					_newValue_2[_k] = _arg0_2(_v, _k - 1, filteredResults)
				end
				-- ▲ ReadonlyArray.map ▲
				local _attributes_2 = {
					Size = UDim2.new(1, 0, 0, math.min(500, #filteredResults * 70)),
					BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
					BorderSizePixel = 0,
					ScrollBarThickness = 1,
					ScrollBarImageTransparency = 0.6,
					CanvasSize = UDim2.new(0, 0, 0, #filteredResults * 70),
				}
				local _children_3 = {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 10),
					}),
					Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 10),
					}),
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0, 6),
					}),
				}
				local _length_4 = #_children_3
				for _k, _v in ipairs(_newValue_2) do
					_children_3[_length_4 + _k] = _v
				end
				_result_1 = (Roact.createElement("ScrollingFrame", _attributes_2, _children_3))
			end
			_result = _result_1
		end
		local _attributes_2 = {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.Y,
		}
		local _children_3 = {
			Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 12),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 66),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 8),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 24),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = UDim.new(0, 8),
					}),
					Roact.createElement("TextLabel", {
						Text = "Results: " .. (tostring(#filteredResults) .. ("/" .. tostring(#scanResults))),
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(0.5, 0, 0, 24),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "Max: " .. tostring(maxResults),
						TextSize = 11,
						Font = "Gotham",
						TextColor3 = Color3.new(0.5, 0.5, 0.5),
						Size = UDim2.new(0.5, 0, 0, 24),
						BackgroundTransparency = 1,
						TextXAlignment = "Right",
						TextYAlignment = "Center",
					}),
				}),
				Roact.createElement("TextBox", {
					Size = UDim2.new(1, 0, 0, 34),
					PlaceholderText = "Search results...",
					Text = searchQuery,
					TextSize = 13,
					Font = "Gotham",
					TextColor3 = Color3.new(1, 1, 1),
					BackgroundColor3 = Color3.new(0.08, 0.08, 0.08),
					BorderSizePixel = 0,
					TextXAlignment = "Left",
					ClearTextOnFocus = false,
					[Roact.Change.Text] = function(rbx)
						return setSearchQuery(rbx.Text)
					end,
				}, {
					Roact.createElement("UICorner", {
						CornerRadius = UDim.new(0, 8),
					}),
					Roact.createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 12),
						PaddingRight = UDim.new(0, 12),
					}),
					Roact.createElement("UIStroke", {
						Color = Color3.new(0.15, 0.15, 0.15),
						Thickness = 1,
					}),
				}),
			}),
		}
		local _length_4 = #_children_3
		_children_3[_length_4 + 1] = _result
		_condition = (Roact.createElement("Frame", _attributes_2, _children_3))
	end
	if _condition then
		_children_1[_length_2 + 2] = _condition
	end
	_children[_length_1 + 1] = Roact.createElement("ScrollingFrame", _attributes, _children_1)
	return Roact.createElement(Container, {}, _children)
end
local default = withHooksPure(Inspection)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Inspection.Inspection"))() end)

_module("Logger", "ModuleScript", "RemoteSpy.components.Pages.Logger", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Logger").default
return exports
 end, _env("RemoteSpy.components.Pages.Logger"))() end)

_module("Header", "ModuleScript", "RemoteSpy.components.Pages.Logger.Header", "RemoteSpy.components.Pages.Logger", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent, "Button").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local TabType = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "tab-group").TabType
local clearOutgoingSignals = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").clearOutgoingSignals
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local getInstancePath = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "instance-util").getInstancePath
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local makeSelectRemoteLogObject = _remote_log.makeSelectRemoteLogObject
local makeSelectRemoteLogType = _remote_log.makeSelectRemoteLogType
local useGroupMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useGroupMotor
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local deleteSprings = {
	default = { Spring.new(0.94, {
		frequency = 6,
	}), Spring.new(0, {
		frequency = 6,
	}) },
	hovered = { Spring.new(0.9, {
		frequency = 6,
	}), Spring.new(0, {
		frequency = 6,
	}) },
	pressed = { Instant.new(0.94), Instant.new(0.2) },
}
local captionTransparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.85, 0), NumberSequenceKeypoint.new(1, 1) })
local function Header(_param)
	local id = _param.id
	local dispatch = useRootDispatch()
	local selectType = useMemo(makeSelectRemoteLogType, {})
	local remoteType = useRootSelector(function(state)
		return selectType(state, id)
	end)
	local selectObject = useMemo(makeSelectRemoteLogObject, {})
	local remoteObject = useRootSelector(function(state)
		return selectObject(state, id)
	end)
	local _binding = useGroupMotor({ 0.94, 0 })
	local deleteTransparency = _binding[1]
	local setDeleteTransparency = _binding[2]
	local deleteButton = useMemo(function()
		return {
			background = deleteTransparency:map(function(t)
				return t[1]
			end),
			foreground = deleteTransparency:map(function(t)
				return t[2]
			end),
		}
	end, {})
	return Roact.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.96,
		Size = UDim2.new(1, 0, 0, 64),
		LayoutOrder = -1,
	}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		Roact.createElement(Button, {
			onClick = function()
				setDeleteTransparency(deleteSprings.hovered)
				dispatch(clearOutgoingSignals(id))
			end,
			onPress = function()
				return setDeleteTransparency(deleteSprings.pressed)
			end,
			onHover = function()
				return setDeleteTransparency(deleteSprings.hovered)
			end,
			onHoverEnd = function()
				return setDeleteTransparency(deleteSprings.default)
			end,
			anchorPoint = Vector2.new(1, 0),
			size = UDim2.new(0, 94, 0, 28),
			position = UDim2.new(1, -18, 0, 18),
			transparency = deleteButton.background,
			cornerRadius = UDim.new(0, 4),
		}, {
			Roact.createElement("TextLabel", {
				Text = "Delete history",
				Font = "Gotham",
				TextColor3 = Color3.new(1, 1, 1),
				TextTransparency = deleteButton.foreground,
				TextSize = 11,
				TextXAlignment = "Center",
				TextYAlignment = "Center",
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIGradient", {
					Transparency = captionTransparency,
				}),
			}),
		}),
		Roact.createElement("ImageLabel", {
			Image = if remoteType == TabType.Event then "rbxassetid://111467142036224" elseif remoteType == TabType.Function then "rbxassetid://104664672211257" elseif remoteType == TabType.BindableEvent then "rbxassetid://76270109328460" elseif remoteType == TabType.BindableFunction then "rbxassetid://87985191222737" else "",
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 18, 0, 20),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Text = if remoteObject then formatEscapes(remoteObject.Name) else "Unknown",
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 13,
			TextXAlignment = "Left",
			TextYAlignment = "Bottom",
			Size = UDim2.new(1, -170, 0, 12),
			Position = UDim2.new(0, 58, 0, 18),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIGradient", {
				Transparency = captionTransparency,
			}),
		}),
		Roact.createElement("TextLabel", {
			Text = if remoteObject then formatEscapes(getInstancePath(remoteObject)) else "Unknown",
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = 0.2,
			TextSize = 11,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Size = UDim2.new(1, -170, 0, 12),
			Position = UDim2.new(0, 58, 0, 39),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIGradient", {
				Transparency = captionTransparency,
			}),
		}),
	})
end
local default = withHooksPure(Header)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Header"))() end)

_module("Logger", "ModuleScript", "RemoteSpy.components.Pages.Logger.Logger", "RemoteSpy.components.Pages.Logger", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Header = TS.import(script, script.Parent, "Header").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Row = TS.import(script, script.Parent, "Row").default
local Selection = TS.import(script, script.Parent.Parent.Parent, "Selection").default
local arrayToMap = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).arrayToMap
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local makeSelectRemoteLogOutgoing = _remote_log.makeSelectRemoteLogOutgoing
local selectSignalIdSelected = _remote_log.selectSignalIdSelected
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local function Logger(_param)
	local id = _param.id
	local selectOutgoing = useMemo(makeSelectRemoteLogOutgoing, {})
	local outgoing = useRootSelector(function(state)
		return selectOutgoing(state, id)
	end)
	local selection = useRootSelector(selectSignalIdSelected)
	local selectionOrder = useMemo(function()
		local _result = outgoing
		if _result ~= nil then
			local _arg0 = function(signal)
				return signal.id == selection
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result_1 = -1
			for _i, _v in ipairs(_result) do
				if _arg0(_v, _i - 1, _result) == true then
					_result_1 = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			_result = _result_1
		end
		local _condition = _result
		if _condition == nil then
			_condition = -1
		end
		return _condition
	end, { outgoing, selection })
	local contentHeight, setContentHeight = useBinding(0)
	if not outgoing then
		return Roact.createFragment()
	end
	local _attributes = {
		CanvasSize = contentHeight:map(function(h)
			return UDim2.new(0, 0, 0, h + 48)
		end),
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 12),
		}),
		Roact.createElement(Selection, {
			height = 64,
			offset = if selection ~= nil and selectionOrder ~= -1 then (selectionOrder + 1) * (64 + 4) else nil,
			hasSelection = selection ~= nil and selectionOrder ~= -1,
		}),
	}
	local _length = #_children
	local _children_1 = {
		Roact.createElement("UIListLayout", {
			[Roact.Change.AbsoluteContentSize] = function(rbx)
				return setContentHeight(rbx.AbsoluteContentSize.Y)
			end,
			SortOrder = "LayoutOrder",
			FillDirection = "Vertical",
			Padding = UDim.new(0, 4),
			VerticalAlignment = "Top",
		}),
		Roact.createElement(Header, {
			id = id,
		}),
	}
	local _length_1 = #_children_1
	for _k, _v in pairs(arrayToMap(outgoing, function(signal, order)
		return { signal.id, Roact.createElement(Row, {
			signal = signal,
			order = order,
			selected = selection == signal.id,
		}) }
	end)) do
		_children_1[_k] = _v
	end
	_children[_length + 1] = Roact.createElement(Container, {}, _children_1)
	return Roact.createElement("ScrollingFrame", _attributes, _children)
end
local default = withHooksPure(Logger)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Logger"))() end)

_module("Row", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row", "RemoteSpy.components.Pages.Logger", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Row").default
return exports
 end, _env("RemoteSpy.components.Pages.Logger.Row"))() end)

_module("Row", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.Row", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local RowView = TS.import(script, script.Parent, "RowView").default
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local withHooksPure = _roact_hooked.withHooksPure
local useSingleMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useSingleMotor
local function Row(_param)
	local signal = _param.signal
	local order = _param.order
	local selected = _param.selected
	local contentHeight, setContentHeight = useBinding(0)
	local _binding = useSingleMotor(0)
	local animation = _binding[1]
	local setGoal = _binding[2]
	useEffect(function()
		setGoal(Spring.new(if selected then 1 else 0, {
			frequency = 6,
		}))
	end, { selected })
	return Roact.createElement(Container, {
		order = order,
		size = Roact.joinBindings({ contentHeight, animation }):map(function(_param_1)
			local y = _param_1[1]
			local a = _param_1[2]
			return UDim2.new(1, 0, 0, 64 + math.round(y * a))
		end),
		clipChildren = true,
	}, {
		Roact.createElement(RowView, {
			signal = signal,
			onHeightChange = setContentHeight,
			selected = selected,
		}),
	})
end
local default = withHooksPure(Row)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.Row"))() end)

_module("RowBody", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowBody", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local RowCaption = TS.import(script, script.Parent, "RowCaption").default
local RowDoubleCaption = TS.import(script, script.Parent, "RowDoubleCaption").default
local RowLine = TS.import(script, script.Parent, "RowLine").default
local stringifySignalTraceback = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "reducers", "remote-log").stringifySignalTraceback
local codify = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "codify").codify
local _function_util = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "function-util")
local describeFunction = _function_util.describeFunction
local stringifyFunctionSignature = _function_util.stringifyFunctionSignature
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local getInstancePath = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "instance-util").getInstancePath
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local function stringifyTypesAndValues(list)
	local types = {}
	local values = {}
	for index, value in pairs(list) do
		if index > 12 then
			table.insert(types, "...")
			table.insert(values, "...")
			break
		end
		if typeof(value) == "Instance" then
			local _className = value.ClassName
			table.insert(types, _className)
		else
			local _arg0 = typeof(value)
			table.insert(types, _arg0)
		end
		local _arg0 = formatEscapes(string.sub(codify(value, -1), 1, 256))
		table.insert(values, _arg0)
	end
	return { types, values }
end
local function RowBody(_param)
	local signal = _param.signal
	local description = useMemo(function()
		return describeFunction(signal.callback)
	end, {})
	local tracebackNames = useMemo(function()
		return stringifySignalTraceback(signal)
	end, {})
	local _binding = useMemo(function()
		return stringifyTypesAndValues(signal.parameters)
	end, {})
	local parameterTypes = _binding[1]
	local parameterValues = _binding[2]
	local _binding_1 = useMemo(function()
		return if signal.returns then stringifyTypesAndValues(signal.returns) else { { "void" }, { "void" } }
	end, {})
	local returnTypes = _binding_1[1]
	local returnValues = _binding_1[2]
	local _children = {
		Roact.createElement(RowLine),
		Roact.createElement("Frame", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.98,
			BorderSizePixel = 0,
		}, {
			Roact.createElement(RowCaption, {
				text = "Remote name",
				description = formatEscapes(signal.name),
				wrapped = true,
			}),
			Roact.createElement(RowCaption, {
				text = "Remote location",
				description = formatEscapes(signal.path),
				wrapped = true,
			}),
			Roact.createElement(RowCaption, {
				text = "Remote caller",
				description = if signal.caller then formatEscapes(getInstancePath(signal.caller)) else "No script found",
				wrapped = true,
			}),
			Roact.createElement(RowCaption, {
				text = "Called from Actor",
				description = if signal.isActor then "Yes" else "No",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 58),
				PaddingRight = UDim.new(0, 58),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			}),
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(),
				VerticalAlignment = "Top",
			}),
		}),
	}
	local _length = #_children
	local _child = #parameterTypes > 0 and (Roact.createFragment({
		Roact.createElement(RowLine),
		Roact.createElement("Frame", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.98,
			BorderSizePixel = 0,
		}, {
			Roact.createElement(RowDoubleCaption, {
				text = "Parameters",
				hint = table.concat(parameterTypes, "\n"),
				description = table.concat(parameterValues, "\n"),
			}),
			returnTypes and (Roact.createElement(RowDoubleCaption, {
				text = "Returns",
				hint = table.concat(returnTypes, "\n"),
				description = table.concat(returnValues, "\n"),
			})),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 58),
				PaddingRight = UDim.new(0, 58),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			}),
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(),
				VerticalAlignment = "Top",
			}),
		}),
	}))
	if _child then
		_children[_length + 1] = _child
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement(RowLine)
	_children[_length + 2] = Roact.createElement("ImageLabel", {
		AutomaticSize = "Y",
		Image = "rbxassetid://9913871236",
		ImageColor3 = Color3.new(1, 1, 1),
		ImageTransparency = 0.98,
		ScaleType = "Slice",
		SliceCenter = Rect.new(4, 4, 4, 4),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
	}, {
		Roact.createElement(RowCaption, {
			text = "Signature",
			description = stringifyFunctionSignature(signal.callback),
			wrapped = true,
		}),
		Roact.createElement(RowCaption, {
			text = "Source",
			description = description.source,
			wrapped = true,
		}),
		Roact.createElement(RowCaption, {
			text = "Traceback",
			wrapped = true,
			description = table.concat(tracebackNames, "\n"),
		}),
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 58),
			PaddingRight = UDim.new(0, 58),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
		}),
		Roact.createElement("UIListLayout", {
			FillDirection = "Vertical",
			Padding = UDim.new(),
			VerticalAlignment = "Top",
		}),
	})
	return Roact.createFragment(_children)
end
local default = withHooksPure(RowBody)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowBody"))() end)

_module("RowCaption", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowCaption", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function RowCaption(_param)
	local text = _param.text
	local description = _param.description
	local wrapped = _param.wrapped
	local richText = _param.richText
	return Roact.createElement("TextLabel", {
		Text = text,
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 11,
		AutomaticSize = "Y",
		Size = UDim2.new(1, 50, 0, 23),
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("TextLabel", {
			RichText = richText,
			Text = description,
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			TextTransparency = 0.3,
			TextWrapped = wrapped,
			AutomaticSize = "Y",
			Size = UDim2.new(1, -114, 0, 0),
			Position = UDim2.new(0, 114, 0, 0),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
			}),
		}),
		Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 4),
		}),
	})
end
return {
	default = RowCaption,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowCaption"))() end)

_module("RowDoubleCaption", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowDoubleCaption", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function RowDoubleCaption(_param)
	local text = _param.text
	local hint = _param.hint
	local description = _param.description
	return Roact.createElement("TextLabel", {
		Text = text,
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextSize = 11,
		AutomaticSize = "Y",
		Size = UDim2.new(1, 0, 0, 23),
		TextXAlignment = "Left",
		TextYAlignment = "Top",
		BackgroundTransparency = 1,
	}, {
		Roact.createElement("TextLabel", {
			Text = hint,
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			TextTransparency = 0.5,
			AutomaticSize = "Y",
			Size = UDim2.new(1, -114, 0, 0),
			Position = UDim2.new(0, 114, 0, 0),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
			}),
		}),
		Roact.createElement("TextLabel", {
			Text = description,
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			TextTransparency = 0.3,
			AutomaticSize = "Y",
			Size = UDim2.new(1, -114 - 100, 0, 0),
			Position = UDim2.new(0, 114 + 100, 0, 0),
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 6),
			}),
		}),
		Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 4),
		}),
	})
end
return {
	default = RowDoubleCaption,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowDoubleCaption"))() end)

_module("RowHeader", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowHeader", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent.Parent, "Button").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local getInstancePath = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "instance-util").getInstancePath
local multiply = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "number-util").multiply
local stringifyFunctionSignature = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "utils", "function-util").stringifyFunctionSignature
local useGroupMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useGroupMotor
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local rowSprings = {
	default = { Spring.new(0.97, {
		frequency = 6,
	}), Spring.new(0, {
		frequency = 6,
	}) },
	defaultOpen = { Spring.new(0.96, {
		frequency = 6,
	}), Spring.new(0, {
		frequency = 6,
	}) },
	hovered = { Spring.new(0.93, {
		frequency = 6,
	}), Spring.new(0, {
		frequency = 6,
	}) },
	pressed = { Instant.new(0.98), Instant.new(0.2) },
}
local captionTransparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 1) })
local function RowHeader(_param)
	local signal = _param.signal
	local open = _param.open
	local onClick = _param.onClick
	local _binding = useGroupMotor({ 0.97, 0 })
	local rowTransparency = _binding[1]
	local setRowTransparency = _binding[2]
	local rowButton = {
		background = rowTransparency:map(function(t)
			return t[1]
		end),
		foreground = rowTransparency:map(function(t)
			return t[2]
		end),
	}
	return Roact.createElement(Button, {
		onClick = function()
			setRowTransparency(rowSprings.hovered)
			onClick()
		end,
		onPress = function()
			return setRowTransparency(rowSprings.pressed)
		end,
		onHover = function()
			return setRowTransparency(rowSprings.hovered)
		end,
		onHoverEnd = function()
			return setRowTransparency(if open then rowSprings.defaultOpen else rowSprings.default)
		end,
		size = UDim2.new(1, 0, 0, 64),
	}, {
		Roact.createElement("ImageLabel", {
			Image = if open then "rbxassetid://9913260292" else "rbxassetid://9913260388",
			ImageColor3 = Color3.new(1, 1, 1),
			ImageTransparency = rowButton.background,
			ScaleType = "Slice",
			SliceCenter = Rect.new(4, 4, 4, 4),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9913356706",
			ImageTransparency = rowButton.foreground,
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 18, 0, 20),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			Text = (if signal.caller then formatEscapes(signal.caller.Name) else "No script") .. (" • " .. stringifyFunctionSignature(signal.callback)),
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = rowButton.foreground,
			TextSize = 13,
			TextXAlignment = "Left",
			TextYAlignment = "Bottom",
			Size = UDim2.new(1, -100, 0, 12),
			Position = UDim2.new(0, 58, 0, 18),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIGradient", {
				Transparency = captionTransparency,
			}),
		}),
		Roact.createElement("TextLabel", {
			Text = if signal.caller then formatEscapes(getInstancePath(signal.caller)) else "Not called from a script",
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextTransparency = rowButton.foreground:map(function(t)
				return multiply(t, 0.2)
			end),
			TextSize = 11,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Size = UDim2.new(1, -100, 0, 12),
			Position = UDim2.new(0, 58, 0, 39),
			BackgroundTransparency = 1,
		}, {
			Roact.createElement("UIGradient", {
				Transparency = captionTransparency,
			}),
		}),
		Roact.createElement("ImageLabel", {
			Image = if open then "rbxassetid://9913448536" else "rbxassetid://9913448364",
			ImageTransparency = rowButton.foreground,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -18, 0, 24),
			BackgroundTransparency = 1,
		}),
	})
end
local default = withHooksPure(RowHeader)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowHeader"))() end)

_module("RowLine", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowLine", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function RowLine()
	return Roact.createElement("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	})
end
return {
	default = RowLine,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowLine"))() end)

_module("RowView", "ModuleScript", "RemoteSpy.components.Pages.Logger.Row.RowView", "RemoteSpy.components.Pages.Logger.Row", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local RowBody = TS.import(script, script.Parent, "RowBody").default
local RowHeader = TS.import(script, script.Parent, "RowHeader").default
local toggleSignalSelected = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "reducers", "remote-log").toggleSignalSelected
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useCallback = _roact_hooked.useCallback
local withHooksPure = _roact_hooked.withHooksPure
local useRootDispatch = TS.import(script, script.Parent.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootDispatch
local function RowView(_param)
	local signal = _param.signal
	local selected = _param.selected
	local onHeightChange = _param.onHeightChange
	local dispatch = useRootDispatch()
	local contentHeight, setContentHeight = useBinding(0)
	local toggle = useCallback(function()
		if signal.caller then
			print("[RemoteSpy] Caller: " .. (signal.caller.Name .. (" (" .. (signal.caller.ClassName .. ")"))))
		else
			print("[RemoteSpy] Caller: nil")
		end
		dispatch(toggleSignalSelected(signal.remoteId, signal.id))
	end, {})
	local _children = {
		Roact.createElement(RowHeader, {
			signal = signal,
			open = selected,
			onClick = toggle,
		}),
	}
	local _length = #_children
	local _attributes = {
		clipChildren = true,
		size = contentHeight:map(function(y)
			return UDim2.new(1, 0, 0, y)
		end),
		position = UDim2.new(0, 0, 0, 64),
	}
	local _children_1 = {
		Roact.createElement("UIListLayout", {
			[Roact.Change.AbsoluteContentSize] = function(_param_1)
				local AbsoluteContentSize = _param_1.AbsoluteContentSize
				setContentHeight(AbsoluteContentSize.Y)
				onHeightChange(AbsoluteContentSize.Y)
			end,
			SortOrder = "LayoutOrder",
			FillDirection = "Vertical",
			Padding = UDim.new(),
			VerticalAlignment = "Top",
		}),
	}
	local _length_1 = #_children_1
	local _child = selected and Roact.createElement(RowBody, {
		signal = signal,
	})
	if _child then
		_children_1[_length_1 + 1] = _child
	end
	_children[_length + 1] = Roact.createElement(Container, _attributes, _children_1)
	return Roact.createFragment(_children)
end
local default = withHooksPure(RowView)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Logger.Row.RowView"))() end)

_module("Page", "ModuleScript", "RemoteSpy.components.Pages.Page", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Home = TS.import(script, script.Parent, "Home").default
local Logger = TS.import(script, script.Parent, "Logger").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Script = TS.import(script, script.Parent, "Script").default
local Settings = TS.import(script, script.Parent, "Settings").default
local Inspection = TS.import(script, script.Parent, "Inspection").default
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local TabType = _tab_group.TabType
local selectActiveTabId = _tab_group.selectActiveTabId
local selectActiveTabOrder = _tab_group.selectActiveTabOrder
local selectTabOrder = _tab_group.selectTabOrder
local selectTabType = _tab_group.selectTabType
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local withHooksPure = _roact_hooked.withHooksPure
local useRootSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local useSingleMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useSingleMotor
local function Page(_param)
	local id = _param.id
	local tabType = useRootSelector(function(state)
		return selectTabType(state, id)
	end)
	local tabOrder = useRootSelector(function(state)
		return selectTabOrder(state, id)
	end)
	local activeTabOrder = useRootSelector(selectActiveTabOrder)
	local activeTabId = useRootSelector(selectActiveTabId)
	local lastActiveTabId = useMutable("")
	local targetSide = if tabOrder < activeTabOrder then -1 elseif tabOrder > activeTabOrder then 1 else 0
	local _binding = useSingleMotor(if targetSide == 0 then 1 else targetSide)
	local side = _binding[1]
	local setSide = _binding[2]
	useEffect(function()
		local isOrWasActive = id == activeTabId or id == lastActiveTabId.current
		local activeTabChanged = activeTabId ~= lastActiveTabId.current
		if isOrWasActive and activeTabChanged then
			setSide(Spring.new(targetSide))
		else
			setSide(Instant.new(targetSide))
		end
	end, { targetSide })
	useEffect(function()
		lastActiveTabId.current = activeTabId
	end)
	local _attributes = {
		position = side:map(function(s)
			return UDim2.new(s, 0, 0, 0)
		end),
	}
	local _children = {}
	local _length = #_children
	local _child = if tabType == TabType.Event or (tabType == TabType.Function or (tabType == TabType.BindableEvent or tabType == TabType.BindableFunction)) then (Roact.createElement(Logger, {
		id = id,
	})) elseif tabType == TabType.Home then (Roact.createElement(Home, {
		pageSelected = activeTabId == id,
	})) elseif tabType == TabType.Script then (Roact.createElement(Script)) elseif tabType == TabType.Settings then (Roact.createElement(Settings)) elseif tabType == TabType.Inspection then (Roact.createElement(Inspection)) else nil
	if _child then
		_children[_length + 1] = _child
	end
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(Page)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Page"))() end)

_module("Pages", "ModuleScript", "RemoteSpy.components.Pages.Pages", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Page = TS.import(script, script.Parent, "Page").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local SIDE_PANEL_WIDTH = TS.import(script, script.Parent.Parent.Parent, "constants").SIDE_PANEL_WIDTH
local arrayToMap = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).arrayToMap
local selectTabs = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group").selectTabs
local useRootSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local function Pages()
	local tabs = useRootSelector(selectTabs)
	local _attributes = {
		BackgroundTransparency = 0.96,
		BackgroundColor3 = Color3.fromHex("#FFFFFF"),
		Size = UDim2.new(1, -SIDE_PANEL_WIDTH - 5, 1, -129),
		Position = UDim2.new(0, 5, 0, 124),
		ClipsDescendants = true,
	}
	local _children = {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	}
	local _length = #_children
	for _k, _v in pairs(arrayToMap(tabs, function(tab)
		return { tab.id, Roact.createElement(Page, {
			id = tab.id,
		}) }
	end)) do
		_children[_k] = _v
	end
	return Roact.createElement("Frame", _attributes, _children)
end
local default = withHooksPure(Pages)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Pages"))() end)

_module("Script", "ModuleScript", "RemoteSpy.components.Pages.Script", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Script").default
return exports
 end, _env("RemoteSpy.components.Pages.Script"))() end)

_module("Script", "ModuleScript", "RemoteSpy.components.Pages.Script.Script", "RemoteSpy.components.Pages.Script", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local selectActiveTab = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "tab-group").selectActiveTab
local _script = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "script")
local selectScript = _script.selectScript
local updateScriptContent = _script.updateScriptContent
local highlightLua = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "syntax-highlight").highlightLua
local function Script()
	local dispatch = useRootDispatch()
	local currentTab = useRootSelector(selectActiveTab)
	local scriptData = useRootSelector(function(state)
		return if currentTab then selectScript(state, currentTab.id) else nil
	end)
	local _result = scriptData
	if _result ~= nil then
		_result = _result.content
	end
	local _condition = _result
	if _condition == nil then
		_condition = "No script content"
	end
	local scriptContent = _condition
	local _result_1 = scriptData
	if _result_1 ~= nil then
		_result_1 = _result_1.signalId
	end
	local isEditable = _result_1 ~= nil
	local highlightedContent = highlightLua(scriptContent)
	local handleTextChange = function(rbx)
		if currentTab and isEditable then
			dispatch(updateScriptContent(currentTab.id, rbx.Text))
		end
	end
	return Roact.createElement(Container, {}, {
		Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
			CanvasSize = UDim2.new(1, 0, 0, 10020),
		}, {
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
			if isEditable then (Roact.createElement("TextBox", {
				Text = scriptContent,
				TextSize = 14,
				Font = Enum.Font.Code,
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				MultiLine = true,
				ClearTextOnFocus = false,
				[Roact.Change.Text] = handleTextChange,
			})) else (Roact.createElement("TextLabel", {
				Text = highlightedContent,
				RichText = true,
				TextSize = 14,
				Font = Enum.Font.Code,
				TextColor3 = Color3.fromRGB(212, 212, 212),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = false,
			})),
		}),
	})
end
local default = withHooksPure(Script)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Script.Script"))() end)

_module("Settings", "ModuleScript", "RemoteSpy.components.Pages.Settings", "RemoteSpy.components.Pages", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Settings").default
return exports
 end, _env("RemoteSpy.components.Pages.Settings"))() end)

_module("Settings", "ModuleScript", "RemoteSpy.components.Pages.Settings.Settings", "RemoteSpy.components.Pages.Settings", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent, "Button").default
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local withHooksPure = _roact_hooked.withHooksPure
local useState = _roact_hooked.useState
local useEffect = _roact_hooked.useEffect
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local _use_root_store = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local selectNoActors = _remote_log.selectNoActors
local selectNoExecutor = _remote_log.selectNoExecutor
local selectShowRemoteEvents = _remote_log.selectShowRemoteEvents
local selectShowRemoteFunctions = _remote_log.selectShowRemoteFunctions
local selectShowBindableEvents = _remote_log.selectShowBindableEvents
local selectShowBindableFunctions = _remote_log.selectShowBindableFunctions
local selectPathNotation = _remote_log.selectPathNotation
local selectMaxInspectionResults = _remote_log.selectMaxInspectionResults
local _remote_log_1 = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local toggleNoActors = _remote_log_1.toggleNoActors
local toggleNoExecutor = _remote_log_1.toggleNoExecutor
local toggleShowRemoteEvents = _remote_log_1.toggleShowRemoteEvents
local toggleShowRemoteFunctions = _remote_log_1.toggleShowRemoteFunctions
local toggleShowBindableEvents = _remote_log_1.toggleShowBindableEvents
local toggleShowBindableFunctions = _remote_log_1.toggleShowBindableFunctions
local setPathNotation = _remote_log_1.setPathNotation
local setMaxInspectionResults = _remote_log_1.setMaxInspectionResults
local PathNotation = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log", "model").PathNotation
local selectToggleKey = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "ui").selectToggleKey
local setToggleKey = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "ui").setToggleKey
local function Settings()
	local dispatch = useRootDispatch()
	local noActors = useRootSelector(selectNoActors)
	local noExecutor = useRootSelector(selectNoExecutor)
	local showRemoteEvents = useRootSelector(selectShowRemoteEvents)
	local showRemoteFunctions = useRootSelector(selectShowRemoteFunctions)
	local showBindableEvents = useRootSelector(selectShowBindableEvents)
	local showBindableFunctions = useRootSelector(selectShowBindableFunctions)
	local pathNotation = useRootSelector(selectPathNotation)
	local toggleKey = useRootSelector(selectToggleKey)
	local maxInspectionResults = useRootSelector(selectMaxInspectionResults)
	local isListeningForKey, setIsListeningForKey = useState(false)
	local maxResultsInput, setMaxResultsInput = useState(tostring(maxInspectionResults))
	local handleToggleNoActors = function()
		dispatch(toggleNoActors())
	end
	local handleToggleNoExecutor = function()
		dispatch(toggleNoExecutor())
	end
	local handleToggleRemoteEvents = function()
		dispatch(toggleShowRemoteEvents())
	end
	local handleToggleRemoteFunctions = function()
		dispatch(toggleShowRemoteFunctions())
	end
	local handleToggleBindableEvents = function()
		dispatch(toggleShowBindableEvents())
	end
	local handleToggleBindableFunctions = function()
		dispatch(toggleShowBindableFunctions())
	end
	local handlePathNotationChange = function(notation)
		dispatch(setPathNotation(notation))
	end
	local handleToggleKeyChange = function(key)
		dispatch(setToggleKey(key))
	end
	local startListeningForKey = function()
		setIsListeningForKey(true)
	end
	useEffect(function()
		if not isListeningForKey then
			return nil
		end
		local connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				handleToggleKeyChange(input.KeyCode)
				setIsListeningForKey(false)
			end
		end)
		return function()
			connection:Disconnect()
		end
	end, { isListeningForKey })
	return Roact.createElement(Container, {}, {
		Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		}, {
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
				PaddingTop = UDim.new(0, 20),
			}),
			Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				Padding = UDim.new(0, 16),
			}),
			Roact.createElement("TextLabel", {
				Text = "Settings",
				TextSize = 24,
				Font = "GothamBold",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Ignore Actor Remotes",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, remote calls from scripts running inside Actors will be ignored and not logged",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleNoActors,
					size = UDim2.new(0, 50, 0, 28),
					background = if noActors then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if noActors then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Ignore Executor Calls",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, remote calls from executor scripts (nil caller) will be ignored and not logged",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleNoExecutor,
					size = UDim2.new(0, 50, 0, 28),
					background = if noExecutor then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if noExecutor then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 100),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 8),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "UI Toggle Keybind",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "Press any key to set as the UI toggle keybind",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 8),
					}),
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 150, 0, 32),
						BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 6),
						}),
						Roact.createElement("TextLabel", {
							Text = "Current: " .. toggleKey.Name,
							TextSize = 14,
							Font = "Gotham",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
					Roact.createElement(Button, {
						onClick = startListeningForKey,
						size = UDim2.new(0, 150, 0, 32),
						background = if isListeningForKey then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.2, 0.5, 0.8),
						transparency = 0,
						cornerRadius = UDim.new(0, 6),
					}, {
						Roact.createElement("TextLabel", {
							Text = if isListeningForKey then "Press a key..." else "Change Keybind",
							TextSize = 14,
							Font = "GothamBold",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
				}),
			}),
			Roact.createElement("TextLabel", {
				Text = "Filter Options",
				TextSize = 18,
				Font = "GothamBold",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Show RemoteEvents",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, RemoteEvent calls will be logged and displayed",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleRemoteEvents,
					size = UDim2.new(0, 50, 0, 28),
					background = if showRemoteEvents then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if showRemoteEvents then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Show RemoteFunctions",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, RemoteFunction calls will be logged and displayed",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleRemoteFunctions,
					size = UDim2.new(0, 50, 0, 28),
					background = if showRemoteFunctions then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if showRemoteFunctions then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Show BindableEvents",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, BindableEvent calls will be logged and displayed",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleBindableEvents,
					size = UDim2.new(0, 50, 0, 28),
					background = if showBindableEvents then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if showBindableEvents then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 70),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = UDim.new(0, 12),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Show BindableFunctions",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "When enabled, BindableFunction calls will be logged and displayed",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 36),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement(Button, {
					onClick = handleToggleBindableFunctions,
					size = UDim2.new(0, 50, 0, 28),
					background = if showBindableFunctions then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.3, 0.3, 0.3),
					transparency = 0,
					cornerRadius = UDim.new(0, 14),
				}, {
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 22, 0, 22),
						Position = if showBindableFunctions then UDim2.new(1, -25, 0.5, 0) else UDim2.new(0, 3, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 11),
						}),
					}),
				}),
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 100),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 8),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Path Notation Style",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "Choose how to access instances in generated scripts (dots, WaitForChild, or FindFirstChild)",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 8),
					}),
					Roact.createElement(Button, {
						onClick = function()
							return handlePathNotationChange(PathNotation.Dot)
						end,
						size = UDim2.new(0, 120, 0, 32),
						background = if pathNotation == PathNotation.Dot then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.2, 0.2, 0.2),
						transparency = 0,
						cornerRadius = UDim.new(0, 6),
					}, {
						Roact.createElement("TextLabel", {
							Text = "Dot (.)",
							TextSize = 14,
							Font = "GothamBold",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
					Roact.createElement(Button, {
						onClick = function()
							return handlePathNotationChange(PathNotation.WaitForChild)
						end,
						size = UDim2.new(0, 120, 0, 32),
						background = if pathNotation == PathNotation.WaitForChild then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.2, 0.2, 0.2),
						transparency = 0,
						cornerRadius = UDim.new(0, 6),
					}, {
						Roact.createElement("TextLabel", {
							Text = "WaitForChild",
							TextSize = 14,
							Font = "GothamBold",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
					Roact.createElement(Button, {
						onClick = function()
							return handlePathNotationChange(PathNotation.FindFirstChild)
						end,
						size = UDim2.new(0, 120, 0, 32),
						background = if pathNotation == PathNotation.FindFirstChild then Color3.new(0.3, 0.7, 0.3) else Color3.new(0.2, 0.2, 0.2),
						transparency = 0,
						cornerRadius = UDim.new(0, 6),
					}, {
						Roact.createElement("TextLabel", {
							Text = "FindFirstChild",
							TextSize = 14,
							Font = "GothamBold",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
				}),
			}),
			Roact.createElement("TextLabel", {
				Text = "Inspection Tools",
				TextSize = 18,
				Font = "GothamBold",
				TextColor3 = Color3.new(1, 1, 1),
				Size = UDim2.new(1, 0, 0, 24),
				BackgroundTransparency = 1,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
			}),
			Roact.createElement("Frame", {
				Size = UDim2.new(1, 0, 0, 100),
				BackgroundTransparency = 1,
			}, {
				Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 8),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 56),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Vertical,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 4),
					}),
					Roact.createElement("TextLabel", {
						Text = "Maximum Inspection Results",
						TextSize = 16,
						Font = "GothamBold",
						TextColor3 = Color3.new(1, 1, 1),
						Size = UDim2.new(1, 0, 0, 20),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Center",
					}),
					Roact.createElement("TextLabel", {
						Text = "Set the maximum number of results to display when scanning (higher values may cause lag)",
						TextSize = 12,
						Font = "Gotham",
						TextColor3 = Color3.new(0.7, 0.7, 0.7),
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundTransparency = 1,
						TextXAlignment = "Left",
						TextYAlignment = "Top",
						TextWrapped = true,
					}),
				}),
				Roact.createElement("Frame", {
					Size = UDim2.new(1, 0, 0, 36),
					BackgroundTransparency = 1,
				}, {
					Roact.createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = UDim.new(0, 8),
					}),
					Roact.createElement("Frame", {
						Size = UDim2.new(0, 150, 0, 32),
						BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
						BorderSizePixel = 0,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 6),
						}),
						Roact.createElement("TextLabel", {
							Text = "Current: " .. tostring(maxInspectionResults),
							TextSize = 14,
							Font = "Gotham",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
					Roact.createElement("TextBox", {
						Size = UDim2.new(0, 150, 0, 32),
						PlaceholderText = "Enter number...",
						Text = maxResultsInput,
						TextSize = 14,
						Font = "Gotham",
						TextColor3 = Color3.new(1, 1, 1),
						BackgroundColor3 = Color3.new(0.15, 0.15, 0.15),
						BorderSizePixel = 0,
						TextXAlignment = "Center",
						ClearTextOnFocus = false,
						[Roact.Change.Text] = function(rbx)
							return setMaxResultsInput(rbx.Text)
						end,
					}, {
						Roact.createElement("UICorner", {
							CornerRadius = UDim.new(0, 6),
						}),
						Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 10),
							PaddingRight = UDim.new(0, 10),
						}),
					}),
					Roact.createElement(Button, {
						onClick = function()
							local num = tonumber(maxResultsInput)
							if num ~= nil and (num > 0 and num <= 10000) then
								dispatch(setMaxInspectionResults(num))
							else
								setMaxResultsInput(tostring(maxInspectionResults))
							end
						end,
						size = UDim2.new(0, 100, 0, 32),
						background = Color3.new(0.2, 0.5, 0.8),
						transparency = 0,
						cornerRadius = UDim.new(0, 6),
					}, {
						Roact.createElement("TextLabel", {
							Text = "Apply",
							TextSize = 14,
							Font = "GothamBold",
							TextColor3 = Color3.new(1, 1, 1),
							Size = UDim2.new(1, 0, 1, 0),
							BackgroundTransparency = 1,
							TextXAlignment = "Center",
							TextYAlignment = "Center",
						}),
					}),
				}),
			}),
		}),
	})
end
local default = withHooksPure(Settings)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Pages.Settings.Settings"))() end)

_module("Root", "ModuleScript", "RemoteSpy.components.Root", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local DISPLAY_ORDER = TS.import(script, script.Parent.Parent, "constants").DISPLAY_ORDER
local Players = TS.import(script, TS.getModule(script, "@rbxts", "services")).Players
local function hasCoreAccess()
	local _arg0 = function()
		return game:GetService("CoreGui").Name
	end
	local _success, _valueOrError = pcall(_arg0)
	return (_success and {
		success = true,
		value = _valueOrError,
	} or {
		success = false,
		error = _valueOrError,
	}).success
end
local function getTarget()
	if gethui then
		return gethui()
	end
	if hasCoreAccess() then
		return game:GetService("CoreGui")
	end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end
local function Root(_param)
	local displayOrder = _param.displayOrder
	if displayOrder == nil then
		displayOrder = 0
	end
	local enabled = _param.enabled
	if enabled == nil then
		enabled = true
	end
	local children = _param[Roact.Children]
	local _attributes = {
		target = getTarget(),
	}
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = "Sibling",
		DisplayOrder = DISPLAY_ORDER + displayOrder,
		Enabled = enabled,
	}
	local _children_1 = {}
	local _length_1 = #_children_1
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children_1[_length_1 + _k] = _v
			else
				_children_1[_k] = _v
			end
		end
	end
	_children[_length + 1] = Roact.createElement("ScreenGui", _attributes_1, _children_1)
	return Roact.createElement(Roact.Portal, _attributes, _children)
end
return {
	default = Root,
}
 end, _env("RemoteSpy.components.Root"))() end)

_module("Selection", "ModuleScript", "RemoteSpy.components.Selection", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Linear = _flipper.Linear
local Spring = _flipper.Spring
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local withHooksPure = _roact_hooked.withHooksPure
local _roact_hooked_plus = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out)
local useSingleMotor = _roact_hooked_plus.useSingleMotor
local useSpring = _roact_hooked_plus.useSpring
local function Selection(_param)
	local height = _param.height
	local offset = _param.offset
	local hasSelection = _param.hasSelection
	local _binding = useSingleMotor(-100)
	local offsetAnim = _binding[1]
	local setOffsetGoal = _binding[2]
	local offsetSpring = _binding[3]
	local _binding_1 = useSingleMotor(0)
	local speedAnim = _binding_1[1]
	local setSpeedGoal = _binding_1[2]
	local heightAnim = useSpring(if hasSelection then 20 else 0, {
		frequency = 8,
	})
	useEffect(function()
		if offset ~= nil then
			setOffsetGoal(Spring.new(offset, {
				frequency = 5,
			}))
		end
	end, { offset })
	useEffect(function()
		if hasSelection and offset ~= nil then
			setOffsetGoal(Instant.new(offset))
		end
	end, { hasSelection })
	useEffect(function()
		if not hasSelection then
			setSpeedGoal(Instant.new(0))
			return nil
		end
		local lastValue = offset
		local lastTime = 0
		local handle = offsetSpring:onStep(function(value)
			local now = tick()
			local deltaTime = now - lastTime
			if lastValue ~= nil then
				setSpeedGoal(Linear.new(math.abs(value - lastValue) / (deltaTime * 60), {
					velocity = 300,
				}))
				lastValue = value
			end
			lastTime = now
		end)
		return function()
			return handle:disconnect()
		end
	end, { hasSelection })
	return Roact.createElement(Container, {
		size = UDim2.new(0, 4, 0, height),
		position = offsetAnim:map(function(y)
			return UDim2.new(0, 0, 0, math.round(y))
		end),
	}, {
		Roact.createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Size = Roact.joinBindings({ heightAnim, speedAnim }):map(function(_param_1)
				local h = _param_1[1]
				local s = _param_1[2]
				return UDim2.new(0, 4, 0, math.round(h + s * 1.7))
			end),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromHex("#4CC2FF"),
		}, {
			Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 2),
			}),
		}),
	})
end
local default = withHooksPure(Selection)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Selection"))() end)

_module("SettingsPersistence", "ModuleScript", "RemoteSpy.components.SettingsPersistence", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "SettingsPersistence").default
return exports
 end, _env("RemoteSpy.components.SettingsPersistence"))() end)

_module("SettingsPersistence", "ModuleScript", "RemoteSpy.components.SettingsPersistence.SettingsPersistence", "RemoteSpy.components.SettingsPersistence", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local withHooksPure = _roact_hooked.withHooksPure
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local _remote_log = TS.import(script, script.Parent.Parent.Parent, "reducers", "remote-log")
local selectNoActors = _remote_log.selectNoActors
local selectNoExecutor = _remote_log.selectNoExecutor
local selectShowRemoteEvents = _remote_log.selectShowRemoteEvents
local selectShowRemoteFunctions = _remote_log.selectShowRemoteFunctions
local selectShowBindableEvents = _remote_log.selectShowBindableEvents
local selectShowBindableFunctions = _remote_log.selectShowBindableFunctions
local selectPathNotation = _remote_log.selectPathNotation
local loadSettingsAction = _remote_log.loadSettings
local _ui = TS.import(script, script.Parent.Parent.Parent, "reducers", "ui")
local selectToggleKey = _ui.selectToggleKey
local loadToggleKey = _ui.loadToggleKey
local _settings_persistence = TS.import(script, script.Parent.Parent.Parent, "utils", "settings-persistence")
local loadSettings = _settings_persistence.loadSettings
local saveSettings = _settings_persistence.saveSettings
local function SettingsPersistence()
	local dispatch = useRootDispatch()
	local loaded = useMutable(false)
	local noActors = useRootSelector(selectNoActors)
	local noExecutor = useRootSelector(selectNoExecutor)
	local showRemoteEvents = useRootSelector(selectShowRemoteEvents)
	local showRemoteFunctions = useRootSelector(selectShowRemoteFunctions)
	local showBindableEvents = useRootSelector(selectShowBindableEvents)
	local showBindableFunctions = useRootSelector(selectShowBindableFunctions)
	local pathNotation = useRootSelector(selectPathNotation)
	local toggleKey = useRootSelector(selectToggleKey)
	useEffect(function()
		local connection = task.delay(1, function()
			local settings = loadSettings()
			if settings then
				dispatch(loadSettingsAction(settings))
				local _value = settings.toggleKey
				if _value ~= "" and _value then
					dispatch(loadToggleKey(settings.toggleKey))
				end
			end
			loaded.current = true
		end)
		return function()
			if connection then
				task.cancel(connection)
			end
		end
	end, {})
	useEffect(function()
		if not loaded.current then
			return nil
		end
		local settings = {
			noActors = noActors,
			noExecutor = noExecutor,
			showRemoteEvents = showRemoteEvents,
			showRemoteFunctions = showRemoteFunctions,
			showBindableEvents = showBindableEvents,
			showBindableFunctions = showBindableFunctions,
			pathNotation = pathNotation,
			toggleKey = toggleKey.Name,
		}
		saveSettings(settings)
	end, { noActors, noExecutor, showRemoteEvents, showRemoteFunctions, showBindableEvents, showBindableFunctions, pathNotation, toggleKey })
	return Roact.createFragment()
end
local default = withHooksPure(SettingsPersistence)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SettingsPersistence.SettingsPersistence"))() end)

_module("SidePanel", "ModuleScript", "RemoteSpy.components.SidePanel", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "SidePanel").default
for _k, _v in pairs(TS.import(script, script, "use-side-panel-context") or {}) do
	exports[_k] = _v
end
return exports
 end, _env("RemoteSpy.components.SidePanel"))() end)

_module("FunctionTree", "ModuleScript", "RemoteSpy.components.SidePanel.FunctionTree", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "FunctionTree").default
return exports
 end, _env("RemoteSpy.components.SidePanel.FunctionTree"))() end)

_module("FunctionTree", "ModuleScript", "RemoteSpy.components.SidePanel.FunctionTree.FunctionTree", "RemoteSpy.components.SidePanel.FunctionTree", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local _function_util = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "function-util")
local describeFunction = _function_util.describeFunction
local stringifyFunctionSignature = _function_util.stringifyFunctionSignature
local selectSignalSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").selectSignalSelected
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local function FunctionNode(_param)
	local fn = _param.fn
	local index = _param.index
	local totalInStack = _param.totalInStack
	local remotePath = _param.remotePath
	local remoteName = _param.remoteName
	local description = describeFunction(fn)
	local signature = stringifyFunctionSignature(fn)
	local isRemoteCaller = index == totalInStack - 1
	local level = index + 1
	local _attributes = {
		AutomaticSize = "Y",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = if isRemoteCaller then Color3.new(0.15, 0.4, 0.15) else Color3.new(1, 1, 1),
		BackgroundTransparency = if isRemoteCaller then 0.8 else 0.93,
		BorderSizePixel = 0,
		LayoutOrder = index,
	}
	local _children = {
		Roact.createElement("UIListLayout", {
			FillDirection = "Vertical",
			Padding = UDim.new(0, 2),
			VerticalAlignment = "Top",
		}),
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12 + index * 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDim.new(0, 6),
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = (if isRemoteCaller then "└─ " else "├─ ") .. ("Level " .. (tostring(level) .. (if isRemoteCaller then " (Remote Caller)" else ""))),
			Font = "Gotham",
			TextColor3 = Color3.new(0.6, 0.6, 0.6),
			TextSize = 10,
			TextXAlignment = "Left",
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = if isRemoteCaller then "→ " .. (signature .. " ←") else signature,
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = formatEscapes(description.source),
			Font = "Gotham",
			TextColor3 = Color3.new(0.75, 0.75, 0.75),
			TextSize = 9,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
	}
	local _length = #_children
	local _child = isRemoteCaller and (Roact.createFragment({
		Roact.createElement("Frame", {
			Size = UDim2.new(1, -16, 0, 1),
			BackgroundColor3 = Color3.new(0.2, 0.5, 0.2),
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = "Calls Remote: " .. formatEscapes(remoteName),
			Font = "Gotham",
			TextColor3 = Color3.new(0.3, 0.7, 0.3),
			TextSize = 10,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = "Path: " .. formatEscapes(remotePath),
			Font = "Gotham",
			TextColor3 = Color3.new(0.3, 0.7, 0.3),
			TextSize = 9,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
	}))
	if _child then
		_children[_length + 1] = _child
	end
	return Roact.createElement("Frame", _attributes, _children)
end
local function FunctionTree()
	local _binding = useSidePanelContext()
	local setUpperHidden = _binding.setUpperHidden
	local upperHidden = _binding.upperHidden
	local upperSize = _binding.upperSize
	local signal = useRootSelector(selectSignalSelected)
	local isEmpty = not signal or #signal.traceback == 0
	local _result
	if not isEmpty and signal then
		local _traceback = signal.traceback
		local _arg0 = function(fn, index)
			return Roact.createElement(FunctionNode, {
				fn = fn,
				index = index,
				totalInStack = #signal.traceback,
				remotePath = signal.path,
				remoteName = signal.name,
			})
		end
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#_traceback)
		for _k, _v in ipairs(_traceback) do
			_newValue[_k] = _arg0(_v, _k - 1, _traceback)
		end
		-- ▲ ReadonlyArray.map ▲
		local _attributes = {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			AutomaticCanvasSize = "Y",
		}
		local _children = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				VerticalAlignment = "Top",
				SortOrder = "LayoutOrder",
				Padding = UDim.new(0, 2),
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		}
		local _length = #_children
		for _k, _v in ipairs(_newValue) do
			_children[_length + _k] = _v
		end
		_result = (Roact.createElement("ScrollingFrame", _attributes, _children))
	else
		_result = (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = "Select a signal to view function tree",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}))
	end
	local _attributes = {
		size = upperSize,
	}
	local _children = {
		Roact.createElement(TitleBar, {
			caption = "Function Tree" .. (if signal then " (" .. (tostring(#signal.traceback) .. ")") else ""),
			hidden = upperHidden,
			toggleHidden = function()
				return setUpperHidden(not upperHidden)
			end,
		}),
	}
	local _length = #_children
	_children[_length + 1] = _result
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(FunctionTree)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.FunctionTree.FunctionTree"))() end)

_module("InspectionConstants", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionConstants", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "InspectionConstants").default
return exports
 end, _env("RemoteSpy.components.SidePanel.InspectionConstants"))() end)

_module("InspectionConstants", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionConstants.InspectionConstants", "RemoteSpy.components.SidePanel.InspectionConstants", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local selectInspectionResultSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").selectInspectionResultSelected
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local function InspectionConstants()
	local _binding = useSidePanelContext()
	local lowerSize = _binding.lowerSize
	local lowerPosition = _binding.lowerPosition
	local lowerHidden = _binding.lowerHidden
	local setLowerHidden = _binding.setLowerHidden
	local selectedResult = useRootSelector(selectInspectionResultSelected)
	local _result = selectedResult
	if _result ~= nil then
		_result = _result.rawConstants
	end
	local _condition = _result
	if _condition then
		_condition = #selectedResult.rawConstants > 0
	end
	local showConstants = _condition
	local _result_1 = selectedResult
	if _result_1 ~= nil then
		_result_1 = _result_1.rawScript
	end
	local _condition_1 = _result_1
	if _condition_1 then
		_condition_1 = not showConstants
	end
	local showScript = _condition_1
	local _result_2 = selectedResult
	if _result_2 ~= nil then
		_result_2 = _result_2.rawConstants
		if _result_2 ~= nil then
			_result_2 = #_result_2
		end
	end
	local _condition_2 = _result_2
	if _condition_2 == nil then
		_condition_2 = 0
	end
	local constantCount = _condition_2
	local isEmpty = not selectedResult or (not showConstants and not showScript)
	local _result_3
	if not isEmpty then
		local _attributes = {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			AutomaticCanvasSize = "Y",
		}
		local _children = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(0, 2),
				VerticalAlignment = "Top",
				SortOrder = "LayoutOrder",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		}
		local _length = #_children
		local _child = if showConstants then ((function()
			local elements = {}
			do
				local i = 0
				local _shouldIncrement = false
				while true do
					if _shouldIncrement then
						i += 1
					else
						_shouldIncrement = true
					end
					if not (i < #selectedResult.rawConstants) then
						break
					end
					local value = selectedResult.rawConstants[i + 1]
					local _arg0 = Roact.createFragment({
						["constant_" .. tostring(i)] = Roact.createElement("Frame", {
							AutomaticSize = "Y",
							Size = UDim2.new(1, -8, 0, 0),
							BackgroundColor3 = Color3.new(1, 1, 1),
							BackgroundTransparency = 0.95,
							BorderSizePixel = 0,
							LayoutOrder = i,
						}, {
							Roact.createElement("UIListLayout", {
								FillDirection = "Vertical",
								Padding = UDim.new(0, 2),
								VerticalAlignment = "Top",
							}),
							Roact.createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 4),
								PaddingBottom = UDim.new(0, 4),
							}),
							Roact.createElement("TextLabel", {
								AutomaticSize = "Y",
								Size = UDim2.new(1, -16, 0, 0),
								Text = "[" .. (tostring(i + 1) .. ("] " .. typeof(value))),
								Font = "GothamBold",
								TextColor3 = Color3.new(0.9, 0.7, 1),
								TextSize = 10,
								TextXAlignment = "Left",
								BackgroundTransparency = 1,
							}),
							Roact.createElement("TextLabel", {
								AutomaticSize = "Y",
								Size = UDim2.new(1, -16, 0, 0),
								Text = string.sub(tostring(value), 1, 150),
								Font = "Code",
								TextColor3 = Color3.new(0.8, 0.8, 0.8),
								TextSize = 9,
								TextXAlignment = "Left",
								TextWrapped = true,
								BackgroundTransparency = 1,
							}),
						}),
					})
					table.insert(elements, _arg0)
				end
			end
			return elements
		end)()) elseif showScript then (Roact.createElement("Frame", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -8, 0, 0),
			BackgroundColor3 = Color3.new(0.05, 0.05, 0.05),
			BackgroundTransparency = 0.3,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}, {
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
			}),
			Roact.createElement("TextLabel", {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
				Text = (function()
					if decompile then
						local success = { pcall(function()
							return decompile(selectedResult.rawScript)
						end) }
						if success[1] then
							local source = success[2]
							local lines = string.split(source, "\n")
							if #lines > 50 then
								local previewLines = {}
								do
									local i = 0
									local _shouldIncrement = false
									while true do
										if _shouldIncrement then
											i += 1
										else
											_shouldIncrement = true
										end
										if not (i < 50) then
											break
										end
										local _arg0 = lines[i + 1]
										table.insert(previewLines, _arg0)
									end
								end
								return table.concat(previewLines, "\n") .. "\n\n-- ... (truncated, use View Script button for full source)"
							end
							return source
						else
							return "-- Failed to decompile\n-- Error: " .. tostring(success[2])
						end
					else
						return "-- decompile() function not available\n-- Use View Script button to open in viewer"
					end
				end)(),
				Font = "Code",
				TextColor3 = Color3.new(0.85, 0.85, 0.85),
				TextSize = 9,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		})) else nil
		if _child then
			if _child.elements ~= nil or _child.props ~= nil and _child.component ~= nil then
				_children[_length + 1] = _child
			else
				for _k, _v in ipairs(_child) do
					_children[_length + _k] = _v
				end
			end
		end
		_result_3 = (Roact.createElement("ScrollingFrame", _attributes, _children))
	else
		_result_3 = (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = "Select a result to view details",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}))
	end
	local _attributes = {
		size = lowerSize,
		position = lowerPosition,
	}
	local _children = {
		Roact.createElement(TitleBar, {
			caption = if showScript then "Script Preview" elseif showConstants then "Constants (" .. (tostring(constantCount) .. ")") else "Constants",
			hidden = lowerHidden,
			toggleHidden = function()
				return setLowerHidden(not lowerHidden)
			end,
		}),
	}
	local _length = #_children
	_children[_length + 1] = _result_3
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(InspectionConstants)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.InspectionConstants.InspectionConstants"))() end)

_module("InspectionMetadata", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionMetadata", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "InspectionMetadata").default
return exports
 end, _env("RemoteSpy.components.SidePanel.InspectionMetadata"))() end)

_module("InspectionMetadata", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionMetadata.InspectionMetadata", "RemoteSpy.components.SidePanel.InspectionMetadata", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local selectInspectionResultSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").selectInspectionResultSelected
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local function InspectionMetadata()
	local _binding = useSidePanelContext()
	local upperSize = _binding.upperSize
	local upperHidden = _binding.upperHidden
	local setUpperHidden = _binding.setUpperHidden
	local selectedResult = useRootSelector(selectInspectionResultSelected)
	local isEmpty = not selectedResult
	local _result
	if not isEmpty then
		local _attributes = {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			AutomaticCanvasSize = "Y",
		}
		local _children = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(0, 2),
				VerticalAlignment = "Top",
				SortOrder = "LayoutOrder",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		}
		local _length = #_children
		local _attributes_1 = {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -8, 0, 0),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.95,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}
		local _children_1 = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(0, 2),
				VerticalAlignment = "Top",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			}),
			Roact.createElement("TextLabel", {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
				Text = "Basic Information",
				Font = "GothamBold",
				TextColor3 = Color3.new(0.9, 0.9, 1),
				TextSize = 11,
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
			}),
			Roact.createElement("TextLabel", {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
				Text = "Type: " .. selectedResult.type,
				Font = "Gotham",
				TextColor3 = Color3.new(0.8, 0.8, 0.8),
				TextSize = 10,
				TextXAlignment = "Left",
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}
		local _length_1 = #_children_1
		local _child = selectedResult.value ~= nil and (Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = "Path: " .. formatEscapes(selectedResult.value),
			Font = "Gotham",
			TextColor3 = Color3.new(0.75, 0.75, 0.75),
			TextSize = 9,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}))
		if _child then
			_children_1[_length_1 + 1] = _child
		end
		_children[_length + 1] = Roact.createElement("Frame", _attributes_1, _children_1)
		local _condition = selectedResult.rawInfo
		if _condition then
			local _attributes_2 = {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -8, 0, 0),
				BackgroundColor3 = Color3.new(0.2, 0.5, 0.2),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}
			local _children_2 = {
				Roact.createElement("UIListLayout", {
					FillDirection = "Vertical",
					Padding = UDim.new(0, 2),
					VerticalAlignment = "Top",
				}),
				Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
				}),
				Roact.createElement("TextLabel", {
					AutomaticSize = "Y",
					Size = UDim2.new(1, -16, 0, 0),
					Text = "Function Details",
					Font = "GothamBold",
					TextColor3 = Color3.new(0.9, 0.9, 1),
					TextSize = 11,
					TextXAlignment = "Left",
					BackgroundTransparency = 1,
				}),
			}
			local _length_2 = #_children_2
			local _attributes_3 = {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
			}
			local _condition_1 = selectedResult.rawInfo.short_src
			if _condition_1 == nil then
				_condition_1 = selectedResult.rawInfo.source
				if _condition_1 == nil then
					_condition_1 = "unknown"
				end
			end
			_attributes_3.Text = "Source: " .. formatEscapes(_condition_1)
			_attributes_3.Font = "Gotham"
			_attributes_3.TextColor3 = Color3.new(0.75, 0.75, 0.75)
			_attributes_3.TextSize = 9
			_attributes_3.TextXAlignment = "Left"
			_attributes_3.TextWrapped = true
			_attributes_3.BackgroundTransparency = 1
			_children_2[_length_2 + 1] = Roact.createElement("TextLabel", _attributes_3)
			local _attributes_4 = {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
			}
			local _condition_2 = selectedResult.rawInfo.what
			if _condition_2 == nil then
				_condition_2 = "Lua"
			end
			local _condition_3 = selectedResult.rawInfo.nups
			if _condition_3 == nil then
				_condition_3 = 0
			end
			_attributes_4.Text = "Type: " .. (_condition_2 .. (" | Upvalues: " .. tostring(_condition_3)))
			_attributes_4.Font = "Gotham"
			_attributes_4.TextColor3 = Color3.new(0.8, 0.8, 0.8)
			_attributes_4.TextSize = 10
			_attributes_4.TextXAlignment = "Left"
			_attributes_4.BackgroundTransparency = 1
			_children_2[_length_2 + 2] = Roact.createElement("TextLabel", _attributes_4)
			local _condition_4 = selectedResult.rawInfo.linedefined ~= nil
			if _condition_4 then
				local _attributes_5 = {
					AutomaticSize = "Y",
					Size = UDim2.new(1, -16, 0, 0),
				}
				local _exp = selectedResult.rawInfo.linedefined
				local _condition_5 = selectedResult.rawInfo.lastlinedefined
				if _condition_5 == nil then
					_condition_5 = "?"
				end
				_attributes_5.Text = "Lines: " .. (tostring(_exp) .. (" - " .. tostring(_condition_5)))
				_attributes_5.Font = "Gotham"
				_attributes_5.TextColor3 = Color3.new(0.8, 0.8, 0.8)
				_attributes_5.TextSize = 10
				_attributes_5.TextXAlignment = "Left"
				_attributes_5.BackgroundTransparency = 1
				_condition_4 = (Roact.createElement("TextLabel", _attributes_5))
			end
			if _condition_4 then
				_children_2[_length_2 + 3] = _condition_4
			end
			_condition = (Roact.createElement("Frame", _attributes_2, _children_2))
		end
		if _condition then
			_children[_length + 2] = _condition
		end
		_length = #_children
		local _condition_1 = selectedResult.rawScript
		if _condition_1 then
			local _attributes_2 = {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -8, 0, 0),
				BackgroundColor3 = Color3.new(0.15, 0.35, 0.6),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				LayoutOrder = 3,
			}
			local _children_2 = {
				Roact.createElement("UIListLayout", {
					FillDirection = "Vertical",
					Padding = UDim.new(0, 2),
					VerticalAlignment = "Top",
				}),
				Roact.createElement("UIPadding", {
					PaddingLeft = UDim.new(0, 8),
					PaddingRight = UDim.new(0, 8),
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
				}),
				Roact.createElement("TextLabel", {
					AutomaticSize = "Y",
					Size = UDim2.new(1, -16, 0, 0),
					Text = "Script Hierarchy",
					Font = "GothamBold",
					TextColor3 = Color3.new(0.9, 0.9, 1),
					TextSize = 11,
					TextXAlignment = "Left",
					BackgroundTransparency = 1,
				}),
				Roact.createElement("TextLabel", {
					AutomaticSize = "Y",
					Size = UDim2.new(1, -16, 0, 0),
					Text = "Class: " .. selectedResult.rawScript.ClassName,
					Font = "Gotham",
					TextColor3 = Color3.new(0.8, 0.8, 0.9),
					TextSize = 10,
					TextXAlignment = "Left",
					BackgroundTransparency = 1,
				}),
			}
			local _length_2 = #_children_2
			local _attributes_3 = {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
			}
			local _result_1 = selectedResult.rawScript.Parent
			if _result_1 ~= nil then
				_result_1 = _result_1.Name
			end
			local _condition_2 = _result_1
			if _condition_2 == nil then
				_condition_2 = "nil"
			end
			_attributes_3.Text = "Parent: " .. (_condition_2 .. (if selectedResult.rawScript.Parent then " (" .. (selectedResult.rawScript.Parent.ClassName .. ")") else ""))
			_attributes_3.Font = "Gotham"
			_attributes_3.TextColor3 = Color3.new(0.75, 0.75, 0.75)
			_attributes_3.TextSize = 9
			_attributes_3.TextXAlignment = "Left"
			_attributes_3.TextWrapped = true
			_attributes_3.BackgroundTransparency = 1
			_children_2[_length_2 + 1] = Roact.createElement("TextLabel", _attributes_3)
			_condition_1 = (Roact.createElement("Frame", _attributes_2, _children_2))
		end
		if _condition_1 then
			_children[_length + 1] = _condition_1
		end
		_result = (Roact.createElement("ScrollingFrame", _attributes, _children))
	else
		_result = (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = "Select an inspection result to view metadata",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}))
	end
	local _attributes = {
		size = upperSize,
	}
	local _children = {
		Roact.createElement(TitleBar, {
			caption = "Metadata" .. (if selectedResult then " - " .. selectedResult.name else ""),
			hidden = upperHidden,
			toggleHidden = function()
				return setUpperHidden(not upperHidden)
			end,
		}),
	}
	local _length = #_children
	_children[_length + 1] = _result
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(InspectionMetadata)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.InspectionMetadata.InspectionMetadata"))() end)

_module("InspectionUpvalues", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionUpvalues", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "InspectionUpvalues").default
return exports
 end, _env("RemoteSpy.components.SidePanel.InspectionUpvalues"))() end)

_module("InspectionUpvalues", "ModuleScript", "RemoteSpy.components.SidePanel.InspectionUpvalues.InspectionUpvalues", "RemoteSpy.components.SidePanel.InspectionUpvalues", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local selectInspectionResultSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").selectInspectionResultSelected
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local function InspectionUpvalues()
	local _binding = useSidePanelContext()
	local middleSize = _binding.middleSize
	local middlePosition = _binding.middlePosition
	local middleHidden = _binding.middleHidden
	local setMiddleHidden = _binding.setMiddleHidden
	local selectedResult = useRootSelector(selectInspectionResultSelected)
	local _condition = not selectedResult or not selectedResult.rawUpvalues
	if not _condition then
		-- ▼ ReadonlyMap.size ▼
		local _size = 0
		for _ in pairs(selectedResult.rawUpvalues) do
			_size += 1
		end
		-- ▲ ReadonlyMap.size ▲
		_condition = _size == 0
	end
	local isEmpty = _condition
	local _result = selectedResult
	if _result ~= nil then
		_result = _result.rawUpvalues
		if _result ~= nil then
			-- ▼ ReadonlyMap.size ▼
			local _size = 0
			for _ in pairs(_result) do
				_size += 1
			end
			-- ▲ ReadonlyMap.size ▲
			_result = _size
		end
	end
	local _condition_1 = _result
	if _condition_1 == nil then
		_condition_1 = 0
	end
	local upvalueCount = _condition_1
	local _result_1
	if not isEmpty then
		local _attributes = {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			AutomaticCanvasSize = "Y",
		}
		local _children = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(0, 2),
				VerticalAlignment = "Top",
				SortOrder = "LayoutOrder",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 4),
				PaddingBottom = UDim.new(0, 4),
			}),
		}
		local _length = #_children
		for _k, _v in ipairs((function()
			local elements = {}
			local index = 0
			local _0 = selectedResult.rawUpvalues
			local _1 = function(value, key)
				local _2 = Roact.createFragment({
					[tostring(key)] = Roact.createElement("Frame", {
						AutomaticSize = "Y",
						Size = UDim2.new(1, -8, 0, 0),
						BackgroundColor3 = Color3.new(1, 1, 1),
						BackgroundTransparency = 0.95,
						BorderSizePixel = 0,
						LayoutOrder = index,
					}, {
						Roact.createElement("UIListLayout", {
							FillDirection = "Vertical",
							Padding = UDim.new(0, 2),
							VerticalAlignment = "Top",
						}),
						Roact.createElement("UIPadding", {
							PaddingLeft = UDim.new(0, 8),
							PaddingRight = UDim.new(0, 8),
							PaddingTop = UDim.new(0, 4),
							PaddingBottom = UDim.new(0, 4),
						}),
						Roact.createElement("TextLabel", {
							AutomaticSize = "Y",
							Size = UDim2.new(1, -16, 0, 0),
							Text = tostring(key),
							Font = "GothamBold",
							TextColor3 = Color3.new(0.7, 0.9, 1),
							TextSize = 10,
							TextXAlignment = "Left",
							BackgroundTransparency = 1,
						}),
						Roact.createElement("TextLabel", {
							AutomaticSize = "Y",
							Size = UDim2.new(1, -16, 0, 0),
							Text = typeof(value) .. (": " .. string.sub(tostring(value), 1, 150)),
							Font = "Gotham",
							TextColor3 = Color3.new(0.8, 0.8, 0.8),
							TextSize = 9,
							TextXAlignment = "Left",
							TextWrapped = true,
							BackgroundTransparency = 1,
						}),
					}),
				})
				table.insert(elements, _2)
				index += 1
			end
			for _3, _4 in pairs(_0) do
				_1(_4, _3, _0)
			end
			return elements
		end)()) do
			_children[_length + _k] = _v
		end
		_result_1 = (Roact.createElement("ScrollingFrame", _attributes, _children))
	else
		_result_1 = (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = if not selectedResult then "Select a function to view upvalues" else "No upvalues found",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}))
	end
	local _attributes = {
		size = middleSize,
		position = middlePosition,
	}
	local _children = {
		Roact.createElement(TitleBar, {
			caption = "Upvalues" .. (if upvalueCount > 0 then " (" .. (tostring(upvalueCount) .. ")") else ""),
			hidden = middleHidden,
			toggleHidden = function()
				return setMiddleHidden(not middleHidden)
			end,
		}),
	}
	local _length = #_children
	_children[_length + 1] = _result_1
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(InspectionUpvalues)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.InspectionUpvalues.InspectionUpvalues"))() end)

_module("Peek", "ModuleScript", "RemoteSpy.components.SidePanel.Peek", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Peek").default
return exports
 end, _env("RemoteSpy.components.SidePanel.Peek"))() end)

_module("Peek", "ModuleScript", "RemoteSpy.components.SidePanel.Peek.Peek", "RemoteSpy.components.SidePanel.Peek", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local _remote_log = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log")
local selectSignalSelected = _remote_log.selectSignalSelected
local selectPathNotation = _remote_log.selectPathNotation
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local genScript = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "gen-script").genScript
local highlightLua = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "syntax-highlight").highlightLua
local function Peek()
	local _binding = useSidePanelContext()
	local middleHidden = _binding.middleHidden
	local setMiddleHidden = _binding.setMiddleHidden
	local middleSize = _binding.middleSize
	local middlePosition = _binding.middlePosition
	local signal = useRootSelector(selectSignalSelected)
	local pathNotation = useRootSelector(selectPathNotation)
	local scriptCode = ""
	local highlightedCode = ""
	if signal then
		local paramEntries = {}
		for key, value in pairs(signal.parameters) do
			local _arg0 = { key, value }
			table.insert(paramEntries, _arg0)
		end
		local _arg0 = function(a, b)
			return a[1] < b[1]
		end
		table.sort(paramEntries, _arg0)
		local _arg0_1 = function(_param)
			local _ = _param[1]
			local value = _param[2]
			return value
		end
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#paramEntries)
		for _k, _v in ipairs(paramEntries) do
			_newValue[_k] = _arg0_1(_v, _k - 1, paramEntries)
		end
		-- ▲ ReadonlyArray.map ▲
		local parameters = _newValue
		scriptCode = genScript(signal.remote, parameters, pathNotation)
		highlightedCode = highlightLua(scriptCode)
	end
	local isEmpty = not signal or scriptCode == ""
	return Roact.createElement(Container, {
		size = middleSize,
		position = middlePosition,
	}, {
		Roact.createElement(TitleBar, {
			caption = "Peek",
			hidden = middleHidden,
			toggleHidden = function()
				return setMiddleHidden(not middleHidden)
			end,
		}),
		if not isEmpty then (Roact.createElement("ScrollingFrame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
			CanvasSize = UDim2.new(1, 0, 0, 10000),
		}, {
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 12),
				PaddingRight = UDim.new(0, 12),
				PaddingTop = UDim.new(0, 12),
				PaddingBottom = UDim.new(0, 12),
			}),
			Roact.createElement("TextLabel", {
				Size = UDim2.new(1, 0, 1, 0),
				Text = highlightedCode,
				RichText = true,
				Font = Enum.Font.Code,
				TextSize = 11,
				TextColor3 = Color3.fromRGB(212, 212, 212),
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				TextWrapped = false,
				BackgroundTransparency = 1,
			}),
		})) else (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = "Select a signal to peek at the generated script",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		})),
	})
end
local default = withHooksPure(Peek)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.Peek.Peek"))() end)

_module("SidePanel", "ModuleScript", "RemoteSpy.components.SidePanel.SidePanel", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent, "Container").default
local FunctionTree = TS.import(script, script.Parent, "FunctionTree").default
local InspectionConstants = TS.import(script, script.Parent, "InspectionConstants").default
local InspectionMetadata = TS.import(script, script.Parent, "InspectionMetadata").default
local InspectionUpvalues = TS.import(script, script.Parent, "InspectionUpvalues").default
local Peek = TS.import(script, script.Parent, "Peek").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Traceback = TS.import(script, script.Parent, "Traceback").default
local SIDE_PANEL_WIDTH = TS.import(script, script.Parent.Parent.Parent, "constants").SIDE_PANEL_WIDTH
local SidePanelContext = TS.import(script, script.Parent, "use-side-panel-context").SidePanelContext
local TabType = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group", "model").TabType
local selectActiveTab = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group").selectActiveTab
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local withHooksPure = _roact_hooked.withHooksPure
local useRootSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local useSpring = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useSpring
local MIN_PANEL_HEIGHT = 40
local MIDDLE_PANEL_HEIGHT = 150
local function SidePanel()
	local currentTab = useRootSelector(selectActiveTab)
	local _result = currentTab
	if _result ~= nil then
		_result = _result.type
	end
	local isInspectionTab = _result == TabType.Inspection
	local lowerHeight, setLowerHeight = useBinding(200)
	local lowerHidden, setLowerHidden = useState(false)
	local middleHidden, setMiddleHidden = useState(false)
	local upperHidden, setUpperHidden = useState(false)
	local lowerAnim = useSpring(if lowerHidden then 1 else 0, {
		frequency = 8,
	})
	local middleAnim = useSpring(if middleHidden then 1 else 0, {
		frequency = 8,
	})
	local upperAnim = useSpring(if upperHidden then 1 else 0, {
		frequency = 8,
	})
	local lowerSize = useMemo(function()
		return Roact.joinBindings({ lowerHeight, lowerAnim, upperAnim }):map(function(_param)
			local height = _param[1]
			local n = _param[2]
			local ftn = _param[3]
			local lowerShown = UDim2.new(1, 0, 0, height)
			local lowerHidden = UDim2.new(1, 0, 0, MIN_PANEL_HEIGHT)
			local upperHidden = UDim2.new(1, 0, 1, -MIN_PANEL_HEIGHT)
			return lowerShown:Lerp(upperHidden, ftn):Lerp(lowerHidden, n)
		end)
	end, {})
	local lowerPosition = useMemo(function()
		return Roact.joinBindings({ lowerHeight, lowerAnim, upperAnim }):map(function(_param)
			local height = _param[1]
			local n = _param[2]
			local ftn = _param[3]
			local lowerShown = UDim2.new(0, 0, 1, -height)
			local lowerHidden = UDim2.new(0, 0, 1, -MIN_PANEL_HEIGHT)
			local upperHidden = UDim2.new(0, 0, 0, MIN_PANEL_HEIGHT)
			return lowerShown:Lerp(lowerHidden, n):Lerp(upperHidden, ftn)
		end)
	end, {})
	local middleSize = useMemo(function()
		return middleAnim:map(function(n)
			local middleShown = UDim2.new(1, 0, 0, MIDDLE_PANEL_HEIGHT)
			local middleHidden = UDim2.new(1, 0, 0, MIN_PANEL_HEIGHT)
			return middleShown:Lerp(middleHidden, n)
		end)
	end, {})
	local middlePosition = useMemo(function()
		return Roact.joinBindings({ lowerHeight, middleAnim, lowerAnim }):map(function(_param)
			local lHeight = _param[1]
			local mAnim = _param[2]
			local lAnim = _param[3]
			local middleHeightActual = MIDDLE_PANEL_HEIGHT * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim
			local lowerHeightActual = lHeight * (1 - lAnim) + MIN_PANEL_HEIGHT * lAnim
			return UDim2.new(0, 0, 1, -lowerHeightActual - middleHeightActual)
		end)
	end, {})
	local upperSize = useMemo(function()
		return Roact.joinBindings({ lowerHeight, upperAnim, lowerAnim, middleAnim }):map(function(_param)
			local lHeight = _param[1]
			local uAnim = _param[2]
			local lAnim = _param[3]
			local mAnim = _param[4]
			local middleHeightActual = MIDDLE_PANEL_HEIGHT * (1 - mAnim) + MIN_PANEL_HEIGHT * mAnim
			local lowerHeightActual = lHeight * (1 - lAnim) + MIN_PANEL_HEIGHT * lAnim
			local upperShown = UDim2.new(1, 0, 1, -middleHeightActual - lowerHeightActual)
			local upperHidden = UDim2.new(1, 0, 0, MIN_PANEL_HEIGHT)
			local lowerHidden = UDim2.new(1, 0, 1, -MIN_PANEL_HEIGHT - middleHeightActual)
			return upperShown:Lerp(lowerHidden, lAnim):Lerp(upperHidden, uAnim)
		end)
	end, {})
	return Roact.createElement(SidePanelContext.Provider, {
		value = {
			upperHidden = upperHidden,
			upperSize = upperSize,
			setUpperHidden = setUpperHidden,
			middleHidden = middleHidden,
			middleSize = middleSize,
			middlePosition = middlePosition,
			setMiddleHidden = setMiddleHidden,
			lowerHidden = lowerHidden,
			lowerSize = lowerSize,
			lowerPosition = lowerPosition,
			setLowerHidden = setLowerHidden,
			setLowerHeight = setLowerHeight,
		},
	}, {
		Roact.createElement(Container, {
			anchorPoint = Vector2.new(1, 0),
			size = UDim2.new(0, SIDE_PANEL_WIDTH, 1, -84),
			position = UDim2.new(1, 0, 0, 84),
		}, {
			if isInspectionTab then (Roact.createFragment({
				Roact.createElement(InspectionMetadata),
				Roact.createElement(InspectionUpvalues),
				Roact.createElement(InspectionConstants),
			})) else (Roact.createFragment({
				Roact.createElement(FunctionTree),
				Roact.createElement(Peek),
				Roact.createElement(Traceback),
			})),
		}),
	})
end
local default = withHooksPure(SidePanel)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.SidePanel"))() end)

_module("Traceback", "ModuleScript", "RemoteSpy.components.SidePanel.Traceback", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Traceback").default
return exports
 end, _env("RemoteSpy.components.SidePanel.Traceback"))() end)

_module("Traceback", "ModuleScript", "RemoteSpy.components.SidePanel.Traceback.Traceback", "RemoteSpy.components.SidePanel.Traceback", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local TitleBar = TS.import(script, script.Parent.Parent, "components", "TitleBar").default
local useSidePanelContext = TS.import(script, script.Parent.Parent, "use-side-panel-context").useSidePanelContext
local _function_util = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "function-util")
local describeFunction = _function_util.describeFunction
local stringifyFunctionSignature = _function_util.stringifyFunctionSignature
local selectTracebackCallStack = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "traceback").selectTracebackCallStack
local selectSignalSelected = TS.import(script, script.Parent.Parent.Parent.Parent, "reducers", "remote-log").selectSignalSelected
local useRootSelector = TS.import(script, script.Parent.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local formatEscapes = TS.import(script, script.Parent.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local function getRemoteTypeName(remote)
	if remote:IsA("RemoteEvent") then
		return "RemoteEvent (FireServer)"
	elseif remote:IsA("RemoteFunction") then
		return "RemoteFunction (InvokeServer)"
	elseif remote:IsA("BindableEvent") then
		return "BindableEvent (Fire)"
	elseif remote:IsA("BindableFunction") then
		return "BindableFunction (Invoke)"
	end
	return "Unknown"
end
local function TracebackFrame(_param)
	local fn = _param.fn
	local index = _param.index
	local isRemoteCaller = _param.isRemoteCaller
	local description = describeFunction(fn)
	local signature = stringifyFunctionSignature(fn)
	return Roact.createElement("Frame", {
		AutomaticSize = "Y",
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = if isRemoteCaller then Color3.new(0.2, 0.5, 0.2) else Color3.new(1, 1, 1),
		BackgroundTransparency = if isRemoteCaller then 0.85 else 0.95,
		BorderSizePixel = 0,
		LayoutOrder = index,
	}, {
		Roact.createElement("UIListLayout", {
			FillDirection = "Vertical",
			Padding = UDim.new(0, 2),
			VerticalAlignment = "Top",
		}),
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 8),
			PaddingRight = UDim.new(0, 8),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = if isRemoteCaller then "→ " .. (signature .. " ←") else signature,
			Font = "Gotham",
			TextColor3 = Color3.new(1, 1, 1),
			TextSize = 11,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = formatEscapes(description.source),
			Font = "Gotham",
			TextColor3 = Color3.new(0.7, 0.7, 0.7),
			TextSize = 9,
			TextXAlignment = "Left",
			TextWrapped = true,
			BackgroundTransparency = 1,
		}),
	})
end
local function Traceback()
	local _binding = useSidePanelContext()
	local lowerHidden = _binding.lowerHidden
	local setLowerHidden = _binding.setLowerHidden
	local lowerSize = _binding.lowerSize
	local lowerPosition = _binding.lowerPosition
	local callStack = useRootSelector(selectTracebackCallStack)
	local signal = useRootSelector(selectSignalSelected)
	local isEmpty = #callStack == 0
	local _result
	if not isEmpty and signal then
		local _attributes = {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ScrollBarThickness = 1,
			ScrollBarImageTransparency = 0.6,
			AutomaticCanvasSize = "Y",
		}
		local _children = {}
		local _length = #_children
		local _attributes_1 = {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -8, 0, 0),
			BackgroundColor3 = Color3.new(0.15, 0.35, 0.6),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0,
			LayoutOrder = -2,
		}
		local _children_1 = {
			Roact.createElement("UIListLayout", {
				FillDirection = "Vertical",
				Padding = UDim.new(0, 2),
				VerticalAlignment = "Top",
			}),
			Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6),
			}),
			Roact.createElement("TextLabel", {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
				Text = "Event Type: " .. getRemoteTypeName(signal.remote),
				Font = "GothamBold",
				TextColor3 = Color3.new(0.9, 0.9, 1),
				TextSize = 11,
				TextXAlignment = "Left",
				BackgroundTransparency = 1,
			}),
			Roact.createElement("TextLabel", {
				AutomaticSize = "Y",
				Size = UDim2.new(1, -16, 0, 0),
				Text = "Remote: " .. formatEscapes(signal.name),
				Font = "Gotham",
				TextColor3 = Color3.new(0.8, 0.8, 0.9),
				TextSize = 10,
				TextXAlignment = "Left",
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}
		local _length_1 = #_children_1
		local _child = signal.isActor and (Roact.createElement("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, -16, 0, 0),
			Text = "Called from Actor",
			Font = "Gotham",
			TextColor3 = Color3.new(1, 0.8, 0.3),
			TextSize = 9,
			TextXAlignment = "Left",
			BackgroundTransparency = 1,
		}))
		if _child then
			_children_1[_length_1 + 1] = _child
		end
		_children[_length + 1] = Roact.createElement("Frame", _attributes_1, _children_1)
		_children[_length + 2] = Roact.createElement("UIListLayout", {
			FillDirection = "Vertical",
			VerticalAlignment = "Top",
			SortOrder = "LayoutOrder",
			Padding = UDim.new(0, 2),
		})
		_children[_length + 3] = Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
			PaddingTop = UDim.new(0, 4),
			PaddingBottom = UDim.new(0, 4),
		})
		local _arg0 = function(fn, index)
			return Roact.createElement(TracebackFrame, {
				fn = fn,
				index = index,
				isRemoteCaller = index == #callStack - 1,
			})
		end
		-- ▼ ReadonlyArray.map ▼
		local _newValue = table.create(#callStack)
		for _k, _v in ipairs(callStack) do
			_newValue[_k] = _arg0(_v, _k - 1, callStack)
		end
		-- ▲ ReadonlyArray.map ▲
		for _k, _v in ipairs(_newValue) do
			_children[_length + 3 + _k] = _v
		end
		_result = (Roact.createElement("ScrollingFrame", _attributes, _children))
	else
		_result = (Roact.createElement("Frame", {
			Size = UDim2.new(1, 0, 1, -30),
			Position = UDim2.new(0, 0, 0, 30),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Roact.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, -20, 1, 0),
				Text = "Select a signal and click Traceback to view details",
				Font = "Gotham",
				TextColor3 = Color3.new(0.5, 0.5, 0.5),
				TextSize = 12,
				TextWrapped = true,
				BackgroundTransparency = 1,
			}),
		}))
	end
	local _attributes = {
		size = lowerSize,
		position = lowerPosition,
	}
	local _children = {
		Roact.createElement(TitleBar, {
			caption = "Traceback (" .. (tostring(#callStack) .. ")"),
			hidden = lowerHidden,
			toggleHidden = function()
				return setLowerHidden(not lowerHidden)
			end,
		}),
	}
	local _length = #_children
	_children[_length + 1] = _result
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(Traceback)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.Traceback.Traceback"))() end)

_instance("components", "Folder", "RemoteSpy.components.SidePanel.components", "RemoteSpy.components.SidePanel")

_module("TitleBar", "ModuleScript", "RemoteSpy.components.SidePanel.components.TitleBar", "RemoteSpy.components.SidePanel.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent.Parent, "Button").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local useGroupMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useGroupMotor
local withHooksPure = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).withHooksPure
local CHEVRON_DEFAULT = { Spring.new(1, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local CHEVRON_HOVERED = { Spring.new(0.95, {
	frequency = 6,
}), Spring.new(0, {
	frequency = 6,
}) }
local CHEVRON_PRESSED = { Instant.new(0.97), Instant.new(0.2) }
local function TitleBar(_param)
	local caption = _param.caption
	local hidden = _param.hidden
	local toggleHidden = _param.toggleHidden
	local _binding = useGroupMotor({ 1, 0 })
	local chevronTransparency = _binding[1]
	local setChevronGoal = _binding[2]
	local chevronBackgroundTransparency = chevronTransparency:map(function(t)
		return t[1]
	end)
	local chevronForegroundTransparency = chevronTransparency:map(function(t)
		return t[2]
	end)
	return Roact.createFragment({
		Roact.createElement("TextLabel", {
			Text = caption,
			TextColor3 = Color3.new(1, 1, 1),
			Font = "GothamBold",
			TextSize = 11,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Size = UDim2.new(1, -24, 0, 20),
			Position = UDim2.new(0, 12, 0, 14),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(Button, {
			onClick = function()
				setChevronGoal(CHEVRON_HOVERED)
				toggleHidden()
			end,
			onPress = function()
				return setChevronGoal(CHEVRON_PRESSED)
			end,
			onHover = function()
				return setChevronGoal(CHEVRON_HOVERED)
			end,
			onHoverEnd = function()
				return setChevronGoal(CHEVRON_DEFAULT)
			end,
			transparency = chevronBackgroundTransparency,
			size = UDim2.new(0, 24, 0, 24),
			position = UDim2.new(1, -8, 0, 8),
			anchorPoint = Vector2.new(1, 0),
			cornerRadius = UDim.new(0, 4),
		}, {
			Roact.createElement("ImageLabel", {
				Image = if hidden then "rbxassetid://9888526164" else "rbxassetid://9888526348",
				ImageTransparency = chevronForegroundTransparency,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 4, 0, 4),
				BackgroundTransparency = 1,
			}),
		}),
	})
end
local default = withHooksPure(TitleBar)
return {
	default = default,
}
 end, _env("RemoteSpy.components.SidePanel.components.TitleBar"))() end)

_module("use-side-panel-context", "ModuleScript", "RemoteSpy.components.SidePanel.use-side-panel-context", "RemoteSpy.components.SidePanel", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local useContext = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useContext
local SidePanelContext = Roact.createContext(nil)
local function useSidePanelContext()
	return useContext(SidePanelContext)
end
return {
	useSidePanelContext = useSidePanelContext,
	SidePanelContext = SidePanelContext,
}
 end, _env("RemoteSpy.components.SidePanel.use-side-panel-context"))() end)

_module("Tabs", "ModuleScript", "RemoteSpy.components.Tabs", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "Tabs").default
return exports
 end, _env("RemoteSpy.components.Tabs"))() end)

_module("Tab", "ModuleScript", "RemoteSpy.components.Tabs.Tab", "RemoteSpy.components.Tabs", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent, "Button").default
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local MAX_TAB_CAPTION_WIDTH = _tab_group.MAX_TAB_CAPTION_WIDTH
local deleteTab = _tab_group.deleteTab
local getTabCaptionWidth = _tab_group.getTabCaptionWidth
local getTabWidth = _tab_group.getTabWidth
local makeSelectTabOffset = _tab_group.makeSelectTabOffset
local selectTabIsActive = _tab_group.selectTabIsActive
local setActiveTab = _tab_group.setActiveTab
local formatEscapes = TS.import(script, script.Parent.Parent.Parent, "utils", "format-escapes").formatEscapes
local tabIcons = TS.import(script, script.Parent, "constants").tabIcons
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local useDraggableTab = TS.import(script, script.Parent, "use-draggable-tab").useDraggableTab
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local _roact_hooked_plus = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out)
local useSingleMotor = _roact_hooked_plus.useSingleMotor
local useSpring = _roact_hooked_plus.useSpring
local FOREGROUND_ACTIVE = Instant.new(0)
local FOREGROUND_DEFAULT = Spring.new(0.4, {
	frequency = 6,
})
local FOREGROUND_HOVERED = Spring.new(0.2, {
	frequency = 6,
})
local CLOSE_DEFAULT = Spring.new(1, {
	frequency = 6,
})
local CLOSE_HOVERED = Spring.new(0.9, {
	frequency = 6,
})
local CLOSE_PRESSED = Instant.new(0.94)
local function Tab(_param)
	local tab = _param.tab
	local canvasPosition = _param.canvasPosition
	local dispatch = useRootDispatch()
	local width = useMemo(function()
		return getTabWidth(tab)
	end, { tab })
	local captionWidth = useMemo(function()
		return getTabCaptionWidth(tab)
	end, { tab })
	local selectTabOffset = useMemo(makeSelectTabOffset, {})
	local active = useRootSelector(function(state)
		return selectTabIsActive(state, tab.id)
	end)
	local offset = useRootSelector(function(state)
		return selectTabOffset(state, tab.id)
	end)
	local _binding = useDraggableTab(tab.id, width, canvasPosition)
	local dragPosition = _binding[1]
	local setDragState = _binding[2]
	local _binding_1 = useSingleMotor(if active then 0 else 0.4)
	local foreground = _binding_1[1]
	local setForeground = _binding_1[2]
	local _binding_2 = useSingleMotor(1)
	local closeBackground = _binding_2[1]
	local setCloseBackground = _binding_2[2]
	local offsetAnim = useSpring(offset, {
		frequency = 30,
		dampingRatio = 3,
	})
	useEffect(function()
		setForeground(if active then FOREGROUND_ACTIVE else FOREGROUND_DEFAULT)
	end, { active })
	local _attributes = {
		onPress = function(_, x)
			if not active then
				dispatch(setActiveTab(tab.id))
			end
			setDragState({
				dragging = false,
				mousePosition = x,
				tabPosition = offset,
			})
		end,
		onClick = function()
			return not active and setForeground(FOREGROUND_HOVERED)
		end,
		onHover = function()
			return not active and setForeground(FOREGROUND_HOVERED)
		end,
		onHoverEnd = function()
			return not active and setForeground(FOREGROUND_DEFAULT)
		end,
		size = UDim2.new(0, width, 1, 0),
		position = Roact.joinBindings({
			dragPosition = dragPosition,
			offsetAnim = offsetAnim,
		}):map(function(binding)
			local xOffset = if binding.dragPosition ~= nil then math.max(binding.dragPosition, 0) else math.round(binding.offsetAnim)
			return UDim2.new(0, xOffset, 0, 0)
		end),
		zIndex = dragPosition:map(function(drag)
			return if drag ~= nil then 1 else 0
		end),
	}
	local _children = {
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9896472554",
			ImageTransparency = if active then 0.96 else 1,
			ImageColor3 = Color3.fromHex("#FFFFFF"),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScaleType = "Slice",
			SliceCenter = Rect.new(8, 8, 8, 8),
		}),
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9896472759",
			ImageTransparency = if active then 0.96 else 1,
			ImageColor3 = Color3.fromHex("#FFFFFF"),
			Size = UDim2.new(0, 5, 0, 5),
			Position = UDim2.new(0, -5, 1, -5),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9896472676",
			ImageTransparency = if active then 0.96 else 1,
			ImageColor3 = Color3.fromHex("#FFFFFF"),
			Size = UDim2.new(0, 5, 0, 5),
			Position = UDim2.new(1, 0, 1, -5),
			BackgroundTransparency = 1,
		}),
	}
	local _length = #_children
	local _children_1 = {
		Roact.createElement("ImageLabel", {
			Image = tabIcons[tab.type],
			ImageTransparency = foreground,
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
		}),
	}
	local _length_1 = #_children_1
	local _attributes_1 = {
		Text = formatEscapes(tab.caption),
		Font = "Gotham",
		TextColor3 = Color3.new(1, 1, 1),
		TextTransparency = foreground,
		TextSize = 11,
		TextXAlignment = "Left",
		TextYAlignment = "Center",
		Size = UDim2.new(0, captionWidth, 1, 0),
		BackgroundTransparency = 1,
	}
	local _children_2 = {}
	local _length_2 = #_children_2
	local _child = captionWidth == MAX_TAB_CAPTION_WIDTH and (Roact.createElement("UIGradient", {
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.9, 0), NumberSequenceKeypoint.new(1, 1) }),
	}))
	if _child then
		_children_2[_length_2 + 1] = _child
	end
	_children_1[_length_1 + 1] = Roact.createElement("TextLabel", _attributes_1, _children_2)
	local _child_1 = tab.canClose and (Roact.createElement(Button, {
		onClick = function()
			return dispatch(deleteTab(tab.id))
		end,
		onPress = function()
			return setCloseBackground(CLOSE_PRESSED)
		end,
		onHover = function()
			return setCloseBackground(CLOSE_HOVERED)
		end,
		onHoverEnd = function()
			return setCloseBackground(CLOSE_DEFAULT)
		end,
		transparency = closeBackground,
		size = UDim2.new(0, 17, 0, 17),
		cornerRadius = UDim.new(0, 4),
	}, {
		Roact.createElement("ImageLabel", {
			Image = "rbxassetid://9896553856",
			ImageTransparency = foreground,
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
		}),
	}))
	if _child_1 then
		_children_1[_length_1 + 2] = _child_1
	end
	_length_1 = #_children_1
	_children_1[_length_1 + 1] = Roact.createElement("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		PaddingTop = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	})
	_children_1[_length_1 + 2] = Roact.createElement("UIListLayout", {
		Padding = UDim.new(0, 6),
		FillDirection = "Horizontal",
		HorizontalAlignment = "Left",
		VerticalAlignment = "Center",
	})
	_children[_length + 1] = Roact.createElement(Container, {}, _children_1)
	return Roact.createElement(Button, _attributes, _children)
end
local default = withHooksPure(Tab)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Tabs.Tab"))() end)

_module("Tabs", "ModuleScript", "RemoteSpy.components.Tabs.Tabs", "RemoteSpy.components.Tabs", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Tab = TS.import(script, script.Parent, "Tab").default
local SIDE_PANEL_WIDTH = TS.import(script, script.Parent.Parent.Parent, "constants").SIDE_PANEL_WIDTH
local arrayToMap = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).arrayToMap
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local getTabWidth = _tab_group.getTabWidth
local selectTabs = _tab_group.selectTabs
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useMemo = _roact_hooked.useMemo
local withHooksPure = _roact_hooked.withHooksPure
local useRootSelector = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootSelector
local function Tabs()
	local tabs = useRootSelector(selectTabs)
	local canvasPosition, setCanvasPosition = useBinding(Vector2.new())
	local totalWidth = useMemo(function()
		local _arg0 = function(acc, tab)
			return acc + getTabWidth(tab)
		end
		-- ▼ ReadonlyArray.reduce ▼
		local _result = 0
		local _callback = _arg0
		for _i = 1, #tabs do
			_result = _callback(_result, tabs[_i], _i - 1, tabs)
		end
		-- ▲ ReadonlyArray.reduce ▲
		return _result
	end, tabs)
	local _attributes = {
		[Roact.Change.CanvasPosition] = function(rbx)
			return setCanvasPosition(rbx.CanvasPosition)
		end,
		CanvasSize = UDim2.new(0, totalWidth + 100, 0, 0),
		ScrollingDirection = "X",
		HorizontalScrollBarInset = "None",
		ScrollBarThickness = 0,
		Size = UDim2.new(1, -SIDE_PANEL_WIDTH - 5, 0, 35),
		Position = UDim2.new(0, 5, 0, 89),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}
	local _children = {
		Roact.createElement("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
		}),
	}
	local _length = #_children
	for _k, _v in pairs(arrayToMap(tabs, function(tab)
		return { tab.id, Roact.createElement(Tab, {
			tab = tab,
			canvasPosition = canvasPosition,
		}) }
	end)) do
		_children[_k] = _v
	end
	return Roact.createElement("ScrollingFrame", _attributes, _children)
end
local default = withHooksPure(Tabs)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Tabs.Tabs"))() end)

_module("constants", "ModuleScript", "RemoteSpy.components.Tabs.constants", "RemoteSpy.components.Tabs", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local TabType = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group").TabType
local tabIcons = {
	[TabType.Home] = "rbxassetid://9896611868",
	[TabType.Event] = "rbxassetid://111467142036224",
	[TabType.Function] = "rbxassetid://104664672211257",
	[TabType.BindableEvent] = "rbxassetid://76270109328460",
	[TabType.BindableFunction] = "rbxassetid://87985191222737",
	[TabType.Script] = "rbxassetid://9896665034",
	[TabType.Settings] = "rbxassetid://102279067978128",
	[TabType.Inspection] = "rbxassetid://86206500190741",
}
return {
	tabIcons = tabIcons,
}
 end, _env("RemoteSpy.components.Tabs.constants"))() end)

_module("use-draggable-tab", "ModuleScript", "RemoteSpy.components.Tabs.use-draggable-tab", "RemoteSpy.components.Tabs", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local _services = TS.import(script, TS.getModule(script, "@rbxts", "services"))
local RunService = _services.RunService
local UserInputService = _services.UserInputService
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local getTabWidth = _tab_group.getTabWidth
local moveTab = _tab_group.moveTab
local selectTabs = _tab_group.selectTabs
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local _use_root_store = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootStore = _use_root_store.useRootStore
local DRAG_THRESHOLD = 5
local function useDraggableTab(id, width, canvasPosition)
	local store = useRootStore()
	local dispatch = useRootDispatch()
	local dragState, setDragState = useState()
	local dragPosition, setDragPosition = useBinding(nil)
	useEffect(function()
		if not dragState then
			return nil
		end
		local tabs
		local estimateNewIndex = function(dragOffset)
			local totalWidth = 0
			for _, t in ipairs(tabs) do
				totalWidth += getTabWidth(t)
				if totalWidth > dragOffset + width / 2 then
					return (table.find(tabs, t) or 0) - 1
				end
			end
			return #tabs - 1
		end
		tabs = selectTabs(store:getState())
		local startCanvasPosition = canvasPosition:getValue()
		local lastIndex = estimateNewIndex(0)
		local isDragging = false
		local mouseMoved = RunService.Heartbeat:Connect(function()
			local current = UserInputService:GetMouseLocation()
			local position = current.X - dragState.mousePosition + dragState.tabPosition
			local canvasDelta = canvasPosition:getValue().X - startCanvasPosition.X
			local dragDistance = math.abs(position)
			if not isDragging and dragDistance < DRAG_THRESHOLD then
				return nil
			end
			isDragging = true
			setDragPosition(position + canvasDelta)
			local newIndex = estimateNewIndex(position + canvasDelta)
			if newIndex ~= lastIndex then
				lastIndex = newIndex
				dispatch(moveTab(id, newIndex))
			end
		end)
		local mouseUp = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				setDragState(nil)
				setDragPosition(nil)
			end
		end)
		return function()
			mouseMoved:Disconnect()
			mouseUp:Disconnect()
		end
	end, { dragState })
	return { dragPosition, setDragState }
end
return {
	useDraggableTab = useDraggableTab,
}
 end, _env("RemoteSpy.components.Tabs.use-draggable-tab"))() end)

_module("Window", "ModuleScript", "RemoteSpy.components.Window", "RemoteSpy.components", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local Window = TS.import(script, script, "Window").default
local WindowBackground = TS.import(script, script, "WindowBackground").default
local WindowDropShadow = TS.import(script, script, "WindowDropShadow").default
local WindowResize = TS.import(script, script, "WindowResize").default
local WindowTitleBar = TS.import(script, script, "WindowTitleBar").default
local default = {
	Root = Window,
	TitleBar = WindowTitleBar,
	Background = WindowBackground,
	DropShadow = WindowDropShadow,
	Resize = WindowResize,
}
return {
	default = default,
}
 end, _env("RemoteSpy.components.Window"))() end)

_module("Window", "ModuleScript", "RemoteSpy.components.Window.Window", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local WindowContext = TS.import(script, script.Parent, "use-window-context").WindowContext
local lerp = TS.import(script, script.Parent.Parent.Parent, "utils", "number-util").lerp
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useState = _roact_hooked.useState
local withHooksPure = _roact_hooked.withHooksPure
local _roact_hooked_plus = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out)
local useSpring = _roact_hooked_plus.useSpring
local useViewportSize = _roact_hooked_plus.useViewportSize
local apply = function(v2, udim)
	return Vector2.new(v2.X * udim.X.Scale + udim.X.Offset, v2.Y * udim.Y.Scale + udim.Y.Offset)
end
local function Window(_param)
	local initialSize = _param.initialSize
	local initialPosition = _param.initialPosition
	local children = _param[Roact.Children]
	local viewportSize = useViewportSize()
	local size, setSize = useBinding(apply(viewportSize:getValue(), initialSize))
	local position, setPosition = useBinding(apply(viewportSize:getValue(), initialPosition))
	local maximized, setMaximized = useState(false)
	local maximizeAnim = useSpring(if maximized then 1 else 0, {
		frequency = 6,
	})
	local _attributes = {
		value = {
			size = size,
			setSize = setSize,
			position = position,
			setPosition = setPosition,
			maximized = maximized,
			setMaximized = setMaximized,
		},
	}
	local _children = {}
	local _length = #_children
	local _attributes_1 = {
		BackgroundTransparency = 1,
		Size = Roact.joinBindings({
			size = size,
			viewportSize = viewportSize,
			maximizeAnim = maximizeAnim,
		}):map(function(_param_1)
			local size = _param_1.size
			local viewportSize = _param_1.viewportSize
			local maximizeAnim = _param_1.maximizeAnim
			return UDim2.new(0, math.round(lerp(size.X, viewportSize.X, maximizeAnim)), 0, math.round(lerp(size.Y, viewportSize.Y, maximizeAnim)))
		end),
		Position = Roact.joinBindings({
			position = position,
			maximizeAnim = maximizeAnim,
		}):map(function(_param_1)
			local position = _param_1.position
			local maximizeAnim = _param_1.maximizeAnim
			return UDim2.new(0, math.round(position.X * (1 - maximizeAnim)), 0, math.round(position.Y * (1 - maximizeAnim)))
		end),
	}
	local _children_1 = {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	}
	local _length_1 = #_children_1
	local _children_2 = {}
	local _length_2 = #_children_2
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children_2[_length_2 + _k] = _v
			else
				_children_2[_k] = _v
			end
		end
	end
	_children_1[_length_1 + 1] = Roact.createFragment(_children_2)
	_children[_length + 1] = Roact.createElement("Frame", _attributes_1, _children_1)
	return Roact.createElement(WindowContext.Provider, _attributes, _children)
end
local default = withHooksPure(Window)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Window.Window"))() end)

_module("Window.story", "ModuleScript", "RemoteSpy.components.Window.Window.story", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local Root = TS.import(script, script.Parent.Parent, "Root").default
local Window = TS.import(script, script.Parent).default
return function(target)
	local handle = Roact.mount(Roact.createElement(Root, {}, {
		Roact.createElement(Window.Root, {
			initialSize = UDim2.new(0, 1080, 0, 700),
			initialPosition = UDim2.new(0.5, -1080 / 2, 0.5, -700 / 2),
		}, {
			Roact.createElement(Window.DropShadow),
			Roact.createElement(Window.Background),
			Roact.createElement(Window.TitleBar, {
				caption = '<font color="#E5E5E5">New window</font>',
				icon = "rbxassetid://9886981409",
			}),
			Roact.createElement(Window.Resize, {
				minSize = Vector2.new(350, 250),
			}),
		}),
	}), target, "App")
	return function()
		Roact.unmount(handle)
	end
end
 end, _env("RemoteSpy.components.Window.Window.story"))() end)

_module("WindowBackground", "ModuleScript", "RemoteSpy.components.Window.WindowBackground", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function WindowBackground(_param)
	local background = _param.background
	if background == nil then
		background = Color3.fromHex("#202020")
	end
	local transparency = _param.transparency
	if transparency == nil then
		transparency = 0.2
	end
	local children = _param[Roact.Children]
	local _attributes = {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = background,
		BackgroundTransparency = transparency,
		BorderSizePixel = 0,
	}
	local _children = {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
	}
	local _length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	_length = #_children
	_children[_length + 1] = Roact.createElement(Container, {}, {
		Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 8),
		}),
		Roact.createElement("UIStroke", {
			Color = Color3.fromHex("#606060"),
			Transparency = 0.5,
			Thickness = 1,
		}),
	})
	return Roact.createElement("Frame", _attributes, _children)
end
return {
	default = WindowBackground,
}
 end, _env("RemoteSpy.components.Window.WindowBackground"))() end)

_module("WindowDropShadow", "ModuleScript", "RemoteSpy.components.Window.WindowDropShadow", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local WindowAssets = TS.import(script, script.Parent, "assets").WindowAssets
local IMAGE_SIZE = Vector2.new(226, 226)
local function WindowDropShadow()
	return Roact.createElement("ImageLabel", {
		Image = WindowAssets.DropShadow,
		ScaleType = "Slice",
		SliceCenter = Rect.new(IMAGE_SIZE / 2, IMAGE_SIZE / 2),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 110, 1, 110),
		Position = UDim2.new(0.5, 0, 0.5, 24),
		BackgroundTransparency = 1,
	})
end
return {
	default = WindowDropShadow,
}
 end, _env("RemoteSpy.components.Window.WindowDropShadow"))() end)

_module("WindowResize", "ModuleScript", "RemoteSpy.components.Window.WindowResize", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent, "Button").default
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local withHooksPure = _roact_hooked.withHooksPure
local useWindowContext = TS.import(script, script.Parent, "use-window-context").useWindowContext
local THICKNESS = 14
local Handle = function(props)
	return Roact.createElement(Button, {
		onPress = function(_, x, y)
			return props.dragStart(Vector2.new(x, y))
		end,
		anchorPoint = Vector2.new(0.5, 0.5),
		size = props.size,
		position = props.position,
		active = false,
	})
end
local function WindowResize(_param)
	local minSize = _param.minSize
	if minSize == nil then
		minSize = Vector2.new(250, 250)
	end
	local maxSize = _param.maxSize
	if maxSize == nil then
		maxSize = Vector2.new(2048, 2048)
	end
	local _binding = useWindowContext()
	local size = _binding.size
	local setSize = _binding.setSize
	local position = _binding.position
	local setPosition = _binding.setPosition
	local maximized = _binding.maximized
	local dragStart, setDragStart = useState()
	useEffect(function()
		if not dragStart or maximized then
			return nil
		end
		local startPosition = position:getValue()
		local startSize = size:getValue()
		local inputBegan = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local current = UserInputService:GetMouseLocation()
				local _mouse = dragStart.mouse
				local delta = current - _mouse
				local _arg0 = dragStart.direction * delta
				local targetSize = startSize + _arg0
				local targetSizeClamped = Vector2.new(math.clamp(targetSize.X, minSize.X, maxSize.X), math.clamp(targetSize.Y, minSize.Y, maxSize.Y))
				setSize(targetSizeClamped)
				if dragStart.direction.X < 0 and dragStart.direction.Y < 0 then
					local _arg0_1 = startSize - targetSizeClamped
					setPosition(startPosition + _arg0_1)
				elseif dragStart.direction.X < 0 then
					setPosition(Vector2.new(startPosition.X + (startSize.X - targetSizeClamped.X), startPosition.Y))
				elseif dragStart.direction.Y < 0 then
					setPosition(Vector2.new(startPosition.X, startPosition.Y + (startSize.Y - targetSizeClamped.Y)))
				end
			end
		end)
		local inputEnded = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				setDragStart(nil)
			end
		end)
		return function()
			inputBegan:Disconnect()
			inputEnded:Disconnect()
		end
	end, { dragStart })
	return Roact.createElement(Container, {}, {
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(0, -1),
				})
			end,
			size = UDim2.new(1, -THICKNESS, 0, THICKNESS),
			position = UDim2.new(0.5, 0, 0, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(-1, 0),
				})
			end,
			size = UDim2.new(0, THICKNESS, 1, -THICKNESS),
			position = UDim2.new(0, 0, 0.5, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(1, 0),
				})
			end,
			size = UDim2.new(0, THICKNESS, 1, -THICKNESS),
			position = UDim2.new(1, 0, 0.5, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(0, 1),
				})
			end,
			size = UDim2.new(1, -THICKNESS, 0, THICKNESS),
			position = UDim2.new(0.5, 0, 1, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(-1, -1),
				})
			end,
			size = UDim2.new(0, THICKNESS, 0, THICKNESS),
			position = UDim2.new(0, 0, 0, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(1, -1),
				})
			end,
			size = UDim2.new(0, THICKNESS, 0, THICKNESS),
			position = UDim2.new(1, 0, 0, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(-1, 1),
				})
			end,
			size = UDim2.new(0, THICKNESS, 0, THICKNESS),
			position = UDim2.new(0, 0, 1, 0),
		}),
		Roact.createElement(Handle, {
			dragStart = function(mouse)
				return setDragStart({
					mouse = mouse,
					direction = Vector2.new(1, 1),
				})
			end,
			size = UDim2.new(0, THICKNESS, 0, THICKNESS),
			position = UDim2.new(1, 0, 1, 0),
		}),
	})
end
local default = withHooksPure(WindowResize)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Window.WindowResize"))() end)

_module("WindowTitleBar", "ModuleScript", "RemoteSpy.components.Window.WindowTitleBar", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Button = TS.import(script, script.Parent.Parent, "Button").default
local Container = TS.import(script, script.Parent.Parent, "Container").default
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local Instant = _flipper.Instant
local Spring = _flipper.Spring
local TOPBAR_OFFSET = TS.import(script, script.Parent.Parent.Parent, "constants").TOPBAR_OFFSET
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local WindowAssets = TS.import(script, script.Parent, "assets").WindowAssets
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local withHooksPure = _roact_hooked.withHooksPure
local useSingleMotor = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked-plus").out).useSingleMotor
local useWindowContext = TS.import(script, script.Parent, "use-window-context").useWindowContext
local _tab_group = TS.import(script, script.Parent.Parent.Parent, "reducers", "tab-group")
local TabType = _tab_group.TabType
local pushTab = _tab_group.pushTab
local setActiveTab = _tab_group.setActiveTab
local createTabColumn = _tab_group.createTabColumn
local useRootDispatch = TS.import(script, script.Parent.Parent.Parent, "hooks", "use-root-store").useRootDispatch
local function WindowTitleBar(_param)
	local caption = _param.caption
	if caption == nil then
		caption = "New window"
	end
	local captionColor = _param.captionColor
	if captionColor == nil then
		captionColor = Color3.new(1, 1, 1)
	end
	local captionTransparency = _param.captionTransparency
	if captionTransparency == nil then
		captionTransparency = 0
	end
	local icon = _param.icon
	if icon == nil then
		icon = WindowAssets.DefaultWindowIcon
	end
	local height = _param.height
	if height == nil then
		height = 42
	end
	local onClose = _param.onClose
	local children = _param[Roact.Children]
	local _binding = useWindowContext()
	local size = _binding.size
	local maximized = _binding.maximized
	local setMaximized = _binding.setMaximized
	local setPosition = _binding.setPosition
	local dispatch = useRootDispatch()
	local _binding_1 = useSingleMotor(1)
	local closeTransparency = _binding_1[1]
	local setCloseTransparency = _binding_1[2]
	local _binding_2 = useSingleMotor(1)
	local minimizeTransparency = _binding_2[1]
	local setMinimizeTransparency = _binding_2[2]
	local _binding_3 = useSingleMotor(1)
	local maximizeTransparency = _binding_3[1]
	local setMaximizeTransparency = _binding_3[2]
	local _binding_4 = useSingleMotor(1)
	local settingsTransparency = _binding_4[1]
	local setSettingsTransparency = _binding_4[2]
	local startPosition, setStartPosition = useBinding(Vector2.new())
	local dragStart, setDragStart = useState()
	useEffect(function()
		if not dragStart then
			return nil
		end
		local startPos = startPosition:getValue()
		local shouldMinimize = maximized
		local mouseMoved = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local current = UserInputService:GetMouseLocation()
				local delta = current - dragStart
				setPosition(startPos + delta)
				if shouldMinimize then
					shouldMinimize = false
					setMaximized(false)
				end
			end
		end)
		local mouseUp = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				setDragStart(nil)
			end
		end)
		return function()
			mouseMoved:Disconnect()
			mouseUp:Disconnect()
		end
	end, { dragStart })
	local _attributes = {
		size = UDim2.new(1, 0, 0, height),
	}
	local _children = {
		Roact.createElement("ImageLabel", {
			Image = icon,
			Size = UDim2.new(0, 21, 0, 21),
			Position = UDim2.new(0, 16, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
		}),
		Roact.createElement("TextLabel", {
			RichText = true,
			Text = caption,
			TextColor3 = captionColor,
			TextTransparency = captionTransparency,
			Font = "Gotham",
			TextSize = 11,
			TextXAlignment = "Left",
			TextYAlignment = "Center",
			Size = UDim2.new(1, -44, 1, 0),
			Position = UDim2.new(0, 44, 0, 0),
			BackgroundTransparency = 1,
		}),
		Roact.createElement(Button, {
			onClick = function()
				local settingsTabId = "settings"
				local tab = createTabColumn(settingsTabId, "Settings", TabType.Settings, true)
				dispatch(pushTab(tab))
				dispatch(setActiveTab(settingsTabId))
				setSettingsTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
			end,
			onPress = function()
				return setSettingsTransparency(Instant.new(0.96))
			end,
			onHover = function()
				return setSettingsTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
			end,
			onHoverEnd = function()
				return setSettingsTransparency(Spring.new(1, {
					frequency = 6,
				}))
			end,
			background = Color3.fromHex("#FFFFFF"),
			transparency = settingsTransparency,
			size = UDim2.new(0, 28, 0, 28),
			position = UDim2.new(1, -46 * 3 - 5, 0.5, 0),
			anchorPoint = Vector2.new(1, 0.5),
			zIndex = 2,
		}, {
			Roact.createElement("ImageLabel", {
				Image = "rbxassetid://102279067978128",
				ImageColor3 = Color3.fromHex("#E0E0E0"),
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),
		}),
		Roact.createElement(Button, {
			onPress = function(rbx, x, y)
				local mouse = Vector2.new(x, y)
				if maximized then
					local currentSize = Vector2.new(size:getValue().X - 46 * 3, height)
					setStartPosition(Vector2.new())
					local _absoluteSize = rbx.AbsoluteSize
					local _arg0 = currentSize / _absoluteSize
					setDragStart(mouse * _arg0)
				else
					setStartPosition(rbx.AbsolutePosition + TOPBAR_OFFSET)
					setDragStart(mouse)
				end
			end,
			active = false,
			size = UDim2.new(1, -46 * 3 - 35, 1, 0),
		}),
		Roact.createElement(Button, {
			onClick = function()
				setCloseTransparency(Spring.new(0, {
					frequency = 6,
				}))
				local _result = onClose
				if _result ~= nil then
					_result()
				end
			end,
			onPress = function()
				return setCloseTransparency(Instant.new(0.25))
			end,
			onHover = function()
				return setCloseTransparency(Spring.new(0, {
					frequency = 6,
				}))
			end,
			onHoverEnd = function()
				return setCloseTransparency(Spring.new(1, {
					frequency = 6,
				}))
			end,
			size = UDim2.new(0, 46, 1, 0),
			position = UDim2.new(1, 0, 0, 0),
			anchorPoint = Vector2.new(1, 0),
		}, {
			Roact.createElement("ImageLabel", {
				Image = WindowAssets.CloseButton,
				ImageTransparency = closeTransparency,
				ImageColor3 = Color3.fromHex("#C83D3D"),
				ScaleType = "Slice",
				SliceCenter = Rect.new(8, 8, 8, 8),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
			}),
			Roact.createElement("ImageLabel", {
				Image = WindowAssets.Close,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),
		}),
		Roact.createElement(Button, {
			onClick = function()
				setMaximizeTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
				setMaximized(not maximized)
			end,
			onPress = function()
				return setMaximizeTransparency(Instant.new(0.96))
			end,
			onHover = function()
				return setMaximizeTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
			end,
			onHoverEnd = function()
				return setMaximizeTransparency(Spring.new(1, {
					frequency = 6,
				}))
			end,
			background = Color3.fromHex("#FFFFFF"),
			transparency = maximizeTransparency,
			size = UDim2.new(0, 46, 1, 0),
			position = UDim2.new(1, -46, 0, 0),
			anchorPoint = Vector2.new(1, 0),
		}, {
			Roact.createElement("ImageLabel", {
				Image = if maximized then WindowAssets.RestoreDown else WindowAssets.Maximize,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),
		}),
		Roact.createElement(Button, {
			onClick = function()
				local _viewportSize = game:GetService("Workspace").CurrentCamera
				if _viewportSize ~= nil then
					_viewportSize = _viewportSize.ViewportSize
				end
				local viewportSize = _viewportSize
				if viewportSize then
					local _vector2 = Vector2.new(42, height)
					setPosition(viewportSize - _vector2)
					if maximized then
						setMaximized(false)
					end
				end
				setMinimizeTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
			end,
			onPress = function()
				return setMinimizeTransparency(Instant.new(0.96))
			end,
			onHover = function()
				return setMinimizeTransparency(Spring.new(0.94, {
					frequency = 6,
				}))
			end,
			onHoverEnd = function()
				return setMinimizeTransparency(Spring.new(1, {
					frequency = 6,
				}))
			end,
			background = Color3.fromHex("#FFFFFF"),
			transparency = minimizeTransparency,
			size = UDim2.new(0, 46, 1, 0),
			position = UDim2.new(1, -46 * 2, 0, 0),
			anchorPoint = Vector2.new(1, 0),
		}, {
			Roact.createElement("ImageLabel", {
				Image = WindowAssets.Minimize,
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
			}),
		}),
	}
	local _length = #_children
	if children then
		for _k, _v in pairs(children) do
			if type(_k) == "number" then
				_children[_length + _k] = _v
			else
				_children[_k] = _v
			end
		end
	end
	return Roact.createElement(Container, _attributes, _children)
end
local default = withHooksPure(WindowTitleBar)
return {
	default = default,
}
 end, _env("RemoteSpy.components.Window.WindowTitleBar"))() end)

_module("assets", "ModuleScript", "RemoteSpy.components.Window.assets", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local WindowAssets
do
	local _inverse = {}
	WindowAssets = setmetatable({}, {
		__index = _inverse,
	})
	WindowAssets.Close = "rbxassetid://9886659671"
	_inverse["rbxassetid://9886659671"] = "Close"
	WindowAssets.CloseButton = "rbxassetid://9887215356"
	_inverse["rbxassetid://9887215356"] = "CloseButton"
	WindowAssets.Maximize = "rbxassetid://9886659406"
	_inverse["rbxassetid://9886659406"] = "Maximize"
	WindowAssets.RestoreDown = "rbxassetid://9886659001"
	_inverse["rbxassetid://9886659001"] = "RestoreDown"
	WindowAssets.Minimize = "rbxassetid://9886659276"
	_inverse["rbxassetid://9886659276"] = "Minimize"
	WindowAssets.DefaultWindowIcon = "rbxassetid://9886659555"
	_inverse["rbxassetid://9886659555"] = "DefaultWindowIcon"
	WindowAssets.DropShadow = "rbxassetid://9886919127"
	_inverse["rbxassetid://9886919127"] = "DropShadow"
end
return {
	WindowAssets = WindowAssets,
}
 end, _env("RemoteSpy.components.Window.assets"))() end)

_module("use-window-context", "ModuleScript", "RemoteSpy.components.Window.use-window-context", "RemoteSpy.components.Window", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local useContext = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useContext
local WindowContext = Roact.createContext(nil)
local function useWindowContext()
	return useContext(WindowContext)
end
return {
	useWindowContext = useWindowContext,
	WindowContext = WindowContext,
}
 end, _env("RemoteSpy.components.Window.use-window-context"))() end)

_module("constants", "ModuleScript", "RemoteSpy.constants", "RemoteSpy", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local DISPLAY_ORDER = 6
local SIDE_PANEL_WIDTH = 280
local TOPBAR_OFFSET = (game:GetService("GuiService"):GetGuiInset())
local IS_LOADED = "__REMOTESPY_IS_LOADED__"
local IS_ELEVATED = loadstring ~= nil
local HAS_FILE_ACCESS = readfile ~= nil
local IS_ACRYLIC_ENABLED = true
return {
	DISPLAY_ORDER = DISPLAY_ORDER,
	SIDE_PANEL_WIDTH = SIDE_PANEL_WIDTH,
	TOPBAR_OFFSET = TOPBAR_OFFSET,
	IS_LOADED = IS_LOADED,
	IS_ELEVATED = IS_ELEVATED,
	HAS_FILE_ACCESS = HAS_FILE_ACCESS,
	IS_ACRYLIC_ENABLED = IS_ACRYLIC_ENABLED,
}
 end, _env("RemoteSpy.constants"))() end)

_instance("hooks", "Folder", "RemoteSpy.hooks", "RemoteSpy")

_module("use-action-effect", "ModuleScript", "RemoteSpy.hooks.use-action-effect", "RemoteSpy.hooks", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _action_bar = TS.import(script, script.Parent.Parent, "reducers", "action-bar")
local deactivateAction = _action_bar.deactivateAction
local selectActionIsActive = _action_bar.selectActionIsActive
local useEffect = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useEffect
local _use_root_store = TS.import(script, script.Parent, "use-root-store")
local useRootDispatch = _use_root_store.useRootDispatch
local useRootSelector = _use_root_store.useRootSelector
local function useActionEffect(action, effect)
	local dispatch = useRootDispatch()
	local activated = useRootSelector(function(state)
		return selectActionIsActive(state, action)
	end)
	useEffect(function()
		if activated then
			task.spawn(effect)
			dispatch(deactivateAction(action))
		end
	end, { activated })
end
return {
	useActionEffect = useActionEffect,
}
 end, _env("RemoteSpy.hooks.use-action-effect"))() end)

_module("use-root-store", "ModuleScript", "RemoteSpy.hooks.use-root-store", "RemoteSpy.hooks", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _roact_rodux_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-rodux-hooked").src)
local useDispatch = _roact_rodux_hooked.useDispatch
local useSelector = _roact_rodux_hooked.useSelector
local useStore = _roact_rodux_hooked.useStore
local useRootSelector = useSelector
local useRootDispatch = useDispatch
local useRootStore = useStore
return {
	useRootSelector = useRootSelector,
	useRootDispatch = useRootDispatch,
	useRootStore = useRootStore,
}
 end, _env("RemoteSpy.hooks.use-root-store"))() end)

_module("receiver", "LocalScript", "RemoteSpy.receiver", "RemoteSpy", function () return setfenv(function() local TS = require(script.Parent.include.RuntimeLib)
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
end) end, _env("RemoteSpy.receiver"))() end)

_module("reducers", "ModuleScript", "RemoteSpy.reducers", "RemoteSpy", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local actionBarReducer = TS.import(script, script, "action-bar").default
local remoteLogReducer = TS.import(script, script, "remote-log").default
local scriptReducer = TS.import(script, script, "script").scriptReducer
local tabGroupReducer = TS.import(script, script, "tab-group").default
local tracebackReducer = TS.import(script, script, "traceback").default
local uiReducer = TS.import(script, script, "ui").default
local default = Rodux.combineReducers({
	actionBar = actionBarReducer,
	remoteLog = remoteLogReducer,
	script = scriptReducer,
	tabGroup = tabGroupReducer,
	traceback = tracebackReducer,
	ui = uiReducer,
})
return {
	default = default,
}
 end, _env("RemoteSpy.reducers"))() end)

_module("action-bar", "ModuleScript", "RemoteSpy.reducers.action-bar", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
exports.default = TS.import(script, script, "reducer").default
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
return exports
 end, _env("RemoteSpy.reducers.action-bar"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.action-bar.actions", "RemoteSpy.reducers.action-bar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function setActionEnabled(id, enabled)
	return {
		type = "SET_ACTION_ENABLED",
		id = id,
		enabled = enabled,
	}
end
local function activateAction(id)
	return {
		type = "ACTIVATE_ACTION",
		id = id,
	}
end
local function deactivateAction(id)
	return {
		type = "DEACTIVATE_ACTION",
		id = id,
	}
end
local function setActionCaption(id, caption)
	return {
		type = "SET_ACTION_CAPTION",
		id = id,
		caption = caption,
	}
end
return {
	setActionEnabled = setActionEnabled,
	activateAction = activateAction,
	deactivateAction = deactivateAction,
	setActionCaption = setActionCaption,
}
 end, _env("RemoteSpy.reducers.action-bar.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.action-bar.model", "RemoteSpy.reducers.action-bar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
return nil
 end, _env("RemoteSpy.reducers.action-bar.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.action-bar.reducer", "RemoteSpy.reducers.action-bar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local initialState = {
	actions = {
		close = {
			id = "close",
			disabled = false,
			active = false,
		},
		navigatePrevious = {
			id = "navigatePrevious",
			disabled = true,
			active = false,
		},
		navigateNext = {
			id = "navigateNext",
			disabled = false,
			active = false,
		},
		copy = {
			id = "copy",
			disabled = true,
			active = false,
		},
		save = {
			id = "save",
			disabled = true,
			active = false,
		},
		delete = {
			id = "delete",
			disabled = true,
			active = false,
		},
		traceback = {
			id = "traceback",
			disabled = false,
			active = false,
		},
		copyPath = {
			id = "copyPath",
			disabled = false,
			active = false,
		},
		copyScript = {
			id = "copyScript",
			disabled = true,
			active = false,
		},
		viewScript = {
			id = "viewScript",
			disabled = true,
			active = false,
		},
		pause = {
			id = "pause",
			disabled = false,
			active = false,
		},
		pauseRemote = {
			id = "pauseRemote",
			disabled = true,
			active = false,
		},
		blockRemote = {
			id = "blockRemote",
			disabled = true,
			active = false,
		},
		blockAll = {
			id = "blockAll",
			disabled = false,
			active = false,
		},
		runRemote = {
			id = "runRemote",
			disabled = true,
			active = false,
		},
	},
}
local function actionBarReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "SET_ACTION_ENABLED" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "actions"
			local _object_1 = {}
			for _k, _v in pairs(state.actions) do
				_object_1[_k] = _v
			end
			local _left_1 = action.id
			local _object_2 = {}
			for _k, _v in pairs(state.actions[action.id]) do
				_object_2[_k] = _v
			end
			_object_2.disabled = not action.enabled
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		if _exp == "ACTIVATE_ACTION" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "actions"
			local _object_1 = {}
			for _k, _v in pairs(state.actions) do
				_object_1[_k] = _v
			end
			local _left_1 = action.id
			local _object_2 = {}
			for _k, _v in pairs(state.actions[action.id]) do
				_object_2[_k] = _v
			end
			_object_2.active = true
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		if _exp == "DEACTIVATE_ACTION" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "actions"
			local _object_1 = {}
			for _k, _v in pairs(state.actions) do
				_object_1[_k] = _v
			end
			local _left_1 = action.id
			local _object_2 = {}
			for _k, _v in pairs(state.actions[action.id]) do
				_object_2[_k] = _v
			end
			_object_2.active = false
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		if _exp == "SET_ACTION_CAPTION" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "actions"
			local _object_1 = {}
			for _k, _v in pairs(state.actions) do
				_object_1[_k] = _v
			end
			local _left_1 = action.id
			local _object_2 = {}
			for _k, _v in pairs(state.actions[action.id]) do
				_object_2[_k] = _v
			end
			_object_2.caption = action.caption
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		return state
	until true
end
return {
	default = actionBarReducer,
}
 end, _env("RemoteSpy.reducers.action-bar.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.action-bar.selectors", "RemoteSpy.reducers.action-bar", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local selectActionBarState = function(state)
	return state.actionBar.actions
end
local selectIsClosing = function(state)
	return state.actionBar.actions.close.active
end
local selectActionById = function(state, id)
	return state.actionBar.actions[id]
end
local selectActionIsActive = function(state, id)
	return state.actionBar.actions[id].active
end
local selectActionIsDisabled = function(state, id)
	return state.actionBar.actions[id].disabled
end
return {
	selectActionBarState = selectActionBarState,
	selectIsClosing = selectIsClosing,
	selectActionById = selectActionById,
	selectActionIsActive = selectActionIsActive,
	selectActionIsDisabled = selectActionIsDisabled,
}
 end, _env("RemoteSpy.reducers.action-bar.selectors"))() end)

_module("remote-log", "ModuleScript", "RemoteSpy.reducers.remote-log", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
exports.default = TS.import(script, script, "reducer").default
for _k, _v in pairs(TS.import(script, script, "utils") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
return exports
 end, _env("RemoteSpy.reducers.remote-log"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.remote-log.actions", "RemoteSpy.reducers.remote-log", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function pushRemoteLog(log)
	return {
		type = "PUSH_REMOTE_LOG",
		log = log,
	}
end
local function removeRemoteLog(id)
	return {
		type = "REMOVE_REMOTE_LOG",
		id = id,
	}
end
local function pushOutgoingSignal(id, signal)
	return {
		type = "PUSH_OUTGOING_SIGNAL",
		id = id,
		signal = signal,
	}
end
local function removeOutgoingSignal(id, signalId)
	return {
		type = "REMOVE_OUTGOING_SIGNAL",
		id = id,
		signalId = signalId,
	}
end
local function clearOutgoingSignals(id)
	return {
		type = "CLEAR_OUTGOING_SIGNALS",
		id = id,
	}
end
local function setRemoteSelected(id)
	return {
		type = "SET_REMOTE_SELECTED",
		id = id,
	}
end
local function setSignalSelected(remote, id)
	return {
		type = "SET_SIGNAL_SELECTED",
		remote = remote,
		id = id,
	}
end
local function toggleSignalSelected(remote, id)
	return {
		type = "TOGGLE_SIGNAL_SELECTED",
		remote = remote,
		id = id,
	}
end
local function togglePaused()
	return {
		type = "TOGGLE_PAUSED",
	}
end
local function toggleRemotePaused(id)
	return {
		type = "TOGGLE_REMOTE_PAUSED",
		id = id,
	}
end
local function toggleRemoteBlocked(id)
	return {
		type = "TOGGLE_REMOTE_BLOCKED",
		id = id,
	}
end
local function toggleBlockAllRemotes()
	return {
		type = "TOGGLE_BLOCK_ALL_REMOTES",
	}
end
local function toggleNoActors()
	return {
		type = "TOGGLE_NO_ACTORS",
	}
end
local function toggleNoExecutor()
	return {
		type = "TOGGLE_NO_EXECUTOR",
	}
end
local function toggleShowRemoteEvents()
	return {
		type = "TOGGLE_SHOW_REMOTE_EVENTS",
	}
end
local function toggleShowRemoteFunctions()
	return {
		type = "TOGGLE_SHOW_REMOTE_FUNCTIONS",
	}
end
local function toggleShowBindableEvents()
	return {
		type = "TOGGLE_SHOW_BINDABLE_EVENTS",
	}
end
local function toggleShowBindableFunctions()
	return {
		type = "TOGGLE_SHOW_BINDABLE_FUNCTIONS",
	}
end
local function setPathNotation(notation)
	return {
		type = "SET_PATH_NOTATION",
		notation = notation,
	}
end
local function setMaxInspectionResults(max)
	return {
		type = "SET_MAX_INSPECTION_RESULTS",
		max = max,
	}
end
local function toggleRemoteMultiSelected(id)
	return {
		type = "TOGGLE_REMOTE_MULTI_SELECTED",
		id = id,
	}
end
local function clearMultiSelection()
	return {
		type = "CLEAR_MULTI_SELECTION",
	}
end
local function loadSettings(settings)
	return {
		type = "LOAD_SETTINGS",
		settings = settings,
	}
end
local function setInspectionResultSelected(result)
	return {
		type = "SET_INSPECTION_RESULT_SELECTED",
		result = result,
	}
end
return {
	pushRemoteLog = pushRemoteLog,
	removeRemoteLog = removeRemoteLog,
	pushOutgoingSignal = pushOutgoingSignal,
	removeOutgoingSignal = removeOutgoingSignal,
	clearOutgoingSignals = clearOutgoingSignals,
	setRemoteSelected = setRemoteSelected,
	setSignalSelected = setSignalSelected,
	toggleSignalSelected = toggleSignalSelected,
	togglePaused = togglePaused,
	toggleRemotePaused = toggleRemotePaused,
	toggleRemoteBlocked = toggleRemoteBlocked,
	toggleBlockAllRemotes = toggleBlockAllRemotes,
	toggleNoActors = toggleNoActors,
	toggleNoExecutor = toggleNoExecutor,
	toggleShowRemoteEvents = toggleShowRemoteEvents,
	toggleShowRemoteFunctions = toggleShowRemoteFunctions,
	toggleShowBindableEvents = toggleShowBindableEvents,
	toggleShowBindableFunctions = toggleShowBindableFunctions,
	setPathNotation = setPathNotation,
	setMaxInspectionResults = setMaxInspectionResults,
	toggleRemoteMultiSelected = toggleRemoteMultiSelected,
	clearMultiSelection = clearMultiSelection,
	loadSettings = loadSettings,
	setInspectionResultSelected = setInspectionResultSelected,
}
 end, _env("RemoteSpy.reducers.remote-log.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.remote-log.model", "RemoteSpy.reducers.remote-log", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local PathNotation
do
	local _inverse = {}
	PathNotation = setmetatable({}, {
		__index = _inverse,
	})
	PathNotation.Dot = "dot"
	_inverse.dot = "Dot"
	PathNotation.WaitForChild = "waitforchild"
	_inverse.waitforchild = "WaitForChild"
	PathNotation.FindFirstChild = "findfirstchild"
	_inverse.findfirstchild = "FindFirstChild"
end
return {
	PathNotation = PathNotation,
}
 end, _env("RemoteSpy.reducers.remote-log.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.remote-log.reducer", "RemoteSpy.reducers.remote-log", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local PathNotation = TS.import(script, script.Parent, "model").PathNotation
local initialState = {
	logs = {},
	paused = false,
	pausedRemotes = {},
	blockedRemotes = {},
	remotesMultiSelected = {},
	noActors = false,
	noExecutor = false,
	showRemoteEvents = true,
	showRemoteFunctions = true,
	showBindableEvents = false,
	showBindableFunctions = false,
	pathNotation = PathNotation.Dot,
	maxInspectionResults = 650,
}
local function remoteLogReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "PUSH_REMOTE_LOG" then
			local _object = {}
			for _k, _v in pairs(action.log) do
				_object[_k] = _v
			end
			local _left = "outgoing"
			local _outgoing = action.log.outgoing
			local _arg0 = function(signal)
				local _object_1 = {}
				for _k, _v in pairs(signal) do
					_object_1[_k] = _v
				end
				_object_1.timestamp = os.clock()
				return _object_1
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_outgoing)
			for _k, _v in ipairs(_outgoing) do
				_newValue[_k] = _arg0(_v, _k - 1, _outgoing)
			end
			-- ▲ ReadonlyArray.map ▲
			_object[_left] = _newValue
			local logWithTimestamps = _object
			local _object_1 = {}
			for _k, _v in pairs(state) do
				_object_1[_k] = _v
			end
			local _left_1 = "logs"
			local _array = {}
			local _length = #_array
			local _array_1 = state.logs
			local _Length = #_array_1
			table.move(_array_1, 1, _Length, _length + 1, _array)
			_length += _Length
			_array[_length + 1] = logWithTimestamps
			_object_1[_left_1] = _array
			return _object_1
		end
		if _exp == "REMOVE_REMOTE_LOG" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "logs"
			local _logs = state.logs
			local _arg0 = function(log)
				return log.id ~= action.id
			end
			-- ▼ ReadonlyArray.filter ▼
			local _newValue = {}
			local _length = 0
			for _k, _v in ipairs(_logs) do
				if _arg0(_v, _k - 1, _logs) == true then
					_length += 1
					_newValue[_length] = _v
				end
			end
			-- ▲ ReadonlyArray.filter ▲
			_object[_left] = _newValue
			return _object
		end
		if _exp == "PUSH_OUTGOING_SIGNAL" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "logs"
			local _logs = state.logs
			local _arg0 = function(log)
				if log.id == action.id then
					local _object_1 = {}
					for _k, _v in pairs(action.signal) do
						_object_1[_k] = _v
					end
					_object_1.timestamp = os.clock()
					local signalWithTimestamp = _object_1
					local _array = { signalWithTimestamp }
					local _length = #_array
					local _array_1 = log.outgoing
					table.move(_array_1, 1, #_array_1, _length + 1, _array)
					local outgoing = _array
					local _object_2 = {}
					for _k, _v in pairs(log) do
						_object_2[_k] = _v
					end
					_object_2.outgoing = outgoing
					return _object_2
				end
				return log
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_logs)
			for _k, _v in ipairs(_logs) do
				_newValue[_k] = _arg0(_v, _k - 1, _logs)
			end
			-- ▲ ReadonlyArray.map ▲
			_object[_left] = _newValue
			return _object
		end
		if _exp == "REMOVE_OUTGOING_SIGNAL" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "logs"
			local _logs = state.logs
			local _arg0 = function(log)
				if log.id == action.id then
					local _object_1 = {}
					for _k, _v in pairs(log) do
						_object_1[_k] = _v
					end
					local _left_1 = "outgoing"
					local _outgoing = log.outgoing
					local _arg0_1 = function(signal)
						return signal.id ~= action.signalId
					end
					-- ▼ ReadonlyArray.filter ▼
					local _newValue = {}
					local _length = 0
					for _k, _v in ipairs(_outgoing) do
						if _arg0_1(_v, _k - 1, _outgoing) == true then
							_length += 1
							_newValue[_length] = _v
						end
					end
					-- ▲ ReadonlyArray.filter ▲
					_object_1[_left_1] = _newValue
					return _object_1
				end
				return log
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_logs)
			for _k, _v in ipairs(_logs) do
				_newValue[_k] = _arg0(_v, _k - 1, _logs)
			end
			-- ▲ ReadonlyArray.map ▲
			_object[_left] = _newValue
			return _object
		end
		if _exp == "CLEAR_OUTGOING_SIGNALS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "logs"
			local _logs = state.logs
			local _arg0 = function(log)
				if log.id == action.id then
					local _object_1 = {}
					for _k, _v in pairs(log) do
						_object_1[_k] = _v
					end
					_object_1.outgoing = {}
					return _object_1
				end
				return log
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#_logs)
			for _k, _v in ipairs(_logs) do
				_newValue[_k] = _arg0(_v, _k - 1, _logs)
			end
			-- ▲ ReadonlyArray.map ▲
			_object[_left] = _newValue
			return _object
		end
		if _exp == "SET_REMOTE_SELECTED" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.remoteSelected = action.id
			return _object
		end
		if _exp == "SET_SIGNAL_SELECTED" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.signalSelected = action.id
			_object.remoteForSignalSelected = if action.id ~= nil then action.remote else nil
			return _object
		end
		if _exp == "TOGGLE_SIGNAL_SELECTED" then
			local signalSelected = if state.signalSelected == action.id then nil else action.id
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.signalSelected = signalSelected
			_object.remoteForSignalSelected = if signalSelected ~= nil then action.remote else nil
			return _object
		end
		if _exp == "TOGGLE_PAUSED" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.paused = not state.paused
			return _object
		end
		if _exp == "TOGGLE_REMOTE_PAUSED" then
			local pausedRemotes = {}
			local _pausedRemotes = state.pausedRemotes
			local _arg0 = function(id)
				pausedRemotes[id] = true
				return pausedRemotes
			end
			for _v in pairs(_pausedRemotes) do
				_arg0(_v, _v, _pausedRemotes)
			end
			local _id = action.id
			if pausedRemotes[_id] ~= nil then
				local _id_1 = action.id
				pausedRemotes[_id_1] = nil
			else
				local _id_1 = action.id
				pausedRemotes[_id_1] = true
			end
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.pausedRemotes = pausedRemotes
			return _object
		end
		if _exp == "TOGGLE_REMOTE_BLOCKED" then
			local blockedRemotes = {}
			local _blockedRemotes = state.blockedRemotes
			local _arg0 = function(id)
				blockedRemotes[id] = true
				return blockedRemotes
			end
			for _v in pairs(_blockedRemotes) do
				_arg0(_v, _v, _blockedRemotes)
			end
			local _id = action.id
			if blockedRemotes[_id] ~= nil then
				local _id_1 = action.id
				blockedRemotes[_id_1] = nil
			else
				local _id_1 = action.id
				blockedRemotes[_id_1] = true
			end
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.blockedRemotes = blockedRemotes
			return _object
		end
		if _exp == "TOGGLE_BLOCK_ALL_REMOTES" then
			local _condition = #state.logs > 0
			if _condition then
				local _logs = state.logs
				local _arg0 = function(log)
					local _blockedRemotes = state.blockedRemotes
					local _id = log.id
					return _blockedRemotes[_id] ~= nil
				end
				-- ▼ ReadonlyArray.every ▼
				local _result = true
				for _k, _v in ipairs(_logs) do
					if not _arg0(_v, _k - 1, _logs) then
						_result = false
						break
					end
				end
				-- ▲ ReadonlyArray.every ▲
				_condition = _result
			end
			local allBlocked = _condition
			local blockedRemotes = {}
			if not allBlocked then
				local _logs = state.logs
				local _arg0 = function(log)
					local _id = log.id
					blockedRemotes[_id] = true
					return blockedRemotes
				end
				for _k, _v in ipairs(_logs) do
					_arg0(_v, _k - 1, _logs)
				end
			end
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.blockedRemotes = blockedRemotes
			return _object
		end
		if _exp == "TOGGLE_NO_ACTORS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.noActors = not state.noActors
			return _object
		end
		if _exp == "TOGGLE_NO_EXECUTOR" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.noExecutor = not state.noExecutor
			return _object
		end
		if _exp == "TOGGLE_SHOW_REMOTE_EVENTS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.showRemoteEvents = not state.showRemoteEvents
			return _object
		end
		if _exp == "TOGGLE_SHOW_REMOTE_FUNCTIONS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.showRemoteFunctions = not state.showRemoteFunctions
			return _object
		end
		if _exp == "TOGGLE_SHOW_BINDABLE_EVENTS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.showBindableEvents = not state.showBindableEvents
			return _object
		end
		if _exp == "TOGGLE_SHOW_BINDABLE_FUNCTIONS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.showBindableFunctions = not state.showBindableFunctions
			return _object
		end
		if _exp == "SET_PATH_NOTATION" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.pathNotation = action.notation
			return _object
		end
		if _exp == "SET_MAX_INSPECTION_RESULTS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.maxInspectionResults = action.max
			return _object
		end
		if _exp == "TOGGLE_REMOTE_MULTI_SELECTED" then
			local remotesMultiSelected = {}
			local _remotesMultiSelected = state.remotesMultiSelected
			local _arg0 = function(id)
				remotesMultiSelected[id] = true
				return remotesMultiSelected
			end
			for _v in pairs(_remotesMultiSelected) do
				_arg0(_v, _v, _remotesMultiSelected)
			end
			local _id = action.id
			if remotesMultiSelected[_id] ~= nil then
				local _id_1 = action.id
				remotesMultiSelected[_id_1] = nil
			else
				local _id_1 = action.id
				remotesMultiSelected[_id_1] = true
			end
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.remotesMultiSelected = remotesMultiSelected
			return _object
		end
		if _exp == "CLEAR_MULTI_SELECTION" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.remotesMultiSelected = {}
			return _object
		end
		if _exp == "LOAD_SETTINGS" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "noActors"
			local _condition = action.settings.noActors
			if _condition == nil then
				_condition = state.noActors
			end
			_object[_left] = _condition
			local _left_1 = "noExecutor"
			local _condition_1 = action.settings.noExecutor
			if _condition_1 == nil then
				_condition_1 = state.noExecutor
			end
			_object[_left_1] = _condition_1
			local _left_2 = "showRemoteEvents"
			local _condition_2 = action.settings.showRemoteEvents
			if _condition_2 == nil then
				_condition_2 = state.showRemoteEvents
			end
			_object[_left_2] = _condition_2
			local _left_3 = "showRemoteFunctions"
			local _condition_3 = action.settings.showRemoteFunctions
			if _condition_3 == nil then
				_condition_3 = state.showRemoteFunctions
			end
			_object[_left_3] = _condition_3
			local _left_4 = "showBindableEvents"
			local _condition_4 = action.settings.showBindableEvents
			if _condition_4 == nil then
				_condition_4 = state.showBindableEvents
			end
			_object[_left_4] = _condition_4
			local _left_5 = "showBindableFunctions"
			local _condition_5 = action.settings.showBindableFunctions
			if _condition_5 == nil then
				_condition_5 = state.showBindableFunctions
			end
			_object[_left_5] = _condition_5
			_object.pathNotation = action.settings.pathNotation or state.pathNotation
			local _left_6 = "maxInspectionResults"
			local _condition_6 = action.settings.maxInspectionResults
			if _condition_6 == nil then
				_condition_6 = state.maxInspectionResults
			end
			_object[_left_6] = _condition_6
			return _object
		end
		if _exp == "SET_INSPECTION_RESULT_SELECTED" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.inspectionResultSelected = action.result
			return _object
		end
		return state
	until true
end
return {
	default = remoteLogReducer,
}
 end, _env("RemoteSpy.reducers.remote-log.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.remote-log.selectors", "RemoteSpy.reducers.remote-log", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local createSelector = TS.import(script, TS.getModule(script, "@rbxts", "roselect").src).createSelector
local selectRemoteLogs = function(state)
	return state.remoteLog.logs
end
local selectRemoteLogsSorted = createSelector({ selectRemoteLogs }, function(logs)
	local _array = {}
	local _length = #_array
	table.move(logs, 1, #logs, _length + 1, _array)
	local _arg0 = function(a, b)
		local _result = a.outgoing[1]
		if _result ~= nil then
			_result = _result.timestamp
		end
		local _condition = _result
		if _condition == nil then
			_condition = -math.huge
		end
		local aTimestamp = _condition
		local _result_1 = b.outgoing[1]
		if _result_1 ~= nil then
			_result_1 = _result_1.timestamp
		end
		local _condition_1 = _result_1
		if _condition_1 == nil then
			_condition_1 = -math.huge
		end
		local bTimestamp = _condition_1
		return aTimestamp > bTimestamp
	end
	table.sort(_array, _arg0)
	return _array
end)
local selectRemoteLogIds = createSelector({ selectRemoteLogsSorted }, function(logs)
	local _arg0 = function(log)
		return log.id
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#logs)
	for _k, _v in ipairs(logs) do
		_newValue[_k] = _arg0(_v, _k - 1, logs)
	end
	-- ▲ ReadonlyArray.map ▲
	return _newValue
end)
local selectRemoteLogsOutgoing = function(state)
	local _logs = state.remoteLog.logs
	local _arg0 = function(log)
		return log.outgoing
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_logs)
	for _k, _v in ipairs(_logs) do
		_newValue[_k] = _arg0(_v, _k - 1, _logs)
	end
	-- ▲ ReadonlyArray.map ▲
	return _newValue
end
local selectRemoteIdSelected = function(state)
	return state.remoteLog.remoteSelected
end
local selectSignalIdSelected = function(state)
	return state.remoteLog.signalSelected
end
local selectSignalIdSelectedRemote = function(state)
	return state.remoteLog.remoteForSignalSelected
end
local selectRemotesMultiSelected = function(state)
	return state.remoteLog.remotesMultiSelected
end
local selectPaused = function(state)
	return state.remoteLog.paused
end
local selectPausedRemotes = function(state)
	return state.remoteLog.pausedRemotes
end
local selectBlockedRemotes = function(state)
	return state.remoteLog.blockedRemotes
end
local selectNoActors = function(state)
	return state.remoteLog.noActors
end
local selectNoExecutor = function(state)
	return state.remoteLog.noExecutor
end
local selectShowRemoteEvents = function(state)
	return state.remoteLog.showRemoteEvents
end
local selectShowRemoteFunctions = function(state)
	return state.remoteLog.showRemoteFunctions
end
local selectShowBindableEvents = function(state)
	return state.remoteLog.showBindableEvents
end
local selectShowBindableFunctions = function(state)
	return state.remoteLog.showBindableFunctions
end
local selectPathNotation = function(state)
	return state.remoteLog.pathNotation
end
local selectMaxInspectionResults = function(state)
	return state.remoteLog.maxInspectionResults
end
local selectInspectionResultSelected = function(state)
	return state.remoteLog.inspectionResultSelected
end
local makeSelectRemoteLog = function()
	return createSelector({ selectRemoteLogsSorted, function(_, id)
		return id
	end }, function(logs, id)
		local _arg0 = function(log)
			return log.id == id
		end
		-- ▼ ReadonlyArray.find ▼
		local _result
		for _i, _v in ipairs(logs) do
			if _arg0(_v, _i - 1, logs) == true then
				_result = _v
				break
			end
		end
		-- ▲ ReadonlyArray.find ▲
		return _result
	end)
end
local makeSelectRemoteLogOutgoing = function()
	return createSelector({ makeSelectRemoteLog() }, function(log)
		local _result = log
		if _result ~= nil then
			_result = _result.outgoing
		end
		return _result
	end)
end
local makeSelectRemoteLogObject = function()
	return createSelector({ makeSelectRemoteLog() }, function(log)
		local _result = log
		if _result ~= nil then
			_result = _result.object
		end
		return _result
	end)
end
local makeSelectRemoteLogType = function()
	return createSelector({ makeSelectRemoteLog() }, function(log)
		local _result = log
		if _result ~= nil then
			_result = _result.type
		end
		return _result
	end)
end
local _selectOutgoing = makeSelectRemoteLogOutgoing()
local selectSignalSelected = createSelector({ function(state)
	local _condition = selectSignalIdSelectedRemote(state)
	if _condition == nil then
		_condition = ""
	end
	return _selectOutgoing(state, _condition)
end, selectSignalIdSelected }, function(outgoing, id)
	local _result
	if outgoing and id ~= nil then
		local _result_1 = outgoing
		if _result_1 ~= nil then
			local _arg0 = function(signal)
				return signal.id == id
			end
			-- ▼ ReadonlyArray.find ▼
			local _result_2
			for _i, _v in ipairs(_result_1) do
				if _arg0(_v, _i - 1, _result_1) == true then
					_result_2 = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			_result_1 = _result_2
		end
		_result = _result_1
	else
		_result = nil
	end
	return _result
end)
return {
	selectRemoteLogs = selectRemoteLogs,
	selectRemoteLogsSorted = selectRemoteLogsSorted,
	selectRemoteLogIds = selectRemoteLogIds,
	selectRemoteLogsOutgoing = selectRemoteLogsOutgoing,
	selectRemoteIdSelected = selectRemoteIdSelected,
	selectSignalIdSelected = selectSignalIdSelected,
	selectSignalIdSelectedRemote = selectSignalIdSelectedRemote,
	selectRemotesMultiSelected = selectRemotesMultiSelected,
	selectPaused = selectPaused,
	selectPausedRemotes = selectPausedRemotes,
	selectBlockedRemotes = selectBlockedRemotes,
	selectNoActors = selectNoActors,
	selectNoExecutor = selectNoExecutor,
	selectShowRemoteEvents = selectShowRemoteEvents,
	selectShowRemoteFunctions = selectShowRemoteFunctions,
	selectShowBindableEvents = selectShowBindableEvents,
	selectShowBindableFunctions = selectShowBindableFunctions,
	selectPathNotation = selectPathNotation,
	selectMaxInspectionResults = selectMaxInspectionResults,
	selectInspectionResultSelected = selectInspectionResultSelected,
	makeSelectRemoteLog = makeSelectRemoteLog,
	makeSelectRemoteLogOutgoing = makeSelectRemoteLogOutgoing,
	makeSelectRemoteLogObject = makeSelectRemoteLogObject,
	makeSelectRemoteLogType = makeSelectRemoteLogType,
	selectSignalSelected = selectSignalSelected,
}
 end, _env("RemoteSpy.reducers.remote-log.selectors"))() end)

_module("utils", "ModuleScript", "RemoteSpy.reducers.remote-log.utils", "RemoteSpy.reducers.remote-log", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local TabType = TS.import(script, script.Parent.Parent, "tab-group").TabType
local _instance_util = TS.import(script, script.Parent.Parent.Parent, "utils", "instance-util")
local getInstanceId = _instance_util.getInstanceId
local getInstancePath = _instance_util.getInstancePath
local stringifyFunctionSignature = TS.import(script, script.Parent.Parent.Parent, "utils", "function-util").stringifyFunctionSignature
local nextId = 0
local function createRemoteLog(object, signal)
	local id = getInstanceId(object)
	local remoteType = if object:IsA("RemoteEvent") then TabType.Event elseif object:IsA("RemoteFunction") then TabType.Function elseif object:IsA("BindableEvent") then TabType.BindableEvent else TabType.BindableFunction
	return {
		id = id,
		object = object,
		type = remoteType,
		outgoing = if signal then { signal } else {},
	}
end
local function createOutgoingSignal(object, caller, callback, traceback, parameters, returns, isActor)
	local _object = {}
	local _left = "id"
	local _original = nextId
	nextId += 1
	_object[_left] = "signal-" .. tostring(_original)
	_object.remote = object
	_object.remoteId = getInstanceId(object)
	_object.name = object.Name
	_object.path = getInstancePath(object)
	_object.pathFmt = getInstancePath(object)
	_object.parameters = parameters
	_object.returns = returns
	_object.caller = caller
	_object.callback = callback
	_object.traceback = traceback
	_object.isActor = isActor
	_object.timestamp = 0
	return _object
end
local function stringifySignalTraceback(signal)
	local _exp = signal.traceback
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_exp)
	for _k, _v in ipairs(_exp) do
		_newValue[_k] = stringifyFunctionSignature(_v, _k - 1, _exp)
	end
	-- ▲ ReadonlyArray.map ▲
	local mapped = _newValue
	local length = #mapped
	do
		local i = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i < length / 2) then
				break
			end
			local temp = mapped[i + 1]
			mapped[i + 1] = mapped[length - i - 1 + 1]
			mapped[length - i - 1 + 1] = temp
		end
	end
	mapped[length - 1 + 1] = "→ " .. (mapped[length - 1 + 1] .. " ←")
	return mapped
end
return {
	createRemoteLog = createRemoteLog,
	createOutgoingSignal = createOutgoingSignal,
	stringifySignalTraceback = stringifySignalTraceback,
}
 end, _env("RemoteSpy.reducers.remote-log.utils"))() end)

_module("script", "ModuleScript", "RemoteSpy.reducers.script", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
exports.scriptReducer = TS.import(script, script, "reducer").default
return exports
 end, _env("RemoteSpy.reducers.script"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.script.actions", "RemoteSpy.reducers.script", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function setScript(id, scriptData)
	return {
		type = "SET_SCRIPT",
		id = id,
		script = scriptData,
	}
end
local function updateScriptContent(id, content)
	return {
		type = "UPDATE_SCRIPT_CONTENT",
		id = id,
		content = content,
	}
end
local function removeScript(id)
	return {
		type = "REMOVE_SCRIPT",
		id = id,
	}
end
return {
	setScript = setScript,
	updateScriptContent = updateScriptContent,
	removeScript = removeScript,
}
 end, _env("RemoteSpy.reducers.script.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.script.model", "RemoteSpy.reducers.script", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
return nil
 end, _env("RemoteSpy.reducers.script.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.script.reducer", "RemoteSpy.reducers.script", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local initialState = {
	scripts = {},
}
local function scriptReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "SET_SCRIPT" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "scripts"
			local _object_1 = {}
			for _k, _v in pairs(state.scripts) do
				_object_1[_k] = _v
			end
			_object_1[action.id] = action.script
			_object[_left] = _object_1
			return _object
		end
		if _exp == "UPDATE_SCRIPT_CONTENT" then
			local scriptData = state.scripts[action.id]
			if not scriptData then
				return state
			end
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "scripts"
			local _object_1 = {}
			for _k, _v in pairs(state.scripts) do
				_object_1[_k] = _v
			end
			local _left_1 = action.id
			local _object_2 = {}
			for _k, _v in pairs(scriptData) do
				_object_2[_k] = _v
			end
			_object_2.content = action.content
			_object_1[_left_1] = _object_2
			_object[_left] = _object_1
			return _object
		end
		if _exp == "REMOVE_SCRIPT" then
			local _object = {}
			for _k, _v in pairs(state.scripts) do
				_object[_k] = _v
			end
			local newScripts = _object
			newScripts[action.id] = nil
			local _object_1 = {}
			for _k, _v in pairs(state) do
				_object_1[_k] = _v
			end
			_object_1.scripts = newScripts
			return _object_1
		end
		return state
	until true
end
return {
	default = scriptReducer,
}
 end, _env("RemoteSpy.reducers.script.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.script.selectors", "RemoteSpy.reducers.script", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local selectScriptState = function(state)
	return state.script
end
local selectScript = function(state, id)
	return state.script.scripts[id]
end
local selectScriptContent = function(state, id)
	local _result = state.script.scripts[id]
	if _result ~= nil then
		_result = _result.content
	end
	return _result
end
return {
	selectScriptState = selectScriptState,
	selectScript = selectScript,
	selectScriptContent = selectScriptContent,
}
 end, _env("RemoteSpy.reducers.script.selectors"))() end)

_module("tab-group", "ModuleScript", "RemoteSpy.reducers.tab-group", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
exports.default = TS.import(script, script, "reducer").default
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "utils") or {}) do
	exports[_k] = _v
end
return exports
 end, _env("RemoteSpy.reducers.tab-group"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.tab-group.actions", "RemoteSpy.reducers.tab-group", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function pushTab(tab)
	return {
		type = "PUSH_TAB",
		tab = tab,
	}
end
local function deleteTab(id)
	return {
		type = "DELETE_TAB",
		id = id,
	}
end
local function moveTab(id, to)
	return {
		type = "MOVE_TAB",
		id = id,
		to = to,
	}
end
local function setActiveTab(id)
	return {
		type = "SET_ACTIVE_TAB",
		id = id,
	}
end
return {
	pushTab = pushTab,
	deleteTab = deleteTab,
	moveTab = moveTab,
	setActiveTab = setActiveTab,
}
 end, _env("RemoteSpy.reducers.tab-group.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.tab-group.model", "RemoteSpy.reducers.tab-group", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TabType
do
	local _inverse = {}
	TabType = setmetatable({}, {
		__index = _inverse,
	})
	TabType.Home = "home"
	_inverse.home = "Home"
	TabType.Event = "event"
	_inverse.event = "Event"
	TabType.Function = "function"
	_inverse["function"] = "Function"
	TabType.BindableEvent = "bindable-event"
	_inverse["bindable-event"] = "BindableEvent"
	TabType.BindableFunction = "bindable-function"
	_inverse["bindable-function"] = "BindableFunction"
	TabType.Script = "script"
	_inverse.script = "Script"
	TabType.Settings = "settings"
	_inverse.settings = "Settings"
	TabType.Inspection = "inspection"
	_inverse.inspection = "Inspection"
end
return {
	TabType = TabType,
}
 end, _env("RemoteSpy.reducers.tab-group.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.tab-group.reducer", "RemoteSpy.reducers.tab-group", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local TabType = TS.import(script, script.Parent, "model").TabType
local createTabColumn = TS.import(script, script.Parent, "utils").createTabColumn
local initialState = {
	tabs = { createTabColumn("home", "Home", TabType.Home, false), createTabColumn("inspection", "Inspection", TabType.Inspection, false) },
	activeTab = "home",
}
local function tabGroupReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "PUSH_TAB" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			local _left = "tabs"
			local _array = {}
			local _length = #_array
			local _array_1 = state.tabs
			local _Length = #_array_1
			table.move(_array_1, 1, _Length, _length + 1, _array)
			_length += _Length
			_array[_length + 1] = action.tab
			_object[_left] = _array
			return _object
		end
		if _exp == "DELETE_TAB" then
			local _tabs = state.tabs
			local _arg0 = function(tab)
				return tab.id == action.id
			end
			-- ▼ ReadonlyArray.findIndex ▼
			local _result = -1
			for _i, _v in ipairs(_tabs) do
				if _arg0(_v, _i - 1, _tabs) == true then
					_result = _i - 1
					break
				end
			end
			-- ▲ ReadonlyArray.findIndex ▲
			local index = _result
			local _object = {}
			local _left = "tabs"
			local _tabs_1 = state.tabs
			local _arg0_1 = function(tab)
				return tab.id ~= action.id
			end
			-- ▼ ReadonlyArray.filter ▼
			local _newValue = {}
			local _length = 0
			for _k, _v in ipairs(_tabs_1) do
				if _arg0_1(_v, _k - 1, _tabs_1) == true then
					_length += 1
					_newValue[_length] = _v
				end
			end
			-- ▲ ReadonlyArray.filter ▲
			_object[_left] = _newValue
			local _left_1 = "activeTab"
			local _result_1
			if state.activeTab == action.id then
				local _result_2 = state.tabs[index - 1 + 1]
				if _result_2 ~= nil then
					_result_2 = _result_2.id
				end
				local _condition = _result_2
				if _condition == nil then
					_condition = state.tabs[index + 1 + 1].id
				end
				_result_1 = _condition
			else
				_result_1 = state.activeTab
			end
			_object[_left_1] = _result_1
			return _object
		end
		if _exp == "MOVE_TAB" then
			local _tabs = state.tabs
			local _arg0 = function(tab)
				return tab.id == action.id
			end
			-- ▼ ReadonlyArray.find ▼
			local _result
			for _i, _v in ipairs(_tabs) do
				if _arg0(_v, _i - 1, _tabs) == true then
					_result = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			local tab = _result
			local from = (table.find(state.tabs, tab) or 0) - 1
			local tabs = table.clone(state.tabs)
			table.remove(tabs, from + 1)
			local _to = action.to
			table.insert(tabs, _to + 1, tab)
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.tabs = tabs
			return _object
		end
		if _exp == "SET_ACTIVE_TAB" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.activeTab = action.id
			return _object
		end
		return state
	until true
end
return {
	default = tabGroupReducer,
}
 end, _env("RemoteSpy.reducers.tab-group.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.tab-group.selectors", "RemoteSpy.reducers.tab-group", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local createSelector = TS.import(script, TS.getModule(script, "@rbxts", "roselect").src).createSelector
local getTabOffset = TS.import(script, script.Parent, "utils").getTabOffset
local selectTabGroup = function(state)
	return state.tabGroup
end
local selectTabs = function(state)
	return state.tabGroup.tabs
end
local selectActiveTabId = function(state)
	return state.tabGroup.activeTab
end
local selectTabCount = function(state)
	return #state.tabGroup.tabs
end
local selectTab
local selectActiveTab = function(state)
	return selectTab(state, state.tabGroup.activeTab)
end
selectTab = function(state, id)
	local _tabs = state.tabGroup.tabs
	local _arg0 = function(tab)
		return tab.id == id
	end
	-- ▼ ReadonlyArray.find ▼
	local _result
	for _i, _v in ipairs(_tabs) do
		if _arg0(_v, _i - 1, _tabs) == true then
			_result = _v
			break
		end
	end
	-- ▲ ReadonlyArray.find ▲
	return _result
end
local selectTabOrder = function(state, id)
	local _tabs = state.tabGroup.tabs
	local _arg0 = function(tab)
		return tab.id == id
	end
	-- ▼ ReadonlyArray.findIndex ▼
	local _result = -1
	for _i, _v in ipairs(_tabs) do
		if _arg0(_v, _i - 1, _tabs) == true then
			_result = _i - 1
			break
		end
	end
	-- ▲ ReadonlyArray.findIndex ▲
	return _result
end
local selectActiveTabOrder = function(state)
	local _tabs = state.tabGroup.tabs
	local _arg0 = function(tab)
		return tab.id == state.tabGroup.activeTab
	end
	-- ▼ ReadonlyArray.findIndex ▼
	local _result = -1
	for _i, _v in ipairs(_tabs) do
		if _arg0(_v, _i - 1, _tabs) == true then
			_result = _i - 1
			break
		end
	end
	-- ▲ ReadonlyArray.findIndex ▲
	return _result
end
local selectTabIsActive = function(state, id)
	return state.tabGroup.activeTab == id
end
local selectTabType = function(state, id)
	local _result = selectTab(state, id)
	if _result ~= nil then
		_result = _result.type
	end
	return _result
end
local makeSelectTabsBefore = function()
	local selectTabsBefore = createSelector({ selectTabs, selectTabOrder }, function(tabs, order)
		local _arg0 = function(_, index)
			return index < order
		end
		-- ▼ ReadonlyArray.filter ▼
		local _newValue = {}
		local _length = 0
		for _k, _v in ipairs(tabs) do
			if _arg0(_v, _k - 1, tabs) == true then
				_length += 1
				_newValue[_length] = _v
			end
		end
		-- ▲ ReadonlyArray.filter ▲
		return _newValue
	end)
	return selectTabsBefore
end
local makeSelectTabOffset = function()
	local selectTabOffset = createSelector({ makeSelectTabsBefore(), selectTab }, function(tabs, tab)
		if not tab then
			return 0
		end
		return getTabOffset(tabs, tab)
	end)
	return selectTabOffset
end
return {
	selectTabGroup = selectTabGroup,
	selectTabs = selectTabs,
	selectActiveTabId = selectActiveTabId,
	selectTabCount = selectTabCount,
	selectActiveTab = selectActiveTab,
	selectTab = selectTab,
	selectTabOrder = selectTabOrder,
	selectActiveTabOrder = selectActiveTabOrder,
	selectTabIsActive = selectTabIsActive,
	selectTabType = selectTabType,
	makeSelectTabsBefore = makeSelectTabsBefore,
	makeSelectTabOffset = makeSelectTabOffset,
}
 end, _env("RemoteSpy.reducers.tab-group.selectors"))() end)

_module("utils", "ModuleScript", "RemoteSpy.reducers.tab-group.utils", "RemoteSpy.reducers.tab-group", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local TextService = TS.import(script, TS.getModule(script, "@rbxts", "services")).TextService
local MAX_TAB_CAPTION_WIDTH = 150
local function createTabColumn(id, caption, tabType, canClose, scriptContent)
	if canClose == nil then
		canClose = true
	end
	return {
		id = id,
		caption = caption,
		type = tabType,
		canClose = canClose,
		scriptContent = scriptContent,
	}
end
local function getTabCaptionWidth(tab)
	local textSize = TextService:GetTextSize(tab.caption, 11, "Gotham", Vector2.new(300, 0))
	return math.min(textSize.X, MAX_TAB_CAPTION_WIDTH)
end
local function getTabWidth(tab)
	local captionWidth = getTabCaptionWidth(tab)
	local iconWidth = 16 + 6
	local closeWidth = if tab.canClose then 16 + 6 else 3
	return 8 + iconWidth + captionWidth + closeWidth + 8
end
local function getTabOffset(tabs, tab)
	local offset = 0
	for _, t in ipairs(tabs) do
		if t == tab then
			break
		end
		offset += getTabWidth(t)
	end
	return offset
end
return {
	createTabColumn = createTabColumn,
	getTabCaptionWidth = getTabCaptionWidth,
	getTabWidth = getTabWidth,
	getTabOffset = getTabOffset,
	MAX_TAB_CAPTION_WIDTH = MAX_TAB_CAPTION_WIDTH,
}
 end, _env("RemoteSpy.reducers.tab-group.utils"))() end)

_module("traceback", "ModuleScript", "RemoteSpy.reducers.traceback", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
exports.default = TS.import(script, script, "reducer").default
return exports
 end, _env("RemoteSpy.reducers.traceback"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.traceback.actions", "RemoteSpy.reducers.traceback", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function setTracebackCallStack(callStack)
	return {
		type = "SET_TRACEBACK_CALL_STACK",
		callStack = callStack,
	}
end
local function clearTraceback()
	return {
		type = "CLEAR_TRACEBACK",
	}
end
return {
	setTracebackCallStack = setTracebackCallStack,
	clearTraceback = clearTraceback,
}
 end, _env("RemoteSpy.reducers.traceback.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.traceback.model", "RemoteSpy.reducers.traceback", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
return nil
 end, _env("RemoteSpy.reducers.traceback.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.traceback.reducer", "RemoteSpy.reducers.traceback", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local initialState = {
	callStack = {},
}
local function tracebackReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "SET_TRACEBACK_CALL_STACK" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.callStack = action.callStack
			return _object
		end
		if _exp == "CLEAR_TRACEBACK" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.callStack = {}
			return _object
		end
		return state
	until true
end
return {
	default = tracebackReducer,
}
 end, _env("RemoteSpy.reducers.traceback.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.traceback.selectors", "RemoteSpy.reducers.traceback", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.Parent.include.RuntimeLib)
local createSelector = TS.import(script, TS.getModule(script, "@rbxts", "roselect").src).createSelector
local _function_util = TS.import(script, script.Parent.Parent.Parent, "utils", "function-util")
local describeFunction = _function_util.describeFunction
local getFunctionScript = _function_util.getFunctionScript
local selectTracebackState = function(state)
	return state.traceback
end
local selectTracebackCallStack = function(state)
	return state.traceback.callStack
end
local selectTracebackByString = createSelector({ selectTracebackState, function(_, searchString)
	return searchString
end }, function(traceback, searchString)
	local _callStack = traceback.callStack
	local _arg0 = function(callback)
		local description = describeFunction(callback)
		local creator = getFunctionScript(callback)
		return (string.find(description.name, searchString)) ~= nil or (string.find(tostring(creator), searchString)) ~= nil
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(_callStack) do
		if _arg0(_v, _k - 1, _callStack) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	return _newValue
end)
return {
	selectTracebackState = selectTracebackState,
	selectTracebackCallStack = selectTracebackCallStack,
	selectTracebackByString = selectTracebackByString,
}
 end, _env("RemoteSpy.reducers.traceback.selectors"))() end)

_module("ui", "ModuleScript", "RemoteSpy.reducers.ui", "RemoteSpy.reducers", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local exports = {}
exports.default = TS.import(script, script, "reducer").default
for _k, _v in pairs(TS.import(script, script, "model") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "actions") or {}) do
	exports[_k] = _v
end
for _k, _v in pairs(TS.import(script, script, "selectors") or {}) do
	exports[_k] = _v
end
return exports
 end, _env("RemoteSpy.reducers.ui"))() end)

_module("actions", "ModuleScript", "RemoteSpy.reducers.ui.actions", "RemoteSpy.reducers.ui", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function toggleUIVisibility()
	return {
		type = "TOGGLE_UI_VISIBILITY",
	}
end
local function setUIVisibility(visible)
	return {
		type = "SET_UI_VISIBILITY",
		visible = visible,
	}
end
local function setToggleKey(key)
	return {
		type = "SET_TOGGLE_KEY",
		key = key,
	}
end
local function loadToggleKey(keyName)
	return {
		type = "LOAD_TOGGLE_KEY",
		keyName = keyName,
	}
end
return {
	toggleUIVisibility = toggleUIVisibility,
	setUIVisibility = setUIVisibility,
	setToggleKey = setToggleKey,
	loadToggleKey = loadToggleKey,
}
 end, _env("RemoteSpy.reducers.ui.actions"))() end)

_module("model", "ModuleScript", "RemoteSpy.reducers.ui.model", "RemoteSpy.reducers.ui", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
return nil
 end, _env("RemoteSpy.reducers.ui.model"))() end)

_module("reducer", "ModuleScript", "RemoteSpy.reducers.ui.reducer", "RemoteSpy.reducers.ui", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local initialState = {
	visible = true,
	toggleKey = Enum.KeyCode.RightControl,
}
local function uiReducer(state, action)
	if state == nil then
		state = initialState
	end
	local _exp = action.type
	repeat
		if _exp == "TOGGLE_UI_VISIBILITY" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.visible = not state.visible
			return _object
		end
		if _exp == "SET_UI_VISIBILITY" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.visible = action.visible
			return _object
		end
		if _exp == "SET_TOGGLE_KEY" then
			local _object = {}
			for _k, _v in pairs(state) do
				_object[_k] = _v
			end
			_object.toggleKey = action.key
			return _object
		end
		if _exp == "LOAD_TOGGLE_KEY" then
			local allKeyCodes = Enum.KeyCode:GetEnumItems()
			local _arg0 = function(keyCode)
				return keyCode.Name == action.keyName
			end
			-- ▼ ReadonlyArray.find ▼
			local _result
			for _i, _v in ipairs(allKeyCodes) do
				if _arg0(_v, _i - 1, allKeyCodes) == true then
					_result = _v
					break
				end
			end
			-- ▲ ReadonlyArray.find ▲
			local foundKeyCode = _result
			if foundKeyCode then
				local _object = {}
				for _k, _v in pairs(state) do
					_object[_k] = _v
				end
				_object.toggleKey = foundKeyCode
				return _object
			end
			return state
		end
		return state
	until true
end
return {
	default = uiReducer,
}
 end, _env("RemoteSpy.reducers.ui.reducer"))() end)

_module("selectors", "ModuleScript", "RemoteSpy.reducers.ui.selectors", "RemoteSpy.reducers.ui", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local selectUIVisible = function(state)
	return state.ui.visible
end
local selectToggleKey = function(state)
	return state.ui.toggleKey
end
return {
	selectUIVisible = selectUIVisible,
	selectToggleKey = selectToggleKey,
}
 end, _env("RemoteSpy.reducers.ui.selectors"))() end)

_module("store", "ModuleScript", "RemoteSpy.store", "RemoteSpy", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.include.RuntimeLib)
local Rodux = TS.import(script, TS.getModule(script, "@rbxts", "rodux").src)
local rootReducer = TS.import(script, script.Parent, "reducers").default
local _remote_log = TS.import(script, script.Parent, "reducers", "remote-log")
local selectPaused = _remote_log.selectPaused
local selectPausedRemotes = _remote_log.selectPausedRemotes
local selectBlockedRemotes = _remote_log.selectBlockedRemotes
local selectNoActors = _remote_log.selectNoActors
local selectNoExecutor = _remote_log.selectNoExecutor
local selectShowRemoteEvents = _remote_log.selectShowRemoteEvents
local selectShowRemoteFunctions = _remote_log.selectShowRemoteFunctions
local selectShowBindableEvents = _remote_log.selectShowBindableEvents
local selectShowBindableFunctions = _remote_log.selectShowBindableFunctions
local store
local isDestructed = false
local function createStore()
	return Rodux.Store.new(rootReducer, nil)
end
local function configureStore()
	if store then
		return store
	end
	store = createStore()
	return store
end
local function destruct()
	if isDestructed then
		return nil
	end
	isDestructed = true
	store:destruct()
end
local function isActive()
	if not store or isDestructed then
		return false
	end
	local paused = selectPaused(store:getState())
	return not paused
end
local function isRemoteBlocked(remoteId)
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	local blockedRemotes = selectBlockedRemotes(state)
	return blockedRemotes[remoteId] ~= nil
end
local function isRemoteAllowed(remoteId)
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	local paused = selectPaused(state)
	local pausedRemotes = selectPausedRemotes(state)
	local blockedRemotes = selectBlockedRemotes(state)
	if paused then
		return false
	end
	if blockedRemotes[remoteId] ~= nil then
		return false
	end
	if pausedRemotes[remoteId] ~= nil then
		return false
	end
	return true
end
local function isNoActors()
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	return selectNoActors(state)
end
local function isNoExecutor()
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	return selectNoExecutor(state)
end
local function isShowRemoteEvents()
	if not store or isDestructed then
		return true
	end
	local state = store:getState()
	return selectShowRemoteEvents(state)
end
local function isShowRemoteFunctions()
	if not store or isDestructed then
		return true
	end
	local state = store:getState()
	return selectShowRemoteFunctions(state)
end
local function isShowBindableEvents()
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	return selectShowBindableEvents(state)
end
local function isShowBindableFunctions()
	if not store or isDestructed then
		return false
	end
	local state = store:getState()
	return selectShowBindableFunctions(state)
end
local function dispatch(action)
	if isDestructed then
		return nil
	end
	return configureStore():dispatch(action)
end
local function get(selector)
	if isDestructed then
		return nil
	end
	local store = configureStore()
	return if selector then selector(store:getState()) else store:getState()
end
local function changed(selector, callback)
	if isDestructed then
		return nil
	end
	local store = configureStore()
	local lastState = selector(store:getState())
	task.defer(callback, lastState)
	return store.changed:connect(function(state)
		local newState = selector(state)
		if lastState ~= newState then
			local _fn = task
			lastState = newState
			_fn.spawn(callback, lastState)
		end
	end)
end
return {
	configureStore = configureStore,
	destruct = destruct,
	isActive = isActive,
	isRemoteBlocked = isRemoteBlocked,
	isRemoteAllowed = isRemoteAllowed,
	isNoActors = isNoActors,
	isNoExecutor = isNoExecutor,
	isShowRemoteEvents = isShowRemoteEvents,
	isShowRemoteFunctions = isShowRemoteFunctions,
	isShowBindableEvents = isShowBindableEvents,
	isShowBindableFunctions = isShowBindableFunctions,
	dispatch = dispatch,
	get = get,
	changed = changed,
}
 end, _env("RemoteSpy.store"))() end)

_instance("util", "Folder", "RemoteSpy.util", "RemoteSpy")

_module("applyUDim2", "ModuleScript", "RemoteSpy.util.applyUDim2", "RemoteSpy.util", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function applyUDim2(v2, udim2)
	return Vector2.new(v2.X * udim2.X.Scale + udim2.X.Offset, v2.Y * udim2.Y.Scale + udim2.Y.Offset)
end
return {
	default = applyUDim2,
}
 end, _env("RemoteSpy.util.applyUDim2"))() end)

_module("number-util", "ModuleScript", "RemoteSpy.util.number-util", "RemoteSpy.util", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function map(n, min0, max0, min1, max1)
	return min1 + ((n - min0) * (max1 - min1)) / (max0 - min0)
end
local function mapStrict(n, min0, max0, min1, max1)
	return math.clamp(min1 + ((n - min0) * (max1 - min1)) / (max0 - min0), min1, max1)
end
local function lerp(a, b, t)
	return a + (b - a) * t
end
local function multiply(n, ...)
	local args = { ... }
	local _arg0 = function(a, b)
		return 1 - (1 - a) * (1 - b)
	end
	-- ▼ ReadonlyArray.reduce ▼
	local _result = n
	local _callback = _arg0
	for _i = 1, #args do
		_result = _callback(_result, args[_i], _i - 1, args)
	end
	-- ▲ ReadonlyArray.reduce ▲
	return _result
end
return {
	map = map,
	mapStrict = mapStrict,
	lerp = lerp,
	multiply = multiply,
}
 end, _env("RemoteSpy.util.number-util"))() end)

_module("withCollection", "ModuleScript", "RemoteSpy.util.withCollection", "RemoteSpy.util", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function withCollection(component, collection)
	for k, v in pairs(collection) do
		component[k] = v
	end
	return component
end
return {
	default = withCollection,
}
 end, _env("RemoteSpy.util.withCollection"))() end)

_instance("utils", "Folder", "RemoteSpy.utils", "RemoteSpy")

_module("codify", "ModuleScript", "RemoteSpy.utils.codify", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local _instance_util = TS.import(script, script.Parent, "instance-util")
local getInstancePath = _instance_util.getInstancePath
local isInstanceInDataModel = _instance_util.isInstanceInDataModel
local codifyTableFlat, codifyTable, codify
local createTransformers = function(context)
	return {
		table = function(value, level)
			return if level == -1 then codifyTableFlat(value, context) else codifyTable(value, level + 1, context)
		end,
		string = function(value)
			return string.format("%q", (string.gsub(value, "\n", "\\n")))
		end,
		number = function(value)
			return tostring(value)
		end,
		boolean = function(value)
			return tostring(value)
		end,
		Instance = function(value)
			if isInstanceInDataModel(value) then
				return getInstancePath(value, context.pathNotation)
			else
				local parent = value.Parent
				local parentStr = if parent then codify(parent, 0, context) else "nil"
				return "Instance.new(" .. (string.format("%q", value.ClassName) .. (", " .. (parentStr .. ")")))
			end
		end,
		BrickColor = function(value)
			return 'BrickColor.new("' .. (value.Name .. '")')
		end,
		Color3 = function(value)
			return "Color3.new(" .. (tostring(value.R) .. (", " .. (tostring(value.G) .. (", " .. (tostring(value.B) .. ")")))))
		end,
		ColorSequenceKeypoint = function(value, level, context)
			return "ColorSequenceKeypoint.new(" .. (tostring(value.Time) .. (", " .. (codify(value.Value, level, context) .. ")")))
		end,
		ColorSequence = function(value, level, context)
			return "ColorSequence.new(" .. (codify(value.Keypoints, level, context) .. ")")
		end,
		NumberRange = function(value)
			return "NumberRange.new(" .. (tostring(value.Min) .. (", " .. (tostring(value.Max) .. ")")))
		end,
		NumberSequenceKeypoint = function(value, level, context)
			return "NumberSequenceKeypoint.new(" .. (tostring(value.Time) .. (", " .. (codify(value.Value, level, context) .. ")")))
		end,
		NumberSequence = function(value, level, context)
			return "NumberSequence.new(" .. (codify(value.Keypoints, level, context) .. ")")
		end,
		Vector3 = function(value)
			return "Vector3.new(" .. (tostring(value.X) .. (", " .. (tostring(value.Y) .. (", " .. (tostring(value.Z) .. ")")))))
		end,
		Vector2 = function(value)
			return "Vector2.new(" .. (tostring(value.X) .. (", " .. (tostring(value.Y) .. ")")))
		end,
		UDim2 = function(value)
			return "UDim2.new(" .. (tostring(value.X.Scale) .. (", " .. (tostring(value.X.Offset) .. (", " .. (tostring(value.Y.Scale) .. (", " .. (tostring(value.Y.Offset) .. ")")))))))
		end,
		Ray = function(value, level, context)
			return "Ray.new(" .. (codify(value.Origin, level, context) .. (", " .. (codify(value.Direction, level, context) .. ")")))
		end,
		CFrame = function(value)
			return "CFrame.new(" .. (table.concat({ value:GetComponents() }, ", ") .. ")")
		end,
	}
end
function codify(value, level, context)
	if level == nil then
		level = 0
	end
	if context == nil then
		context = {
			pathNotation = "dot",
		}
	end
	local transformers = createTransformers(context)
	local transformer = transformers[typeof(value)]
	if transformer then
		return transformer(value, level, context)
	else
		return tostring(value) .. (" --[[" .. (typeof(value) .. " not supported]]"))
	end
end
function codifyTable(object, level, context)
	if level == nil then
		level = 0
	end
	if context == nil then
		context = {
			pathNotation = "dot",
		}
	end
	local lines = {}
	local indent = string.rep("	", level + 1)
	local isArray = true
	local maxIndex = 0
	local entries = {}
	for key, value in pairs(object) do
		if type(value) == "function" or type(value) == "thread" then
			continue
		end
		local _arg0 = { key, value }
		table.insert(entries, _arg0)
		if type(key) == "number" then
			local numKey = key
			if numKey > maxIndex then
				maxIndex = numKey
			end
		else
			isArray = false
		end
	end
	if isArray and #entries > 0 then
		do
			local i = 1
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= maxIndex) then
					break
				end
				local found = false
				for _, _binding in ipairs(entries) do
					local key = _binding[1]
					if key == i then
						found = true
						break
					end
				end
				if not found then
					isArray = false
					break
				end
			end
		end
	end
	if isArray and #entries > 0 then
		local _arg0 = function(a, b)
			return (a[1]) < (b[1])
		end
		table.sort(entries, _arg0)
		local sortedEntries = entries
		for _, _binding in ipairs(sortedEntries) do
			local _ = _binding[1]
			local value = _binding[2]
			local _arg0_1 = indent .. codify(value, level, context)
			table.insert(lines, _arg0_1)
		end
		if #lines == 0 then
			return "{}"
		end
		return "{\n" .. (table.concat(lines, ",\n") .. ("\n" .. (string.sub(indent, 1, -2) .. "}")))
	end
	for _, _binding in ipairs(entries) do
		local key = _binding[1]
		local value = _binding[2]
		local _arg0 = indent .. ("[" .. (codify(key, level, context) .. ("] = " .. codify(value, level, context))))
		table.insert(lines, _arg0)
	end
	if #lines == 0 then
		return "{}"
	end
	return "{\n" .. (table.concat(lines, ",\n") .. ("\n" .. (string.sub(indent, 1, -2) .. "}")))
end
function codifyTableFlat(object, context)
	if context == nil then
		context = {
			pathNotation = "dot",
		}
	end
	local lines = {}
	local isArray = true
	local maxIndex = 0
	local entries = {}
	for key, value in pairs(object) do
		if type(value) == "function" or type(value) == "thread" then
			continue
		end
		local _arg0 = { key, value }
		table.insert(entries, _arg0)
		if type(key) == "number" then
			local numKey = key
			if numKey > maxIndex then
				maxIndex = numKey
			end
		else
			isArray = false
		end
	end
	if isArray and #entries > 0 then
		do
			local i = 1
			local _shouldIncrement = false
			while true do
				if _shouldIncrement then
					i += 1
				else
					_shouldIncrement = true
				end
				if not (i <= maxIndex) then
					break
				end
				local found = false
				for _, _binding in ipairs(entries) do
					local key = _binding[1]
					if key == i then
						found = true
						break
					end
				end
				if not found then
					isArray = false
					break
				end
			end
		end
	end
	if isArray and #entries > 0 then
		local _arg0 = function(a, b)
			return (a[1]) < (b[1])
		end
		table.sort(entries, _arg0)
		local sortedEntries = entries
		for _, _binding in ipairs(sortedEntries) do
			local _ = _binding[1]
			local value = _binding[2]
			local _arg0_1 = codify(value, -1, context)
			table.insert(lines, _arg0_1)
		end
		if #lines == 0 then
			return "{}"
		end
		return "{ " .. (table.concat(lines, ", ") .. " }")
	end
	for _, _binding in ipairs(entries) do
		local key = _binding[1]
		local value = _binding[2]
		local _arg0 = "[" .. (codify(key, -1, context) .. ("] = " .. codify(value, -1, context)))
		table.insert(lines, _arg0)
	end
	if #lines == 0 then
		return "{}"
	end
	return "{ " .. (table.concat(lines, ", ") .. " }")
end
return {
	codify = codify,
	codifyTable = codifyTable,
	codifyTableFlat = codifyTableFlat,
}
 end, _env("RemoteSpy.utils.codify"))() end)

_module("format-escapes", "ModuleScript", "RemoteSpy.utils.format-escapes", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function formatEscapes(str)
	return (string.gsub(str, "[\n\r\t]+", " "))
end
return {
	formatEscapes = formatEscapes,
}
 end, _env("RemoteSpy.utils.format-escapes"))() end)

_module("function-util", "ModuleScript", "RemoteSpy.utils.function-util", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function describeFunction(fn)
	if debug.getinfo then
		local info = debug.getinfo(fn)
		local _object = {
			name = if info.name == "" or info.name == nil then "(anonymous)" else info.name,
			source = info.short_src,
		}
		local _left = "parameters"
		local _condition = info.numparams
		if _condition == nil then
			_condition = 0
		end
		_object[_left] = _condition
		_object.variadic = if info.is_vararg == 1 then true else false
		return _object
	end
	local name = debug.info(fn, "n")
	local source = debug.info(fn, "s")
	local parameters, variadic = debug.info(fn, "a")
	return {
		name = if name == "" or name == nil then "(anonymous)" else name,
		source = source,
		parameters = parameters,
		variadic = variadic,
	}
end
local function getFunctionScript(fn)
	return rawget(getfenv(fn), "script")
end
local function stringifyFunctionSignature(fn)
	local description = describeFunction(fn)
	local params = {}
	do
		local i = 0
		local _shouldIncrement = false
		while true do
			if _shouldIncrement then
				i += 1
			else
				_shouldIncrement = true
			end
			if not (i < description.parameters) then
				break
			end
			local _arg0 = string.char((string.byte("A")) + i)
			table.insert(params, _arg0)
		end
	end
	if description.variadic then
		table.insert(params, "...")
	end
	return description.name .. ("(" .. (table.concat(params, ", ") .. ")"))
end
return {
	describeFunction = describeFunction,
	getFunctionScript = getFunctionScript,
	stringifyFunctionSignature = stringifyFunctionSignature,
}
 end, _env("RemoteSpy.utils.function-util"))() end)

_module("gen-script", "ModuleScript", "RemoteSpy.utils.gen-script", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local codifyTable = TS.import(script, script.Parent, "codify").codifyTable
local getInstancePath = TS.import(script, script.Parent, "instance-util").getInstancePath
local function genScript(remote, args, pathNotation)
	if pathNotation == nil then
		pathNotation = "dot"
	end
	local gen = ""
	local hasArgs = (next(args)) ~= nil
	if hasArgs then
		gen = "local args = " .. (codifyTable(args, 0, {
			pathNotation = pathNotation,
		}) .. "\n\n")
	end
	gen ..= "local remote = " .. (getInstancePath(remote, pathNotation) .. "\n")
	if remote:IsA("RemoteEvent") then
		if hasArgs then
			gen ..= "remote:FireServer(unpack(args))"
		else
			gen ..= "remote:FireServer()"
		end
	elseif remote:IsA("RemoteFunction") then
		if hasArgs then
			gen ..= "local result = remote:InvokeServer(unpack(args))"
		else
			gen ..= "local result = remote:InvokeServer()"
		end
	elseif remote:IsA("BindableEvent") then
		if hasArgs then
			gen ..= "remote:Fire(unpack(args))"
		else
			gen ..= "remote:Fire()"
		end
	elseif remote:IsA("BindableFunction") then
		if hasArgs then
			gen ..= "local result = remote:Invoke(unpack(args))"
		else
			gen ..= "local result = remote:Invoke()"
		end
	end
	return gen
end
return {
	genScript = genScript,
}
 end, _env("RemoteSpy.utils.gen-script"))() end)

_module("global-util", "ModuleScript", "RemoteSpy.utils.global-util", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local globals = if getgenv then getgenv() else {}
local function getGlobals()
	return globals
end
local function setGlobal(key, value)
	globals[key] = value
end
local function getGlobal(key)
	return globals[key]
end
local function hasGlobal(key)
	return globals[key] ~= nil
end
return {
	getGlobals = getGlobals,
	setGlobal = setGlobal,
	getGlobal = getGlobal,
	hasGlobal = hasGlobal,
}
 end, _env("RemoteSpy.utils.global-util"))() end)

_module("instance-util", "ModuleScript", "RemoteSpy.utils.instance-util", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local idsByObject = {}
local objectsById = {}
local nextId = 0
local hasSpecialCharacters = function(str)
	return (string.match(str, "[a-zA-Z0-9_]+")) ~= str
end
local function isInstanceInDataModel(object)
	local current = object
	while current do
		if current == game then
			return true
		end
		current = current.Parent
	end
	return false
end
local function getInstanceId(object)
	if not (idsByObject[object] ~= nil) then
		local _original = nextId
		nextId += 1
		local id = "instance-" .. tostring(_original)
		idsByObject[object] = id
		objectsById[id] = object
	end
	return idsByObject[object]
end
local function getInstanceFromId(id)
	return objectsById[id]
end
local function getInstancePath(object, notation)
	if notation == nil then
		notation = "dot"
	end
	local path = ""
	local current = object
	local isInDataModel = false
	local isFirst = true
	repeat
		do
			if current == game then
				path = "game" .. path
				isInDataModel = true
			elseif current.Parent == game then
				path = ":GetService(" .. (string.format("%q", current.ClassName) .. (")" .. path))
			else
				if notation == "dot" then
					path = if hasSpecialCharacters(current.Name) then "[" .. (string.format("%q", current.Name) .. ("]" .. path)) else "." .. (current.Name .. path)
				elseif notation == "waitforchild" then
					local nameStr = string.format("%q", current.Name)
					path = if isFirst then ":WaitForChild(" .. (nameStr .. (")" .. path)) else ":WaitForChild(" .. (nameStr .. (")" .. path))
				elseif notation == "findfirstchild" then
					local nameStr = string.format("%q", current.Name)
					path = if isFirst then ":FindFirstChild(" .. (nameStr .. (")" .. path)) else ":FindFirstChild(" .. (nameStr .. (")" .. path))
				end
				isFirst = false
			end
			current = current.Parent
		end
	until not current
	if not isInDataModel then
		path = "(nil)" .. path
	end
	path = string.gsub(path, '^game:GetService%("Workspace"%)', "workspace")
	return path
end
return {
	isInstanceInDataModel = isInstanceInDataModel,
	getInstanceId = getInstanceId,
	getInstanceFromId = getInstanceFromId,
	getInstancePath = getInstancePath,
}
 end, _env("RemoteSpy.utils.instance-util"))() end)

_module("notify", "ModuleScript", "RemoteSpy.utils.notify", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function notify(message, lifetime, isError)
	if lifetime == nil then
		lifetime = 3
	end
	if isError == nil then
		isError = false
	end
	if Utility ~= nil and (typeof(Utility) == "table" and Utility.UtilityNotify ~= nil) then
		Utility.UtilityNotify(isError, message, lifetime)
		return nil
	end
	local StarterGui = game:GetService("StarterGui")
	StarterGui:SetCore("SendNotification", {
		Title = if isError then "Error" else "Wavified Spy",
		Text = message,
		Duration = lifetime,
	})
end
return {
	notify = notify,
}
 end, _env("RemoteSpy.utils.notify"))() end)

_module("number-util", "ModuleScript", "RemoteSpy.utils.number-util", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function map(n, min0, max0, min1, max1)
	return min1 + ((n - min0) * (max1 - min1)) / (max0 - min0)
end
local function mapStrict(n, min0, max0, min1, max1)
	return math.clamp(min1 + ((n - min0) * (max1 - min1)) / (max0 - min0), min1, max1)
end
local function lerp(a, b, t)
	return a + (b - a) * t
end
local function multiply(n, ...)
	local args = { ... }
	local _arg0 = function(a, b)
		return 1 - (1 - a) * (1 - b)
	end
	-- ▼ ReadonlyArray.reduce ▼
	local _result = n
	local _callback = _arg0
	for _i = 1, #args do
		_result = _callback(_result, args[_i], _i - 1, args)
	end
	-- ▲ ReadonlyArray.reduce ▲
	return _result
end
return {
	map = map,
	mapStrict = mapStrict,
	lerp = lerp,
	multiply = multiply,
}
 end, _env("RemoteSpy.utils.number-util"))() end)

_module("script-tab-util", "ModuleScript", "RemoteSpy.utils.script-tab-util", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local TabType = TS.import(script, script.Parent.Parent, "reducers", "tab-group").TabType
local function generateUniqueScriptName(baseName, existingTabs)
	local _arg0 = function(tab)
		if tab.type ~= TabType.Script then
			return false
		end
		local _caption = tab.caption
		local _arg0_1 = "^" .. (baseName .. "( - \\d+)?$")
		local match = { string.match(_caption, _arg0_1) }
		return match ~= nil and match[1] ~= nil
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(existingTabs) do
		if _arg0(_v, _k - 1, existingTabs) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	local scriptTabs = _newValue
	if #scriptTabs == 0 then
		return baseName
	end
	local maxIndex = 0
	for _, tab in ipairs(scriptTabs) do
		local _caption = tab.caption
		local _arg0_1 = "^" .. (baseName .. " - (\\d+)$")
		local match = { string.match(_caption, _arg0_1) }
		if match ~= nil and (match[1] ~= nil and match[2] ~= nil) then
			local index = tonumber(match[2])
			if index ~= nil and index > maxIndex then
				maxIndex = index
			end
		elseif tab.caption == baseName then
			maxIndex = math.max(maxIndex, 1)
		end
	end
	return baseName .. (" - " .. tostring(maxIndex + 1))
end
return {
	generateUniqueScriptName = generateUniqueScriptName,
}
 end, _env("RemoteSpy.utils.script-tab-util"))() end)

_module("settings-persistence", "ModuleScript", "RemoteSpy.utils.settings-persistence", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = require(script.Parent.Parent.include.RuntimeLib)
local SETTINGS_FILE = "wavified_spy_settings.json"
local function saveSettings(settings)
	if not writefile then
		return nil
	end
	TS.try(function()
		local json = game:GetService("HttpService"):JSONEncode(settings)
		writefile(SETTINGS_FILE, json)
	end, function(err)
		warn("Failed to save settings:", err)
	end)
end
local function loadSettings()
	if not readfile then
		return nil
	end
	local _exitType, _returns = TS.try(function()
		local content = readfile(SETTINGS_FILE)
		local settings = game:GetService("HttpService"):JSONDecode(content)
		return TS.TRY_RETURN, { settings }
	end, function(err)
		return TS.TRY_RETURN, { nil }
	end)
	if _exitType then
		return unpack(_returns)
	end
end
return {
	saveSettings = saveSettings,
	loadSettings = loadSettings,
}
 end, _env("RemoteSpy.utils.settings-persistence"))() end)

_module("syntax-highlight", "ModuleScript", "RemoteSpy.utils.syntax-highlight", "RemoteSpy.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local KEYWORDS = { "and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while" }
local BUILTIN_FUNCTIONS = { "print", "warn", "error", "assert", "type", "typeof", "pcall", "xpcall", "ipairs", "pairs", "next", "select", "tonumber", "tostring", "getmetatable", "setmetatable", "rawget", "rawset", "rawequal", "unpack", "task", "wait", "spawn", "delay", "game", "workspace", "FireServer", "InvokeServer", "FindFirstChild", "WaitForChild" }
local COLORS = {
	keyword = "86, 156, 214",
	string = "206, 145, 120",
	number = "181, 206, 168",
	comment = "106, 153, 85",
	["function"] = "220, 220, 170",
	builtin = "78, 201, 176",
	operator = "212, 212, 212",
	default = "212, 212, 212",
}
local function escapeRichText(text)
	local result = (string.gsub(text, "&", "&amp;"))
	result = (string.gsub(result, "<", "&lt;"))
	result = (string.gsub(result, ">", "&gt;"))
	return result
end
local function highlightLua(code)
	local result = ""
	local pos = 1
	while pos <= #code do
		local _pos = pos
		local _pos_1 = pos
		local char = string.sub(code, _pos, _pos_1)
		local _condition = char == "-"
		if _condition then
			local _arg0 = pos + 1
			local _arg1 = pos + 1
			_condition = string.sub(code, _arg0, _arg1) == "-"
		end
		if _condition then
			local _pos_2 = pos
			local endOfLine = string.find(code, "\n", _pos_2)
			local lineEnd = if endOfLine ~= nil then endOfLine - 1 else #code
			local _pos_3 = pos
			local comment = string.sub(code, _pos_3, lineEnd)
			result ..= '<font color="rgb(' .. (COLORS.comment .. (')">' .. (escapeRichText(comment) .. "</font>")))
			pos = lineEnd + 1
			continue
		end
		if char == '"' then
			local endPos = pos + 1
			local escaped = false
			while endPos <= #code do
				local _endPos = endPos
				local _endPos_1 = endPos
				local c = string.sub(code, _endPos, _endPos_1)
				if c == "\\" and not escaped then
					escaped = true
				elseif c == '"' and not escaped then
					break
				else
					escaped = false
				end
				endPos += 1
			end
			local _pos_2 = pos
			local _endPos = endPos
			local str = string.sub(code, _pos_2, _endPos)
			result ..= '<font color="rgb(' .. (COLORS.string .. (')">' .. (escapeRichText(str) .. "</font>")))
			pos = endPos + 1
			continue
		end
		if char == "'" then
			local endPos = pos + 1
			local escaped = false
			while endPos <= #code do
				local _endPos = endPos
				local _endPos_1 = endPos
				local c = string.sub(code, _endPos, _endPos_1)
				if c == "\\" and not escaped then
					escaped = true
				elseif c == "'" and not escaped then
					break
				else
					escaped = false
				end
				endPos += 1
			end
			local _pos_2 = pos
			local _endPos = endPos
			local str = string.sub(code, _pos_2, _endPos)
			result ..= '<font color="rgb(' .. (COLORS.string .. (')">' .. (escapeRichText(str) .. "</font>")))
			pos = endPos + 1
			continue
		end
		local isDigit = string.match(char, "%d")
		local _arg0 = pos + 1
		local _arg1 = pos + 1
		local nextChar = string.sub(code, _arg0, _arg1)
		local nextIsDigit = string.match(nextChar, "%d")
		if isDigit ~= nil or (char == "." and nextIsDigit ~= nil) then
			local endPos = pos
			while endPos <= #code do
				local _endPos = endPos
				local _endPos_1 = endPos
				local c = string.sub(code, _endPos, _endPos_1)
				local isNumChar = string.match(c, "[%d%.]")
				if isNumChar == nil then
					break
				end
				endPos += 1
			end
			local _pos_2 = pos
			local _arg1_1 = endPos - 1
			local num = string.sub(code, _pos_2, _arg1_1)
			result ..= '<font color="rgb(' .. (COLORS.number .. (')">' .. (num .. "</font>")))
			pos = endPos
			continue
		end
		local isAlpha = string.match(char, "[%a_]")
		if isAlpha ~= nil then
			local endPos = pos
			while endPos <= #code do
				local _endPos = endPos
				local _endPos_1 = endPos
				local c = string.sub(code, _endPos, _endPos_1)
				local isWordChar = string.match(c, "[%w_]")
				if isWordChar == nil then
					break
				end
				endPos += 1
			end
			local _pos_2 = pos
			local _arg1_1 = endPos - 1
			local word = string.sub(code, _pos_2, _arg1_1)
			if table.find(KEYWORDS, word) ~= nil then
				result ..= '<font color="rgb(' .. (COLORS.keyword .. (')">' .. (word .. "</font>")))
			elseif table.find(BUILTIN_FUNCTIONS, word) ~= nil then
				result ..= '<font color="rgb(' .. (COLORS.builtin .. (')">' .. (word .. "</font>")))
			else
				local checkPos = endPos
				while checkPos <= #code do
					local _checkPos = checkPos
					local _checkPos_1 = checkPos
					local c = string.sub(code, _checkPos, _checkPos_1)
					local isSpace = string.match(c, "%s")
					if isSpace == nil then
						break
					end
					checkPos += 1
				end
				local _checkPos = checkPos
				local _checkPos_1 = checkPos
				if string.sub(code, _checkPos, _checkPos_1) == "(" then
					result ..= '<font color="rgb(' .. (COLORS["function"] .. (')">' .. (word .. "</font>")))
				else
					result ..= '<font color="rgb(' .. (COLORS.default .. (')">' .. (word .. "</font>")))
				end
			end
			pos = endPos
			continue
		end
		result ..= escapeRichText(char)
		pos += 1
	end
	return result
end
return {
	highlightLua = highlightLua,
}
 end, _env("RemoteSpy.utils.syntax-highlight"))() end)

_instance("include", "Folder", "RemoteSpy.include", "RemoteSpy")

_module("Promise", "ModuleScript", "RemoteSpy.include.Promise", "RemoteSpy.include", function () return setfenv(function() --[[
	An implementation of Promises similar to Promise/A+.
]]

local ERROR_NON_PROMISE_IN_LIST = "Non-promise value passed into %s at index %s"
local ERROR_NON_LIST = "Please pass a list of promises to %s"
local ERROR_NON_FUNCTION = "Please pass a handler function to %s!"
local MODE_KEY_METATABLE = { __mode = "k" }

local function isCallable(value)
	if type(value) == "function" then
		return true
	end

	if type(value) == "table" then
		local metatable = getmetatable(value)
		if metatable and type(rawget(metatable, "__call")) == "function" then
			return true
		end
	end

	return false
end

--[[
	Creates an enum dictionary with some metamethods to prevent common mistakes.
]]
local function makeEnum(enumName, members)
	local enum = {}

	for _, memberName in ipairs(members) do
		enum[memberName] = memberName
	end

	return setmetatable(enum, {
		__index = function(_, k)
			error(string.format("%s is not in %s!", k, enumName), 2)
		end,
		__newindex = function()
			error(string.format("Creating new members in %s is not allowed!", enumName), 2)
		end,
	})
end

--[=[
	An object to represent runtime errors that occur during execution.
	Promises that experience an error like this will be rejected with
	an instance of this object.

	@class Error
]=]
local Error
do
	Error = {
		Kind = makeEnum("Promise.Error.Kind", {
			"ExecutionError",
			"AlreadyCancelled",
			"NotResolvedInTime",
			"TimedOut",
		}),
	}
	Error.__index = Error

	function Error.new(options, parent)
		options = options or {}
		return setmetatable({
			error = tostring(options.error) or "[This error has no error text.]",
			trace = options.trace,
			context = options.context,
			kind = options.kind,
			parent = parent,
			createdTick = os.clock(),
			createdTrace = debug.traceback(),
		}, Error)
	end

	function Error.is(anything)
		if type(anything) == "table" then
			local metatable = getmetatable(anything)

			if type(metatable) == "table" then
				return rawget(anything, "error") ~= nil and type(rawget(metatable, "extend")) == "function"
			end
		end

		return false
	end

	function Error.isKind(anything, kind)
		assert(kind ~= nil, "Argument #2 to Promise.Error.isKind must not be nil")

		return Error.is(anything) and anything.kind == kind
	end

	function Error:extend(options)
		options = options or {}

		options.kind = options.kind or self.kind

		return Error.new(options, self)
	end

	function Error:getErrorChain()
		local runtimeErrors = { self }

		while runtimeErrors[#runtimeErrors].parent do
			table.insert(runtimeErrors, runtimeErrors[#runtimeErrors].parent)
		end

		return runtimeErrors
	end

	function Error:__tostring()
		local errorStrings = {
			string.format("-- Promise.Error(%s) --", self.kind or "?"),
		}

		for _, runtimeError in ipairs(self:getErrorChain()) do
			table.insert(
				errorStrings,
				table.concat({
					runtimeError.trace or runtimeError.error,
					runtimeError.context,
				}, "\n")
			)
		end

		return table.concat(errorStrings, "\n")
	end
end

--[[
	Packs a number of arguments into a table and returns its length.

	Used to cajole varargs without dropping sparse values.
]]
local function pack(...)
	return select("#", ...), { ... }
end

--[[
	Returns first value (success), and packs all following values.
]]
local function packResult(success, ...)
	return success, select("#", ...), { ... }
end

local function makeErrorHandler(traceback)
	assert(traceback ~= nil, "traceback is nil")

	return function(err)
		-- If the error object is already a table, forward it directly.
		-- Should we extend the error here and add our own trace?

		if type(err) == "table" then
			return err
		end

		return Error.new({
			error = err,
			kind = Error.Kind.ExecutionError,
			trace = debug.traceback(tostring(err), 2),
			context = "Promise created at:\n\n" .. traceback,
		})
	end
end

--[[
	Calls a Promise executor with error handling.
]]
local function runExecutor(traceback, callback, ...)
	return packResult(xpcall(callback, makeErrorHandler(traceback), ...))
end

--[[
	Creates a function that invokes a callback with correct error handling and
	resolution mechanisms.
]]
local function createAdvancer(traceback, callback, resolve, reject)
	return function(...)
		local ok, resultLength, result = runExecutor(traceback, callback, ...)

		if ok then
			resolve(unpack(result, 1, resultLength))
		else
			reject(result[1])
		end
	end
end

local function isEmpty(t)
	return next(t) == nil
end

--[=[
	An enum value used to represent the Promise's status.
	@interface Status
	@tag enum
	@within Promise
	.Started "Started" -- The Promise is executing, and not settled yet.
	.Resolved "Resolved" -- The Promise finished successfully.
	.Rejected "Rejected" -- The Promise was rejected.
	.Cancelled "Cancelled" -- The Promise was cancelled before it finished.
]=]
--[=[
	@prop Status Status
	@within Promise
	@readonly
	@tag enums
	A table containing all members of the `Status` enum, e.g., `Promise.Status.Resolved`.
]=]
--[=[
	A Promise is an object that represents a value that will exist in the future, but doesn't right now.
	Promises allow you to then attach callbacks that can run once the value becomes available (known as *resolving*),
	or if an error has occurred (known as *rejecting*).

	@class Promise
	@__index prototype
]=]
local Promise = {
	Error = Error,
	Status = makeEnum("Promise.Status", { "Started", "Resolved", "Rejected", "Cancelled" }),
	_getTime = os.clock,
	_timeEvent = game:GetService("RunService").Heartbeat,
	_unhandledRejectionCallbacks = {},
}
Promise.prototype = {}
Promise.__index = Promise.prototype

function Promise._new(traceback, callback, parent)
	if parent ~= nil and not Promise.is(parent) then
		error("Argument #2 to Promise.new must be a promise or nil", 2)
	end

	local self = {
		-- Used to locate where a promise was created
		_source = traceback,

		_status = Promise.Status.Started,

		-- A table containing a list of all results, whether success or failure.
		-- Only valid if _status is set to something besides Started
		_values = nil,

		-- Lua doesn't like sparse arrays very much, so we explicitly store the
		-- length of _values to handle middle nils.
		_valuesLength = -1,

		-- Tracks if this Promise has no error observers..
		_unhandledRejection = true,

		-- Queues representing functions we should invoke when we update!
		_queuedResolve = {},
		_queuedReject = {},
		_queuedFinally = {},

		-- The function to run when/if this promise is cancelled.
		_cancellationHook = nil,

		-- The "parent" of this promise in a promise chain. Required for
		-- cancellation propagation upstream.
		_parent = parent,

		-- Consumers are Promises that have chained onto this one.
		-- We track them for cancellation propagation downstream.
		_consumers = setmetatable({}, MODE_KEY_METATABLE),
	}

	if parent and parent._status == Promise.Status.Started then
		parent._consumers[self] = true
	end

	setmetatable(self, Promise)

	local function resolve(...)
		self:_resolve(...)
	end

	local function reject(...)
		self:_reject(...)
	end

	local function onCancel(cancellationHook)
		if cancellationHook then
			if self._status == Promise.Status.Cancelled then
				cancellationHook()
			else
				self._cancellationHook = cancellationHook
			end
		end

		return self._status == Promise.Status.Cancelled
	end

	coroutine.wrap(function()
		local ok, _, result = runExecutor(self._source, callback, resolve, reject, onCancel)

		if not ok then
			reject(result[1])
		end
	end)()

	return self
end

--[=[
	Construct a new Promise that will be resolved or rejected with the given callbacks.

	If you `resolve` with a Promise, it will be chained onto.

	You can safely yield within the executor function and it will not block the creating thread.

	```lua
	local myFunction()
		return Promise.new(function(resolve, reject, onCancel)
			wait(1)
			resolve("Hello world!")
		end)
	end

	myFunction():andThen(print)
	```

	You do not need to use `pcall` within a Promise. Errors that occur during execution will be caught and turned into a rejection automatically. If `error()` is called with a table, that table will be the rejection value. Otherwise, string errors will be converted into `Promise.Error(Promise.Error.Kind.ExecutionError)` objects for tracking debug information.

	You may register an optional cancellation hook by using the `onCancel` argument:

	* This should be used to abort any ongoing operations leading up to the promise being settled.
	* Call the `onCancel` function with a function callback as its only argument to set a hook which will in turn be called when/if the promise is cancelled.
	* `onCancel` returns `true` if the Promise was already cancelled when you called `onCancel`.
	* Calling `onCancel` with no argument will not override a previously set cancellation hook, but it will still return `true` if the Promise is currently cancelled.
	* You can set the cancellation hook at any time before resolving.
	* When a promise is cancelled, calls to `resolve` or `reject` will be ignored, regardless of if you set a cancellation hook or not.

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.new(executor)
	return Promise._new(debug.traceback(nil, 2), executor)
end

function Promise:__tostring()
	return string.format("Promise(%s)", self._status)
end

--[=[
	The same as [Promise.new](/api/Promise#new), except execution begins after the next `Heartbeat` event.

	This is a spiritual replacement for `spawn`, but it does not suffer from the same [issues](https://eryn.io/gist/3db84579866c099cdd5bb2ff37947cec) as `spawn`.

	```lua
	local function waitForChild(instance, childName, timeout)
	  return Promise.defer(function(resolve, reject)
		local child = instance:WaitForChild(childName, timeout)

		;(child and resolve or reject)(child)
	  end)
	end
	```

	@param executor (resolve: (...: any) -> (), reject: (...: any) -> (), onCancel: (abortHandler?: () -> ()) -> boolean) -> ()
	@return Promise
]=]
function Promise.defer(executor)
	local traceback = debug.traceback(nil, 2)
	local promise
	promise = Promise._new(traceback, function(resolve, reject, onCancel)
		local connection
		connection = Promise._timeEvent:Connect(function()
			connection:Disconnect()
			local ok, _, result = runExecutor(traceback, executor, resolve, reject, onCancel)

			if not ok then
				reject(result[1])
			end
		end)
	end)

	return promise
end

-- Backwards compatibility
Promise.async = Promise.defer

--[=[
	Creates an immediately resolved Promise with the given value.

	```lua
	-- Example using Promise.resolve to deliver cached values:
	function getSomething(name)
		if cache[name] then
			return Promise.resolve(cache[name])
		else
			return Promise.new(function(resolve, reject)
				local thing = getTheThing()
				cache[name] = thing

				resolve(thing)
			end)
		end
	end
	```

	@param ... any
	@return Promise<...any>
]=]
function Promise.resolve(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(resolve)
		resolve(unpack(values, 1, length))
	end)
end

--[=[
	Creates an immediately rejected Promise with the given value.

	:::caution
	Something needs to consume this rejection (i.e. `:catch()` it), otherwise it will emit an unhandled Promise rejection warning on the next frame. Thus, you should not create and store rejected Promises for later use. Only create them on-demand as needed.
	:::

	@param ... any
	@return Promise<...any>
]=]
function Promise.reject(...)
	local length, values = pack(...)
	return Promise._new(debug.traceback(nil, 2), function(_, reject)
		reject(unpack(values, 1, length))
	end)
end

--[[
	Runs a non-promise-returning function as a Promise with the
  given arguments.
]]
function Promise._try(traceback, callback, ...)
	local valuesLength, values = pack(...)

	return Promise._new(traceback, function(resolve)
		resolve(callback(unpack(values, 1, valuesLength)))
	end)
end

--[=[
	Begins a Promise chain, calling a function and returning a Promise resolving with its return value. If the function errors, the returned Promise will be rejected with the error. You can safely yield within the Promise.try callback.

	:::info
	`Promise.try` is similar to [Promise.promisify](#promisify), except the callback is invoked immediately instead of returning a new function.
	:::

	```lua
	Promise.try(function()
		return math.random(1, 2) == 1 and "ok" or error("Oh an error!")
	end)
		:andThen(function(text)
			print(text)
		end)
		:catch(function(err)
			warn("Something went wrong")
		end)
	```

	@param callback (...: T...) -> ...any
	@param ... T... -- Additional arguments passed to `callback`
	@return Promise
]=]
function Promise.try(callback, ...)
	return Promise._try(debug.traceback(nil, 2), callback, ...)
end

--[[
	Returns a new promise that:
		* is resolved when all input promises resolve
		* is rejected if ANY input promises reject
]]
function Promise._all(traceback, promises, amount)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.all"), 3)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.all", tostring(i)), 3)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 or amount == 0 then
		return Promise.resolve({})
	end

	return Promise._new(traceback, function(resolve, reject, onCancel)
		-- An array to contain our resolved values from the given promises.
		local resolvedValues = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local resolvedCount = 0
		local rejectedCount = 0
		local done = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			if done then
				return
			end

			resolvedCount = resolvedCount + 1

			if amount == nil then
				resolvedValues[i] = ...
			else
				resolvedValues[resolvedCount] = ...
			end

			if resolvedCount >= (amount or #promises) then
				done = true
				resolve(resolvedValues)
				cancel()
			end
		end

		onCancel(cancel)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(function(...)
				resolveOne(i, ...)
			end, function(...)
				rejectedCount = rejectedCount + 1

				if amount == nil or #promises - rejectedCount < amount then
					cancel()
					done = true

					reject(...)
				end
			end)
		end

		if done then
			cancel()
		end
	end)
end

--[=[
	Accepts an array of Promises and returns a new promise that:
	* is resolved after all input promises resolve.
	* is rejected if *any* input promises reject.

	:::info
	Only the first return value from each promise will be present in the resulting array.
	:::

	After any input Promise rejects, all other input Promises that are still pending will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.all(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{T}>
]=]
function Promise.all(promises)
	return Promise._all(debug.traceback(nil, 2), promises)
end

--[=[
	Folds an array of values or promises into a single value. The array is traversed sequentially.

	The reducer function can return a promise or value directly. Each iteration receives the resolved value from the previous, and the first receives your defined initial value.

	The folding will stop at the first rejection encountered.
	```lua
	local basket = {"blueberry", "melon", "pear", "melon"}
	Promise.fold(basket, function(cost, fruit)
		if fruit == "blueberry" then
			return cost -- blueberries are free!
		else
			-- call a function that returns a promise with the fruit price
			return fetchPrice(fruit):andThen(function(fruitCost)
				return cost + fruitCost
			end)
		end
	end, 0)
	```

	@since v3.1.0
	@param list {T | Promise<T>}
	@param reducer (accumulator: U, value: T, index: number) -> U | Promise<U>
	@param initialValue U
]=]
function Promise.fold(list, reducer, initialValue)
	assert(type(list) == "table", "Bad argument #1 to Promise.fold: must be a table")
	assert(isCallable(reducer), "Bad argument #2 to Promise.fold: must be a function")

	local accumulator = Promise.resolve(initialValue)
	return Promise.each(list, function(resolvedElement, i)
		accumulator = accumulator:andThen(function(previousValueResolved)
			return reducer(previousValueResolved, resolvedElement, i)
		end)
	end):andThen(function()
		return accumulator
	end)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as `count` Promises are resolved from the input array. The resolved array values are in the order that the Promises resolved in. When this Promise resolves, all other pending Promises are cancelled if they have no other consumers.

	`count` 0 results in an empty array. The resultant array will never have more than `count` elements.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.some(promises, 2) -- Only resolves with first 2 promises to resolve
	```

	@param promises {Promise<T>}
	@param count number
	@return Promise<{T}>
]=]
function Promise.some(promises, count)
	assert(type(count) == "number", "Bad argument #2 to Promise.some: must be a number")

	return Promise._all(debug.traceback(nil, 2), promises, count)
end

--[=[
	Accepts an array of Promises and returns a Promise that is resolved as soon as *any* of the input Promises resolves. It will reject only if *all* input Promises reject. As soon as one Promises resolves, all other pending Promises are cancelled if they have no other consumers.

	Resolves directly with the value of the first resolved Promise. This is essentially [[Promise.some]] with `1` count, except the Promise resolves with the value directly instead of an array with one element.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.any(promises) -- Resolves with first value to resolve (only rejects if all 3 rejected)
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.any(promises)
	return Promise._all(debug.traceback(nil, 2), promises, 1):andThen(function(values)
		return values[1]
	end)
end

--[=[
	Accepts an array of Promises and returns a new Promise that resolves with an array of in-place Statuses when all input Promises have settled. This is equivalent to mapping `promise:finally` over the array of Promises.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.allSettled(promises)
	```

	@param promises {Promise<T>}
	@return Promise<{Status}>
]=]
function Promise.allSettled(promises)
	if type(promises) ~= "table" then
		error(string.format(ERROR_NON_LIST, "Promise.allSettled"), 2)
	end

	-- We need to check that each value is a promise here so that we can produce
	-- a proper error rather than a rejected promise with our error.
	for i, promise in pairs(promises) do
		if not Promise.is(promise) then
			error(string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.allSettled", tostring(i)), 2)
		end
	end

	-- If there are no values then return an already resolved promise.
	if #promises == 0 then
		return Promise.resolve({})
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		-- An array to contain our resolved values from the given promises.
		local fates = {}
		local newPromises = {}

		-- Keep a count of resolved promises because just checking the resolved
		-- values length wouldn't account for promises that resolve with nil.
		local finishedCount = 0

		-- Called when a single value is resolved and resolves if all are done.
		local function resolveOne(i, ...)
			finishedCount = finishedCount + 1

			fates[i] = ...

			if finishedCount >= #promises then
				resolve(fates)
			end
		end

		onCancel(function()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end)

		-- We can assume the values inside `promises` are all promises since we
		-- checked above.
		for i, promise in ipairs(promises) do
			newPromises[i] = promise:finally(function(...)
				resolveOne(i, ...)
			end)
		end
	end)
end

--[=[
	Accepts an array of Promises and returns a new promise that is resolved or rejected as soon as any Promise in the array resolves or rejects.

	:::warning
	If the first Promise to settle from the array settles with a rejection, the resulting Promise from `race` will reject.

	If you instead want to tolerate rejections, and only care about at least one Promise resolving, you should use [Promise.any](#any) or [Promise.some](#some) instead.
	:::

	All other Promises that don't win the race will be cancelled if they have no other consumers.

	```lua
	local promises = {
		returnsAPromise("example 1"),
		returnsAPromise("example 2"),
		returnsAPromise("example 3"),
	}

	return Promise.race(promises) -- Only returns 1st value to resolve or reject
	```

	@param promises {Promise<T>}
	@return Promise<T>
]=]
function Promise.race(promises)
	assert(type(promises) == "table", string.format(ERROR_NON_LIST, "Promise.race"))

	for i, promise in pairs(promises) do
		assert(Promise.is(promise), string.format(ERROR_NON_PROMISE_IN_LIST, "Promise.race", tostring(i)))
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local newPromises = {}
		local finished = false

		local function cancel()
			for _, promise in ipairs(newPromises) do
				promise:cancel()
			end
		end

		local function finalize(callback)
			return function(...)
				cancel()
				finished = true
				return callback(...)
			end
		end

		if onCancel(finalize(reject)) then
			return
		end

		for i, promise in ipairs(promises) do
			newPromises[i] = promise:andThen(finalize(resolve), finalize(reject))
		end

		if finished then
			cancel()
		end
	end)
end

--[=[
	Iterates serially over the given an array of values, calling the predicate callback on each value before continuing.

	If the predicate returns a Promise, we wait for that Promise to resolve before moving on to the next item
	in the array.

	:::info
	`Promise.each` is similar to `Promise.all`, except the Promises are ran in order instead of all at once.

	But because Promises are eager, by the time they are created, they're already running. Thus, we need a way to defer creation of each Promise until a later time.

	The predicate function exists as a way for us to operate on our data instead of creating a new closure for each Promise. If you would prefer, you can pass in an array of functions, and in the predicate, call the function and return its return value.
	:::

	```lua
	Promise.each({
		"foo",
		"bar",
		"baz",
		"qux"
	}, function(value, index)
		return Promise.delay(1):andThen(function()
		print(("%d) Got %s!"):format(index, value))
		end)
	end)

	--[[
		(1 second passes)
		> 1) Got foo!
		(1 second passes)
		> 2) Got bar!
		(1 second passes)
		> 3) Got baz!
		(1 second passes)
		> 4) Got qux!
	]]
	```

	If the Promise a predicate returns rejects, the Promise from `Promise.each` is also rejected with the same value.

	If the array of values contains a Promise, when we get to that point in the list, we wait for the Promise to resolve before calling the predicate with the value.

	If a Promise in the array of values is already Rejected when `Promise.each` is called, `Promise.each` rejects with that value immediately (the predicate callback will never be called even once). If a Promise in the list is already Cancelled when `Promise.each` is called, `Promise.each` rejects with `Promise.Error(Promise.Error.Kind.AlreadyCancelled`). If a Promise in the array of values is Started at first, but later rejects, `Promise.each` will reject with that value and iteration will not continue once iteration encounters that value.

	Returns a Promise containing an array of the returned/resolved values from the predicate for each item in the array of values.

	If this Promise returned from `Promise.each` rejects or is cancelled for any reason, the following are true:
	- Iteration will not continue.
	- Any Promises within the array of values will now be cancelled if they have no other consumers.
	- The Promise returned from the currently active predicate will be cancelled if it hasn't resolved yet.

	@since 3.0.0
	@param list {T | Promise<T>}
	@param predicate (value: T, index: number) -> U | Promise<U>
	@return Promise<{U}>
]=]
function Promise.each(list, predicate)
	assert(type(list) == "table", string.format(ERROR_NON_LIST, "Promise.each"))
	assert(isCallable(predicate), string.format(ERROR_NON_FUNCTION, "Promise.each"))

	return Promise._new(debug.traceback(nil, 2), function(resolve, reject, onCancel)
		local results = {}
		local promisesToCancel = {}

		local cancelled = false

		local function cancel()
			for _, promiseToCancel in ipairs(promisesToCancel) do
				promiseToCancel:cancel()
			end
		end

		onCancel(function()
			cancelled = true

			cancel()
		end)

		-- We need to preprocess the list of values and look for Promises.
		-- If we find some, we must register our andThen calls now, so that those Promises have a consumer
		-- from us registered. If we don't do this, those Promises might get cancelled by something else
		-- before we get to them in the series because it's not possible to tell that we plan to use it
		-- unless we indicate it here.

		local preprocessedList = {}

		for index, value in ipairs(list) do
			if Promise.is(value) then
				if value:getStatus() == Promise.Status.Cancelled then
					cancel()
					return reject(Error.new({
						error = "Promise is cancelled",
						kind = Error.Kind.AlreadyCancelled,
						context = string.format(
							"The Promise that was part of the array at index %d passed into Promise.each was already cancelled when Promise.each began.\n\nThat Promise was created at:\n\n%s",
							index,
							value._source
						),
					}))
				elseif value:getStatus() == Promise.Status.Rejected then
					cancel()
					return reject(select(2, value:await()))
				end

				-- Chain a new Promise from this one so we only cancel ours
				local ourPromise = value:andThen(function(...)
					return ...
				end)

				table.insert(promisesToCancel, ourPromise)
				preprocessedList[index] = ourPromise
			else
				preprocessedList[index] = value
			end
		end

		for index, value in ipairs(preprocessedList) do
			if Promise.is(value) then
				local success
				success, value = value:await()

				if not success then
					cancel()
					return reject(value)
				end
			end

			if cancelled then
				return
			end

			local predicatePromise = Promise.resolve(predicate(value, index))

			table.insert(promisesToCancel, predicatePromise)

			local success, result = predicatePromise:await()

			if not success then
				cancel()
				return reject(result)
			end

			results[index] = result
		end

		resolve(results)
	end)
end

--[=[
	Checks whether the given object is a Promise via duck typing. This only checks if the object is a table and has an `andThen` method.

	@param object any
	@return boolean -- `true` if the given `object` is a Promise.
]=]
function Promise.is(object)
	if type(object) ~= "table" then
		return false
	end

	local objectMetatable = getmetatable(object)

	if objectMetatable == Promise then
		-- The Promise came from this library.
		return true
	elseif objectMetatable == nil then
		-- No metatable, but we should still chain onto tables with andThen methods
		return isCallable(object.andThen)
	elseif
		type(objectMetatable) == "table"
		and type(rawget(objectMetatable, "__index")) == "table"
		and isCallable(rawget(rawget(objectMetatable, "__index"), "andThen"))
	then
		-- Maybe this came from a different or older Promise library.
		return true
	end

	return false
end

--[=[
	Wraps a function that yields into one that returns a Promise.

	Any errors that occur while executing the function will be turned into rejections.

	:::info
	`Promise.promisify` is similar to [Promise.try](#try), except the callback is returned as a callable function instead of being invoked immediately.
	:::

	```lua
	local sleep = Promise.promisify(wait)

	sleep(1):andThen(print)
	```

	```lua
	local isPlayerInGroup = Promise.promisify(function(player, groupId)
		return player:IsInGroup(groupId)
	end)
	```

	@param callback (...: any) -> ...any
	@return (...: any) -> Promise
]=]
function Promise.promisify(callback)
	return function(...)
		return Promise._try(debug.traceback(nil, 2), callback, ...)
	end
end

--[=[
	Returns a Promise that resolves after `seconds` seconds have passed. The Promise resolves with the actual amount of time that was waited.

	This function is **not** a wrapper around `wait`. `Promise.delay` uses a custom scheduler which provides more accurate timing. As an optimization, cancelling this Promise instantly removes the task from the scheduler.

	:::warning
	Passing `NaN`, infinity, or a number less than 1/60 is equivalent to passing 1/60.
	:::

	```lua
		Promise.delay(5):andThenCall(print, "This prints after 5 seconds")
	```

	@function delay
	@within Promise
	@param seconds number
	@return Promise<number>
]=]
do
	-- uses a sorted doubly linked list (queue) to achieve O(1) remove operations and O(n) for insert

	-- the initial node in the linked list
	local first
	local connection

	function Promise.delay(seconds)
		assert(type(seconds) == "number", "Bad argument #1 to Promise.delay, must be a number.")
		-- If seconds is -INF, INF, NaN, or less than 1 / 60, assume seconds is 1 / 60.
		-- This mirrors the behavior of wait()
		if not (seconds >= 1 / 60) or seconds == math.huge then
			seconds = 1 / 60
		end

		return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
			local startTime = Promise._getTime()
			local endTime = startTime + seconds

			local node = {
				resolve = resolve,
				startTime = startTime,
				endTime = endTime,
			}

			if connection == nil then -- first is nil when connection is nil
				first = node
				connection = Promise._timeEvent:Connect(function()
					local threadStart = Promise._getTime()

					while first ~= nil and first.endTime < threadStart do
						local current = first
						first = current.next

						if first == nil then
							connection:Disconnect()
							connection = nil
						else
							first.previous = nil
						end

						current.resolve(Promise._getTime() - current.startTime)
					end
				end)
			else -- first is non-nil
				if first.endTime < endTime then -- if `node` should be placed after `first`
					-- we will insert `node` between `current` and `next`
					-- (i.e. after `current` if `next` is nil)
					local current = first
					local next = current.next

					while next ~= nil and next.endTime < endTime do
						current = next
						next = current.next
					end

					-- `current` must be non-nil, but `next` could be `nil` (i.e. last item in list)
					current.next = node
					node.previous = current

					if next ~= nil then
						node.next = next
						next.previous = node
					end
				else
					-- set `node` to `first`
					node.next = first
					first.previous = node
					first = node
				end
			end

			onCancel(function()
				-- remove node from queue
				local next = node.next

				if first == node then
					if next == nil then -- if `node` is the first and last
						connection:Disconnect()
						connection = nil
					else -- if `node` is `first` and not the last
						next.previous = nil
					end
					first = next
				else
					local previous = node.previous
					-- since `node` is not `first`, then we know `previous` is non-nil
					previous.next = next

					if next ~= nil then
						next.previous = previous
					end
				end
			end)
		end)
	end
end

--[=[
	Returns a new Promise that resolves if the chained Promise resolves within `seconds` seconds, or rejects if execution time exceeds `seconds`. The chained Promise will be cancelled if the timeout is reached.

	Rejects with `rejectionValue` if it is non-nil. If a `rejectionValue` is not given, it will reject with a `Promise.Error(Promise.Error.Kind.TimedOut)`. This can be checked with [[Error.isKind]].

	```lua
	getSomething():timeout(5):andThen(function(something)
		-- got something and it only took at max 5 seconds
	end):catch(function(e)
		-- Either getting something failed or the time was exceeded.

		if Promise.Error.isKind(e, Promise.Error.Kind.TimedOut) then
			warn("Operation timed out!")
		else
			warn("Operation encountered an error!")
		end
	end)
	```

	Sugar for:

	```lua
	Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(
				rejectionValue == nil
				and Promise.Error.new({ kind = Promise.Error.Kind.TimedOut })
				or rejectionValue
			)
		end),
		promise
	})
	```

	@param seconds number
	@param rejectionValue? any -- The value to reject with if the timeout is reached
	@return Promise
]=]
function Promise.prototype:timeout(seconds, rejectionValue)
	local traceback = debug.traceback(nil, 2)

	return Promise.race({
		Promise.delay(seconds):andThen(function()
			return Promise.reject(rejectionValue == nil and Error.new({
				kind = Error.Kind.TimedOut,
				error = "Timed out",
				context = string.format(
					"Timeout of %d seconds exceeded.\n:timeout() called at:\n\n%s",
					seconds,
					traceback
				),
			}) or rejectionValue)
		end),
		self,
	})
end

--[=[
	Returns the current Promise status.

	@return Status
]=]
function Promise.prototype:getStatus()
	return self._status
end

--[[
	Creates a new promise that receives the result of this promise.

	The given callbacks are invoked depending on that result.
]]
function Promise.prototype:_andThen(traceback, successHandler, failureHandler)
	self._unhandledRejection = false

	-- Create a new promise to follow this part of the chain
	return Promise._new(traceback, function(resolve, reject)
		-- Our default callbacks just pass values onto the next promise.
		-- This lets success and failure cascade correctly!

		local successCallback = resolve
		if successHandler then
			successCallback = createAdvancer(traceback, successHandler, resolve, reject)
		end

		local failureCallback = reject
		if failureHandler then
			failureCallback = createAdvancer(traceback, failureHandler, resolve, reject)
		end

		if self._status == Promise.Status.Started then
			-- If we haven't resolved yet, put ourselves into the queue
			table.insert(self._queuedResolve, successCallback)
			table.insert(self._queuedReject, failureCallback)
		elseif self._status == Promise.Status.Resolved then
			-- This promise has already resolved! Trigger success immediately.
			successCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Rejected then
			-- This promise died a terrible death! Trigger failure immediately.
			failureCallback(unpack(self._values, 1, self._valuesLength))
		elseif self._status == Promise.Status.Cancelled then
			-- We don't want to call the success handler or the failure handler,
			-- we just reject this promise outright.
			reject(Error.new({
				error = "Promise is cancelled",
				kind = Error.Kind.AlreadyCancelled,
				context = "Promise created at\n\n" .. traceback,
			}))
		end
	end, self)
end

--[=[
	Chains onto an existing Promise and returns a new Promise.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::

	Return a Promise from the success or failure handler and it will be chained onto.

	@param successHandler (...: any) -> ...any
	@param failureHandler? (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:andThen(successHandler, failureHandler)
	assert(successHandler == nil or isCallable(successHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:andThen"))

	return self:_andThen(debug.traceback(nil, 2), successHandler, failureHandler)
end

--[=[
	Shorthand for `Promise:andThen(nil, failureHandler)`.

	Returns a Promise that resolves if the `failureHandler` worked without encountering an additional error.

	:::warning
	Within the failure handler, you should never assume that the rejection value is a string. Some rejections within the Promise library are represented by [[Error]] objects. If you want to treat it as a string for debugging, you should call `tostring` on it first.
	:::


	@param failureHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:catch(failureHandler)
	assert(failureHandler == nil or isCallable(failureHandler), string.format(ERROR_NON_FUNCTION, "Promise:catch"))
	return self:_andThen(debug.traceback(nil, 2), nil, failureHandler)
end

--[=[
	Similar to [Promise.andThen](#andThen), except the return value is the same as the value passed to the handler. In other words, you can insert a `:tap` into a Promise chain without affecting the value that downstream Promises receive.

	```lua
		getTheValue()
		:tap(print)
		:andThen(function(theValue)
			print("Got", theValue, "even though print returns nil!")
		end)
	```

	If you return a Promise from the tap handler callback, its value will be discarded but `tap` will still wait until it resolves before passing the original value through.

	@param tapHandler (...: any) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:tap(tapHandler)
	assert(isCallable(tapHandler), string.format(ERROR_NON_FUNCTION, "Promise:tap"))
	return self:_andThen(debug.traceback(nil, 2), function(...)
		local callbackReturn = tapHandler(...)

		if Promise.is(callbackReturn) then
			local length, values = pack(...)
			return callbackReturn:andThen(function()
				return unpack(values, 1, length)
			end)
		end

		return ...
	end)
end

--[=[
	Attaches an `andThen` handler to this Promise that calls the given callback with the predefined arguments. The resolved value is discarded.

	```lua
		promise:andThenCall(someFunction, "some", "arguments")
	```

	This is sugar for

	```lua
		promise:andThen(function()
		return someFunction("some", "arguments")
		end)
	```

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:andThenCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:andThenCall"))
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches an `andThen` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:andThenReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:andThen(function()
			return "some", "values"
		end)
	```

	:::caution
	Promises are eager, so if you pass a Promise to `andThenReturn`, it will begin executing before `andThenReturn` is reached in the chain. Likewise, if you pass a Promise created from [[Promise.reject]] into `andThenReturn`, it's possible that this will trigger the unhandled rejection warning. If you need to return a Promise, it's usually best practice to use [[Promise.andThen]].
	:::

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:andThenReturn(...)
	local length, values = pack(...)
	return self:_andThen(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Cancels this promise, preventing the promise from resolving or rejecting. Does not do anything if the promise is already settled.

	Cancellations will propagate upwards and downwards through chained promises.

	Promises will only be cancelled if all of their consumers are also cancelled. This is to say that if you call `andThen` twice on the same promise, and you cancel only one of the child promises, it will not cancel the parent promise until the other child promise is also cancelled.

	```lua
		promise:cancel()
	```
]=]
function Promise.prototype:cancel()
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Cancelled

	if self._cancellationHook then
		self._cancellationHook()
	end

	if self._parent then
		self._parent:_consumerCancelled(self)
	end

	for child in pairs(self._consumers) do
		child:cancel()
	end

	self:_finalize()
end

--[[
	Used to decrease the number of consumers by 1, and if there are no more,
	cancel this promise.
]]
function Promise.prototype:_consumerCancelled(consumer)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._consumers[consumer] = nil

	if next(self._consumers) == nil then
		self:cancel()
	end
end

--[[
	Used to set a handler for when the promise resolves, rejects, or is
	cancelled. Returns a new promise chained from this promise.
]]
function Promise.prototype:_finally(traceback, finallyHandler, onlyOk)
	if not onlyOk then
		self._unhandledRejection = false
	end

	-- Return a promise chained off of this promise
	return Promise._new(traceback, function(resolve, reject)
		local finallyCallback = resolve
		if finallyHandler then
			finallyCallback = createAdvancer(traceback, finallyHandler, resolve, reject)
		end

		if onlyOk then
			local callback = finallyCallback
			finallyCallback = function(...)
				if self._status == Promise.Status.Rejected then
					return resolve(self)
				end

				return callback(...)
			end
		end

		if self._status == Promise.Status.Started then
			-- The promise is not settled, so queue this.
			table.insert(self._queuedFinally, finallyCallback)
		else
			-- The promise already settled or was cancelled, run the callback now.
			finallyCallback(self._status)
		end
	end, self)
end

--[=[
	Set a handler that will be called regardless of the promise's fate. The handler is called when the promise is resolved, rejected, *or* cancelled.

	Returns a new promise chained from this promise.

	:::caution
	If the Promise is cancelled, any Promises chained off of it with `andThen` won't run. Only Promises chained with `finally` or `done` will run in the case of cancellation.
	:::

	```lua
	local thing = createSomething()

	doSomethingWith(thing)
		:andThen(function()
			print("It worked!")
			-- do something..
		end)
		:catch(function()
			warn("Oh no it failed!")
		end)
		:finally(function()
			-- either way, destroy thing

			thing:Destroy()
		end)

	```

	@param finallyHandler (status: Status) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:finally(finallyHandler)
	assert(finallyHandler == nil or isCallable(finallyHandler), string.format(ERROR_NON_FUNCTION, "Promise:finally"))
	return self:_finally(debug.traceback(nil, 2), finallyHandler)
end

--[=[
	Same as `andThenCall`, except for `finally`.

	Attaches a `finally` handler to this Promise that calls the given callback with the predefined arguments.

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:finallyCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:finallyCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end)
end

--[=[
	Attaches a `finally` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:finallyReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:finally(function()
			return "some", "values"
		end)
	```

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:finallyReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end)
end

--[=[
	Set a handler that will be called only if the Promise resolves or is cancelled. This method is similar to `finally`, except it doesn't catch rejections.

	:::caution
	`done` should be reserved specifically when you want to perform some operation after the Promise is finished (like `finally`), but you don't want to consume rejections (like in <a href="/roblox-lua-promise/lib/Examples.html#cancellable-animation-sequence">this example</a>). You should use `andThen` instead if you only care about the Resolved case.
	:::

	:::warning
	Like `finally`, if the Promise is cancelled, any Promises chained off of it with `andThen` won't run. Only Promises chained with `done` and `finally` will run in the case of cancellation.
	:::

	Returns a new promise chained from this promise.

	@param doneHandler (status: Status) -> ...any
	@return Promise<...any>
]=]
function Promise.prototype:done(doneHandler)
	assert(doneHandler == nil or isCallable(doneHandler), string.format(ERROR_NON_FUNCTION, "Promise:done"))
	return self:_finally(debug.traceback(nil, 2), doneHandler, true)
end

--[=[
	Same as `andThenCall`, except for `done`.

	Attaches a `done` handler to this Promise that calls the given callback with the predefined arguments.

	@param callback (...: any) -> any
	@param ...? any -- Additional arguments which will be passed to `callback`
	@return Promise
]=]
function Promise.prototype:doneCall(callback, ...)
	assert(isCallable(callback), string.format(ERROR_NON_FUNCTION, "Promise:doneCall"))
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return callback(unpack(values, 1, length))
	end, true)
end

--[=[
	Attaches a `done` handler to this Promise that discards the resolved value and returns the given value from it.

	```lua
		promise:doneReturn("some", "values")
	```

	This is sugar for

	```lua
		promise:done(function()
			return "some", "values"
		end)
	```

	@param ... any -- Values to return from the function
	@return Promise
]=]
function Promise.prototype:doneReturn(...)
	local length, values = pack(...)
	return self:_finally(debug.traceback(nil, 2), function()
		return unpack(values, 1, length)
	end, true)
end

--[=[
	Yields the current thread until the given Promise completes. Returns the Promise's status, followed by the values that the promise resolved or rejected with.

	@yields
	@return Status -- The Status representing the fate of the Promise
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:awaitStatus()
	self._unhandledRejection = false

	if self._status == Promise.Status.Started then
		local bindable = Instance.new("BindableEvent")

		self:finally(function()
			bindable:Fire()
		end)

		bindable.Event:Wait()
		bindable:Destroy()
	end

	if self._status == Promise.Status.Resolved then
		return self._status, unpack(self._values, 1, self._valuesLength)
	elseif self._status == Promise.Status.Rejected then
		return self._status, unpack(self._values, 1, self._valuesLength)
	end

	return self._status
end

local function awaitHelper(status, ...)
	return status == Promise.Status.Resolved, ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns true if the Promise resolved, followed by the values that the promise resolved or rejected with.

	:::caution
	If the Promise gets cancelled, this function will return `false`, which is indistinguishable from a rejection. If you need to differentiate, you should use [[Promise.awaitStatus]] instead.
	:::

	```lua
		local worked, value = getTheValue():await()

	if worked then
		print("got", value)
	else
		warn("it failed")
	end
	```

	@yields
	@return boolean -- `true` if the Promise successfully resolved
	@return ...any -- The values the Promise resolved or rejected with.
]=]
function Promise.prototype:await()
	return awaitHelper(self:awaitStatus())
end

local function expectHelper(status, ...)
	if status ~= Promise.Status.Resolved then
		error((...) == nil and "Expected Promise rejected with no value." or (...), 3)
	end

	return ...
end

--[=[
	Yields the current thread until the given Promise completes. Returns the values that the promise resolved with.

	```lua
	local worked = pcall(function()
		print("got", getTheValue():expect())
	end)

	if not worked then
		warn("it failed")
	end
	```

	This is essentially sugar for:

	```lua
	select(2, assert(promise:await()))
	```

	**Errors** if the Promise rejects or gets cancelled.

	@error any -- Errors with the rejection value if this Promise rejects or gets cancelled.
	@yields
	@return ...any -- The values the Promise resolved with.
]=]
function Promise.prototype:expect()
	return expectHelper(self:awaitStatus())
end

-- Backwards compatibility
Promise.prototype.awaitValue = Promise.prototype.expect

--[[
	Intended for use in tests.

	Similar to await(), but instead of yielding if the promise is unresolved,
	_unwrap will throw. This indicates an assumption that a promise has
	resolved.
]]
function Promise.prototype:_unwrap()
	if self._status == Promise.Status.Started then
		error("Promise has not resolved or rejected.", 2)
	end

	local success = self._status == Promise.Status.Resolved

	return success, unpack(self._values, 1, self._valuesLength)
end

function Promise.prototype:_resolve(...)
	if self._status ~= Promise.Status.Started then
		if Promise.is((...)) then
			(...):_consumerCancelled(self)
		end
		return
	end

	-- If the resolved value was a Promise, we chain onto it!
	if Promise.is((...)) then
		-- Without this warning, arguments sometimes mysteriously disappear
		if select("#", ...) > 1 then
			local message = string.format(
				"When returning a Promise from andThen, extra arguments are " .. "discarded! See:\n\n%s",
				self._source
			)
			warn(message)
		end

		local chainedPromise = ...

		local promise = chainedPromise:andThen(function(...)
			self:_resolve(...)
		end, function(...)
			local maybeRuntimeError = chainedPromise._values[1]

			-- Backwards compatibility < v2
			if chainedPromise._error then
				maybeRuntimeError = Error.new({
					error = chainedPromise._error,
					kind = Error.Kind.ExecutionError,
					context = "[No stack trace available as this Promise originated from an older version of the Promise library (< v2)]",
				})
			end

			if Error.isKind(maybeRuntimeError, Error.Kind.ExecutionError) then
				return self:_reject(maybeRuntimeError:extend({
					error = "This Promise was chained to a Promise that errored.",
					trace = "",
					context = string.format(
						"The Promise at:\n\n%s\n...Rejected because it was chained to the following Promise, which encountered an error:\n",
						self._source
					),
				}))
			end

			self:_reject(...)
		end)

		if promise._status == Promise.Status.Cancelled then
			self:cancel()
		elseif promise._status == Promise.Status.Started then
			-- Adopt ourselves into promise for cancellation propagation.
			self._parent = promise
			promise._consumers[self] = true
		end

		return
	end

	self._status = Promise.Status.Resolved
	self._valuesLength, self._values = pack(...)

	-- We assume that these callbacks will not throw errors.
	for _, callback in ipairs(self._queuedResolve) do
		coroutine.wrap(callback)(...)
	end

	self:_finalize()
end

function Promise.prototype:_reject(...)
	if self._status ~= Promise.Status.Started then
		return
	end

	self._status = Promise.Status.Rejected
	self._valuesLength, self._values = pack(...)

	-- If there are any rejection handlers, call those!
	if not isEmpty(self._queuedReject) then
		-- We assume that these callbacks will not throw errors.
		for _, callback in ipairs(self._queuedReject) do
			coroutine.wrap(callback)(...)
		end
	else
		-- At this point, no one was able to observe the error.
		-- An error handler might still be attached if the error occurred
		-- synchronously. We'll wait one tick, and if there are still no
		-- observers, then we should put a message in the console.

		local err = tostring((...))

		coroutine.wrap(function()
			Promise._timeEvent:Wait()

			-- Someone observed the error, hooray!
			if not self._unhandledRejection then
				return
			end

			-- Build a reasonable message
			local message = string.format("Unhandled Promise rejection:\n\n%s\n\n%s", err, self._source)

			for _, callback in ipairs(Promise._unhandledRejectionCallbacks) do
				task.spawn(callback, self, unpack(self._values, 1, self._valuesLength))
			end

			if Promise.TEST then
				-- Don't spam output when we're running tests.
				return
			end

			warn(message)
		end)()
	end

	self:_finalize()
end

--[[
	Calls any :finally handlers. We need this to be a separate method and
	queue because we must call all of the finally callbacks upon a success,
	failure, *and* cancellation.
]]
function Promise.prototype:_finalize()
	for _, callback in ipairs(self._queuedFinally) do
		-- Purposefully not passing values to callbacks here, as it could be the
		-- resolved values, or rejected errors. If the developer needs the values,
		-- they should use :andThen or :catch explicitly.
		coroutine.wrap(callback)(self._status)
	end

	self._queuedFinally = nil
	self._queuedReject = nil
	self._queuedResolve = nil

	-- Clear references to other Promises to allow gc
	if not Promise.TEST then
		self._parent = nil
		self._consumers = nil
	end
end

--[=[
	Chains a Promise from this one that is resolved if this Promise is already resolved, and rejected if it is not resolved at the time of calling `:now()`. This can be used to ensure your `andThen` handler occurs on the same frame as the root Promise execution.

	```lua
	doSomething()
		:now()
		:andThen(function(value)
			print("Got", value, "synchronously.")
		end)
	```

	If this Promise is still running, Rejected, or Cancelled, the Promise returned from `:now()` will reject with the `rejectionValue` if passed, otherwise with a `Promise.Error(Promise.Error.Kind.NotResolvedInTime)`. This can be checked with [[Error.isKind]].

	@param rejectionValue? any -- The value to reject with if the Promise isn't resolved
	@return Promise
]=]
function Promise.prototype:now(rejectionValue)
	local traceback = debug.traceback(nil, 2)
	if self._status == Promise.Status.Resolved then
		return self:_andThen(traceback, function(...)
			return ...
		end)
	else
		return Promise.reject(rejectionValue == nil and Error.new({
			kind = Error.Kind.NotResolvedInTime,
			error = "This Promise was not resolved in time for :now()",
			context = ":now() was called at:\n\n" .. traceback,
		}) or rejectionValue)
	end
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	```lua
	local function canFail(a, b, c)
		return Promise.new(function(resolve, reject)
			-- do something that can fail

			local failed, thing = doSomethingThatCanFail(a, b, c)

			if failed then
				reject("it failed")
			else
				resolve(thing)
			end
		end)
	end

	local MAX_RETRIES = 10
	local value = Promise.retry(canFail, MAX_RETRIES, "foo", "bar", "baz") -- args to send to canFail
	```

	@since 3.0.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param ...? P
]=]
function Promise.retry(callback, times, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			return Promise.retry(callback, times - 1, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Repeatedly calls a Promise-returning function up to `times` number of times, waiting `seconds` seconds between each
	retry, until the returned Promise resolves.

	If the amount of retries is exceeded, the function will return the latest rejected Promise.

	@since v3.2.0
	@param callback (...: P) -> Promise<T>
	@param times number
	@param seconds number
	@param ...? P
]=]
function Promise.retryWithDelay(callback, times, seconds, ...)
	assert(isCallable(callback), "Parameter #1 to Promise.retry must be a function")
	assert(type(times) == "number", "Parameter #2 (times) to Promise.retry must be a number")
	assert(type(seconds) == "number", "Parameter #3 (seconds) to Promise.retry must be a number")

	local args, length = { ... }, select("#", ...)

	return Promise.resolve(callback(...)):catch(function(...)
		if times > 0 then
			Promise.delay(seconds):await()

			return Promise.retryWithDelay(callback, times - 1, seconds, unpack(args, 1, length))
		else
			return Promise.reject(...)
		end
	end)
end

--[=[
	Converts an event into a Promise which resolves the next time the event fires.

	The optional `predicate` callback, if passed, will receive the event arguments and should return `true` or `false`, based on if this fired event should resolve the Promise or not. If `true`, the Promise resolves. If `false`, nothing happens and the predicate will be rerun the next time the event fires.

	The Promise will resolve with the event arguments.

	:::tip
	This function will work given any object with a `Connect` method. This includes all Roblox events.
	:::

	```lua
	-- Creates a Promise which only resolves when `somePart` is touched
	-- by a part named `"Something specific"`.
	return Promise.fromEvent(somePart.Touched, function(part)
		return part.Name == "Something specific"
	end)
	```

	@since 3.0.0
	@param event Event -- Any object with a `Connect` method. This includes all Roblox events.
	@param predicate? (...: P) -> boolean -- A function which determines if the Promise should resolve with the given value, or wait for the next event to check again.
	@return Promise<P>
]=]
function Promise.fromEvent(event, predicate)
	predicate = predicate or function()
		return true
	end

	return Promise._new(debug.traceback(nil, 2), function(resolve, _, onCancel)
		local connection
		local shouldDisconnect = false

		local function disconnect()
			connection:Disconnect()
			connection = nil
		end

		-- We use shouldDisconnect because if the callback given to Connect is called before
		-- Connect returns, connection will still be nil. This happens with events that queue up
		-- events when there's nothing connected, such as RemoteEvents

		connection = event:Connect(function(...)
			local callbackValue = predicate(...)

			if callbackValue == true then
				resolve(...)

				if connection then
					disconnect()
				else
					shouldDisconnect = true
				end
			elseif type(callbackValue) ~= "boolean" then
				error("Promise.fromEvent predicate should always return a boolean")
			end
		end)

		if shouldDisconnect and connection then
			return disconnect()
		end

		onCancel(disconnect)
	end)
end

--[=[
	Registers a callback that runs when an unhandled rejection happens. An unhandled rejection happens when a Promise
	is rejected, and the rejection is not observed with `:catch`.

	The callback is called with the actual promise that rejected, followed by the rejection values.

	@since v3.2.0
	@param callback (promise: Promise, ...: any) -- A callback that runs when an unhandled rejection happens.
	@return () -> () -- Function that unregisters the `callback` when called
]=]
function Promise.onUnhandledRejection(callback)
	table.insert(Promise._unhandledRejectionCallbacks, callback)

	return function()
		local index = table.find(Promise._unhandledRejectionCallbacks, callback)

		if index then
			table.remove(Promise._unhandledRejectionCallbacks, index)
		end
	end
end

return Promise
 end, _env("RemoteSpy.include.Promise"))() end)

_module("RuntimeLib", "ModuleScript", "RemoteSpy.include.RuntimeLib", "RemoteSpy.include", function () return setfenv(function() local Promise = require(script.Parent.Promise)

local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local TS = {}

TS.Promise = Promise

local function isPlugin(object)
	return RunService:IsStudio() and object:FindFirstAncestorWhichIsA("Plugin") ~= nil
end

function TS.getModule(object, scope, moduleName)
	if moduleName == nil then
		moduleName = scope
		scope = "@rbxts"
	end

	if RunService:IsRunning() and object:IsDescendantOf(ReplicatedFirst) then
		warn("roblox-ts packages should not be used from ReplicatedFirst!")
	end

	-- ensure modules have fully replicated
	if RunService:IsRunning() and RunService:IsClient() and not isPlugin(object) and not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local globalModules = script.Parent:FindFirstChild("node_modules")
	if not globalModules then
		error("Could not find any modules!", 2)
	end

	repeat
		local modules = object:FindFirstChild("node_modules")
		if modules and modules ~= globalModules then
			modules = modules:FindFirstChild("@rbxts")
		end
		if modules then
			local module = modules:FindFirstChild(moduleName)
			if module then
				return module
			end
		end
		object = object.Parent
	until object == nil or object == globalModules

	local scopedModules = globalModules:FindFirstChild(scope or "@rbxts");
	return (scopedModules or globalModules):FindFirstChild(moduleName) or error("Could not find module: " .. moduleName, 2)
end

-- This is a hash which TS.import uses as a kind of linked-list-like history of [Script who Loaded] -> Library
local currentlyLoading = {}
local registeredLibraries = {}

function TS.import(caller, module, ...)
	for i = 1, select("#", ...) do
		module = module:WaitForChild((select(i, ...)))
	end

	if module.ClassName ~= "ModuleScript" then
		error("Failed to import! Expected ModuleScript, got " .. module.ClassName, 2)
	end

	currentlyLoading[caller] = module

	-- Check to see if a case like this occurs:
	-- module -> Module1 -> Module2 -> module

	-- WHERE currentlyLoading[module] is Module1
	-- and currentlyLoading[Module1] is Module2
	-- and currentlyLoading[Module2] is module

	local currentModule = module
	local depth = 0

	while currentModule do
		depth = depth + 1
		currentModule = currentlyLoading[currentModule]

		if currentModule == module then
			local str = currentModule.Name -- Get the string traceback

			for _ = 1, depth do
				currentModule = currentlyLoading[currentModule]
				str = str .. "  ⇒ " .. currentModule.Name
			end

			error("Failed to import! Detected a circular dependency chain: " .. str, 2)
		end
	end

	if not registeredLibraries[module] then
		if _G[module] then
			error(
				"Invalid module access! Do you have two TS runtimes trying to import this? " .. module:GetFullName(),
				2
			)
		end

		_G[module] = TS
		registeredLibraries[module] = true -- register as already loaded for subsequent calls
	end

	local data = require(module)

	if currentlyLoading[caller] == module then -- Thread-safe cleanup!
		currentlyLoading[caller] = nil
	end

	return data
end

function TS.instanceof(obj, class)
	-- custom Class.instanceof() check
	if type(class) == "table" and type(class.instanceof) == "function" then
		return class.instanceof(obj)
	end

	-- metatable check
	if type(obj) == "table" then
		obj = getmetatable(obj)
		while obj ~= nil do
			if obj == class then
				return true
			end
			local mt = getmetatable(obj)
			if mt then
				obj = mt.__index
			else
				obj = nil
			end
		end
	end

	return false
end

function TS.async(callback)
	return function(...)
		local n = select("#", ...)
		local args = { ... }
		return Promise.new(function(resolve, reject)
			coroutine.wrap(function()
				local ok, result = pcall(callback, unpack(args, 1, n))
				if ok then
					resolve(result)
				else
					reject(result)
				end
			end)()
		end)
	end
end

function TS.await(promise)
	if not Promise.is(promise) then
		return promise
	end

	local status, value = promise:awaitStatus()
	if status == Promise.Status.Resolved then
		return value
	elseif status == Promise.Status.Rejected then
		error(value, 2)
	else
		error("The awaited Promise was cancelled", 2)
	end
end

function TS.bit_lrsh(a, b)
	local absA = math.abs(a)
	local result = bit32.rshift(absA, b)
	if a == absA then
		return result
	else
		return -result - 1
	end
end

TS.TRY_RETURN = 1
TS.TRY_BREAK = 2
TS.TRY_CONTINUE = 3

function TS.try(func, catch, finally)
	local err, traceback
	local success, exitType, returns = xpcall(
		func,
		function(errInner)
			err = errInner
			traceback = debug.traceback()
		end
	)
	if not success and catch then
		local newExitType, newReturns = catch(err, traceback)
		if newExitType then
			exitType, returns = newExitType, newReturns
		end
	end
	if finally then
		local newExitType, newReturns = finally()
		if newExitType then
			exitType, returns = newExitType, newReturns
		end
	end
	return exitType, returns
end

function TS.generator(callback)
	local co = coroutine.create(callback)
	return {
		next = function(...)
			if coroutine.status(co) == "dead" then
				return { done = true }
			else
				local success, value = coroutine.resume(co, ...)
				if success == false then
					error(value, 2)
				end
				return {
					value = value,
					done = coroutine.status(co) == "dead",
				}
			end
		end,
	}
end

return TS
 end, _env("RemoteSpy.include.RuntimeLib"))() end)

_instance("node_modules", "Folder", "RemoteSpy.include.node_modules", "RemoteSpy.include")

_instance("bin", "Folder", "RemoteSpy.include.node_modules.bin", "RemoteSpy.include.node_modules")

_module("out", "ModuleScript", "RemoteSpy.include.node_modules.bin.out", "RemoteSpy.include.node_modules.bin", function () return setfenv(function() -- Compiled with roblox-ts v1.2.7
--[[
	*
	* Tracks connections, instances, functions, and objects to be later destroyed.
]]
local Bin
do
	Bin = setmetatable({}, {
		__tostring = function()
			return "Bin"
		end,
	})
	Bin.__index = Bin
	function Bin.new(...)
		local self = setmetatable({}, Bin)
		return self:constructor(...) or self
	end
	function Bin:constructor()
	end
	function Bin:add(item)
		local node = {
			item = item,
		}
		if self.head == nil then
			self.head = node
		end
		if self.tail then
			self.tail.next = node
		end
		self.tail = node
		return item
	end
	function Bin:destroy()
		while self.head do
			local item = self.head.item
			if type(item) == "function" then
				item()
			elseif typeof(item) == "RBXScriptConnection" then
				item:Disconnect()
			elseif item.destroy ~= nil then
				item:destroy()
			elseif item.Destroy ~= nil then
				item:Destroy()
			end
			self.head = self.head.next
		end
	end
	function Bin:isEmpty()
		return self.head == nil
	end
end
return {
	Bin = Bin,
}
 end, _env("RemoteSpy.include.node_modules.bin.out"))() end)

_instance("compiler-types", "Folder", "RemoteSpy.include.node_modules.compiler-types", "RemoteSpy.include.node_modules")

_instance("types", "Folder", "RemoteSpy.include.node_modules.compiler-types.types", "RemoteSpy.include.node_modules.compiler-types")

_instance("flipper", "Folder", "RemoteSpy.include.node_modules.flipper", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src", "RemoteSpy.include.node_modules.flipper", function () return setfenv(function() local Flipper = {
	SingleMotor = require(script.SingleMotor),
	GroupMotor = require(script.GroupMotor),

	Instant = require(script.Instant),
	Linear = require(script.Linear),
	Spring = require(script.Spring),
	
	isMotor = require(script.isMotor),
}

return Flipper end, _env("RemoteSpy.include.node_modules.flipper.src"))() end)

_module("BaseMotor", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.BaseMotor", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)

local noop = function() end

local BaseMotor = {}
BaseMotor.__index = BaseMotor

function BaseMotor.new()
	return setmetatable({
		_onStep = Signal.new(),
		_onStart = Signal.new(),
		_onComplete = Signal.new(),
	}, BaseMotor)
end

function BaseMotor:onStep(handler)
	return self._onStep:connect(handler)
end

function BaseMotor:onStart(handler)
	return self._onStart:connect(handler)
end

function BaseMotor:onComplete(handler)
	return self._onComplete:connect(handler)
end

function BaseMotor:start()
	if not self._connection then
		self._connection = RunService.RenderStepped:Connect(function(deltaTime)
			self:step(deltaTime)
		end)
	end
end

function BaseMotor:stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

BaseMotor.destroy = BaseMotor.stop

BaseMotor.step = noop
BaseMotor.getValue = noop
BaseMotor.setGoal = noop

function BaseMotor:__tostring()
	return "Motor"
end

return BaseMotor
 end, _env("RemoteSpy.include.node_modules.flipper.src.BaseMotor"))() end)

_module("GroupMotor", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.GroupMotor", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local BaseMotor = require(script.Parent.BaseMotor)
local SingleMotor = require(script.Parent.SingleMotor)

local isMotor = require(script.Parent.isMotor)

local GroupMotor = setmetatable({}, BaseMotor)
GroupMotor.__index = GroupMotor

local function toMotor(value)
	if isMotor(value) then
		return value
	end

	local valueType = typeof(value)

	if valueType == "number" then
		return SingleMotor.new(value, false)
	elseif valueType == "table" then
		return GroupMotor.new(value, false)
	end

	error(("Unable to convert %q to motor; type %s is unsupported"):format(value, valueType), 2)
end

function GroupMotor.new(initialValues, useImplicitConnections)
	assert(initialValues, "Missing argument #1: initialValues")
	assert(typeof(initialValues) == "table", "initialValues must be a table!")
	assert(not initialValues.step, "initialValues contains disallowed property \"step\". Did you mean to put a table of values here?")

	local self = setmetatable(BaseMotor.new(), GroupMotor)

	if useImplicitConnections ~= nil then
		self._useImplicitConnections = useImplicitConnections
	else
		self._useImplicitConnections = true
	end

	self._complete = true
	self._motors = {}

	for key, value in pairs(initialValues) do
		self._motors[key] = toMotor(value)
	end

	return self
end

function GroupMotor:step(deltaTime)
	if self._complete then
		return true
	end

	local allMotorsComplete = true

	for _, motor in pairs(self._motors) do
		local complete = motor:step(deltaTime)
		if not complete then
			-- If any of the sub-motors are incomplete, the group motor will not be complete either
			allMotorsComplete = false
		end
	end

	self._onStep:fire(self:getValue())

	if allMotorsComplete then
		if self._useImplicitConnections then
			self:stop()
		end

		self._complete = true
		self._onComplete:fire()
	end

	return allMotorsComplete
end

function GroupMotor:setGoal(goals)
	assert(not goals.step, "goals contains disallowed property \"step\". Did you mean to put a table of goals here?")

	self._complete = false
	self._onStart:fire()

	for key, goal in pairs(goals) do
		local motor = assert(self._motors[key], ("Unknown motor for key %s"):format(key))
		motor:setGoal(goal)
	end

	if self._useImplicitConnections then
		self:start()
	end
end

function GroupMotor:getValue()
	local values = {}

	for key, motor in pairs(self._motors) do
		values[key] = motor:getValue()
	end

	return values
end

function GroupMotor:__tostring()
	return "Motor(Group)"
end

return GroupMotor
 end, _env("RemoteSpy.include.node_modules.flipper.src.GroupMotor"))() end)

_module("Instant", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.Instant", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local Instant = {}
Instant.__index = Instant

function Instant.new(targetValue)
	return setmetatable({
		_targetValue = targetValue,
	}, Instant)
end

function Instant:step()
	return {
		complete = true,
		value = self._targetValue,
	}
end

return Instant end, _env("RemoteSpy.include.node_modules.flipper.src.Instant"))() end)

_module("Linear", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.Linear", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local Linear = {}
Linear.__index = Linear

function Linear.new(targetValue, options)
	assert(targetValue, "Missing argument #1: targetValue")
	
	options = options or {}

	return setmetatable({
		_targetValue = targetValue,
		_velocity = options.velocity or 1,
	}, Linear)
end

function Linear:step(state, dt)
	local position = state.value
	local velocity = self._velocity -- Linear motion ignores the state's velocity
	local goal = self._targetValue

	local dPos = dt * velocity

	local complete = dPos >= math.abs(goal - position)
	position = position + dPos * (goal > position and 1 or -1)
	if complete then
		position = self._targetValue
		velocity = 0
	end
	
	return {
		complete = complete,
		value = position,
		velocity = velocity,
	}
end

return Linear end, _env("RemoteSpy.include.node_modules.flipper.src.Linear"))() end)

_module("Signal", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.Signal", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local Connection = {}
Connection.__index = Connection

function Connection.new(signal, handler)
	return setmetatable({
		signal = signal,
		connected = true,
		_handler = handler,
	}, Connection)
end

function Connection:disconnect()
	if self.connected then
		self.connected = false

		for index, connection in pairs(self.signal._connections) do
			if connection == self then
				table.remove(self.signal._connections, index)
				return
			end
		end
	end
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({
		_connections = {},
		_threads = {},
	}, Signal)
end

function Signal:fire(...)
	for _, connection in pairs(self._connections) do
		connection._handler(...)
	end

	for _, thread in pairs(self._threads) do
		coroutine.resume(thread, ...)
	end
	
	self._threads = {}
end

function Signal:connect(handler)
	local connection = Connection.new(self, handler)
	table.insert(self._connections, connection)
	return connection
end

function Signal:wait()
	table.insert(self._threads, coroutine.running())
	return coroutine.yield()
end

return Signal end, _env("RemoteSpy.include.node_modules.flipper.src.Signal"))() end)

_module("SingleMotor", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.SingleMotor", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local BaseMotor = require(script.Parent.BaseMotor)

local SingleMotor = setmetatable({}, BaseMotor)
SingleMotor.__index = SingleMotor

function SingleMotor.new(initialValue, useImplicitConnections)
	assert(initialValue, "Missing argument #1: initialValue")
	assert(typeof(initialValue) == "number", "initialValue must be a number!")

	local self = setmetatable(BaseMotor.new(), SingleMotor)

	if useImplicitConnections ~= nil then
		self._useImplicitConnections = useImplicitConnections
	else
		self._useImplicitConnections = true
	end

	self._goal = nil
	self._state = {
		complete = true,
		value = initialValue,
	}

	return self
end

function SingleMotor:step(deltaTime)
	if self._state.complete then
		return true
	end

	local newState = self._goal:step(self._state, deltaTime)

	self._state = newState
	self._onStep:fire(newState.value)

	if newState.complete then
		if self._useImplicitConnections then
			self:stop()
		end

		self._onComplete:fire()
	end

	return newState.complete
end

function SingleMotor:getValue()
	return self._state.value
end

function SingleMotor:setGoal(goal)
	self._state.complete = false
	self._goal = goal

	self._onStart:fire()

	if self._useImplicitConnections then
		self:start()
	end
end

function SingleMotor:__tostring()
	return "Motor(Single)"
end

return SingleMotor
 end, _env("RemoteSpy.include.node_modules.flipper.src.SingleMotor"))() end)

_module("Spring", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.Spring", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local VELOCITY_THRESHOLD = 0.001
local POSITION_THRESHOLD = 0.001

local EPS = 0.0001

local Spring = {}
Spring.__index = Spring

function Spring.new(targetValue, options)
	assert(targetValue, "Missing argument #1: targetValue")
	options = options or {}

	return setmetatable({
		_targetValue = targetValue,
		_frequency = options.frequency or 4,
		_dampingRatio = options.dampingRatio or 1,
	}, Spring)
end

function Spring:step(state, dt)
	-- Copyright 2018 Parker Stebbins (parker@fractality.io)
	-- github.com/Fraktality/Spring
	-- Distributed under the MIT license

	local d = self._dampingRatio
	local f = self._frequency*2*math.pi
	local g = self._targetValue
	local p0 = state.value
	local v0 = state.velocity or 0

	local offset = p0 - g
	local decay = math.exp(-d*f*dt)

	local p1, v1

	if d == 1 then -- Critically damped
		p1 = (offset*(1 + f*dt) + v0*dt)*decay + g
		v1 = (v0*(1 - f*dt) - offset*(f*f*dt))*decay
	elseif d < 1 then -- Underdamped
		local c = math.sqrt(1 - d*d)

		local i = math.cos(f*c*dt)
		local j = math.sin(f*c*dt)

		-- Damping ratios approaching 1 can cause division by small numbers.
		-- To fix that, group terms around z=j/c and find an approximation for z.
		-- Start with the definition of z:
		--    z = sin(dt*f*c)/c
		-- Substitute a=dt*f:
		--    z = sin(a*c)/c
		-- Take the Maclaurin expansion of z with respect to c:
		--    z = a - (a^3*c^2)/6 + (a^5*c^4)/120 + O(c^6)
		--    z ≈ a - (a^3*c^2)/6 + (a^5*c^4)/120
		-- Rewrite in Horner form:
		--    z ≈ a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6

		local z
		if c > EPS then
			z = j/c
		else
			local a = dt*f
			z = a + ((a*a)*(c*c)*(c*c)/20 - c*c)*(a*a*a)/6
		end

		-- Frequencies approaching 0 present a similar problem.
		-- We want an approximation for y as f approaches 0, where:
		--    y = sin(dt*f*c)/(f*c)
		-- Substitute b=dt*c:
		--    y = sin(b*c)/b
		-- Now reapply the process from z.

		local y
		if f*c > EPS then
			y = j/(f*c)
		else
			local b = f*c
			y = dt + ((dt*dt)*(b*b)*(b*b)/20 - b*b)*(dt*dt*dt)/6
		end

		p1 = (offset*(i + d*z) + v0*y)*decay + g
		v1 = (v0*(i - z*d) - offset*(z*f))*decay

	else -- Overdamped
		local c = math.sqrt(d*d - 1)

		local r1 = -f*(d - c)
		local r2 = -f*(d + c)

		local co2 = (v0 - offset*r1)/(2*f*c)
		local co1 = offset - co2

		local e1 = co1*math.exp(r1*dt)
		local e2 = co2*math.exp(r2*dt)

		p1 = e1 + e2 + g
		v1 = e1*r1 + e2*r2
	end

	local complete = math.abs(v1) < VELOCITY_THRESHOLD and math.abs(p1 - g) < POSITION_THRESHOLD
	
	return {
		complete = complete,
		value = complete and g or p1,
		velocity = v1,
	}
end

return Spring end, _env("RemoteSpy.include.node_modules.flipper.src.Spring"))() end)

_module("isMotor", "ModuleScript", "RemoteSpy.include.node_modules.flipper.src.isMotor", "RemoteSpy.include.node_modules.flipper.src", function () return setfenv(function() local function isMotor(value)
	local motorType = tostring(value):match("^Motor%((.+)%)$")

	if motorType then
		return true, motorType
	else
		return false
	end
end

return isMotor end, _env("RemoteSpy.include.node_modules.flipper.src.isMotor"))() end)

_instance("typings", "Folder", "RemoteSpy.include.node_modules.flipper.typings", "RemoteSpy.include.node_modules.flipper")

_instance("hax", "Folder", "RemoteSpy.include.node_modules.hax", "RemoteSpy.include.node_modules")

_instance("types", "Folder", "RemoteSpy.include.node_modules.hax.types", "RemoteSpy.include.node_modules.hax")

_module("make", "ModuleScript", "RemoteSpy.include.node_modules.make", "RemoteSpy.include.node_modules", function () return setfenv(function() -- Compiled with roblox-ts v1.2.3
--[[
	*
	* Returns a table wherein an object's writable properties can be specified,
	* while also allowing functions to be passed in which can be bound to a RBXScriptSignal.
]]
--[[
	*
	* Instantiates a new Instance of `className` with given `settings`,
	* where `settings` is an object of the form { [K: propertyName]: value }.
	*
	* `settings.Children` is an array of child objects to be parented to the generated Instance.
	*
	* Events can be set to a callback function, which will be connected.
	*
	* `settings.Parent` is always set last.
]]
local function Make(className, settings)
	local _binding = settings
	local children = _binding.Children
	local parent = _binding.Parent
	local instance = Instance.new(className)
	for setting, value in pairs(settings) do
		if setting ~= "Children" and setting ~= "Parent" then
			local _binding_1 = instance
			local prop = _binding_1[setting]
			if typeof(prop) == "RBXScriptSignal" then
				prop:Connect(value)
			else
				instance[setting] = value
			end
		end
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = instance
		end
	end
	instance.Parent = parent
	return instance
end
return Make
 end, _env("RemoteSpy.include.node_modules.make"))() end)

_instance("node_modules", "Folder", "RemoteSpy.include.node_modules.make.node_modules", "RemoteSpy.include.node_modules.make")

_instance("@rbxts", "Folder", "RemoteSpy.include.node_modules.make.node_modules.@rbxts", "RemoteSpy.include.node_modules.make.node_modules")

_instance("compiler-types", "Folder", "RemoteSpy.include.node_modules.make.node_modules.@rbxts.compiler-types", "RemoteSpy.include.node_modules.make.node_modules.@rbxts")

_instance("types", "Folder", "RemoteSpy.include.node_modules.make.node_modules.@rbxts.compiler-types.types", "RemoteSpy.include.node_modules.make.node_modules.@rbxts.compiler-types")

_module("object-utils", "ModuleScript", "RemoteSpy.include.node_modules.object-utils", "RemoteSpy.include.node_modules", function () return setfenv(function() local HttpService = game:GetService("HttpService")

local Object = {}

function Object.keys(object)
	local result = table.create(#object)
	for key in pairs(object) do
		result[#result + 1] = key
	end
	return result
end

function Object.values(object)
	local result = table.create(#object)
	for _, value in pairs(object) do
		result[#result + 1] = value
	end
	return result
end

function Object.entries(object)
	local result = table.create(#object)
	for key, value in pairs(object) do
		result[#result + 1] = { key, value }
	end
	return result
end

function Object.assign(toObj, ...)
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if type(arg) == "table" then
			for key, value in pairs(arg) do
				toObj[key] = value
			end
		end
	end
	return toObj
end

function Object.copy(object)
	local result = table.create(#object)
	for k, v in pairs(object) do
		result[k] = v
	end
	return result
end

local function deepCopyHelper(object, encountered)
	local result = table.create(#object)
	encountered[object] = result

	for k, v in pairs(object) do
		if type(k) == "table" then
			k = encountered[k] or deepCopyHelper(k, encountered)
		end

		if type(v) == "table" then
			v = encountered[v] or deepCopyHelper(v, encountered)
		end

		result[k] = v
	end

	return result
end

function Object.deepCopy(object)
	return deepCopyHelper(object, {})
end

function Object.deepEquals(a, b)
	-- a[k] == b[k]
	for k in pairs(a) do
		local av = a[k]
		local bv = b[k]
		if type(av) == "table" and type(bv) == "table" then
			local result = Object.deepEquals(av, bv)
			if not result then
				return false
			end
		elseif av ~= bv then
			return false
		end
	end

	-- extra keys in b
	for k in pairs(b) do
		if a[k] == nil then
			return false
		end
	end

	return true
end

function Object.toString(data)
	return HttpService:JSONEncode(data)
end

function Object.isEmpty(object)
	return next(object) == nil
end

function Object.fromEntries(entries)
	local entriesLen = #entries

	local result = table.create(entriesLen)
	if entries then
		for i = 1, entriesLen do
			local pair = entries[i]
			result[pair[1]] = pair[2]
		end
	end
	return result
end

return Object
 end, _env("RemoteSpy.include.node_modules.object-utils"))() end)

_instance("roact", "Folder", "RemoteSpy.include.node_modules.roact", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.roact.src", "RemoteSpy.include.node_modules.roact", function () return setfenv(function() --[[
	Packages up the internals of Roact and exposes a public API for it.
]]

local GlobalConfig = require(script.GlobalConfig)
local createReconciler = require(script.createReconciler)
local createReconcilerCompat = require(script.createReconcilerCompat)
local RobloxRenderer = require(script.RobloxRenderer)
local strict = require(script.strict)
local Binding = require(script.Binding)

local robloxReconciler = createReconciler(RobloxRenderer)
local reconcilerCompat = createReconcilerCompat(robloxReconciler)

local Roact = strict {
	Component = require(script.Component),
	createElement = require(script.createElement),
	createFragment = require(script.createFragment),
	oneChild = require(script.oneChild),
	PureComponent = require(script.PureComponent),
	None = require(script.None),
	Portal = require(script.Portal),
	createRef = require(script.createRef),
	forwardRef = require(script.forwardRef),
	createBinding = Binding.create,
	joinBindings = Binding.join,
	createContext = require(script.createContext),

	Change = require(script.PropMarkers.Change),
	Children = require(script.PropMarkers.Children),
	Event = require(script.PropMarkers.Event),
	Ref = require(script.PropMarkers.Ref),

	mount = robloxReconciler.mountVirtualTree,
	unmount = robloxReconciler.unmountVirtualTree,
	update = robloxReconciler.updateVirtualTree,

	reify = reconcilerCompat.reify,
	teardown = reconcilerCompat.teardown,
	reconcile = reconcilerCompat.reconcile,

	setGlobalConfig = GlobalConfig.set,

	-- APIs that may change in the future without warning
	UNSTABLE = {
	},
}

return Roact end, _env("RemoteSpy.include.node_modules.roact.src"))() end)

_module("Binding", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Binding", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local createSignal = require(script.Parent.createSignal)
local Symbol = require(script.Parent.Symbol)
local Type = require(script.Parent.Type)

local config = require(script.Parent.GlobalConfig).get()

local BindingImpl = Symbol.named("BindingImpl")

local BindingInternalApi = {}

local bindingPrototype = {}

function bindingPrototype:getValue()
	return BindingInternalApi.getValue(self)
end

function bindingPrototype:map(predicate)
	return BindingInternalApi.map(self, predicate)
end

local BindingPublicMeta = {
	__index = bindingPrototype,
	__tostring = function(self)
		return string.format("RoactBinding(%s)", tostring(self:getValue()))
	end,
}

function BindingInternalApi.update(binding, newValue)
	return binding[BindingImpl].update(newValue)
end

function BindingInternalApi.subscribe(binding, callback)
	return binding[BindingImpl].subscribe(callback)
end

function BindingInternalApi.getValue(binding)
	return binding[BindingImpl].getValue()
end

function BindingInternalApi.create(initialValue)
	local impl = {
		value = initialValue,
		changeSignal = createSignal(),
	}

	function impl.subscribe(callback)
		return impl.changeSignal:subscribe(callback)
	end

	function impl.update(newValue)
		impl.value = newValue
		impl.changeSignal:fire(newValue)
	end

	function impl.getValue()
		return impl.value
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta), impl.update
end

function BindingInternalApi.map(upstreamBinding, predicate)
	if config.typeChecks then
		assert(Type.of(upstreamBinding) == Type.Binding, "Expected arg #1 to be a binding")
		assert(typeof(predicate) == "function", "Expected arg #1 to be a function")
	end

	local impl = {}

	function impl.subscribe(callback)
		return BindingInternalApi.subscribe(upstreamBinding, function(newValue)
			callback(predicate(newValue))
		end)
	end

	function impl.update(newValue)
		error("Bindings created by Binding:map(fn) cannot be updated directly", 2)
	end

	function impl.getValue()
		return predicate(upstreamBinding:getValue())
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

function BindingInternalApi.join(upstreamBindings)
	if config.typeChecks then
		assert(typeof(upstreamBindings) == "table", "Expected arg #1 to be of type table")

		for key, value in pairs(upstreamBindings) do
			if Type.of(value) ~= Type.Binding then
				local message = (
					"Expected arg #1 to contain only bindings, but key %q had a non-binding value"
				):format(
					tostring(key)
				)
				error(message, 2)
			end
		end
	end

	local impl = {}

	local function getValue()
		local value = {}

		for key, upstream in pairs(upstreamBindings) do
			value[key] = upstream:getValue()
		end

		return value
	end

	function impl.subscribe(callback)
		local disconnects = {}

		for key, upstream in pairs(upstreamBindings) do
			disconnects[key] = BindingInternalApi.subscribe(upstream, function(newValue)
				callback(getValue())
			end)
		end

		return function()
			if disconnects == nil then
				return
			end

			for _, disconnect in pairs(disconnects) do
				disconnect()
			end

			disconnects = nil
		end
	end

	function impl.update(newValue)
		error("Bindings created by joinBindings(...) cannot be updated directly", 2)
	end

	function impl.getValue()
		return getValue()
	end

	return setmetatable({
		[Type] = Type.Binding,
		[BindingImpl] = impl,
	}, BindingPublicMeta)
end

return BindingInternalApi end, _env("RemoteSpy.include.node_modules.roact.src.Binding"))() end)

_module("Component", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Component", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local assign = require(script.Parent.assign)
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)
local Type = require(script.Parent.Type)
local Symbol = require(script.Parent.Symbol)
local invalidSetStateMessages = require(script.Parent.invalidSetStateMessages)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

--[[
	Calling setState during certain lifecycle allowed methods has the potential
	to create an infinitely updating component. Rather than time out, we exit
	with an error if an unreasonable number of self-triggering updates occur
]]
local MAX_PENDING_UPDATES = 100

local InternalData = Symbol.named("InternalData")

local componentMissingRenderMessage = [[
The component %q is missing the `render` method.
`render` must be defined when creating a Roact component!]]

local tooManyUpdatesMessage = [[
The component %q has reached the setState update recursion limit.
When using `setState` in `didUpdate`, make sure that it won't repeat infinitely!]]

local componentClassMetatable = {}

function componentClassMetatable:__tostring()
	return self.__componentName
end

local Component = {}
setmetatable(Component, componentClassMetatable)

Component[Type] = Type.StatefulComponentClass
Component.__index = Component
Component.__componentName = "Component"

--[[
	A method called by consumers of Roact to create a new component class.
	Components can not be extended beyond this point, with the exception of
	PureComponent.
]]
function Component:extend(name)
	if config.typeChecks then
		assert(Type.of(self) == Type.StatefulComponentClass, "Invalid `self` argument to `extend`.")
		assert(typeof(name) == "string", "Component class name must be a string")
	end

	local class = {}

	for key, value in pairs(self) do
		-- Roact opts to make consumers use composition over inheritance, which
		-- lines up with React.
		-- https://reactjs.org/docs/composition-vs-inheritance.html
		if key ~= "extend" then
			class[key] = value
		end
	end

	class[Type] = Type.StatefulComponentClass
	class.__index = class
	class.__componentName = name

	setmetatable(class, componentClassMetatable)

	return class
end

function Component:__getDerivedState(incomingProps, incomingState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getDerivedState`")
	end

	local internalData = self[InternalData]
	local componentClass = internalData.componentClass

	if componentClass.getDerivedStateFromProps ~= nil then
		local derivedState = componentClass.getDerivedStateFromProps(incomingProps, incomingState)

		if derivedState ~= nil then
			if config.typeChecks then
				assert(typeof(derivedState) == "table", "getDerivedStateFromProps must return a table!")
			end

			return derivedState
		end
	end

	return nil
end

function Component:setState(mapState)
	if config.typeChecks then
		assert(Type.of(self) == Type.StatefulComponentInstance, "Invalid `self` argument to `extend`.")
	end

	local internalData = self[InternalData]
	local lifecyclePhase = internalData.lifecyclePhase

	--[[
		When preparing to update, rendering, or unmounting, it is not safe
		to call `setState` as it will interfere with in-flight updates. It's
		also disallowed during unmounting
	]]
	if lifecyclePhase == ComponentLifecyclePhase.ShouldUpdate or
		lifecyclePhase == ComponentLifecyclePhase.WillUpdate or
		lifecyclePhase == ComponentLifecyclePhase.Render or
		lifecyclePhase == ComponentLifecyclePhase.WillUnmount
	then
		local messageTemplate = invalidSetStateMessages[internalData.lifecyclePhase]

		local message = messageTemplate:format(tostring(internalData.componentClass))

		error(message, 2)
	end

	local pendingState = internalData.pendingState

	local partialState
	if typeof(mapState) == "function" then
		partialState = mapState(pendingState or self.state, self.props)

		-- Abort the state update if the given state updater function returns nil
		if partialState == nil then
			return
		end
	elseif typeof(mapState) == "table" then
		partialState = mapState
	else
		error("Invalid argument to setState, expected function or table", 2)
	end

	local newState
	if pendingState ~= nil then
		newState = assign(pendingState, partialState)
	else
		newState = assign({}, self.state, partialState)
	end

	if lifecyclePhase == ComponentLifecyclePhase.Init then
		-- If `setState` is called in `init`, we can skip triggering an update!
		local derivedState = self:__getDerivedState(self.props, newState)
		self.state = assign(newState, derivedState)

	elseif lifecyclePhase == ComponentLifecyclePhase.DidMount or
		lifecyclePhase == ComponentLifecyclePhase.DidUpdate or
		lifecyclePhase == ComponentLifecyclePhase.ReconcileChildren
	then
		--[[
			During certain phases of the component lifecycle, it's acceptable to
			allow `setState` but defer the update until we're done with ones in flight.
			We do this by collapsing it into any pending updates we have.
		]]
		local derivedState = self:__getDerivedState(self.props, newState)
		internalData.pendingState = assign(newState, derivedState)

	elseif lifecyclePhase == ComponentLifecyclePhase.Idle then
		-- Pause parent events when we are updated outside of our lifecycle
		-- If these events are not paused, our setState can cause a component higher up the
		-- tree to rerender based on events caused by our component while this reconciliation is happening.
		-- This could cause the tree to become invalid.
		local virtualNode = internalData.virtualNode
		local reconciler = internalData.reconciler
		if config.tempFixUpdateChildrenReEntrancy then
			reconciler.suspendParentEvents(virtualNode)
		end

		-- Outside of our lifecycle, the state update is safe to make immediately
		self:__update(nil, newState)

		if config.tempFixUpdateChildrenReEntrancy then
			reconciler.resumeParentEvents(virtualNode)
		end
	else
		local messageTemplate = invalidSetStateMessages.default

		local message = messageTemplate:format(tostring(internalData.componentClass))

		error(message, 2)
	end
end

--[[
	Returns the stack trace of where the element was created that this component
	instance's properties are based on.

	Intended to be used primarily by diagnostic tools.
]]
function Component:getElementTraceback()
	return self[InternalData].virtualNode.currentElement.source
end

--[[
	Returns a snapshot of this component given the current props and state. Must
	be overridden by consumers of Roact and should be a pure function with
	regards to props and state.

	TODO (#199): Accept props and state as arguments.
]]
function Component:render()
	local internalData = self[InternalData]

	local message = componentMissingRenderMessage:format(
		tostring(internalData.componentClass)
	)

	error(message, 0)
end

--[[
	Retrieves the context value corresponding to the given key. Can return nil
	if a requested context key is not present
]]
function Component:__getContext(key)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__getContext`")
		internalAssert(key ~= nil, "Context key cannot be nil")
	end

	local virtualNode = self[InternalData].virtualNode
	local context = virtualNode.context

	return context[key]
end

--[[
	Adds a new context entry to this component's context table (which will be
	passed down to child components).
]]
function Component:__addContext(key, value)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__addContext`")
	end
	local virtualNode = self[InternalData].virtualNode

	-- Make sure we store a reference to the component's original, unmodified
	-- context the virtual node. In the reconciler, we'll restore the original
	-- context if we need to replace the node (this happens when a node gets
	-- re-rendered as a different component)
	if virtualNode.originalContext == nil then
		virtualNode.originalContext = virtualNode.context
	end

	-- Build a new context table on top of the existing one, then apply it to
	-- our virtualNode
	local existing = virtualNode.context
	virtualNode.context = assign({}, existing, { [key] = value })
end

--[[
	Performs property validation if the static method validateProps is declared.
	validateProps should follow assert's expected arguments:
	(false, message: string) | true. The function may return a message in the
	true case; it will be ignored. If this fails, the function will throw the
	error.
]]
function Component:__validateProps(props)
	if not config.propValidation then
		return
	end

	local validator = self[InternalData].componentClass.validateProps

	if validator == nil then
		return
	end

	if typeof(validator) ~= "function" then
		error(("validateProps must be a function, but it is a %s.\nCheck the definition of the component %q."):format(
			typeof(validator),
			self.__componentName
		))
	end

	local success, failureReason = validator(props)

	if not success then
		failureReason = failureReason or "<Validator function did not supply a message>"
		error(("Property validation failed in %s: %s\n\n%s"):format(
			self.__componentName,
			tostring(failureReason),
			self:getElementTraceback() or "<enable element tracebacks>"),
		0)
	end
end

--[[
	An internal method used by the reconciler to construct a new component
	instance and attach it to the given virtualNode.
]]
function Component:__mount(reconciler, virtualNode)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentClass, "Invalid use of `__mount`")
		internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #2 to be of type VirtualNode")
	end

	local currentElement = virtualNode.currentElement
	local hostParent = virtualNode.hostParent

	-- Contains all the information that we want to keep from consumers of
	-- Roact, or even other parts of the codebase like the reconciler.
	local internalData = {
		reconciler = reconciler,
		virtualNode = virtualNode,
		componentClass = self,
		lifecyclePhase = ComponentLifecyclePhase.Init,
	}

	local instance = {
		[Type] = Type.StatefulComponentInstance,
		[InternalData] = internalData,
	}

	setmetatable(instance, self)

	virtualNode.instance = instance

	local props = currentElement.props

	if self.defaultProps ~= nil then
		props = assign({}, self.defaultProps, props)
	end

	instance:__validateProps(props)

	instance.props = props

	local newContext = assign({}, virtualNode.legacyContext)
	instance._context = newContext

	instance.state = assign({}, instance:__getDerivedState(instance.props, {}))

	if instance.init ~= nil then
		instance:init(instance.props)
		assign(instance.state, instance:__getDerivedState(instance.props, instance.state))
	end

	-- It's possible for init() to redefine _context!
	virtualNode.legacyContext = instance._context

	internalData.lifecyclePhase = ComponentLifecyclePhase.Render
	local renderResult = instance:render()

	internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
	reconciler.updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)

	if instance.didMount ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.DidMount
		instance:didMount()
	end

	if internalData.pendingState ~= nil then
		-- __update will handle pendingState, so we don't pass any new element or state
		instance:__update(nil, nil)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
end

--[[
	Internal method used by the reconciler to clean up any resources held by
	this component instance.
]]
function Component:__unmount()
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__unmount`")
	end

	local internalData = self[InternalData]
	local virtualNode = internalData.virtualNode
	local reconciler = internalData.reconciler

	if self.willUnmount ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.WillUnmount
		self:willUnmount()
	end

	for _, childNode in pairs(virtualNode.children) do
		reconciler.unmountVirtualNode(childNode)
	end
end

--[[
	Internal method used by setState (to trigger updates based on state) and by
	the reconciler (to trigger updates based on props)

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
]]
function Component:__update(updatedElement, updatedState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__update`")
		internalAssert(
			Type.of(updatedElement) == Type.Element or updatedElement == nil,
			"Expected arg #1 to be of type Element or nil"
		)
		internalAssert(
			typeof(updatedState) == "table" or updatedState == nil,
			"Expected arg #2 to be of type table or nil"
		)
	end

	local internalData = self[InternalData]
	local componentClass = internalData.componentClass

	local newProps = self.props
	if updatedElement ~= nil then
		newProps = updatedElement.props

		if componentClass.defaultProps ~= nil then
			newProps = assign({}, componentClass.defaultProps, newProps)
		end

		self:__validateProps(newProps)
	end

	local updateCount = 0
	repeat
		local finalState
		local pendingState = nil

		-- Consume any pending state we might have
		if internalData.pendingState ~= nil then
			pendingState = internalData.pendingState
			internalData.pendingState = nil
		end

		-- Consume a standard update to state or props
		if updatedState ~= nil or newProps ~= self.props then
			if pendingState == nil then
				finalState = updatedState or self.state
			else
				finalState = assign(pendingState, updatedState)
			end

			local derivedState = self:__getDerivedState(newProps, finalState)

			if derivedState ~= nil then
				finalState = assign({}, finalState, derivedState)
			end

			updatedState = nil
		else
			finalState = pendingState
		end

		if not self:__resolveUpdate(newProps, finalState) then
			-- If the update was short-circuited, bubble the result up to the caller
			return false
		end

		updateCount = updateCount + 1

		if updateCount > MAX_PENDING_UPDATES then
			error(tooManyUpdatesMessage:format(tostring(internalData.componentClass)), 3)
		end
	until internalData.pendingState == nil

	return true
end

--[[
	Internal method used by __update to apply new props and state

	Returns true if the update was completed, false if it was cancelled by shouldUpdate
]]
function Component:__resolveUpdate(incomingProps, incomingState)
	if config.internalTypeChecks then
		internalAssert(Type.of(self) == Type.StatefulComponentInstance, "Invalid use of `__resolveUpdate`")
	end

	local internalData = self[InternalData]
	local virtualNode = internalData.virtualNode
	local reconciler = internalData.reconciler

	local oldProps = self.props
	local oldState = self.state

	if incomingProps == nil then
		incomingProps = oldProps
	end
	if incomingState == nil then
		incomingState = oldState
	end

	if self.shouldUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.ShouldUpdate
		local continueWithUpdate = self:shouldUpdate(incomingProps, incomingState)

		if not continueWithUpdate then
			internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
			return false
		end
	end

	if self.willUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.WillUpdate
		self:willUpdate(incomingProps, incomingState)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Render

	self.props = incomingProps
	self.state = incomingState

	local renderResult = virtualNode.instance:render()

	internalData.lifecyclePhase = ComponentLifecyclePhase.ReconcileChildren
	reconciler.updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, renderResult)

	if self.didUpdate ~= nil then
		internalData.lifecyclePhase = ComponentLifecyclePhase.DidUpdate
		self:didUpdate(oldProps, oldState)
	end

	internalData.lifecyclePhase = ComponentLifecyclePhase.Idle
	return true
end

return Component end, _env("RemoteSpy.include.node_modules.roact.src.Component"))() end)

_module("ComponentLifecyclePhase", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.ComponentLifecyclePhase", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)

local ComponentLifecyclePhase = strict({
	-- Component methods
	Init = Symbol.named("init"),
	Render = Symbol.named("render"),
	ShouldUpdate = Symbol.named("shouldUpdate"),
	WillUpdate = Symbol.named("willUpdate"),
	DidMount = Symbol.named("didMount"),
	DidUpdate = Symbol.named("didUpdate"),
	WillUnmount = Symbol.named("willUnmount"),

	-- Phases describing reconciliation status
	ReconcileChildren = Symbol.named("reconcileChildren"),
	Idle = Symbol.named("idle"),
}, "ComponentLifecyclePhase")

return ComponentLifecyclePhase end, _env("RemoteSpy.include.node_modules.roact.src.ComponentLifecyclePhase"))() end)

_module("Config", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Config", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Exposes an interface to set global configuration values for Roact.

	Configuration can only occur once, and should only be done by an application
	using Roact, not a library.

	Any keys that aren't recognized will cause errors. Configuration is only
	intended for configuring Roact itself, not extensions or libraries.

	Configuration is expected to be set immediately after loading Roact. Setting
	configuration values after an application starts may produce unpredictable
	behavior.
]]

-- Every valid configuration value should be non-nil in this table.
local defaultConfig = {
	-- Enables asserts for internal Roact APIs. Useful for debugging Roact itself.
	["internalTypeChecks"] = false,
	-- Enables stricter type asserts for Roact's public API.
	["typeChecks"] = false,
	-- Enables storage of `debug.traceback()` values on elements for debugging.
	["elementTracing"] = false,
	-- Enables validation of component props in stateful components.
	["propValidation"] = false,

	-- Temporary config for enabling a bug fix for processing events based on updates to child instances
	-- outside of the standard lifecycle.
	["tempFixUpdateChildrenReEntrancy"] = false,
}

-- Build a list of valid configuration values up for debug messages.
local defaultConfigKeys = {}
for key in pairs(defaultConfig) do
	table.insert(defaultConfigKeys, key)
end

local Config = {}

function Config.new()
	local self = {}

	self._currentConfig = setmetatable({}, {
		__index = function(_, key)
			local message = (
				"Invalid global configuration key %q. Valid configuration keys are: %s"
			):format(
				tostring(key),
				table.concat(defaultConfigKeys, ", ")
			)

			error(message, 3)
		end
	})

	-- We manually bind these methods here so that the Config's methods can be
	-- used without passing in self, since they eventually get exposed on the
	-- root Roact object.
	self.set = function(...)
		return Config.set(self, ...)
	end

	self.get = function(...)
		return Config.get(self, ...)
	end

	self.scoped = function(...)
		return Config.scoped(self, ...)
	end

	self.set(defaultConfig)

	return self
end

function Config:set(configValues)
	-- Validate values without changing any configuration.
	-- We only want to apply this configuration if it's valid!
	for key, value in pairs(configValues) do
		if defaultConfig[key] == nil then
			local message = (
				"Invalid global configuration key %q (type %s). Valid configuration keys are: %s"
			):format(
				tostring(key),
				typeof(key),
				table.concat(defaultConfigKeys, ", ")
			)

			error(message, 3)
		end

		-- Right now, all configuration values must be boolean.
		if typeof(value) ~= "boolean" then
			local message = (
				"Invalid value %q (type %s) for global configuration key %q. Valid values are: true, false"
			):format(
				tostring(value),
				typeof(value),
				tostring(key)
			)

			error(message, 3)
		end

		self._currentConfig[key] = value
	end
end

function Config:get()
	return self._currentConfig
end

function Config:scoped(configValues, callback)
	local previousValues = {}
	for key, value in pairs(self._currentConfig) do
		previousValues[key] = value
	end

	self.set(configValues)

	local success, result = pcall(callback)

	self.set(previousValues)

	assert(success, result)
end

return Config end, _env("RemoteSpy.include.node_modules.roact.src.Config"))() end)

_module("ElementKind", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.ElementKind", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Contains markers for annotating the type of an element.

	Use `ElementKind` as a key, and values from it as the value.

		local element = {
			[ElementKind] = ElementKind.Host,
		}
]]

local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)
local Portal = require(script.Parent.Portal)

local ElementKind = newproxy(true)

local ElementKindInternal = {
	Portal = Symbol.named("Portal"),
	Host = Symbol.named("Host"),
	Function = Symbol.named("Function"),
	Stateful = Symbol.named("Stateful"),
	Fragment = Symbol.named("Fragment"),
}

function ElementKindInternal.of(value)
	if typeof(value) ~= "table" then
		return nil
	end

	return value[ElementKind]
end

local componentTypesToKinds = {
	["string"] = ElementKindInternal.Host,
	["function"] = ElementKindInternal.Function,
	["table"] = ElementKindInternal.Stateful,
}

function ElementKindInternal.fromComponent(component)
	if component == Portal then
		return ElementKind.Portal
	else
		return componentTypesToKinds[typeof(component)]
	end
end

getmetatable(ElementKind).__index = ElementKindInternal

strict(ElementKindInternal, "ElementKind")

return ElementKind end, _env("RemoteSpy.include.node_modules.roact.src.ElementKind"))() end)

_module("ElementUtils", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.ElementUtils", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Type = require(script.Parent.Type)
local Symbol = require(script.Parent.Symbol)

local function noop()
	return nil
end

local ElementUtils = {}

--[[
	A signal value indicating that a child should use its parent's key, because
	it has no key of its own.

	This occurs when you return only one element from a function component or
	stateful render function.
]]
ElementUtils.UseParentKey = Symbol.named("UseParentKey")

--[[
	Returns an iterator over the children of an element.
	`elementOrElements` may be one of:
	* a boolean
	* nil
	* a single element
	* a fragment
	* a table of elements

	If `elementOrElements` is a boolean or nil, this will return an iterator with
	zero elements.

	If `elementOrElements` is a single element, this will return an iterator with
	one element: a tuple where the first value is ElementUtils.UseParentKey, and
	the second is the value of `elementOrElements`.

	If `elementOrElements` is a fragment or a table, this will return an iterator
	over all the elements of the array.

	If `elementOrElements` is none of the above, this function will throw.
]]
function ElementUtils.iterateElements(elementOrElements)
	local richType = Type.of(elementOrElements)

	-- Single child
	if richType == Type.Element then
		local called = false

		return function()
			if called then
				return nil
			else
				called = true
				return ElementUtils.UseParentKey, elementOrElements
			end
		end
	end

	local regularType = typeof(elementOrElements)

	if elementOrElements == nil or regularType == "boolean" then
		return noop
	end

	if regularType == "table" then
		return pairs(elementOrElements)
	end

	error("Invalid elements")
end

--[[
	Gets the child corresponding to a given key, respecting Roact's rules for
	children. Specifically:
	* If `elements` is nil or a boolean, this will return `nil`, regardless of
		the key given.
	* If `elements` is a single element, this will return `nil`, unless the key
		is ElementUtils.UseParentKey.
	* If `elements` is a table of elements, this will return `elements[key]`.
]]
function ElementUtils.getElementByKey(elements, hostKey)
	if elements == nil or typeof(elements) == "boolean" then
		return nil
	end

	if Type.of(elements) == Type.Element then
		if hostKey == ElementUtils.UseParentKey then
			return elements
		end

		return nil
	end

	if typeof(elements) == "table" then
		return elements[hostKey]
	end

	error("Invalid elements")
end

return ElementUtils end, _env("RemoteSpy.include.node_modules.roact.src.ElementUtils"))() end)

_module("GlobalConfig", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.GlobalConfig", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Exposes a single instance of a configuration as Roact's GlobalConfig.
]]

local Config = require(script.Parent.Config)

return Config.new() end, _env("RemoteSpy.include.node_modules.roact.src.GlobalConfig"))() end)

_module("Logging", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Logging", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Centralized place to handle logging. Lets us:
	- Unit test log output via `Logging.capture`
	- Disable verbose log messages when not debugging Roact

	This should be broken out into a separate library with the addition of
	scoping and logging configuration.
]]

-- Determines whether log messages will go to stdout/stderr
local outputEnabled = true

-- A set of LogInfo objects that should have messages inserted into them.
-- This is a set so that nested calls to Logging.capture will behave.
local collectors = {}

-- A set of all stack traces that have called warnOnce.
local onceUsedLocations = {}

--[[
	Indent a potentially multi-line string with the given number of tabs, in
	addition to any indentation the string already has.
]]
local function indent(source, indentLevel)
	local indentString = ("\t"):rep(indentLevel)

	return indentString .. source:gsub("\n", "\n" .. indentString)
end

--[[
	Indents a list of strings and then concatenates them together with newlines
	into a single string.
]]
local function indentLines(lines, indentLevel)
	local outputBuffer = {}

	for _, line in ipairs(lines) do
		table.insert(outputBuffer, indent(line, indentLevel))
	end

	return table.concat(outputBuffer, "\n")
end

local logInfoMetatable = {}

--[[
	Automatic coercion to strings for LogInfo objects to enable debugging them
	more easily.
]]
function logInfoMetatable:__tostring()
	local outputBuffer = {"LogInfo {"}

	local errorCount = #self.errors
	local warningCount = #self.warnings
	local infosCount = #self.infos

	if errorCount + warningCount + infosCount == 0 then
		table.insert(outputBuffer, "\t(no messages)")
	end

	if errorCount > 0 then
		table.insert(outputBuffer, ("\tErrors (%d) {"):format(errorCount))
		table.insert(outputBuffer, indentLines(self.errors, 2))
		table.insert(outputBuffer, "\t}")
	end

	if warningCount > 0 then
		table.insert(outputBuffer, ("\tWarnings (%d) {"):format(warningCount))
		table.insert(outputBuffer, indentLines(self.warnings, 2))
		table.insert(outputBuffer, "\t}")
	end

	if infosCount > 0 then
		table.insert(outputBuffer, ("\tInfos (%d) {"):format(infosCount))
		table.insert(outputBuffer, indentLines(self.infos, 2))
		table.insert(outputBuffer, "\t}")
	end

	table.insert(outputBuffer, "}")

	return table.concat(outputBuffer, "\n")
end

local function createLogInfo()
	local logInfo = {
		errors = {},
		warnings = {},
		infos = {},
	}

	setmetatable(logInfo, logInfoMetatable)

	return logInfo
end

local Logging = {}

--[[
	Invokes `callback`, capturing all output that happens during its execution.

	Output will not go to stdout or stderr and will instead be put into a
	LogInfo object that is returned. If `callback` throws, the error will be
	bubbled up to the caller of `Logging.capture`.
]]
function Logging.capture(callback)
	local collector = createLogInfo()

	local wasOutputEnabled = outputEnabled
	outputEnabled = false
	collectors[collector] = true

	local success, result = pcall(callback)

	collectors[collector] = nil
	outputEnabled = wasOutputEnabled

	assert(success, result)

	return collector
end

--[[
	Issues a warning with an automatically attached stack trace.
]]
function Logging.warn(messageTemplate, ...)
	local message = messageTemplate:format(...)

	for collector in pairs(collectors) do
		table.insert(collector.warnings, message)
	end

	-- debug.traceback inserts a leading newline, so we trim it here
	local trace = debug.traceback("", 2):sub(2)
	local fullMessage = ("%s\n%s"):format(message, indent(trace, 1))

	if outputEnabled then
		warn(fullMessage)
	end
end

--[[
	Issues a warning like `Logging.warn`, but only outputs once per call site.

	This is useful for marking deprecated functions that might be called a lot;
	using `warnOnce` instead of `warn` will reduce output noise while still
	correctly marking all call sites.
]]
function Logging.warnOnce(messageTemplate, ...)
	local trace = debug.traceback()

	if onceUsedLocations[trace] then
		return
	end

	onceUsedLocations[trace] = true
	Logging.warn(messageTemplate, ...)
end

return Logging end, _env("RemoteSpy.include.node_modules.roact.src.Logging"))() end)

_module("None", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.None", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Symbol = require(script.Parent.Symbol)

-- Marker used to specify that the value is nothing, because nil cannot be
-- stored in tables.
local None = Symbol.named("None")

return None end, _env("RemoteSpy.include.node_modules.roact.src.None"))() end)

_module("NoopRenderer", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.NoopRenderer", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Reference renderer intended for use in tests as well as for documenting the
	minimum required interface for a Roact renderer.
]]

local NoopRenderer = {}

function NoopRenderer.isHostObject(target)
	-- Attempting to use NoopRenderer to target a Roblox instance is almost
	-- certainly a mistake.
	return target == nil
end

function NoopRenderer.mountHostNode(reconciler, node)
end

function NoopRenderer.unmountHostNode(reconciler, node)
end

function NoopRenderer.updateHostNode(reconciler, node, newElement)
	return node
end

return NoopRenderer end, _env("RemoteSpy.include.node_modules.roact.src.NoopRenderer"))() end)

_module("Portal", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Portal", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Symbol = require(script.Parent.Symbol)

local Portal = Symbol.named("Portal")

return Portal end, _env("RemoteSpy.include.node_modules.roact.src.Portal"))() end)

_instance("PropMarkers", "Folder", "RemoteSpy.include.node_modules.roact.src.PropMarkers", "RemoteSpy.include.node_modules.roact.src")

_module("Change", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.PropMarkers.Change", "RemoteSpy.include.node_modules.roact.src.PropMarkers", function () return setfenv(function() --[[
	Change is used to generate special prop keys that can be used to connect to
	GetPropertyChangedSignal.

	Generally, Change is indexed by a Roblox property name:

		Roact.createElement("TextBox", {
			[Roact.Change.Text] = function(rbx)
				print("The TextBox", rbx, "changed text to", rbx.Text)
			end,
		})
]]

local Type = require(script.Parent.Parent.Type)

local Change = {}

local changeMetatable = {
	__tostring = function(self)
		return ("RoactHostChangeEvent(%s)"):format(self.name)
	end,
}

setmetatable(Change, {
	__index = function(self, propertyName)
		local changeListener = {
			[Type] = Type.HostChangeEvent,
			name = propertyName,
		}

		setmetatable(changeListener, changeMetatable)
		Change[propertyName] = changeListener

		return changeListener
	end,
})

return Change
 end, _env("RemoteSpy.include.node_modules.roact.src.PropMarkers.Change"))() end)

_module("Children", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.PropMarkers.Children", "RemoteSpy.include.node_modules.roact.src.PropMarkers", function () return setfenv(function() local Symbol = require(script.Parent.Parent.Symbol)

local Children = Symbol.named("Children")

return Children end, _env("RemoteSpy.include.node_modules.roact.src.PropMarkers.Children"))() end)

_module("Event", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.PropMarkers.Event", "RemoteSpy.include.node_modules.roact.src.PropMarkers", function () return setfenv(function() --[[
	Index into `Event` to get a prop key for attaching to an event on a Roblox
	Instance.

	Example:

		Roact.createElement("TextButton", {
			Text = "Hello, world!",

			[Roact.Event.MouseButton1Click] = function(rbx)
				print("Clicked", rbx)
			end
		})
]]

local Type = require(script.Parent.Parent.Type)

local Event = {}

local eventMetatable = {
	__tostring = function(self)
		return ("RoactHostEvent(%s)"):format(self.name)
	end,
}

setmetatable(Event, {
	__index = function(self, eventName)
		local event = {
			[Type] = Type.HostEvent,
			name = eventName,
		}

		setmetatable(event, eventMetatable)

		Event[eventName] = event

		return event
	end,
})

return Event
 end, _env("RemoteSpy.include.node_modules.roact.src.PropMarkers.Event"))() end)

_module("Ref", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.PropMarkers.Ref", "RemoteSpy.include.node_modules.roact.src.PropMarkers", function () return setfenv(function() local Symbol = require(script.Parent.Parent.Symbol)

local Ref = Symbol.named("Ref")

return Ref end, _env("RemoteSpy.include.node_modules.roact.src.PropMarkers.Ref"))() end)

_module("PureComponent", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.PureComponent", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A version of Component with a `shouldUpdate` method that forces the
	resulting component to be pure.
]]

local Component = require(script.Parent.Component)

local PureComponent = Component:extend("PureComponent")

-- When extend()ing a component, you don't get an extend method.
-- This is to promote composition over inheritance.
-- PureComponent is an exception to this rule.
PureComponent.extend = Component.extend

function PureComponent:shouldUpdate(newProps, newState)
	-- In a vast majority of cases, if state updated, something has updated.
	-- We don't bother checking in this case.
	if newState ~= self.state then
		return true
	end

	if newProps == self.props then
		return false
	end

	for key, value in pairs(newProps) do
		if self.props[key] ~= value then
			return true
		end
	end

	for key, value in pairs(self.props) do
		if newProps[key] ~= value then
			return true
		end
	end

	return false
end

return PureComponent end, _env("RemoteSpy.include.node_modules.roact.src.PureComponent"))() end)

_module("RobloxRenderer", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.RobloxRenderer", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Renderer that deals in terms of Roblox Instances. This is the most
	well-supported renderer after NoopRenderer and is currently the only
	renderer that does anything.
]]

local Binding = require(script.Parent.Binding)
local Children = require(script.Parent.PropMarkers.Children)
local ElementKind = require(script.Parent.ElementKind)
local SingleEventManager = require(script.Parent.SingleEventManager)
local getDefaultInstanceProperty = require(script.Parent.getDefaultInstanceProperty)
local Ref = require(script.Parent.PropMarkers.Ref)
local Type = require(script.Parent.Type)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

local applyPropsError = [[
Error applying props:
	%s
In element:
%s
]]

local updatePropsError = [[
Error updating props:
	%s
In element:
%s
]]

local function identity(...)
	return ...
end

local function applyRef(ref, newHostObject)
	if ref == nil then
		return
	end

	if typeof(ref) == "function" then
		ref(newHostObject)
	elseif Type.of(ref) == Type.Binding then
		Binding.update(ref, newHostObject)
	else
		-- TODO (#197): Better error message
		error(("Invalid ref: Expected type Binding but got %s"):format(
			typeof(ref)
		))
	end
end

local function setRobloxInstanceProperty(hostObject, key, newValue)
	if newValue == nil then
		local hostClass = hostObject.ClassName
		local _, defaultValue = getDefaultInstanceProperty(hostClass, key)
		newValue = defaultValue
	end

	-- Assign the new value to the object
	hostObject[key] = newValue

	return
end

local function removeBinding(virtualNode, key)
	local disconnect = virtualNode.bindings[key]
	disconnect()
	virtualNode.bindings[key] = nil
end

local function attachBinding(virtualNode, key, newBinding)
	local function updateBoundProperty(newValue)
		local success, errorMessage = xpcall(function()
			setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
		end, identity)

		if not success then
			local source = virtualNode.currentElement.source

			if source == nil then
				source = "<enable element tracebacks>"
			end

			local fullMessage = updatePropsError:format(errorMessage, source)
			error(fullMessage, 0)
		end
	end

	if virtualNode.bindings == nil then
		virtualNode.bindings = {}
	end

	virtualNode.bindings[key] = Binding.subscribe(newBinding, updateBoundProperty)

	updateBoundProperty(newBinding:getValue())
end

local function detachAllBindings(virtualNode)
	if virtualNode.bindings ~= nil then
		for _, disconnect in pairs(virtualNode.bindings) do
			disconnect()
		end
	end
end

local function applyProp(virtualNode, key, newValue, oldValue)
	if newValue == oldValue then
		return
	end

	if key == Ref or key == Children then
		-- Refs and children are handled in a separate pass
		return
	end

	local internalKeyType = Type.of(key)

	if internalKeyType == Type.HostEvent or internalKeyType == Type.HostChangeEvent then
		if virtualNode.eventManager == nil then
			virtualNode.eventManager = SingleEventManager.new(virtualNode.hostObject)
		end

		local eventName = key.name

		if internalKeyType == Type.HostChangeEvent then
			virtualNode.eventManager:connectPropertyChange(eventName, newValue)
		else
			virtualNode.eventManager:connectEvent(eventName, newValue)
		end

		return
	end

	local newIsBinding = Type.of(newValue) == Type.Binding
	local oldIsBinding = Type.of(oldValue) == Type.Binding

	if oldIsBinding then
		removeBinding(virtualNode, key)
	end

	if newIsBinding then
		attachBinding(virtualNode, key, newValue)
	else
		setRobloxInstanceProperty(virtualNode.hostObject, key, newValue)
	end
end

local function applyProps(virtualNode, props)
	for propKey, value in pairs(props) do
		applyProp(virtualNode, propKey, value, nil)
	end
end

local function updateProps(virtualNode, oldProps, newProps)
	-- Apply props that were added or updated
	for propKey, newValue in pairs(newProps) do
		local oldValue = oldProps[propKey]

		applyProp(virtualNode, propKey, newValue, oldValue)
	end

	-- Clean up props that were removed
	for propKey, oldValue in pairs(oldProps) do
		local newValue = newProps[propKey]

		if newValue == nil then
			applyProp(virtualNode, propKey, nil, oldValue)
		end
	end
end

local RobloxRenderer = {}

function RobloxRenderer.isHostObject(target)
	return typeof(target) == "Instance"
end

function RobloxRenderer.mountHostNode(reconciler, virtualNode)
	local element = virtualNode.currentElement
	local hostParent = virtualNode.hostParent
	local hostKey = virtualNode.hostKey

	if config.internalTypeChecks then
		internalAssert(ElementKind.of(element) == ElementKind.Host, "Element at given node is not a host Element")
	end
	if config.typeChecks then
		assert(element.props.Name == nil, "Name can not be specified as a prop to a host component in Roact.")
		assert(element.props.Parent == nil, "Parent can not be specified as a prop to a host component in Roact.")
	end

	local instance = Instance.new(element.component)
	virtualNode.hostObject = instance

	local success, errorMessage = xpcall(function()
		applyProps(virtualNode, element.props)
	end, identity)

	if not success then
		local source = element.source

		if source == nil then
			source = "<enable element tracebacks>"
		end

		local fullMessage = applyPropsError:format(errorMessage, source)
		error(fullMessage, 0)
	end

	instance.Name = tostring(hostKey)

	local children = element.props[Children]

	if children ~= nil then
		reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
	end

	instance.Parent = hostParent
	virtualNode.hostObject = instance

	applyRef(element.props[Ref], instance)

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:resume()
	end
end

function RobloxRenderer.unmountHostNode(reconciler, virtualNode)
	local element = virtualNode.currentElement

	applyRef(element.props[Ref], nil)

	for _, childNode in pairs(virtualNode.children) do
		reconciler.unmountVirtualNode(childNode)
	end

	detachAllBindings(virtualNode)

	virtualNode.hostObject:Destroy()
end

function RobloxRenderer.updateHostNode(reconciler, virtualNode, newElement)
	local oldProps = virtualNode.currentElement.props
	local newProps = newElement.props

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:suspend()
	end

	-- If refs changed, detach the old ref and attach the new one
	if oldProps[Ref] ~= newProps[Ref] then
		applyRef(oldProps[Ref], nil)
		applyRef(newProps[Ref], virtualNode.hostObject)
	end

	local success, errorMessage = xpcall(function()
		updateProps(virtualNode, oldProps, newProps)
	end, identity)

	if not success then
		local source = newElement.source

		if source == nil then
			source = "<enable element tracebacks>"
		end

		local fullMessage = updatePropsError:format(errorMessage, source)
		error(fullMessage, 0)
	end

	local children = newElement.props[Children]
	if children ~= nil or oldProps[Children] ~= nil then
		reconciler.updateVirtualNodeWithChildren(virtualNode, virtualNode.hostObject, children)
	end

	if virtualNode.eventManager ~= nil then
		virtualNode.eventManager:resume()
	end

	return virtualNode
end

return RobloxRenderer
 end, _env("RemoteSpy.include.node_modules.roact.src.RobloxRenderer"))() end)

_module("SingleEventManager", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.SingleEventManager", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A manager for a single host virtual node's connected events.
]]

local Logging = require(script.Parent.Logging)

local CHANGE_PREFIX = "Change."

local EventStatus = {
	-- No events are processed at all; they're silently discarded
	Disabled = "Disabled",

	-- Events are stored in a queue; listeners are invoked when the manager is resumed
	Suspended = "Suspended",

	-- Event listeners are invoked as the events fire
	Enabled = "Enabled",
}

local SingleEventManager = {}
SingleEventManager.__index = SingleEventManager

function SingleEventManager.new(instance)
	local self = setmetatable({
		-- The queue of suspended events
		_suspendedEventQueue = {},

		-- All the event connections being managed
		-- Events are indexed by a string key
		_connections = {},

		-- All the listeners being managed
		-- These are stored distinctly from the connections
		-- Connections can have their listeners replaced at runtime
		_listeners = {},

		-- The suspension status of the manager
		-- Managers start disabled and are "resumed" after the initial render
		_status = EventStatus.Disabled,

		-- If true, the manager is processing queued events right now.
		_isResuming = false,

		-- The Roblox instance the manager is managing
		_instance = instance,
	}, SingleEventManager)

	return self
end

function SingleEventManager:connectEvent(key, listener)
	self:_connect(key, self._instance[key], listener)
end

function SingleEventManager:connectPropertyChange(key, listener)
	local success, event = pcall(function()
		return self._instance:GetPropertyChangedSignal(key)
	end)

	if not success then
		error(("Cannot get changed signal on property %q: %s"):format(
			tostring(key),
			event
		), 0)
	end

	self:_connect(CHANGE_PREFIX .. key, event, listener)
end

function SingleEventManager:_connect(eventKey, event, listener)
	-- If the listener doesn't exist we can just disconnect the existing connection
	if listener == nil then
		if self._connections[eventKey] ~= nil then
			self._connections[eventKey]:Disconnect()
			self._connections[eventKey] = nil
		end

		self._listeners[eventKey] = nil
	else
		if self._connections[eventKey] == nil then
			self._connections[eventKey] = event:Connect(function(...)
				if self._status == EventStatus.Enabled then
					self._listeners[eventKey](self._instance, ...)
				elseif self._status == EventStatus.Suspended then
					-- Store this event invocation to be fired when resume is
					-- called.

					local argumentCount = select("#", ...)
					table.insert(self._suspendedEventQueue, { eventKey, argumentCount, ... })
				end
			end)
		end

		self._listeners[eventKey] = listener
	end
end

function SingleEventManager:suspend()
	self._status = EventStatus.Suspended
end

function SingleEventManager:resume()
	-- If we're already resuming events for this instance, trying to resume
	-- again would cause a disaster.
	if self._isResuming then
		return
	end

	self._isResuming = true

	local index = 1

	-- More events might be added to the queue when evaluating events, so we
	-- need to be careful in order to preserve correct evaluation order.
	while index <= #self._suspendedEventQueue do
		local eventInvocation = self._suspendedEventQueue[index]
		local listener = self._listeners[eventInvocation[1]]
		local argumentCount = eventInvocation[2]

		-- The event might have been disconnected since suspension started; in
		-- this case, we drop the event.
		if listener ~= nil then
			-- Wrap the listener in a coroutine to catch errors and handle
			-- yielding correctly.
			local listenerCo = coroutine.create(listener)
			local success, result = coroutine.resume(
				listenerCo,
				self._instance,
				unpack(eventInvocation, 3, 2 + argumentCount))

			-- If the listener threw an error, we log it as a warning, since
			-- there's no way to write error text in Roblox Lua without killing
			-- our thread!
			if not success then
				Logging.warn("%s", result)
			end
		end

		index = index + 1
	end

	self._isResuming = false
	self._status = EventStatus.Enabled
	self._suspendedEventQueue = {}
end

return SingleEventManager end, _env("RemoteSpy.include.node_modules.roact.src.SingleEventManager"))() end)

_module("Symbol", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Symbol", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A 'Symbol' is an opaque marker type.

	Symbols have the type 'userdata', but when printed to the console, the name
	of the symbol is shown.
]]

local Symbol = {}

--[[
	Creates a Symbol with the given name.

	When printed or coerced to a string, the symbol will turn into the string
	given as its name.
]]
function Symbol.named(name)
	assert(type(name) == "string", "Symbols must be created using a string name!")

	local self = newproxy(true)

	local wrappedName = ("Symbol(%s)"):format(name)

	getmetatable(self).__tostring = function()
		return wrappedName
	end

	return self
end

return Symbol end, _env("RemoteSpy.include.node_modules.roact.src.Symbol"))() end)

_module("Type", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.Type", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Contains markers for annotating objects with types.

	To set the type of an object, use `Type` as a key and the actual marker as
	the value:

		local foo = {
			[Type] = Type.Foo,
		}
]]

local Symbol = require(script.Parent.Symbol)
local strict = require(script.Parent.strict)

local Type = newproxy(true)

local TypeInternal = {}

local function addType(name)
	TypeInternal[name] = Symbol.named("Roact" .. name)
end

addType("Binding")
addType("Element")
addType("HostChangeEvent")
addType("HostEvent")
addType("StatefulComponentClass")
addType("StatefulComponentInstance")
addType("VirtualNode")
addType("VirtualTree")

function TypeInternal.of(value)
	if typeof(value) ~= "table" then
		return nil
	end

	return value[Type]
end

getmetatable(Type).__index = TypeInternal

getmetatable(Type).__tostring = function()
	return "RoactType"
end

strict(TypeInternal, "Type")

return Type end, _env("RemoteSpy.include.node_modules.roact.src.Type"))() end)

_module("assertDeepEqual", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.assertDeepEqual", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A utility used to assert that two objects are value-equal recursively. It
	outputs fairly nicely formatted messages to help diagnose why two objects
	would be different.

	This should only be used in tests.
]]

local function deepEqual(a, b)
	if typeof(a) ~= typeof(b) then
		local message = ("{1} is of type %s, but {2} is of type %s"):format(
			typeof(a),
			typeof(b)
		)
		return false, message
	end

	if typeof(a) == "table" then
		local visitedKeys = {}

		for key, value in pairs(a) do
			visitedKeys[key] = true

			local success, innerMessage = deepEqual(value, b[key])
			if not success then
				local message = innerMessage
					:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
					:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

				return false, message
			end
		end

		for key, value in pairs(b) do
			if not visitedKeys[key] then
				local success, innerMessage = deepEqual(value, a[key])

				if not success then
					local message = innerMessage
						:gsub("{1}", ("{1}[%s]"):format(tostring(key)))
						:gsub("{2}", ("{2}[%s]"):format(tostring(key)))

					return false, message
				end
			end
		end

		return true
	end

	if a == b then
		return true
	end

	local message = "{1} ~= {2}"
	return false, message
end

local function assertDeepEqual(a, b)
	local success, innerMessageTemplate = deepEqual(a, b)

	if not success then
		local innerMessage = innerMessageTemplate
			:gsub("{1}", "first")
			:gsub("{2}", "second")

		local message = ("Values were not deep-equal.\n%s"):format(innerMessage)

		error(message, 2)
	end
end

return assertDeepEqual end, _env("RemoteSpy.include.node_modules.roact.src.assertDeepEqual"))() end)

_module("assign", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.assign", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local None = require(script.Parent.None)

--[[
	Merges values from zero or more tables onto a target table. If a value is
	set to None, it will instead be removed from the table.

	This function is identical in functionality to JavaScript's Object.assign.
]]
local function assign(target, ...)
	for index = 1, select("#", ...) do
		local source = select(index, ...)

		if source ~= nil then
			for key, value in pairs(source) do
				if value == None then
					target[key] = nil
				else
					target[key] = value
				end
			end
		end
	end

	return target
end

return assign end, _env("RemoteSpy.include.node_modules.roact.src.assign"))() end)

_module("createContext", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createContext", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Symbol = require(script.Parent.Symbol)
local createFragment = require(script.Parent.createFragment)
local createSignal = require(script.Parent.createSignal)
local Children = require(script.Parent.PropMarkers.Children)
local Component = require(script.Parent.Component)

--[[
	Construct the value that is assigned to Roact's context storage.
]]
local function createContextEntry(currentValue)
	return {
		value = currentValue,
		onUpdate = createSignal(),
	}
end

local function createProvider(context)
	local Provider = Component:extend("Provider")

	function Provider:init(props)
		self.contextEntry = createContextEntry(props.value)
		self:__addContext(context.key, self.contextEntry)
	end

	function Provider:willUpdate(nextProps)
		-- If the provided value changed, immediately update the context entry.
		--
		-- During this update, any components that are reachable will receive
		-- this updated value at the same time as any props and state updates
		-- that are being applied.
		if nextProps.value ~= self.props.value then
			self.contextEntry.value = nextProps.value
		end
	end

	function Provider:didUpdate(prevProps)
		-- If the provided value changed, after we've updated every reachable
		-- component, fire a signal to update the rest.
		--
		-- This signal will notify all context consumers. It's expected that
		-- they will compare the last context value they updated with and only
		-- trigger an update on themselves if this value is different.
		--
		-- This codepath will generally only update consumer components that has
		-- a component implementing shouldUpdate between them and the provider.
		if prevProps.value ~= self.props.value then
			self.contextEntry.onUpdate:fire(self.props.value)
		end
	end

	function Provider:render()
		return createFragment(self.props[Children])
	end

	return Provider
end

local function createConsumer(context)
	local Consumer = Component:extend("Consumer")

	function Consumer.validateProps(props)
		if type(props.render) ~= "function" then
			return false, "Consumer expects a `render` function"
		else
			return true
		end
	end

	function Consumer:init(props)
		-- This value may be nil, which indicates that our consumer is not a
		-- descendant of a provider for this context item.
		self.contextEntry = self:__getContext(context.key)
	end

	function Consumer:render()
		-- Render using the latest available for this context item.
		--
		-- We don't store this value in state in order to have more fine-grained
		-- control over our update behavior.
		local value
		if self.contextEntry ~= nil then
			value = self.contextEntry.value
		else
			value = context.defaultValue
		end

		return self.props.render(value)
	end

	function Consumer:didUpdate()
		-- Store the value that we most recently updated with.
		--
		-- This value is compared in the contextEntry onUpdate hook below.
		if self.contextEntry ~= nil then
			self.lastValue = self.contextEntry.value
		end
	end

	function Consumer:didMount()
		if self.contextEntry ~= nil then
			-- When onUpdate is fired, a new value has been made available in
			-- this context entry, but we may have already updated in the same
			-- update cycle.
			--
			-- To avoid sending a redundant update, we compare the new value
			-- with the last value that we updated with (set in didUpdate) and
			-- only update if they differ. This may happen when an update from a
			-- provider was blocked by an intermediate component that returned
			-- false from shouldUpdate.
			self.disconnect = self.contextEntry.onUpdate:subscribe(function(newValue)
				if newValue ~= self.lastValue then
					-- Trigger a dummy state update.
					self:setState({})
				end
			end)
		end
	end

	function Consumer:willUnmount()
		if self.disconnect ~= nil then
			self.disconnect()
		end
	end

	return Consumer
end

local Context = {}
Context.__index = Context

function Context.new(defaultValue)
	return setmetatable({
		defaultValue = defaultValue,
		key = Symbol.named("ContextKey"),
	}, Context)
end

function Context:__tostring()
	return "RoactContext"
end

local function createContext(defaultValue)
	local context = Context.new(defaultValue)

	return {
		Provider = createProvider(context),
		Consumer = createConsumer(context),
	}
end

return createContext
 end, _env("RemoteSpy.include.node_modules.roact.src.createContext"))() end)

_module("createElement", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createElement", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Children = require(script.Parent.PropMarkers.Children)
local ElementKind = require(script.Parent.ElementKind)
local Logging = require(script.Parent.Logging)
local Type = require(script.Parent.Type)

local config = require(script.Parent.GlobalConfig).get()

local multipleChildrenMessage = [[
The prop `Roact.Children` was defined but was overriden by the third parameter to createElement!
This can happen when a component passes props through to a child element but also uses the `children` argument:

	Roact.createElement("Frame", passedProps, {
		child = ...
	})

Instead, consider using a utility function to merge tables of children together:

	local children = mergeTables(passedProps[Roact.Children], {
		child = ...
	})

	local fullProps = mergeTables(passedProps, {
		[Roact.Children] = children
	})

	Roact.createElement("Frame", fullProps)]]

--[[
	Creates a new element representing the given component.

	Elements are lightweight representations of what a component instance should
	look like.

	Children is a shorthand for specifying `Roact.Children` as a key inside
	props. If specified, the passed `props` table is mutated!
]]
local function createElement(component, props, children)
	if config.typeChecks then
		assert(component ~= nil, "`component` is required")
		assert(typeof(props) == "table" or props == nil, "`props` must be a table or nil")
		assert(typeof(children) == "table" or children == nil, "`children` must be a table or nil")
	end

	if props == nil then
		props = {}
	end

	if children ~= nil then
		if props[Children] ~= nil then
			Logging.warnOnce(multipleChildrenMessage)
		end

		props[Children] = children
	end

	local elementKind = ElementKind.fromComponent(component)

	local element = {
		[Type] = Type.Element,
		[ElementKind] = elementKind,
		component = component,
		props = props,
	}

	if config.elementTracing then
		-- We trim out the leading newline since there's no way to specify the
		-- trace level without also specifying a message.
		element.source = debug.traceback("", 2):sub(2)
	end

	return element
end

return createElement end, _env("RemoteSpy.include.node_modules.roact.src.createElement"))() end)

_module("createFragment", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createFragment", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local ElementKind = require(script.Parent.ElementKind)
local Type = require(script.Parent.Type)

local function createFragment(elements)
	return {
		[Type] = Type.Element,
		[ElementKind] = ElementKind.Fragment,
		elements = elements,
	}
end

return createFragment end, _env("RemoteSpy.include.node_modules.roact.src.createFragment"))() end)

_module("createReconciler", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createReconciler", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local Type = require(script.Parent.Type)
local ElementKind = require(script.Parent.ElementKind)
local ElementUtils = require(script.Parent.ElementUtils)
local Children = require(script.Parent.PropMarkers.Children)
local Symbol = require(script.Parent.Symbol)
local internalAssert = require(script.Parent.internalAssert)

local config = require(script.Parent.GlobalConfig).get()

local InternalData = Symbol.named("InternalData")

--[[
	The reconciler is the mechanism in Roact that constructs the virtual tree
	that later gets turned into concrete objects by the renderer.

	Roact's reconciler is constructed with the renderer as an argument, which
	enables switching to different renderers for different platforms or
	scenarios.

	When testing the reconciler itself, it's common to use `NoopRenderer` with
	spies replacing some methods. The default (and only) reconciler interface
	exposed by Roact right now uses `RobloxRenderer`.
]]
local function createReconciler(renderer)
	local reconciler
	local mountVirtualNode
	local updateVirtualNode
	local unmountVirtualNode

	--[[
		Unmount the given virtualNode, replacing it with a new node described by
		the given element.

		Preserves host properties, depth, and legacyContext from parent.
	]]
	local function replaceVirtualNode(virtualNode, newElement)
		local hostParent = virtualNode.hostParent
		local hostKey = virtualNode.hostKey
		local depth = virtualNode.depth
		local parent = virtualNode.parent

		-- If the node that is being replaced has modified context, we need to
		-- use the original *unmodified* context for the new node
		-- The `originalContext` field will be nil if the context was unchanged
		local context = virtualNode.originalContext or virtualNode.context
		local parentLegacyContext = virtualNode.parentLegacyContext

		unmountVirtualNode(virtualNode)
		local newNode = mountVirtualNode(newElement, hostParent, hostKey, context, parentLegacyContext)

		-- mountVirtualNode can return nil if the element is a boolean
		if newNode ~= nil then
			newNode.depth = depth
			newNode.parent = parent
		end

		return newNode
	end

	--[[
		Utility to update the children of a virtual node based on zero or more
		updated children given as elements.
	]]
	local function updateChildren(virtualNode, hostParent, newChildElements)
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		local removeKeys = {}

		-- Changed or removed children
		for childKey, childNode in pairs(virtualNode.children) do
			local newElement = ElementUtils.getElementByKey(newChildElements, childKey)
			local newNode = updateVirtualNode(childNode, newElement)

			if newNode ~= nil then
				virtualNode.children[childKey] = newNode
			else
				removeKeys[childKey] = true
			end
		end

		for childKey in pairs(removeKeys) do
			virtualNode.children[childKey] = nil
		end

		-- Added children
		for childKey, newElement in ElementUtils.iterateElements(newChildElements) do
			local concreteKey = childKey
			if childKey == ElementUtils.UseParentKey then
				concreteKey = virtualNode.hostKey
			end

			if virtualNode.children[childKey] == nil then
				local childNode = mountVirtualNode(
					newElement,
					hostParent,
					concreteKey,
					virtualNode.context,
					virtualNode.legacyContext
				)

				-- mountVirtualNode can return nil if the element is a boolean
				if childNode ~= nil then
					childNode.depth = virtualNode.depth + 1
					childNode.parent = virtualNode
					virtualNode.children[childKey] = childNode
				end
			end
		end
	end

	local function updateVirtualNodeWithChildren(virtualNode, hostParent, newChildElements)
		updateChildren(virtualNode, hostParent, newChildElements)
	end

	local function updateVirtualNodeWithRenderResult(virtualNode, hostParent, renderResult)
		if Type.of(renderResult) == Type.Element
			or renderResult == nil
			or typeof(renderResult) == "boolean"
		then
			updateChildren(virtualNode, hostParent, renderResult)
		else
			error(("%s\n%s"):format(
				"Component returned invalid children:",
				virtualNode.currentElement.source or "<enable element tracebacks>"
			), 0)
		end
	end

	--[[
		Unmounts the given virtual node and releases any held resources.
	]]
	function unmountVirtualNode(virtualNode)
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end

		local kind = ElementKind.of(virtualNode.currentElement)

		if kind == ElementKind.Host then
			renderer.unmountHostNode(reconciler, virtualNode)
		elseif kind == ElementKind.Function then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		elseif kind == ElementKind.Stateful then
			virtualNode.instance:__unmount()
		elseif kind == ElementKind.Portal then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		elseif kind == ElementKind.Fragment then
			for _, childNode in pairs(virtualNode.children) do
				unmountVirtualNode(childNode)
			end
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end
	end

	local function updateFunctionVirtualNode(virtualNode, newElement)
		local children = newElement.component(newElement.props)

		updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)

		return virtualNode
	end

	local function updatePortalVirtualNode(virtualNode, newElement)
		local oldElement = virtualNode.currentElement
		local oldTargetHostParent = oldElement.props.target

		local targetHostParent = newElement.props.target

		assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

		if targetHostParent ~= oldTargetHostParent then
			return replaceVirtualNode(virtualNode, newElement)
		end

		local children = newElement.props[Children]

		updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)

		return virtualNode
	end

	local function updateFragmentVirtualNode(virtualNode, newElement)
		updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, newElement.elements)

		return virtualNode
	end

	--[[
		Update the given virtual node using a new element describing what it
		should transform into.

		`updateVirtualNode` will return a new virtual node that should replace
		the passed in virtual node. This is because a virtual node can be
		updated with an element referencing a different component!

		In that case, `updateVirtualNode` will unmount the input virtual node,
		mount a new virtual node, and return it in this case, while also issuing
		a warning to the user.
	]]
	function updateVirtualNode(virtualNode, newElement, newState)
		if config.internalTypeChecks then
			internalAssert(Type.of(virtualNode) == Type.VirtualNode, "Expected arg #1 to be of type VirtualNode")
		end
		if config.typeChecks then
			assert(
				Type.of(newElement) == Type.Element or typeof(newElement) == "boolean" or newElement == nil,
				"Expected arg #2 to be of type Element, boolean, or nil"
			)
		end

		-- If nothing changed, we can skip this update
		if virtualNode.currentElement == newElement and newState == nil then
			return virtualNode
		end

		if typeof(newElement) == "boolean" or newElement == nil then
			unmountVirtualNode(virtualNode)
			return nil
		end

		if virtualNode.currentElement.component ~= newElement.component then
			return replaceVirtualNode(virtualNode, newElement)
		end

		local kind = ElementKind.of(newElement)

		local shouldContinueUpdate = true

		if kind == ElementKind.Host then
			virtualNode = renderer.updateHostNode(reconciler, virtualNode, newElement)
		elseif kind == ElementKind.Function then
			virtualNode = updateFunctionVirtualNode(virtualNode, newElement)
		elseif kind == ElementKind.Stateful then
			shouldContinueUpdate = virtualNode.instance:__update(newElement, newState)
		elseif kind == ElementKind.Portal then
			virtualNode = updatePortalVirtualNode(virtualNode, newElement)
		elseif kind == ElementKind.Fragment then
			virtualNode = updateFragmentVirtualNode(virtualNode, newElement)
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end

		-- Stateful components can abort updates via shouldUpdate. If that
		-- happens, we should stop doing stuff at this point.
		if not shouldContinueUpdate then
			return virtualNode
		end

		virtualNode.currentElement = newElement

		return virtualNode
	end

	--[[
		Constructs a new virtual node but not does mount it.
	]]
	local function createVirtualNode(element, hostParent, hostKey, context, legacyContext)
		if config.internalTypeChecks then
			internalAssert(renderer.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
			internalAssert(typeof(context) == "table" or context == nil, "Expected arg #4 to be of type table or nil")
			internalAssert(
				typeof(legacyContext) == "table" or legacyContext == nil,
				"Expected arg #5 to be of type table or nil"
			)
		end
		if config.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(element) == Type.Element or typeof(element) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		return {
			[Type] = Type.VirtualNode,
			currentElement = element,
			depth = 1,
			parent = nil,
			children = {},
			hostParent = hostParent,
			hostKey = hostKey,

			-- Legacy Context API
			-- A table of context values inherited from the parent node
			legacyContext = legacyContext,

			-- A saved copy of the parent context, used when replacing a node
			parentLegacyContext = legacyContext,

			-- Context API
			-- A table of context values inherited from the parent node
			context = context or {},

			-- A saved copy of the unmodified context; this will be updated when
			-- a component adds new context and used when a node is replaced
			originalContext = nil,
		}
	end

	local function mountFunctionVirtualNode(virtualNode)
		local element = virtualNode.currentElement

		local children = element.component(element.props)

		updateVirtualNodeWithRenderResult(virtualNode, virtualNode.hostParent, children)
	end

	local function mountPortalVirtualNode(virtualNode)
		local element = virtualNode.currentElement

		local targetHostParent = element.props.target
		local children = element.props[Children]

		assert(renderer.isHostObject(targetHostParent), "Expected target to be host object")

		updateVirtualNodeWithChildren(virtualNode, targetHostParent, children)
	end

	local function mountFragmentVirtualNode(virtualNode)
		local element = virtualNode.currentElement
		local children = element.elements

		updateVirtualNodeWithChildren(virtualNode, virtualNode.hostParent, children)
	end

	--[[
		Constructs a new virtual node and mounts it, but does not place it into
		the tree.
	]]
	function mountVirtualNode(element, hostParent, hostKey, context, legacyContext)
		if config.internalTypeChecks then
			internalAssert(renderer.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
			internalAssert(
				typeof(legacyContext) == "table" or legacyContext == nil,
				"Expected arg #5 to be of type table or nil"
			)
		end
		if config.typeChecks then
			assert(hostKey ~= nil, "Expected arg #3 to be non-nil")
			assert(
				Type.of(element) == Type.Element or typeof(element) == "boolean",
				"Expected arg #1 to be of type Element or boolean"
			)
		end

		-- Boolean values render as nil to enable terse conditional rendering.
		if typeof(element) == "boolean" then
			return nil
		end

		local kind = ElementKind.of(element)

		local virtualNode = createVirtualNode(element, hostParent, hostKey, context, legacyContext)

		if kind == ElementKind.Host then
			renderer.mountHostNode(reconciler, virtualNode)
		elseif kind == ElementKind.Function then
			mountFunctionVirtualNode(virtualNode)
		elseif kind == ElementKind.Stateful then
			element.component:__mount(reconciler, virtualNode)
		elseif kind == ElementKind.Portal then
			mountPortalVirtualNode(virtualNode)
		elseif kind == ElementKind.Fragment then
			mountFragmentVirtualNode(virtualNode)
		else
			error(("Unknown ElementKind %q"):format(tostring(kind)), 2)
		end

		return virtualNode
	end

	--[[
		Constructs a new Roact virtual tree, constructs a root node for
		it, and mounts it.
	]]
	local function mountVirtualTree(element, hostParent, hostKey)
		if config.typeChecks then
			assert(Type.of(element) == Type.Element, "Expected arg #1 to be of type Element")
			assert(renderer.isHostObject(hostParent) or hostParent == nil, "Expected arg #2 to be a host object")
		end

		if hostKey == nil then
			hostKey = "RoactTree"
		end

		local tree = {
			[Type] = Type.VirtualTree,
			[InternalData] = {
				-- The root node of the tree, which starts into the hierarchy of
				-- Roact component instances.
				rootNode = nil,
				mounted = true,
			},
		}

		tree[InternalData].rootNode = mountVirtualNode(element, hostParent, hostKey)

		return tree
	end

	--[[
		Unmounts the virtual tree, freeing all of its resources.

		No further operations should be done on the tree after it's been
		unmounted, as indicated by its the `mounted` field.
	]]
	local function unmountVirtualTree(tree)
		local internalData = tree[InternalData]
		if config.typeChecks then
			assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
			assert(internalData.mounted, "Cannot unmounted a Roact tree that has already been unmounted")
		end

		internalData.mounted = false

		if internalData.rootNode ~= nil then
			unmountVirtualNode(internalData.rootNode)
		end
	end

	--[[
		Utility method for updating the root node of a virtual tree given a new
		element.
	]]
	local function updateVirtualTree(tree, newElement)
		local internalData = tree[InternalData]
		if config.typeChecks then
			assert(Type.of(tree) == Type.VirtualTree, "Expected arg #1 to be a Roact handle")
			assert(Type.of(newElement) == Type.Element, "Expected arg #2 to be a Roact Element")
		end

		internalData.rootNode = updateVirtualNode(internalData.rootNode, newElement)

		return tree
	end

	local function suspendParentEvents(virtualNode)
		local parentNode = virtualNode.parent
		while parentNode do
			if parentNode.eventManager ~= nil then
				parentNode.eventManager:suspend()
			end

			parentNode = parentNode.parent
		end
	end

	local function resumeParentEvents(virtualNode)
		local parentNode = virtualNode.parent
		while parentNode do
			if parentNode.eventManager ~= nil then
				parentNode.eventManager:resume()
			end

			parentNode = parentNode.parent
		end
	end

	reconciler = {
		mountVirtualTree = mountVirtualTree,
		unmountVirtualTree = unmountVirtualTree,
		updateVirtualTree = updateVirtualTree,

		createVirtualNode = createVirtualNode,
		mountVirtualNode = mountVirtualNode,
		unmountVirtualNode = unmountVirtualNode,
		updateVirtualNode = updateVirtualNode,
		updateVirtualNodeWithChildren = updateVirtualNodeWithChildren,
		updateVirtualNodeWithRenderResult = updateVirtualNodeWithRenderResult,

		suspendParentEvents = suspendParentEvents,
		resumeParentEvents = resumeParentEvents,
	}

	return reconciler
end

return createReconciler
 end, _env("RemoteSpy.include.node_modules.roact.src.createReconciler"))() end)

_module("createReconcilerCompat", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createReconcilerCompat", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Contains deprecated methods from Reconciler. Broken out so that removing
	this shim is easy -- just delete this file and remove it from init.
]]

local Logging = require(script.Parent.Logging)

local reifyMessage = [[
Roact.reify has been renamed to Roact.mount and will be removed in a future release.
Check the call to Roact.reify at:
]]

local teardownMessage = [[
Roact.teardown has been renamed to Roact.unmount and will be removed in a future release.
Check the call to Roact.teardown at:
]]

local reconcileMessage = [[
Roact.reconcile has been renamed to Roact.update and will be removed in a future release.
Check the call to Roact.reconcile at:
]]

local function createReconcilerCompat(reconciler)
	local compat = {}

	function compat.reify(...)
		Logging.warnOnce(reifyMessage)

		return reconciler.mountVirtualTree(...)
	end

	function compat.teardown(...)
		Logging.warnOnce(teardownMessage)

		return reconciler.unmountVirtualTree(...)
	end

	function compat.reconcile(...)
		Logging.warnOnce(reconcileMessage)

		return reconciler.updateVirtualTree(...)
	end

	return compat
end

return createReconcilerCompat end, _env("RemoteSpy.include.node_modules.roact.src.createReconcilerCompat"))() end)

_module("createRef", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createRef", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A ref is nothing more than a binding with a special field 'current'
	that maps to the getValue method of the binding
]]
local Binding = require(script.Parent.Binding)

local function createRef()
	local binding, _ = Binding.create(nil)

	local ref = {}

	--[[
		A ref is just redirected to a binding via its metatable
	]]
	setmetatable(ref, {
		__index = function(self, key)
			if key == "current" then
				return binding:getValue()
			else
				return binding[key]
			end
		end,
		__newindex = function(self, key, value)
			if key == "current" then
				error("Cannot assign to the 'current' property of refs", 2)
			end

			binding[key] = value
		end,
		__tostring = function(self)
			return ("RoactRef(%s)"):format(tostring(binding:getValue()))
		end,
	})

	return ref
end

return createRef end, _env("RemoteSpy.include.node_modules.roact.src.createRef"))() end)

_module("createSignal", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createSignal", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	This is a simple signal implementation that has a dead-simple API.

		local signal = createSignal()

		local disconnect = signal:subscribe(function(foo)
			print("Cool foo:", foo)
		end)

		signal:fire("something")

		disconnect()
]]

local function createSignal()
	local connections = {}
	local suspendedConnections = {}
	local firing = false

	local function subscribe(self, callback)
		assert(typeof(callback) == "function", "Can only subscribe to signals with a function.")

		local connection = {
			callback = callback,
			disconnected = false,
		}

		-- If the callback is already registered, don't add to the suspendedConnection. Otherwise, this will disable
		-- the existing one.
		if firing and not connections[callback] then
			suspendedConnections[callback] = connection
		end

		connections[callback] = connection

		local function disconnect()
			assert(not connection.disconnected, "Listeners can only be disconnected once.")

			connection.disconnected = true
			connections[callback] = nil
			suspendedConnections[callback] = nil
		end

		return disconnect
	end

	local function fire(self, ...)
		firing = true
		for callback, connection in pairs(connections) do
			if not connection.disconnected and not suspendedConnections[callback] then
				callback(...)
			end
		end

		firing = false

		for callback, _ in pairs(suspendedConnections) do
			suspendedConnections[callback] = nil
		end
	end

	return {
		subscribe = subscribe,
		fire = fire,
	}
end

return createSignal
 end, _env("RemoteSpy.include.node_modules.roact.src.createSignal"))() end)

_module("createSpy", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.createSpy", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	A utility used to create a function spy that can be used to robustly test
	that functions are invoked the correct number of times and with the correct
	number of arguments.

	This should only be used in tests.
]]

local assertDeepEqual = require(script.Parent.assertDeepEqual)

local function createSpy(inner)
	local self = {
		callCount = 0,
		values = {},
		valuesLength = 0,
	}

	self.value = function(...)
		self.callCount = self.callCount + 1
		self.values = {...}
		self.valuesLength = select("#", ...)

		if inner ~= nil then
			return inner(...)
		end
	end

	self.assertCalledWith = function(_, ...)
		local len = select("#", ...)

		if self.valuesLength ~= len then
			error(("Expected %d arguments, but was called with %d arguments"):format(
				self.valuesLength,
				len
			), 2)
		end

		for i = 1, len do
			local expected = select(i, ...)

			assert(self.values[i] == expected, "value differs")
		end
	end

	self.assertCalledWithDeepEqual = function(_, ...)
		local len = select("#", ...)

		if self.valuesLength ~= len then
			error(("Expected %d arguments, but was called with %d arguments"):format(
				self.valuesLength,
				len
			), 2)
		end

		for i = 1, len do
			local expected = select(i, ...)

			assertDeepEqual(self.values[i], expected)
		end
	end

	self.captureValues = function(_, ...)
		local len = select("#", ...)
		local result = {}

		assert(self.valuesLength == len, "length of expected values differs from stored values")

		for i = 1, len do
			local key = select(i, ...)
			result[key] = self.values[i]
		end

		return result
	end

	setmetatable(self, {
		__index = function(_, key)
			error(("%q is not a valid member of spy"):format(key))
		end,
	})

	return self
end

return createSpy end, _env("RemoteSpy.include.node_modules.roact.src.createSpy"))() end)

_module("forwardRef", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.forwardRef", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local assign = require(script.Parent.assign)
local None = require(script.Parent.None)
local Ref = require(script.Parent.PropMarkers.Ref)

local config = require(script.Parent.GlobalConfig).get()

local excludeRef = {
	[Ref] = None,
}

--[[
	Allows forwarding of refs to underlying host components. Accepts a render
	callback which accepts props and a ref, and returns an element.
]]
local function forwardRef(render)
	if config.typeChecks then
		assert(typeof(render) == "function", "Expected arg #1 to be a function")
	end

	return function(props)
		local ref = props[Ref]
		local propsWithoutRef = assign({}, props, excludeRef)

		return render(propsWithoutRef, ref)
	end
end

return forwardRef end, _env("RemoteSpy.include.node_modules.roact.src.forwardRef"))() end)

_module("getDefaultInstanceProperty", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.getDefaultInstanceProperty", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Attempts to get the default value of a given property on a Roblox instance.

	This is used by the reconciler in cases where a prop was previously set on a
	primitive component, but is no longer present in a component's new props.

	Eventually, Roblox might provide a nicer API to query the default property
	of an object without constructing an instance of it.
]]

local Symbol = require(script.Parent.Symbol)

local Nil = Symbol.named("Nil")
local _cachedPropertyValues = {}

local function getDefaultInstanceProperty(className, propertyName)
	local classCache = _cachedPropertyValues[className]

	if classCache then
		local propValue = classCache[propertyName]

		-- We have to use a marker here, because Lua doesn't distinguish
		-- between 'nil' and 'not in a table'
		if propValue == Nil then
			return true, nil
		end

		if propValue ~= nil then
			return true, propValue
		end
	else
		classCache = {}
		_cachedPropertyValues[className] = classCache
	end

	local created = Instance.new(className)
	local ok, defaultValue = pcall(function()
		return created[propertyName]
	end)

	created:Destroy()

	if ok then
		if defaultValue == nil then
			classCache[propertyName] = Nil
		else
			classCache[propertyName] = defaultValue
		end
	end

	return ok, defaultValue
end

return getDefaultInstanceProperty end, _env("RemoteSpy.include.node_modules.roact.src.getDefaultInstanceProperty"))() end)

_module("internalAssert", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.internalAssert", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local function internalAssert(condition, message)
	if not condition then
		error(message .. " (This is probably a bug in Roact!)", 3)
	end
end

return internalAssert end, _env("RemoteSpy.include.node_modules.roact.src.internalAssert"))() end)

_module("invalidSetStateMessages", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.invalidSetStateMessages", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	These messages are used by Component to help users diagnose when they're
	calling setState in inappropriate places.

	The indentation may seem odd, but it's necessary to avoid introducing extra
	whitespace into the error messages themselves.
]]
local ComponentLifecyclePhase = require(script.Parent.ComponentLifecyclePhase)

local invalidSetStateMessages = {}

invalidSetStateMessages[ComponentLifecyclePhase.WillUpdate] = [[
setState cannot be used in the willUpdate lifecycle method.
Consider using the didUpdate method instead, or using getDerivedStateFromProps.

Check the definition of willUpdate in the component %q.]]

invalidSetStateMessages[ComponentLifecyclePhase.WillUnmount] = [[
setState cannot be used in the willUnmount lifecycle method.
A component that is being unmounted cannot be updated!

Check the definition of willUnmount in the component %q.]]

invalidSetStateMessages[ComponentLifecyclePhase.ShouldUpdate] = [[
setState cannot be used in the shouldUpdate lifecycle method.
shouldUpdate must be a pure function that only depends on props and state.

Check the definition of shouldUpdate in the component %q.]]

invalidSetStateMessages[ComponentLifecyclePhase.Render] = [[
setState cannot be used in the render method.
render must be a pure function that only depends on props and state.

Check the definition of render in the component %q.]]

invalidSetStateMessages["default"] = [[
setState can not be used in the current situation, because Roact doesn't know
which part of the lifecycle this component is in.

This is a bug in Roact.
It was triggered by the component %q.
]]

return invalidSetStateMessages end, _env("RemoteSpy.include.node_modules.roact.src.invalidSetStateMessages"))() end)

_module("oneChild", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.oneChild", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() --[[
	Retrieves at most one child from the children passed to a component.

	If passed nil or an empty table, will return nil.

	Throws an error if passed more than one child.
]]
local function oneChild(children)
	if not children then
		return nil
	end

	local key, child = next(children)

	if not child then
		return nil
	end

	local after = next(children, key)

	if after then
		error("Expected at most child, had more than one child.", 2)
	end

	return child
end

return oneChild end, _env("RemoteSpy.include.node_modules.roact.src.oneChild"))() end)

_module("strict", "ModuleScript", "RemoteSpy.include.node_modules.roact.src.strict", "RemoteSpy.include.node_modules.roact.src", function () return setfenv(function() local function strict(t, name)
	name = name or tostring(t)

	return setmetatable(t, {
		__index = function(self, key)
			local message = ("%q (%s) is not a valid member of %s"):format(
				tostring(key),
				typeof(key),
				name
			)

			error(message, 2)
		end,

		__newindex = function(self, key, value)
			local message = ("%q (%s) is not a valid member of %s"):format(
				tostring(key),
				typeof(key),
				name
			)

			error(message, 2)
		end,
	})
end

return strict end, _env("RemoteSpy.include.node_modules.roact.src.strict"))() end)

_instance("roact-hooked", "Folder", "RemoteSpy.include.node_modules.roact-hooked", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked.src", "RemoteSpy.include.node_modules.roact-hooked", function () return setfenv(function() local hoc = require(script.hoc)
local hooks = require(script.hooks)

return {
	-- HOC
	withHooks = hoc.withHooks,
	withHooksPure = hoc.withHooksPure,

	-- Hooks
	useBinding = hooks.useBinding,
	useCallback = hooks.useCallback,
	useContext = hooks.useContext,
	useEffect = hooks.useEffect,
	useMemo = hooks.useMemo,
	useMutable = hooks.useMutable,
	useReducer = hooks.useReducer,
	useRef = hooks.useRef,
	useState = hooks.useState,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked.src"))() end)

_module("Roact", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked.src.Roact", "RemoteSpy.include.node_modules.roact-hooked.src", function () return setfenv(function() if script.Parent.Parent:FindFirstChild("Roact") then
	return require(script.Parent.Parent.Roact)
elseif script:FindFirstAncestor("node_modules") then
	return require(script:FindFirstAncestor("node_modules").roact.src)
else
	error("Could not find Roact or roact in the parent hierarchy.")
end
 end, _env("RemoteSpy.include.node_modules.roact-hooked.src.Roact"))() end)

_module("hoc", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked.src.hoc", "RemoteSpy.include.node_modules.roact-hooked.src", function () return setfenv(function() local Roact = require(script.Parent.Roact)
local hooks = require(script.Parent.hooks)
local prepareToUseHooks = hooks.prepareToUseHooks
local finishHooks = hooks.finishHooks
local commitHookEffectListUpdate = hooks.commitHookEffectListUpdate
local commitHookEffectListUnmount = hooks.commitHookEffectListUnmount

local function withHooksImpl(Component, Superclass)
	local componentName = debug.info(Component, "n") or "Component"

	local Proxy = Superclass:extend("withHooks(" .. componentName .. ")")

	function Proxy:render()
		prepareToUseHooks(self)
		local children = Component(self.props)
		finishHooks(self)
		return children
	end

	function Proxy:didMount()
		commitHookEffectListUpdate(self, true)
	end

	function Proxy:didUpdate()
		commitHookEffectListUpdate(self, true)
	end

	function Proxy:willUnmount()
		commitHookEffectListUnmount(self, false)
	end

	return Proxy
end

local function withHooks(Component)
	return withHooksImpl(Component, Roact.Component)
end

local function withHooksPure(Component)
	return withHooksImpl(Component, Roact.PureComponent)
end

return {
	withHooks = withHooks,
	withHooksPure = withHooksPure,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked.src.hoc"))() end)

_module("hooks", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked.src.hooks", "RemoteSpy.include.node_modules.roact-hooked.src", function () return setfenv(function() -- https://github.com/facebook/react/blob/main/packages/react-dom/src/server/ReactPartialRendererHooks.js
-- https://github.com/facebook/react/blob/main/packages/react-reconciler/src/ReactFiberHooks.new.js

local Roact = require(script.Parent.Roact)

local currentlyRenderingComponent
local hookCount = 0
local workInProgressHook

local isReRender

local function finishHooks()
	currentlyRenderingComponent = nil
	hookCount = 0
	workInProgressHook = nil
end

local function prepareToUseHooks(componentIdentity)
	currentlyRenderingComponent = componentIdentity

	if workInProgressHook ~= nil then
		warn("A component failed to fully unmount before rendering a new one.")
		finishHooks()
	end
end

local function resolveCurrentlyRenderingComponent()
	if not currentlyRenderingComponent then
		error(
			'Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:\n' ..
			'1. You might have mismatching versions of React and the renderer (such as React DOM)\n' ..
			'2. You might be breaking the Rules of Hooks\n' ..
			'3. You might have more than one copy of React in the same app\n' ..
			'See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.'
		)
	end

	return currentlyRenderingComponent
end

local function areHookInputsEqual(nextDeps, prevDeps)
	if not prevDeps then
		return false
	end

	if #nextDeps ~= #prevDeps then
		return false
	end

	for i, v in ipairs(nextDeps) do
		if prevDeps[i] ~= v then
			return false
		end
	end

	return true
end

local function createHook()
	return {
		memoizedState = nil,
		next = nil,
		index = hookCount,
	}
end

local function createWorkInProgressHook()
	hookCount += 1

	if not workInProgressHook then
		-- This is the first hook in the list
		if not currentlyRenderingComponent.firstHook then
			-- The component is being mounted. Create a new hook.
			isReRender = false

			local hook = createHook()
			currentlyRenderingComponent.firstHook = hook
			workInProgressHook = hook
		else
			-- The component is being re-rendered. Reuse the first hook.
			isReRender = true
			workInProgressHook = currentlyRenderingComponent.firstHook
		end
	else
		if not workInProgressHook.next then
			isReRender = false

			-- Append to the end of the list
			local hook = createHook()
			workInProgressHook.next = hook
			workInProgressHook = hook
		else
			isReRender = true
			workInProgressHook = workInProgressHook.next
		end
	end

	return workInProgressHook
end

local function commitHookEffectListUpdate(componentIdentity)
	local lastEffect = componentIdentity.lastEffect

	if not lastEffect then
		return
	end

	local firstEffect = lastEffect.next
	local effect = firstEffect

	repeat
		if effect.prevDeps and areHookInputsEqual(effect.deps, effect.prevDeps) then
			-- Nothing changed
			effect = effect.next
			continue
		end

		-- Clear
		local destroy = effect.destroy
		effect.destroy = nil

		if destroy then
			task.spawn(destroy)
		end

		-- Update
		task.spawn(function()
			effect.destroy = effect.create()
		end)

		effect = effect.next
	until effect == firstEffect
end

local function commitHookEffectListUnmount(componentIdentity)
	local lastEffect = componentIdentity.lastEffect

	if not lastEffect then
		return
	end

	local firstEffect = lastEffect.next
	local effect = firstEffect

	repeat
		-- Clear
		local destroy = effect.destroy
		effect.destroy = nil

		if destroy then
			task.spawn(destroy)
		end

		effect = effect.next
	until effect == firstEffect
end

local function pushEffect(create, destroy, deps)
	resolveCurrentlyRenderingComponent()

	local effect = {
		create = create,
		destroy = destroy,
		deps = deps,
		prevDeps = nil,
		next = nil,
	}

	local lastEffect = currentlyRenderingComponent.lastEffect

	if lastEffect then
		local firstEffect = lastEffect.next
		lastEffect.next = effect
		effect.next = firstEffect
		currentlyRenderingComponent.lastEffect = effect
	else
		effect.next = effect
		currentlyRenderingComponent.lastEffect = effect
	end

	return effect
end

local function useEffect(create, deps)
	resolveCurrentlyRenderingComponent()

	local hook = createWorkInProgressHook()
	
	if not isReRender then
		hook.memoizedState = pushEffect(create, nil, deps)
	else
		hook.memoizedState.prevDeps = hook.memoizedState.deps
		hook.memoizedState.deps = deps
		hook.memoizedState.create = create
	end
end

local function basicStateReducer(state, action)
	if type(action) == "function" then
		return action(state)
	else
		return action
	end
end

local function useReducer(reducer, initialArg, init)
	local component = resolveCurrentlyRenderingComponent()
	local hook = createWorkInProgressHook()

	-- Mount
	if not isReRender then
		local initialState

		if reducer == basicStateReducer then
			-- Special case for `useState`.
			if type(initialArg) == "function" then
				initialState = initialArg()
			else
				initialState = initialArg
			end
		else
			if init then
				initialState = init(initialArg)
			else
				initialState = initialArg
			end
		end

		local function dispatch(action)
			local nextState = reducer(hook.memoizedState.state, action)

			if nextState == hook.memoizedState.state then
				return
			end

			hook.memoizedState.state = nextState

			component:setState({
				[hook.index] = nextState,
			})

			return nextState
		end

		hook.memoizedState = {
			dispatch = dispatch,
			state = initialState,
		}
	end

	return hook.memoizedState.state, hook.memoizedState.dispatch
end

local function useState(initialState)
	-- Use useReducer's special case for `useState`.
	return useReducer(basicStateReducer, initialState)
end

local function useMemo(create, deps)
	resolveCurrentlyRenderingComponent()

	local hook = createWorkInProgressHook()
	local prevState = hook.memoizedState

	if prevState ~= nil and deps ~= nil and areHookInputsEqual(deps, prevState.deps) then
		return prevState.value
	end

	local value = create()
	hook.memoizedState = { value = value, deps = deps }

	return value
end

local function useCallback(callback, deps)
	return useMemo(function()
		return callback
	end, deps)
end

local function useMutable(initialValue)
	resolveCurrentlyRenderingComponent()

	local hook = createWorkInProgressHook()

	if not isReRender then
		hook.memoizedState = { current = initialValue }
	end

	return hook.memoizedState
end

local function useRef()
	resolveCurrentlyRenderingComponent()

	local hook = createWorkInProgressHook()

	if not isReRender then
		hook.memoizedState = Roact.createRef()
	end

	return hook.memoizedState
end

local function useBinding(initialValue)
	resolveCurrentlyRenderingComponent()
	
	local hook = createWorkInProgressHook()

	if not isReRender then
		local binding, setValue = Roact.createBinding(initialValue)
		hook.memoizedState = { binding = binding, setValue = setValue }
	end

	return hook.memoizedState.binding, hook.memoizedState.setValue
end

local function useContext(context)
	resolveCurrentlyRenderingComponent()

	local hook = createWorkInProgressHook()

	if not isReRender then
		local consumer = setmetatable({}, { __index = currentlyRenderingComponent })
		context.Consumer.init(consumer)
		hook.memoizedState = consumer.contextEntry
	end

	local contextEntry = hook.memoizedState
	local value, setValue = useState(contextEntry and contextEntry.value)

	useEffect(function()
		return contextEntry.onUpdate:subscribe(setValue)
	end, {})

	return value
end

return {
	-- Hooks
	useBinding = useBinding,
	useCallback = useCallback,
	useContext = useContext,
	useEffect = useEffect,
	useMemo = useMemo,
	useMutable = useMutable,
	useReducer = useReducer,
	useRef = useRef,
	useState = useState,

	-- Internal API
	commitHookEffectListUpdate = commitHookEffectListUpdate,
	commitHookEffectListUnmount = commitHookEffectListUnmount,
	prepareToUseHooks = prepareToUseHooks,
	finishHooks = finishHooks,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked.src.hooks"))() end)

_instance("roact-hooked-plus", "Folder", "RemoteSpy.include.node_modules.roact-hooked-plus", "RemoteSpy.include.node_modules")

_module("out", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out", "RemoteSpy.include.node_modules.roact-hooked-plus", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local exports = {}
exports.arrayToMap = TS.import(script, script, "utils", "array-to-map").arrayToMap
local _binding_utils = TS.import(script, script, "utils", "binding-utils")
exports.asBinding = _binding_utils.asBinding
exports.getBindingValue = _binding_utils.getBindingValue
exports.isBinding = _binding_utils.isBinding
exports.mapBinding = _binding_utils.mapBinding
local _set_timeout = TS.import(script, script, "utils", "set-timeout")
exports.Timeout = _set_timeout.Timeout
exports.clearTimeout = _set_timeout.clearTimeout
exports.setTimeout = _set_timeout.setTimeout
local _set_interval = TS.import(script, script, "utils", "set-interval")
exports.Interval = _set_interval.Interval
exports.clearInterval = _set_interval.clearInterval
exports.setInterval = _set_interval.setInterval
local _flipper = TS.import(script, script, "flipper")
exports.getBinding = _flipper.getBinding
exports.useGoal = _flipper.useGoal
exports.useInstant = _flipper.useInstant
exports.useLinear = _flipper.useLinear
exports.useMotor = _flipper.useMotor
exports.useSpring = _flipper.useSpring
for _k, _v in pairs(TS.import(script, TS.getModule(script, "@rbxts", "flipper").src) or {}) do
	exports[_k] = _v
end
exports.useAnimation = TS.import(script, script, "use-animation").useAnimation
exports.useClickOutside = TS.import(script, script, "use-click-outside").useClickOutside
exports.useDebouncedValue = TS.import(script, script, "use-debounced-value").useDebouncedValue
exports.useDelayedEffect = TS.import(script, script, "use-delayed-effect").useDelayedEffect
exports.useDelayedValue = TS.import(script, script, "use-delayed-value").useDelayedValue
exports.useDidMount = TS.import(script, script, "use-did-mount").useDidMount
exports.useEvent = TS.import(script, script, "use-event").useEvent
exports.useForceUpdate = TS.import(script, script, "use-force-update").useForceUpdate
exports.useGroupMotor = TS.import(script, script, "use-group-motor").useGroupMotor
exports.useHotkeys = TS.import(script, script, "use-hotkeys").useHotkeys
exports.useIdle = TS.import(script, script, "use-idle").useIdle
exports.useInterval = TS.import(script, script, "use-interval").useInterval
exports.useListState = TS.import(script, script, "use-list-state").useListState
exports.useMouse = TS.import(script, script, "use-mouse").useMouse
exports.usePromise = TS.import(script, script, "use-promise").usePromise
exports.useSequenceCallback = TS.import(script, script, "use-sequence-callback").useSequenceCallback
exports.useSequence = TS.import(script, script, "use-sequence").useSequence
exports.useSetState = TS.import(script, script, "use-set-state").useSetState
exports.useSingleMotor = TS.import(script, script, "use-single-motor").useSingleMotor
exports.useToggle = TS.import(script, script, "use-toggle").useToggle
exports.useViewportSize = TS.import(script, script, "use-viewport-size").useViewportSize
return exports
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out"))() end)

_module("flipper", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local exports = {}
exports.getBinding = TS.import(script, script, "get-binding").getBinding
exports.useGoal = TS.import(script, script, "use-goal").useGoal
exports.useInstant = TS.import(script, script, "use-instant").useInstant
exports.useLinear = TS.import(script, script, "use-linear").useLinear
exports.useMotor = TS.import(script, script, "use-motor").useMotor
exports.useSpring = TS.import(script, script, "use-spring").useSpring
return exports
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper"))() end)

_module("get-binding", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.get-binding", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local isMotor = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).isMotor
local AssignedBinding = setmetatable({}, {
	__tostring = function()
		return "AssignedBinding"
	end,
})
local function getBinding(motor)
	assert(motor, "Missing argument #1: motor")
	local _arg0 = isMotor(motor)
	assert(_arg0, "Provided value is not a motor")
	if motor[AssignedBinding] ~= nil then
		return motor[AssignedBinding]
	end
	local binding, setBindingValue = Roact.createBinding(motor:getValue())
	motor:onStep(setBindingValue)
	motor[AssignedBinding] = binding
	return binding
end
return {
	getBinding = getBinding,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.get-binding"))() end)

_module("use-goal", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-goal", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local getBinding = TS.import(script, script.Parent, "get-binding").getBinding
local useMotor = TS.import(script, script.Parent, "use-motor").useMotor
local function useGoal(goal)
	local motor = useMotor(goal._targetValue)
	motor:setGoal(goal)
	return getBinding(motor)
end
return {
	useGoal = useGoal,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-goal"))() end)

_module("use-instant", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-instant", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Instant = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Instant
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useInstant(targetValue)
	return useGoal(Instant.new(targetValue))
end
return {
	useInstant = useInstant,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-instant"))() end)

_module("use-linear", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-linear", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Linear = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Linear
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useLinear(targetValue, options)
	return useGoal(Linear.new(targetValue, options))
end
return {
	useLinear = useLinear,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-linear"))() end)

_module("use-motor", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-motor", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _flipper = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src)
local GroupMotor = _flipper.GroupMotor
local SingleMotor = _flipper.SingleMotor
local useMemo = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useMemo
local function createMotor(initialValue)
	if type(initialValue) == "number" then
		return SingleMotor.new(initialValue)
	elseif type(initialValue) == "table" then
		return GroupMotor.new(initialValue)
	else
		error("Invalid type for initialValue. Expected 'number' or 'table', got '" .. (tostring(initialValue) .. "'"))
	end
end
local function useMotor(initialValue)
	return useMemo(function()
		return createMotor(initialValue)
	end, {})
end
return {
	useMotor = useMotor,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-motor"))() end)

_module("use-spring", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-spring", "RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local useGoal = TS.import(script, script.Parent, "use-goal").useGoal
local function useSpring(targetValue, options)
	return useGoal(Spring.new(targetValue, options))
end
return {
	useSpring = useSpring,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.flipper.use-spring"))() end)

_module("use-animation", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-animation", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Spring = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).Spring
local _flipper = TS.import(script, script.Parent, "flipper")
local getBinding = _flipper.getBinding
local useMotor = _flipper.useMotor
local _object = {}
local _left = "number"
local _arg0 = function(value, ctor, options)
	if options == nil then
		options = {}
	end
	local motor = useMotor(value)
	motor:setGoal(ctor.new(value, options))
	return getBinding(motor)
end
_object[_left] = _arg0
local _left_1 = "Color3"
local _arg0_1 = function(color, ctor, options)
	if options == nil then
		options = {}
	end
	local motor = useMotor({ color.R, color.G, color.B })
	motor:setGoal({ ctor.new(color.R, options), ctor.new(color.G, options), ctor.new(color.B, options) })
	return getBinding(motor):map(function(_param)
		local r = _param[1]
		local g = _param[2]
		local b = _param[3]
		return Color3.new(r, g, b)
	end)
end
_object[_left_1] = _arg0_1
local _left_2 = "UDim"
local _arg0_2 = function(udim, ctor, options)
	local motor = useMotor({ udim.Scale, udim.Offset })
	motor:setGoal({ ctor.new(udim.Scale, options), ctor.new(udim.Offset, options) })
	return getBinding(motor):map(function(_param)
		local s = _param[1]
		local o = _param[2]
		return UDim.new(s, o)
	end)
end
_object[_left_2] = _arg0_2
local _left_3 = "UDim2"
local _arg0_3 = function(udim2, ctor, options)
	local motor = useMotor({ udim2.X.Scale, udim2.X.Offset, udim2.Y.Scale, udim2.Y.Offset })
	motor:setGoal({ ctor.new(udim2.X.Scale, options), ctor.new(udim2.X.Offset, options), ctor.new(udim2.Y.Scale, options), ctor.new(udim2.Y.Offset, options) })
	return getBinding(motor):map(function(_param)
		local xS = _param[1]
		local xO = _param[2]
		local yS = _param[3]
		local yO = _param[4]
		return UDim2.new(xS, math.round(xO), yS, math.round(yO))
	end)
end
_object[_left_3] = _arg0_3
local _left_4 = "Vector2"
local _arg0_4 = function(vector2, ctor, options)
	local motor = useMotor({ vector2.X, vector2.Y })
	motor:setGoal({ ctor.new(vector2.X, options), ctor.new(vector2.Y, options) })
	return getBinding(motor):map(function(_param)
		local X = _param[1]
		local Y = _param[2]
		return Vector2.new(X, Y)
	end)
end
_object[_left_4] = _arg0_4
local _left_5 = "table"
local _arg0_5 = function(array, ctor, options)
	local motor = useMotor(array)
	local _fn = motor
	local _arg0_6 = function(value)
		return ctor.new(value, options)
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#array)
	for _k, _v in ipairs(array) do
		_newValue[_k] = _arg0_6(_v, _k - 1, array)
	end
	-- ▲ ReadonlyArray.map ▲
	_fn:setGoal(_newValue)
	return getBinding(motor)
end
_object[_left_5] = _arg0_5
local motorHooks = _object
local function useAnimation(value, ctor, options)
	local hook = motorHooks[typeof(value)]
	local _arg1 = "useAnimation: Value of type " .. (typeof(value) .. " is not supported")
	assert(hook, _arg1)
	return hook(value, (ctor or Spring), options)
end
return {
	useAnimation = useAnimation,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-animation"))() end)

_module("use-click-outside", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-click-outside", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useRef = _roact_hooked.useRef
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local DEFAULT_INPUTS = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch }
local function contains(object, mouse)
	return object.AbsolutePosition.X <= mouse.X and (object.AbsolutePosition.Y <= mouse.Y and (object.AbsolutePosition.X + object.AbsoluteSize.X >= mouse.X and object.AbsolutePosition.Y + object.AbsoluteSize.Y >= mouse.Y))
end
--[[
	*
	* @see https://mantine.dev/hooks/use-click-outside/
]]
local function useClickOutside(handler, inputs, instances)
	if inputs == nil then
		inputs = DEFAULT_INPUTS
	end
	local ref = useRef()
	useEffect(function()
		local listener = function(input)
			local instance = ref:getValue()
			if type(instances) == "table" then
				local _arg0 = function(obj)
					return obj ~= nil and not contains(obj, input.Position)
				end
				-- ▼ ReadonlyArray.every ▼
				local _result = true
				for _k, _v in ipairs(instances) do
					if not _arg0(_v, _k - 1, instances) then
						_result = false
						break
					end
				end
				-- ▲ ReadonlyArray.every ▲
				local shouldTrigger = _result
				if shouldTrigger then
					handler()
				end
			elseif instance ~= nil and not contains(instance, input.Position) then
				handler()
			end
		end
		local handle = UserInputService.InputBegan:Connect(function(input)
			local _userInputType = input.UserInputType
			if table.find(inputs, _userInputType) ~= nil then
				listener(input)
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, { ref, handler, instances })
	return ref
end
return {
	useClickOutside = useClickOutside,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-click-outside"))() end)

_module("use-debounced-value", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-debounced-value", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local useState = _roact_hooked.useState
local _set_timeout = TS.import(script, script.Parent, "utils", "set-timeout")
local clearTimeout = _set_timeout.clearTimeout
local setTimeout = _set_timeout.setTimeout
--[[
	*
	* @see https://mantine.dev/hooks/use-debounced-value/
]]
local function useDebouncedValue(value, wait, options)
	if options == nil then
		options = {
			leading = false,
		}
	end
	local _value, setValue = useState(value)
	local mountedRef = useMutable(false)
	local timeoutRef = useMutable(nil)
	local cooldownRef = useMutable(false)
	local cancel = function()
		return clearTimeout(timeoutRef.current)
	end
	useEffect(function()
		if mountedRef.current then
			if not cooldownRef.current and options.leading then
				cooldownRef.current = true
				setValue(value)
			else
				cancel()
				timeoutRef.current = setTimeout(function()
					cooldownRef.current = false
					setValue(value)
				end, wait)
			end
		end
	end, { value, options.leading })
	useEffect(function()
		mountedRef.current = true
		return cancel
	end, {})
	return { _value, cancel }
end
return {
	useDebouncedValue = useDebouncedValue,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-debounced-value"))() end)

_module("use-delayed-effect", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-delayed-effect", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local setTimeout = TS.import(script, script.Parent, "utils", "set-timeout").setTimeout
local clearUpdates = TS.import(script, script.Parent, "use-delayed-value").clearUpdates
local nextId = 0
local function useDelayedEffect(effect, delayMs, deps)
	local updates = useMemo(function()
		return {}
	end, {})
	useEffect(function()
		local _original = nextId
		nextId += 1
		local id = _original
		local update = {
			timeout = setTimeout(function()
				effect()
				updates[id] = nil
			end, delayMs),
			resolveTime = os.clock() + delayMs,
		}
		-- Clear all updates that are later than the current one to prevent overlap
		clearUpdates(updates, update.resolveTime)
		updates[id] = update
	end, deps)
	useEffect(function()
		return function()
			return clearUpdates(updates)
		end
	end, {})
end
return {
	useDelayedEffect = useDelayedEffect,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-delayed-effect"))() end)

_module("use-delayed-value", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-delayed-value", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local _set_timeout = TS.import(script, script.Parent, "utils", "set-timeout")
local clearTimeout = _set_timeout.clearTimeout
local setTimeout = _set_timeout.setTimeout
local function clearUpdates(updates, laterThan)
	for id, update in pairs(updates) do
		if laterThan == nil or update.resolveTime >= laterThan then
			updates[id] = nil
			clearTimeout(update.timeout)
		end
	end
end
local nextId = 0
local function useDelayedValue(value, delayMs)
	local delayedValue, setDelayedValue = useState(value)
	local updates = useMemo(function()
		return {}
	end, {})
	useEffect(function()
		local _original = nextId
		nextId += 1
		local id = _original
		local update = {
			timeout = setTimeout(function()
				setDelayedValue(value)
				updates[id] = nil
			end, delayMs),
			resolveTime = os.clock() + delayMs,
		}
		-- Clear all updates that are later than the current one to prevent overlap
		clearUpdates(updates, update.resolveTime)
		updates[id] = update
	end, { value })
	useEffect(function()
		return function()
			return clearUpdates(updates)
		end
	end, {})
	return delayedValue
end
return {
	clearUpdates = clearUpdates,
	useDelayedValue = useDelayedValue,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-delayed-value"))() end)

_module("use-did-mount", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-did-mount", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local function useDidMount()
	local ref = useMutable(true)
	useEffect(function()
		ref.current = false
	end, {})
	return ref.current
end
return {
	useDidMount = useDidMount,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-did-mount"))() end)

_module("use-event", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-event", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useEffect = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useEffect
local function useEvent(event, callback, deps)
	if deps == nil then
		deps = {}
	end
	useEffect(function()
		local handle = event:Connect(callback)
		return function()
			return handle:Disconnect()
		end
	end, deps)
end
return {
	useEvent = useEvent,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-event"))() end)

_module("use-force-update", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-force-update", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useReducer = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useReducer
local reducer = function(value)
	return (value + 1) % 1000000
end
local function useForceUpdate()
	local _, update = useReducer(reducer, 0)
	return update
end
return {
	useForceUpdate = useForceUpdate,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-force-update"))() end)

_module("use-group-motor", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-group-motor", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local GroupMotor = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).GroupMotor
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local function useGroupMotor(initialValue)
	local motor = useMemo(function()
		return GroupMotor.new(initialValue)
	end, {})
	local binding, setBinding = useBinding(motor:getValue())
	useEffect(function()
		motor:onStep(setBinding)
	end, {})
	local setGoal = function(goal)
		motor:setGoal(goal)
	end
	return { binding, setGoal, motor }
end
return {
	useGroupMotor = useGroupMotor,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-group-motor"))() end)

_module("use-hotkeys", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-hotkeys", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useEffect = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useEffect
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local function isHotkeyPressed(hotkey)
	local _exp = UserInputService:GetKeysPressed()
	local _arg0 = function(key)
		return key.KeyCode
	end
	-- ▼ ReadonlyArray.map ▼
	local _newValue = table.create(#_exp)
	for _k, _v in ipairs(_exp) do
		_newValue[_k] = _arg0(_v, _k - 1, _exp)
	end
	-- ▲ ReadonlyArray.map ▲
	local keysDown = _newValue
	local _arg0_1 = function(key)
		if type(key) == "string" then
			local _arg0_2 = Enum.KeyCode[key]
			return table.find(keysDown, _arg0_2) ~= nil
		else
			return table.find(keysDown, key) ~= nil
		end
	end
	-- ▼ ReadonlyArray.every ▼
	local _result = true
	for _k, _v in ipairs(hotkey) do
		if not _arg0_1(_v, _k - 1, hotkey) then
			_result = false
			break
		end
	end
	-- ▲ ReadonlyArray.every ▲
	return _result
end
local function useHotkeys(hotkeys)
	useEffect(function()
		local handle = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
				local _arg0 = function(_param)
					local hotkey = _param[1]
					local event = _param[2]
					local _name = input.KeyCode.Name
					local _condition = table.find(hotkey, _name) ~= nil
					if _condition then
						_condition = isHotkeyPressed(hotkey)
					end
					if _condition then
						event()
					end
				end
				for _k, _v in ipairs(hotkeys) do
					_arg0(_v, _k - 1, hotkeys)
				end
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, { hotkeys })
end
return {
	useHotkeys = useHotkeys,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-hotkeys"))() end)

_module("use-idle", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-idle", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useCallback = _roact_hooked.useCallback
local useEffect = _roact_hooked.useEffect
local useMutable = _roact_hooked.useMutable
local useState = _roact_hooked.useState
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local _set_timeout = TS.import(script, script.Parent, "utils", "set-timeout")
local clearTimeout = _set_timeout.clearTimeout
local setTimeout = _set_timeout.setTimeout
local DEFAULT_INPUTS = { Enum.UserInputType.Keyboard, Enum.UserInputType.Touch, Enum.UserInputType.Gamepad1, Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
local DEFAULT_OPTIONS = {
	inputs = DEFAULT_INPUTS,
	useWindowFocus = true,
	initialState = true,
}
local function useIdle(timeout, options)
	local _object = {}
	for _k, _v in pairs(DEFAULT_OPTIONS) do
		_object[_k] = _v
	end
	if type(options) == "table" then
		for _k, _v in pairs(options) do
			_object[_k] = _v
		end
	end
	local _binding = _object
	local inputs = _binding.inputs
	local useWindowFocus = _binding.useWindowFocus
	local initialState = _binding.initialState
	local idle, setIdle = useState(initialState)
	local timer = useMutable()
	local handleInput = useCallback(function()
		setIdle(false)
		if timer.current then
			clearTimeout(timer.current)
		end
		timer.current = setTimeout(function()
			setIdle(true)
		end, timeout)
	end, { timeout })
	useEffect(function()
		local events = UserInputService.InputBegan:Connect(function(input)
			local _userInputType = input.UserInputType
			if table.find(inputs, _userInputType) ~= nil then
				handleInput()
			end
		end)
		return function()
			events:Disconnect()
		end
	end, { handleInput })
	useEffect(function()
		if not useWindowFocus then
			return nil
		end
		local windowFocused = UserInputService.WindowFocused:Connect(handleInput)
		local windowFocusReleased = UserInputService.WindowFocusReleased:Connect(function()
			if timer.current then
				clearTimeout(timer.current)
				timer.current = nil
			end
			setIdle(true)
		end)
		return function()
			windowFocused:Disconnect()
			windowFocusReleased:Disconnect()
		end
	end, { useWindowFocus, handleInput })
	return idle
end
return {
	useIdle = useIdle,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-idle"))() end)

_module("use-interval", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-interval", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useMutable = _roact_hooked.useMutable
local useState = _roact_hooked.useState
local _set_interval = TS.import(script, script.Parent, "utils", "set-interval")
local clearInterval = _set_interval.clearInterval
local setInterval = _set_interval.setInterval
--[[
	*
	* @see https://mantine.dev/hooks/use-interval/
]]
local function useInterval(fn, intervalMs)
	local active, setActive = useState(false)
	local intervalRef = useMutable()
	local start = function()
		if not active then
			setActive(true)
			intervalRef.current = setInterval(fn, intervalMs)
		end
	end
	local stop = function()
		setActive(false)
		clearInterval(intervalRef.current)
	end
	local toggle = function()
		if active then
			stop()
		else
			start()
		end
	end
	return {
		start = start,
		stop = stop,
		toggle = toggle,
		active = active,
	}
end
return {
	useInterval = useInterval,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-interval"))() end)

_module("use-list-state", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-list-state", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useState = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useState
local function slice(array, start, finish)
	if start == nil then
		start = 0
	end
	if finish == nil then
		finish = math.huge
	end
	local _arg0 = function(_, index)
		return index >= start and index < finish
	end
	-- ▼ ReadonlyArray.filter ▼
	local _newValue = {}
	local _length = 0
	for _k, _v in ipairs(array) do
		if _arg0(_v, _k - 1, array) == true then
			_length += 1
			_newValue[_length] = _v
		end
	end
	-- ▲ ReadonlyArray.filter ▲
	return _newValue
end
--[[
	*
	* @see https://mantine.dev/hooks/use-list-state/
]]
local function useListState(initialValue)
	if initialValue == nil then
		initialValue = {}
	end
	local state, setState = useState(initialValue)
	local append = function(...)
		local items = { ... }
		return setState(function(current)
			local _array = {}
			local _length = #_array
			local _currentLength = #current
			table.move(current, 1, _currentLength, _length + 1, _array)
			_length += _currentLength
			table.move(items, 1, #items, _length + 1, _array)
			return _array
		end)
	end
	local prepend = function(...)
		local items = { ... }
		return setState(function(current)
			local _array = {}
			local _length = #_array
			local _itemsLength = #items
			table.move(items, 1, _itemsLength, _length + 1, _array)
			_length += _itemsLength
			table.move(current, 1, #current, _length + 1, _array)
			return _array
		end)
	end
	local insert = function(index, ...)
		local items = { ... }
		return setState(function(current)
			local _array = {}
			local _length = #_array
			local _array_1 = slice(current, 0, index)
			local _Length = #_array_1
			table.move(_array_1, 1, _Length, _length + 1, _array)
			_length += _Length
			local _itemsLength = #items
			table.move(items, 1, _itemsLength, _length + 1, _array)
			_length += _itemsLength
			local _array_2 = slice(current, index)
			table.move(_array_2, 1, #_array_2, _length + 1, _array)
			return _array
		end)
	end
	local apply = function(fn)
		return setState(function(current)
			local _arg0 = function(item, index)
				return fn(item, index)
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#current)
			for _k, _v in ipairs(current) do
				_newValue[_k] = _arg0(_v, _k - 1, current)
			end
			-- ▲ ReadonlyArray.map ▲
			return _newValue
		end)
	end
	local remove = function(...)
		local indices = { ... }
		return setState(function(current)
			local _arg0 = function(_, index)
				return not (table.find(indices, index) ~= nil)
			end
			-- ▼ ReadonlyArray.filter ▼
			local _newValue = {}
			local _length = 0
			for _k, _v in ipairs(current) do
				if _arg0(_v, _k - 1, current) == true then
					_length += 1
					_newValue[_length] = _v
				end
			end
			-- ▲ ReadonlyArray.filter ▲
			return _newValue
		end)
	end
	local pop = function()
		return setState(function(current)
			local _array = {}
			local _length = #_array
			table.move(current, 1, #current, _length + 1, _array)
			local cloned = _array
			cloned[#cloned] = nil
			return cloned
		end)
	end
	local shift = function()
		return setState(function(current)
			local _array = {}
			local _length = #_array
			table.move(current, 1, #current, _length + 1, _array)
			local cloned = _array
			table.remove(cloned, 1)
			return cloned
		end)
	end
	local reorder = function(_param)
		local from = _param.from
		local to = _param.to
		return setState(function(current)
			local _array = {}
			local _length = #_array
			table.move(current, 1, #current, _length + 1, _array)
			local cloned = _array
			local item = table.remove(cloned, from + 1)
			if item ~= nil then
				table.insert(cloned, to + 1, item)
			end
			return cloned
		end)
	end
	local setItem = function(index, item)
		return setState(function(current)
			local _array = {}
			local _length = #_array
			table.move(current, 1, #current, _length + 1, _array)
			local cloned = _array
			cloned[index + 1] = item
			return cloned
		end)
	end
	local setItemProp = function(index, prop, value)
		return setState(function(current)
			local _array = {}
			local _length = #_array
			table.move(current, 1, #current, _length + 1, _array)
			local cloned = _array
			local _object = {}
			local _spread = cloned[index + 1]
			if type(_spread) == "table" then
				for _k, _v in pairs(_spread) do
					_object[_k] = _v
				end
			end
			_object[prop] = value
			cloned[index + 1] = _object
			return cloned
		end)
	end
	local applyWhere = function(condition, fn)
		return setState(function(current)
			local _arg0 = function(item, index)
				if condition(item, index) then
					return fn(item, index)
				else
					return item
				end
			end
			-- ▼ ReadonlyArray.map ▼
			local _newValue = table.create(#current)
			for _k, _v in ipairs(current) do
				_newValue[_k] = _arg0(_v, _k - 1, current)
			end
			-- ▲ ReadonlyArray.map ▲
			return _newValue
		end)
	end
	return { state, {
		setState = setState,
		append = append,
		prepend = prepend,
		insert = insert,
		pop = pop,
		shift = shift,
		apply = apply,
		applyWhere = applyWhere,
		remove = remove,
		reorder = reorder,
		setItem = setItem,
		setItemProp = setItemProp,
	} }
end
return {
	slice = slice,
	useListState = useListState,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-list-state"))() end)

_module("use-mouse", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-mouse", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local UserInputService = TS.import(script, TS.getModule(script, "@rbxts", "services")).UserInputService
local function useMouse(onChange)
	local location, setLocation = useBinding(UserInputService:GetMouseLocation())
	useEffect(function()
		local handle = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local location = UserInputService:GetMouseLocation()
				setLocation(location)
				local _result = onChange
				if _result ~= nil then
					_result(location)
				end
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, {})
	return location
end
return {
	useMouse = useMouse,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-mouse"))() end)

_module("use-promise", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-promise", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useReducer = _roact_hooked.useReducer
-- https://github.com/bsonntag/react-use-promise
local function resolvePromise(promise)
	if type(promise) == "function" then
		return promise()
	end
	return promise
end
local states = {
	pending = "pending",
	rejected = "rejected",
	resolved = "resolved",
}
local defaultState = {
	err = nil,
	result = nil,
	state = states.pending,
}
local function reducer(state, action)
	local _exp = action.type
	repeat
		if _exp == (states.pending) then
			return defaultState
		end
		if _exp == (states.resolved) then
			return {
				err = nil,
				result = action.payload,
				state = states.resolved,
			}
		end
		if _exp == (states.rejected) then
			return {
				err = action.payload,
				result = nil,
				state = states.rejected,
			}
		end
		return state
	until true
end
local function usePromise(promise, deps)
	if deps == nil then
		deps = {}
	end
	local _binding, dispatch = useReducer(reducer, defaultState)
	local err = _binding.err
	local result = _binding.result
	local state = _binding.state
	useEffect(function()
		promise = resolvePromise(promise)
		if not promise then
			return nil
		end
		local canceled = false
		dispatch({
			type = states.pending,
		})
		local _arg0 = function(result)
			return not canceled and dispatch({
				payload = result,
				type = states.resolved,
			})
		end
		local _arg1 = function(err)
			return not canceled and dispatch({
				payload = err,
				type = states.rejected,
			})
		end
		promise:andThen(_arg0, _arg1)
		return function()
			canceled = true
		end
	end, deps)
	return { result, err, state }
end
return {
	usePromise = usePromise,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-promise"))() end)

_module("use-sequence-callback", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-sequence-callback", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useMutable = _roact_hooked.useMutable
local useDidMount = TS.import(script, script.Parent, "use-did-mount").useDidMount
local resolve = TS.import(script, script.Parent, "utils", "resolve").resolve
local _set_timeout = TS.import(script, script.Parent, "utils", "set-timeout")
local clearTimeout = _set_timeout.clearTimeout
local setTimeout = _set_timeout.setTimeout
local function useSequenceCallback(sequence, onUpdate, deps)
	if deps == nil then
		deps = {}
	end
	local updates = useMemo(function()
		return resolve(sequence.updates)
	end, deps)
	local callback = useMutable(onUpdate)
	callback.current = onUpdate
	local didMount = useDidMount()
	useEffect(function()
		if didMount and sequence.ignoreMount then
			return nil
		end
		local timeout
		local index = 0
		local runNext
		runNext = function()
			if index < #updates then
				local _binding = updates[index + 1]
				local delay = _binding[1]
				local func = _binding[2]
				timeout = setTimeout(function()
					callback.current(func())
					runNext()
				end, delay)
				index += 1
			end
		end
		runNext()
		return function()
			return clearTimeout(timeout)
		end
	end, { updates, didMount })
end
return {
	useSequenceCallback = useSequenceCallback,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-sequence-callback"))() end)

_module("use-sequence", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-sequence", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local useState = _roact_hooked.useState
local useDidMount = TS.import(script, script.Parent, "use-did-mount").useDidMount
local resolve = TS.import(script, script.Parent, "utils", "resolve").resolve
local _set_timeout = TS.import(script, script.Parent, "utils", "set-timeout")
local clearTimeout = _set_timeout.clearTimeout
local setTimeout = _set_timeout.setTimeout
local function useSequence(sequence, deps)
	if deps == nil then
		deps = {}
	end
	local state, setState = useState(sequence.initialState)
	local updates = useMemo(function()
		return resolve(sequence.updates)
	end, deps)
	local didMount = useDidMount()
	useEffect(function()
		if didMount and sequence.ignoreMount then
			return nil
		end
		local timeout
		local index = 0
		local runNext
		runNext = function()
			if index < #updates then
				local _binding = updates[index + 1]
				local delay = _binding[1]
				local func = _binding[2]
				timeout = setTimeout(function()
					setState(func())
					runNext()
				end, delay)
				index += 1
			end
		end
		runNext()
		return function()
			return clearTimeout(timeout)
		end
	end, { updates, didMount })
	return state
end
return {
	useSequence = useSequence,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-sequence"))() end)

_module("use-set-state", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-set-state", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useState = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useState
local resolve = TS.import(script, script.Parent, "utils", "resolve").resolve
--[[
	*
	* @see https://mantine.dev/hooks/use-set-state/
]]
local function useSetState(initialState)
	local state, _setState = useState(initialState)
	local setState = function(statePartial)
		return _setState(function(current)
			local _object = {}
			for _k, _v in pairs(current) do
				_object[_k] = _v
			end
			for _k, _v in pairs(resolve(statePartial, current)) do
				_object[_k] = _v
			end
			return _object
		end)
	end
	return { state, setState }
end
return {
	useSetState = useSetState,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-set-state"))() end)

_module("use-single-motor", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-single-motor", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local SingleMotor = TS.import(script, TS.getModule(script, "@rbxts", "flipper").src).SingleMotor
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useMemo = _roact_hooked.useMemo
local function useSingleMotor(initialValue)
	local motor = useMemo(function()
		return SingleMotor.new(initialValue)
	end, {})
	local binding, setBinding = useBinding(motor:getValue())
	useEffect(function()
		motor:onStep(setBinding)
	end, {})
	local setGoal = function(goal)
		motor:setGoal(goal)
	end
	return { binding, setGoal, motor }
end
return {
	useSingleMotor = useSingleMotor,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-single-motor"))() end)

_module("use-toggle", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-toggle", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local useState = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src).useState
--[[
	*
	* @see https://mantine.dev/hooks/use-toggle/
]]
local function useToggle(initialValue, options)
	local state, setState = useState(initialValue)
	local toggle = function(value)
		if value ~= nil then
			setState(value)
		else
			setState(function(current)
				if current == options[1] then
					return options[2]
				end
				return options[1]
			end)
		end
	end
	return { state, toggle }
end
--[[
	*
	* @see https://mantine.dev/hooks/use-toggle/
]]
local function useBooleanToggle(initialValue)
	if initialValue == nil then
		initialValue = false
	end
	return useToggle(initialValue, { true, false })
end
return {
	useToggle = useToggle,
	useBooleanToggle = useBooleanToggle,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-toggle"))() end)

_module("use-viewport-size", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.use-viewport-size", "RemoteSpy.include.node_modules.roact-hooked-plus.out", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local _roact_hooked = TS.import(script, TS.getModule(script, "@rbxts", "roact-hooked").src)
local useBinding = _roact_hooked.useBinding
local useEffect = _roact_hooked.useEffect
local useState = _roact_hooked.useState
local Workspace = TS.import(script, TS.getModule(script, "@rbxts", "services")).Workspace
--[[
	*
	* Returns a binding to the current screen size.
	* @param onChange Fires when the viewport size changes
]]
local function useViewportSize(onChange)
	local camera, setCamera = useState(Workspace.CurrentCamera)
	local size, setSize = useBinding(camera.ViewportSize)
	useEffect(function()
		local handle = Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if Workspace.CurrentCamera then
				setCamera(Workspace.CurrentCamera)
				setSize(Workspace.CurrentCamera.ViewportSize)
				local _result = onChange
				if _result ~= nil then
					_result(Workspace.CurrentCamera.ViewportSize)
				end
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, {})
	useEffect(function()
		local handle = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			setSize(camera.ViewportSize)
			local _result = onChange
			if _result ~= nil then
				_result(camera.ViewportSize)
			end
		end)
		return function()
			handle:Disconnect()
		end
	end, { camera })
	return size
end
return {
	useViewportSize = useViewportSize,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.use-viewport-size"))() end)

_instance("utils", "Folder", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", "RemoteSpy.include.node_modules.roact-hooked-plus.out")

_module("array-to-map", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.array-to-map", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function arrayToMap(array, callback)
	local map = {}
	local _arg0 = function(value, index)
		local _binding = callback(value, index, array)
		local k = _binding[1]
		local v = _binding[2]
		map[k] = v
	end
	for _k, _v in ipairs(array) do
		_arg0(_v, _k - 1, array)
	end
	return map
end
return {
	arrayToMap = arrayToMap,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.array-to-map"))() end)

_module("binding-utils", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.binding-utils", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local Roact = TS.import(script, TS.getModule(script, "@rbxts", "roact").src)
local function isBinding(value)
	return type(value) == "table" and value.getValue ~= nil
end
local function asBinding(value)
	if isBinding(value) then
		return value
	else
		return (Roact.createBinding(value))
	end
end
local function mapBinding(value, transform)
	if isBinding(value) then
		return value:map(transform)
	else
		return (Roact.createBinding(transform(value)))
	end
end
local function getBindingValue(value)
	if isBinding(value) then
		return value:getValue()
	else
		return value
	end
end
return {
	isBinding = isBinding,
	asBinding = asBinding,
	mapBinding = mapBinding,
	getBindingValue = getBindingValue,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.binding-utils"))() end)

_module("resolve", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.resolve", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local function resolve(fn, ...)
	local args = { ... }
	if type(fn) == "function" then
		return fn(unpack(args))
	else
		return fn
	end
end
return {
	resolve = resolve,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.resolve"))() end)

_module("set-interval", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.set-interval", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local TS = _G[script]
local RunService = TS.import(script, TS.getModule(script, "@rbxts", "services")).RunService
local Interval
do
	Interval = setmetatable({}, {
		__tostring = function()
			return "Interval"
		end,
	})
	Interval.__index = Interval
	function Interval.new(...)
		local self = setmetatable({}, Interval)
		return self:constructor(...) or self
	end
	function Interval:constructor(callback, milliseconds, ...)
		local args = { ... }
		self.running = true
		task.defer(function()
			local clock = 0
			local hb
			hb = RunService.Heartbeat:Connect(function(step)
				clock += step
				if not self.running then
					hb:Disconnect()
				elseif clock >= milliseconds / 1000 then
					clock -= milliseconds / 1000
					callback(unpack(args))
				end
			end)
		end)
	end
	function Interval:clear()
		self.running = false
	end
end
local function setInterval(callback, milliseconds, ...)
	local args = { ... }
	return Interval.new(callback, milliseconds, unpack(args))
end
local function clearInterval(interval)
	local _result = interval
	if _result ~= nil then
		_result:clear()
	end
end
return {
	setInterval = setInterval,
	clearInterval = clearInterval,
	Interval = Interval,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.set-interval"))() end)

_module("set-timeout", "ModuleScript", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.set-timeout", "RemoteSpy.include.node_modules.roact-hooked-plus.out.utils", function () return setfenv(function() -- Compiled with roblox-ts v1.3.3
local Timeout
do
	Timeout = setmetatable({}, {
		__tostring = function()
			return "Timeout"
		end,
	})
	Timeout.__index = Timeout
	function Timeout.new(...)
		local self = setmetatable({}, Timeout)
		return self:constructor(...) or self
	end
	function Timeout:constructor(callback, milliseconds, ...)
		local args = { ... }
		self.running = true
		task.delay(milliseconds / 1000, function()
			if self.running then
				callback(unpack(args))
			end
		end)
	end
	function Timeout:clear()
		self.running = false
	end
end
local function setTimeout(callback, milliseconds, ...)
	local args = { ... }
	return Timeout.new(callback, milliseconds, unpack(args))
end
local function clearTimeout(timeout)
	timeout:clear()
end
return {
	setTimeout = setTimeout,
	clearTimeout = clearTimeout,
	Timeout = Timeout,
}
 end, _env("RemoteSpy.include.node_modules.roact-hooked-plus.out.utils.set-timeout"))() end)

_instance("roact-rodux-hooked", "Folder", "RemoteSpy.include.node_modules.roact-rodux-hooked", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src", "RemoteSpy.include.node_modules.roact-rodux-hooked", function () return setfenv(function() local RoactRoduxContext = require(script.components.Context)
local StoreProvider = require(script.components.StoreProvider)

local useDispatch = require(script.hooks.useDispatch)
local useSelector = require(script.hooks.useSelector)
local useStore = require(script.hooks.useStore)

local shallowEqual = require(script.utils.shallowEqual)

return {
	useDispatch = useDispatch,
	useSelector = useSelector,
	useStore = useStore,
	shallowEqual = shallowEqual,
	StoreProvider = StoreProvider,
	RoactRoduxContext = RoactRoduxContext,
}
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src"))() end)

_module("Roact", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.Roact", "RemoteSpy.include.node_modules.roact-rodux-hooked.src", function () return setfenv(function() if script:FindFirstAncestor("node_modules") then
	return require(script:FindFirstAncestor("node_modules").roact.src)
elseif script.Parent.Parent:FindFirstChild("Roact") then
	return require(script.Parent.Parent.Roact)
else
	error("Could not find Roact or @rbxts/roact in the parent hierarchy.")
end
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.Roact"))() end)

_module("RoactHooked", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.RoactHooked", "RemoteSpy.include.node_modules.roact-rodux-hooked.src", function () return setfenv(function() if script:FindFirstAncestor("node_modules") then
	return require(script:FindFirstAncestor("node_modules")["roact-hooked"].src)
elseif script.Parent.Parent:FindFirstChild("roact-hooked") then
	return require(script.Parent.Parent["roact-hooked"])
else
	error("Could not find @rbxts/roact-hooked in the parent hierarchy.")
end
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.RoactHooked"))() end)

_instance("components", "Folder", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.components", "RemoteSpy.include.node_modules.roact-rodux-hooked.src")

_module("Context", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.components.Context", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.components", function () return setfenv(function() local Roact = require(script.Parent.Parent.Roact)

local RoactRoduxContext = Roact.createContext()

return RoactRoduxContext
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.components.Context"))() end)

_module("StoreProvider", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.components.StoreProvider", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.components", function () return setfenv(function() local Roact = require(script.Parent.Parent.Roact)
local RoactRoduxContext = require(script.Parent.Context)

local function StoreProvider(props)
	return (
		Roact.createElement(RoactRoduxContext.Provider, {
			value = props.store,
		}, props[Roact.Children])
	)
end

return StoreProvider
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.components.StoreProvider"))() end)

_instance("hooks", "Folder", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks", "RemoteSpy.include.node_modules.roact-rodux-hooked.src")

_module("useDispatch", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useDispatch", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks", function () return setfenv(function() local Hooks = require(script.Parent.Parent.RoactHooked)
local useStore = require(script.Parent.useStore)

local function useDispatch()
	local store = useStore()

	local dispatch = Hooks.useCallback(function(action)
		store:dispatch(action)
	end, { store })

	return dispatch
end

return useDispatch
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useDispatch"))() end)

_module("useSelector", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useSelector", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks", function () return setfenv(function() -- https://github.com/reduxjs/react-redux/blob/7.x/src/hooks/useSelector.js

local Hooks = require(script.Parent.Parent.RoactHooked)
local useStore = require(script.Parent.useStore)

local function refEquality(a, b)
	return a == b
end

local function useSelector(selector, isEqual)
	if isEqual == nil then
		isEqual = refEquality
	end

	local _, forceRender = Hooks.useReducer(function(n)
		return n + 1
	end, 0)

	local store = useStore()

	local latestSubscriptionCallbackError = Hooks.useMutable()
	local latestSelector = Hooks.useMutable()
	local latestStoreState = Hooks.useMutable()
	local latestSelectedState = Hooks.useMutable()

	local storeState = store:getState()
	local selectedState

	local success, err = pcall(function()
		if 
			selector ~= latestSelector.current or
			storeState ~= latestStoreState.current or
			latestSubscriptionCallbackError.current
		then
			local newSelectedState = selector(storeState)

			-- ensure latest selected state is reused so that a custom equality
			-- function can result in identical references
			if
				latestSelectedState.current == nil or
				not isEqual(newSelectedState, latestSelectedState.current)
			then
				selectedState = newSelectedState
			else
				selectedState = latestSelectedState.current
			end
		else
			selectedState = latestSelectedState.current
		end
	end)

	if not success then
		if latestSubscriptionCallbackError.current then
			err ..= (
				"\nThe error may be correlated with this previous error:\n" ..
				latestSubscriptionCallbackError.current ..
				"\n\n"
			)

			error(err)
		end
	end

	Hooks.useEffect(function()
		latestSelector.current = selector
		latestStoreState.current = storeState
		latestSelectedState.current = selectedState
		latestSubscriptionCallbackError.current = nil
	end)

	Hooks.useEffect(function()
		local function checkForUpdates(newStoreState)
			local success, shouldRender = pcall(function()
				-- Avoid calling selector multiple times if the store's state has not changed
				if newStoreState == latestStoreState.current then
					return false
				end

				local newSelectedState = latestSelector.current(newStoreState)

				if isEqual(newSelectedState, latestSelectedState.current) then
					return false
				end

				latestSelectedState.current = newSelectedState
				latestStoreState.current = newStoreState

				return true
			end)

			if not success then
				-- we ignore all errors here, since when the component
				-- is re-rendered, the selectors are called again, and
				-- will throw again, if neither props nor store state
				-- changed
				latestSubscriptionCallbackError.current = shouldRender
			elseif shouldRender then
				-- pcall will not block this rerender in the guard clauses,
				-- so use the returned boolean value to decide
				forceRender()
			end
		end

		local subscription = store.changed:connect(checkForUpdates)

		checkForUpdates(storeState)

		return function()
			subscription:disconnect()
		end
	end, { store })

	return selectedState
end

return useSelector
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useSelector"))() end)

_module("useStore", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useStore", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks", function () return setfenv(function() local Hooks = require(script.Parent.Parent.RoactHooked)
local RoactRoduxContext = require(script.Parent.Parent.components.Context)

local function useStore()
	return Hooks.useContext(RoactRoduxContext)
end

return useStore
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.hooks.useStore"))() end)

_instance("utils", "Folder", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.utils", "RemoteSpy.include.node_modules.roact-rodux-hooked.src")

_module("shallowEqual", "ModuleScript", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.utils.shallowEqual", "RemoteSpy.include.node_modules.roact-rodux-hooked.src.utils", function () return setfenv(function() local function shallowEqual(left, right)
	if left == right then
		return true
	end

	if type(left) ~= "table" or type(right) ~= "table" then
		return false
	end

	if #left ~= #right then
		return false
	end

	for key, value in pairs(left) do
		if right[key] ~= value then
			return false
		end
	end

	return true
end

return shallowEqual
 end, _env("RemoteSpy.include.node_modules.roact-rodux-hooked.src.utils.shallowEqual"))() end)

_instance("rodux", "Folder", "RemoteSpy.include.node_modules.rodux", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src", "RemoteSpy.include.node_modules.rodux", function () return setfenv(function() local Store = require(script.Store)
local createReducer = require(script.createReducer)
local combineReducers = require(script.combineReducers)
local makeActionCreator = require(script.makeActionCreator)
local loggerMiddleware = require(script.loggerMiddleware)
local thunkMiddleware = require(script.thunkMiddleware)

return {
	Store = Store,
	createReducer = createReducer,
	combineReducers = combineReducers,
	makeActionCreator = makeActionCreator,
	loggerMiddleware = loggerMiddleware.middleware,
	thunkMiddleware = thunkMiddleware,
}
 end, _env("RemoteSpy.include.node_modules.rodux.src"))() end)

_module("NoYield", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.NoYield", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() --!nocheck

--[[
	Calls a function and throws an error if it attempts to yield.

	Pass any number of arguments to the function after the callback.

	This function supports multiple return; all results returned from the
	given function will be returned.
]]

local function resultHandler(co, ok, ...)
	if not ok then
		local message = (...)
		error(debug.traceback(co, message), 2)
	end

	if coroutine.status(co) ~= "dead" then
		error(debug.traceback(co, "Attempted to yield inside changed event!"), 2)
	end

	return ...
end

local function NoYield(callback, ...)
	local co = coroutine.create(callback)

	return resultHandler(co, coroutine.resume(co, ...))
end

return NoYield
 end, _env("RemoteSpy.include.node_modules.rodux.src.NoYield"))() end)

_module("Signal", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.Signal", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() --[[
	A limited, simple implementation of a Signal.

	Handlers are fired in order, and (dis)connections are properly handled when
	executing an event.
]]
local function immutableAppend(list, ...)
	local new = {}
	local len = #list

	for key = 1, len do
		new[key] = list[key]
	end

	for i = 1, select("#", ...) do
		new[len + i] = select(i, ...)
	end

	return new
end

local function immutableRemoveValue(list, removeValue)
	local new = {}

	for i = 1, #list do
		if list[i] ~= removeValue then
			table.insert(new, list[i])
		end
	end

	return new
end

local Signal = {}

Signal.__index = Signal

function Signal.new(store)
	local self = {
		_listeners = {},
		_store = store
	}

	setmetatable(self, Signal)

	return self
end

function Signal:connect(callback)
	if typeof(callback) ~= "function" then
		error("Expected the listener to be a function.")
	end

	if self._store and self._store._isDispatching then
		error(
			'You may not call store.changed:connect() while the reducer is executing. ' ..
				'If you would like to be notified after the store has been updated, subscribe from a ' ..
				'component and invoke store:getState() in the callback to access the latest state. '
		)
	end

	local listener = {
		callback = callback,
		disconnected = false,
		connectTraceback = debug.traceback(),
		disconnectTraceback = nil
	}

	self._listeners = immutableAppend(self._listeners, listener)

	local function disconnect()
		if listener.disconnected then
			error((
				"Listener connected at: \n%s\n" ..
				"was already disconnected at: \n%s\n"
			):format(
				tostring(listener.connectTraceback),
				tostring(listener.disconnectTraceback)
			))
		end

		if self._store and self._store._isDispatching then
			error("You may not unsubscribe from a store listener while the reducer is executing.")
		end

		listener.disconnected = true
		listener.disconnectTraceback = debug.traceback()
		self._listeners = immutableRemoveValue(self._listeners, listener)
	end

	return {
		disconnect = disconnect
	}
end

function Signal:fire(...)
	for _, listener in ipairs(self._listeners) do
		if not listener.disconnected then
			listener.callback(...)
		end
	end
end

return Signal end, _env("RemoteSpy.include.node_modules.rodux.src.Signal"))() end)

_module("Store", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.Store", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)
local NoYield = require(script.Parent.NoYield)

local ACTION_LOG_LENGTH = 3

local rethrowErrorReporter = {
	reportReducerError = function(prevState, action, errorResult)
		error(string.format("Received error: %s\n\n%s", errorResult.message, errorResult.thrownValue))
	end,
	reportUpdateError = function(prevState, currentState, lastActions, errorResult)
		error(string.format("Received error: %s\n\n%s", errorResult.message, errorResult.thrownValue))
	end,
}

local function tracebackReporter(message)
	return debug.traceback(tostring(message))
end

local Store = {}

-- This value is exposed as a private value so that the test code can stay in
-- sync with what event we listen to for dispatching the Changed event.
-- It may not be Heartbeat in the future.
Store._flushEvent = RunService.Heartbeat

Store.__index = Store

--[[
	Create a new Store whose state is transformed by the given reducer function.

	Each time an action is dispatched to the store, the new state of the store
	is given by:

		state = reducer(state, action)

	Reducers do not mutate the state object, so the original state is still
	valid.
]]
function Store.new(reducer, initialState, middlewares, errorReporter)
	assert(typeof(reducer) == "function", "Bad argument #1 to Store.new, expected function.")
	assert(middlewares == nil or typeof(middlewares) == "table", "Bad argument #3 to Store.new, expected nil or table.")
	if middlewares ~= nil then
		for i=1, #middlewares, 1 do
			assert(
				typeof(middlewares[i]) == "function",
				("Expected the middleware ('%s') at index %d to be a function."):format(tostring(middlewares[i]), i)
			)
		end
	end

	local self = {}

	self._errorReporter = errorReporter or rethrowErrorReporter
	self._isDispatching = false
	self._reducer = reducer
	local initAction = {
		type = "@@INIT",
	}
	self._actionLog = { initAction }
	local ok, result = xpcall(function()
		self._state = reducer(initialState, initAction)
	end, tracebackReporter)
	if not ok then
		self._errorReporter.reportReducerError(initialState, initAction, {
			message = "Caught error in reducer with init",
			thrownValue = result,
		})
		self._state = initialState
	end
	self._lastState = self._state

	self._mutatedSinceFlush = false
	self._connections = {}

	self.changed = Signal.new(self)

	setmetatable(self, Store)

	local connection = self._flushEvent:Connect(function()
		self:flush()
	end)
	table.insert(self._connections, connection)

	if middlewares then
		local unboundDispatch = self.dispatch
		local dispatch = function(...)
			return unboundDispatch(self, ...)
		end

		for i = #middlewares, 1, -1 do
			local middleware = middlewares[i]
			dispatch = middleware(dispatch, self)
		end

		self.dispatch = function(_self, ...)
			return dispatch(...)
		end
	end

	return self
end

--[[
	Get the current state of the Store. Do not mutate this!
]]
function Store:getState()
	if self._isDispatching then
		error(("You may not call store:getState() while the reducer is executing. " ..
			"The reducer (%s) has already received the state as an argument. " ..
			"Pass it down from the top reducer instead of reading it from the store."):format(tostring(self._reducer)))
	end

	return self._state
end

--[[
	Dispatch an action to the store. This allows the store's reducer to mutate
	the state of the application by creating a new copy of the state.

	Listeners on the changed event of the store are notified when the state
	changes, but not necessarily on every Dispatch.
]]
function Store:dispatch(action)
	if typeof(action) ~= "table" then
		error(("Actions must be tables. " ..
			"Use custom middleware for %q actions."):format(typeof(action)),
			2
		)
	end

	if action.type == nil then
		error("Actions may not have an undefined 'type' property. " ..
			"Have you misspelled a constant? \n" ..
			tostring(action), 2)
	end

	if self._isDispatching then
		error("Reducers may not dispatch actions.")
	end

	local ok, result = pcall(function()
		self._isDispatching = true
		self._state = self._reducer(self._state, action)
		self._mutatedSinceFlush = true
	end)

	self._isDispatching = false

	if not ok then
		self._errorReporter.reportReducerError(
			self._state,
			action,
			{
				message = "Caught error in reducer",
				thrownValue = result,
			}
		)
	end

	if #self._actionLog == ACTION_LOG_LENGTH then
		table.remove(self._actionLog, 1)
	end
	table.insert(self._actionLog, action)
end

--[[
	Marks the store as deleted, disconnecting any outstanding connections.
]]
function Store:destruct()
	for _, connection in ipairs(self._connections) do
		connection:Disconnect()
	end

	self._connections = nil
end

--[[
	Flush all pending actions since the last change event was dispatched.
]]
function Store:flush()
	if not self._mutatedSinceFlush then
		return
	end

	self._mutatedSinceFlush = false

	-- On self.changed:fire(), further actions may be immediately dispatched, in
	-- which case self._lastState will be set to the most recent self._state,
	-- unless we cache this value first
	local state = self._state

	local ok, errorResult = xpcall(function()
		-- If a changed listener yields, *very* surprising bugs can ensue.
		-- Because of that, changed listeners cannot yield.
		NoYield(function()
			self.changed:fire(state, self._lastState)
		end)
	end, tracebackReporter)

	if not ok then
		self._errorReporter.reportUpdateError(
			self._lastState,
			state,
			self._actionLog,
			{
				message = "Caught error flushing store updates",
				thrownValue = errorResult,
			}
		)
	end

	self._lastState = state
end

return Store
 end, _env("RemoteSpy.include.node_modules.rodux.src.Store"))() end)

_module("combineReducers", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.combineReducers", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() --[[
	Create a composite reducer from a map of keys and sub-reducers.
]]
local function combineReducers(map)
	return function(state, action)
		-- If state is nil, substitute it with a blank table.
		if state == nil then
			state = {}
		end

		local newState = {}

		for key, reducer in pairs(map) do
			-- Each reducer gets its own state, not the entire state table
			newState[key] = reducer(state[key], action)
		end

		return newState
	end
end

return combineReducers
 end, _env("RemoteSpy.include.node_modules.rodux.src.combineReducers"))() end)

_module("createReducer", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.createReducer", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() return function(initialState, handlers)
	return function(state, action)
		if state == nil then
			state = initialState
		end

		local handler = handlers[action.type]

		if handler then
			return handler(state, action)
		end

		return state
	end
end
 end, _env("RemoteSpy.include.node_modules.rodux.src.createReducer"))() end)

_module("loggerMiddleware", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.loggerMiddleware", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() -- We want to be able to override outputFunction in tests, so the shape of this
-- module is kind of unconventional.
--
-- We fix it this weird shape in init.lua.
local prettyPrint = require(script.Parent.prettyPrint)
local loggerMiddleware = {
	outputFunction = print,
}

function loggerMiddleware.middleware(nextDispatch, store)
	return function(action)
		local result = nextDispatch(action)

		loggerMiddleware.outputFunction(("Action dispatched: %s\nState changed to: %s"):format(
			prettyPrint(action),
			prettyPrint(store:getState())
		))

		return result
	end
end

return loggerMiddleware
 end, _env("RemoteSpy.include.node_modules.rodux.src.loggerMiddleware"))() end)

_module("makeActionCreator", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.makeActionCreator", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() --[[
	A helper function to define a Rodux action creator with an associated name.
]]
local function makeActionCreator(name, fn)
	assert(type(name) == "string", "Bad argument #1: Expected a string name for the action creator")

	assert(type(fn) == "function", "Bad argument #2: Expected a function that creates action objects")

	return setmetatable({
		name = name,
	}, {
		__call = function(self, ...)
			local result = fn(...)

			assert(type(result) == "table", "Invalid action: An action creator must return a table")

			result.type = name

			return result
		end
	})
end

return makeActionCreator
 end, _env("RemoteSpy.include.node_modules.rodux.src.makeActionCreator"))() end)

_module("prettyPrint", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.prettyPrint", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() local indent = "    "

local function prettyPrint(value, indentLevel)
	indentLevel = indentLevel or 0
	local output = {}

	if typeof(value) == "table" then
		table.insert(output, "{\n")

		for tableKey, tableValue in pairs(value) do
			table.insert(output, indent:rep(indentLevel + 1))
			table.insert(output, tostring(tableKey))
			table.insert(output, " = ")

			table.insert(output, prettyPrint(tableValue, indentLevel + 1))
			table.insert(output, "\n")
		end

		table.insert(output, indent:rep(indentLevel))
		table.insert(output, "}")
	elseif typeof(value) == "string" then
		table.insert(output, string.format("%q", value))
		table.insert(output, " (string)")
	else
		table.insert(output, tostring(value))
		table.insert(output, " (")
		table.insert(output, typeof(value))
		table.insert(output, ")")
	end

	return table.concat(output, "")
end

return prettyPrint end, _env("RemoteSpy.include.node_modules.rodux.src.prettyPrint"))() end)

_module("thunkMiddleware", "ModuleScript", "RemoteSpy.include.node_modules.rodux.src.thunkMiddleware", "RemoteSpy.include.node_modules.rodux.src", function () return setfenv(function() --[[
	A middleware that allows for functions to be dispatched.
	Functions will receive a single argument, the store itself.
	This middleware consumes the function; middleware further down the chain
	will not receive it.
]]
local function tracebackReporter(message)
	return debug.traceback(message)
end

local function thunkMiddleware(nextDispatch, store)
	return function(action)
		if typeof(action) == "function" then
			local ok, result = xpcall(function()
				return action(store)
			end, tracebackReporter)

			if not ok then
				-- report the error and move on so it's non-fatal app
				store._errorReporter.reportReducerError(store:getState(), action, {
					message = "Caught error in thunk",
					thrownValue = result,
				})
				return nil
			end

			return result
		end

		return nextDispatch(action)
	end
end

return thunkMiddleware
 end, _env("RemoteSpy.include.node_modules.rodux.src.thunkMiddleware"))() end)

_instance("roselect", "Folder", "RemoteSpy.include.node_modules.roselect", "RemoteSpy.include.node_modules")

_module("src", "ModuleScript", "RemoteSpy.include.node_modules.roselect.src", "RemoteSpy.include.node_modules.roselect", function () return setfenv(function() local function defaultEqualityCheck(a, b)
	return a == b
end

local function isDictionary(tbl)
	if type(value) ~= "table" then
		return false
	end

	for k, _ in pairs(tbl) do
		if type(k) ~= "number" then
			return true
		end
	end
	
	return false
end

local function isDependency(value)
	return type(value) == "table" and isDictionary(value) == false and value["dependencies"] == nil
end

local function reduce(tbl, callback, initialValue)
        tbl = tbl or {}
	local value = initialValue or tbl[1]

	for i, v in ipairs(tbl) do
		value = callback(value, v, i)
	end

	return value
end

local function areArgumentsShallowlyEqual(equalityCheck, prev, nextValue)
	if prev == nil or nextValue == nil or #prev ~= #nextValue then
		return false
	end

	for i = 1, #prev do
		if equalityCheck(prev[i], nextValue[i]) == false then
			return false
		end
	end

	return true
end

local function defaultMemoize(func, equalityCheck)
	if equalityCheck == nil then
		equalityCheck = defaultEqualityCheck
	end

	local lastArgs
	local lastResult

	return function(...)
		local args = {...}

		if areArgumentsShallowlyEqual(equalityCheck, lastArgs, args) == false then
			lastResult = func(unpack(args))
		end

		lastArgs = args
		return lastResult
	end
end

local function getDependencies(funcs)
	local dependencies = if isDependency(funcs[1]) then funcs[1] else funcs

	for _, dep in ipairs(dependencies) do
		if isDependency(dep) then
			error("Selector creators expect all input-selectors to be functions.", 2)
		end
	end

	return dependencies
end

local function createSelectorCreator(memoize, ...)
	local memoizeOptions = {...}

	return function(...)
		local funcs = {...}

		local recomputations = 0
		local resultFunc = table.remove(funcs, #funcs)
		local dependencies = getDependencies(funcs)

		local memoizedResultFunc = memoize(
			function(...)
				recomputations += 1
				return resultFunc(...)
			end,
			unpack(memoizeOptions)
		)

		local selector = setmetatable({
			resultFunc = resultFunc,
			dependencies = dependencies,
			recomputations = function()
				return recomputations
			end,
			resetRecomputations = function()
				recomputations = 0
				return recomputations
			end
		}, {
			__call = memoize(function(self, ...)
				local params = {}

				for i = 1, #dependencies do
					table.insert(params, dependencies[i](...))
				end

				return memoizedResultFunc(unpack(params))
			end)
		})

		return selector
	end
end

local createSelector = createSelectorCreator(defaultMemoize)

local function createStructuredSelector(selectors, selectorCreator)
	if type(selectors) ~= "table" then
		error((
			"createStructuredSelector expects first argument to be an object where each property is a selector, instead received a %s"
		):format(type(selectors)), 2)
	elseif selectorCreator == nil then
		selectorCreator = createSelector
	end

	local keys = {}
	for key, _ in pairs(selectors) do
		table.insert(keys, key)
	end

	local funcs = table.create(#keys)
	for _, key in ipairs(keys) do
		table.insert(funcs, selectors[key])
	end

	return selectorCreator(
		funcs,
		function(...)
			return reduce({...}, function(composition, value, index)
				composition[keys[index]] = value
				return composition
			end)
		end
	)
end

return {
	defaultMemoize = defaultMemoize,
	reduce = reduce,
	createSelectorCreator = createSelectorCreator,
	createSelector = createSelector,
	createStructuredSelector = createStructuredSelector,
} end, _env("RemoteSpy.include.node_modules.roselect.src"))() end)

_module("services", "ModuleScript", "RemoteSpy.include.node_modules.services", "RemoteSpy.include.node_modules", function () return setfenv(function() return setmetatable({}, {
	__index = function(self, serviceName)
		local service = game:GetService(serviceName)
		self[serviceName] = service
		return service
	end,
})
 end, _env("RemoteSpy.include.node_modules.services"))() end)

_instance("types", "Folder", "RemoteSpy.include.node_modules.types", "RemoteSpy.include.node_modules")

_instance("include", "Folder", "RemoteSpy.include.node_modules.types.include", "RemoteSpy.include.node_modules.types")

_instance("generated", "Folder", "RemoteSpy.include.node_modules.types.include.generated", "RemoteSpy.include.node_modules.types.include")

start()