--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
  return {
    name      = "Chili Visual Novel",
    desc      = "Displays pink-haired anime babes",
    author    = "KingRaptor (L.J. Lim)",
    date      = "2016.05.20",
    license   = "GNU GPL, v2 or later",
    layer     = 0,
    enabled   = true,
  }
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetDirectory(filepath) 
    return filepath and filepath:gsub("(.*/)(.*)", "%1") 
end

assert(debug)
local source = debug and debug.getinfo(1).source
local DIR = GetDirectory(source)

local config = VFS.Include(string.sub(DIR, 1, -9) .. "Configs/vn_config.lua")
config.VN_DIR = string.sub(DIR, 1, -15) .. config.VN_DIR

local Chili
local Window
local Panel
local Button
local StackPanel
local ScrollPanel
local Image
local Label
local TextBox
local screen0

-- Chili elements
local mainWindow
local textPanel
local textbox, nameLabel
local nvlPanel, nvlStack
local portraitPanel, portrait
local background
local menuButton, menuStack
local buttonSave, buttonLoad, buttonLog, buttonQuit
local logPanel
local panelChoiceDialog

--//=============================================================================

options_path = 'Settings/HUD Panels/Visual Novel'
options = {
  textSpeed = {
    name = "Text Speed",
    type = 'number',
    min = 0, 
    max = 100, 
    step = 5,
    value = 30,
    desc = 'Characters/second (0 = instant)',
  },
  waitTime = {
    name = "Wait time",
    type = 'number',
    min = 0, 
    max = 4, 
    step = 0.5,
    value = 1.5,
    desc = 'Wait time at end of each script line before auto-advance',
  },
}

local waitTime = nil -- tick down in Update()
local waitAction  -- will we actually care what this is?

-- {[1]} = {target = target, type = type, startX = x, startY = y, endX = x, endY = y, startAlpha = alpha, endAlpha = alpha, time = time, timeElapsed = time ...}}
-- every Update(dt), increment time by dt and move stuff accordingly
-- elements are removed from table once timeElapsed >= time
local animations = {}
local nvlControls = {}

-- Stuff that is defined in script and should not change during play
local defs = {
  storyInfo = {}, -- entire contents of story_info.lua
  storyDir = "",
  scripts = {}, -- {[scriptName] = {list of actions}}
  characters = {},  -- {[charactername] = {data}}
  images = {} -- {[image name] = {data}}
}

-- Variable stuff (anything that needs save/load support)
local data = {
  storyID = nil,
  images = {},  -- {[id] = Chili.Image}
  subscreens = {},
  vars = {},
  textLog = {}, -- {[1] = <AddText args table>, [2] = ...}
  backgroundFile = "",  -- path as specified in script (before prepending dir)
  portraitFile = "",  -- ditto
  currentText = nil, -- the full line (textbox will not contain the full line until text writing has reached the end)
  currentMusic = nil,  -- PlayMusic arg
  nvlMode = false,
  nvlText = {},  -- {[1] = <AddText args table>, [2] = ...}

  currentScript = nil,

  currentLine = 1,
}

scriptFunctions = {}  -- not local so script can access it

local menuVisible = false
local uiHidden = false
local autoAdvance = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function CountElements(tbl)
  local num = 0
  for i,v in pairs(tbl) do
    num = num + 1
  end
  return num
end

-- hax for parent directory syntax
local function GetFilePath(givenPath)
  if givenPath == nil then
    return ""
  end
  
  if string.find(givenPath, "../../", 1, true) == 1 then
    return string.sub(givenPath, 7)
  elseif string.find(givenPath, "../", 1, true) == 1 then
    return config.VN_DIR .. string.sub(givenPath, 4)
  else
    return defs.storyDir .. givenPath
  end
end

