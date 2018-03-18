local invertZoomMult = -1

local TRUE = "true"
local FALSE = "false"

local lupsFileTarget = "lups.cfg"

local function UpdateLups()
	local settings = WG.Chobby and WG.Chobby.Configuration and WG.Chobby.Configuration.settingsMenuValues
	if not settings then
		return
	end
	
	local lupsFileName = settings.ShaderDetail_file or "LuaMenu/configs/gameConfig/zk/lups/lups3.cfg"
	local lupsAirJetDisabled = ((settings.LupsAirJet == "On") and FALSE) or TRUE
	local lupsRibbonDisabled = ((settings.LupsRibbon == "On") and FALSE) or TRUE
	local lupsShieldSphereColorDisabled = ((settings.LupsShieldSphereColor == "On") and FALSE) or TRUE
	
	local sourceFile = VFS.LoadFile(lupsFileName)
	
	sourceFile = sourceFile:gsub("__AIR_JET__", lupsAirJetDisabled)
	sourceFile = sourceFile:gsub("__RIBBON__", lupsRibbonDisabled)
	sourceFile = sourceFile:gsub("__SHIELD_SPHERE_COLOR__", lupsShieldSphereColorDisabled)
	
	local settingsFile = io.open(lupsFileTarget, "w")
	settingsFile:write(sourceFile)
	settingsFile:close()
end

local function GetUiScaleParameters()
	local realWidth, realHeight = Spring.Orig.GetViewSizes()
	local defaultUiScale = math.floor(math.max(1, realHeight/950))*100
	local maxUiScale = math.max(2, realWidth/1000)*100
	local minUiScale = math.min(0.5, realWidth/4000)*100
	return defaultUiScale, maxUiScale, minUiScale
end

local defaultUiScale, maxUiScale, minUiScale = GetUiScaleParameters()

