---------------------------------------------------------------------------
--
--    couth mpc/mpd volume indicator library. 
--
--    In order for this to work, mpc must be on your path, and mpd must be
--    running on the host (obviously)
--
--    Usage Examples:
--
--      -- Get the the volume from localhost and return an bar indicator
--      -- for display
--      couth.mpc:getVolume('localhost')
--
--      -- Set the the volume from localhost to NEW_VALUE, and
--      -- return a bar indicator that displays the new value.
--      -- NOTE: NEW_VALUE can be any string that "mpc volume" will
--      -- accept as an argument, e.g., 
--      --    "50" to set volume to 50%,
--      --    "+5" to increase the volume by 5%,
--      --    "-5" to decrease the volume by 5%,
--      couth.mpc:setVolume('localhost', NEW_VALUE)
--
--
--    I use this configuration in ~/.config/awesome/rc.lua to adjust the volume
--    on my media server "pizza":
--
--    -- mpc volume on pizza
--    awful.key({ modkey, "Shift" }, "XF86AudioLowerVolume",    function () couth.notifier:notify( couth.mpc:setVolume('pizza','-5')) end),
--    awful.key({ modkey, "Shift" }, "XF86AudioRaiseVolume",    function () couth.notifier:notify( couth.mpc:setVolume('pizza','+5')) end),
--    awful.key({ modkey, "Shift" }, "v",                       function () couth.notifier:notify( couth.mpc:getVolume('pizza') ) end) 
--
---------------------------------------------------------------------------
local M = {}
M.__volume_pattern = '^volume:%s*(%d+)%%'

function M:execMpcVolume(host, arg)
  arg = arg or ''
  local fd = io.popen('mpc -h ' .. host .. ' volume ' .. arg)
  local mpc_ret = fd:read("*all")
  fd:close()

  local ret
  for line in mpc_ret:gmatch("[^\n]+") do 
    local _,_,ret = line:find(self.__volume_pattern)
    if ret then return ret end
  end
  return '0'
end

function M:renderVolumeDisplay(host, volume )
  local prefix,suffix = '<span color="green">', "</span>"
  local label = host .. ' volume: '
  return prefix .. label .. couth.indicator.barIndicator(volume) .. suffix
end

-- get all alsa volumes as a table:
function M:getVolume(host)
  return self:renderVolumeDisplay(host, self:execMpcVolume(host) )
end

function M:setVolume(host, val)
  return self:renderVolumeDisplay(host, self:execMpcVolume(host, val) )
end

couth.mpc = M
