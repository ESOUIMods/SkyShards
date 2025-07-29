--[[
-------------------------------------------------------------------------------
-- SkyShards
-------------------------------------------------------------------------------
-- Original author: Ales Machat (Garkin), started 2014-04-05
--
-- Maintainers:
--    Ayantir (contributions starting 2015-11-07)
--    AssemblerManiac (contributions starting 2018-05-27)
--    Sharlikran (current maintainer, contributions starting 2020-06-24)
--
-------------------------------------------------------------------------------
-- This addon includes contributions licensed under the following terms:
--
-- MIT License (Garkin, 2014–2015):
--   Permission is hereby granted, free of charge, to any person obtaining a copy
--   of this software and associated documentation files (the "Software"), to deal
--   in the Software without restriction, including without limitation the rights
--   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--   copies of the Software, and to permit persons to whom the Software is
--   furnished to do so, subject to the conditions in the LICENSE file.
--
-- Creative Commons BY-NC-SA 4.0 (Ayantir, AssemblerManiac, 2015–2020):
--   You are free to share and adapt the material with attribution, but not for
--   commercial purposes. Derivatives must be licensed under the same terms.
--   Full terms at: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
--
-- BSD 3-Clause License (Sharlikran, 2020–present):
--   Redistribution and use in source and binary forms, with or without
--   modification, are permitted under the conditions detailed in the LICENSE file.
--
-------------------------------------------------------------------------------
-- Maintainer Notice:
-- Redistribution of this addon outside of ESOUI.com or GitHub is discouraged
-- unless authorized by the current maintainer. While the original MIT license
-- permits wide redistribution, uncoordinated uploads may cause version
-- fragmentation or confusion. Please respect the intent of the maintainers and
-- the ESO addon ecosystem.
-- ----------------------------------------------------------------------------
-- Data Integrity and Attribution Notice:
-- While individual skyshard locations can be discovered using the ESO API,
-- the compiled dataset provided in SkyShards is the result of years of
-- manual exploration, community submissions, and dedicated contributions.
-- Recreating this dataset independently requires significant time and effort.
--
-- Direct reuse, copying, or redistribution of the data tables, either in full
-- or in substantial part, without permission from the current maintainer,
-- is prohibited. Misrepresenting this work as your own, or implying you
-- independently compiled the data, undermines the efforts of the contributors.
--
-- If you wish to incorporate this data into your addon or tool, please
-- contact the current maintainer to request permission and discuss proper
-- attribution.
-- ----------------------------------------------------------------------------
]]
--Libraries--------------------------------------------------------------------
local LMP = LibMapPins
local GPS = LibGPS3

--Local constants -------------------------------------------------------------

local SKYSHARDS_PINDATA_LOCX = 1
local SKYSHARDS_PINDATA_LOCY = 2
local SKYSHARDS_PINDATA_ACHIEVEMENTID = 3
local SKYSHARDS_PINDATA_ZONEGUIDEINDEX = 4
local SKYSHARDS_PINDATA_MOREINFO = 5

local SKYSHARDS_PINDATA_ON_CITY_MAP = 1
local SKYSHARDS_PINDATA_IN_DELVE = 2
local SKYSHARDS_PINDATA_IN_PUBLIC_DUNGEON = 3
local SKYSHARDS_PINDATA_UNDER_GROUND = 4
local SKYSHARDS_PINDATA_IN_GROUP_DELVE = 5

local SKYSHARDS_SKILLPANEL_FORMAT_BASIC = 1
local SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED = 2
local SKYSHARDS_SKILLPANEL_FORMAT_DETAILED = 3

-- Local functions ------------------------------------------------------------
local function MyPrint(...)
  CHAT_ROUTER:AddSystemMessage(...)
end

local collectedSkyShards
local totalSkyShards

