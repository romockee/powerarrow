local awful = require("awful")
local helpers =require("blingbling.helpers")
local io = require("io")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local type=type
local cairo = require("oocairo")
local capi = { image = image, widget = widget, timer = timer }
local layout = require("awful.widget.layout")
local string = require("string")
---A graphical widget dedicated to the sound on your system.
module("blingbling.volume")

---Fill all the widget (width * height) with this color (default is transparent ) 
--myvolume:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the form of the graph: use five growing bars instead of a triangle
--myvolume:set_bar(boolean) --> true or false
--@name set_bar
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

--Define the top and bottom margin for the graph
--myvolume:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the graph
--@param margin an integer for top and bottom margin

--Define the left and right margin for the graph
--myvolume:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the graph
--@param margin an integer for left and right margin

---Set the color of the graph background
--myvolume:set_filled_color(string) -->"#rrggbbaa"
--@name set_filled_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph color
--myvolume:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Display text on the graph or not
--myvolume:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

--Define the color of the text
--myvolume:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--myvolume:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--myvolume:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display
--@usage myvolume:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("Volume:") will display "Volume:" on the graph
--dynamic string: use $percent in the string example set_label("Volume $percent %") will display "Volume 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin", "h_margin", "background_color", "background_graph_color", "graph_color","show_text", "text_color", "background_text_color" ,"label", "font_size", "bar"}

local function update(v_graph)
  local v_graph_surface=cairo.image_surface_create("argb32",data[v_graph].width, data[v_graph].height)
  local v_graph_context = cairo.context_create(v_graph_surface)
  
  local v_margin = 2
  if data[v_graph].v_margin and data[v_graph].v_margin <= data[v_graph].height/4 then 
    v_margin = data[v_graph].v_margin 
  end
  local h_margin = 0
  if data[v_graph].h_margin and data[v_graph].h_margin <= data[v_graph].width / 3 then 
    h_margin = data[v_graph].h_margin 
  end

--Generate Background (background color and Tiles)
  if data[v_graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[v_graph].background_color)
    v_graph_context:set_source_rgba(r,g,b,a)
    v_graph_context:paint()
  end
