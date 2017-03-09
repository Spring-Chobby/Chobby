ChiliFX = LCS.class{}

LOG_SECTION = "ChiliFX"

-- Private methods
function ChiliFX:init(disable)
    self.enabled = gl.CreateShader ~= nil and not disable
    Spring.Log(LOG_SECTION, LOG.NOTICE, "Enabled: " .. tostring(self.enabled))

    if self.enabled then
        Spring.Log(LOG_SECTION, LOG.NOTICE, "Loading shaders...")
        self:LoadEffectDefs()
        Spring.Log(LOG_SECTION, LOG.NOTICE, "Finished loading shaders.")
    end
end

function ChiliFX:LoadEffectDefs()
    -- Definitions
    self.effectDefs = {
        fade = {
            shader = {
                fragment = VFS.LoadFile(CHILILFX_DIR .. "shaders/fade.frag"),
            },
            uniformNames = { "tex", "multi" },
        },
        glow = {
            shader = {
                fragment = VFS.LoadFile(CHILILFX_DIR .. "shaders/glow.frag"),
            },
            uniformNames = { "tex", "multi" },
        },
--[[
        shine = {
            shader = {
                fragment = VFS.LoadFile(CHILILFX_DIR .. "shaders/shine.frag"),
                -- TODO: maybe move to code
                uniformInt = { tex0 = 0, tex1 = 1, tex2 = 2 }
            },
            uniformNames = { "tex0", "tex1", "tex2", "time" },
            rawDraw = true,
        }
--]]
    }
    -- Compiled effects
    self.effects = {}
    for name, effectDef in pairs(self.effectDefs) do
        effectDef.name = name
        self:LoadEffectDef(effectDef)
    end
    -- Active effects
    self.activeEffects = {}
end

function ChiliFX:LoadEffectDef(effectDef)
    if self.effects[effectDef.name] then
        error("Effect with name: " .. tostring(effectDef.name) ..
            " already exists. Remove it first")
    end

    -- Create effect object from the shader definition
    Spring.Log(LOG_SECTION, LOG.INFO, "Loading effect " .. tostring(effectDef.name) .. "...")
    local shader = gl.CreateShader(effectDef.shader)
    local glslLog = gl.GetShaderLog()
    if shader == nil then
        Spring.Log(LOG_SECTION, LOG.ERROR, "Error loading effect: " .. effectDef.name)
        Spring.Log(LOG_SECTION, LOG.ERROR, glslLog)
        return
    end
    if glslLog ~= "" then
        Spring.Log(LOG_SECTION, LOG.WARNING, "Warning loading effect: " .. effectDef.name)
        Spring.Log(LOG_SECTION, LOG.WARNING, glslLog)
    end
    local effectObj = {
        shader = shader,
        uniforms = {},
        textures = {},
    }

    -- Store all shader uniforms for easier access later
    for _, uName in pairs(effectDef.uniformNames) do
        effectObj.uniforms[uName] = gl.GetUniformLocation(effectObj.shader, uName)
        if effectObj.uniforms[uName] == nil then
            Spring.Log(LOG_SECTION, LOG.ERROR, "Error loading effect: " .. effectDef.name)
            Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to find uniform: " .. uName)
            return
        end
        if uName:match("tex[0-3]") then
            local texID = tonumber(uName:sub(4, 4))
            effectObj.textures[texID] = uName
            --gl.Uniform(effectObj.uniforms[texName], texID)
        end
    end

    -- Finally store the newly created shader object
    self.effects[effectDef.name] = effectObj
end

function ChiliFX:UnloadEffectDef(effectName)
    -- Delete the shader object and unregister it
    local effectObj = self.effects[effectName]
    if not effectObj then
        Spring.Log(LOG_SECTION, LOG.WARNING,
            "Trying to unload effect that doesn't exist: " .. tostring(effectName))
        return
    end
    gl.DeleteShader(effectObj.shader)
    self.effects[effectName] = nil
end


