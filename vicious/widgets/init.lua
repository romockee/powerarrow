---------------------------------------------------
-- Vicious widgets for the awesome window manager
---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
---------------------------------------------------

-- {{{ Setup environment
local setmetatable = setmetatable
local wrequire = require("vicious.helpers").wrequire

require("vicious.widgets.sensors")

-- Vicious: widgets for the awesome window manager
module("vicious.widgets")
-- }}}

-- Load modules at runtime as needed
setmetatable(_M, { __index = wrequire })
