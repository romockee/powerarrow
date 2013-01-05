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

---A graph widget that uses tiles to represent data
module("blingbling.tiled_graph")

local data = setmetatable({}, { __mode = "k" })

---Fill all the widget (width * height) with this color (default is transparent ) 
--mytiledgraph:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@graph graph the tiled graph
--@param color a string "#rrggbbaa" or "#rrggbb"

--Define the top and bottom margin for the filed background and the graph
--mytiledgraph:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param graph the tiled graph
--@param margin an integer for top and bottom margin

--Define the left and right margin for the filed background and the graph
--mytiledgraph:set_h_margin(integer)
--@name set_h_margin
--@class function
--@param graph the tiled graph
--@param margin an integer for left and right margin

---Set the color of the background tiles
--mytiledgraph:set_background_tiles_color(string) -->"#rrggbbaa"
--@name set_background_tiles_color
--@class function
--@param graph the tiled graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define foreground tiles color 
--mytiledgraph:set_tiles_graph_color(string) -->"#rrggbbaa"
--@name set_tiles_graph_color
--@class function
--@param graph the tiled graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Invert the tiles graph color for the top tiles 
--mytiledgraph:set_hat_top_tile(boolean) --> true or false
--@name set_hat_top_tile
--@class function
--@param graph the tiled graph
--@param color a boolean (true or false, false by default)

--Display text on the graph or not
--mytiledgraph:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param graph the tiled graph
--@param boolean true or false (default is false)

--Define the color of the text
--mytiledgraph:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param graph the tiled graph
--@param color a string "#rrggbbaa" or "#rrggbb" defaul is white

--Define the background color of the text
--mytiledgraph:set_background_text_color(string) -->"#rrggbbaa"
--@name set_background_text_color
--@class
--@param graph the tiled graph
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the text font size
--mytiledgraph:set_font_size(integer)
--@name set_font_size
--@class function
--@param graph the tiled graph
--@param size the font size

---Define the template of the text to display
--mytiledgraph:set_label(string)
--By default the text is : (value_send_to_the_widget *100) .. "%"
--static string: example set_label("CPU usage:") will display "CUP usage:" on the graph
--dynamic string: use $percent in the string example set_label("Load $percent %") will display "Load 10%" 
--@name set_label
--@class function
--@param graph the tiled graph
--@param text the text to display

local properties = { "width", "height", "v_margin","h_margin", "background_color", "background_tiles_color", "tiles_graph_color", "hat_top_tile", "show_text", "text_color", "background_text_color" ,"label", "font_size"}

local function display_how_many_lines(nb_lines, value)
  --create table with possible range that we can display (example: 4 lines -> range_table={0,25,50,75,100}
  local range_table={}
  for i=1, nb_lines do
    range_table[i]=i*(100/nb_lines)
  end
  table.insert(range_table,1,0)
  --compare the value with the range table to get the nb lines to display
  for i,range in ipairs(range_table) do 
    if value <= range then
      nb_line_to_display = i - 1
      break
    end
  end
  return nb_line_to_display
end

local function update(t_graph)
  
  local t_graph_surface=cairo.image_surface_create("argb32",data[t_graph].width, data[t_graph].height)
  local t_graph_context = cairo.context_create(t_graph_surface)
  
  local v_margin = 2  
  if data[t_graph].v_margin then 
    v_margin = data[t_graph].v_margin 
  end
  local h_margin = 0
  if data[t_graph].h_margin then 
    h_margin = data[t_graph].h_margin 
  end

--Generate Background (background color and Tiles)
  if data[t_graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[t_graph].background_color)
    t_graph_context:set_source_rgba(r,g,b,a)
    t_graph_context:paint()
  end
  --find nb max horizontal lignes we can display with 2 pix squarre and 1 px separator (3px)
  local max_line=math.floor((data[t_graph].height - (v_margin *2)) /3)
  --what to do with the rest of the height:
  local rest=(data[t_graph].height - (v_margin * 2)) - (max_line * 3)
  --if rest = 0, we do nothing
  --if rest = 1, nothing to do
  --if rest = 2, we can add a line of squarre whitout separator.
  if rest == 2 then 
    max_line= max_line + 1
  end
  --find nb columns we can draw with 1 square of 4px and 2 px separator (6px)
  local max_column=math.floor((data[t_graph].width - (4+(h_margin * 2)))/6)
  max_column=max_column + 1
  --center all the tiles f( rest ):
  h_rest=(data[t_graph].width - (4+(h_margin * 2)))%6
  --rest can be 1, 2, 3, 4, 5
  --if rest =1, we do nothing
  --if rest =2 or 3 we add 1px margin on right and 1 or 2px margin on left
  --if rest =4 or 5 we add 2px margin on right and 2 or 3px margin on left
  if h_rest ==1 then
    h_rest =0
  end
  if h_rest == 2 or h_rest == 3 then
    h_rest =1
  end
  if h_rest == 4 or h_rest == 5 then
    h_rest = 2
  end
  --set x and y at the bottom right minus column length for x (rectangle origin is the left bottom corner)
  x=data[t_graph].width-(4 + h_margin+h_rest) 
  y=data[t_graph].height-(v_margin *2)
  for i=1,max_column do
    for j=1,max_line do
      t_graph_context:rectangle(x,y,4,2)
	  y= y-3
    end
    y=data[t_graph].height - (v_margin *2)
    x=x-6
  end
  if data[t_graph].background_tiles_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[t_graph].background_tiles_color)
    t_graph_context:set_source_rgba(r, g, b,a)
  else
    t_graph_context:set_source_rgba(0, 0, 0,0.5)
  end
  t_graph_context:fill()

