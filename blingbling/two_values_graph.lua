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
local os = require("os")
module("blingbling.two_values_graph")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "margin", "background_color", "tiles_color", "twov_graph_color", "twov_graph_line_color", "text_color", "background_text_color" ,"label", "font_size"}

local function update(twov_graph)
  
  local twov_graph_surface=cairo.image_surface_create("argb32",data[twov_graph].width, data[twov_graph].height)
  local twov_graph_context = cairo.context_create(twov_graph_surface)
  
  local margin = 3
  if data[twov_graph].margin then 
    margin = data[twov_graph].margin 
  end

--Generate Background (background color and Tiles)
  if data[twov_graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[twov_graph].background_color)
    twov_graph_context:set_source_rgba(r,g,b,a)
    twov_graph_context:paint()
  end
  --find nb max horizontal lignes we can display with 2 pix squarre and 1 px separator (3px)
  local max_line=math.floor((data[twov_graph].height - (margin *2)) /3)
  --what to do with the rest of the height:
  local rest=(data[twov_graph].height - (margin * 2)) - (max_line * 3)
  --if rest = 0, we do nothing
  --if rest = 1, nothing to do
  --if rest = 2, we can add a line of squarre whitout separator.
  if rest == 2 then 
    max_line= max_line + 1
  end
  --find nb columns we can draw with 1 square of 4px and 2 px separator (6px)
  local max_column=math.ceil(data[twov_graph].width/6)

  --set x and y at the bottom right minus column length for x (rectangle origin is the left bottom corner)
  x=data[twov_graph].width-4 
  y=data[twov_graph].height-(margin*2)
  --helpers.dbg({y})
  for i=1,max_column do
    for j=1,max_line do
      twov_graph_context:rectangle(x,y,4,2)
	  y= y-3
    end
    y=data[twov_graph].height - (margin * 2)
    x=x-6
  end
  if data[twov_graph].tiles_color then
    --helpers.dbg({data[twov_graph].tiles_color})
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[twov_graph].tiles_color)
    twov_graph_context:set_source_rgba(r, g, b,a)
  else
    twov_graph_context:set_source_rgba(0, 0, 0,0.5)
  end
  twov_graph_context:fill()

--Drawn the twov_graph
 --find nb values we can draw every 3 px
  max_column=math.ceil(data[twov_graph].width/3)
 --dbg({max_column})
  --Check if the table twov_graph values is empty / not initialized
  --if next(data[twov_graph].values) == nil then
  if #data[twov_graph].values_1 == 0 or #data[twov_graph].values_1 ~= max_column then
      -- initialize twov_graph_values with empty values:
  data[twov_graph].values_1={}
    for i=1,max_column do
      --twov_graph_values[i]=math.random(0,100) / 100
      data[twov_graph].values_1[i]=0
      --dbg({data[twov_graph].values[i]})
    end
  end
  
  if #data[twov_graph].values_2 == 0 or #data[twov_graph].values_2 ~= max_column then
      -- initialize twov_graph_values with empty values:
  data[twov_graph].values_2={}
    for i=1,max_column do
      --twov_graph_values[i]=math.random(0,100) / 100
      data[twov_graph].values_2[i]=0
      --dbg({data[twov_graph].values[i]})
    end
  end
