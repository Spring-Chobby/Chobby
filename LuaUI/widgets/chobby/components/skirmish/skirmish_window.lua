SkirmishWindow = LCS.class{}

function SkirmishWindow:init(parent)
	self.btnClose = Button:New {
		right = 10,
		y = 0,
		width = 60,
		height = 35,
		caption = Configuration:GetErrorColor() .. i18n("close") .. "\b",
		OnClick = {
			function()
				self.window:Hide()
			end
		},
	}
	
	self.gameListStack = StackPanel:New {
		x = 10,
		width = "100%",
		y = 10,
		resizeItems = false,
		autosize    = true,
		children = {
			Label:New {
				caption = '-- Select Game --',
				y = 6,
				fontSize = 18,
				x = '0%',
				width = '100%',
				align = 'center'
			}
		}
	}
	
	for _, archive in pairs(VFS.GetAllArchives()) do
		local info = VFS.GetArchiveInfo(archive)
		if info and info.modtype == 1 then
			self.gameListStack:AddChild(Button:New {
				caption  = info.name or (info.game .. " " .. (info.version or "")),
				tooltip  = info.name .. "\n" .. (info.description or ""),
				x 		 = 0,
				width    = 500,
				y        = #self.gameListStack.children * 45,
				height   = 40,
				fontSize = 20,
				OnClick = {
					function(self)
						StartScript(info.name)
					end
				}
			})
		end
	end

	self.window = Window:New {
		x = 250,
		right = 5,
		y = 0,
		bottom = 5,
		parent = parent,
		resizable = false,
		draggable = false,
		padding = {0, 20, 0, 0},
		children = {
			self.btnClose,
			ScrollPanel:New {
				x = 5,
				right = 5,
				y = 50,
				bottom = 10,
				borderColor = {0,0,0,0},
				horizontalScrollbar = false,
				children = {
					self.gameListStack,
				}
			}
		},
	}
end

function ScriptTXT(script)
  local string = '[Game]\n{\n\n'

  -- First write Tables
  for key, value in pairs(script) do
    if type(value) == 'table' then
      string = string..'\t['..key..']\n\t{\n'
      for key, value in pairs(value) do
        string = string..'\t\t'..key..' = '..value..';\n'
      end
      string = string..'\t}\n\n'
    end
  end

  -- Then the rest (purely for aesthetics)
  for key, value in pairs(script) do
    if type(value) ~= 'table' then
      string = string..'\t'..key..' = '..value..';\n'
    end
  end
  string = string..'}'

  local txt = io.open('script.txt', 'w+')
  txt:write(string)
	txt:close()
  return string
end

function StartScript(name)
	local script = {
		player0  =  {
			isfromdemo = 0,
			name = 'Local',
			rank = 0,
			spectator = 1,
			team = 0,
		},

		team0  =  {
			allyteam = 0,
			rgbcolor = '0.99609375 0.546875 0',
			side = 'CORE',
			teamleader = 0,
		},

		allyteam0  =  {
			numallies = 0,
		},

		gametype = name,
		hostip = '127.0.0.1',
		hostport = 8458, -- probably should pick hosts better
		ishost = 1,
		mapname = Game.mapName, --'Blank v1', -- TODO: map choosing
		myplayername = 'Local',
		nohelperais = 0,
		numplayers = 1,
		numusers = 2,
		startpostype = 2,
	}
	
	local scriptFileName = "scriptFile.txt"
	local scriptFile = io.open(scriptFileName, "w")
	local scriptTxt = ScriptTXT(script)
	scriptFile:write(scriptTxt)
	scriptFile:close()
	Spring.Start(scriptFileName, "")
end

-- function SkirmishWindow:GenerateScriptTxt()
-- 	local battle = lobby:GetBattle(self.battleID)
-- 	local scriptTxt = 
-- [[
-- [GAME]
-- {
-- 	HostIP=__IP__;
-- 	HostPort=__PORT__;
-- 	IsHost=0;
-- 	MyPlayerName=__MY_PLAYER_NAME__;
-- 	MyPasswd=__MY_PASSWD__;
-- }
-- ]]
-- 
-- 	scriptTxt = scriptTxt:gsub("__IP__", battle.ip)
-- 						:gsub("__PORT__", battle.port)
-- 						:gsub("__MY_PLAYER_NAME__", lobby:GetMyUserName())
-- 						:gsub("__MY_PASSWD__", "12345")
-- 	return scriptTxt
-- end
