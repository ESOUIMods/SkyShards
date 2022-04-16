--[[
-------------------------------------------------------------------------------
-- SkyShards
-- Current maintainer: Sharlikran
-- Previous maintainer: AssemblerManiac
-- originally by Garkin, Ayantir
-------------------------------------------------------------------------------
This software is under : CreativeCommons CC BY-NC-SA 4.0
Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)

You are free to:

    Share - copy and redistribute the material in any medium or format
    Adapt - remix, transform, and build upon the material
    The licensor cannot revoke these freedoms as long as you follow the license terms.


Under the following terms:

    Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    NonCommercial - You may not use the material for commercial purposes.
    ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
    No additional restrictions - You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.


Please read full licence at :
http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
]]

--Libraries--------------------------------------------------------------------
local LAM = LibAddonMenu2
local LMP = LibMapPins
local GPS = LibGPS3

--Local constants -------------------------------------------------------------
local ADDON_NAME = "SkyShards"
local ADDON_VERSION = "10.40"
local ADDON_WEBSITE = "http://www.esoui.com/downloads/info128-SkyShards.html"
local PINS_UNKNOWN = "SkySMapPin_unknown"
local PINS_COLLECTED = "SkySMapPin_collected"
local PINS_COMPASS = "SkySCompassPin_unknown"
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

--Local variables -------------------------------------------------------------
local updatePins = {}
local updating = false
local db
local defaults = {      -- default settings for saved variables
  compassMaxDistance = 0.05,
  skillPanelDisplay = 2,
  pinTexture = {
    type = 1,
    size = 38,
    level = 40,
  },
  filters = {
    [PINS_COMPASS] = true,
    [PINS_UNKNOWN] = true,
    [PINS_COLLECTED] = false,
  },
  mainworldSkyshards = ZO_SELECTED_TEXT:ToHex(),
  immersiveMode = 1,
}

-- Local functions ------------------------------------------------------------
local function MyPrint(...)
  CHAT_ROUTER:AddSystemMessage(...)
end

-- Pins -----------------------------------------------------------------------
local pinTextures = {
  unknown = {
    [1] = "SkyShards/Icons/Skyshard-unknown.dds",
    [2] = "SkyShards/Icons/Skyshard-unknown-alternative.dds",
    [3] = "SkyShards/Icons/Skyshard-unknown-Esohead.dds",
    [4] = "SkyShards/Icons/Skyshard-unknown-Rushmik.dds",
    [5] = "SkyShards/Icons/Skyshard-unknown-Heidra.dds",
  },
  collected = {
    [1] = "SkyShards/Icons/Skyshard-collected.dds",
    [2] = "SkyShards/Icons/Skyshard-collected-alternative.dds",
    [3] = "SkyShards/Icons/Skyshard-collected-Esohead.dds",
    [4] = "SkyShards/Icons/Skyshard-collected-Rushmik.dds",
    [5] = "SkyShards/Icons/Skyshard-collected-Heidra.dds",
  },
}

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

local function CompassCallback()
  if GetMapType() <= MAPTYPE_ZONE and db.filters[PINS_COMPASS] then
    local zone, subzone = LMP:GetZoneAndSubzone(false, true)
    local skyshards = SkyShards_GetLocalData(zone, subzone)
    if skyshards ~= nil then
      for _, pinData in ipairs(skyshards) do
        local zoneId = GetSkyshardAchievementZoneId(pinData[SKYSHARDS_PINDATA_ACHIEVEMENTID])
        local shardId = GetZoneSkyshardId(zoneId, pinData[SKYSHARDS_PINDATA_ZONEGUIDEINDEX])
        local shardStatus = GetSkyshardDiscoveryStatus(shardId)
        if (shardStatus == SKYSHARD_DISCOVERY_STATUS_DISCOVERED or shardStatus == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED) then
          COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
        end
      end
    end
  end
end

local function ShouldDisplaySkyshards()

  if db.immersiveMode == 1 then
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
    local conditionData = SkyShards_GetImmersiveModeCondition(db.immersiveMode, mapIndex)
    if db.immersiveMode == 2 then
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

    elseif db.immersiveMode == 3 then
      -- Wayshrines

      if mapIndex ~= 14 then
        -- It is impossible to unlock all Wayshrines in Cyrodiil
        return conditionData
      end

    elseif db.immersiveMode == 4 then
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

    elseif db.immersiveMode == 5 then
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

