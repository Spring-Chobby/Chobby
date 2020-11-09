return {
	-- name is required, try not to clash with other names.
	name = "Unit Level Ups",

	-- description is displayed as a tooltip in the Custom Mode menu.
	description = "Units gain stats and weapons with experience.",

	-- roomType can be Custom, 1v1, Team, FFA, Chicken. It should probably be Custom.
	roomType = "Custom",

	-- map should match map name exactly, as is written below the minimap in the battleroom.
	map = nil,

	-- game should match game name exactly, as is shown left of the map when the game is selected.
	game = "Unit Level Ups v5",

	-- options is a table of Adv Options. The keys are internal names.
	-- All the keys can be found here: https://github.com/ZeroK-RTS/Zero-K/blob/master/ModOptions.lua
	options = {
	},
}
