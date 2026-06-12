require("config")

-- Adjustable Lights
-- Version 1.1.5

local MOD_NAME = "Adjustable Lights"

---@param message string
---@param ... string
local function Log(message, ...)
	print(string.format("[%s] %s \n", MOD_NAME, string.format(message, ...)))
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

Log("Initializing...")

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

Log("Generating Config...")
local Config, Layout = GenerateConfig(Lights)

write_text(MANIFEST_PATH, Layout)
Log("Successfully Generated And Saved Config!")

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

--[[
---@param instance UObject
local function IsRealObject(instance)
	return not string.match(instance:GetFName():ToString(), "Default__")
end
]]

-- Removed Cuz It Causes Lag
--[[
local function ApplyAll()
	for lightName, lightData in pairs(Lights) do
		local actors = FindAllOf(lightData.ShortName)
		if actors then
			for _, actor in ipairs(actors) do
				if IsRealObject(actor) then
					ProcessActorComponents(actor, lightName, lightData)
				end
			end
		end
	end
end
]]

local KnownLights = {}

Log("Setting Up New Object Hooks...")
for lightName, lightData in pairs(Lights) do
	---@param actor UObject
	---@diagnostic disable-next-line: redundant-parameter
	NotifyOnNewObject(lightData.Path, function(actor)
		ExecuteWithDelay(250, function()
			ExecuteInGameThread(function()
				KnownLights[actor:GetAddress()] = { actor = actor, name = lightName, data = lightData }

				if actor and actor:IsValid() then
					Log("Found New Light Actor => %s : %s", actor:GetFName():ToString(), actor:GetAddress())
					ProcessActorComponents(actor, lightName, lightData)
				end
			end)
		end)
	end)
end
Log("Object Hooks Initialized!")

LoopAsync(3000, function()
	if not LoadFromShared() then
		return false
	end

	ExecuteInGameThread(function()
		for addr, entry in pairs(KnownLights) do
			if entry.actor and entry.actor:IsValid() then
				ProcessActorComponents(entry.actor, entry.name, entry.data)
			else
				-- Cleanup
				Log("Deleting Light Actor => %s", addr)
				KnownLights[addr] = nil
			end
		end
	end)

	return false
end)

Log("Adjustable Lights v1.1.5 Initialized")