local function CreatePins()

  local shouldDisplay = ShouldDisplaySkyshards()

  local zone, subzone = LMP:GetZoneAndSubzone(false, true)
  local skyshards = SkyShards_GetLocalData(zone, subzone)

  if skyshards ~= nil then
    for _, pinData in ipairs(skyshards) do
      local zoneId = GetSkyshardAchievementZoneId(pinData[SKYSHARDS_PINDATA_ACHIEVEMENTID])
      local shardId = GetZoneSkyshardId(zoneId, pinData[SKYSHARDS_PINDATA_ZONEGUIDEINDEX])
      local shardStatus = GetSkyshardDiscoveryStatus(shardId)
      if shardStatus == SKYSHARD_DISCOVERY_STATUS_ACQUIRED and updatePins[PINS_COLLECTED] and LMP:IsEnabled(PINS_COLLECTED) then
        LMP:CreatePin(PINS_COLLECTED, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
      elseif shouldDisplay and (shardStatus == SKYSHARD_DISCOVERY_STATUS_DISCOVERED or shardStatus == SKYSHARD_DISCOVERY_STATUS_UNDISCOVERED) then
        if updatePins[PINS_UNKNOWN] and LMP:IsEnabled(PINS_UNKNOWN) then
          LMP:CreatePin(PINS_UNKNOWN, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
        end
        if updatePins[PINS_COMPASS] and db.filters[PINS_COMPASS] then
          COMPASS_PINS.pinManager:CreatePin(PINS_COMPASS, pinData, pinData[SKYSHARDS_PINDATA_LOCX], pinData[SKYSHARDS_PINDATA_LOCY])
        end
      end
    end
  end

  updatePins = {}

  updating = false

end

local function QueueCreatePins(pinType)
  updatePins[pinType] = true

  if not updating then
    updating = true
    if IsPlayerActivated() then
      CreatePins()
    else
      EVENT_MANAGER:RegisterForEvent("SkyShards_PinUpdate", EVENT_PLAYER_ACTIVATED,
        function(event)
          EVENT_MANAGER:UnregisterForEvent("SkyShards_PinUpdate", event)
          CreatePins()
        end)
    end
  end
end

local function MapCallback_unknown()
  if not LMP:IsEnabled(PINS_UNKNOWN) or (GetMapType() > MAPTYPE_ZONE) then return end
  QueueCreatePins(PINS_UNKNOWN)
end

local function MapCallback_collected()
  if not LMP:IsEnabled(PINS_COLLECTED) or (GetMapType() > MAPTYPE_ZONE) then return end
  QueueCreatePins(PINS_COLLECTED)
end

local function CompassCallback()
  if not db.filters[PINS_COMPASS] or (GetMapType() > MAPTYPE_ZONE) then return end
  QueueCreatePins(PINS_COMPASS)
end

local function SetMainworldTint(pin)
  if pin.m_PinTag then
    if not pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] or pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_ON_CITY_MAP or pin.m_PinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_UNDER_GROUND then
      return MAINWORLD_SKYS
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

  MyPrint(zo_strformat("<<1>>: <<2>>\195\151<<3>> (<<4>>/<<5>>)", GetMapName(), locX, locY,
    LMP:GetZoneAndSubzone(false, true)))

end
SLASH_COMMANDS["/skypos"] = ShowMyPosition

-- Settings menu --------------------------------------------------------------
local function CreateSettingsMenu()

  local skillPanelChoices = {
    [1] = GetString(SKYS_SKILLS_OPTION1),
    [2] = GetString(SKYS_SKILLS_OPTION2),
    [3] = GetString(SKYS_SKILLS_OPTION3),
  }

  local immersiveChoices = {
    [1] = GetString(SKYS_IMMERSIVE_CHOICE1),
    [2] = GetString(SKYS_IMMERSIVE_CHOICE2),
    [3] = GetString(SKYS_IMMERSIVE_CHOICE3),
    [4] = GetString(SKYS_IMMERSIVE_CHOICE4),
    [5] = GetString(SKYS_IMMERSIVE_CHOICE5),
  }

  local pinTexturesList = {
    [1] = "Default icons (Garkin)",
    [2] = "Alternative icons (Garkin)",
    [3] = "Esohead's icons (Mitsarugi)",
    [4] = "Glowing icons (Rushmik)",
    [5] = "Realistic icons (Heidra)",
  }

  local panelData = {
    type = "panel",
    name = GetString(SKYS_TITLE),
    displayName = "|cFFFFB0" .. GetString(SKYS_TITLE) .. "|r",
    author = "Ayantir & Garkin",
    version = ADDON_VERSION,
    slashCommand = "/skyshards",
    registerForRefresh = true,
    registerForDefaults = true,
    website = ADDON_WEBSITE,
  }
  LAM:RegisterAddonPanel(ADDON_NAME, panelData)

  local CreateIcons, unknownIcon, collectedIcon
  CreateIcons = function(panel)
    if panel == SkyShards then
      unknownIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
      unknownIcon:SetAnchor(RIGHT, panel.controlsToRefresh[1].combobox, LEFT, -10, 0)
      unknownIcon:SetTexture(pinTextures.unknown[db.pinTexture.type])
      unknownIcon:SetDimensions(db.pinTexture.size, db.pinTexture.size)
      collectedIcon = WINDOW_MANAGER:CreateControl(nil, panel.controlsToRefresh[1], CT_TEXTURE)
      collectedIcon:SetAnchor(RIGHT, unknownIcon, LEFT, -5, 0)
      collectedIcon:SetTexture(pinTextures.collected[db.pinTexture.type])
      collectedIcon:SetDimensions(db.pinTexture.size, db.pinTexture.size)
      CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
    end
  end
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)

  local optionsTable = {
    {
      type = "dropdown",
      name = GetString(SKYS_PIN_TEXTURE),
      tooltip = GetString(SKYS_PIN_TEXTURE_DESC),
      choices = pinTexturesList,
      getFunc = function() return pinTexturesList[db.pinTexture.type] end,
      setFunc = function(selected)
        for index, name in ipairs(pinTexturesList) do
          if name == selected then
            db.pinTexture.type = index
            LMP:SetLayoutKey(PINS_UNKNOWN, "texture", pinTextures.unknown[index])
            LMP:SetLayoutKey(PINS_COLLECTED, "texture", pinTextures.collected[index])
            unknownIcon:SetTexture(pinTextures.unknown[index])
            collectedIcon:SetTexture(pinTextures.collected[index])
            LMP:RefreshPins(PINS_UNKNOWN)
            LMP:RefreshPins(PINS_COLLECTED)
            COMPASS_PINS.pinLayouts[PINS_COMPASS].texture = pinTextures.unknown[index]
            COMPASS_PINS:RefreshPins(PINS_COMPASS)
            break
          end
        end
      end,
      disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED]) end,
      default = pinTexturesList[defaults.pinTexture.type],
    },
    {
      type = "slider",
      name = GetString(SKYS_PIN_SIZE),
      tooltip = GetString(SKYS_PIN_SIZE_DESC),
      min = 20,
      max = 70,
      getFunc = function() return db.pinTexture.size end,
      setFunc = function(size)
        db.pinTexture.size = size
        unknownIcon:SetDimensions(size, size)
        collectedIcon:SetDimensions(size, size)
        LMP:SetLayoutKey(PINS_UNKNOWN, "size", size)
        LMP:SetLayoutKey(PINS_COLLECTED, "size", size)
        LMP:RefreshPins(PINS_UNKNOWN)
        LMP:RefreshPins(PINS_COLLECTED)
      end,
      disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED]) end,
      default = defaults.pinTexture.size
    },
    {
      type = "slider",
      name = GetString(SKYS_PIN_LAYER),
      tooltip = GetString(SKYS_PIN_LAYER_DESC),
      min = 10,
      max = 200,
      step = 5,
      getFunc = function() return db.pinTexture.level end,
      setFunc = function(level)
        db.pinTexture.level = level
        LMP:SetLayoutKey(PINS_UNKNOWN, "level", level)
        LMP:SetLayoutKey(PINS_COLLECTED, "level", level)
        LMP:RefreshPins(PINS_UNKNOWN)
        LMP:RefreshPins(PINS_COLLECTED)
      end,
      disabled = function() return not (db.filters[PINS_UNKNOWN] or db.filters[PINS_COLLECTED]) end,
      default = defaults.pinTexture.level,
    },
    {
      type = "checkbox",
      name = GetString(SKYS_UNKNOWN),
      tooltip = GetString(SKYS_UNKNOWN_DESC),
      getFunc = function() return db.filters[PINS_UNKNOWN] end,
      setFunc = function(state)
        db.filters[PINS_UNKNOWN] = state
        LMP:SetEnabled(PINS_UNKNOWN, state)
      end,
      default = defaults.filters[PINS_UNKNOWN],
    },
    {
      type = "checkbox",
      name = GetString(SKYS_COLLECTED),
      tooltip = GetString(SKYS_COLLECTED_DESC),
      getFunc = function() return db.filters[PINS_COLLECTED] end,
      setFunc = function(state)
        db.filters[PINS_COLLECTED] = state
        LMP:SetEnabled(PINS_COLLECTED, state)
      end,
      default = defaults.filters[PINS_COLLECTED]
    },
    {
      type = "checkbox",
      name = GetString(SKYS_COMPASS_UNKNOWN),
      tooltip = GetString(SKYS_COMPASS_UNKNOWN_DESC),
      getFunc = function() return db.filters[PINS_COMPASS] end,
      setFunc = function(state)
        db.filters[PINS_COMPASS] = state
        COMPASS_PINS:RefreshPins(PINS_COMPASS)
      end,
      default = defaults.filters[PINS_COMPASS],
    },
    {
      type = "slider",
      name = GetString(SKYS_COMPASS_DIST),
      tooltip = GetString(SKYS_COMPASS_DIST_DESC),
      min = 1,
      max = 100,
      getFunc = function() return db.compassMaxDistance * 1000 end,
      setFunc = function(maxDistance)
        db.compassMaxDistance = maxDistance / 1000
        COMPASS_PINS.pinLayouts[PINS_COMPASS].maxDistance = maxDistance / 1000
        COMPASS_PINS:RefreshPins(PINS_COMPASS)
      end,
      width = "full",
      disabled = function() return not db.filters[PINS_COMPASS] end,
      default = defaults.compassMaxDistance * 1000,
    },
    {
      type = "colorpicker",
      name = GetString(SKYS_MAINWORLD),
      tooltip = GetString(SKYS_MAINWORLD_DESC),
      getFunc = function() return MAINWORLD_SKYS:UnpackRGBA() end,
      setFunc = function(...)
        MAINWORLD_SKYS:SetRGBA(...)
        db.mainworldSkyshards = MAINWORLD_SKYS:ToHex()
        LMP:RefreshPins()
        COMPASS_PINS:RefreshPins(PINS_COMPASS)
      end,
      default = ZO_SELECTED_TEXT,
    },
    {
      type = "dropdown",
      name = GetString(SKYS_SKILLS),
      tooltip = GetString(SKYS_SKILLS_DESC),
      choices = skillPanelChoices,
      getFunc = function() return skillPanelChoices[db.skillPanelDisplay] end,
      setFunc = function(selected)
        for index, name in ipairs(skillPanelChoices) do
          if name == selected then
            db.skillPanelDisplay = index
            SKILLS_WINDOW:RefreshSkillPointInfo()
            break
          end
        end
      end,
      default = skillPanelChoices[defaults.skillPanelDisplay],
    },
    {
      type = "dropdown",
      name = GetString(SKYS_IMMERSIVE),
      tooltip = GetString(SKYS_IMMERSIVE_DESC),
      choices = immersiveChoices,
      getFunc = function() return immersiveChoices[db.immersiveMode] end,
      setFunc = function(selected)
        for index, name in ipairs(immersiveChoices) do
          if name == selected then
            db.immersiveMode = index
            break
          end
        end
      end,
      default = immersiveChoices[defaults.immersiveMode],
    },
  }
  LAM:RegisterOptionControls(ADDON_NAME, optionsTable)
