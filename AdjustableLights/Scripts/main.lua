local UEHelpers = require("UEHelpers")
require("config")

local MOD_NAME = "Adjustable Lights"

local function Log(message)
	print(string.format("[%s] %s \n", MOD_NAME, message))
end

-- Flashlight Handled By AGC_Flashlight_Active_C -> class USpotLightComponent* SpotLight;
local FLASHLIGHT_PATH = "/Game/GameplayCueNotifies/Flashlight/GC_Flashlight_Active.GC_Flashlight_Active_C"
local FLASHLIGHT_SHORT_NAME = "GC_Flashlight_Active_C"
-- WakeMaker Handled By AGC_Wakemaker_Lights_C -> class USpotLightComponent* SpotLight_L; & class USpotLightComponent* SpotLight_R;
local WAKEMAKER_PATH = "/Game/GameplayCueNotifies/Wakemaker/GC_Wakemaker_Lights.GC_Wakemaker_Lights_C"
local WAKEMAKER_SHORT_NAME = "GC_Wakemaker_Lights_C"
-- Tadpole Handled By AGC_TadpoleLight_C -> class USpotLightComponent* SpotLight_L; & class USpotLightComponent* SpotLight_R;
local TADPOLE_PATH = "/Game/GameplayCueNotifies/Tadpole/GC_TadpoleLight.GC_TadpoleLight_C"
local TADPOLE_SHORT_NAME = "GC_TadpoleLight_C"
-- Scanner Handled By AGC_ScannerOnline_C -> class USpotLightComponent* FrontLight_Spot; (Only Appears When Scanner In Hand)
local SCANNER_PATH = "/Game/GameplayCueNotifies/Scanner/GC_ScannerOnline.GC_ScannerOnline_C"
local SCANNER_SHORT_NAME = "GC_ScannerOnline_C"

local FlashlightHasDefault = true
local TadpoleLHasDefault = true
local TadpoleRHasDefault = true
local WakeMakerLHasDefault = true
local WakeMakerRHasDefault = true
local ScannerHasDefault = true

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
]]

---@class RGB
---@field R number
---@field G number
---@field B number

---@type RGB
local DefaultColor = {
	R = 179.0,
	G = 244.0,
	B = 239.0,
}

-- TODO: Maybe Add VolumetricScatteringIntensity, SpecularScale Or MAYBE The Shadow Stuff For Perf IDK

---@class LightSettings
---@field Intensity number
---@field AttenuationRadius number
---@field InnerConeAngle number
---@field OuterConeAngle number
---@field Temperature number | nil
---@field LightFalloffExponent number
---@field Color RGB | nil

---@type LightSettings
local FLASHLIGHT_DEFAULT = {
	Intensity = 5.0,
	AttenuationRadius = 3500.0,
	InnerConeAngle = 20.0,
	OuterConeAngle = 55.0,
	Temperature = 8750.0,
	LightFalloffExponent = 3.0,
}

---@type LightSettings
local TADPOLE_L_DEFAULT = {
	Intensity = 0.35,
	AttenuationRadius = 5000.0,
	InnerConeAngle = 25.0,
	OuterConeAngle = 50.0,
	Temperature = 8750.0,
	LightFalloffExponent = 5.0,
}

---@type LightSettings
local TADPOLE_R_DEFAULT = {
	Intensity = 0.35,
	AttenuationRadius = 500.0,
	InnerConeAngle = 25.0,
	OuterConeAngle = 50.0,
	Temperature = 8750.0,
	LightFalloffExponent = 3.0,
}

---@type LightSettings
local WAKEMAKER_L_DEFAULT = {
	Intensity = 5.0,
	AttenuationRadius = 500.0,
	InnerConeAngle = 12.7,
	OuterConeAngle = 55.0,
	Temperature = 8750.0,
	LightFalloffExponent = 3.0,
}

---@type LightSettings
local WAKEMAKER_R_DEFAULT = {
	Intensity = 5.0,
	AttenuationRadius = 4000.0,
	InnerConeAngle = 12.7,
	OuterConeAngle = 55.0,
	Temperature = 8750.0,
	LightFalloffExponent = 3.0,
}

---@type LightSettings
local SCANNER_DEFAULT = {
	Intensity = 0.5,
	AttenuationRadius = 400.0,
	InnerConeAngle = 0.0,
	OuterConeAngle = 80.0,
	Temperature = 6500.0,
	LightFalloffExponent = 8.0,
}