--tooltip creator
local pinTooltipCreator = {}
pinTooltipCreator.tooltip = 1 --TOOLTIP_MODE.INFORMATION
pinTooltipCreator.creator = function(pin)

  local _, pinTag = pin:GetPinTypeAndTag()
  local name = GetAchievementInfo(pinTag[SKYSHARDS_PINDATA_ACHIEVEMENTID])
  local zoneId = GetSkyshardAchievementZoneId(pinTag[SKYSHARDS_PINDATA_ACHIEVEMENTID])
  local shardId = GetZoneSkyshardId(zoneId, pinTag[SKYSHARDS_PINDATA_ZONEGUIDEINDEX])
  local description = GetSkyshardHint(shardId)
  local shardStatus = GetSkyshardDiscoveryStatus(shardId)
  local info = {}

  if pinTag[SKYSHARDS_PINDATA_MOREINFO] ~= nil then
    table.insert(info, "[" .. GetString("SKYS_MOREINFO", pinTag[SKYSHARDS_PINDATA_MOREINFO]) .. "]")
  end
  if shardStatus == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
    table.insert(info, "[" .. GetString(SKYS_KNOWN) .. "]")
  end

  local informationTooltip = IsInGamepadPreferredMode() and ZO_MapLocationTooltip_Gamepad or InformationTooltip
  if IsInGamepadPreferredMode() then
    local tooltip = informationTooltip.tooltip
    local mapTitleStyle = tooltip:GetStyle("mapTitle")
    informationTooltip:LayoutIconStringLine(tooltip, nil, zo_strformat("<<1>>", name), mapTitleStyle)
    informationTooltip:LayoutIconStringLine(tooltip, nil, zo_strformat("(<<1>>) <<2>>", pinTag[SKYSHARDS_PINDATA_ZONEGUIDEINDEX], description),
      { fontSize = 27, fontColorField = GAMEPAD_TOOLTIP_COLOR_GENERAL_COLOR_3 })
    if info[1] then
      informationTooltip:LayoutIconStringLine(tooltip, nil, table.concat(info, " / "),
        tooltip:GetStyle("worldMapTooltip"))
    end
  else
    informationTooltip:AddLine(zo_strformat("<<1>>", name), "ZoFontGameOutline", ZO_SELECTED_TEXT:UnpackRGB())
    ZO_Tooltip_AddDivider(informationTooltip)
    informationTooltip:AddLine(zo_strformat("(<<1>>) <<2>>", pinTag[SKYSHARDS_PINDATA_ZONEGUIDEINDEX], description), "", ZO_HIGHLIGHT_TEXT:UnpackRGB())
    if info[1] then
      informationTooltip:AddLine(table.concat(info, " / "), "", ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
    end
  end

end

local lastZone = ""
local skyshards
local function UpdateSkyshardsData(zone, subzone)
  skyshards = SkyShards_GetLocalData(zone, subzone)
  lastZone = GetMapTileTexture()
end

local function ShouldDisplaySkyshards()

  if SkyShards.db.immersiveMode == 1 then
    return true
  end

  local mapIndex = GetCurrentMapIndex()

  if not mapIndex and IsInImperialCity() then mapIndex = GetImperialCityMapIndex() end

  if not mapIndex then
    local measurements = GPS:GetCurrentMapMeasurement()
    if measurements then
      mapIndex = measurements.mapIndex  -- Sigh
    end
  end

  if mapIndex then
    local conditionData = SkyShards_GetImmersiveModeCondition(SkyShards.db.immersiveMode, mapIndex)
    if SkyShards.db.immersiveMode == 2 then
      -- MainQuest

      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif SkyShards.db.immersiveMode == 3 then
      -- Wayshrines

      if mapIndex ~= 14 then
        -- It is impossible to unlock all Wayshrines in Cyrodiil
        return conditionData
      end

    elseif SkyShards.db.immersiveMode == 4 then
      -- Exploration

      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    elseif SkyShards.db.immersiveMode == 5 then
      -- Zone Quests

      if type(conditionData) == "table" then
        for conditionIndex, achievementIndex in ipairs(conditionData) do
          local _, _, _, _, completed = GetAchievementInfo(achievementIndex)
          if not completed then
            return false
          end
        end
        return true
      else
        local _, _, _, _, completed = GetAchievementInfo(conditionData)
        return completed
      end

    end
  end

  return true

end

local function CompassCallback()
  if GetMapType() > MAPTYPE_ZONE then return end

  if not SkyShards.db.filters[SkyShards.PINS_COMPASS] then return end

  local shouldDisplay = ShouldDisplaySkyshards()

  if skyshards ~= nil then
    for _, pinData in ipairs(skyshards) do
      local zoneId = GetSkyshardAchievementZoneId(pinData[SKYSHARDS_PINDATA_ACHIEVEMENTID])
      local shardId = GetZoneSkyshardId(zoneId, pinData[SKYSHARDS_PINDATA_ZONEGUIDEINDEX])
      local shardStatus = GetSkyshardDiscoveryStatus(shardId)
      if shouldDisplay and (shardStatus == SKYSHARD_DISCOVERY_STATUS_DISCOVERED or shardStatus == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED) then
        COMPASS_PINS.pinManager:CreatePin(SkyShards.PINS_COMPASS, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
      end
    end
  end
end

local function MapCallbackCreatePins(pinType)

  if GetMapType() > MAPTYPE_ZONE then return end

  local shouldDisplay = ShouldDisplaySkyshards()

  local zone, subzone = LMP:GetZoneAndSubzone(false, true)
  if GetMapTileTexture() ~= lastZone then
    UpdateSkyshardsData(zone, subzone)
  end

  if skyshards ~= nil then
    for _, pinData in ipairs(skyshards) do
      local zoneId = GetSkyshardAchievementZoneId(pinData[SKYSHARDS_PINDATA_ACHIEVEMENTID])
      local shardId = GetZoneSkyshardId(zoneId, pinData[SKYSHARDS_PINDATA_ZONEGUIDEINDEX])
      local shardStatus = GetSkyshardDiscoveryStatus(shardId)
      if pinType == SkyShards.PINS_COLLECTED then
        if shardStatus == SKYSHARD_DISCOVERY_STATUS_ACQUIRED and LMP:IsEnabled(SkyShards.PINS_COLLECTED) then
          LMP:CreatePin(SkyShards.PINS_COLLECTED, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
        end
      end

      if pinType == SkyShards.PINS_UNKNOWN then
        if shouldDisplay and (shardStatus == SKYSHARD_DISCOVERY_STATUS_DISCOVERED or shardStatus == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED) and LMP:IsEnabled(SkyShards.PINS_UNKNOWN) then
          LMP:CreatePin(SkyShards.PINS_UNKNOWN, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
        end
      end

    end
  end
end

local function SetMainworldTint(pin)
  if pin.m_PinTag then
    if not pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] or pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_ON_CITY_MAP or pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_UNDER_GROUND then
      return SkyShards.mainworldColor
    end
  end

  return ZO_SELECTED_TEXT

end

-- Slash commands -------------------------------------------------------------
local function ShowMyPosition()

  if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
    CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
  end

  local x, y = GetMapPlayerPosition("player")

  local locX = ("%02.04f"):format(zo_round(x * 10000) / 10000)
  local locY = ("%02.04f"):format(zo_round(y * 10000) / 10000)

  MyPrint(zo_strformat("<<1>>: <<2>>\195\151<<3>> (<<4>>/<<5>>)", GetMapName(), locX, locY, LMP:GetZoneAndSubzone(false, true)))

end
SLASH_COMMANDS["/skypos"] = ShowMyPosition

local function GetNumFoundSkyShards()

  collectedSkyShards = 0
  --[[TODO why does this have to be 1 in order to have a total divisible by 3?
  Is it purely because of the quest Soul Shriven in Coldharbour?
  ]]--
  totalSkyShards = 1

  local ids = SkyShards_GetAchievementIDs()
  for achievementId in pairs(ids) do
    local zoneId = GetSkyshardAchievementZoneId(achievementId)
    local numSkyshards = GetNumSkyshardsInZone(zoneId)
    if numSkyshards then
      totalSkyShards = totalSkyShards + numSkyshards
      for skyshardIndex = 1, numSkyshards do
        local skyshardId = GetZoneSkyshardId(zoneId, skyshardIndex)
        local completed = GetSkyshardDiscoveryStatus(skyshardId)
        if completed == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
          collectedSkyShards = collectedSkyShards + 1
        end
      end
    end
  end

  -- "Soul Shriven in Coldharbour", 4296
  if HasCompletedQuest(4296) then collectedSkyShards = collectedSkyShards + 1 end
end

local function AlterSkyShardsIndicator()

  local function PreHookRefreshSkillPointInfo(self)
    -- keyboard function
    GetNumFoundSkyShards()
    local availablePoints = SKILL_POINT_ALLOCATION_MANAGER:GetAvailableSkillPoints()
    local pointsLabel = zo_strformat(SI_SKILLS_POINTS_TO_SPEND, availablePoints)
    if SSP then
      pointsLabel = string.format("%s|cffffff/%d|r", pointsLabel, SSP.GetTotalSpentPoints() + availablePoints)
    end
    self.availablePointsLabel:SetText(pointsLabel)

    if SkyShards.db.skillPanelDisplay > SKYSHARDS_SKILLPANEL_FORMAT_BASIC then
      if collectedSkyShards < totalSkyShards then
        if SkyShards.db.skillPanelDisplay == SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED then
          local newFormat = string.gsub(GetString(SI_SKILLS_SKY_SHARDS_COLLECTED), "\/3", "\/" .. totalSkyShards)
          self.skyShardsLabel:SetText(zo_strformat(newFormat, collectedSkyShards))
        elseif SkyShards.db.skillPanelDisplay == SKYSHARDS_SKILLPANEL_FORMAT_DETAILED then
          local newFormat = string.gsub(GetString(SI_SKILLS_SKY_SHARDS_COLLECTED), "\/3",
            "\/" .. totalSkyShards .. " (" .. GetNumSkyShards() .. "/3)")
          self.skyShardsLabel:SetText(zo_strformat(newFormat, collectedSkyShards))
        end
      else
        local newFormat = string.gsub(GetString(SI_SKILLS_SKY_SHARDS_COLLECTED), "\/3", "")
        self.skyShardsLabel:SetText(zo_strformat(newFormat, totalSkyShards))
      end
      return true
    end
  end

  local function PreHookRefreshPointsDisplay(self)
    -- gamepad function
    GetNumFoundSkyShards()
    local availablePoints = GetAvailableSkillPoints()
    self.headerData.data1Text = availablePoints

    if SkyShards.db.skillPanelDisplay == SKYSHARDS_SKILLPANEL_FORMAT_BASIC then
      local skyShards = GetNumSkyShards()
      self.headerData.data2Text = zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, skyShards,
        NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
    elseif SkyShards.db.skillPanelDisplay > SKYSHARDS_SKILLPANEL_FORMAT_BASIC then
      if collectedSkyShards < totalSkyShards then
        if SkyShards.db.skillPanelDisplay == SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED then
          self.headerData.data2Text = zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, collectedSkyShards,
            totalSkyShards)
        elseif SkyShards.db.skillPanelDisplay == SKYSHARDS_SKILLPANEL_FORMAT_DETAILED then
          local skyShards = GetNumSkyShards()
          self.headerData.data2Text = zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, collectedSkyShards,
            totalSkyShards) .. " (" .. zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, skyShards,
            NUM_PARTIAL_SKILL_POINTS_FOR_FULL) .. ")"
        end
      else
        self.headerData.data2Text = collectedSkyShards
      end
    end

    ZO_GamepadGenericHeader_RefreshData(self.header, self.headerData)
    return true

  end

  GetNumFoundSkyShards()
  ZO_PreHook(SKILLS_WINDOW, "RefreshSkillPointInfo", PreHookRefreshSkillPointInfo)
  ZO_PreHook(GAMEPAD_SKILLS, "RefreshPointsDisplay", PreHookRefreshPointsDisplay)

