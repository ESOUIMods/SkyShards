----------------------------------------
-- Spanish localization for SkyShards --
----------------------------------------

do
   local Add = ZO_CreateStringId

   --tooltips
   Add("SKYS_KNOWN",                "Collected")

   Add("SKYS_MOREINFO1",            "Town")
   Add("SKYS_MOREINFO2",            "Solo dungeon")
   Add("SKYS_MOREINFO3",            "Public dungeon")
   Add("SKYS_MOREINFO4",            "Cave")

   --settings menu header
   Add("SKYS_TITLE",                "SkyShards")

   --appearance
   Add("SKYS_PIN_TEXTURE",          "Select map pin icons")
   Add("SKYS_PIN_TEXTURE_DESC",     "Select map pin icons.")
   Add("SKYS_PIN_SIZE",             "Pin size")
   Add("SKYS_PIN_SIZE_DESC",        "Set the size of the map pins.")
   Add("SKYS_PIN_LAYER",            "Pin layer")
   Add("SKYS_PIN_LAYER_DESC",       "Set the layer of the map pins")

   --compass
   Add("SKYS_COMPASS_UNKNOWN",      "Show skyshards on the compass.")
   Add("SKYS_COMPASS_UNKNOWN_DESC", "Show/hide icons for uncollected skyshards on the compass.")
   Add("SKYS_COMPASS_DIST",         "Max pin distance")
   Add("SKYS_COMPASS_DIST_DESC",    "The maximum distance for pins to appear on the compass.")

   --filters
   Add("SKYS_UNKNOWN",              "Show unknown skyshards")
   Add("SKYS_UNKNOWN_DESC",         "Show/hide icons for unknown skyshards on the map.")
   Add("SKYS_COLLECTED",            "Show collected skyshards")
   Add("SKYS_COLLECTED_DESC",       "Show/hide icons for already collected skyshards on the map.")

   --worldmap filters
   Add("SKYS_FILTER_UNKNOWN",       "Unknown skyshards")
   Add("SKYS_FILTER_COLLECTED",     "Collected skyshards")
end
