local awful = require("awful")
local naughty = require("naughty")
local helpers =require("blingbling.helpers")
local string = require("string")
local io = require("io")
local os = require("os")
local setmetatable = setmetatable
local tonumber = tonumber
local ipairs = ipairs
local pairs =pairs
local math = math
local type=type
local cairo = require("oocairo")
local capi = { image = image, widget = widget, timer =timer }
local layout = require("awful.widget.layout")

---Net widget
module("blingbling.net")

---Set the interface we monitor:
--mynet:set_interface(string) --> "eth0"
--@name set_interface
--@param graph the net graph

---Fill all the widget (width * height) with this color (default is transparent ) 
--mynet:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the top and bottom margin for the filed background and the graph
--mynet:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the net graph
--@param margin an integer for top and bottom margin

--Define the left and right margin for the filed background and the graph
--mynet:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the net graph
--@param margin an integer for left and right margin

---Set the color of the graph (arrows) background
--mynet:set_background_graph_color(string) -->"#rrggbbaa"
--@name set_background_graph_color
--@class function
--@param graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph (arrows) color
--mynet:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the graph (arrows) outline
--mynet:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Display upload and download values
--mynet:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the net graph
--@param boolean true or false (default is false)

--Define the color of the text
--mynet:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--mynet:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the net graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--mynet:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the net graph
--@param size the font size

local data = setmetatable({}, { __mode = "k" })

local properties = { "interface", "width", "height", "v_margin", "h_margin", "background_color", "filled", "filled_color", "background_graph_color","graph_color", "graph_line_color","show_text", "text_color", "background_text_color" ,"label", "font_size","horizontal"}

local function update(n_graph)
  
  local interface=""
  if data[n_graph].interface == nil then
    data[n_graph].interface = "eth0"
  end
  interface = data[n_graph].interface 
  local v_margin = 2
  if data[n_graph].v_margin and data[n_graph].v_margin <= data[n_graph].height/4 then 
    v_margin = data[n_graph].v_margin 
  end
  local h_margin = 0
  if data[n_graph].h_margin and data[n_graph].h_margin <= data[n_graph].width / 3 then 
    h_margin = data[n_graph].h_margin 
  end
  
  if data[n_graph].show_text then
    --search the good width to display all text and graph and modify the widget width if necessary
    local n_graph_surface=cairo.image_surface_create("argb32",data[n_graph].width, data[n_graph].height)
    local n_graph_context = cairo.context_create(n_graph_surface)
    if data[n_graph].font_size then
      n_graph_context:set_font_size(data[n_graph].font_size)
    else
      n_graph_context:set_font_size(9)
    end
    --Adapt widget width with max lenght text
    local text_reference="1.00mb"
    local ext=n_graph_context:text_extents(text_reference)
    local text_width=ext.width +1 
    local arrow_width = 6 
    local arrows_separator = 2
    local total_width = (2* text_width) +(2*arrow_width) +(2 * ext.x_bearing)+ arrows_separator + (2*h_margin) 
    --helpers.dbg({data[n_graph].width,total_width}) 
    data[n_graph].width = total_width
  else
    local arrow_width = 8
    local arrows_separator = 2
    data[n_graph].width = (arrow_width * 2) + arrows_separator + (2*h_margin)
  end
  
  n_graph_surface= nil
  local n_graph_surface=cairo.image_surface_create("argb32",data[n_graph].width, data[n_graph].height)
  local n_graph_context = cairo.context_create(n_graph_surface)
  

  --Generate Background (background widget)
  if data[n_graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[n_graph].background_color)
    n_graph_context:set_source_rgba(r,g,b,a)
    n_graph_context:paint()
  end
  
  --Draw nothing or filled ( graph background)
  if data[n_graph].filled  == true then
    --fill the graph background
    n_graph_context:rectangle(h_margin,v_margin, data[n_graph].width - (2*h_margin), data[n_graph].height - (2* v_margin))
    if data[n_graph].filled_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[n_graph].filled_color)
          n_graph_context:set_source_rgba(r, g, b,a)
    else
          n_graph_context:set_source_rgba(0, 0, 0,0.5)
    end
    n_graph_context:fill()
  end

--Prepare the Text  
  local unit = { "b", "kb","mb","gb"}
  local unit_range = { 1, 1024, 1024^2, 1024^3 }
  local down_value
  local down_unit
  local up_value
  local up_unit
  
  down_value=0
  down_unit="b"  
  
  up_value=0
  up_unit="b"

  if data[n_graph][interface.."_down"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface.."_down"] >= v then
        down_value=data[n_graph][interface.."_down"]/v
        down_unit=unit[i]
      end
    end
  end
  if data[n_graph][interface.."_up"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface .."_up"] >= v then
        up_value=data[n_graph][interface.."_up"]/v
        up_unit=unit[i]
      end
    end
  end