end

local function GetNumFoundSkyShards()

  collectedSkyShards = 0
  totalSkyShards = 1

  local ids = SkyShards_GetAchievementIDs()
  for achievementId in pairs(ids) do
    local zoneId = GetSkyshardAchievementZoneId(achievementId)
    local numSkyshards = GetNumSkyshardsInZone(zoneId)
    if numSkyshards then
      totalSkyShards = totalSkyShards + numSkyshards
      for n = 1, numSkyshards do
        local skyshardId = GetZoneSkyshardId(zoneId, n)
        local completed = GetSkyshardDiscoveryStatus(skyshardId)
        if completed == SKYSHARD_DISCOVERY_STATUS_ACQUIRED then
          collectedSkyShards = collectedSkyShards + 1
        end
      end
    end
  end

    for i = 4290, 5000 do
    -- Get next completed quest. If it was the last, break loop
      id = GetNextCompletedQuestId(i)
      if id == nil then break end
      if id == 4296 then collectedSkyShards = collectedSkyShards + 1 end
    end
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

    if db.skillPanelDisplay > 1 then
      if collectedSkyShards < totalSkyShards then
        if db.skillPanelDisplay == 2 then
          local newFormat = string.gsub(GetString(SI_SKILLS_SKY_SHARDS_COLLECTED), "\/3", "\/" .. totalSkyShards)
          self.skyShardsLabel:SetText(zo_strformat(newFormat, collectedSkyShards))
        elseif db.skillPanelDisplay == 3 then
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

    if db.skillPanelDisplay == 1 then
      local skyShards = GetNumSkyShards()
      self.headerData.data2Text = zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, skyShards,
        NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
    elseif db.skillPanelDisplay > 1 then
      if collectedSkyShards < totalSkyShards then
        if db.skillPanelDisplay == 2 then
          self.headerData.data2Text = zo_strformat(SI_GAMEPAD_SKILLS_SKY_SHARDS_FOUND, collectedSkyShards,
            totalSkyShards)
        elseif db.skillPanelDisplay == 3 then
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
  LMP:RefreshPins(PINS_UNKNOWN)
  LMP:RefreshPins(PINS_COLLECTED)
  COMPASS_PINS:RefreshPins(PINS_COMPASS)
