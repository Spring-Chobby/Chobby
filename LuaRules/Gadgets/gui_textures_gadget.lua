--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--

function gadget:GetInfo()
  return {
	name      = "DualFog",
	version   = 3,
	desc      = "Fog Drawing Gadget",
	author    = "trepan, user, aegis, jK",
	date      = "2008-2011",
	license   = "GNU GPL, v2 or later",
	layer     = 1,
	enabled   = true
  }
end

if (gadgetHandler:IsSyncedCode()) then
	return false
end

Spring.Echo("loading texture gadget...")
-- Automatically generated local definitions

local GL_MODELVIEW           = GL.MODELVIEW
local GL_NEAREST             = GL.NEAREST
local GL_ONE                 = GL.ONE
local GL_ONE_MINUS_SRC_ALPHA = GL.ONE_MINUS_SRC_ALPHA
local GL_PROJECTION          = GL.PROJECTION
local GL_QUADS               = GL.QUADS
local GL_SRC_ALPHA           = GL.SRC_ALPHA
local glBeginEnd             = gl.BeginEnd
local glBlending             = gl.Blending
local glCallList             = gl.CallList
local glColor                = gl.Color
local glColorMask            = gl.ColorMask
local glCopyToTexture        = gl.CopyToTexture
local glCreateList           = gl.CreateList
local glCreateShader         = gl.CreateShader
local glCreateTexture        = gl.CreateTexture
local glDeleteShader         = gl.DeleteShader
local glDeleteTexture        = gl.DeleteTexture
local glDepthMask            = gl.DepthMask
local glDepthTest            = gl.DepthTest
local glGetMatrixData        = gl.GetMatrixData
local glGetShaderLog         = gl.GetShaderLog
local glGetUniformLocation   = gl.GetUniformLocation
local glGetViewSizes         = gl.GetViewSizes
local glLoadIdentity         = gl.LoadIdentity
local glLoadMatrix           = gl.LoadMatrix
local glMatrixMode           = gl.MatrixMode
local glMultiTexCoord        = gl.MultiTexCoord
local glPopMatrix            = gl.PopMatrix
local glPushMatrix           = gl.PushMatrix
local glResetMatrices        = gl.ResetMatrices
local glTexCoord             = gl.TexCoord
local glTexture              = gl.Texture
local glRect                 = gl.Rect
local glUniform              = gl.Uniform
local glUniformMatrix        = gl.UniformMatrix
local glUseShader            = gl.UseShader
local glVertex               = gl.Vertex
local glTranslate            = gl.Translate
local spEcho                 = Spring.Echo
local spGetCameraPosition    = Spring.GetCameraPosition
local spGetCameraVectors     = Spring.GetCameraVectors
local time                   = Spring.GetGameSeconds
local spGetDrawFrame         = Spring.GetDrawFrame

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Extra GL constants
--

local GL_DEPTH_BITS = 0x0D56

local GL_DEPTH_COMPONENT   = 0x1902
local GL_DEPTH_COMPONENT16 = 0x81A5
local GL_DEPTH_COMPONENT24 = 0x81A6
local GL_DEPTH_COMPONENT32 = 0x81A7


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local debugGfx  = false --or true

local GLSLRenderer = true
local forceNonGLSL = false -- force using the non-GLSL renderer
local post83 = false
do
	local engv = tonumber("0." .. Game.version:gsub("[^%d]",""):sub(2)) 
	engv = engv + (Game.version:find("+") and 0.01 or 0)
	post83 = (engv >= 0.83)
end
if (forceNonGLSL) then
	GLSLRenderer = false
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local gnd_min, gnd_max = Spring.GetGroundExtremes()
if (gnd_min < 0) then gnd_min = 0 end
if (gnd_max < 0) then gnd_max = 0 end
local vsx, vsy
local mx = Game.mapSizeX
local mz = Game.mapSizeZ
local fog
local CurrentCameraY
local timeNow, timeThen = 0,0