--SN2ModSettings Config
local Config = {
	-- Flashlight
	EnableFlashlight = false,
	FlashlightIntensity = 5.0,
	FlashlightRadius = 3500.0,
	FlashlightInnerAngle = 20.0,
	FlashlightOuterAngle = 55.0,
	FlashlightTemperature = 8750.0,
	FlashlightFalloff = 3.0,
	EnableFlashlightColor = false,
	FlashlightColorR = 255,
	FlashlightColorG = 255,
	FlashlightColorB = 255,

	-- Tadpole (L)
	EnableTadpoleL = false,
	TadpoleLIntensity = 0.35,
	TadpoleLRadius = 5000.0,
	TadpoleLInner = 25.0,
	TadpoleLOuter = 50.0,
	TadpoleLTemperature = 8750.0,
	TadpoleLFalloff = 5.0,
	EnableTadpoleLColor = false,
	TadpoleLColorR = 255,
	TadpoleLColorG = 255,
	TadpoleLColorB = 255,

	-- Tadpole (R)
	EnableTadpoleR = false,
	TadpoleRIntensity = 0.35,
	TadpoleRRadius = 500.0,
	TadpoleRInner = 25.0,
	TadpoleROuter = 50.0,
	TadpoleRTemperature = 8750.0,
	TadpoleRFalloff = 3.0,
	EnableTadpoleRColor = false,
	TadpoleRColorR = 255,
	TadpoleRColorG = 255,
	TadpoleRColorB = 255,

	-- WakeMaker (L)
	EnableWakeMakerL = false,
	WakeMakerLIntensity = 5.0,
	WakeMakerLRadius = 500.0,
	WakeMakerLInner = 12.7,
	WakeMakerLOuter = 55.0,
	WakeMakerLTemperature = 8750.0,
	WakeMakerLFalloff = 3.0,
	EnableWakeMakerLColor = false,
	WakeMakerLColorR = 255,
	WakeMakerLColorG = 255,
	WakeMakerLColorB = 255,

	-- WakeMaker (R)
	EnableWakeMakerR = false,
	WakeMakerRIntensity = 5.0,
	WakeMakerRRadius = 4000.0,
	WakeMakerRInner = 12.7,
	WakeMakerROuter = 55.0,
	WakeMakerRTemperature = 8750.0,
	WakeMakerRFalloff = 3.0,
	EnableWakeMakerRColor = false,
	WakeMakerRColorR = 255,
	WakeMakerRColorG = 255,
	WakeMakerRColorB = 255,

	-- Scanner
	EnableScanner = false,
	ScannerIntensity = 0.5,
	ScannerRadius = 400.0,
	ScannerInner = 0.0,
	ScannerOuter = 80.0,
	ScannerTemperature = 6500.0,
	ScannerFalloff = 8.0,
	EnableScannerColor = false,
	ScannerColorR = 255,
	ScannerColorG = 255,
	ScannerColorB = 255,
}

local function LoadFromShared()
	if not ModRef then
		return false
	end
	local changed = false

	for k in pairs(Config) do
		local v = ModRef:GetSharedVariable("SN2ModSettings/AdjustableLights/" .. k)
		if v ~= nil and type(v) == type(Config[k]) and Config[k] ~= v then
			Config[k] = v
			changed = true
		end
	end

	return changed
end

---@param rgb RGB
---@return FLinearColor
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
local function ApplyLightSettings(light, settings)
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
		light:SetLightColor(ConvertToFLinear(DefaultColor), true)
	end
end

---@param light USpotLightComponent
local function ApplyFlashlight(light)
	if not Config.EnableFlashlight then
		if not FlashlightHasDefault then
			ApplyLightSettings(light, FLASHLIGHT_DEFAULT)
			FlashlightHasDefault = true
		end
	else
		---@type LightSettings
		local settings = {
			Intensity = Config.FlashlightIntensity,
			AttenuationRadius = Config.FlashlightRadius,
			InnerConeAngle = Config.FlashlightInnerAngle,
			OuterConeAngle = Config.FlashlightOuterAngle,
			Temperature = Config.FlashlightTemperature,
			LightFalloffExponent = Config.FlashlightFalloff,
			Color = Config.EnableFlashlightColor and {
				R = Config.FlashlightColorR,
				G = Config.FlashlightColorG,
				B = Config.FlashlightColorB,
			} or nil,
		}

		ApplyLightSettings(light, settings)
		FlashlightHasDefault = false
	end
end