--we format the value
  if  down_value >=0 and down_value <10 then 
    down_text=string.format("%.2f",down_value)..down_unit
  end
  if down_value >= 10 and down_value < 100 then
     down_text=string.format("%.1f",down_value)..down_unit
  end
  if down_value >= 100 then
     down_text=string.format("%d",math.ceil(down_value))..down_unit
  end
  
  if data[n_graph][interface.."_up"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface.."_up"] >= v then
        up_value=data[n_graph][interface.."_up"]/v
        up_unit=unit[i]
      end
    end
  end
  --we format the value
  if  up_value >=0 and up_value <10 then 
    up_text=string.format("%.2f",up_value)..up_unit
  end
  if up_value >= 10 and up_value < 100 then
     up_text=string.format("%.1f",up_value)..up_unit
  end
  if up_value >= 100 then
     uptext=string.format("%d",math.ceil(up_value))..up_unit
  end

if data[n_graph].background_graph_color == nil then
  data[n_graph].background_graph_color="#00000077"
end
if data[n_graph].graph_color == nil then
  data[n_graph].graph_color="#7fb21946"--46"
end
if data[n_graph].graph_line_color == nil then
  data[n_graph].graph_line_color="#7fb219"
end

--Drawn up arrow 
  helpers.draw_up_down_arrows(
      n_graph_context,
      math.floor(data[n_graph].width/2 -1),
      data[n_graph].height - v_margin,
      v_margin, 
      up_value, 
      data[n_graph].background_graph_color, 
      data[n_graph].graph_color,
      data[n_graph].graph_line_color , 
      true)
  --Drawn down arrow
  helpers.draw_up_down_arrows(
      n_graph_context,
      math.floor(data[n_graph].width/2)+1,
      v_margin,
      data[n_graph].height - v_margin,
      down_value,
      data[n_graph].background_graph_color, 
      data[n_graph].graph_color,
      data[n_graph].graph_line_color , 
      false)
  
  if data[n_graph][interface.."_state"] ~= "up" or data[n_graph][interface.."_carrier"] ~= "1" then
     n_graph_context:move_to(data[n_graph].width*2/5, v_margin)
     n_graph_context:line_to(data[n_graph].width*3/5,data[n_graph].height - v_margin)
     n_graph_context:move_to(data[n_graph].width *4/7, 2*v_margin)
     n_graph_context:line_to(data[n_graph].width*3/7,data[n_graph].height - 2*v_margin)
     n_graph_context:set_source_rgb(1,0,0)
     n_graph_context:set_line_width(1)
     n_graph_context:stroke()
  end

  if data[n_graph].show_text == true then
  --Draw Text and it's background
    if data[n_graph].font_size == nil then
      data[n_graph].font_size = 9
    end
    n_graph_context:set_font_size(data[n_graph].font_size)
    
    if data[n_graph].background_text_color == nil then
     data[n_graph].background_text_color = "#000000dd" 
    end
    if data[n_graph].text_color == nil then
     data[n_graph].text_color = "#ffffffff" 
    end    
    helpers.draw_text_and_background(n_graph_context, 
                                        down_text, 
                                        data[n_graph].width -h_margin, 
                                        v_margin , 
                                        data[n_graph].background_text_color, 
                                        data[n_graph].text_color,
                                        false,
                                        false,
                                        true,
                                        true)
    
    helpers.draw_text_and_background(n_graph_context, 
                                        up_text, 
                                        h_margin, 
                                        data[n_graph].height -v_margin , 
                                        data[n_graph].background_text_color, 
                                        data[n_graph].text_color,
                                        false,
                                        false,
                                        false,
                                        false)
    
end
    n_graph.widget.image = capi.image.argb32(data[n_graph].width, data[n_graph].height, n_graph_surface:get_data())

end

