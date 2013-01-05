---------------------------------------------------------------------------
--
--    couth alsa volume library
--
--    This only works with ALSA (not OSS). You must have amixer on your path
--    for this to work.
--
--    Usage Examples:
--
--      -- Get the the volume for all alsa controls and return an indicator
--      couth.alsa:getVolume()
--
--      -- Get the the volume for all alsa controls and return an indicator,
--      -- highlighting the Master volume in green
--      couth.alsa:getVolume('Master')
--
--      -- Set the the volume for CONTROL to NEW_VALUE, and
--      -- return bar indicators that displays all volumes with 
--      -- the indicator for CONTROL highlighted.
--      -- 
--      -- NOTE: NEW_VALUE can be any string that "amixer" will
--      -- accept as an argument, e.g., 3dB-, 3dB+, etc.
--      couth.alsa:setVolume('localhost', NEW_VALUE)
--
--
--    TODO: my examples:
--
---------------------------------------------------------------------------

local M = {}

M.__volume_pattern = 'Playback.*%[(%d+)%%%]'
M.__mute_pattern = '%[(o[nf]+)%]'
M.__control_pattern = "^Simple mixer control '(%a+)'"

-- get all alsa volumes as a table:
function M:getVolumes()
  local fd = io.popen("amixer -c0 scontents")
  local volumes = fd:read("*all")
  fd:close()

  local n=1
  local ret = {}

  local controls = {}
  for i,v in pairs(couth.CONFIG.ALSA_CONTROLS) do controls[v]=1 end

  local m, ctrl, vol, mute
  for line in volumes:gmatch("[^\n]+") do 
    if couth.count_keys(controls) > 0 then
      _,_,m = line:find(self.__control_pattern)
      if m and controls[m] then 
        ctrl = m 
      else
        _,_,vol = line:find(self.__volume_pattern)
        if ctrl and vol and controls[ctrl] then
          ret[ctrl] = {vol = vol}
          _,_,mute=line:find(self.__mute_pattern) 
          if mute then ret[ctrl]['mute'] = mute end
          controls[ctrl], vol, mute, ctrl = nil
        end
      end
    end
  end
  return ret
end

function M:muteIndicator(isOrOff)
  if not isOrOff then return '   ' end
  if isOrOff == 'on' then
    return '[ ]'
  end
  -- off means the ctrl is mute
  return '[M]'
end

--
--  ctrlToHighlight: the name of an alsa control that we want to highlight in
--                   the output. If this is nil then no controls will be
--                   highlighted in the output. Use this to signify the
--                   control that was just modified -- i.e., if we are
--                   adjusting the Master volume then Master will be
--                   highlighted and others will not be. This helps give us
--                   a visual indicator of the volume control we are adjusting
--                   so we know if we accidentally hit the wrong key.
--
function M:getVolume(ctrlToHighlight)
  local ret = {}
  local vol, mute
  local volumes = self:getVolumes()
  local pad_width = couth.string.maxLen(couth.CONFIG.ALSA_CONTROLS)

  for _,ctrl in ipairs(couth.CONFIG.ALSA_CONTROLS) do
    if volumes[ctrl] then
      local prefix, suffix = '',''
      if ctrl == ctrlToHighlight then
        prefix,suffix = '<span color="yellow">',"</span>"
      end
      table.insert(ret, prefix .. couth.string.rpad(ctrl, pad_width) .. ': '
        .. self:muteIndicator(volumes[ctrl]['mute']) .. ' '
        .. couth.indicator.barIndicator(volumes[ctrl]['vol']) .. suffix)
    end
  end
  return table.concat(ret,"\n")
end

--
--  level can be "toggle" to toggle mute/unmute or any other string
--  that amixer can recognize 3dB+
--
function M:setVolume(ctrl, level)
  io.popen("amixer -c0 set " .. ctrl .. ' ' .. level):close()
  return self:getVolume(ctrl)
end

couth.alsa = M
