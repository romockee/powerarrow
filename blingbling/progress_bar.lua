local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table =table
local type=type
local cairo = require("oocairo")
local capi = { image = image, widget = widget }
local layout = require("awful.widget.layout")

---A progressbar widget which looks like a cylinder
module("blingbling.progress_bar")

---Fill all the widget (width * height) with this color (default is transparent ) 
--mycairoprogressbar:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the progressgraph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the top and bottom margin for the filed background and the graph
--mycairoprogressbar:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the progressbar
--@param margin an integer for top and bottom margin

--Define the left and right margin for the filed background and the graph
--mycairoprogressbar:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the progressbar
--@param margin an integer for left and right margin

---Set the color to use to create the background gradiant of the graph, default color is black
--mycairoprogressbar:set_background_graph_color(string) -->"#rrggbbaa"
--@name set_background_graph_color
--@class function
--@param graph the progressbar
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the bar color
--mycairoprogressbar:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the progressbar
--@param color a string "#rrggbbaa" or "#rrggbb"

--Set the graph to evolve horizontaly or verticaly
--mycairoprogressbar:set_horizontal(boolean) --> true or false
--@name set_horizontal
--@class function
--@param graph the progressbar
--@param boolean true or false (default is true)

--Invert the orientation of the graph 
--If invert is true, the graph increase from top to bottom. If horizontal is set to true and invert to true, the graph will increase from right to left. Default is from left to right with horizontal set to true.
--mycairoprogressbar:set_invert(boolean) --> true or false
--@name set_horizontal
--@class function
--@param graph the progressbar
--@param boolean true or false (default is false)

--Display text on the graph or not
--mycairoprogressbar:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the progressbar
--@param boolean true or false (default is false)

--Define the color of the text
--mycairoprogressbar:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the progressbar
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--mycairoprogressbar:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the progressbar
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--mycairoprogressbar:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the progressbar
--@param size the font size

---Define the template of the text to display
--mycairoprogressbar:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the progressbar
--@param text the text to display

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin", "h_margin", "background_color","horizontal", "invert","background_graph_color", "graph_color", "show_text", "text_color", "background_text_color" ,"label", "font_size"}

local function update(p_bar)
  
  local p_bar_surface=cairo.image_surface_create("argb32",data[p_bar].width, data[p_bar].height)
  local p_bar_context = cairo.context_create(p_bar_surface)
  
  local v_margin =  2 
  if data[p_bar].v_margin and data[p_bar].v_margin <= data[p_bar].height/4 then 
    v_margin = data[p_bar].v_margin 
  end
  local h_margin = 0
  if data[p_bar].h_margin and data[p_bar].h_margin <= data[p_bar].width / 3 then 
    h_margin = data[p_bar].h_margin 
  end

--Generate Background (background widget)
  if data[p_bar].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[p_bar].background_color)
    p_bar_context:set_source_rgba(r,g,b,a)
    p_bar_context:paint()
  end
  
  if data[p_bar].graph_color == nil then
    data[p_bar].graph_color = "#7fb219"
  end

--Draw graph and graph background)
  if data[p_bar].horizontal  == true then
    helpers.draw_horizontal_bar(p_bar_context, 
                      h_margin, 
                      v_margin,
                      data[p_bar].width , 
                      data[p_bar].height,
--                      "#000000",
                      {["value"]= data[p_bar].value,["color"]=data[p_bar].graph_color,["invert"]= data[p_bar].invert,["background_bar_color"] = data[p_bar].background_graph_color}
                       )
  else
    helpers.draw_vertical_bar(p_bar_context, 
                      h_margin, 
                      v_margin,
                      data[p_bar].width , 
                      data[p_bar].height,
 --                     "#000000",
                      {["value"]= data[p_bar].value,["color"]=data[p_bar].graph_color,["invert"]= data[p_bar].invert,["background_bar_color"] = data[p_bar].background_graph_color}
                      )
  end

  if data[p_bar].show_text == true then
  --Draw Text and it's background
    if data[p_bar].font_size == nil then
      data[p_bar].font_size = 9
    end
    p_bar_context:set_font_size(data[p_bar].font_size)
        if data[p_bar].background_text_color == nil then
     data[p_bar].background_text_color = "#000000dd" 
    end
    if data[p_bar].text_color == nil then
     data[p_bar].text_color = "#ffffffff" 
    end    
    
    local value = data[p_bar].value * 100
    if data[p_bar].label then
      text=string.gsub(data[p_bar].label,"$percent", value)
    else
      text=value .. "%"
    end
    --if vertical bar, text is at the middle of the width, if vertical bar text is at the middle of the height
    if data[p_bar].horizontal == nil or data[p_bar].horizontal == false then
      helpers.draw_text_and_background(p_bar_context, 
                                        text, 
                                        data[p_bar].width/2, 
                                        data[p_bar].height/2 , 
                                        data[p_bar].background_text_color, 
                                        data[p_bar].text_color,
                                        true,
                                        true,
                                        false,
                                        false)
    else
       helpers.draw_text_and_background(p_bar_context, 
                                        text, 
                                        h_margin, 
                                        data[p_bar].height/2 , 
                                        data[p_bar].background_text_color, 
                                        data[p_bar].text_color,
                                        false,
                                        true,
                                        false,
                                        false)
    end    
  end

  p_bar.widget.image = capi.image.argb32(data[p_bar].width, data[p_bar].height, p_bar_surface:get_data())

end

--- Add a value to the graph
-- @param p_bar The graph.
-- @param value The value between 0 and 1.
local function add_value(p_bar, value)
  if not p_bar then return end
  local value = value or 0

  if string.find(value, "nan") then
    value=0
  end

  data[p_bar].value = value
  
  update(p_bar)
  return p_bar
end

--- Set the graph height.
-- @param p_bar The graph.
-- @param height The height to set.
function set_height(p_bar, height)
    if height >= 5 then
        data[p_bar].height = height
        update(p_bar)
    end
    return p_bar
end

--- Set the graph width.
-- @param p_bar The graph.
-- @param width The width to set.
function set_width(p_bar, width)
    if width >= 5 then
        data[p_bar].width = width
        update(p_bar)
    end
    return p_bar
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(p_bar, value)
            data[p_bar][prop] = value
            update(p_bar)
            return p_bar
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

    if width < 6 or height < 6 then return end

    local p_bar = {}
    p_bar.widget = capi.widget(args)
    p_bar.widget.resize = false

    data[p_bar] = { width = width, height = height, value = 0 }

    -- Set methods
    p_bar.add_value = add_value

    for _, prop in ipairs(properties) do
        p_bar["set_" .. prop] = _M["set_" .. prop]
    end

    p_bar.layout = args.layout or layout.horizontal.leftright
    return p_bar
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
