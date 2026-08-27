require("config")

-- Adjustable Lights
-- Version 1.3.0

local MOD_NAME = "Adjustable Lights"
local MOD_UNIQUE_NAME = "AdjustableLights"
local MOD_VERSION = "1.3.0"

local InitKeyBinds = false

---@param key string
---@param fallback string
---@return string
local function Translate(key, fallback)
    if not TH then
        return fallback
    end
    return TH.Translate(MOD_UNIQUE_NAME, key, fallback)
end

---@param key string
---@param fallback string
---@param ... any
local function Log(key, fallback, ...)
    print(string.format("[%s] %s \n", MOD_NAME, string.format(Translate(key, fallback), ...)))
end

---@class RGB
---@field R number
---@field G number
---@field B number

---@class LightSettings
---@field Intensity number
---@field AttenuationRadius number
---@field InnerConeAngle number
---@field OuterConeAngle number
---@field Temperature number | nil
---@field LightFalloffExponent number
---@field Color RGB | nil

---@class Light
---@field Path string
---@field ShortName string
---@field Defaults table<string, LightSettings>

--[[
Default Values From My Testing

Flashlight:
    Intensity -> 5.0
    AttenuationRadius -> 3500.0
    InnerConeAngle -> 20.0
    OuterConeAngle -> 55.0
    Temperature -> 8750.0
    LightFalloffExponent -> 3.0

Tadpole: (L Is Main, R Is Helper)
    L:
        Intensity -> 0.35
        AttenuationRadius -> 5000.0
        InnerConeAngle -> 25.0
        OuterConeAngle -> 50.0
        Temperature -> 8750.0
        LightFalloffExponent -> 5.0
    R:
        Intensity -> 0.35
        AttenuationRadius -> 500.0
        InnerConeAngle -> 25.0
        OuterConeAngle -> 50.0
        Temperature -> 8750.0
        LightFalloffExponent -> 3.0

WakeMaker: (L Is Helper, R Is Main) (Bruh)
    L:
        Intensity -> 5.0
        AttenuationRadius -> 500.0
        InnerConeAngle -> 12.7
        OuterConeAngle -> 55.0
        Temperature -> 8750.0
        LightFalloffExponent -> 3.0
    R:
        Intensity -> 5.0
        AttenuationRadius -> 4000.0
        InnerConeAngle -> 12.7
        OuterConeAngle -> 55.0
        Temperature -> 8750.0
        LightFalloffExponent -> 3.0

Scanner: (Only Appears When Scanner In Hand)
    Intensity -> 0.5
    AttenuationRadius -> 400.0
    InnerConeAngle -> 0.0
    OuterConeAngle -> 80.0
    Temperature -> 6500.0
    LightFalloffExponent -> 8.0

Scout Ray: (L Is Helper, R Is Main)
	L:
		Intensity -> 0.35
		AttenuationRadius -> 750.0
		InnerConeAngle -> 25.0
		OuterConeAngle -> 50.0
		Temperature -> 8750.0
		LightFalloffExponent -> 5.0
	R:
		Intensity -> 0.35
		AttenuationRadius -> 5000.0
		InnerConeAngle -> 25.0
		OuterConeAngle -> 50.0
		Temperature -> 8750.0
		LightFalloffExponent -> 5.0

Hauler: (L Is Main, R Is Helper, M Is The Middle One)
	L:
		Intensity -> 0.35
		AttenuationRadius -> 5000.0
		InnerConeAngle -> 25.0
		OuterConeAngle -> 50.0
		Temperature -> 8750.0
		LightFalloffExponent -> 5.0
	R:
		Intensity -> 0.35
		AttenuationRadius -> 500.0
		InnerConeAngle -> 25.0
		OuterConeAngle -> 50.0
		Temperature -> 8750.0
		LightFalloffExponent -> 5.0
	M:
		Intensity -> 0.35
		AttenuationRadius -> 2000.0
		InnerConeAngle -> 25.0
		OuterConeAngle -> 50.0
		Temperature -> 8750.0
		LightFalloffExponent -> 5.0

WorkLight:
	Intensity -> 7.50
	AttenuationRadius -> 5000.0
	InnerConeAngle -> 25.0
	OuterConeAngle -> 50.0
	Temperature -> 8750.0
	LightFalloffExponent -> 3.0
]]