end

local function NamesToIDSavedVars()

  if not db.namesToIDSavedVars then

    local displayName = GetDisplayName()
    local name = GetUnitName("player")

    if SkyS_SavedVariables.Default[displayName][name] then
      db = SkyS_SavedVariables.Default[displayName][name]
      db.namesToIDSavedVars = true -- should not be necessary because data don't exist anymore in SkyS_SavedVariables.Default[displayName][name]
    end

  end

end

local GetSkyshardHintAchivementLookup = {
  -- Aldmeri 694
        ["Within sight of Mnem."] = {
          [1] = 0.574,
          [2] = 0.851,
          [3] = 694,
        },
        ["Ascending toward prophecy and dawn."] = {
          [1] = 0.413,
          [2] = 0.842,
          [3] = 694,
        },
        ["Helping establish a new town."] = {
          [1] = 0.311,
          [2] = 0.659,
          [3] = 694,
        },
        ["Tooth of Jone or Jode."] = {
          [1] = 0.629,
          [2] = 0.681,
          [3] = 694,
        },
        ["Ruined spire peering north to the Tower."] = {
          [1] = 0.482,
          [2] = 0.534,
          [3] = 694,
        },
        ["Hears hacking to the east."] = {
          [1] = 0.184,
          [2] = 0.458,
          [3] = 694,
        },
        ["Upon timbered fingers."] = {
          [1] = 0.259,
          [2] = 0.531,
          [3] = 694,
        },
        ["Ruin's crown between three castles."] = {
          [1] = 0.501,
          [2] = 0.761,
          [3] = 694,
        },
        ["Where archers of the Eight train."] = {
          [1] = 0.330,
          [2] = 0.770,
          [3] = 694,
        },
        ["Six-legged assassins crawl the cave."] = {
          [1] = 0.5377,
          [2] = 0.8100,
          [3] = 694,
        },
        ["The Black Dagger's prize."] = {
          [1] = 0.2893,
          [2] = 0.4848,
          [3] = 694,
        },
        ["Singing straw's song."] = {
          [1] = 0.3165,
          [2] = 0.5627,
          [3] = 694,
        },
        ["Walk the Shadowed Path."] = {
          [1] = 0.3628,
          [2] = 0.6982,
          [3] = 694,
        },
        ["At the end of a bumpy road."] = {
          [1] = 0.4548,
          [2] = 0.7252,
          [3] = 694,
        },
        ["Where bear and ogre burrow."] = {
          [1] = 0.2056,
          [2] = 0.5074,
          [3] = 694,
        },
  -- Daggerfall 693
        ["Approach the southern scroll."] = {
          [1] = 0.105,
          [2] = 0.267,
          [3] = 693,
        },
        ["Overlooking Ni-Mohk's falls."] = {
          [1] = 0.153,
          [2] = 0.152,
          [3] = 693,
        },
        ["Near liquid fire flowing."] = {
          [1] = 0.176,
          [2] = 0.371,
          [3] = 693,
        },
        ["Decorating a Nord's manor grounds."] = {
          [1] = 0.467,
          [2] = 0.172,
          [3] = 693,
        },
        ["Offering at the priory."] = {
          [1] = 0.210,
          [2] = 0.397,
          [3] = 693,
        },
        ["Atop a crumbling Empire."] = {
          [1] = 0.375,
          [2] = 0.330,
          [3] = 693,
        },
        ["Home of the goat-faced altar."] = {
          [1] = 0.271,
          [2] = 0.229,
          [3] = 693,
        },
        ["Search near the cliffs … cliffs … cliffs …."] = {
          [1] = 0.2945,
          [2] = 0.1286,
          [3] = 693,
        },
        ["Where a ruin-seeking Khajiit is denied."] = {
          [1] = 0.535,
          [2] = 0.224,
          [3] = 693,
        },
        ["Bandits' crowning achievement."] = {
          [1] = 0.4217,
          [2] = 0.1465,
          [3] = 693,
        },
        ["Amid reverberations of clattering bones."] = {
          [1] = 0.3547,
          [2] = 0.1348,
          [3] = 693,
        },
        ["Vampires prowl where Elves once lived."] = {
          [1] = 0.1544,
          [2] = 0.2411,
          [3] = 693,
        },
        ["In a cave of crimson treasures."] = {
          [1] = 0.5831,
          [2] = 0.1949,
          [3] = 693,
        },
        ["Surrounded by frozen fungus."] = {
          [1] = 0.5027,
          [2] = 0.2148,
          [3] = 693,
        },
        ["Under shroud and ground."] = {
          [1] = 0.3612,
          [2] = 0.2210,
          [3] = 693,
        },
  -- Ebonheart 692
        ["Near the scroll of royalty's secret syllable."] = {
          [1] = 0.8105,
          [2] = 0.1672,
          [3] = 692,
        },
        ["Rope ladder hangs south of Ghartok."] = {
          [1] = 0.8874,
          [2] = 0.3297,
          [3] = 692,
        },
        ["Keeping the crops alive."] = {
          [1] = 0.7023,
          [2] = 0.6259,
          [3] = 692,
        },
        ["Cradled in a ruined temple hall."] = {
          [1] = 0.7793,
          [2] = 0.3877,
          [3] = 692,
        },
        ["The Arvinas' pride."] = {
          [1] = 0.7238,
          [2] = 0.5086,
          [3] = 692,
        },
        ["Blue Road's trees fall just down the hill."] = {
          [1] = 0.6542,
          [2] = 0.3785,
          [3] = 692,
        },
        ["Where bound spirits hold vigil."] = {
          [1] = 0.8068,
          [2] = 0.3047,
          [3] = 692,
        },
        ["Soft wings spin choral garb."] = {
          [1] = 0.7796,
          [2] = 0.2086,
          [3] = 692,
        },
        ["Wedged well in Sedor."] = {
          [1] = 0.6789,
          [2] = 0.1857,
          [3] = 692,
        },
        ["Fractured by the Bloody Hand."] = {
          [1] = 0.6726,
          [2] = 0.5961,
          [3] = 692,
        },
        ["The monarch's buried secret."] = {
          [1] = 0.8074,
          [2] = 0.2506,
          [3] = 692,
        },
        ["Enjoy a good roll in the muck."] = {
          [1] = 0.7103,
          [2] = 0.4903,
          [3] = 692,
        },
        ["Nurtured by amphibious host."] = {
          [1] = 0.7211,
          [2] = 0.6949,
          [3] = 692,
        },
        ["Rushing water in the depths."] = {
          [1] = 0.7587,
          [2] = 0.3474,
          [3] = 692,
        },
        ["Facing the Faceless."] = {
          [1] = 0.8067,
          [2] = 0.4610,
          [3] = 692,
        },
  -- Mountain 748
        ["Where White Fall reaches for Aetherius."] = {
          [1] = 0.7525,
          [2] = 0.2966,
          [3] = 748,
        },
}