--Drawn the t_graph
  
  -- initialize t_graph_values with empty values:
  if #data[t_graph].values == 0 or #data[t_graph].values ~= max_column then
  data[t_graph].values={}
    for i=1,max_column do
      --t_graph_values[i]=math.random(0,100) / 100
      data[t_graph].values[i]=0
    end
  end

  --set x and y at the bottom right minus column length for x (rectangle origin is the left bottom corner)
  x=data[t_graph].width-(4 + h_margin +h_rest)
  y=data[t_graph].height-(v_margin *2)
   
   if data[t_graph].tiles_graph_color then
          r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[t_graph].tiles_graph_color)
  else
          r=0.5
          g=0.7
          b=0.1
          a=1
  end
  if data[t_graph].hat_top_tile == true then 
    for i=1,max_column do
      nb_lines_to_display=display_how_many_lines(max_line, data[t_graph].values[i] * 100)
      for j=1,   nb_lines_to_display do
        t_graph_context:rectangle(x,y,4,2)      
        if j == nb_lines_to_display then
          t_graph_context:set_source_rgba(1-r,1- g,1- b, a)
        else
          t_graph_context:set_source_rgba(r,g,b, a)
        end
        t_graph_context:fill()
        y= y - 3
      end
      y=data[t_graph].height-(v_margin *2)
      x=x-6
    end
  else
    for i=1,max_column do
      nb_lines_to_display=display_how_many_lines(max_line, data[t_graph].values[i] * 100)
      for j=1,   nb_lines_to_display do
        t_graph_context:rectangle(x,y,4,2)      
        t_graph_context:set_source_rgba(r,g,b, a)
        t_graph_context:fill()
        y= y - 3
      end
      y=data[t_graph].height-(v_margin *2) 
      x=x-6
    end
  end

  if data[t_graph].show_text == true then
  --Draw Text and it's background
    if data[t_graph].font_size == nil then
      data[t_graph].font_size = 9
    end
    t_graph_context:set_font_size(data[t_graph].font_size)
    
    if data[t_graph].background_text_color == nil then
     data[t_graph].background_text_color = "#000000dd" 
    end
    if data[t_graph].text_color == nil then
     data[t_graph].text_color = "#ffffffff" 
    end    
      
    local value = data[t_graph].values[1] * 100
    if data[t_graph].label then
      text=string.gsub(data[t_graph].label,"$percent", value)
    else
      text=value .. "%"
    end
    
    helpers.draw_text_and_background(t_graph_context, 
                                        text, 
                                        h_margin, 
                                        (data[t_graph].height/2) , 
                                        data[t_graph].background_text_color, 
                                        data[t_graph].text_color,
                                        false,
                                        true,
                                        false,
                                        false)
  end
  
  t_graph.widget.image = capi.image.argb32(data[t_graph].width, data[t_graph].height, t_graph_surface:get_data())
end

--- Add a value to the graph
-- @param t_graph the tiled graph.
-- @param value The value between 0 and 1.
local function add_value(t_graph, value)
  if not t_graph then return end
  local value = value or 0

  if string.find(value, "nan") then
    value=0
  end

  local values = data[t_graph].values
  table.remove(values, #values)
  table.insert(values,1,value)

  update(t_graph)
  return t_graph
end

--- Set the graph height.
-- @param t_graph The tiled graph.
-- @param height The height to set.
function set_height(t_graph, height)
    if height >= 5 then
        data[t_graph].height = height
        update(t_graph)
    end
    return t_graph
end

--- Set the graph width.
-- @param t_graph The tiled graph.
-- @param width The width to set.
function set_width(t_graph, width)
    if width >= 5 then
        data[t_graph].width = width
        update(t_graph)
    end
    return t_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(t_graph, value)
            data[t_graph][prop] = value
            update(t_graph)
            return t_graph
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

    local t_graph = {}
    t_graph.widget = capi.widget(args)
    t_graph.widget.resize = false

    data[t_graph] = { width = width, height = height, values = {} }

    -- Set methods
    t_graph.add_value = add_value

    for _, prop in ipairs(properties) do
        t_graph["set_" .. prop] = _M["set_" .. prop]
    end

    t_graph.layout = args.layout or layout.horizontal.leftright

    return t_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