-- Public API
-- Definitions
function ChiliFX:AddEffectDef(effectDef)
    self:LoadEffectDef(effectDef)
    self.effectDefs[effectDef] = effectDef
end

function ChiliFX:RemoveEffectDef(effectName)
    if self.effectDefs[effectName] == nil then
        Spring.Log(LOG_SECTION, LOG.WARNING,
            "Trying to remove shader def that doesn't exist: " .. tostring(effectName))
    end
    if self.effects[effectName] then
        self:UnloadEffectDef(effectName)
    end
    self.effectDefs[effectName] = nil
end

local function Tex2Rect(x, y, w, h, t0, t1)
    gl.MultiTexCoord(t0, 0, 0 )
    gl.MultiTexCoord(t1, 0, 0 )
    gl.Vertex(x, y)

    gl.MultiTexCoord(t0, 0, 1 )
    gl.MultiTexCoord(t1, 0, 1 )
    gl.Vertex(x, y+h)

    gl.MultiTexCoord(t0, 1, 1 )
    gl.MultiTexCoord(t1, 1, 1 )
    gl.Vertex(x+w, y+h)

    gl.MultiTexCoord(t0, 1, 0 )
    gl.MultiTexCoord(t1, 1, 0 )
    gl.Vertex(x+w, y)
end

local function Tex3Rect(x, y, w, h, t0, t1, t2)
    gl.MultiTexCoord(t0, 0, 0 )
    gl.MultiTexCoord(t1, 0, 0 )
    gl.MultiTexCoord(t2, 0, 0 )
    gl.Vertex(x, y)

    gl.MultiTexCoord(t0, 0, 1 )
    gl.MultiTexCoord(t1, 0, 1 )
    gl.MultiTexCoord(t2, 0, 1 )
    gl.Vertex(x, y+h)

    gl.MultiTexCoord(t0, 1, 1 )
    gl.MultiTexCoord(t1, 1, 1 )
    gl.MultiTexCoord(t2, 1, 1 )
    gl.Vertex(x+w, y+h)

    gl.MultiTexCoord(t0, 1, 0 )
    gl.MultiTexCoord(t1, 1, 0 )
    gl.MultiTexCoord(t2, 1, 0 )
    gl.Vertex(x+w, y)
end

-- Sets a drawing effect on the Chili object
function ChiliFX:SetEffect(opts)
    local obj        = opts.obj     -- chili object
    local effectName = opts.effect  -- name of the effect def to apply

    if not self.enabled then
        return
    end

    local effectObj = self.effects[effectName]
    self.activeEffects[obj] = opts
    self.activeEffects[obj].DrawControl = obj.DrawControl

    obj.DrawControl = function(...)
        --Spring.Echo(" function(...) ",  ...)
        gl.UseShader(effectObj.shader)
        if effectObj.uniforms.time then
            gl.Uniform(effectObj.uniforms.time, os.clock())
        end
        if not self.effectDefs[effectName].rawDraw then
            self.activeEffects[obj].DrawControl(...)
        else
--            gl.Color(obj.color)
            local texs = {}
            for texID, texName in pairs(effectObj.textures) do
                --Spring.Echo("LoadTexture", texID, obj[texName], obj)
                gl.Texture(texID, obj[texName])
                --WG.Chili.TextureHandler.LoadTexture(texID, obj[texName], obj)
                table.insert(texs, texID)
            end
            if #texs == 1 then
                gl.TexRect(0, 0, obj.width, obj.height)
            elseif #texs == 2 then
                gl.BeginEnd(GL.QUADS, Tex2Rect, 0, 0, obj.width, obj.height, texs[1], texs[2])
            elseif #texs == 3 then
                gl.BeginEnd(GL.QUADS, Tex3Rect, 0, 0, obj.width, obj.height, texs[1], texs[2], texs[3])
            end
        end
        gl.UseShader(0)
        -- obj:Invalidate()
        -- FIXME: the line above doesn't seem to always cause a Draw to be invoked so we're hacking it with a delayed call
        WG.Delay(function() obj:Invalidate() end, 0.001)
    end
end

