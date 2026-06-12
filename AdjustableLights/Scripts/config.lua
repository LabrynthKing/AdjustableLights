local Order = { "Flashlight", "Wakemaker", "Scanner", "Worklight", "Tadpole", "ScoutRay", "Hauler" }

---Yes I Am Lazy
---@param lights table<string, Light>
---@return table Config
---@return string LayoutString
function GenerateConfig(lights)
	local Config = {}
	local Layout = {
		name = "AdjustableLights",
		display = "Adjustable Lights",
		version = "1.1.5",
		github = "LabrynthKing/AdjustableLights",
		nexus_id = "381",
		settings = {},
	}

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
					title = "Enable " .. uiLabel,
					description = "Toggle " .. uiLabel .. " Customization.",
					type = "toggle",
					default = false,
				})

				-- Intensity Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "Intensity",
					title = uiLabel .. " Intensity",
					description = "The Intensity Of The " .. uiLabel .. ".",
					type = "slider",
					default = defaultValues.Intensity,
					min = (defaultValues.Intensity < 1) and 0.01 or 0.1,
					max = (defaultValues.Intensity < 1) and 5.0 or 50.0,
					step = (defaultValues.Intensity < 1) and 0.05 or 0.5,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Attenuation Radius Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "Radius",
					title = uiLabel .. " Attenuation Radius",
					description = "The Attenuation Radius Of The " .. uiLabel .. ".",
					type = "slider",
					default = defaultValues.AttenuationRadius,
					min = 100.0,
					max = 10000.0,
					step = 100.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Inner Cone Angle Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "InnerAngle",
					title = uiLabel .. " Inner Cone Angle",
					description = "The Inner Cone Angle Of The " .. uiLabel .. ".",
					type = "slider",
					default = defaultValues.InnerConeAngle,
					min = 0.0,
					max = 90.0,
					step = 1.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Outer Cone Angle Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "OuterAngle",
					title = uiLabel .. " Outer Cone Angle",
					description = "The Outer Cone Angle Of The " .. uiLabel .. ".",
					type = "slider",
					default = defaultValues.OuterConeAngle,
					min = 0.0,
					max = 90.0,
					step = 1.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Temperature Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "Temperature",
					title = uiLabel .. " Temperature",
					description = "The Temperature Of The " .. uiLabel .. " (Disabled When Using Color)",
					type = "slider",
					default = defaultValues.Temperature,
					min = 1000.0,
					max = 20000.0,
					step = 100.0,
					format = "float",
					enabled_by = masterEnableKey,
				})

				-- Falloff Exponent Slider
				table.insert(Layout.settings, {
					key = lightName .. suffix .. "Falloff",
					title = uiLabel .. " Falloff Exponent",
					description = "The Falloff Exponent Of The " .. uiLabel .. ".",
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
					title = "Enable " .. uiLabel .. " Color",
					description = "Toggle Custom " .. uiLabel .. " Color.",
					type = "toggle",
					default = false,
					enabled_by = masterEnableKey,
				})

				-- RGB Color Sliders
				local rgbConfig = { { k = "R", n = "Red" }, { k = "G", n = "Green" }, { k = "B", n = "Blue" } }
				for _, rgb in ipairs(rgbConfig) do
					table.insert(Layout.settings, {
						key = lightName .. suffix .. "Color" .. rgb.k,
						title = uiLabel .. " " .. rgb.n,
						description = rgb.n .. " Channel Value.",
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
		table.insert(lines, string.format("            default = %s,", tostring(s.default)))

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
