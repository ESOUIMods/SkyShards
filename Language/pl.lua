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

SafeAddString(SKYS_SET_WAYPOINT, "Ustaw Niebiañski Od³amek jako cel podró¿y", 1)

--settings menu header
SafeAddString(SKYS_TITLE,                 "SkyShards", 1)

--appearance
SafeAddString(SKYS_PIN_TEXTURE,           "Wybierz ikonê punktów na mapie", 1)
SafeAddString(SKYS_PIN_TEXTURE_DESC,      "Wybiera ikonê punktów na mapie.", 1)
SafeAddString(SKYS_PIN_SIZE,              "Wielkoœæ punktów", 1)
SafeAddString(SKYS_PIN_SIZE_DESC,         "Ustawia wielkoœæ punktu na mapie.", 1)
SafeAddString(SKYS_PIN_LAYER,             "Warstwa punktu", 1)
SafeAddString(SKYS_PIN_LAYER_DESC,        "Ustawia kolejnoœæ warstw punktów mapy, gdy kilka punktów ma te same wspó³rzêdne", 1)

--compass
SafeAddString(SKYS_COMPASS_UNKNOWN,       "Poka¿ Niebiañskie Od³amki na kompasie.", 1)
SafeAddString(SKYS_COMPASS_UNKNOWN_DESC,  "Pokazuje/ukrywa na kompasie ikony dla niezebranych Niebiañskich Od³amków.", 1)
SafeAddString(SKYS_COMPASS_DIST,          "Maksymalna odleg³oœæ punktów", 1)
SafeAddString(SKYS_COMPASS_DIST_DESC,     "Maksymalna odleg³oœæ, w jakiej punkty pojawiaj¹ siê na kompasie.", 1)

SafeAddString(SKYS_MAINWORLD, 			  "Kolor punktów Niebiañskich Od³amków na g³ównej mapie œwiata", 1)
SafeAddString(SKYS_MAINWORLD_DESC, 		  "Kolor punktów Niebiañskich Od³amków dostêpnych bezpoœrednio na g³ównej mapie œwiata", 1)

--skill panel
SafeAddString(SKYS_SKILLS, 				  "Podsumuj w panelu umiejêtnoœci", 1)
SafeAddString(SKYS_SKILLS_DESC, 		  "Wybierz format wyœwietlania liczby Niebiañskich Od³amków w panelu umiejêtnoœci.", 1)
SafeAddString(SKYS_SKILLS_OPTION1, 		  "Podstawowy", 1)
SafeAddString(SKYS_SKILLS_OPTION3, 		  "Zaawansowany", 1)
SafeAddString(SKYS_SKILLS_OPTION2, 		  "Szczegó³owy", 1)

--filters
SafeAddString(SKYS_UNKNOWN,               "Poka¿ niezebrane Niebiañskie Od³amki", 1)
SafeAddString(SKYS_UNKNOWN_DESC,          "Pokazuje/ukrywa ikony na mapie dla niezebranych Niebiañskich Od³amków.", 1)
SafeAddString(SKYS_COLLECTED,             "Poka¿ zebrane Niebiañskie Od³amki", 1)
SafeAddString(SKYS_COLLECTED_DESC,        "Pokazuje/ukrywa ikony na mapie dla zebranych Niebiañskich Od³amków.", 1)

--worldmap filters
SafeAddString(SKYS_FILTER_UNKNOWN,        "Niezebrane Niebiañskie Od³amki", 1)
SafeAddString(SKYS_FILTER_COLLECTED,      "Zebrane Niebiañskie Od³amki", 1)

-- Immersive Mode
SafeAddString(SKYS_IMMERSIVE,				"W³¹cz tryb immersyjny jako podstawowy", 1)
SafeAddString(SKYS_IMMERSIVE_DESC,			"Niezebrane Niebiañskie Od³amki nie bêd¹ wyœwietlane, ta opcja bazuje na stopniu ukoñczenia osi¹gniêcia w danej strefie", 1)
	
SafeAddString(SKYS_IMMERSIVE_CHOICE1,		"Wy³¹cz", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE2,		"Strefa g³ównego zadania", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE3,		GetString(SI_MAPFILTER8), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE4,		GetAchievementCategoryInfo(6), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE5,		"Strefa zadañ", 1)