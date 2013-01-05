---------------------------------------------------------------------------
--
--    couth.lua   -- shared libaries for the couth awesomewm library
--
--    @author Greg Orlowski
--    @copyright 2011 Greg Orlowski
--
--  
--
---------------------------------------------------------------------------

require 'io'

if not couth then couth = {} end
--
--  This is the default configuration for couth modules. 
--  Modify this table to change the defaults.
--
if not couth.CONFIG then 
  couth.CONFIG = {

		-- The width of your volume indicators (the max number of | characters to
		-- display)
    INDICATOR_MAX_BARS = 20,

    -- these are the alsa controls that can be controlled or displayed
    -- by couth. To get a list of possible values, execute this in a shell:
    --
    --    amixer scontrols |sed -e "s/.* '//" -e "s/'.*//"
    --
    ALSA_CONTROLS = {
      'Master',
      'PCM',
    },

		-- The font to use for notifications. You should use a mono-space font so
		-- the columns are evenly aligned.
    NOTIFIER_FONT = 'fixed 12',
    NOTIFIER_POSITION = 'top_right',
    NOTIFIER_TIMEOUT = 1,

  } 
end

--
--  general functions
--
function couth.count_keys(t)
  local n=0
  for _,_ in pairs(t) do n=n+1 end
  return n
end


--
--  file path functions (like python os.path)
--
if not couth['path'] then couth.path = {} end
function couth.path.file_exists(fileName)
  doesExist = false
  f = io.open(fileName, 'r')
  if f then
    doesExist = true
    f:close()
  end
  return doesExist
end

--
--  string functions
--
if not couth['string'] then couth.string = {} end
function couth.string.maxLen(t)
  local ret=0, l
  for _,v in pairs(t) do
    if v and type(v)=='string' then
      l = v:len()
      if l>ret then ret=l end
    end
  end
  return ret
end

function couth.string.rpad(str, width)
  return str .. string.rep(' ', width - str:len())
end

--
--  indicator functions
--
if not couth['indicator'] then couth.indicator = {} end
function couth.indicator.barIndicator(prct)
  local maxBars = couth.CONFIG.INDICATOR_MAX_BARS
  local num_bars = math.floor(maxBars * (prct / 100.0))
  return '[' .. couth.string.rpad(string.rep('|', num_bars), maxBars) .. ']'
end

--
--  notifier
--
if not couth['notifier'] then couth.notifier = {id=nil} end
function couth.notifier:notify(msg)
  self.id = naughty.notify({
    text = msg,
    font = couth.CONFIG.NOTIFIER_FONT,
    position = couth.CONFIG.NOTIFIER_POSITION,
    timeout = couth.CONFIG.NOTIFIER_TIMEOUT,
    replaces_id = self.id
  }).id
end

