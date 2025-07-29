SkyShards = SkyShards or {}
SkyShards.db = SkyShards.db or {}

SkyShards.name = "SkyShards"
SkyShards.version = "10.58"
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
    level = 40,
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
d("[Init] SkyShards.defaults.pinTexture = " .. tostring(SkyShards.defaults and SkyShards.defaults.pinTexture))

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