local function get_net_infos(n_graph)
  -- Variable definitions
  for line in io.lines("/proc/net/dev") do
    local device = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
    if device ~= nil then
    -- Received bytes, first value after the name
      local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
    -- Transmited bytes, 7 fields from end of the line
      local send = tonumber(string.match(line,
      "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))
      --check if interface is up or down
      local state
      for line in io.lines("/sys/class/net/"..string.gsub(device,"%s","").."/operstate") do
        state = line
      end
      data[n_graph][device.."_state"]=state
      --check if wire is connected
      local carrier
      if data[n_graph][device.."_state"] == "up" then
        for line in io.lines("/sys/class/net/"..string.gsub(device,"%s","").."/carrier") do
          carrier = line
        end
        data[n_graph][device.."_carrier"]=carrier
      else
        data[n_graph][device.."_carrier"]="0"
      end
      
      local now =os.time()
        if data[n_graph][device.."_down"] == nil or data[n_graph][device.."_up"] == nil then
            data[n_graph][device.."_down"] = 0
            data[n_graph][device.."_up"] = 0
        else 
          local interval = now - data[n_graph][device.."_time"]
          if interval <= 0 then interval =1 end

          local down = (recv -data[n_graph][device.."_last_recv"]) / interval
          local up = (send - data[n_graph][device.."_last_send"]) / interval
            data[n_graph][device.."_down" ] = down
            data[n_graph][device.."_up"] = up
        end

        data[n_graph][device.."_time"] = now

        data[n_graph][device.."_last_recv"] = recv
        data[n_graph][device.."_last_send"] = send
      end
  end
end

local function update_net(n_graph)
if not n_graph then return end
  data[n_graph].timer_update = capi.timer({timeout = 2})
  data[n_graph].timer_update:add_signal("timeout", function()
   get_net_infos(n_graph);
     update(n_graph)
     end)
  data[n_graph].timer_update:start()
end

--- Set the graph height.
-- @param n_graph The net graph.
-- @param height The height to set.
function set_height(n_graph, height)
    if height >= 5 then
        data[n_graph].height = height
        update(n_graph)
    end
    return n_graph
end

function set_width(n_graph, width)
    if width >= 5 then
        data[n_graph].width = width
        update(n_graph)
    end
    return n_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(n_graph, value)
            data[n_graph][prop] = value
            update(n_graph)
            return n_graph
        end
    end
end

local function hide_ippopup_infos(n_graph)
  if data[n_graph].ippopup ~= nil then
    naughty.destroy(data[n_graph].ippopup)
    data[n_graph].ippopup = nil
  end
end

local function show_ippopup_infos(n_graph)
  local ip_addr
  local gateway
  local all_infos=awful.util.pread("ip route show")
  local interface = data[n_graph].interface
  if data[n_graph][interface.."_state"] == "up" then
    if data[n_graph][interface.."_carrier"] == "1" then --get local ip configuration
      ip_addr=string.match(string.match(all_infos,"%ssrc%s[%d]+%.[d%]+%.[%d]+%.[%d]+"), "[%d]+%.[d%]+%.[%d]+%.[%d]+")
      --get gateway
      gateway=string.match(string.match(all_infos,"default%svia%s[%d]+%.[d%]+%.[%d]+%.[%d]+"), "[%d]+%.[d%]+%.[%d]+%.[%d]+")
      --get external ip configuration
      local ext_ip = awful.util.pread("curl --silent --connect-timeout 3 -S http://automation.whatismyip.com/n09230945.asp 2>&1")
      --if time out then no external ip
      if string.match(ext_ip,"timed%sout%!") then
        data[n_graph].ext_ip = "n/a" 
      else
        data[n_graph].ext_ip = ext_ip
      end

      --get tor external configuration
      local tor_ext_ip
      --we check that the tor address have not been checked or that the elapsed time from the last request is not < 300 sec. whereas whatsmyip block the request
      if (data[n_graph].tor_ext_ip_timer == nil or data[n_graph].tor_ext_ip_timer + 300 < os.time()) and data[n_graph].ext_ip ~= "n/a" then
        if awful.util.pread("pgrep tor") ~= "" then
          tor_ext_ip = awful.util.pread("curl --silent -S -x socks4a://localhost:9050 http://automation.whatismyip.com/n09230945.asp") 
        else
          tor_ext_ip = "No tor"
        end
        data[n_graph].tor_ext_ip=tor_ext_ip
        data[n_graph].tor_ext_ip_timer=os.time()
      --if local ip is ok but not the external ip, then we can't get external tor ip
      elseif data[n_graph].ext_ip == "n/a" then
        tor_ext_ip="n/a"
      --we get the last value of tor_ext_ip of the last recent check.
      else
        tor_ext_ip= data[n_graph].tor_ext_ip
      end
      local separator ="\n|\n"
      text="Local Ip:\t"..ip_addr..separator.."Gateway:\t\t".. gateway..separator .."External Ip:\t"..data[n_graph].ext_ip .. separator .. "Tor External Ip:\t" .. tor_ext_ip
    else
      text="Wire is not connected on " .. interface
    end
  else 
      text ="Interface : "..interface .. " is down."
  end
  data[n_graph].ippopup=naughty.notify({
      title = interface .. " informations:",
      text = text,
      timeout= 0,
      hover_timeout = 0.5
      })

end

function set_ippopup(n_graph)
  n_graph.widget:add_signal("mouse::enter", function()
      show_ippopup_infos(n_graph)
    end)
    n_graph.widget:add_signal("mouse::leave", function()
        hide_ippopup_infos(n_graph)
    end)
end

--- Create a net graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A net graph widget.

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100 
    local height = args.height or 20

    if width < 6 or height < 6 then return end

    local n_graph = {}
    n_graph.widget = capi.widget(args)
    n_graph.widget.resize = false

    data[n_graph] = { width = width, height = height, value = 0 ,nets={}}
    -- Set methods
--    n_graph.add_value = add_value
      n_graph.set_ippopup = set_ippopup
    for _, prop in ipairs(properties) do
        n_graph["set_" .. prop] = _M["set_" .. prop]
    end

    n_graph.layout = args.layout or layout.horizontal.leftright
    update_net(n_graph)
--    set_ippopup(n_graph)
    return n_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
