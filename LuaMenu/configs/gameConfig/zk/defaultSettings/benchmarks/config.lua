local settings = [[MaxDynamicMapLights = 1
DynamicSky = 0
CamTimeFactor = 1
LODScale = 1
BumpWaterDepthBits = 32
FullscreenEdgeMove = 0
FSAALevel = 8
BuildWarnings = 0
GroundDetail = 120
CamTimeExponent = 4
ShadowMapSize = 2048
InitialNetworkTimeout = 0
RotOverheadScrollSpeed = 50
SmoothPoints = 3
LuaAutoModWidgets = 1
GrassDetail = 9
BumpWaterReflection = 2
LODScaleRefraction = 1
MaximumTransmissionUnit = 0
FPSScrollSpeed = 50
AdvSky = 0
CamMode = 1
MaxDynamicModelLights = 1
MiddleClickScrollSpeed = -0.0018
HangTimeout = 30
Water = 4
MouseDragScrollThreshold = 0
LogFlush = 0
FeatureDrawDistance = 600000
UsePBO = 1
LuaShaders = 1
BumpWaterTexSizeReflection = 256
ForceDisableShaders = 0
GroundScarAlphaFade = 1
Version = 2
OverheadScrollSpeed = 50
EdgeMoveWidth = 0
FontSize = 18
snd_general = 100
BumpWaterBlurReflection = 1
LODScaleShadow = 1
UnitLodDist = 9999
AdvMapShading = 1
interfaceScale = 100
MoveWarnings = 0
CubeTexSizeReflection = 128
TreeRadius = 1500
AllowDeferredMapRendering = 1
LinkBandwidth = 0
WorkerThreadSpinTime = 5
WindowedEdgeMove = 0
AdvUnitShading = 1
VerboseLevel = 10
3DTrees = 1
VSync = 0
UseLuaMemPools = 0
LoadingMT = 0
UseDistToGroundForIcons = 1.10000002
CamFreeScrollSpeed = 50
ReconnectTimeout = 0
ScrollWheelSpeed = -25
SmoothLines = 3
ShowClock = 0
DualScreenMiniMapOnLeft = 1
ROAM = 1
DisplayDebugPrefixConsole = 0
GroundDecals = 5
ReflectiveWater = 4
BumpWaterRefraction = 1
MaxParticles = 25000
SplashScreenDir = ./MenuLoadscreens
RotateLogFiles = 1
FeatureFadeDistance = 600000
Shadows = 1
BumpWaterShoreWaves = 1
MinimapOnLeft = 1
MaxSounds = 32
MiniMapMarker = 0
NormalMapping = 1
LODScaleReflection = 1
FPSFOV = 90
BumpWaterAnisotropy = 2
HardwareCursor = 1
OverheadMaxHeightFactor = 1.39999998
FSAA = 1
CubeTexSizeSpecular = 128
EdgeMoveDynamic = 0
AllowDeferredModelRendering = 1
XResolution = 1920
YResolution = 1080
WindowBorderless = 0
Fullscreen = 1
snd_volmaster = 2]]

local data = {
	{
		humanName = "Run benchmark",
		name = "Benchmarkv2",
		decription = "Compare three engine versions using six tests, each taking between 1 and 4 minutes. Expected run time of of 15 minutes. Last updated 14-11-2018.",
		map = "Comet Catcher Redux v3.1",
		game = "Zero-K test-14830-12b7004",
		duplicates = 2,
		topRow = ",average up,sdev up,min up,max up,u_0,u_3,u_6,u_9,u_12,u_15,u_18,u_21,u_24,u_27,u_30,u_33,u_36,u_39,u_42,u_45,average gf,sdev gf,min gf,max gf,g_0,g_3,g_6,g_9,g_12,g_15,g_18,g_21,g_24,g_27,g_30,g_33,g_36,g_39,g_42,g_45,end unit count",
		runs = {
			{
				file = "hide_benchmark_v2_104.0.1-287-gf7b0fcc maintenance.sdfz",
				engine = "104.0.1-287-gf7b0fcc",
				settings = settings,
				runName = "Engine 287",
			},
			{
				file = "hide_benchmark_v2_104.0.1-527-gf2536df maintenance.sdfz",
				engine = "104.0.1-527-gf2536df",
				settings = settings,
				runName = "Engine 527",
			},
			{
				file = "hide_benchmark_v2_104.0.1-889-g0871f35 maintenance.sdfz",
				engine = "104.0.1-889-g0871f35",
				settings = settings,
				runName = "Engine 889",
			},
		}
	},
	{
		humanName = "Benchmark x20",
		name = "Benchmark20v2",
		decription = "Compare three engine versions using 120 tests, each taking between 1 and 4 minutes. Expected run time of of 5 hours. Last updated 14-11-2018.",
		map = "Comet Catcher Redux v3.1",
		game = "Zero-K test-14830-12b7004",
		duplicates = 40,
		topRow = ",average up,sdev up,min up,max up,u_0,u_3,u_6,u_9,u_12,u_15,u_18,u_21,u_24,u_27,u_30,u_33,u_36,u_39,u_42,u_45,average gf,sdev gf,min gf,max gf,g_0,g_3,g_6,g_9,g_12,g_15,g_18,g_21,g_24,g_27,g_30,g_33,g_36,g_39,g_42,g_45,end unit count",
		runs = {
			{
				file = "hide_benchmark_v2_104.0.1-287-gf7b0fcc maintenance.sdfz",
				engine = "104.0.1-287-gf7b0fcc",
				settings = settings,
				runName = "Engine 287",
			},
			{
				file = "hide_benchmark_v2_104.0.1-527-gf2536df maintenance.sdfz",
				engine = "104.0.1-527-gf2536df",
				settings = settings,
				runName = "Engine 527",
			},
			{
				file = "hide_benchmark_v2_104.0.1-889-g0871f35 maintenance.sdfz",
				engine = "104.0.1-889-g0871f35",
				settings = settings,
				runName = "Engine 889",
			},
		}
	},
}

return data