local settingsConfig = {
	{
		name = "Graphics",
		presets = {
			{
				name = "Compat.",
				settings = {
					WaterType = "Basic",
					WaterQuality = "Low",
					DeferredRendering = "Off",
					UnitReflections = "Off",
					Shadows = "None",
					ShadowDetail = "Low",
					ParticleLimit = "2000",
					TerrainDetail = "Minimal",
					VegetationDetail = "Minimal",
					FeatureFade = "On",
					CompatibilityMode = "On",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Off",
					ShaderDetail = "Minimal",
					LupsAirJet = "Off",
					LupsRibbon = "Off",
					LupsShieldSphereColor = "Off",
					FancySky = "Off",
				}
			},
			{
				name = "Lowest",
				settings = {
					WaterType = "Reflective",
					WaterQuality = "Low",
					DeferredRendering = "Off",
					UnitReflections = "Low",
					Shadows = "Units Only",
					ShadowDetail = "Low",
					ParticleLimit = "6000",
					TerrainDetail = "Low",
					VegetationDetail = "Low",
					FeatureFade = "Off",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					ShaderDetail = "Low",
					LupsAirJet = "Off",
					LupsRibbon = "Off",
					LupsShieldSphereColor = "Off",
					FancySky = "Off",
				}
			},
			{
				name = "Low",
				settings = {
					WaterType = "Bumpmapped",
					WaterQuality = "Low",
					DeferredRendering = "Off",
					UnitReflections = "Low",
					Shadows = "Units and Terrain",
					ShadowDetail = "Medium",
					ParticleLimit = "12000",
					TerrainDetail = "Low",
					VegetationDetail = "Low",
					FeatureFade = "Off",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					ShaderDetail = "Low",
					LupsAirJet = "Off",
					LupsRibbon = "On",
					LupsShieldSphereColor = "On",
					FancySky = "Off",
				}
			},
			{
				name = "Medium",
				settings = {
					WaterType = "Bumpmapped",
					WaterQuality = "Medium",
					DeferredRendering = "On",
					UnitReflections = "Medium",
					Shadows = "Units and Terrain",
					ShadowDetail = "High",
					ParticleLimit = "15000",
					TerrainDetail = "Medium",
					VegetationDetail = "Medium",
					FeatureFade = "Off",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "Low",
					ShaderDetail = "Medium",
					LupsAirJet = "On",
					LupsRibbon = "On",
					LupsShieldSphereColor = "On",
					FancySky = "Off",
				}
			},
			{
				name = "High",
				settings = {
					WaterType = "Bumpmapped",
					WaterQuality = "High",
					DeferredRendering = "On",
					UnitReflections = "Medium",
					Shadows = "Units and Terrain",
					ShadowDetail = "Ultra",
					ParticleLimit = "25000",
					TerrainDetail = "High",
					VegetationDetail = "High",
					FeatureFade = "Off",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "High",
					ShaderDetail = "High",
					LupsAirJet = "On",
					LupsRibbon = "On",
					LupsShieldSphereColor = "On",
					FancySky = "Off",
				}
			},
			{
				name = "Ultra",
				settings = {
					WaterType = "Bumpmapped",
					WaterQuality = "Ultra",
					DeferredRendering = "On",
					UnitReflections = "Ultra",
					Shadows = "Units and Terrain",
					ShadowDetail = "Ultra",
					ParticleLimit = "50000",
					TerrainDetail = "Ultra",
					VegetationDetail = "Ultra",
					FeatureFade = "Off",
					CompatibilityMode = "Off",
					AtiIntelCompatibility_2 = "Automatic",
					AntiAliasing = "High",
					ShaderDetail = "Ultra",
					LupsAirJet = "On",
					LupsRibbon = "On",
					LupsShieldSphereColor = "On",
					FancySky = "On",
				}
			},
		},
		
		settings = {
			{
				name = "DisplayMode",
				humanName = "Ingame Display Mode",
				displayModeToggle = true,
			},
			{
				name = "LobbyDisplayMode",
				humanName = "Menu Display Mode",
				lobbyDisplayModeToggle = true,
			},
			{
				name = "WaterType",
				humanName = "Water Type",
				options = {
					{
						name = "Basic",
						apply = {
							Water = 0,
						}
					},
					{
						name = "Reflective",
						apply = {
							Water = 1,
						}
					},
					{
						name = "Refractive",
						apply = {
							Water = 2,
						}
					},
					{
						name = "Dynamic",
						apply = {
							Water = 3,
						}
					},
					{
						name = "Bumpmapped",
						apply = {
							Water = 4,
						}
					},
				},
			},
			{
				name = "WaterQuality",
				humanName = "Water Quality",
				options = {
					{
						name = "Low",
						apply = {
							BumpWaterAnisotropy = 0,
							BumpWaterBlurReflection = 0,
							BumpWaterReflection = 0,
							BumpWaterRefraction = 0,
							BumpWaterDepthBits = 16,
							BumpWaterShoreWaves = 0,
							BumpWaterTexSizeReflection = 64,
						}
					},
					{
						name = "Medium",
						apply = {
							BumpWaterAnisotropy = 0,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 1,
							BumpWaterRefraction = 1,
							BumpWaterDepthBits = 24,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 128,
						}
					},
					{
						name = "High",
						apply = {
							BumpWaterAnisotropy = 2,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 2,
							BumpWaterRefraction = 1,
							BumpWaterDepthBits = 32,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 256,
						}
					},
					{
						name = "Ultra",
						apply = {
							BumpWaterAnisotropy = 2,
							BumpWaterBlurReflection = 1,
							BumpWaterReflection = 2,
							BumpWaterRefraction = 2,
							BumpWaterDepthBits = 32,
							BumpWaterShoreWaves = 1,
							BumpWaterTexSizeReflection = 1024,
						}
					},
				},
			},
			{
				name = "DeferredRendering",
				humanName = "Deferred Rendering",
				options = {
					{
						name = "On",
						apply = {
							AllowDeferredModelRendering = 1,
							AllowDeferredMapRendering = 1,
						}
					},
					{
						name = "Off",
						apply = {
							AllowDeferredModelRendering = 0,
							AllowDeferredMapRendering = 0,
						}
					},
				},
			},
			{
				name = "UnitReflections",
				humanName = "Unit Reflection Quality",
				options = {
					{
						name="Off",
						apply = {
							CubeTexSizeReflection = 1,
							CubeTexSizeSpecular = 1,
						}
					},
					{
						name="Low",
						apply = {
							CubeTexSizeReflection = 64,
							CubeTexSizeSpecular = 64,
						}
					},
					{
						name="Medium",
						apply = {
							CubeTexSizeReflection = 128,
							CubeTexSizeSpecular = 128,
						}
					},
					{
						name="High",
						apply = {
							CubeTexSizeReflection = 256,
							CubeTexSizeSpecular = 256,
						}
					},
					{
						name="Ultra",
						apply = {
							CubeTexSizeReflection = 1024,
							CubeTexSizeSpecular = 1024,
						}
					},
				},
			},
			{
				name = "Shadows",
				humanName = "Shadows",
				options = {
					{
						name = "None",
						apply = {
							Shadows = 0
						}
					},
					{
						name = "Units Only",
						apply = {
							Shadows = 2
						}
					},
					{
						name = "Units and Terrain",
						apply = {
							Shadows = 1
						}
					},
				},
			},
			{
				name = "ShadowDetail",
				humanName = "Shadow Detail",
				options = {
					{
						name = "Low",
						apply = {
							ShadowMapSize = 1024
						}
					},
					{
						name = "Medium",
						apply = {
							ShadowMapSize = 2048
						}
					},
					{
						name = "High",
						apply = {
							ShadowMapSize = 4096
						}
					},
					{
						name = "Ultra",
						apply = {
							ShadowMapSize = 8192
						}
					},
				},
			},
			{
				name = "ParticleLimit",
				humanName = "Particle Limit",
				options = {
					{
						name = "2000",
						apply = {
							MaxParticles = 2000
						}
					},
					{
						name = "4000",
						apply = {
							MaxParticles = 4000
						}
					},
					{
						name = "6000",
						apply = {
							MaxParticles = 6000
						}
					},
					{
						name = "9000",
						apply = {
							MaxParticles = 9000
						}
					},
					{
						name = "12000",
						apply = {
							MaxParticles = 12000
						}
					},
					{
						name = "15000",
						apply = {
							MaxParticles = 15000
						}
					},
					{
						name = "20000",
						apply = {
							MaxParticles = 15000
						}
					},
					{
						name = "25000",
						apply = {
							MaxParticles = 25000
						}
					},
					{
						name = "35000",
						apply = {
							MaxParticles = 25000
						}
					},
					{
						name = "50000",
						apply = {
							MaxParticles = 50000
						}
					},
				},
			},
			{
				name = "ShaderDetail",
				humanName = "Shader Detail",
				fileTarget = lupsFileTarget,
				applyFunction = UpdateLups,
				options = {
					{
						name = "Minimal",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups0.cfg"
					},
					{
						name = "Low",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups1.cfg"
					},
					{
						name = "Medium",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups2.cfg"
					},
					{
						name = "High",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups3.cfg"
					},
					{
						name = "Ultra",
						file = "LuaMenu/configs/gameConfig/zk/lups/lups4.cfg"
					},
				},
			},
			{
				name = "LupsAirJet",
				humanName = "Aircraft Jets",
				options = {
					{
						name = "On",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "LupsRibbon",
				humanName = "Aircraft Wing Trails",
				options = {
					{
						name = "On",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "LupsShieldSphereColor",
				humanName = "Shield Effect Shader",
				options = {
					{
						name = "On",
						applyFunction = UpdateLups,
					},
					{
						name = "Off",
						applyFunction = UpdateLups,
					},
				},
			},
			{
				name = "TerrainDetail",
				humanName = "Terrain Detail",
				options = {
					{
						name = "Minimal",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 0,
							GroundDetail = 50,
						}
					},
					{
						name = "Low",
						apply = {
							GroundScarAlphaFade = 0,
							GroundDecals = 1,
							GroundDetail = 70,
						}
					},
					{
						name = "Medium",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 2,
							GroundDetail = 90,
						}
					},
					{
						name = "High",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 5,
							GroundDetail = 120,
						}
					},
					{
						name = "Ultra",
						apply = {
							GroundScarAlphaFade = 1,
							GroundDecals = 10,
							GroundDetail = 180,
						}
					},
				},
			},
			{
				name = "VegetationDetail",
				humanName = "Vegetation Detail",
				options = {
					{
						name = "Minimal",
						apply = {
							TreeRadius = 1000,
							GrassDetail = 0,
						}
					},
					{
						name = "Low",
						apply = {
							TreeRadius = 1000,
							GrassDetail = 1,
						}
					},
					{
						name = "Medium",
						apply = {
							TreeRadius = 1200,
							GrassDetail = 4,
						}
					},
					{
						name = "High",
						apply = {
							TreeRadius = 1500,
							GrassDetail = 9,
						}
					},
					{
						name = "Ultra",
						apply = {
							TreeRadius = 2500,
							GrassDetail = 16,
						}
					},
					{
						name = "Ridiculous",
						apply = {
							TreeRadius = 2500,
							GrassDetail = 100,
						}
					},
				},
			},
			{
				name = "FancySky",
				humanName = "Fancy Sky",
				options = {
					{
						name = "On",
						apply = {
							DynamicSky = 1,
							AdvSky = 1,
						}
					},
					{
						name = "Off",
						apply = {
							DynamicSky = 0,
							AdvSky = 0,
						}
					},
				},
			},
			{
				name = "FeatureFade",
				humanName = "Rock and Wreck Fade",
				options = {
					{
						name = "On",
						apply = {
							FeatureDrawDistance = 6000,
							FeatureFadeDistance = 4500,
						}
					},
					{
						name = "Off",
						apply = {
							FeatureDrawDistance = 600000,
							FeatureFadeDistance = 600000,
						}
					},
				},
			},
			{
				name = "CompatibilityMode",
				humanName = "Compatibility Mode",
				options = {
					{
						name = "On",
						apply = {
							LoadingMT = 0,
							AdvUnitShading = 0,
							AdvMapShading = 0,
							LuaShaders = 0,
							ForceDisableShaders = 1,
							UsePBO = 0,
							["3DTrees"] = 0,
							MaxDynamicMapLights = 0,
							MaxDynamicModelLights = 0,
							ROAM = 1,
						}
					},
					{
						name = "Off",
						apply = {
							LoadingMT = 0, -- See https://github.com/spring/spring/commit/bdd6b641960759ccadf3e7201e37f2192d873791
							AdvUnitShading = 1, 
							AdvMapShading = 1,
							LuaShaders = 1,
							ForceDisableShaders = 0,
							UsePBO = 1,
							["3DTrees"] = 1,
							MaxDynamicMapLights = 1,
							MaxDynamicModelLights = 1,
							ROAM = 1, --Maybe ROAM = 0 when the new renderer is fully developed
						}
					},
				},
			},
			{
				name = "AtiIntelCompatibility_2",
				humanName = "ATI/Intel Compatibility",
				options = {
					{
						name = "On",
						applyFunction = function(_, conf)
							conf:UpdateFixedSettings(conf.AtiIntelSettingsOverride)
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Enabled")
							return
						end
					},
					{
						name = "Automatic",
						applyFunction = function(_, conf)
							if conf:GetIsNotRunningNvidia() then
								conf:UpdateFixedSettings(conf.AtiIntelSettingsOverride)
								Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Enabled")
								return
							end
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Disabled")
							return
						end
					},
					{
						name = "Off",
						applyFunction = function(_, conf)
							conf:UpdateFixedSettings()
							Spring.Echo("Set ATI/intel/other non-nvidia compatibility state: Enabled")
							return
						end
					},
				},
			},
			{
				name = "AntiAliasing",
				humanName = "Anti Aliasing",
				options = {
					{
						name = "Off",
						apply = {
							FSAALevel = 1, -- Required, see https://springrts.com/mantis/view.php?id=5625
							FSAA = 0,
							SmoothLines = 0,
							SmoothPoints = 0,
						}
					},
					{
						name = "Low",
						apply = {
							FSAALevel = 4,
							FSAA = 1,
							SmoothLines = 1,
							SmoothPoints = 1,
						}
					},
					{
						name = "High",
						apply = {
							FSAALevel = 8,
							FSAA = 1,
							SmoothLines = 3,
							SmoothPoints = 3,
						}
					},
				},
			},
		},
	},
	{
		name = "Game",
		presets = {
			{
				name = "Default",
				settings = {
					InterfaceScale = defaultUiScale,
					--IconDistance = 151,
					MouseZoomSpeed = 25,
					InvertZoom = "Off",
					TextToSpeech = "On",
					MiddlePanSpeed = 15,
					CameraPanSpeed = 50,
				}
			},
		},
		settings = {
			--{
			--	name = "IconDistance",
			--	humanName = "Icon Distance",
			--	isNumberSetting = true,
			--	applyName = "UnitIconDist",
			--	minValue = 0,
			--	maxValue = 10000,
			--	springConversion = function(value)
			--		return value
			--	end,
			--},
			{
				name = "InterfaceScale",
				humanName = "Game Interface Scale",
				isNumberSetting = true,
				minValue = minUiScale,
				maxValue = maxUiScale,
				isPercent = true,
				applyFunction = function(value)
					if Spring.GetGameName() ~= "" then
						Spring.SendLuaUIMsg("SetInterfaceScale " .. value)
					end
					return {
						interfaceScale = value,
					}
				end,
			},
			{
				name = "MouseZoomSpeed",
				humanName = "Mouse Zoom Speed",
				isNumberSetting = true,
				applyName = "ScrollWheelSpeed",
				minValue = 1,
				maxValue = 500,
				springConversion = function(value)
					return value*invertZoomMult
				end,
			},
			{
				name = "InvertZoom",
				humanName = "Invert Zoom",
				options = {
					{
						name = "On",
						applyFunction = function()
							invertZoomMult = 1
							local currentZoom = WG.Chobby.Configuration.settingsMenuValues["MouseZoomSpeed"] or 25
							return {
								ScrollWheelSpeed = currentZoom,
							}
						end
					},
					{
						name = "Off",
						applyFunction = function()
							invertZoomMult = -1
							local currentZoom = WG.Chobby.Configuration.settingsMenuValues["MouseZoomSpeed"] or 25
							return {
								ScrollWheelSpeed = currentZoom * -1,
							}
						end
					},
				},
			},
			{
				name = "TextToSpeech",
				humanName = "Text To Speech",
				options = {
					{
						name = "On",
						applyFunction = function()
							local Configuration = WG.Chobby.Configuration
							Configuration:SetConfigValue("enableTextToSpeech", true)
							return false
						end
					},
					{
						name = "Off",
						applyFunction = function()
							local Configuration = WG.Chobby.Configuration
							Configuration:SetConfigValue("enableTextToSpeech", false)
							return false
						end
					},
				},
			},
			{
				name = "MiddlePanSpeed",
				humanName = "Middle Click Pan Speed",
				isNumberSetting = true,
				minValue = 0,
				maxValue = 1000,
				applyFunction = function(value)
					local camPan = 50
					if WG.Chobby and WG.Chobby.Configuration and WG.Chobby.Configuration.game_settings then
						camPan = WG.Chobby.Configuration.game_settings.OverheadScrollSpeed or camPan
					end
					value = value*(-1/200)
					return {
						MiddleClickScrollSpeed = value/camPan,
					}
				end,
			},
			{
				name = "CameraPanSpeed",
				humanName = "Camera Pan Speed",
				isNumberSetting = true,
				minValue = 0,
				maxValue = 1000,
				applyFunction = function(value)
					local middleScroll = 10
					if WG.Chobby and WG.Chobby.Configuration and WG.Chobby.Configuration.settingsMenuValues then
						middleScroll = WG.Chobby.Configuration.settingsMenuValues.MiddlePanSpeed or middleScroll
					end
					middleScroll = middleScroll*(-1/200)
					return {
						MiddleClickScrollSpeed = middleScroll/value,
						OverheadScrollSpeed = value,
					}
				end,
			},
		},
	},
}

local settingsDefault = {
	WaterType = "Bumpmapped",
	WaterQuality = "High",
	DeferredRendering = "On",
	UnitReflections = "Medium",
	Shadows = "Units and Terrain",
	ShadowDetail = "Ultra",
	ParticleLimit = "25000",
	TerrainDetail = "High",
	VegetationDetail = "High",
	FeatureFade = "Off",
	CompatibilityMode = "Off",
	AtiIntelCompatibility_2 = "Automatic",
	AntiAliasing = "High",
	ShaderDetail = "High",
	LupsAirJet = "On",
	LupsRibbon = "On",
	LupsShieldSphereColor = "On",
	FancySky = "Off",
	--IconDistance = 151,
	InterfaceScale = defaultUiScale,
	MouseZoomSpeed = 25,
	InvertZoom = "Off",
	TextToSpeech = "On",
	MiddlePanSpeed = 15,
	CameraPanSpeed = 50,
}

local settingsNames = {}
for i = 1, #settingsConfig do
	local subSettings = settingsConfig[i].settings
	for j = 1, #subSettings do
		local data = subSettings[j]
		settingsNames[data.name] = data
		if data.options then
			data.optionNames = {}
			for k = 1, #data.options do
				data.optionNames[data.options[k].name] = data.options[k]
			end
		end
	end
end

local function DefaultPresetFunc()
	if Platform then
		local gpuMemorySize = Platform.gpuMemorySize
		if gpuMemorySize then
			if gpuMemorySize < 1024 then
				-- Minimal
				return settingsConfig[1].presets[1].settings
			elseif gpuMemorySize < 2048 then
				-- Low
				return settingsConfig[1].presets[2].settings
			elseif gpuMemorySize == 2048 then
				-- Medium
				return settingsConfig[1].presets[3].settings
			end
		end
		-- High
		return settingsConfig[1].presets[4].settings
	end
	return false
end

return settingsConfig, settingsNames, settingsDefault, DefaultPresetFunc