--first graph
  x=data[twov_graph].width-2 
  y=data[twov_graph].height-(margin) 
  
  twov_graph_context:new_path()
  twov_graph_context:move_to(x,y)
  twov_graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[twov_graph].height - (2 * margin)
    
    --dbg({data[twov_graph].values[i]})
    y= data[twov_graph].height - (margin + ((data[twov_graph].values_2[i]) * y_range))
    --y= data[twov_graph].height - (margin + ((0/100) * y_range))
    twov_graph_context:line_to(x,y)
    x=x-3
  end
  --dbg({i,data[twov_graph].values[1]})
  y=data[twov_graph].height - (margin )
  twov_graph_context:line_to(x+3,y) 
  twov_graph_context:line_to(data[twov_graph].width-2,data[twov_graph].height-(margin))
  twov_graph_context:close_path()
  if data[twov_graph].twov_graph_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].twov_graph_color)
    twov_graph_context:set_source_rgba(1 - r, 1 - g, 1 - b, a)
  else
    twov_graph_context:set_source_rgba(1 - 0.5, 1 - 0.7, 1 - 0.1, 0.7)
  end
  twov_graph_context:fill()
  --set x and y at the bottom right minus column length for x (rectangle origin is the left bottom corner)

  x=data[twov_graph].width-2 
  y=data[twov_graph].height-(margin ) 
 
  twov_graph_context:new_path()
  twov_graph_context:move_to(x,y)
  twov_graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[twov_graph].height - (2 * margin)
    y= data[twov_graph].height - (margin + ((data[twov_graph].values_2[i]) * y_range))
    twov_graph_context:line_to(x,y)
    x=x-3
  end
  y=data[twov_graph].height - (margin )
  twov_graph_context:line_to(x+3,y) 
  twov_graph_context:set_line_width(1)
  if data[twov_graph].twov_graph_line_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].twov_graph_line_color)
    twov_graph_context:set_source_rgb(1 - r, 1 - g, 1 - b)
  else
    twov_graph_context:set_source_rgb(1 - 0.5, 1 - 0.7, 1 - 0.1)
  end
  
  twov_graph_context:stroke()
--second /front graph
  x=data[twov_graph].width-2 
  y=data[twov_graph].height-(margin) 
  
  twov_graph_context:new_path()
  twov_graph_context:move_to(x,y)
  twov_graph_context:line_to(x,y)
  for i=1,max_column do
    y_range=data[twov_graph].height - (2 * margin)
    
    --dbg({data[twov_graph].values[i]})
    y= data[twov_graph].height - (margin + ((data[twov_graph].values_1[i]) * y_range))
    --y= data[twov_graph].height - (margin + ((0/100) * y_range))
    twov_graph_context:line_to(x,y)
    x=x-3
  end
  --dbg({i,data[twov_graph].values[1]})
  y=data[twov_graph].height - (margin )
  twov_graph_context:line_to(x + 3,y) 
  twov_graph_context:line_to(data[twov_graph].width-2,data[twov_graph].height-(margin))
  twov_graph_context:close_path()
  if data[twov_graph].twov_graph_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].twov_graph_color)
    twov_graph_context:set_source_rgba(r, g, b, a)
  else
    twov_graph_context:set_source_rgba(0.5, 0.7, 0.1, 0.7)
  end
  twov_graph_context:fill()
  --set x and y at the bottom right minus column length for x (rectangle origin is the left bottom corner)

--  x=data[twov_graph].width-2 
--  y=data[twov_graph].height-(margin ) 
 
--  twov_graph_context:new_path()
--  twov_graph_context:move_to(x,y)
--  twov_graph_context:line_to(x,y)
--  for i=1,max_column do
--    y_range=data[twov_graph].height - (2 * margin)
--    y= data[twov_graph].height - (margin + ((data[twov_graph].values_1[i]) * y_range))
--    twov_graph_context:line_to(x,y)
--    x=x-3
--  end
--  y=data[twov_graph].height - (margin) 
--  twov_graph_context:line_to(x,y) 
--  twov_graph_context:set_line_width(1)
--  if data[twov_graph].twov_graph_line_color then
--    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].twov_graph_line_color)
--    twov_graph_context:set_source_rgb(r, g, b)
--  else
--    twov_graph_context:set_source_rgb(0.5, 0.7, 0.1)
--  end
  
--  twov_graph_context:stroke()