---@type table<string, Light>
local Lights = {
	["Flashlight"] = {
		Path = "/Game/GameplayCueNotifies/Flashlight/GC_Flashlight_Active.GC_Flashlight_Active_C",
		ShortName = "GC_Flashlight_Active_C",
		Defaults = {
			["D"] = {
				Intensity = 5.0,
				AttenuationRadius = 3500.0,
				InnerConeAngle = 20.0,
				OuterConeAngle = 55.0,
				Temperature = 8750.0,
				LightFalloffExponent = 3.0,
				Color = { R = 179.0, G = 244.0, B = 239.0 },
			},
		},
	},
	["Tadpole"] = {
		Path = "/Game/GameplayCueNotifies/Tadpole/GC_TadpoleLight.GC_TadpoleLight_C",
		ShortName = "GC_TadpoleLight_C",
		Defaults = {
			["L"] = {
				Intensity = 0.35,
				AttenuationRadius = 5000.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
			["R"] = {
				Intensity = 0.35,
				AttenuationRadius = 500.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 3.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
		},
	},
	["Wakemaker"] = {
		Path = "/Game/GameplayCueNotifies/Wakemaker/GC_Wakemaker_Lights.GC_Wakemaker_Lights_C",
		ShortName = "GC_Wakemaker_Lights_C",
		Defaults = {
			["L"] = {
				Intensity = 5.0,
				AttenuationRadius = 500.0,
				InnerConeAngle = 12.7,
				OuterConeAngle = 55.0,
				Temperature = 8750.0,
				LightFalloffExponent = 3.0,
				Color = { R = 179.0, G = 244.0, B = 239.0 },
			},
			["R"] = {
				Intensity = 5.0,
				AttenuationRadius = 4000.0,
				InnerConeAngle = 12.7,
				OuterConeAngle = 55.0,
				Temperature = 8750.0,
				LightFalloffExponent = 3.0,
				Color = { R = 179.0, G = 244.0, B = 239.0 },
			},
		},
	},
	["Scanner"] = {
		Path = "/Game/GameplayCueNotifies/Scanner/GC_ScannerOnline.GC_ScannerOnline_C",
		ShortName = "GC_ScannerOnline_C",
		Defaults = {
			["F"] = {
				Intensity = 0.5,
				AttenuationRadius = 400.0,
				InnerConeAngle = 0.0,
				OuterConeAngle = 80.0,
				Temperature = 6500.0,
				LightFalloffExponent = 8.0,
				Color = { R = 94.0, G = 207.0, B = 255.0 },
			},
		},
	},
	["ScoutRay"] = {
		Path = "/Game/GameplayCueNotifies/Tadpole/Chassis/GC_ScoutRayLight.GC_ScoutRayLight_C",
		ShortName = "GC_ScoutRayLight_C",
		Defaults = {
			["L"] = {
				Intensity = 0.35,
				AttenuationRadius = 750.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
			["R"] = {
				Intensity = 0.35,
				AttenuationRadius = 5000.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
		},
	},
	["Hauler"] = {
		Path = "/Game/GameplayCueNotifies/Tadpole/Chassis/GC_HaulLights.GC_HaulLights_C",
		ShortName = "GC_HaulLights_C",
		Defaults = {
			["L"] = {
				Intensity = 0.35,
				AttenuationRadius = 5000.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
			["M"] = {
				Intensity = 0.35,
				AttenuationRadius = 2000.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
			["R"] = {
				Intensity = 0.35,
				AttenuationRadius = 500.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 5.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
		},
	},
	["Worklight"] = {
		Path = "/Game/GameplayCueNotifies/Carryables/GC_WorkLight.GC_WorkLight_C",
		ShortName = "GC_WorkLight_C",
		Defaults = {
			["D"] = {
				Intensity = 7.50,
				AttenuationRadius = 5000.0,
				InnerConeAngle = 25.0,
				OuterConeAngle = 50.0,
				Temperature = 8750.0,
				LightFalloffExponent = 3.0,
				Color = { R = 163.0, G = 248.0, B = 255.0 },
			},
		},
	},
}

if TH then
    TH.RegisterMod(MOD_UNIQUE_NAME)
end

Log("init", "Initializing...")

local MANIFEST_PATH = "./ue4ss/Mods/SN2ModSettings/registrations/AdjustableLights.lua"

local function write_text(path, body)
	local dir = path:match("(.*[/\\])")
	os.execute('mkdir "' .. dir:gsub("/", "\\") .. '" 2>nul')

	local f = io.open(path, "w")
	if not f then
		return false
	end

	f:write(body)
	f:close()
	return true
end

Log("genConfig", "Generating Config...")
local Config, Layout = GenerateConfig(Lights, MOD_VERSION)

write_text(MANIFEST_PATH, Layout)
Log("configSuccess", "Successfully Generated And Saved Config!")

local function LoadFromShared()
	---@diagnostic disable-next-line: undefined-global
	if not ModRef then
		return false
	end
	local changed = false

	for k in pairs(Config) do
		---@diagnostic disable-next-line: undefined-global
		local v = ModRef:GetSharedVariable("SN2ModSettings/AdjustableLights/" .. k)
		if v ~= nil and type(v) == type(Config[k]) and Config[k] ~= v then
			Config[k] = v
			changed = true
		end
	end

	return changed
end

---@param rgb RGB
---@return table
local function ConvertToFLinear(rgb)
	return {
		R = rgb.R / 255,
		G = rgb.G / 255,
		B = rgb.B / 255,
		A = 1.0,
	}
end

---@param light USpotLightComponent
---@param settings LightSettings
---@param defaultSettings LightSettings
local function ApplyLightSettings(light, settings, defaultSettings)
	if not light or not light:IsValid() then
		return
	end

	light:SetIntensity(settings.Intensity)
	light:SetAttenuationRadius(settings.AttenuationRadius)
	light:SetInnerConeAngle(settings.InnerConeAngle)
	light:SetOuterConeAngle(settings.OuterConeAngle)
	light:SetLightFalloffExponent(settings.LightFalloffExponent)

	if settings.Color ~= nil then
		light:SetUseTemperature(false)
		light:SetLightColor(ConvertToFLinear(settings.Color), true)
	else
		light:SetUseTemperature(true)
		light:SetTemperature(settings.Temperature)
		light:SetLightColor(ConvertToFLinear(defaultSettings.Color), true)
	end
end

local DefaultTracking = {}
local SubKeyToComponent = {
	D = "SpotLight",
	F = "FrontLight_Spot",
	L = "SpotLight_L",
	R = "SpotLight_R",
	M = "SpotLight_M",
}

---@param actor UObject
---@param light USpotLightComponent
---@param lightName string
---@param suffix string
---@param defaultSettings LightSettings
local function ProcessAndApplyLight(actor, light, lightName, suffix, defaultSettings)
	if not light or not light:IsValid() then
		return
	end

	-- Using Address Cuz Multiple Vehicle Handling
	local trackingKey = string.format("%X_%s", actor:GetAddress(), lightName .. suffix)
	local masterEnableKey = "Enable" .. lightName .. suffix
	local colorEnableKey = "Enable" .. lightName .. suffix .. "Color"

	if not Config[masterEnableKey] then
		if not DefaultTracking[trackingKey] then
			ApplyLightSettings(light, defaultSettings, defaultSettings)
			DefaultTracking[trackingKey] = true
		end
		return
	end

	local settings = {
		Intensity = Config[lightName .. suffix .. "Intensity"],
		AttenuationRadius = Config[lightName .. suffix .. "Radius"],
		InnerConeAngle = Config[lightName .. suffix .. "InnerAngle"],
		OuterConeAngle = Config[lightName .. suffix .. "OuterAngle"],
		Temperature = Config[lightName .. suffix .. "Temperature"],
		LightFalloffExponent = Config[lightName .. suffix .. "Falloff"],
		Color = Config[colorEnableKey] and {
			R = Config[lightName .. suffix .. "ColorR"],
			G = Config[lightName .. suffix .. "ColorG"],
			B = Config[lightName .. suffix .. "ColorB"],
		} or nil,
	}

	ApplyLightSettings(light, settings, defaultSettings)
	DefaultTracking[trackingKey] = false
end

---@param actor UObject
---@param lightName string
---@param lightData Light
local function ProcessActorComponents(actor, lightName, lightData)
	for subKey, defaultSettings in pairs(lightData.Defaults) do
		local compName = SubKeyToComponent[subKey]
		if compName then
			local lightComponent = actor[compName]
			if lightComponent and lightComponent:IsValid() then
				local isSingle = (subKey == "D") or (subKey == "F")
				local suffix = isSingle and "" or subKey

				ProcessAndApplyLight(actor, lightComponent, lightName, suffix, defaultSettings)
			end
		end
	end
end

-- Technically Is This Reduntant??
---@param instance UObject
local function IsRealObject(instance)
	return not string.match(instance:GetFName():ToString(), "Default__")
end

local KnownLights = {}

local function ApplyAll()
	for lightName, lightData in pairs(Lights) do
		local actors = FindAllOf(lightData.ShortName)
		if actors then
			for _, actor in ipairs(actors) do
				if IsRealObject(actor) then
					local addr = actor:GetAddress()
					Log("foundActor", "Found Light Actor => %s : %s", actor:GetFName():ToString(), addr)
					KnownLights[addr] = { actor = actor, name = lightName, data = lightData }
					ProcessActorComponents(actor, lightName, lightData)
				end
			end
		end
	end
end

-- HAHA! TIME TO STEAL CODE FROM OTHER MODS MUAHAHAHHAHAHA (Its My Own Mod LMAO)
local keyRegistry = {
	["A"] = Key.A,
	["B"] = Key.B,
	["C"] = Key.C,
	["D"] = Key.D,
	["E"] = Key.E,
	["F"] = Key.F,
	["G"] = Key.G,
	["H"] = Key.H,
	["I"] = Key.I,
	["J"] = Key.J,
	["K"] = Key.K,
	["L"] = Key.L,
	["M"] = Key.M,
	["N"] = Key.N,
	["O"] = Key.O,
	["P"] = Key.P,
	["Q"] = Key.Q,
	["R"] = Key.R,
	["S"] = Key.S,
	["T"] = Key.T,
	["U"] = Key.U,
	["V"] = Key.V,
	["W"] = Key.W,
	["X"] = Key.X,
	["Y"] = Key.Y,
	["Z"] = Key.Z,

	["0"] = Key.ZERO,
	["1"] = Key.ONE,
	["2"] = Key.TWO,
	["3"] = Key.THREE,
	["4"] = Key.FOUR,
	["5"] = Key.FIVE,
	["6"] = Key.SIX,
	["7"] = Key.SEVEN,
	["8"] = Key.EIGHT,
	["9"] = Key.NINE,

	["F1"] = Key.F1,
	["F2"] = Key.F2,
	["F3"] = Key.F3,
	["F4"] = Key.F4,
	["F5"] = Key.F5,
	["F6"] = Key.F6,
	["F7"] = Key.F7,
	["F8"] = Key.F8,
	["F9"] = Key.F9,
	["F10"] = Key.F10,
	["F11"] = Key.F11,
	["F12"] = Key.F12,

	["Up"] = Key.UP_ARROW,
	["Down"] = Key.DOWN_ARROW,
	["Left"] = Key.LEFT_ARROW,
	["Right"] = Key.RIGHT_ARROW,
	["Space"] = Key.SPACE,
	["Tab"] = Key.TAB,
	["Escape"] = Key.ESCAPE,
	["Backspace"] = Key.BACKSPACE,
	["Home"] = Key.HOME,
	["End"] = Key.END,
	["PageUp"] = Key.PAGE_UP,
	["PageDown"] = Key.PAGE_DOWN,
	["CapsLock"] = Key.CAPS_LOCK,

	["LeftMouseButton"] = Key.LEFT_MOUSE_BUTTON,
	["RightMouseButton"] = Key.RIGHT_MOUSE_BUTTON,
	["MiddleMouseButton"] = Key.MIDDLE_MOUSE_BUTTON,
	["ThumbMouseButton"] = Key.XBUTTON_ONE,
	["ThumbMouseButton2"] = Key.XBUTTON_TWO,
}

local registeredBinds = {}

---@param keyName string
local function BindKeyString(keyName)
	if not keyName or keyName == "" then
		return
	end

	local keyConst = keyRegistry[keyName]
	if not keyConst then
		return
	end

	if registeredBinds[keyConst] then
		return
	end
	registeredBinds[keyConst] = true

	RegisterKeyBind(keyConst, function()
		ExecuteInGameThread(function()
			if
				Config.ReloadAllKeyBind == keyName
				or (Config.ReloadAllKeyBind_Alt ~= "" and Config.ReloadAllKeyBind_Alt == keyName)
			then
				ApplyAll()
			end
		end)
	end)
end

Log("newHook", "Setting Up New Object Hooks...")
for lightName, lightData in pairs(Lights) do
	---@param actor UObject
	---@diagnostic disable-next-line: redundant-parameter
	NotifyOnNewObject(lightData.Path, function(actor)
		ExecuteWithDelay(250, function()
			ExecuteInGameThread(function()
				KnownLights[actor:GetAddress()] = { actor = actor, name = lightName, data = lightData }

				if actor and actor:IsValid() then
					Log("newActor", "Found New Light Actor => %s : %s", actor:GetFName():ToString(), actor:GetAddress())
					ProcessActorComponents(actor, lightName, lightData)
				end
			end)
		end)
	end)
end
Log("objHooks", "Object Hooks Initialized!")

LoopAsync(3000, function()
	if not InitKeyBinds then
		LoadFromShared()
		BindKeyString(Config.ReloadAllKeyBind)
		BindKeyString(Config.ReloadAllKeyBind_Alt)
		InitKeyBinds = true
	end

	if not LoadFromShared() then
		return false
	end

	ExecuteInGameThread(function()
		for addr, entry in pairs(KnownLights) do
			if entry.actor and entry.actor:IsValid() then
				ProcessActorComponents(entry.actor, entry.name, entry.data)
			else
				-- Cleanup
				Log("delData", "Deleting Light Actor => %s", addr)
				KnownLights[addr] = nil
			end
		end

		BindKeyString(Config.ReloadAllKeyBind)
		BindKeyString(Config.ReloadAllKeyBind_Alt)
	end)

	return false
end)

Log("initDone", "Adjustable Lights v%s Initialized", MOD_VERSION)