local depthShader
local depthTexture

local uniformEyePos
local uniformNoise
local uniformViewPrjInv

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
----a simple plane, very complete, would look good with shadows, reflex and stuff.

local function DrawPlaneModel()
  local layers = (fogHeight - (gnd_min+50)) / 50

  glColor(fr,fg,fb,50*fogAtten)
  glDepthTest(true)
  glBlending(true)

  glBeginEnd(GL_QUADS,function()
	for h = gnd_min+50,fogHeight,50 do
	  local l = -mx*4
	  local r = mx + mx*4
	  local t = -mz*4
	  local b = mz + mz*4
	  glVertex(l, h, t)
	  glVertex(r, h, t)
	  glVertex(r, h, b)
	  glVertex(l, h, b)
	end
  end)

  glDepthTest(false)
  glBlending(false)
  glColor(1,1,1,1)
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:ViewResize()
	vsx, vsy = gl.GetViewSizes()
	if (Spring.GetMiniMapDualScreen()=='left') then
		vsx=vsx/2;
	end
	if (Spring.GetMiniMapDualScreen()=='right') then
		vsx=vsx/2
	end

	if (depthTexture) then
		glDeleteTexture(depthTexture)
	end

	depthTexture = glCreateTexture(vsx, vsy, {
		format = GL_DEPTH_COMPONENT24,
		min_filter = GL_NEAREST,
		mag_filter = GL_NEAREST,
	})

	if (depthTexture == nil) then
		spEcho("Removing fog gadget, bad depth texture")
		gadgetHandler:Removegadget()
	end
end

gadget:ViewResize()


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local vertSrc = [[

  void main(void)
  {
	gl_TexCoord[0] = gl_MultiTexCoord0;
	gl_Position    = gl_Vertex;
  }
]]



fogColor = {1, 1, 1, 1}
local fragSrc = ([[
  const float fogAtten  = 0.003f;
  const float fogHeight = 0.8f;
  const vec3 fogColor   = vec3(0f, 0f, 1f);

  uniform sampler2D tex0;
  uniform vec3 eyePos;
  uniform vec2 noise;
#ifdef USE_INVERSEMATRIX
  uniform mat4 viewProjectionInv;
#endif

  //! source: http://www.ozone3d.net/blogs/lab/20110427/glsl-random-generator/
  float rand(vec2 n)
  {
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
  }

  void main(void)
  {
	float z = texture2D(tex0, gl_TexCoord[0].st).x;

	vec4 ppos;
	ppos.xyz = vec3(gl_TexCoord[0].st, z) * 2. - 1.;
	ppos.a   = 1.;
#ifdef USE_INVERSEMATRIX
	vec4 worldPos4 = viewProjectionInv * ppos;
#else
	vec4 worldPos4 = gl_ModelViewProjectionMatrixInverse * ppos;
#endif
	vec3 worldPos  = worldPos4.xyz / worldPos4.w;
	vec3 toPoint   = worldPos - eyePos;

#ifdef DEBUG_GFX // world position debugging
	const float k  = 100.0;
	vec3 debugColor = pow(2.0 * abs(0.5 - fract(worldPos / k)), 6.0);
	gl_FragColor = vec4(debugColor, 1.0);
	return; // BAIL
#endif

	float h0 = clamp(worldPos.y, 0.0, fogHeight);
	float h1 = clamp(eyePos.y,   0.0, fogHeight); // FIXME: uniform ...

	float len = length(toPoint);
	float dist = len * abs((h1 - h0) / toPoint.y); // div-by-zero prob?
	float atten = clamp(1.0 - exp(-dist * fogAtten), 0.0, 1.0);

	gl_FragColor = vec4(fogColor, atten);

	//! noise
	vec2 seed = gl_TexCoord[0].st + noise;
	gl_FragColor.rgb += 0.030 * rand(seed);
  }
]])

if (post83) then
  fragSrc = '#define USE_INVERSEMATRIX\n' .. fragSrc