-- Removes the drawing effect from the Chili object
function ChiliFX:UnsetEffect(opts)
    local obj        = opts.obj    -- chili object

    if not self.enabled then
        return
    end

    obj.DrawControl = self.activeEffects[obj].DrawControl
    if self.activeEffects[obj].after then self.activeEffects[obj].after() end

    self.activeEffects[obj] = nil
end

-- Sets a timed drawing event on the Chili object
function ChiliFX:SetTimedEffect(opts)
    local obj        = opts.obj    -- chili object
    local time       = opts.time   -- time in seconds the effect should last
    local after      = opts.after  -- (optional) function to execute after the effect ends

    if not self.enabled then
        if after then after() end
        return
    end

    self:SetEffect(opts)

end

function ChiliFX:AddFadeEffect(effect)
    local obj = effect.obj
    local time = effect.time
    local after = effect.after
    local endValue = effect.endValue
    local startValue = effect.startValue or 1

    if not self.enabled then
        if after then after() end
        return
    end
    local effectObj = self.effects.fade
    if effectObj == nil then
        if after then after() end
        return
    end

    local start = os.clock()

    if obj._origDraw == nil then
        obj._origDraw = obj.DrawControl
    end

    obj.DrawControl = function(...)
        local progress = math.min((os.clock() - start) / time, 1)
        local value = startValue + progress * (endValue - startValue)

        gl.UseShader(effectObj.shader)
        gl.Uniform(effectObj.uniforms.tex, 0)
        gl.Uniform(effectObj.uniforms.multi, value)
        obj._origDraw(...)
        gl.UseShader(0)
        -- obj:Invalidate()
        -- FIXME: the line above doesn't seem to always cause a Draw to be invoked so we're hacking it with a delayed call
        WG.Delay(function() obj:Invalidate() end, 0.001)
        if progress == 1 then
            obj.DrawControl = obj._origDraw
            if after then after() end
        end
    end

    if not obj.children then return end
    for _, child in pairs(obj.children) do
        if type(child) == "table" then
            effect.obj = child
            effect.after = nil
            self:AddFadeEffect(effect)
        end
    end
    obj:Invalidate()
end

function ChiliFX:AddGlowEffect(effect)
    local obj = effect.obj
    local time = effect.time
    local after = effect.after
    local endValue = effect.endValue
    local startValue = effect.startValue or 1

    if not self.enabled then
        if after then after() end
        return
    end
    local effectObj = self.effects.glow
    if effectObj == nil then
        if after then after() end
        return
    end

    local start = os.clock()

    if obj._origDraw == nil then
        obj._origDraw = obj.DrawControl
    end

    obj.DrawControl = function(...)
        local progress = math.min((os.clock() - start) / time, 1)
        local value = startValue + progress * (endValue - startValue)

        gl.UseShader(effectObj.shader)
        gl.Uniform(effectObj.uniforms.tex, 0)
        gl.Uniform(effectObj.uniforms.multi, value)
        obj._origDraw(...)
        gl.UseShader(0)
        -- obj:Invalidate()
        -- FIXME: the line above doesn't seem to always cause a Draw to be invoked so we're hacking it with a delayed call
        WG.Delay(function() obj:Invalidate() end, 0.001)
        if progress == 1 then
            obj.DrawControl = obj._origDraw
            if after then after() end
        end
    end

    if not obj.children then return end
    for _, child in pairs(obj.children) do
        if type(child) == "table" then
            effect.obj = child
            effect.after = nil
            self:AddGlowEffect(effect)
        end
    end
    obj:Invalidate()
end

function ChiliFX:IsEnabled()
    return self.enabled
end

function ChiliFX:Enable()
    if gl.CreateShader == nil then
        Spring.Log(LOG_SECTION, LOG.ERROR, "ChiliFX not loaded. Spring has failed to detect GLSL support on your system.")
        return
    end
    self.enabled = true
    if self.effects == nil then -- we haven't loaded shaders once yet
        self:LoadEffectDefs()
    end
end

function ChiliFX:Disable()
    self.enabled = false
end