---@param light USpotLightComponent
local function ApplyTadpoleL(light)
	if not Config.EnableTadpoleL then
		if not TadpoleLHasDefault then
			ApplyLightSettings(light, TADPOLE_L_DEFAULT)
			TadpoleLHasDefault = true
		end
	else
		local settings = {
			Intensity = Config.TadpoleLIntensity,
			AttenuationRadius = Config.TadpoleLRadius,
			InnerConeAngle = Config.TadpoleLInner,
			OuterConeAngle = Config.TadpoleLOuter,
			Temperature = Config.TadpoleLTemperature,
			LightFalloffExponent = Config.TadpoleLFalloff,
			Color = Config.EnableTadpoleLColor
					and { R = Config.TadpoleLColorR, G = Config.TadpoleLColorG, B = Config.TadpoleLColorB }
				or nil,
		}
		ApplyLightSettings(light, settings)
		TadpoleLHasDefault = false
	end
end

---@param light USpotLightComponent
local function ApplyTadpoleR(light)
	if not Config.EnableTadpoleR then
		if not TadpoleRHasDefault then
			ApplyLightSettings(light, TADPOLE_R_DEFAULT)
			TadpoleRHasDefault = true
		end
	else
		local settings = {
			Intensity = Config.TadpoleRIntensity,
			AttenuationRadius = Config.TadpoleRRadius,
			InnerConeAngle = Config.TadpoleRInner,
			OuterConeAngle = Config.TadpoleROuter,
			Temperature = Config.TadpoleRTemperature,
			LightFalloffExponent = Config.TadpoleRFalloff,
			Color = Config.EnableTadpoleRColor
					and { R = Config.TadpoleRColorR, G = Config.TadpoleRColorG, B = Config.TadpoleRColorB }
				or nil,
		}
		ApplyLightSettings(light, settings)
		TadpoleRHasDefault = false
	end
end

---@param light USpotLightComponent
local function ApplyWakeMakerL(light)
	if not Config.EnableWakeMakerL then
		if not WakeMakerLHasDefault then
			ApplyLightSettings(light, WAKEMAKER_L_DEFAULT)
			WakeMakerLHasDefault = true
		end
	else
		local settings = {
			Intensity = Config.WakeMakerLIntensity,
			AttenuationRadius = Config.WakeMakerLRadius,
			InnerConeAngle = Config.WakeMakerLInner,
			OuterConeAngle = Config.WakeMakerLOuter,
			Temperature = Config.WakeMakerLTemperature,
			LightFalloffExponent = Config.WakeMakerLFalloff,
			Color = Config.EnableWakeMakerLColor
					and { R = Config.WakeMakerLColorR, G = Config.WakeMakerLColorG, B = Config.WakeMakerLColorB }
				or nil,
		}
		ApplyLightSettings(light, settings)
		WakeMakerLHasDefault = false
	end
end

---@param light USpotLightComponent
local function ApplyWakeMakerR(light)
	if not Config.EnableWakeMakerR then
		if not WakeMakerRHasDefault then
			ApplyLightSettings(light, WAKEMAKER_R_DEFAULT)
			WakeMakerRHasDefault = true
		end
	else
		local settings = {
			Intensity = Config.WakeMakerRIntensity,
			AttenuationRadius = Config.WakeMakerRRadius,
			InnerConeAngle = Config.WakeMakerRInner,
			OuterConeAngle = Config.WakeMakerROuter,
			Temperature = Config.WakeMakerRTemperature,
			LightFalloffExponent = Config.WakeMakerRFalloff,
			Color = Config.EnableWakeMakerRColor
					and { R = Config.WakeMakerRColorR, G = Config.WakeMakerRColorG, B = Config.WakeMakerRColorB }
				or nil,
		}
		ApplyLightSettings(light, settings)
		WakeMakerRHasDefault = false
	end
end

---@param light USpotLightComponent
local function ApplyScanner(light)
	if not Config.EnableScanner then
		if not ScannerHasDefault then
			ApplyLightSettings(light, SCANNER_DEFAULT)
			ScannerHasDefault = true
		end
	else
		local settings = {
			Intensity = Config.ScannerIntensity,
			AttenuationRadius = Config.ScannerRadius,
			InnerConeAngle = Config.ScannerInner,
			OuterConeAngle = Config.ScannerOuter,
			Temperature = Config.ScannerTemperature,
			LightFalloffExponent = Config.ScannerFalloff,
			Color = Config.EnableScannerColor
					and { R = Config.ScannerColorR, G = Config.ScannerColorG, B = Config.ScannerColorB }
				or nil,
		}
		ApplyLightSettings(light, settings)
		ScannerHasDefault = false
	end
