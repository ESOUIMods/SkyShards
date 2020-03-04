local strings = {
	--tooltips
	SKYS_KNOWN						= "Collected",

	SKYS_MOREINFO1					= "Town",
	SKYS_MOREINFO2					= "Delve",
	SKYS_MOREINFO3					= "Public Dungeon",
	SKYS_MOREINFO4					= "Under ground",
	SKYS_MOREINFO5					= "Group Delve",

	SKYS_SET_WAYPOINT				= "Set waypoint to skyshard",

	--settings menu header
	SKYS_TITLE						= "SkyShards",

	--appearance
	SKYS_PIN_TEXTURE				= "Select map pin icons",
	SKYS_PIN_TEXTURE_DESC		= "Select map pin icons.",
	SKYS_PIN_SIZE					= "Pin size",
	SKYS_PIN_SIZE_DESC			= "Set the size of the map pins.",
	SKYS_PIN_LAYER					= "Pin layer",
	SKYS_PIN_LAYER_DESC			= "Set the layer of the map pins when they are at same coordinates than others",

	--compass
	SKYS_COMPASS_UNKNOWN			= "Show skyshards on the compass.",
	SKYS_COMPASS_UNKNOWN_DESC	= "Show/hide icons for uncollected skyshards on the compass.",
	SKYS_COMPASS_DIST				= "Max pin distance",
	SKYS_COMPASS_DIST_DESC		= "The maximum distance for pins to appear on the compass.",

	SKYS_MAINWORLD					= "Pin color for Skyshards in overworld",
	SKYS_MAINWORLD_DESC			= "The color of the pins for skyshards directly available in the overworld",
	
	--skill panel
	SKYS_SKILLS						= "Recap on the skill panel",
	SKYS_SKILLS_DESC				= "Select the display format of the SkyShards count on the skill panel.",
	SKYS_SKILLS_OPTION1			= "Basic",
	SKYS_SKILLS_OPTION3			= "Advanced",
	SKYS_SKILLS_OPTION2			= "Detailed",

	--filters
	SKYS_UNKNOWN					= "Show unknown skyshards",
	SKYS_UNKNOWN_DESC				= "Show/hide icons for unknown skyshards on the map.",
	SKYS_COLLECTED					= "Show collected skyshards",
	SKYS_COLLECTED_DESC			= "Show/hide icons for already collected skyshards on the map.",

	--worldmap filters
	SKYS_FILTER_UNKNOWN			= "Unknown skyshards",
	SKYS_FILTER_COLLECTED		= "Collected skyshards",
	
	-- Immersive Mode
	SKYS_IMMERSIVE					= "Enable Immersive Mode based on",
	SKYS_IMMERSIVE_DESC			= "Unknown SkyShards won't be displayed based on the completion of the following objective on the current zone you are looking at",
	
	SKYS_IMMERSIVE_CHOICE1		= "Disabled",
	SKYS_IMMERSIVE_CHOICE2		= "Zone Main Quest",
	SKYS_IMMERSIVE_CHOICE3		= GetString(SI_MAPFILTER8),
	SKYS_IMMERSIVE_CHOICE4		= GetAchievementCategoryInfo(6),
	SKYS_IMMERSIVE_CHOICE5		= "Zone Quests",
	
}

for stringId, stringValue in pairs(strings) do
   ZO_CreateStringId(stringId, stringValue)
   SafeAddVersion(stringId, 1)
end
