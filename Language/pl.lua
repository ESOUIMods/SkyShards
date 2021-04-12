----------------------------------------
-- English localization for SkyShards --
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

SafeAddString(SKYS_SET_WAYPOINT, "Ustaw Niebia�ski Od�amek jako cel podr�y", 1)

--settings menu header
SafeAddString(SKYS_TITLE,                 "SkyShards", 1)

--appearance
SafeAddString(SKYS_PIN_TEXTURE,           "Wybierz ikon� punkt�w na mapie", 1)
SafeAddString(SKYS_PIN_TEXTURE_DESC,      "Wybiera ikon� punkt�w na mapie.", 1)
SafeAddString(SKYS_PIN_SIZE,              "Wielko�� punkt�w", 1)
SafeAddString(SKYS_PIN_SIZE_DESC,         "Ustawia wielko�� punktu na mapie.", 1)
SafeAddString(SKYS_PIN_LAYER,             "Warstwa punktu", 1)
SafeAddString(SKYS_PIN_LAYER_DESC,        "Ustawia kolejno�� warstw punkt�w mapy, gdy kilka punkt�w ma te same wsp�rz�dne", 1)

--compass
SafeAddString(SKYS_COMPASS_UNKNOWN,       "Poka� Niebia�skie Od�amki na kompasie.", 1)
SafeAddString(SKYS_COMPASS_UNKNOWN_DESC,  "Pokazuje/ukrywa na kompasie ikony dla niezebranych Niebia�skich Od�amk�w.", 1)
SafeAddString(SKYS_COMPASS_DIST,          "Maksymalna odleg�o�� punkt�w", 1)
SafeAddString(SKYS_COMPASS_DIST_DESC,     "Maksymalna odleg�o��, w jakiej punkty pojawiaj� si� na kompasie.", 1)

SafeAddString(SKYS_MAINWORLD, 			  "Kolor punkt�w Niebia�skich Od�amk�w na g��wnej mapie �wiata", 1)
SafeAddString(SKYS_MAINWORLD_DESC, 		  "Kolor punkt�w Niebia�skich Od�amk�w dost�pnych bezpo�rednio na g��wnej mapie �wiata", 1)

--skill panel
SafeAddString(SKYS_SKILLS, 				  "Podsumuj w panelu umiej�tno�ci", 1)
SafeAddString(SKYS_SKILLS_DESC, 		  "Wybierz format wy�wietlania liczby Niebia�skich Od�amk�w w panelu umiej�tno�ci.", 1)
SafeAddString(SKYS_SKILLS_OPTION1, 		  "Podstawowy", 1)
SafeAddString(SKYS_SKILLS_OPTION3, 		  "Zaawansowany", 1)
SafeAddString(SKYS_SKILLS_OPTION2, 		  "Szczeg�owy", 1)

--filters
SafeAddString(SKYS_UNKNOWN,               "Poka� niezebrane Niebia�skie Od�amki", 1)
SafeAddString(SKYS_UNKNOWN_DESC,          "Pokazuje/ukrywa ikony na mapie dla niezebranych Niebia�skich Od�amk�w.", 1)
SafeAddString(SKYS_COLLECTED,             "Poka� zebrane Niebia�skie Od�amki", 1)
SafeAddString(SKYS_COLLECTED_DESC,        "Pokazuje/ukrywa ikony na mapie dla zebranych Niebia�skich Od�amk�w.", 1)

--worldmap filters
SafeAddString(SKYS_FILTER_UNKNOWN,        "Niezebrane Niebia�skie Od�amki", 1)
SafeAddString(SKYS_FILTER_COLLECTED,      "Zebrane Niebia�skie Od�amki", 1)

-- Immersive Mode
SafeAddString(SKYS_IMMERSIVE,				"W��cz tryb immersyjny jako podstawowy", 1)
SafeAddString(SKYS_IMMERSIVE_DESC,			"Niezebrane Niebia�skie Od�amki nie b�d� wy�wietlane, ta opcja bazuje na stopniu uko�czenia osi�gni�cia w danej strefie", 1)
	
SafeAddString(SKYS_IMMERSIVE_CHOICE1,		"Wy��cz", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE2,		"Strefa g��wnego zadania", 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE3,		GetString(SI_MAPFILTER8), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE4,		GetAchievementCategoryInfo(6), 1)
SafeAddString(SKYS_IMMERSIVE_CHOICE5,		"Strefa zada�", 1)