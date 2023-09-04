SkyShards = {}
local ADDON_NAME = "SkyShards"
SkyShards.name = ADDON_NAME

-------------------------------------------------
----- Logger Function                       -----
-------------------------------------------------
SkyShards.show_log = false
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
