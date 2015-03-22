ChiliFX = LCS.class{}

local shaderDefs = {
    {
        fragment = "fade.frag",
        name = "fade",
        uniforms = { "tex", "multi" },
    },
    {
        fragment = "glow.frag",
        name = "glow",
        uniforms = { "tex", "multi" },
    },
}

function ChiliFX:init()
    self.enabled = gl.CreateShader ~= nil

    Spring.Log("ChiliFX", LOG.NOTICE, "Enabled: " .. tostring(self.enabled))

    if self.enabled then
        Spring.Log("ChiliFX", LOG.NOTICE, "Loading shaders...")
        self:LoadShaders()
        Spring.Log("ChiliFX", LOG.NOTICE, "Finished loading shaders.")
    end
end

function ChiliFX:LoadShaders()
    self.shaders = {}
    
    for _, shaderDef in pairs(shaderDefs) do
        Spring.Log("ChiliFX", LOG.INFO, "Loading shader " .. shaderDef.name .. ": " .. shaderDef.fragment)
        local shaderObj = {}
        local shader = gl.CreateShader({
            fragment = VFS.LoadFile(CHILILFX_DIR .. "shaders/" .. shaderDef.fragment),
        })
        local glslLog = gl.GetShaderLog()
        if glslLog ~= "" then 
            Shader.Log("ChiliFX", "Error loading shader: " .. shaderDef.name)
            Spring.Log("ChiliFX", LOG.ERROR, glslLog)
        else
            local fail = false
            shaderObj.shader = shader
            for _, uniform in pairs(shaderDef.uniforms) do
                shaderObj[uniform] = gl.GetUniformLocation(shader, uniform)
                if shaderObj[uniform] == nil then
                    Spring.Log("ChiliFX", LOG.ERROR, "Error loading shader: " .. shaderDef.name)
                    Spring.Log("ChiliFX", LOG.ERROR, "Failed to find uniform: " .. uniform)
                    fail = true
                    break
                end
            end
            if not fail then
                self.shaders[shaderDef.name] = shaderObj
            end
        end
    end
end

-- public functions
function ChiliFX:AddFadeEffect(effect)
    local obj = effect.obj
    local time = effect.time
    local callback = effect.callback
    local endValue = effect.endValue
    local startValue = effect.startValue or 1

    local shaderObj = self.shaders.fade
    if not (self.enabled and shaderObj) then
        if callback then callback() end
        return
    end

    local start = os.clock()

    if obj._origDraw == nil then
        obj._origDraw = obj.DrawControl
    end

    obj.DrawControl = function(...)
        local progress = math.min((os.clock() - start) / time, 1)
        local value = startValue + progress * (endValue - startValue)

        gl.UseShader(shaderObj.shader)
        gl.Uniform(shaderObj.tex, 0)
        gl.Uniform(shaderObj.multi, value)
        obj._origDraw(...) 
        gl.UseShader(0)
        -- obj:Invalidate()
        -- FIXME: the line above doesn't seem to always cause a Draw to be invoked so we're hacking it with a delayed call
        WG.Delay(function() obj:Invalidate() end, 0.001)
        if progress == 1 then
            obj.DrawControl = obj._origDraw
            if callback then callback() end
        end
    end

    if not obj.children then return end
    for _, child in pairs(obj.children) do
        if type(child) == "table" then
            effect.obj = child
            effect.callback = nil
            self:AddFadeEffect(effect)
        end
    end
    obj:Invalidate()
end

function ChiliFX:AddGlowEffect(effect)
    local obj = effect.obj
    local time = effect.time
    local callback = effect.callback
    local endValue = effect.endValue
    local startValue = effect.startValue or 1

    local shaderObj = self.shaders.glow
    if not (self.enabled and shaderObj) then
        if callback then callback() end
        return
    end

    local start = os.clock()

    if obj._origDraw == nil then
        obj._origDraw = obj.DrawControl
    end

    obj.DrawControl = function(...)
        local progress = math.min((os.clock() - start) / time, 1)
        local value = startValue + progress * (endValue - startValue)

        gl.UseShader(shaderObj.shader)
        gl.Uniform(shaderObj.tex, 0)
        gl.Uniform(shaderObj.multi, value)
        obj._origDraw(...) 
        gl.UseShader(0)
        -- obj:Invalidate()
        -- FIXME: the line above doesn't seem to always cause a Draw to be invoked so we're hacking it with a delayed call
        WG.Delay(function() obj:Invalidate() end, 0.001)
        if progress == 1 then
            obj.DrawControl = obj._origDraw
            if callback then callback() end
        end
    end

    if not obj.children then return end
    for _, child in pairs(obj.children) do
        if type(child) == "table" then
            effect.obj = child
            effect.callback = nil
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
        Spring.Log("ChiliFX", LOG.ERROR, "ChiliFX not loaded. Spring has failed to detect GLSL support on your system.")
        return
    end
    self.enabled = true
end

function ChiliFX:Disable()
    self.enabled = false
end

ChiliFX = ChiliFX()