--Drawn the v_graph
  
  if data[v_graph].value > 0 then
    if data[v_graph].bar == true then
      --4 bar are use to represent data:
      --bar width:
      local nb_bar=5
      local bar_separator = 2
      local bar_width 
      bar_width=math.floor((data[v_graph].width -((2*h_margin) + ((nb_bar - 1) * bar_separator)))/nb_bar)
      local h_rest =data[v_graph].width -( 2*h_margin +((nb_bar -1)*bar_separator) + nb_bar * bar_width)
      if h_rest ==2 or h_rest == 3 then 
        h_rest = 1
      end
      if h_rest == 4 then
        h_rest = 2
      end
      --Drawn background graph
      x=h_margin+h_rest
      y=data[v_graph].height - v_margin
      for i=1, nb_bar do
        v_graph_context:rectangle(x,y-((0.2*i)*(data[v_graph].height - 2*v_margin)),bar_width,((0.2*i)*(data[v_graph].height - 2*v_margin)))
        x=x+(bar_width + bar_separator)
      end
      if data[v_graph].graph_color then
        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[v_graph].background_graph_color)
        v_graph_context:set_source_rgba(r, g, b, a)
      else
        v_graph_context:set_source_rgba(0, 0, 0, 0.5)
      end
      v_graph_context:fill()
      --Drawn the graph
      --find nb column to drawn:
      local ranges={0,0.2,0.4,0.6,0.8,1,1.2}
      nb_bar=0
      for i,  limite in ipairs(ranges) do
        if data[v_graph].value < limite then
        --helpers.dbg({data[v_graph].value, limite})
          nb_bar = i-1
          break
        end
      end
      x=h_margin+h_rest
      y=data[v_graph].height - v_margin
      for i=1, nb_bar do
        if i ~= nb_bar then
          v_graph_context:rectangle(x,y-((0.2*i)*(data[v_graph].height - 2*v_margin)),bar_width,(0.2*i)*(data[v_graph].height - 2*v_margin))
          x=x+(bar_width + bar_separator)
        else
          val_to_display =data[v_graph].value - ((nb_bar-1) * 0.2)

          v_graph_context:rectangle(x,y-((0.2*i)*(data[v_graph].height - 2*v_margin)),bar_width * (val_to_display/0.2),(0.2*i)*(data[v_graph].height - 2*v_margin))
        end
      end
      if data[v_graph].graph_color then
        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[v_graph].graph_color)
        v_graph_context:set_source_rgba(r, g, b, a)
      else
        v_graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      end
      v_graph_context:fill()

    elseif data[v_graph].arc == true then
    
    else  
      x=h_margin 
      y=data[v_graph].height-(v_margin) 
  
      v_graph_context:new_path()
      v_graph_context:move_to(x,y)
      v_graph_context:line_to(x,y)
      y_range=data[v_graph].height - (2 * v_margin)
      v_graph_context:line_to(data[v_graph].width + h_margin,data[v_graph].height -( v_margin + y_range ))
      v_graph_context:line_to(data[v_graph].width  + h_margin, data[v_graph].height - (v_margin ))
      v_graph_context:line_to(h_margin,data[v_graph].height-(v_margin))
  
      v_graph_context:close_path()
    
      if data[v_graph].background_graph_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[v_graph].background_graph_color)
          v_graph_context:set_source_rgba(r, g, b,a)
      else
          v_graph_context:set_source_rgba(0, 0, 0,0.5)
      end
      v_graph_context:fill()
      
      x=h_margin 
      y=data[v_graph].height-(v_margin) 
  
      v_graph_context:new_path()
      v_graph_context:move_to(x,y)
      v_graph_context:line_to(x,y)
      y_range=data[v_graph].height - (2 * v_margin)
      v_graph_context:line_to(data[v_graph].width * data[v_graph].value + h_margin,data[v_graph].height -( v_margin + (y_range * data[v_graph].value)))
      v_graph_context:line_to(data[v_graph].width * data[v_graph].value + h_margin, data[v_graph].height - (v_margin ))
      v_graph_context:line_to(0+h_margin,data[v_graph].height-(v_margin))
  
      v_graph_context:close_path()
      if data[v_graph].graph_color then
        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[v_graph].graph_color)
        v_graph_context:set_source_rgba(r, g, b, a)
      else
        v_graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
      end
      v_graph_context:fill()

      x=0+h_margin 
      y=data[v_graph].height-(v_margin) 

      v_graph_context:new_path()
      v_graph_context:move_to(x,y)
      v_graph_context:line_to(x,y)
      y_range=data[v_graph].height - (2 * v_margin)
      v_graph_context:line_to((data[v_graph].width * data[v_graph].value) + h_margin  ,data[v_graph].height -( v_margin +  (y_range * data[v_graph].value)))
      v_graph_context:line_to((data[v_graph].width * data[v_graph].value) - h_margin, data[v_graph].height - (v_margin ))
      v_graph_context:set_antialias("subpixel") 
      v_graph_context:set_line_width(1)
      if data[v_graph].graph_line_color then
        r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[v_graph].graph_line_color)
        v_graph_context:set_source_rgb(r, g, b)
      else
        v_graph_context:set_source_rgb(0.5, 0.7, 0.1)
      end
  
      v_graph_context:stroke()
    end
  end
  
--Draw Text and it's background
  if data[v_graph].show_text == true and data[v_graph].state ~= "off" then
    if data[v_graph].font_size == nil then
      data[v_graph].font_size = 9
    end
    v_graph_context:set_font_size(data[v_graph].font_size)
    
    if data[v_graph].background_text_color == nil then
     data[v_graph].background_text_color = "#000000dd" 
    end
    if data[v_graph].text_color == nil then
     data[v_graph].text_color = "#ffffffff" 
    end    
     local value = data[v_graph].value * 100
    
    if data[v_graph].label then
      text=string.gsub(data[v_graph].label,"$percent", value)
    else
      text=value .. "%"
    end
    helpers.draw_text_and_background(v_graph_context, 
                                      text, 
                                      h_margin, 
                                      (data[v_graph].height/2) , 
                                      data[v_graph].background_text_color, 
                                      data[v_graph].text_color,
                                      false,
                                      true,
                                      false,
                                      false)
  else 
    if data[v_graph].state == "off" then
      text = "Muted"
      local background_text_color = "#000000dd" 
      local text_color = "#ff0000ff" 
      if data[v_graph].font_size == nil then
        data[v_graph].font_size = 9
      end
      v_graph_context:set_font_size(data[v_graph].font_size)
      helpers.draw_text_and_background(v_graph_context, 
                                      text, 
                                      h_margin, 
                                      (data[v_graph].height/2) , 
                                      background_text_color, 
                                      text_color,
                                      false,
                                      true,
                                      false,
                                      false)
    end
  end
  
  v_graph.widget.image = capi.image.argb32(data[v_graph].width, data[v_graph].height, v_graph_surface:get_data())