end

if (debugGfx) then
  fragSrc = '#define DEBUG_GFX\n' .. fragSrc
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:Initialize()
	if ((not forceNonGLSL) and Spring.GetMiniMapDualScreen()~='left') then --FIXME dualscreen
		if (not glCreateShader) then
			spEcho("Shaders not found, reverting to non-GLSL gadget")
			GLSLRenderer = false
		else
			depthShader = glCreateShader({
				vertex = vertSrc,
				fragment = fragSrc,
				uniformInt = {
					tex0 = 0,
				},
			})

			if (not depthShader) then
				spEcho(glGetShaderLog())
				spEcho("Bad shader, reverting to non-GLSL gadget.")
				GLSLRenderer = false
			else
				uniformEyePos       = glGetUniformLocation(depthShader, 'eyePos')
				uniformNoise        = glGetUniformLocation(depthShader, 'noise')
				uniformViewPrjInv   = glGetUniformLocation(depthShader, 'viewProjectionInv')
			end
			Spring.Echo("loaded texture gadget!")
		end
	else
		GLSLRenderer = false
	end
	if (not GLSLRenderer) then
		fog = glCreateList(DrawPlaneModel)
	end
end


function gadget:Shutdown()
  if (GLSLRenderer) then
	glDeleteTexture(depthTexture)
	if (glDeleteShader) then
	  glDeleteShader(depthShader)
	end
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Vector Math
--

local function cross(a, b)
  return {
	(a[2] * b[3]) - (a[3] * b[2]),
	(a[3] * b[1]) - (a[1] * b[3]),
	(a[1] * b[2]) - (a[2] * b[1])
  }
end

local function add(a, b)
  return {
	a[1] * b[1],
	a[2] * b[2],
	a[3] * b[3]
  }
end

local function dot(a, b)
  return (a[1] * b[1]) + (a[2] * b[2]) + (a[3] * b[3])
end


local function normalize(a)
  local len = math.sqrt((a[1] * a[1]) + (a[2] * a[2]) + (a[3] * a[3]))
  if (len == 0.0) then
	return a
  end
  a[1] = a[1] / len
  a[2] = a[2] / len
  a[3] = a[3] / len
  return { a[1], a[2], a[3] }
end


local function scale(a, s)
  a[1] = a[1] * s
  a[2] = a[2] * s
  a[3] = a[3] * s
  return { a[1], a[2], a[3] }
end



local function fract(x)
	return select(2, math.modf(x,1))
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local dl

local function DrawTextures()
	--//FIXME handle dualscreen correctly!

	-- copy the depth buffer
	glCopyToTexture(depthTexture, 0, 0, 0, 0, vsx, vsy) --FIXME scale down?

	-- setup the shader and its uniform values
	glUseShader(depthShader)

	-- set uniforms
	local cpx, cpy, cpz = spGetCameraPosition()
	glUniform(uniformEyePos, cpx, cpy, cpz)

	local noise1 = (spGetDrawFrame() / 2521) % 1 -- why 2521? it's prime ;)
	glUniform(uniformNoise, noise1 + fract(cpx), noise1 + fract(cpz))

	if (post83) then
		glUniformMatrix(uniformViewPrjInv,  "viewprojectioninverse")
	end

	if (not dl) then
		dl = gl.CreateList(function()
			-- render a full screen quad
			glTexture(0, depthTexture)
			glTexture(0, false)
			gl.TexRect(-1, -1, 1, 1, 0, 0, 1, 1)

			--// finished
			glUseShader(0)
		end)
	end

	glCallList(dl)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function gadget:DrawWorld()
	if (GLSLRenderer) then
		if (debugGfx) then glBlending(GL_SRC_ALPHA, GL_ONE) end
		DrawTextures()

		if (debugGfx) then glBlending(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA) end
	else
	end
end

if (not GLSLRenderer) then
	function gadget:DrawScreenEffects()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
