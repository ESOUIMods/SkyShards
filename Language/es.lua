----------------------------------------
-- Spanish localization for SkyShards --
----------------------------------------

do
   local Add = ZO_CreateStringId

   --tooltips
   Add("SKYS_KNOWN",                "Collected")

   Add("SKYS_MOREINFO1",            "Ciudad")
   Add("SKYS_MOREINFO2",            "Mazmorra en solitario")
   Add("SKYS_MOREINFO3",            "Mazmorra pública")
   Add("SKYS_MOREINFO4",            "Cueva")

   --settings menu header
   Add("SKYS_TITLE",                "SkyShards")

   --appearance
   Add("SKYS_PIN_TEXTURE",          "Iconos en el mapa")
   Add("SKYS_PIN_TEXTURE_DESC",     "Define los iconos que aparecerán en el mapa.")
   Add("SKYS_PIN_SIZE",             "Tamaño de marcador")
   Add("SKYS_PIN_SIZE_DESC",        "Define el tamaño de los marcadores en el mapa.")
   Add("SKYS_PIN_LAYER",            "Nivel del marcador")
   Add("SKYS_PIN_LAYER_DESC",       "Define el nivel de los marcadores en el mapa.")

   --compass
   Add("SKYS_COMPASS_UNKNOWN",      "Mostrar fragmentos en la brújula.")
   Add("SKYS_COMPASS_UNKNOWN_DESC", "Muestra los iconos de los fragmentos del cielo desconocidos en la brújula.")
   Add("SKYS_COMPASS_DIST",         "Distancia máxima del marcador")
   Add("SKYS_COMPASS_DIST_DESC",    "La distancia máxima en la que los marcadores aparecerán en la brújula.")

   --filters
   Add("SKYS_UNKNOWN",              "Mostrar fragmentos desconocidos")
   Add("SKYS_UNKNOWN_DESC",         "Muestra los iconos de los fragmentos del cielo desconocidos en el mapa.")
   Add("SKYS_COLLECTED",            "Mostrar fragmentos coleccionados")
   Add("SKYS_COLLECTED_DESC",       "Muestra los iconos de los fragmentos del cielo ya coleccionados en el mapa.")

   --worldmap filters
   Add("SKYS_FILTER_UNKNOWN",       "(Sky) Fragmentos desconocidos")
   Add("SKYS_FILTER_COLLECTED",     "(Sky) Fragmentos coleccionados")
end