--Draw Text and it's background
  local value_1 = data[twov_graph].values_1[1] * 100
  local value_2 = data[twov_graph].values_2[1] * 100

  if data[twov_graph].label then
    text=data[twov_graph].label .. value_1 .. "+" .. value_2 .."%"
  else
    text=string.format("%d",value_1) .. "+" .. string.format("%d",value_2 - value_1) .."%"

  end
  --Text Background
  ext=twov_graph_context:text_extents(text)
  twov_graph_context:rectangle(0+margin + ext.x_bearing ,(data[twov_graph].height - (2 * margin)) + ext.y_bearing ,ext.width, ext.height)
  if data[twov_graph].background_text_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].background_text_color)
    twov_graph_context:set_source_rgba(r,g,b,a)
  else
    twov_graph_context:set_source_rgba(0,0,0,0.5)
  end
  twov_graph_context:fill()
  --Text
  if data[twov_graph].font_size then
    twov_graph_context:set_font_size(data[twov_graph].font_size)
  else
    twov_graph_context:set_font_size(9)
  end
  --twov_graph_context:select_font_face("Sans", "normal", "normal")
  twov_graph_context:new_path()
  twov_graph_context:move_to(0+margin,data[twov_graph].height - (2 * margin))
  if data[twov_graph].text_color then
    r,g,b,a=helpers.hexadecimal_to_rgba_percent(data[twov_graph].text_color)
    twov_graph_context:set_source_rgba(r, g, b, a)
  else
    twov_graph_context:set_source_rgba(1,1,1,1)
  end
  twov_graph_context:show_text(text)
  twov_graph.widget.image = capi.image.argb32(data[twov_graph].width, data[twov_graph].height, twov_graph_surface:get_data())
end

--@param twov_graph The twov_graph
--@param value value between 0 and 100.

local function add_value(twov_graph, value_1, value_2)
  local name="values"
  --helpers.dbg({name,type(value_1),value_1, name,type(value_2),value_2,os.date("%H:%M:%S")})
  
  if not twov_graph then return end
  local value={}
  --value=the_values
  --local the_values = the_values  
 -- value = helpers.split( the_values,":")  or 0
  value[1]= value_1/100 or 0
  value[2] =value_2/100 or 0

  if string.find(value[1], "nan") then
    value=0
  end

  if string.find(value[2], "nan") then
    dbg({value})
    value=0
  end
  local values_1 = data[twov_graph].values_1
  --dbg({value})
  --table.remove(data[twov_graph].values, #values)
  --table.insert(data[twov_graph].values,1,value)
  table.remove(values_1, #values_1)
  table.insert(values_1,1,value[1])

   local values_2 = data[twov_graph].values_2
  --dbg({value})
  --table.remove(data[twov_graph].values, #values)
  --table.insert(data[twov_graph].values,1,value)
  table.remove(values_2, #values_2)
  table.insert(values_2,1,value[2])
 --for i=1,#values do
--	dbg({data[twov_graph].values[i]})
  --end
  update(twov_graph)
  return twov_graph
end


--- Set the twov_graph height.
-- @param twov_graph The twov_graph.
-- @param height The height to set.
function set_height(twov_graph, height)
    if height >= 5 then
        data[twov_graph].height = height
        update(twov_graph)
    end
    return twov_graph
end

--- Set the twov_graph width.
-- @param twov_graph The twov_graph.
-- @param width The width to set.
function set_width(twov_graph, width)
    if width >= 5 then
        data[twov_graph].width = width
        update(twov_graph)
    end
    return twov_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(twov_graph, value)
            data[twov_graph][prop] = value
            update(twov_graph)
            return twov_graph
        end
    end
end

--- Create a twov_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set twov_graph geometry.
-- @return A twov_graph widget.
function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local twov_graph = {}
    twov_graph.widget = capi.widget(args)
    twov_graph.widget.resize = false

    data[twov_graph] = { width = width, height = height, values_1 = {}, values_2 = {} }

    -- Set methods
    twov_graph.add_value = add_value

    for _, prop in ipairs(properties) do
        twov_graph["set_" .. prop] = _M["set_" .. prop]
    end

    twov_graph.layout = args.layout or layout.horizontal.leftright

    return twov_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