end

---@param instance UObject
local function IsRealObject(instance)
	return not string.match(instance:GetFName():ToString(), "Default__")
end

local function ApplyAll()
	-- Flashlight
	---@type AGC_Flashlight_Active_C[] | nil
	local flashlights = FindAllOf(FLASHLIGHT_SHORT_NAME)

	if flashlights then
		for _, flashlight in ipairs(flashlights) do
			if IsRealObject(flashlight) then
				local spotlight = flashlight.SpotLight

				if spotlight and spotlight:IsValid() then
					ApplyFlashlight(spotlight)
				end
			end
		end
	end

	-- Tadpole
	---@type AGC_TadpoleLight_C[] | nil
	local tadpoles = FindAllOf(TADPOLE_SHORT_NAME)

	if tadpoles then
		for _, tadpole in ipairs(tadpoles) do
			if IsRealObject(tadpole) then
				local lightR = tadpole.SpotLight_R
				local lightL = tadpole.SpotLight_L

				if lightL and lightL:IsValid() then
					ApplyTadpoleL(lightL)
				end

				if lightR and lightR:IsValid() then
					ApplyTadpoleR(lightR)
				end
			end
		end
	end

	-- WakeMaker
	---@type AGC_Wakemaker_Lights_C[] | nil
	local wakemakers = FindAllOf(WAKEMAKER_SHORT_NAME)
	if wakemakers then
		for _, wakemaker in ipairs(wakemakers) do
			if IsRealObject(wakemaker) then
				local lightL = wakemaker.SpotLight_L
				local lightR = wakemaker.SpotLight_R

				if lightL and lightL:IsValid() then
					ApplyWakeMakerL(lightL)
				end

				if lightR and lightR:IsValid() then
					ApplyWakeMakerR(lightR)
				end
			end
		end
	end

	-- Scanner
	---@type AGC_ScannerOnline_C[] | nil
	local scanners = FindAllOf(SCANNER_SHORT_NAME)

	if scanners then
		for _, scanner in ipairs(scanners) do
			if IsRealObject(scanner) then
				local spotlight = scanner.FrontLight_Spot -- Seems To Only Be Assigned When Using Scanner
				if spotlight and spotlight:IsValid() then
					ApplyScanner(spotlight)
				end
			end
		end
	end
end

---@param flashlight AGC_Flashlight_Active_C
NotifyOnNewObject(FLASHLIGHT_PATH, function(flashlight)
	ExecuteWithDelay(250, function()
		ExecuteInGameThread(function()
			local spotlight = flashlight.SpotLight

			if spotlight and spotlight:IsValid() then
				ApplyFlashlight(spotlight)
			end
		end)
	end)
end)

---@param tadpole AGC_TadpoleLight_C
NotifyOnNewObject(TADPOLE_PATH, function(tadpole)
	ExecuteWithDelay(250, function()
		ExecuteInGameThread(function()
			local lightR = tadpole.SpotLight_R
			local lightL = tadpole.SpotLight_L

			if lightL and lightL:IsValid() then
				ApplyTadpoleL(lightL)
			end

			if lightR and lightR:IsValid() then
				ApplyTadpoleR(lightR)
			end
		end)
	end)
end)

---@param wakemaker AGC_Wakemaker_Lights_C
NotifyOnNewObject(WAKEMAKER_PATH, function(wakemaker)
	ExecuteWithDelay(250, function()
		ExecuteInGameThread(function()
			local lightL = wakemaker.SpotLight_L
			local lightR = wakemaker.SpotLight_R

			if lightL and lightL:IsValid() then
				ApplyWakeMakerL(lightL)
			end
			if lightR and lightR:IsValid() then
				ApplyWakeMakerR(lightR)
			end
		end)
	end)
end)

---@param scanner AGC_ScannerOnline_C
NotifyOnNewObject(SCANNER_PATH, function(scanner)
	ExecuteWithDelay(250, function()
		ExecuteInGameThread(function()
			local spotlight = scanner.FrontLight_Spot
			if spotlight and spotlight:IsValid() then
				ApplyScanner(spotlight)
			end
		end)
	end)
end)

LoopAsync(2000, function()
	LoadFromShared()
	ExecuteInGameThread(function()
		ApplyAll()
	end)
end)

Log("Mod Initialized! Version 1.0.0")