function SkyShards_BuildSkyShardCyrodiilData()
  --d("BuildSkyShardCyrodiilData")
  local zoneId = GetSkyshardAchievementZoneId(694)
  --d(zoneId)
  local numSkyshards = GetNumSkyshardsInZone(zoneId)
  --d(numSkyshards)
  for shardIndex = 1, numSkyshards do
    local shardId = GetZoneSkyshardId(zoneId, shardIndex)
    local loc_x, loc_y = GetNormalizedPositionForSkyshardId(shardId)
    local description = GetSkyshardHint(shardId)
    local dataPool = SkyShards_GetCyrodiilData()
    for index, data in pairs(dataPool) do
      if shardIndex == data[SKYSHARDS_PINDATA_ZONEGUIDEINDEX] then
        --d(string.format("Altering Data: %s for shardIndex: %s",index,shardIndex))
        local skyshardData = GetSkyshardHintAchivementLookup[description]
        --d(skyshardData)
        if skyshardData then
          SkyShards_SetCyrodiilData(skyshardData[1], skyshardData[2], skyshardData[3], index)
        end
      end
    end
  end
end

local function OnLoad(eventCode, addOnName)

  if addOnName == "SkyShards" then
    EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)

    db = ZO_SavedVars:NewCharacterIdSettings("SkyS_SavedVariables", 4, nil, defaults)
    NamesToIDSavedVars()

    MAINWORLD_SKYS = ZO_ColorDef:New(db.mainworldSkyshards)

    --get pin layout from saved variables
    local pinTextureType = db.pinTexture.type
    local pinTextureLevel = db.pinTexture.level
    local pinTextureSize = db.pinTexture.size
    local compassMaxDistance = db.compassMaxDistance

    local pinLayout_unknown = { level = pinTextureLevel, texture = pinTextures.unknown[pinTextureType], size = pinTextureSize, tint = SetMainworldTint }
    local pinLayout_collected = { level = pinTextureLevel, texture = pinTextures.collected[pinTextureType], size = pinTextureSize, tint = SetMainworldTint }
    local pinLayout_compassunknown = {
      maxDistance = compassMaxDistance,
      texture = pinTextures.unknown[pinTextureType],
      sizeCallback = function(pin, angle, normalizedAngle, normalizedDistance)
        if zo_abs(normalizedAngle) > 0.25 then
          pin:SetDimensions(54 - 24 * zo_abs(normalizedAngle), 54 - 24 * zo_abs(normalizedAngle))
        else
          pin:SetDimensions(48, 48)
        end
      end,
      additionalLayout = {
        function(pin)
          if pin.pinTag then
            if not pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] or pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_ON_CITY_MAP or pin.pinTag[SKYSHARDS_PINDATA_MOREINFO] == SKYSHARDS_PINDATA_UNDER_GROUND then
              local icon = pin:GetNamedChild("Background")
              icon:SetColor(MAINWORLD_SKYS:UnpackRGBA())
            end
          end
        end,
        function(pin)
          --
        end
      }
    }

    --initialize map pins
    LMP:AddPinType(PINS_UNKNOWN, MapCallback_unknown, nil, pinLayout_unknown, pinTooltipCreator)
    LMP:AddPinType(PINS_COLLECTED, MapCallback_collected, nil, pinLayout_collected, pinTooltipCreator)

    --add filter check boxex
    LMP:AddPinFilter(PINS_UNKNOWN, GetString(SKYS_FILTER_UNKNOWN), nil, db.filters)
    LMP:AddPinFilter(PINS_COLLECTED, GetString(SKYS_FILTER_COLLECTED), nil, db.filters)

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
    LMP:SetClickHandlers(PINS_UNKNOWN, clickHandler)
    LMP:SetClickHandlers(PINS_COLLECTED, clickHandler)

    --initialize compass pins
    COMPASS_PINS:AddCustomPin(PINS_COMPASS, CompassCallback, pinLayout_compassunknown)
    COMPASS_PINS:RefreshPins(PINS_COMPASS)

    -- addon menu
    CreateSettingsMenu()

    -- Change SkyShard Display on Skills window
    AlterSkyShardsIndicator()

    -- Build Cyrodiil Skyshard Data
    SkyShards_BuildSkyShardCyrodiilData()

    --events
    EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_SKYSHARDS_UPDATED, OnSkyshardsUpdated)
  end

end

EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnLoad)