end

-- Event handlers -------------------------------------------------------------
local function OnSkyshardsUpdated(eventCode)
  LMP:RefreshPins(SkyShards.PINS_UNKNOWN)
  LMP:RefreshPins(SkyShards.PINS_COLLECTED)
  COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)
end

local function OnLoad(eventCode, addOnName)

  if addOnName == "SkyShards" then
    EVENT_MANAGER:UnregisterForEvent(SkyShards.name, EVENT_ADD_ON_LOADED)

    SkyShards.db = ZO_SavedVars:NewCharacterIdSettings("SkyS_SavedVariables", 4, nil, SkyShards.defaults)
    SkyShards.mainworldColor = ZO_ColorDef:New(SkyShards.db.mainworldSkyshards)

    --get pin layout from saved variables
    local pinTextureType = SkyShards.db.pinTexture.type
    local pinTextureLevel = SkyShards.db.pinTexture.level
    local pinTextureSize = SkyShards.db.pinTexture.size
    local compassMaxDistance = SkyShards.db.compassMaxDistance

    local pinLayout_unknown = { level = pinTextureLevel, texture = SkyShards.pinTextures.unknown[pinTextureType], size = pinTextureSize, tint = SetMainworldTint }
    local pinLayout_collected = { level = pinTextureLevel, texture = SkyShards.pinTextures.collected[pinTextureType], size = pinTextureSize, tint = SetMainworldTint }
    local pinLayout_compassunknown = {
      maxDistance = compassMaxDistance,
      texture = SkyShards.pinTextures.unknown[pinTextureType],
      sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
        if zo_abs(normalizedAngle) > 0.25 then
          pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
        else
          pin:SetDimensions(48, 48)
        end
      end,
      additionalLayout = {
        [CUSTOM_COMPASS_LAYOUT_UPDATE] = function(pin)
          if pin.pinTag then
            if not pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] or
              pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_ON_CITY_MAP or
              pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_UNDER_GROUND then
              local icon = pin:GetNamedChild("Background")
              icon:SetColor(SkyShards.mainworldColor:UnpackRGBA())
            end
          end
        end
      },
      mapPinTypeString = SkyShards.PINS_UNKNOWN,
      onToggleCallback = function(compassPinType, enabled)
        COMPASS_PINS:SetCompassPinEnabled(compassPinType, enabled)
        COMPASS_PINS:RefreshPins(compassPinType)
      end,
    }

    --initialize map pins
    LMP:AddPinType(SkyShards.PINS_UNKNOWN, function() MapCallbackCreatePins(SkyShards.PINS_UNKNOWN) end, nil, pinLayout_unknown, pinTooltipCreator)
    LMP:AddPinType(SkyShards.PINS_COLLECTED, function() MapCallbackCreatePins(SkyShards.PINS_COLLECTED) end, nil, pinLayout_collected, pinTooltipCreator)

    --add filter check boxex
    LMP:AddPinFilter(SkyShards.PINS_UNKNOWN, GetString(SKYS_FILTER_UNKNOWN), nil, SkyShards.db.filters)
    LMP:AddPinFilter(SkyShards.PINS_COLLECTED, GetString(SKYS_FILTER_COLLECTED), nil, SkyShards.db.filters)

    --add handler for the left click
    local clickHandler = {
      [1] = {
        name = GetString(SKYS_SET_WAYPOINT),
        gamepadName = GetString(SKYS_SET_WAYPOINT),
        show = function(pin) return true end,
        duplicates = function(pin1, pin2) return (pin1.m_PinTag[SKYSHARDS_PINDATA_ACHIEVEMENTID] == pin2.m_PinTag[SKYSHARDS_PINDATA_ACHIEVEMENTID] and pin1.m_PinTag[SKYSHARDS_PINDATA_ZONEGUIDEINDEX] == pin2.m_PinTag[SKYSHARDS_PINDATA_ZONEGUIDEINDEX]) end,
        callback = function(pin) PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, pin.normalizedX,
          pin.normalizedY) end,
      },
    }
    LMP:SetClickHandlers(SkyShards.PINS_UNKNOWN, clickHandler)
    LMP:SetClickHandlers(SkyShards.PINS_COLLECTED, clickHandler)

    --initialize compass pins
    COMPASS_PINS:AddCustomPin(SkyShards.PINS_COMPASS, function() CompassCallback() end, pinLayout_compassunknown, SkyShards.db.filters)
    COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)

    -- addon menu
    SkyShards:CreateSettingsMenu()

    -- Change SkyShard Display on Skills window
    AlterSkyShardsIndicator()

    RedirectTexture("EsoUI/Art/MapPins/skyshard_seen.dds", "/esoui/art/icons/heraldrycrests_misc_blank_01.dds")
    RedirectTexture("EsoUI/Art/Compass/skyshard_seen.dds", "/esoui/art/icons/heraldrycrests_misc_blank_01.dds")

    --events
    EVENT_MANAGER:RegisterForEvent(SkyShards.name, EVENT_SKYSHARDS_UPDATED, OnSkyshardsUpdated)
  end

end

EVENT_MANAGER:RegisterForEvent(SkyShards.name, EVENT_ADD_ON_LOADED, OnLoad)
