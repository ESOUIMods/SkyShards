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
SkyShards = SkyShards or {}
SkyShards.db = SkyShards.db or {}

SkyShards.name = "SkyShards"
SkyShards.version = "10.60"
SkyShards.website = "http://www.esoui.com/downloads/info128-SkyShards.html"

SkyShards.PINS_UNKNOWN = "SkySMapPin_unknown"
SkyShards.PINS_COLLECTED = "SkySMapPin_collected"
SkyShards.PINS_COMPASS = "SkySCompassPin_unknown"

local defaults = {
  compassMaxDistance = 0.05,
  skillPanelDisplay = 3, -- SKYSHARDS_SKILLPANEL_FORMAT_DETAILED
  pinTexture = {
    type = 1,
    size = 38,
    level = 80,
  },
  filters = {
    ["SkySCompassPin_unknown"] = true,
    ["SkySMapPin_unknown"] = true,
    ["SkySMapPin_collected"] = true,
  },
  mainworldSkyshards = ZO_SELECTED_TEXT:ToHex(),
  immersiveMode = 1,
}
SkyShards.defaults = defaults

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
SkyShards.pinTextures = pinTextures

SkyShards.mainworldColor = ZO_SELECTED_TEXT

-------------------------------------------------
----- Logger Function                       -----
-------------------------------------------------
SkyShards.show_log = true
if LibDebugLogger then
  SkyShards.logger = LibDebugLogger.Create(SkyShards.name)
end
local logger
local viewer
if DebugLogViewer then viewer = true else viewer = false end
if LibDebugLogger then logger = true else logger = false end

local function create_log(log_type, log_content)
  if not viewer and log_type == "Info" then
    CHAT_ROUTER:AddSystemMessage(log_content)
    return
  end
  if not SkyShards.show_log then return end
  if logger and log_type == "Debug" then
    SkyShards.logger:Debug(log_content)
  end
  if logger and log_type == "Info" then
    SkyShards.logger:Info(log_content)
  end
  if logger and log_type == "Verbose" then
    SkyShards.logger:Verbose(log_content)
  end
  if logger and log_type == "Warn" then
    SkyShards.logger:Warn(log_content)
  end
end

local function emit_message(log_type, text)
  if (text == "") then
    text = "[Empty String]"
  end
  create_log(log_type, text)
end

local function emit_table(log_type, t, indent, table_history)
  indent = indent or "."
  table_history = table_history or {}

  for k, v in pairs(t) do
    local vType = type(v)

    emit_message(log_type, indent .. "(" .. vType .. "): " .. tostring(k) .. " = " .. tostring(v))

    if (vType == "table") then
      if (table_history[v]) then
        emit_message(log_type, indent .. "Avoiding cycle on table...")
      else
        table_history[v] = true
        emit_table(log_type, v, indent .. "  ", table_history)
      end
    end
  end
end

function SkyShards:dm(log_type, ...)
  for i = 1, select("#", ...) do
    local value = select(i, ...)
    if (type(value) == "table") then
      emit_table(log_type, value)
    else
      emit_message(log_type, tostring(value))
    end
  end
end
