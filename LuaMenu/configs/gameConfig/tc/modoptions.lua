local options={
 ---- GAME SETTINGS ----
 -- make keys alwas lower case and adjust the widgest/gadgets accordingly
  {
    key    = 'a_startconds',
    name   = 'Start',
    desc   = 'Start condition settings.',
    type   = 'section',
  },

   {
    key    = "shuffle",
    name   = "Start Boxes",
    desc   = "Start box settings.",
    type   = "list",
    section= 'a_startconds',
    def    = "auto",
    items  = {
      {
        key  = "off",
        name = "Fixed",
        desc = "Startboxes have a fixed correspondence to teams.",
      },
      {
        key  = "shuffle",
        name = "Shuffle",
        desc = "Shuffle among boxes that would be used.",
      },
      {
        key  = "allshuffle",
        name = "All Shuffle",
        desc = "Shuffle all present boxes.",
      },
      {
        key  = "auto",
        name = "Autodetect",
        desc = "Shuffle if FFA.",
      },
      {
        key  = "disable",
        name = "Start Anywhere",
        desc = "Allow to place anywhere. Boxes are still drawn for reference but are not obligatory.",
      },
    },
  },

 -------------------------------------------------------------------------------
  {
    key    = 'b_resources',
    name   = 'Resources',
    desc   = 'Sets storage and amount of resources that players will start with',
    type   = 'section',
  },
  {
   key    = 'startmetal',
   scope  = 'team',
   name   = 'Team Starting metal',
   desc   = 'Determines amount of metal and metal storage this team will start with',
   type   = 'number',
   section= 'b_resources',
   def    = 1000,
   min    = 500,
   max    = 10000,
   step   = 1,  -- quantization is aligned to the def value   -- (step <= 0) means that there is no quantization
  },
  {
    key    = 'startenergy',
    name   = 'Starting energy',
    desc   = 'Determines amount of energy and energy storage that each player will start with',
    type   = 'number',
    section= 'b_resources',
    def    = 2000,
    min    = 500,
    max    = 10000,
    step   = 1,
  },
  {
    key    = 'metalmult',
    name   = 'Metal Extraction Multiplier',
    desc   = 'Multiplies metal extraction rate. For use in large team games when there are fewer mexes per player.',
    type   = 'number',
    section= 'b_resources',
    def    = 1,
    min    = 0.1,
    max    = 100,
    step   = 0.05,
  },
     {
    key    = 'corpsetime',
    name   = 'Corpse stay time',
    desc   = 'A factor that determines how long corpses will stay on the battlefield for reclaiming or resurrection',
    type   = 'number',
    section= "b_resources",
    def    = 4,
    min    = 0,
    max    = 20,
    step   = 1,
  },

  ---- AI OPTIONS ----
	{
		key    = 'e_aioptions',
		name   = 'AI Options',
		desc   = 'Additional AI Options',
		type   = 'section',
	},
	{
		key="cheatingai",
		name="Should the AI cheat?",
		desc="A cheating AI starts in skirmishes with some defense buildings, base shields and an energy and metal producing central building.",
		type = "bool",
		def = false,
		section= "e_aioptions",
	},
	{
		key="killstragglers",
		name="Kill AI stragglers?",
		desc="All (non survival mode) AI units will be killed after the AI's base was destroyed.",
		type = "bool",
		def = true,
		section= "e_aioptions",
	},
  {
	key		= "critters",
	name	= "Spawn critters",
	desc	= "This will enable spawning neutral critters on maps",
	type	= "bool",
	def		= true,
	section= "e_aioptions",
  },

 ---- CHICKEN/SURVIAL MODE STUFF ----
 --[[{
    key    = 'd_chicken',
    name   = 'Survival Mode',
    desc   = 'Settings for Survival: Custom',
    type   = 'section',
  },
  {
    key    = 'chickenspawnrate',
    name   = 'Undead Spawn Rate',
    desc   = 'Sets the frequency of undead waves in seconds.',
    type   = 'number',
    section= 'd_chicken',
    def    = 50,
    min    = 20,
    max    = 200,
    step   = 1,
  },
  {
    key    = 'burrowspawnrate',
    name   = 'Burrow Spawn Rate',
    desc   = 'Sets the frequency of burrow spawns in seconds (modified by playercount and number of existing burrows).',
    type   = 'number',
    section= 'd_chicken',
    def    = 45,
    min    = 20,
    max    = 200,
    step   = 1,
  },
  {
    key    = 'queentime',
    name   = 'Boss Time',
    desc   = 'How soon the boss appears, minutes.',
    type   = 'number',
    section= 'd_chicken',
    def    = 60,
    min    = 1,
    max    = 200,
    step   = 1,
  },
  {
    key    = 'graceperiod',
    name   = 'Grace Period',
    desc   = 'Delay before the first wave appears, minutes.',
    type   = 'number',
    section= 'd_chicken',
    def    = 2.5,
    min    = 0,
    max    = 120,
    step   = 0.5,
  },
  {
    key    = 'miniqueentime',
    name   = 'Dragon Time',
    desc   = 'Time when the Bone Dragons appear, as a proportion of boss time. 0 disables.',
    type   = 'number',
    section= 'd_chicken',
    def    = 0.6,
    min    = 0,
    max    = 1,
    step   = 0.05,
  },
  {
    key    = 'techtimemult',
    name   = 'Tech Time Mult',
    desc   = 'Multiplier for the appearance times of advanced chickens.',
    type   = 'number',
    section= 'd_chicken',
    def    = 1,
    min    = 0,
    max    = 5,
    step   = 0.05,
  },
  {
	key    = 'burrowtechtime',
	name   = 'Burrow Tech Time',
	desc   = 'How much time each burrow shaves off chicken appearance times per wave (divided by playercount), seconds',
	type   = 'number',
	section= 'chicken',
	def    = 12,
	min    = 0,
	max    = 60,
	step   = 1,
  },
  {
	key    = 'burrowqueentime',
	name   = 'Burrow Boss Time',
	desc   = 'How much time each burrow death subtracts from boss appearance time (divided by playercount), seconds',
	type   = 'number',
	section= 'chicken',
	def    = 100,
	min    = 0,
	max    = 1200,
	step   = 1,
  }, ]]--
-- Control Victory Options
	{
		key    = 'controlvictoryoptions',
		name   = 'Control Victory',
		desc   = 'Allows you to control at a granular level the individual options for Control Point Victory',
		type   = 'section',
	},
	{
		key="scoremode",
		name="Scoring Mode (Control Victory Points)",
		desc="Defines how the game is played",
		type="list",
		def="disabled",
		section="controlvictoryoptions",
		items={
			{key="disabled", name="Disabled", desc="Disable Control Points as a victory condition."},
			{key="countdown", name="Countdown", desc="A Control Point decreases all opponents' scores, zero means defeat."},
			{key="tugofwar", name="Tug of War", desc="A Control Point steals enemy score, zero means defeat."},
			{key="domination", name="Domination", desc="Holding all Control Points will grant 1000 score, first to reach the score limit wins."},
		}
	},
	{
		key    = 'limitscore',
		name   = 'Total Score',
		desc   = 'Total score amount available.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 3000,
		min    = 500,
		max    = 5000,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
	{
		key    = "numberofcontrolpoints",
		name   = "Set number of Control Points on map",
		desc   = "Sets the number of control points on the map and scales the total score amount to match. Has no effect if Preset map configs are enabled.",
		section= "controlvictoryoptions",
		type="list",
		def="7",
		section= "controlvictoryoptions",
		items={
			{key="1", name="1", desc="King of the Hill Mode"},
			{key="7", name="7", desc="Capture 7 points"},
			{key="13", name="13", desc="Capture 13 points"},
			{key="19", name="19", desc="Capture 19 points"},
			{key="25", name="25", desc="Capture 25 points"},
		}
    },
--[[	{
		key    = "usemapconfig",
		name   = "Use preset map-specific Control Point locations?",
		desc   = "Should the control point config for this map be used instead of autogenerated control points?",
		type="list",
		def="disabled",
		section= "controlvictoryoptions",
		items={
			{key="disabled", name="Disabled", desc="This will tell the game to use autogenerated control points."},
			{key="enabled", name="Enabled", desc="This will tell the game to use preset map control points (Set via map config)."},
		}
    }, ]]
	{
		key		= "startbase",
		name	= "Start with bases",
		desc	= "Players start with a small base.",
		type	= "bool",
		def		= true,
		section	= 'controlvictoryoptions',
	 },

	{
		key    = 'captureradius',
		name   = 'Capture Radius',
		desc   = 'Radius around a point in which to capture it.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 300,
		min    = 250,
		max    = 1000,
		step   = 25,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'capturetime',
		name   = 'Capture Time',
		desc   = 'Time to capture a point.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 30,
		min    = 1,
		max    = 60,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'capturebonus',
		name   = 'Capture Bonus',
		desc   = 'Percentage of how much faster capture takes place by adding more units.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 5,
		min    = 1,
		max    = 100,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'decapspeed',
		name   = 'De-Cap Speed',
		desc   = 'Speed multiplier for neutralizing an enemy point.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 2,
		min    = 1,
		max    = 3,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'starttime',
		name   = 'Start Time',
		desc   = 'The time when capturing can start.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 0,
		min    = 0,
		max    = 300,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'metalperpoint',
		name   = 'Metal given per captured point',
		desc   = 'Each player on an allyteam that has captured a point will receive this amount of resources per point captured per second',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 0,
		min    = 0,
		max    = 20,
		step   = 0.1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'energyperpoint',
		name   = 'Energy given per captured point',
		desc   = 'Each player on an allyteam that has captured a point will receive this amount of resources per point captured per second',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 0,
		min    = 0,
		max    = 20,
		step   = 0.1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'dominationscoretime',
		name   = 'Domination Score Time',
		desc   = 'Time needed holding all points to score in multi domination.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 30,
		min    = 1,
		max    = 60,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'tugofwarmodifier',
		name   = 'Tug of War Modifier',
		desc   = 'The amount of score transfered between opponents when points are captured is multiplied by this amount.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 2,
		min    = 0,
		max    = 6,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
		{
		key    = 'dominationscore',
		name   = 'Score awarded for Domination',
		desc   = 'The amount of score awarded when you have scored a domination.',
		type   = 'number',
		section= 'controlvictoryoptions',
		def    = 1000,
		min    = 500,
		max    = 1000,
		step   = 1,  -- quantization is aligned to the def value
		-- (step <= 0) means that there is no quantization
	},
-- End Control Victory Options
}

--// add key-name to the description (so you can easier manage modoptions in springie)
for i=1,#options do
  local opt = options[i]
  opt.desc = opt.desc .. '\nkey: ' .. opt.key
end

return options