-- This forces the background to the back after toggling GUI (so bg doesn't draw in front of UI elements)
local function ResetMainLayers(force)
  --[[
  if force or (not uiHidden) then
    textPanel:SetLayer(1)
    menuButton:SetLayer(2)
    menuStack:SetLayer(3)
  end
  ]]--
  background:SetLayer(99)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AdvanceScript() end  -- redefined in a bit

local function GetCurrentScriptLineItem()
  local item = defs.scripts[data.currentScript][data.currentLine]
  return item
end

-- Runs the action for the current line in the script
local function PlayScriptLine(line)
  if (not data.currentScript) then
    Spring.Log(widget:GetInfo().name, LOG.ERROR, "No story loaded")
    return
  end
  line = line or data.currentLine
  local item = defs.scripts[data.currentScript][line]
  if item then
    local action = item[1]
    local args = item[2]
    if (type(args) == 'table') then
      args = Spring.Utilities.CopyTable(item[2], true)
    elseif args == nil then
      args = {}
    end
    scriptFunctions[action](args)
    if config.autoAdvanceActions[action] and (type(args) ~= 'table' or (not args.wait)) then
      AdvanceScript(false)
    end
    if (action ~= "AddText" and type(args) == 'table' and args.wait) then
      waitTime = waitTime or options.waitTime.value
    end
    
  elseif line > #defs.scripts[data.currentScript] then
    Spring.Log(widget:GetInfo().name, LOG.WARNING, "Reached end of script " .. data.currentScript)
  end
end

local function StartScript(scriptName)
  if mainWindow.hidden then
    mainWindow:Show()
  end
  mainWindow:SetLayer(1)  -- bring to front
  data.currentScript = scriptName
  data.currentLine = 1
  PlayScriptLine(1)
end

-- Text scrolling behaviour, advance to next script line at end if so desired
local function AdvanceText(time, toEnd)
  local nvlControlsEntry = nvlControls[#nvlControls]
  local nvl = false
  local textControl = textbox
  if data.nvlMode and nvlControlsEntry then
    textControl = nvlControlsEntry.text
    nvl = true
  end
  
  local wantedLength = string.len(data.currentText or "")
  local currLength = string.len(textControl.text or "")
  if currLength < wantedLength then
    local oldHeight = textControl.height
    if (toEnd) then
      textControl:SetText(data.currentText)
      textControl:UpdateLayout()
    else
      local charactersToAdd = math.floor(time * options.textSpeed.value + 0.5)
      local newLength = currLength + charactersToAdd
      if newLength > wantedLength then newLength = wantedLength end
      local newText = string.sub(data.currentText, 1, newLength)
      textControl:SetText(newText)
    end
    if nvl then
      -- force panel size
      textControl:Invalidate()
      local panel = nvlControlsEntry.panel
      local height = textControl.height + panel.padding[2] + panel.padding[4]
      if (panel.height < height) then
        panel:Resize(nil, height, true, true)
        panel:Hide()  -- force refresh
        panel:Show()
        --Spring.Echo("force resizing", textControl.height, panel.height)
      end
    end
  else
    if toEnd then
      AdvanceScript(true)
    else
      if autoAdvance then
        waitTime = waitTime or options.waitTime.value
      else
        local item = GetCurrentScriptLineItem()
        if item then
          local args = item[2]
          if (type(args) == 'table') and args.wait == false then
            waitTime = waitTime or 0
          end
        end
      end
    end
  end
end

local function ShakeImage(anim, proportion)
  local target = anim.image and data.images[anim.image] or background
  anim.baseX = anim.baseX or target.x
  anim.baseY = anim.baseY or target.y
  anim.offsetX = anim.offsetX or (math.random() > 0.5 and 1 or -1)
  anim.offsetY = anim.offsetY or (math.random() > 0.5 and 1 or -1)
  
  if (proportion == 1) then	-- animation end, reset to normal
    target.x = anim.baseX
    target.y = anim.baseY
    target:Invalidate()
    return
  end
  proportion = 0.2 + proportion * 0.8
  
  local strengthX = anim.strengthX or 32
  local strengthY = anim.strengthY or 24
  
  -- invert direction each frame
  local newOffsetX = math.random(1, strengthX) * ((anim.offsetX > 1) and -1 or 1)
  local newOffsetY = math.random(1, strengthY) * ((anim.offsetY > 1) and -1 or 1)
  newOffsetX = math.floor(newOffsetX * (1 - proportion) + 0.5)
  newOffsetY = math.floor(newOffsetY * (1 - proportion) + 0.5)
  anim.offsetX = newOffsetX
  anim.offsetY = newOffsetY
  target.x = anim.baseX + newOffsetX
  target.y = anim.baseY + newOffsetY
  target:Invalidate()
end

-- Advance animations a frame
local function AdvanceAnimations(dt)
  local toRemove = {}
  for i=1, #animations do
    local anim = animations[i]
    local done = false
    local target = anim.image and data.images[anim.image] or background
    anim.timeElapsed = (anim.timeElapsed or 0) + dt
    if anim.timeElapsed >= anim.time then
      anim.timeElapsed = anim.time
      done = true
    end
    
    -- do animations
    local proportion = anim.timeElapsed/anim.time
    if (proportion <= 0) then
      proportion = 0  -- animation at zero point, do nothing for now
    elseif (anim.type == "shake") then
      ShakeImage(anim, proportion)
    else
      local dissolve = anim.type == "dissolve" 
      anim.startX = anim.startX or target.x
      anim.startY = anim.startY or target.y
      anim.startColor = anim.startColor or target.color or {1, 1, 1, 1}
      anim.startAlpha = anim.startAlpha or (target.color and target.color[4]) or 1
      if dissolve then
        anim.startAlpha2 = anim.startAlpha2 or (target.color and 1 - target.color[4]) or 0
        target.file2 = target.oldFile
      end
      if anim.endX then
        target.x = math.floor(anim.endX * proportion + anim.startX * (1 - proportion) + 0.5)
      end
      if anim.endY then
        target.y = math.floor(anim.endY * proportion + anim.startY * (1 - proportion) + 0.5)
      end
      if anim.endColor then
        target.color = target.color or {1, 1, 1, 1}
        for i=1,4 do
          target.color[i] = anim.endColor[i] * proportion + anim.startColor[i] * (1 - proportion)
        end
        if (dissolve) then
          target.color2 = target.color2 or Spring.Utilities.CopyTable(target.color) or {1, 1, 1, 1}
          for i=1,4 do
            target.color2[i] = anim.endColor[i] * (1 - proportion) + anim.startColor[i] * proportion
          end
        end
      elseif anim.endAlpha then
        target.color = target.color or {1, 1, 1, 1}
        target.color[4] = anim.endAlpha * proportion + anim.startAlpha * (1 - proportion)
        if dissolve then
          target.color2 = target.color2 or Spring.Utilities.CopyTable(target.color) or {1, 1, 1, 1}
          target.color2[4] = anim.endAlpha * (1- proportion) + anim.startAlpha * proportion
        end
      end
      target:Invalidate()
    end
    
    if done then
      toRemove[#toRemove+1] = i
    end
  end
  for i=#toRemove,1,-1 do
    local anim = animations[toRemove[i]]
    local target = anim.image and data.images[anim.image] or background
    if anim.type == "dissolve" then
      target.file2 = nil
      target.color2 = nil
    end
    table.remove(animations, toRemove[i])
    if (anim.removeTargetOnDone) then
      data.images[target.id] = nil
      target:Dispose()
    end
  end
end

-- Go to next line in script
AdvanceScript = function(skipAnims)
  --Spring.Echo("Advancing script")
  --AdvanceText(0, true)
  if panelChoiceDialog ~= nil then
    return
  end
  waitTime = nil
  if skipAnims then
    AdvanceAnimations(99999)
  end
  data.currentLine = data.currentLine + 1
  PlayScriptLine(data.currentLine)
end


local function RemoveChoiceDialogPanel()
  if (panelChoiceDialog == nil) then return end
  panelChoiceDialog:Dispose()
  panelChoiceDialog = nil
  ResetMainLayers()
end

local function CreateChoiceDialogPanel(choices)
  if (panelChoiceDialog ~= nil) then
    RemoveChoiceDialogPanel()
  end
  panelChoiceDialog = Panel:New{
    parent = mainWindow,
    name = "vn_panelChoiceDialog",
    x = (mainWindow.width - DIALOG_PANEL_WIDTH)/2,
    y = "40%",
    height = #choices * DIALOG_BUTTON_HEIGHT + 10,
    width = DIALOG_PANEL_WIDTH,
  }
  panelChoiceDialog:SetLayer(1)
  
  local stackChoiceDialog= StackPanel:New{
    parent = panelChoiceDialog;
    name = "vn_stackChoiceDialog",
    orientation = 'vertical',
    autosize = false,
    resizeItems = true,
    centerItems = false,
    x = 0, y = 0, right = 0, bottom = 0
  }
  
  for i=1,#choices do
    local choice = choices[i]
    local text = choice.text
    local func = choice.action
    
    Button:New {
      parent = stackChoiceDialog,
      caption = text,
      width = "100%",
      height = DIALOG_BUTTON_HEIGHT,
      font = {size = DIALOG_FONT_SIZE},
      OnClick = { function() RemoveChoiceDialogPanel(); func(); ResetMainLayers(); end },
    }
  end
end

-- Register an animation to play
local function AddAnimation(args, image)
  local anim = args.animation
  anim.image = args.id
  image.color = args.startColor or image.color or {1, 1, 1, 1}
  image.color[4] = anim.startAlpha or 1
  
  anim.startX = anim.startX or args.x
  anim.startY = anim.startY or args.y
  
  if (type(anim.startX) == 'string') then
    anim.startX = image.parent.width * tonumber(anim.startX)
  end
  if (type(anim.startY) == 'string') then
    anim.startY = image.parent.width * tonumber(anim.startY)
  end
  if (type(anim.endX) == 'string') then
    anim.endX = image.parent.width * tonumber(anim.endX)
  end
  if (type(anim.endY) == 'string') then
    anim.endY = image.parent.width * tonumber(anim.endY)
  end
  
  anim.timeElapsed = anim.delay and -anim.delay or 0
  
  animations[#animations + 1] = Spring.Utilities.CopyTable(anim, true)
end

local function SetPortrait(image)
  if not portrait then return end
  image = image and GetFilePath(image) or BLANK_IMAGE_PATH
  portrait.file = image
  portrait:Invalidate()
end

local function SetTextboxHeight(control)
  local font = control.font
  local padding = control.padding
  local width  = control.width - padding[1] - padding[3]
  local height = control.height - padding[2] - padding[4]
  
  control._wrappedText = control.font:WrapText(control.text, width, height)
  local textHeight,textDescender,numLines = control.font:GetTextHeight(control._wrappedText)
  textHeight = textHeight-textDescender

  if (control.autoObeyLineHeight) then
    if (numLines>1) then
      textHeight = numLines * control.font:GetLineHeight()
    else
      --// AscenderHeight = LineHeight w/o such deep chars as 'g','p',...
      textHeight = math.min( math.max(textHeight, control.font:GetAscenderHeight()), control.font:GetLineHeight())
    end
  end
  control:Resize(nil, textHeight, true, true)
end

local function AddNVLTextBox(name, text)
  local text = TextBox:New {
    text = text,
    align = "left",
    x = NVL_NAME_WIDTH + 4 + 4 + 8,
    y = 4,
    right = 4,
    height = 32,
    --autoHeight = false  -- we do the resizing manually later
  }
  -- set textbox height
  --SetTextboxHeight(text)
  
  local name = TextBox:New {
    align = "left",
    text = name or "",  -- todo i18n
    x = 4,
    y = 4,
    width = NVL_NAME_WIDTH,
    height = 20,
    font    = {
      size = 16;
      shadow = true;
      color = speaker and speaker.color
    }
  }
  text:UpdateLayout()
  local panel = Panel:New {
    width="100%",
    height = 32,
    backgroundColor = {1, 1, 1, 0},
    --autosize = true,
    children = {
      name,
      text,
    },
  }
  nvlStack:AddChild(panel)
  text:SetText("")
  nvlControls[#nvlControls + 1] = {panel = panel, name = name, text = text}
  return panel, name, text
end

local function SubstituteVars(str)
  return string.gsub(str, "%{%{(.-)%}%}", function(a) return data.vars[a] or "" end)
end

local function AddText(args)
  -- TODO get i18n string
  local instant = args.instant or options.textSpeed.value <= 0
  args.text = SubstituteVars(args.text)
  
  if (args.append) then
    args.text = (data.currentText or "") .. args.text
  end
  data.currentText = args.text
  
  local speaker = {}
  local speakerName = args.name
  if (args.speakerID) then
    speaker = defs.characters[args.speakerID]
    speakerName = speakerName or speaker.name or ""
  end
  
  local textControl = textbox
  local label = nameLabel
  if data.nvlMode then
    if append then
      local lastNVLControl = nvlControls[#nvlControls] or AddNVLTextBox(args.name or speaker.name, args.text)
      label = lastNVLControl.name
      textControl = lastNVLControl.text
    else
      _,label,textControl = AddNVLTextBox(args.name or speaker.name, args.text)
    end
  end
  
  args.size = args.size or DEFAULT_FONT_SIZE
  if args.size ~= textControl.font.size then
    textControl.font.size = args.size
    --textBox:Invalidate()
  end
  
  if instant then
    textControl:SetText(args.text)
  elseif (not args.append) then
    textControl:SetText("")
  end
  
  if (args.speakerID) then
    local color = speaker.color
    --nameLabel:SetCaption(string.char(color[4], color[1], color[2], color[3]).. speaker.name.."\008")
    label.font.color = color
    label:SetText(speakerName)
    if args.setPortrait ~= false then
      SetPortrait(speaker.portrait)
    end
  else
    --nameLabel:SetCaption("")
    label:SetText(args.name or "")
    if args.setPortrait ~= false then
      SetPortrait(nil)
    end
  end
  label:Invalidate()
  
  if not args.noLog then
    if args.append and #data.textLog > 0 then
      data.textLog[#data.textLog] = args
    else
      data.textLog[#data.textLog + 1] = args
    end
  end
  if data.nvlMode then
    if args.append and #data.textLog > 0 then
      data.nvlText[#data.nvlText] = args
    else
      data.nvlText[#data.nvlText + 1] = args
    end
  end
  
  if instant and (args.wait == false) then
    AdvanceScript()
  end
end

-- disposes of existing stuff
local function Cleanup()
  for imageID, image in pairs(data.images) do
    image:Dispose()
  end
  scriptFunctions.ClearNVL()
  animations = {}
  --for screenID, screen in pairs(data.subscreens) do
  --  screen:Dispose()
  --end
  scriptFunctions.StopMusic()
  SetPortrait(nil)
  textbox:SetText("")
  nameLabel:SetText("")
  RemoveChoiceDialogPanel()
  
  data.images = {}
  data.subscreens = {}
  data.vars = {}
  data.textLog = {}
  data.backgroundFile = ""
  background.file = ""
  background:Invalidate()
  data.portraitFile = ""
  data.currentText = nil
  data.currentMusic = nil
  data.nvlMode = false
  data.currentScript = nil
  data.currentLine = 1
end

local function CloseStory()
  Cleanup()
  data.storyID = nil
  defs = {
    storyInfo = {},
    storyDir = "",
    scripts = {},
    characters = {},
    images = {}
  }
  if (not mainWindow.hidden) then
    mainWindow:Show()
  end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

scriptFunctions = {
  AddBackground = function(args)
    local argsType = type(args)
    local image = (argsType == 'string' and args) or (argsType == 'table' and args.file)
    background.file = GetFilePath(image)
    data.backgroundFile = image
    if (argsType == 'table' and args.animation) then
      AddAnimation(args, background)
    end
    background:Invalidate()
  end,
  
  AddImage = function(args)
    local image = data.images[args.id]
    if image then
      Spring.Log(widget:GetInfo().name, LOG.WARNING, "Image " .. args.id .. " already exists, modifying instead")
      return scriptFunctions.ModifyImage(args)
    end
    
    local imageDef = defs.images[args.defID] and Spring.Utilities.CopyTable(defs.images[args.defID], true) or {anchor = {}}
    args = Spring.Utilities.MergeTable(args, imageDef, false)
    
    local image = Image:New{
      id = args.id,
      parent = background,
      file = GetFilePath(args.file),
      height = args.height,
      width = args.width,
    }
    if (type(args.x) == 'string') then
      args.x = image.parent.width * tonumber(args.x)
    end
    if (type(args.y) == 'string') then
      args.y = image.parent.height * tonumber(args.y)
    end
    image.x = args.x - args.anchor[1]
    image.y = args.y - args.anchor[2]
    image.anchor = args.anchor or {}
    
    if (args.animation) then
      AddAnimation(args, image)
    end
    
    data.images[args.id] = image
    if (args.layer) then
      image:SetLayer(layer)
      image.layer = args.layer
    else
      image.layer = CountElements(data.images)
    end
    
    image:Invalidate()
  end,
  
  AddText = function(args)
    AddText(args)
  end,
  
  ClearNVL = function()
    for i=1,#nvlControls do
       local controls = nvlControls[i]
       controls.panel:Dispose()
    end
    nvlControls = {}
    data.nvlText = {}
  end,
  
  ClearText = function()
    nameLabel:SetText("")
    nameLabel:Invalidate()
    textbox:SetText("")
    data.currentText = nil
    SetPortrait(nil)
  end,
  
  ChoiceDialog = function(args)
    CreateChoiceDialogPanel(args)
  end,
  
  CustomAction = function(args)
    local argsType = type(args)
    local func = (argsType == 'function' and args) or (argsType == 'table' and args.func)
    func()
  end,
  
  Exit = function()
    mainWindow:Hide()
  end,
  
  JumpScript = function(script)
    StartScript(script)
  end,
  
  ModifyImage = function(args)
    local image = data.images[args.id]
    if not image then
      Spring.Log(widget:GetInfo().name, LOG.ERROR, "Attempt to modify nonexistent image " .. args.id)
      return
    end
    
    local imageDef = defs.images[args.defID] and Spring.Utilities.CopyTable(defs.images[args.defID], true) or {anchor = {}}
    args = Spring.Utilities.MergeTable(args, imageDef, false)
    
    if args.file then
      image.oldFile = image.file
      image.file = GetFilePath(args.file)
    end
    if args.height then image.height = args.height end
    if args.width then image.width = args.width end
    
    if (type(args.x) == 'string') then
      args.x = screen0.width * tonumber(args.x)
    end
    if (type(args.y) == 'string') then
      args.y = screen0.height * tonumber(args.y)
    end
    local anchor = args.anchor or image.anchor or {}
    image.anchor = anchor
    if args.x then image.x = args.x - anchor[1] end
    if args.y then image.y = args.y - anchor[2] end
    
    if (args.animation) then
      AddAnimation(args, image)
    end
    
    image:Invalidate()
  end,
  
  PlayMusic = function(args)
    local argsType = type(args)
    local track = (argsType == 'string' and args) or (argsType == 'table' and args.track)
    if not track then return end
    
    local trackFull = GetFilePath(track)
    local intro = (argsType == 'table' and args.intro and GetFilePath(args.intro)) or trackFull
    if argsType == 'table' and args.loop and WG.Music and WG.Music.StartLoopingTrack then
      WG.Music.StartLoopingTrack(intro, trackFull)
    elseif WG.Music then
      WG.Music.StartTrack(trackFull)
    else
      Spring.StopSoundStream()
      Spring.PlaySoundStream(trackFull, 1)
    end
    data.currentMusic = (argsType == 'table') and args or {track = track}
  end,
  
  PlaySound = function(args)
    if(type(args) == 'table') then
      Spring.PlaySoundFile(GetFilePath(args.file), args.volume or 1, args.channel)
    else
      Spring.PlaySoundFile(GetFilePath(args))
    end
  end,
  
  -- TODO: implement separate hideImage?
  RemoveImage = function(args)
    local argsType = type(args)
    local id = (argsType == 'string' and args) or (argsType == 'table' and args.id)
    local image = data.images[id]
    if not image then
      Spring.Log(widget:GetInfo().name, LOG.ERROR, "Attempt to modify nonexistent image " .. id)
      return
    end
    image:Dispose()
    data.images[id] = nil
  end,
  
  SetPortrait = function(args)
    local file = (type(args) == 'string' and args) or (type(args) == 'table' and args.file)
    SetPortrait(file)
  end,
  
  SetNVLMode = function(args)
    local bool = (type(args) == 'boolean' and args) or (type(args) == 'table' and args.mode)
    if (bool == data.nvlMode and not (type(args) == 'table' and args.force)) then return end
    data.nvlMode = bool
    if not uiHidden then
      if (bool) then
        textPanel:Hide()
        nvlPanel:Show()
      else
        textPanel:Show()
        nvlPanel:Hide()
      end
      ResetMainLayers()
    end
  end,
  
  SetVars = function(args)
    for i,v in pairs(args) do
      data.vars[i] = v 
    end
  end,
  
  ShakeScreen = function(args)
    args.type = "shake"
    AddAnimation({animation = args}, background)
  end,
  
  StopMusic = function(args)
    if WG.Music and WG.Music.StopTrack then
      WG.Music.StopTrack(args and (not args.continue) or true)
    else
      Spring.StopSoundStream()
    end
    data.currentMusic = nil
  end,
  
  UnsetVars = function(args)
    for i=1,#args do
       data.vars[args[i]] = nil 
    end
  end,
  
  Wait = function(args)
    local time = (type(args) == 'number' and args) or (type(args) == 'table' and args.time)
    if time then
      waitTime = time
    end
  end,
}

-- Show/hide the menu buttons
local function ToggleMenu()
  if menuVisible then
    menuStack:Hide()
  else
    menuStack:Show()
  end
  background:SetLayer(99999)
  menuVisible = not menuVisible
end

local function ToggleUI()
  if uiHidden then
    if data.nvlMode then
      nvlPanel:Show()
    else
      textPanel:Show()
    end
    menuButton:Show()
    if menuVisible then
      menuStack:Show()
    end
    if panelChoiceDialog ~= nil then
      panelChoiceDialog:Show()
    end
  else
    if data.nvlMode then
      nvlPanel:Hide()
    else
      textPanel:Hide()
    end
    menuButton:Hide()
    if menuVisible then
      menuStack:Hide()
    end
    if panelChoiceDialog ~= nil then
      panelChoiceDialog:Hide()
    end
  end
  ResetMainLayers(true)
  uiHidden = not uiHidden
end

local function RemoveLogPanel()
  if (logPanel == nil) then return end
  mainWindow:RemoveChild(logPanel)
  logPanel:Dispose()
  logPanel = nil
  ResetMainLayers()
end

-- Dialog log panel
local function CreateLogPanel()
  -- already have log panel, close it
  if (logPanel ~= nil) then
    RemoveLogPanel()
    return
  end
  
  logPanel = Panel:New {
    parent = mainWindow,
    name = "vn_logPanel",
    width = "80%",
    height = "80%",
    x = "10%",
    y = "10%",
    children = {
      Label:New {
        caption = "LOG",
        width = 64,
        height = 16,
        y = 4,
        x = 64,
        align = "center"
      }
    }
  }
  logPanel:SetLayer(1)
  local logScroll = ScrollPanel:New {
    parent = logPanel,
    name = "vn_logScroll",
    x = 0,
    y = 24,
    width = "100%",
    bottom = 32,
  }
  --[[
  local logStack = StackPanel:New {
    parent = logscroll,
    name = "vn_logstack",
    orientation = 'vertical',
    autosize = true,
    resizeItems = true,
    centerItems = false,
    width = "100%",
    height = 500,
  }
  ]]--
  local logButtonClose = Button:New {
    parent = logPanel,
    name = "vn_logButtonClose",
    caption = "Close",
    right = 4,
    bottom = 4,
    width = 48,
    height = 28,
    OnClick = { function()
        RemoveLogPanel()
      end
    }
  }
  
  local count = 0
  for i=#data.textLog,#data.textLog-50,-1 do
    count = count + 1
    local entry = data.textLog[i]
    if (not entry) then
      break
    end
    local speaker = entry.speakerID and defs.characters[entry.speakerID]
    local color = speaker and speaker.color or nil
      
    logScroll:AddChild(Panel:New {
      width="100%",
      height = LOG_PANEL_HEIGHT,
      y = (LOG_PANEL_HEIGHT + 4)*(count-1),
      children = {
        TextBox:New {
          align = "left",
          text = entry.name or (speaker and speaker.name) or "",  -- todo i18n
          x = 4,
          y = 4,
          right = 4,
          height = 20,
          font    = {
            size = 16;
            shadow = true;
            color = speaker and speaker.color
          },
        },
        TextBox:New {
          text = entry.text,
          align = "left",
          x = 4,
          y = 28,
          right = 4,
          height = 32,
        }
      },
    })
  end
end

local function GetDefs()
  return defs
end

local function GetData()
  return data
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- save/load handling

local function ImageToTable(image)
  local imgTable = {
    id = image.id,
    file = image.file,
    height = image.height,
    width = image.width,
    x = image.x,
    y = image.y,
    anchor = image.anchor,
    layer = image.layer,
    color = image.color
  }
  return imgTable
end

local function TableToImage(table)
  local image = Image:New {
    id = table.id,
    file = table.file,
    height = table.height,
    width = table.width,
    x = table.x,
    y = table.y,
    anchor = table.anchor,
    layer = table.layer,
    color = table.color,
  }
  return image
end

local function SaveGame(filename)
  filename = filename or "save.lua"
  local saveData = Spring.Utilities.CopyTable(data, true)
  
  -- force all image animations forward
  AdvanceAnimations(99999)
  
  -- we can't save userdata so change all the images to tables first
  local imagesSaved = {}
  for imageID, image in pairs(saveData.images) do
    imagesSaved[imageID] = ImageToTable(image)
  end
  saveData.imagesSaved = imagesSaved
  saveData.images = nil
  
  WG.SaveTable(saveData, defs.storyDir, filename, nil, {concise = true, prefixReturn = true, endOfFile = true})
  Spring.Log(widget:GetInfo().name, LOG.INFO, "Saved game to " .. filename)
end

local function LoadGame(filename)
  filename = filename or "save.lua"
  local path = defs.storyDir .. filename
  if not VFS.FileExists(path) then
    Spring.Log(widget:GetInfo().name, LOG.ERROR, "Unable to find save file " .. filename)
    return
  end
  
  AdvanceAnimations(99999)
  Cleanup()
  
  data = VFS.Include(path)
  scriptFunctions.AddBackground({file = data.backgroundFile, wait = true})
  scriptFunctions.SetNVLMode({mode = data.nvlMode, force = true})
  
  -- readd images from saved data
  data.images = {}
  for imageID, imageSaved in pairs(data.imagesSaved) do
    local image = TableToImage(imageSaved)
    background:AddChild(image)
    data.images[imageID] = image
  end
  for imageID, image in pairs(data.images) do
    image:SetLayer(image.layer)
  end
  data.imagesSaved = nil
  
  if data.nvlMode then
    for i=1,#data.nvlText do
      local text =  Spring.Utilities.CopyTable(data.nvlText[i], true)
      text.noLog = true
      text.append = false
      text.instant = true
      text.wait = true
      scriptFunctions.AddText(text)
    end
  else
    if data.currentText then
      local lastText = data.textLog[#data.textLog]
      if type(lastText) == 'table' then
        lastText = Spring.Utilities.CopyTable(lastText, true)
        lastText.noLog = true
        lastText.append = false
        lastText.instant = true
        lastText.wait = true
        scriptFunctions.AddText(lastText)
      end
    end
  end
  scriptFunctions.PlayMusic({track = data.currentMusic, wait = true})
  
  RemoveChoiceDialogPanel()
  local scriptItem = GetCurrentScriptLineItem()
  if scriptItem and scriptItem[1] == "ChoiceDialog" then
    PlayScriptLine()
  end
  --for screenID, screen in pairs(data.subscreens) do
  --  mainWindow:AddChild(screen)
  --end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function LoadStory(storyID, dir)
  if (data.storyID ~= nil) then
    CloseStory()
  end
  
  defs.storyDir = (dir or config.VN_DIR) .. storyID .. "/"
  local storyPath = defs.storyDir .. "story_info.lua"
  if not VFS.FileExists(storyPath, VFS.RAW_FIRST) then
    Spring.Log(widget:GetInfo().name, LOG.ERROR, "VN story " .. storyID .. " does not exist")
    return
  end
  
  defs.storyInfo = VFS.Include(storyPath)
  defs.storyInfo.scripts = defs.storyInfo.scripts or {}
  for i=1,#defs.storyInfo.scripts do
    defs.storyInfo.scripts[i] = defs.storyDir .. defs.storyInfo.scripts[i]
  end
  local autoloadScripts = VFS.DirList(defs.storyDir .. "scripts", "*.lua", VFS.RAW_FIRST)
  for i=1,#autoloadScripts do
    defs.storyInfo.scripts[#defs.storyInfo.scripts + 1] = autoloadScripts[i]
  end
  data.storyID = storyID
  
  for _,path in ipairs(defs.storyInfo.scripts) do
    if VFS.FileExists(path, VFS.RAW_FIRST) then
      local loadedScripts = VFS.Include(path)
      for scriptName,data in pairs(loadedScripts) do
        defs.scripts[scriptName] = data
      end
    else
      -- warning/error message
    end
  end
  for _,charDefPath in ipairs(defs.storyInfo.characterDefs) do
    local path = defs.storyDir .. charDefPath
    if VFS.FileExists(path, VFS.RAW_FIRST) then
      local loadedCharDefs = VFS.Include(path)	--Spring.Utilities.json.decode(VFS.LoadFile(path, VFS.ZIP))
      for charName,data in pairs(loadedCharDefs) do
        defs.characters[charName] = data
      end
    else
      -- warning/error message
    end
  end
  for _,imagesPath in ipairs(defs.storyInfo.imageDefs) do
    local path = defs.storyDir .. imagesPath
    if VFS.FileExists(path, VFS.RAW_FIRST) then
      local imageDefs = VFS.Include(path)	--Spring.Utilities.json.decode(VFS.LoadFile(path, VFS.ZIP))
      for imageName,data in pairs(imageDefs) do
        defs.images[imageName] = data
      end
    else
      -- warning/error message
    end
  end
  
  mainWindow.caption = defs.storyInfo.name
  mainWindow:Invalidate()
  
  Spring.Log(widget:GetInfo().name, LOG.INFO, "VN story " .. defs.storyInfo.name .. " loaded")
end

local function StartStory(storyID)
  LoadStory(storyID)
  StartScript(defs.storyInfo.startScript)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local textTime = 0

function widget:Update(dt)
  if (data.currentScript == nil) then
    return
  end
  
  if (waitTime) then
    waitTime = waitTime - dt
    if waitTime <= 0 then
      waitTime = nil
      AdvanceScript()
    end
  end
  AdvanceAnimations(dt)
  textTime = textTime + dt
  
  if textTime > TEXT_INTERVAL and not mainWindow.hidden then
    if Spring.GetPressedKeys()[306] then  -- ctrl
      AdvanceScript(true)
    else
      AdvanceText(textTime, false)
    end
    textTime = 0
  end
end

function widget:Initialize()
  -- chili stuff here
  if not (WG.Chili) then
    Spring.Log(widget:GetInfo().name, LOG.ERROR, "Chili not loaded")
    widgetHandler:RemoveWidget()
    return
  end

  -- chili setup
  Chili = WG.Chili
  Window = Chili.Window
  Panel = Chili.Panel
  ScrollPanel = Chili.ScrollPanel
  --Grid = Chili.Grid
  Label = Chili.Label
  TextBox = Chili.TextBox
  Image = Chili.Image
  Button = Chili.Button
  StackPanel = Chili.StackPanel
  screen0 = Chili.Screen0
  
  -- create windows
  mainWindow = Window:New{  
    name = "vn_mainWindow",
    caption = "Chili VN",
    --fontSize = 50,
    x = screen0.width*0.5 - WINDOW_WIDTH/2,
    y = screen0.height/2 - WINDOW_HEIGHT/2 - 8,
    width  = WINDOW_WIDTH,
    height = WINDOW_HEIGHT + 24,
    padding = {8, 8, 8, 8};
    --autosize   = true;
    parent = screen0,
    draggable = true,
    resizable = false,
  }
  
  menuButton = Button:New{
    parent = mainWindow,
    name = "vn_menuButton",
    caption = "MENU",
    y = 24,
    right = 4,
    width = MENU_BUTTON_WIDTH_LARGE,
    height = MENU_BUTTON_HEIGHT_LARGE,
    OnClick = {ToggleMenu}
  }
  
  buttonSave = Button:New{
    name = "vn_menuButton",
    caption = "SAVE",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() SaveGame() end}
  }
  
  buttonLoad = Button:New{
    name = "vn_buttonLoad",
    caption = "LOAD",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() LoadGame() end}
  }
  
  buttonAuto = Button:New{
    name = "vn_buttonAuto",
    caption = "AUTO",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() autoAdvance = not autoAdvance end}
  }
  
  buttonLog = Button:New{
    name = "vn_buttonLog",
    caption = "LOG",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() CreateLogPanel() end}
  }
  
  buttonOptions = Button:New{
    name = "vn_buttonOptions",
    caption = "OPT",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() WG.crude.OpenPath(options_path); WG.crude.ShowMenu(); end}
  }
  
  buttonQuit = Button:New{
    name = "vn_buttonQuit",
    caption = "QUIT",
    width = MENU_BUTTON_WIDTH,
    height = MENU_BUTTON_HEIGHT,
    OnClick = {function() Cleanup(); mainWindow:Hide() end}
  }
  
  local menuChildren
  if ALLOW_SAVE_LOAD then
    menuChildren = {buttonSave, buttonLoad, buttonAuto, buttonLog, buttonOptions, buttonQuit}
  else
    menuChildren = {buttonAuto, buttonLog, buttonOptions, buttonQuit}
  end
  menuStack = StackPanel:New{
    parent = mainWindow,
    orientation = 'vertical',
    autosize = false,
    resizeItems = true,
    centerItems = false,
    y = MENU_BUTTON_HEIGHT_LARGE + 24 + 8,
    right = 4,
    height = #menuChildren * (MENU_BUTTON_HEIGHT + 4) + 4,
    width = MENU_BUTTON_WIDTH + 4,
    padding = {0, 0, 0, 0},
    children = menuChildren,
  }
  menuStack:Hide()
  
  textPanel = Panel:New {
    parent = mainWindow,
    name = "vn_textPanel",
    width = "100%",
    height = TEXT_PANEL_HEIGHT,
    x = 0,
    bottom = 0,
  }
  --function textPanel:HitTest() return self end
  
  if USE_PORTRAIT then
    portraitPanel = Panel:New {
      parent = textPanel,
      name = "vn_portraitPanel",
      width = PORTRAIT_WIDTH + 6,
      height = PORTRAIT_HEIGHT + 6,
      x = 0,
      padding = {3, 3, 3, 3},
      y = 4,
    }
    portrait = Image:New{
      parent = portraitPanel,
      name = "vn_portrait",
      width = "100%",
      height = "100%"
    }
  end
  
  nameLabel = TextBox:New{
    parent = textPanel,
    name = "vn_nameLabel",
    text = "",
    x = (USE_PORTRAIT and PORTRAIT_WIDTH + 8 or 0) + 8,
    y = 4,
    right = 4,
    font = {
      size = 24;
      shadow = true;
    },
  }
  textbox = TextBox:New{
    parent = textPanel,
    name = "vn_textbox",
    text    = "",
    align   = "left",
    x = (USE_PORTRAIT and PORTRAIT_WIDTH + 16 or 52),
    bottom = 0,
    right = "5%",
    height = "75%",
    padding = {5, 5, 5, 5},
    font    = {
      size = DEFAULT_FONT_SIZE;
      shadow = true;
    },
  }
  
  nvlPanel = Panel:New {
    parent = mainWindow,
    name = "vn_nvlPanel",
    width = "100%",
    height = "80%",
    x = 0,
    y = "10%",
    backgroundColor = {1, 1, 1, 0.3}
  }
  nvlStack = StackPanel:New {
    parent = nvlPanel,
    name = "vn_nvlStack",
    orientation = 'vertical',
    autosize = false,
    resizeItems = false,
    centerItems = false,
    width = "100%",
    height = "100%",
  }
  
  background = Image:New{
    parent = mainWindow,
    name = "vn_background",
    x = 4,
    y = 24,
    width = "100%",
    height = "100%",
        OnClick = {function(self, x, y, mouse)
        if mouse == 1 then
          if not uiHidden then
            AdvanceText(0, true)
          else
            ToggleUI()
          end
        elseif mouse == 3 then
          ToggleUI()
        end
      end
    },
    OnMouseDown = {function(self) return true end},
  }
  
  nvlPanel:Hide()
  mainWindow:Hide()
  
  WG.VisualNovel = {
    GetDefs = GetDefs,
    GetData = GetData,
    StartScript = StartScript,
    AdvanceScript = AdvanceScript,
    StartStory = StartStory,
    LoadStory = LoadStory,
    CloseStory = CloseStory,
    Cleanup = Cleanup,
    
    scriptFunctions = scriptFunctions,
  }
  
  StartStory("test")
end

function widget:Shutdown()
  WG.VisualNovel = nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------