end

local function get_master_infos()
  local f=io.popen("amixer get Master")
  for line in f:lines() do
    if string.match(line, "%s%[%d+%%%]%s") ~= nil then
      volume=string.match(line, "%s%[%d+%%%]%s")
      volume=string.gsub(volume, "[%[%]%%%s]","")
      --helpers.dbg({volume})
    end
    if string.match(line, "%s%[[%l]+%]$") then
      state=string.match(line, "%s%[[%l]+%]$")
      state=string.gsub(state,"[%[%]%%%s]","")
    end
  end
  f:close()
  return state, volume
end

local function set_master(parameters)
    local cmd = "amixer --quiet set Master " ..parameters
    local f=io.popen(cmd)
    f:close()
end

---Add a value to the graph
--@param v_graph the volume graph
--@param value the value between 0 and 1
local function add_value(v_graph, value)
  if not v_graph then return end
  local value = value or 0

  if string.find(value, "nan") then
    value=0
  end
  data[v_graph].value = value
  update(v_graph)
  return v_graph
end

local function update_master(v_graph)
    local state
    local value
    data[v_graph].mastertimer = capi.timer({timeout = 0.5})
    data[v_graph].mastertimer:add_signal("timeout", function() 
      data[v_graph].state, value = get_master_infos(); add_value(v_graph,value/100) 
    end)
    data[v_graph].mastertimer:start()
end

local function get_mpd_volume()
  local mpd_volume=0

  local pass = "\"\""
  local host = "127.0.0.1"
  local port = "6600"

    -- MPD client command 
  local mpd_c = "mpc" .. " -h " .. host .. " -p " .. port .. " status 2>&1"

  -- Get data from MPD server
  local f = io.popen(mpd_c)

  for line in f:lines() do
    --helpers.dbg({line})
    if string.find(line,'error:%sConnection%srefused') then
      mpd_vol="-1"
    end
    if string.find(line,"volume:.%d%d%%") then
      mpd_volume = string.match(line,"[%s%d]%d%d")
      --mpd_volume = line
    end
  end
  f:close()
  return mpd_volume
end
---Link the widget to mpd's volume level 
--myvolume:update_mpd()
--@param v_graph the volume graph
local function update_mpd(v_graph)
    local state
    local value
    data[v_graph].mastertimer = capi.timer({timeout = 0.5})
    data[v_graph].mastertimer:add_signal("timeout", function() 
      value = get_mpd_volume(); add_value(v_graph,value/100) 
    end)
        data[v_graph].mastertimer:start()
end

---Link the widget to the master channel of your system (uses amixer)
--@usage myvolume:set_master_control()
--a left clic toggle mute/unmute
--wheel up increase the volume 
--wheel down decrease the volume
--@param v_graph the volume graph
local function set_master_control(v_graph)
    v_graph.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      set_master("toggle")
    end),
    awful.button({ }, 5, function()
      set_master("2%-")
    end),
    awful.button({ }, 4, function()
      set_master("2%+")
    end)))
end

--- Set the graph height.
-- @param v_graph The volume graph.
-- @param height The height to set.
function set_height(v_graph, height)
    if height >= 5 then
        data[v_graph].height = height
        update(v_graph)
    end
    return v_graph
end

--- Set the graph width.
-- @param v_graph The volume graph.
-- @param width The width to set.
function set_width(v_graph, width)
    if width >= 5 then
        data[v_graph].width = width
        update(v_graph)
    end
    return v_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(v_graph, value)
            data[v_graph][prop] = value
            update(v_graph)
            return v_graph
        end
    end
end

--- Create a graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100 
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local v_graph = {}
    v_graph.widget = capi.widget(args)
    v_graph.widget.resize = false

    data[v_graph] = { width = width, height = height, value = 0 }

    -- Set methods
    v_graph.add_value = add_value
    v_graph.update_master = update_master
    v_graph.update_mpd= update_mpd
    v_graph.set_master_control = set_master_control
    for _, prop in ipairs(properties) do
        v_graph["set_" .. prop] = _M["set_" .. prop]
    end
    v_graph.layout = args.layout or layout.horizontal.leftright
    return v_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
