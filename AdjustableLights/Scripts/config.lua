local Order = { "Flashlight", "Wakemaker", "Scanner", "Worklight", "Tadpole", "ScoutRay", "Hauler" }

local MOD_UNIQUE_NAME = "AdjustableLights"

---@param key string
---@param fallback string
---@return string
local function Translate(key, fallback)
    if not TH then
        return fallback
    end
    return TH.Translate(MOD_UNIQUE_NAME, key, fallback)
end

---Yes I Am Lazy (Still, Just With Translations Now)
---@param lights table<string, Light>
---@param version string
---@return table Config
---@return string LayoutString
function GenerateConfig(lights, version)
	local Config = {}
	local Layout = {
		name = "AdjustableLights",
		display = "Adjustable Lights",
		version = version,
		github = "LabrynthKing/AdjustableLights",
		nexus_id = "381",
		settings = {},
	}

	Config["ReloadAllKeyBind"] = "F6"
	Config["ReloadAllKeyBind_Alt"] = ""

	table.insert(Layout.settings, {
		key = "ReloadAllKeyBind",
		title = Translate("ReloadAllKeyBind", "Re-Apply All KeyBind"),
		description = Translate("ReloadAllKeyBind_desc", "Key To Re-Apply Lighting To ALL Lights Currently Present In Case It's Stuck (May Cause A Small Lag-Spike For A Second)"),
		type = "keybind",
		default = "F6",
	})

	for _, lightName in ipairs(Order) do
		local lightData = lights[lightName]
		if lightData then
			local subKeys = {}
			for k in pairs(lightData.Defaults) do
				table.insert(subKeys, k)
			end
			table.sort(subKeys)

			for _, subKey in ipairs(subKeys) do
				local defaultValues = lightData.Defaults[subKey]

				local isSingle = (subKey == "D") or (subKey == "F")
				local suffix = isSingle and "" or subKey
				local uiLabel = isSingle and lightName or string.format("%s (%s)", lightName, subKey)

				local masterEnableKey = "Enable" .. lightName .. suffix
				local colorEnableKey = "Enable" .. lightName .. suffix .. "Color"

				Config[masterEnableKey] = false
				Config[lightName .. suffix .. "Intensity"] = defaultValues.Intensity
				Config[lightName .. suffix .. "Radius"] = defaultValues.AttenuationRadius
				Config[lightName .. suffix .. "InnerAngle"] = defaultValues.InnerConeAngle
				Config[lightName .. suffix .. "OuterAngle"] = defaultValues.OuterConeAngle
				Config[lightName .. suffix .. "Temperature"] = defaultValues.Temperature
				Config[lightName .. suffix .. "Falloff"] = defaultValues.LightFalloffExponent
				Config[colorEnableKey] = false
				Config[lightName .. suffix .. "ColorR"] = defaultValues.Color.R
				Config[lightName .. suffix .. "ColorG"] = defaultValues.Color.G
				Config[lightName .. suffix .. "ColorB"] = defaultValues.Color.B

				-- Master Toggle
				table.insert(Layout.settings, {
					key = masterEnableKey,
					title = Translate(masterEnableKey, "Enable " .. uiLabel),
					description = Translate(masterEnableKey .. "_desc", "Toggle " .. uiLabel .. " Customization."),
					type = "toggle",
					default = false,
				})

				-- Intensity Slider
				local intensityKey = lightName .. suffix .. "Intensity"
				table.insert(Layout.settings, {
					key = intensityKey,
					title = Translate(intensityKey, uiLabel .. " Intensity"),
					description = Translate(intensityKey .. "_desc", "The Intensity Of The " .. uiLabel .. "."),
					type = "slider",
					default = defaultValues.Intensity,
					min = (defaultValues.Intensity < 1) and 0.01 or 0.1,
					max = (defaultValues.Intensity < 1) and 5.0 or 50.0,
					step = (defaultValues.Intensity < 1) and 0.05 or 0.5,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Attenuation Radius Slider
				local radiusKey = lightName .. suffix .. "Radius"
				table.insert(Layout.settings, {
					key = radiusKey,
					title = Translate(radiusKey, uiLabel .. " Attenuation Radius"),
					description = Translate(radiusKey .. "_desc", "The Attenuation Radius Of The " .. uiLabel .. "."),
					type = "slider",
					default = defaultValues.AttenuationRadius,
					min = 100.0,
					max = 10000.0,
					step = 100.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Inner Cone Angle Slider
				local innerAngleKey = lightName .. suffix .. "InnerAngle"
				table.insert(Layout.settings, {
					key = innerAngleKey,
					title = Translate(innerAngleKey, uiLabel .. " Inner Cone Angle"),
					description = Translate(innerAngleKey .. "_desc", "The Inner Cone Angle Of The " .. uiLabel .. "."),
					type = "slider",
					default = defaultValues.InnerConeAngle,
					min = 0.0,
					max = 90.0,
					step = 1.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Outer Cone Angle Slider
				local outerAngleKey = lightName .. suffix .. "OuterAngle"
				table.insert(Layout.settings, {
					key = outerAngleKey,
					title = Translate(outerAngleKey, uiLabel .. " Outer Cone Angle"),
					description = Translate(outerAngleKey .. "_desc", "The Outer Cone Angle Of The " .. uiLabel .. "."),
					type = "slider",
					default = defaultValues.OuterConeAngle,
					min = 0.0,
					max = 90.0,
					step = 1.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Temperature Slider
				local temperatureKey = lightName .. suffix .. "Temperature"
				table.insert(Layout.settings, {
					key = temperatureKey,
					title = Translate(temperatureKey, uiLabel .. " Temperature"),
					description = Translate(temperatureKey .. "_desc", "The Temperature Of The " .. uiLabel .. " (Disabled When Using Color)"),
					type = "slider",
					default = defaultValues.Temperature,
					min = 1000.0,
					max = 20000.0,
					step = 100.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Falloff Exponent Slider
				local falloffKey = lightName .. suffix .. "Falloff"
				table.insert(Layout.settings, {
					key = falloffKey,
					title = Translate(falloffKey, uiLabel .. " Falloff Exponent"),
					description = Translate(falloffKey .. "_desc", "The Falloff Exponent Of The " .. uiLabel .. "."),
					type = "slider",
					default = defaultValues.LightFalloffExponent,
					min = 0.1,
					max = 20.0,
					step = 0.1,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Color Enable Toggle
				table.insert(Layout.settings, {
					key = colorEnableKey,
					title = Translate(colorEnableKey, "Enable " .. uiLabel .. " Color"),
					description = Translate(colorEnableKey .. "_desc", "Toggle Custom " .. uiLabel .. " Color."),
					type = "toggle",
					default = false,
					enabled_by = masterEnableKey,
				})

				-- RGB Color Sliders
				local rgbConfig = { { k = "R", n = "Red" }, { k = "G", n = "Green" }, { k = "B", n = "Blue" } }
				for _, rgb in ipairs(rgbConfig) do
					local colorKey = lightName .. suffix .. "Color" .. rgb.k
					table.insert(Layout.settings, {
						key = colorKey,
						title = Translate(colorKey, uiLabel .. " " .. rgb.n),
						description = Translate(colorKey .. "_desc", rgb.n .. " Channel Value."),
						type = "slider",
						default = defaultValues.Color[rgb.k],
						min = 0.0,
						max = 255.0,
						step = 1.0,
						format = "int",
						enabled_by = colorEnableKey,
					})
				end
			end
		end
	end

	local lines = { "return {" }
	table.insert(lines, string.format("    name = %q,", Layout.name))
	table.insert(lines, string.format("    display = %q,", Layout.display))
	table.insert(lines, string.format("    version = %q,", Layout.version))
	table.insert(lines, string.format("    github = %q,", Layout.github))
	table.insert(lines, string.format("    nexus_id = %q,", Layout.nexus_id))
	table.insert(lines, "    settings = {")

	for _, s in ipairs(Layout.settings) do
		table.insert(lines, "        {")
		table.insert(lines, string.format("            key = %q,", s.key))
		table.insert(lines, string.format("            title = %q,", s.title))
		table.insert(lines, string.format("            description = %q,", s.description))
		table.insert(lines, string.format("            type = %q,", s.type))

		-- Wow Only Reason To Add This Was The Keybind (I Am Stupid)
		local defaultVal
		if type(s.default) == "string" then
			defaultVal = string.format("%q", s.default)
		else
			defaultVal = tostring(s.default)
		end
		table.insert(lines, string.format("            default = %s,", defaultVal))

		if s.min then
			table.insert(lines, string.format("            min = %s,", s.min))
		end
		if s.max then
			table.insert(lines, string.format("            max = %s,", s.max))
		end
		if s.step then
			table.insert(lines, string.format("            step = %s,", s.step))
		end
		if s.format then
			table.insert(lines, string.format("            format = %q,", s.format))
		end
		if s.enabled_by then
			table.insert(lines, string.format("            enabled_by = %q,", s.enabled_by))
		end
		table.insert(lines, "        },")
	end

	table.insert(lines, "    }")
	table.insert(lines, "}")

	local LayoutString = table.concat(lines, "\n")
	return Config, LayoutString
end
