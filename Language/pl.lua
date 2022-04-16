----------------------------------------
-- Polish localization for SkyShards --
----------------------------------------

--Code below is commented out, because english strings was added in strings.lua.
--This is just an example how localization file should look like.


--tooltips
SafeAddString(SKYS_KNOWN,                 "Zebrane", 1)

SafeAddString(SKYS_MOREINFO1,             "Miasto", 1)
SafeAddString(SKYS_MOREINFO2,             "Grota", 1)
SafeAddString(SKYS_MOREINFO3,             "Publiczny loch", 1)
SafeAddString(SKYS_MOREINFO4,             "Podziemia", 1)
SafeAddString(SKYS_MOREINFO5,             "Grupowa grota", 1)

SafeAddString(SKYS_SET_WAYPOINT, "Ustaw Niebiański Odłamek jako cel podróży", 1)

--settings menu header
SafeAddString(SKYS_TITLE,                 "SkyShards", 1)

--appearance
SafeAddString(SKYS_PIN_TEXTURE,           "Wybierz ikonę punktów na mapie", 1)
SafeAddString(SKYS_PIN_TEXTURE_DESC,      "Wybiera ikonę punktów na mapie.", 1)
SafeAddString(SKYS_PIN_SIZE,              "Wielkość punktów", 1)
SafeAddString(SKYS_PIN_SIZE_DESC,         "Ustawia wielkość punktu na mapie.", 1)
SafeAddString(SKYS_PIN_LAYER,             "Warstwa punktu", 1)
SafeAddString(SKYS_PIN_LAYER_DESC,        "Ustawia kolejność warstw punktów mapy, gdy kilka punktów ma te same współrzędne", 1)

--compass
SafeAddString(SKYS_COMPASS_UNKNOWN,       "Pokaż Niebiańskie Odłamki na kompasie.", 1)
SafeAddString(SKYS_COMPASS_UNKNOWN_DESC,  "Pokazuje/ukrywa na kompasie ikony dla niezebranych Niebiańskich Odłamków.", 1)
SafeAddString(SKYS_COMPASS_DIST,          "Maksymalna odległość punktów", 1)
SafeAddString(SKYS_COMPASS_DIST_DESC,     "Maksymalna odległość, w jakiej punkty pojawiają się na kompasie.", 1)

SafeAddString(SKYS_MAINWORLD, 			  "Kolor punktów Niebiańskich Odłamków na głównej mapie świata", 1)
SafeAddString(SKYS_MAINWORLD_DESC, 		  "Kolor punktów Niebiańskich Odłamków dostępnych bezpośrednio na głównej mapie świata", 1)

--skill panel
SafeAddString(SKYS_SKILLS, 				  "Podsumuj w panelu umiejętności", 1)
SafeAddString(SKYS_SKILLS_DESC, 		  "Wybierz format wyświetlania liczby Niebiańskich Odłamków w panelu umiejętności.", 1)
SafeAddString(SKYS_SKILLS_OPTION1, 		  "Podstawowy", 1)
SafeAddString(SKYS_SKILLS_OPTION3, 		  "Zaawansowany", 1)
SafeAddString(SKYS_SKILLS_OPTION2, 		  "Szczegółowy", 1)

--filters
SafeAddString(SKYS_UNKNOWN,               "Pokaż niezebrane Niebiańskie Odłamki", 1)
SafeAddString(SKYS_UNKNOWN_DESC,          "Pokazuje/ukrywa ikony na mapie dla niezebranych Niebiańskich Odłamków.", 1)
SafeAddString(SKYS_COLLECTED,             "Pokaż zebrane Niebiańskie Odłamki", 1)
SafeAddString(SKYS_COLLECTED_DESC,        "Pokazuje/ukrywa ikony na mapie dla zebranych Niebiańskich Odłamków.", 1)

--worldmap filters
SafeAddString(SKYS_FILTER_UNKNOWN,        "(Sky) Niezebrane Niebiańskie Odłamki", 1)
SafeAddString(SKYS_FILTER_COLLECTED,      "(Sky) Zebrane Niebiańskie Odłamki", 1)

-- Immersive Mode
SafeAddString(SKYS_IMMERSIVE,				"Włącz tryb immersyjny jako podstawowy", 1)
SafeAddString(SKYS_IMMERSIVE_DESC,			"Niezebrane Niebiańskie Odłamki nie będą wyświetlane, ta opcja bazuje na stopniu ukończenia osiągnięcia w danej strefie", 1)
	
SafeAddString(SKYS_IMMERSIVE_CHOICE1,		"Wyłącz", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE2,		"Strefa głównego zadania", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE3,		GetString(SI_MAPFILTER8), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE4,		GetAchievementCategoryInfo(6), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE5,		"Strefa zadań", 1)