local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type=type
local cairo = require "oocairo"
local capi = { image = image, widget = widget }
local layout = require("awful.widget.layout")

---A graph widget.
module("blingbling.classical_graph")

---Fill all the widget (width * height) with this color (default is transparent ) 
--mycairograph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set rounded corners for background and graph background
--mycairograph:set_rounded_size(a) -> a in [0,1]
--@name set_rounded_size
--@class function
--@param graph the graph
--@param rounded_size float in [0,1]

--Define the top and bottom margin for the filed background and the graph
--mycairograph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the graph
--@param margin an integer for top and bottom margin

--Define the left and right margin for the filed background and the graph
--mycairograph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the graph
--@param margin an integer for left and right margin

---Draw a rectangle behind the graph, default color is black
--mycairograph:set_filled(boolean) --> true or false
--@name set_filled
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

---Set the color of the filled background
--mycairograph:set_filled_color(string) -->"#rrggbbaa"
--@name set_filled_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Draw tiles behind the graph
--mycairograph:set_tiles(boolean) --> true or false
--@name set_tiles
--@class function
--@param graph the graph
--@param boolean true or false (default is true)

---Define tiles color
--mycairograph:set_tiles_color(string) -->"#rrggbbaa"
--@name set_tiles_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph color
--mycairograph:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the graph outline
--mycairograph:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Display text on the graph or not
--mycairograph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the graph
--@param boolean true or false (default is false)

--Define the color of the text
--mycairograph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--mycairograph:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--mycairograph:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the graph
--@param size the font size

---Define the template of the text to display
--mycairograph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the graph
--@param text the text to display

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin","h_margin", "background_color", "filled", "filled_color", "rounded_size", "tiles", "tiles_color", "graph_color", "graph_line_color", "show_text", "text_color", "background_text_color" ,"label", "font_size"}

local function update(graph)
  
  local graph_surface=cairo.image_surface_create("argb32",data[graph].width, data[graph].height)
  local graph_context = cairo.context_create(graph_surface)
  
  local v_margin = 2 
  if data[graph].v_margin then 
    v_margin = data[graph].v_margin 
  end
  local h_margin = 0
  if data[graph].h_margin and data[graph].h_margin <= data[graph].width / 3 then 
    h_margin = data[graph].h_margin 
  end

--Generate Background (background widget)
  if data[graph].background_color then
    rounded_size = data[graph].rounded_size or 0
    helpers.draw_rounded_corners_rectangle( graph_context,
                                            0,
                                            0,
                                            data[graph].width, 
                                            data[graph].height,
                                            data[graph].background_color, 
                                            rounded_size )
  
  end
  
  --Draw nothing, tiles (default) or graph background (filled) 
  if data[graph].filled  == true then
    --fill the graph background
    rounded_size = data[graph].rounded_size or 0
    if data[graph].filled_color then
    helpers.draw_rounded_corners_rectangle( graph_context,
                                            h_margin,
                                            v_margin,
                                            data[graph].width - h_margin, 
                                            data[graph].height - v_margin ,
                                            data[graph].filled_color, 
                                            rounded_size )
    else
    helpers.draw_rounded_corners_rectangle( graph_context,
                                            h_margin,
                                            v_margin,
                                            data[graph].width - h_margin, 
                                            data[graph].height - v_margin ,
                                            "#00000066", 
                                            rounded_size )
    end
  elseif data[graph].filled ~= true and data[graph].tiles== false then
      --draw nothing
      else
      --draw tiles
        if data[graph].tiles_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[graph].tiles_color)
          graph_context:set_source_rgba(r, g, b,a)
        else
          graph_context:set_source_rgba(0, 0, 0,0.5)
        end
		helpers.draw_background_tiles(graph_context, data[graph].height, v_margin, data[graph].width ,h_margin )
        graph_context:fill()
  end

