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
-- Creative Commons BY-NC-SA 4.0 (Ayantir, AssemblerManiac, Sharlikran, 2015–present):
--   You are free to share and adapt the material with attribution, but not for
--   commercial purposes. Derivatives must be licensed under the same terms.
--   Full terms at: https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
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
local LAM = LibAddonMenu2
local LMP = LibMapPins

-- Settings menu --------------------------------------------------------------
function SkyShards:CreateSettingsMenu()


local SKYSHARDS_SKILLPANEL_FORMAT_BASIC = 1
local SKYSHARDS_SKILLPANEL_FORMAT_DETAILED = 2
local SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED = 3

  local skillPanelChoices = {
    [SKYSHARDS_SKILLPANEL_FORMAT_BASIC] = GetString(SKYS_SKILLS_OPTION1),
    [SKYSHARDS_SKILLPANEL_FORMAT_DETAILED] = GetString(SKYS_SKILLS_OPTION2),
    [SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED] = GetString(SKYS_SKILLS_OPTION3),
  }

local skillPanelChoicesValues = {
    [1] = SKYSHARDS_SKILLPANEL_FORMAT_BASIC,
    [2] = SKYSHARDS_SKILLPANEL_FORMAT_DETAILED,
    [3] = SKYSHARDS_SKILLPANEL_FORMAT_ADVANCED,
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
    version = SkyShards.version,
    slashCommand = "/skyshards",
    registerForRefresh = true,
    registerForDefaults = false,
    website = SkyShards.website,
  }
  local settingsPanel = LAM:RegisterAddonPanel("SkyShards_OptionsPanel", panelData)

  local unknownIcon, collectedIcon
  local function CreateAllIconPreviews()
    -- Unknown shard icon
    unknownIcon = WINDOW_MANAGER:CreateControl(nil, previewSkyshardPinTexture, CT_TEXTURE)
    unknownIcon:SetAnchor(RIGHT, previewSkyshardPinTexture.dropdown:GetControl(), LEFT, -40, 0)
    unknownIcon:SetTexture(SkyShards.pinTextures.unknown[SkyShards.db.pinTexture.type])
    unknownIcon:SetDimensions(SkyShards.db.pinTexture.size, SkyShards.db.pinTexture.size)

    -- Collected shard icon
    collectedIcon = WINDOW_MANAGER:CreateControl(nil, previewSkyshardPinTexture, CT_TEXTURE)
    collectedIcon:SetAnchor(RIGHT, previewSkyshardPinTexture.dropdown:GetControl(), LEFT, -5, 0)
    collectedIcon:SetTexture(SkyShards.pinTextures.collected[SkyShards.db.pinTexture.type])
    collectedIcon:SetDimensions(SkyShards.db.pinTexture.size, SkyShards.db.pinTexture.size)
  end

  local function CreateIcons(panel)
    if panel == settingsPanel then
      -- Assuming `settingsPanel` is assigned during panel registration
      CreateAllIconPreviews()
      CALLBACK_MANAGER:UnregisterCallback("LAM-PanelControlsCreated", CreateIcons)
    end
  end
  CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", CreateIcons)

  local optionsTable = {
    {
      type = "dropdown",
      name = GetString(SKYS_PIN_TEXTURE),
      tooltip = GetString(SKYS_PIN_TEXTURE_DESC),
      reference = "previewSkyshardPinTexture",
      choices = pinTexturesList,
      getFunc = function() return pinTexturesList[SkyShards.db.pinTexture.type] end,
      setFunc = function(selected)
        for index, name in ipairs(pinTexturesList) do
          if name == selected then
            SkyShards.db.pinTexture.type = index
            LMP:SetLayoutKey(SkyShards.PINS_UNKNOWN, "texture", SkyShards.pinTextures.unknown[index])
            LMP:SetLayoutKey(SkyShards.PINS_COLLECTED, "texture", SkyShards.pinTextures.collected[index])
            unknownIcon:SetTexture(SkyShards.pinTextures.unknown[index])
            collectedIcon:SetTexture(SkyShards.pinTextures.collected[index])
            LMP:RefreshPins(SkyShards.PINS_UNKNOWN)
            LMP:RefreshPins(SkyShards.PINS_COLLECTED)
            COMPASS_PINS.pinLayouts[SkyShards.PINS_COMPASS].texture = SkyShards.pinTextures.unknown[index]
            COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)
            break
          end
        end
      end,
      disabled = function() return not (SkyShards.db.filters[SkyShards.PINS_UNKNOWN] or SkyShards.db.filters[SkyShards.PINS_COLLECTED]) end,
      default = pinTexturesList[SkyShards.defaults.pinTexture.type],
    },
    {
      type = "slider",
      name = GetString(SKYS_PIN_SIZE),
      tooltip = GetString(SKYS_PIN_SIZE_DESC),
      min = 20,
      max = 70,
      getFunc = function() return SkyShards.db.pinTexture.size end,
      setFunc = function(size)
        SkyShards.db.pinTexture.size = size
        unknownIcon:SetDimensions(size, size)
        collectedIcon:SetDimensions(size, size)
        LMP:SetLayoutKey(SkyShards.PINS_UNKNOWN, "size", size)
        LMP:SetLayoutKey(SkyShards.PINS_COLLECTED, "size", size)
        LMP:RefreshPins(SkyShards.PINS_UNKNOWN)
        LMP:RefreshPins(SkyShards.PINS_COLLECTED)
      end,
      disabled = function() return not (SkyShards.db.filters[SkyShards.PINS_UNKNOWN] or SkyShards.db.filters[SkyShards.PINS_COLLECTED]) end,
      default = SkyShards.defaults.pinTexture.size
    },
    {
      type = "slider",
      name = GetString(SKYS_PIN_LAYER),
      tooltip = GetString(SKYS_PIN_LAYER_DESC),
      min = 10,
      max = 200,
      step = 5,
      getFunc = function() return SkyShards.db.pinTexture.level end,
      setFunc = function(level)
        SkyShards.db.pinTexture.level = level
        LMP:SetLayoutKey(SkyShards.PINS_UNKNOWN, "level", level)
        LMP:SetLayoutKey(SkyShards.PINS_COLLECTED, "level", level)
        LMP:RefreshPins(SkyShards.PINS_UNKNOWN)
        LMP:RefreshPins(SkyShards.PINS_COLLECTED)
      end,
      disabled = function() return not (SkyShards.db.filters[SkyShards.PINS_UNKNOWN] or SkyShards.db.filters[SkyShards.PINS_COLLECTED]) end,
      default = SkyShards.defaults.pinTexture.level,
    },
    {
      type = "checkbox",
      name = GetString(SKYS_UNKNOWN),
      tooltip = GetString(SKYS_UNKNOWN_DESC),
      getFunc = function() return SkyShards.db.filters[SkyShards.PINS_UNKNOWN] end,
      setFunc = function(state)
        SkyShards.db.filters[SkyShards.PINS_UNKNOWN] = state
        LMP:SetEnabled(SkyShards.PINS_UNKNOWN, state)
      end,
      default = SkyShards.defaults.filters[SkyShards.PINS_UNKNOWN],
    },
    {
      type = "checkbox",
      name = GetString(SKYS_COLLECTED),
      tooltip = GetString(SKYS_COLLECTED_DESC),
      getFunc = function() return SkyShards.db.filters[SkyShards.PINS_COLLECTED] end,
      setFunc = function(state)
        SkyShards.db.filters[SkyShards.PINS_COLLECTED] = state
        LMP:SetEnabled(SkyShards.PINS_COLLECTED, state)
      end,
      default = SkyShards.defaults.filters[SkyShards.PINS_COLLECTED]
    },
    {
      type = "checkbox",
      name = GetString(SKYS_COMPASS_UNKNOWN),
      tooltip = GetString(SKYS_COMPASS_UNKNOWN_DESC),
      getFunc = function() return SkyShards.db.filters[SkyShards.PINS_COMPASS] end,
      setFunc = function(state)
        SkyShards.db.filters[SkyShards.PINS_COMPASS] = state
        COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)
      end,
      default = SkyShards.defaults.filters[SkyShards.PINS_COMPASS],
    },
    {
      type = "slider",
      name = GetString(SKYS_COMPASS_DIST),
      tooltip = GetString(SKYS_COMPASS_DIST_DESC),
      min = 1,
      max = 100,
      getFunc = function() return SkyShards.db.compassMaxDistance * 1000 end,
      setFunc = function(maxDistance)
        SkyShards.db.compassMaxDistance = maxDistance / 1000
        COMPASS_PINS.pinLayouts[SkyShards.PINS_COMPASS].maxDistance = maxDistance / 1000
        COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)
      end,
      width = "full",
      disabled = function() return not SkyShards.db.filters[SkyShards.PINS_COMPASS] end,
      default = SkyShards.defaults.compassMaxDistance * 1000,
    },
    {
      type = "colorpicker",
      name = GetString(SKYS_MAINWORLD),
      tooltip = GetString(SKYS_MAINWORLD_DESC),
      getFunc = function() return SkyShards.mainworldColor:UnpackRGBA() end,
      setFunc = function(...)
        SkyShards.mainworldColor:SetRGBA(...)
        SkyShards.db.mainworldSkyshards = SkyShards.mainworldColor:ToHex()
        LMP:RefreshPins()
        COMPASS_PINS:RefreshPins(SkyShards.PINS_COMPASS)
      end,
      default = ZO_SELECTED_TEXT,
    },
    {
      type = "dropdown",
      name = GetString(SKYS_SKILLS),
      tooltip = GetString(SKYS_SKILLS_DESC),
      choices = skillPanelChoices,
      choicesValues = skillPanelChoicesValues,
      getFunc = function() return SkyShards.db.skillPanelDisplay end,
      setFunc = function(selected)
        SkyShards.db.skillPanelDisplay = selected
        SKILLS_WINDOW:RefreshSkillPointInfo()
      end,
      default = skillPanelChoices[SkyShards.defaults.skillPanelDisplay],
    },
    {
      type = "dropdown",
      name = GetString(SKYS_IMMERSIVE),
      tooltip = GetString(SKYS_IMMERSIVE_DESC),
      choices = immersiveChoices,
      getFunc = function() return immersiveChoices[SkyShards.db.immersiveMode] end,
      setFunc = function(selected)
        for index, name in ipairs(immersiveChoices) do
          if name == selected then
            SkyShards.db.immersiveMode = index
            break
          end
        end
      end,
      default = immersiveChoices[SkyShards.defaults.immersiveMode],
    },
  }
  LAM:RegisterOptionControls("SkyShards_OptionsPanel", optionsTable)
end