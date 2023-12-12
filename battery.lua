VERSION = "0.0.1"

local micro = import("micro")
local shell = import("micro/shell")
local config = import("micro/config")

function init()
  config.MakeCommand("battery", percentage, config.NoComplete)
  config.TryBindKey("F7", "lua:battery.percentage", false)
end

-- Runs command and filter one line that has what is in contains
function RunCommandAndGrep(input, contains)
  local ret, err = shell.RunCommand(input)
  if err ~= nil then
    micro.Log("Error while running " .. input)
  end
  
  local result = ""
  for s in ret:gmatch("[^\r\n]+") do
      if string.find(s, contains) then
        result = s
      end
  end
  return result
end

-- percentage print the battery percentage on the infobar as message.
-- The function emulate the next cli command
-- upower -i $(upower -e | grep BAT) | grep --color=never -E "percentage"
function percentage(bp)
  -- get devices and select the battery one
  local device, err = RunCommandAndGrep("upower -e", "BAT")
  if err ~= nil then
    micro.Log("Error while running upower")
  end

  -- query the device BATtery and filter the line with the percentage
  local batteryPercentage, err = RunCommandAndGrep("upower -i " .. device, "percentage")
  if err ~= nil then
    micro.Log("Error while running upower: " ..  err)
  end

  -- display Battery percentage: x%
	micro.InfoBar():Message("Battery" .. batteryPercentage)
end
