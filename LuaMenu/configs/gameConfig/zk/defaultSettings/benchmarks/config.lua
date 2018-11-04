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
snd_volmaster = 5]]

local data = {
	{
		humanName = "Run benchmark",
		name = "GCBenchmarkv1",
		decription = "Run and log the framerate for three different engine versions in a five minute battle. Expected run time of 20 minutes.",
		map = "Comet Catcher Redux v3.1",
		game = "Zero-K v1.6.11.1",
		topRow = ",average dt,min dt,max dt,dt_0,dt_3,dt_6,dt_9,dt_12,dt_15,dt_18,dt_21,dt_24,dt_27,dt_30,dt_33,dt_36,dt_39,dt_42,dt_45,average time,min time,max time,time_0,time_3,time_6,time_9,time_12,time_15,time_18,time_21,time_24,time_27,time_30,time_33,time_36,time_39,time_42,time_45,end unit count",
		runs = {
			{
				file = "hide_benchmark_v1_104.0.1-287-gf7b0fcc maintenance.sdfz",
				engine = "104.0.1-287-gf7b0fcc",
				settings = settings,
				runName = "Engine 287",
			},
			{
				file = "hide_benchmark_v1_104.0.1-308-g17ff6c0 maintenance.sdfz",
				engine = "104.0.1-308-g17ff6c0",
				settings = settings,
				runName = "Engine 308",
			},
			{
				file = "hide_benchmark_v1_104.0.1-309-ga8b5ffc maintenance.sdfz",
				engine = "104.0.1-309-ga8b5ffc",
				settings = settings,
				runName = "Engine 309",
			},
		}
	},
	{
		humanName = "Benchmark x20",
		name = "GCBenchmark20v1",
		decription = "Run and log the framerate for three different engine versions in a five minute battle, repeated 20 times each. Expected run time of 7 hours.",
		map = "Comet Catcher Redux v3.1",
		game = "Zero-K v1.6.11.1",
		duplicates = 20,
		topRow = ",average dt,min dt,max dt,dt_0,dt_3,dt_6,dt_9,dt_12,dt_15,dt_18,dt_21,dt_24,dt_27,dt_30,dt_33,dt_36,dt_39,dt_42,dt_45,average time,min time,max time,time_0,time_3,time_6,time_9,time_12,time_15,time_18,time_21,time_24,time_27,time_30,time_33,time_36,time_39,time_42,time_45,end unit count",
		runs = {
			{
				file = "hide_benchmark_v1_104.0.1-287-gf7b0fcc maintenance.sdfz",
				engine = "104.0.1-287-gf7b0fcc",
				settings = settings,
				runName = "Engine 287",
			},
			{
				file = "hide_benchmark_v1_104.0.1-308-g17ff6c0 maintenance.sdfz",
				engine = "104.0.1-308-g17ff6c0",
				settings = settings,
				runName = "Engine 308",
			},
			{
				file = "hide_benchmark_v1_104.0.1-309-ga8b5ffc maintenance.sdfz",
				engine = "104.0.1-309-ga8b5ffc",
				settings = settings,
				runName = "Engine 309",
			},
		}
	},
}

return data