--Drawn the graph
 --find nb values we can draw every 3 px
  --if rounded, make sure that graph don't begin or end outside background
  --check for the less value between hight and height:
  rounded_size = data[graph].rounded_size or 0
    helpers.clip_rounded_corners_rectangle(graph_context,
                                   h_margin, --x
                                   v_margin, --y
                                   data[graph].width - h_margin, 
                                   data[graph].height - v_margin,
                                   rounded_size
                                    )
  
  if data[graph].height > data[graph].width then
    less_value = data[graph].width/2
  else
    less_value = data[graph].height/2
  end
  max_column=math.ceil((data[graph].width - (2*h_margin + 2*(rounded_size * less_value)))/3)
  --Check if the table graph values is empty / not initialized
  --if next(data[graph].values) == nil then
  if #data[graph].values == 0 or #data[graph].values ~= max_column then
      -- initialize graph_values with empty values:
  data[graph].values={}
    for i=1,max_column do
      --the following line feed the graph with random value if you uncomment it and comment the line after it
      --data[graph].values[i]=math.random(0,100) / 100
      data[graph].values[i]=0
    end
  end
  
  x=data[graph].width -(h_margin + rounded_size * less_value)
  y=data[graph].height-(v_margin) 
  
  graph_context:new_path()
  graph_context:move_to(x,y)
  graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[graph].height - (2 * v_margin)
    
    y= data[graph].height - (v_margin + ((data[graph].values[i]) * y_range))
    graph_context:line_to(x,y)
    x=x-3
  end
  y=data[graph].height - (v_margin )
  graph_context:line_to(x + 3 ,y) 
  graph_context:line_to(data[graph].width-h_margin,data[graph].height-(v_margin))
  graph_context:close_path()
  if data[graph].graph_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_color)
    graph_context:set_source_rgba(r, g, b, a)
  else
    graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
  end
  graph_context:fill()
  

  x=data[graph].width - (h_margin + rounded_size * less_value)
  y=data[graph].height-(v_margin) 
 
  graph_context:new_path()
  graph_context:move_to(x,y)
  graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[graph].height - (2 * v_margin + 1)
    y= data[graph].height - (v_margin + ((data[graph].values[i]) * y_range))
    graph_context:line_to(x,y)
    x=x-3
  end
  x=x+ 3
  y=data[graph].height - (v_margin )
  graph_context:line_to(x ,y) 
  graph_context:set_line_width(1)
  if data[graph].graph_line_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[graph].graph_line_color)
    graph_context:set_source_rgba(r, g, b,a)
  else
    graph_context:set_source_rgb(0.5, 0.7, 0.1)
  end
  
  graph_context:stroke()
  if data[graph].show_text == true then
  --Draw Text and it's background
    if data[graph].font_size == nil then
      data[graph].font_size = 9
    end
    graph_context:set_font_size(data[graph].font_size)
    
    if data[graph].background_text_color == nil then
     data[graph].background_text_color = "#000000dd" 
    end
    if data[graph].text_color == nil then
     data[graph].text_color = "#ffffffff" 
    end    
    
    local value = data[graph].values[1] * 100
    if data[graph].label then
      text=string.gsub(data[graph].label,"$percent", value)
    else
      text=value .. "%"
    end

    helpers.draw_text_and_background(graph_context, 
                                        text, 
                                        h_margin + rounded_size * less_value, 
                                        data[graph].height/2 , 
                                        data[graph].background_text_color, 
                                        data[graph].text_color,
                                        false,
                                        true,
                                        false,
                                        false)
  end
  graph.widget.image = capi.image.argb32(data[graph].width, data[graph].height, graph_surface:get_data())
end

--- Add a value to the graph
-- @param graph The graph.
-- @param value The value between 0 and 1.
local function add_value(graph, value)
  if not graph then return end
  local value = value or 0

  if string.find(value, "nan") then
    dbg({value})
    value=0
  end

  local values = data[graph].values
  table.remove(values, #values)
  table.insert(values,1,value)

  update(graph)
  return graph
end

--- Set the graph height.
-- @param graph The graph.
-- @param height The height to set.
function set_height(graph, height)
    if height >= 5 then
        data[graph].height = height
        update(graph)
    end
    return graph
end

--- Set the graph width.
-- @param graph The graph.
-- @param width The width to set.
function set_width(graph, width)
    if width >= 5 then
        data[graph].width = width
        update(graph)
    end
    return graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(graph, value)
            data[graph][prop] = value
            update(graph)
            return graph
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

    local graph = {}
    graph.widget = capi.widget(args)
    graph.widget.resize = false

    data[graph] = { width = width, height = height, values = {} }

    -- Set methods
    graph.add_value = add_value

    for _, prop in ipairs(properties) do
        graph["set_" .. prop] = _M["set_" .. prop]
    end

    graph.layout = args.layout or layout.horizontal.leftright

    return graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
