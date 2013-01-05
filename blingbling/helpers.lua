local naughty= require("naughty")
local cairo=require("oocairo")
local string = require("string")
local os = require('os')
local math = math
local table = table
---Functions used in blingbling.
module("blingbling.helpers")

widget_index={}

---Display values of variables in an awesome popup.
--Each variables in vars is separated by a "|"
--@param vars a table of variable
function dbg(vars)
  local text = ""
  for i=1, #vars do text = text .. vars[i] .. " | " end
  naughty.notify({ text = text, timeout = 15 })
end

---Convert an hexadecimal color to rgba color.
--It convert a string variable "#rrggbb" or "#rrggbbaa" (with r,g,b and a which are hexadecimal value) to r, g, b a=1 or r,g,b,a (with r,g,b,a floated value from 0 to 1.
--The function returns 4 variables.
--@param my_color a string "#rrggbb" or "#rrggbbaa"
function hexadecimal_to_rgba_percent(my_color)
  --check if color is a valid hex color else return white
  if string.find(my_color,"#[0-f][0-f][0-f][0-f][0-f]") then
  --delete #
    my_color=string.gsub(my_color,"^#","")
    r=string.format("%d", "0x"..string.sub(my_color,1,2))
    v=string.format("%d", "0x"..string.sub(my_color,3,4))
    b=string.format("%d", "0x"..string.sub(my_color,5,6))
    if string.sub(my_color,7,8) == "" then
      a=255
    else
      a=string.format("%d", "0x"..string.sub(my_color,7,8))
    end
  else
    r=255
    v=255
    b=255
    a=255
   end
  return r/255,v/255,b/255,a/255
end

---Split string in different parts which are returned in a table. The delimiter of each part is a pattern given in argument
--@param str the string to split
--@param pat the pattern delimiter
function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = string.find(str,fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = string.find(str,fpat, last_end)
  end
  if last_end <= #str then
    cap = string.sub(str,last_end)
    table.insert(t, cap)
  end
  return t
end

---Draw tiles in a cairo context.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param height the height of the surface on which we want tiles
--@param v_margin value used to define top margin and/or bottom margin (tiles are not drawn on the margins)
--@param width the width of the surface on which we want tiles
--@param h_margin value used to define left margin and/or right margin.
function draw_background_tiles(cairo_context, height, v_margin , width, h_margin)
--tiles: width 4 px height 2px horizontal separator=1 px vertical separator=2px
--			v_separator
--		 _______\ /_______
--		|_______| |_______| 
--	 	 _______   _______  <--h_separator
--		|_______| |_______|	<--tiles_height
--		/        \
--		tiles_width
   
  tiles_width=4
  tiles_height=2
  h_separator=1
  v_separator=2
--find nb max horizontal lignes we can display with 2 pix squarre and 1 px separator (3px)
  local max_line=math.floor((height - v_margin*2) /(tiles_height+h_separator))
  --what to do with the rest of the height:
  local h_rest=(height - v_margin*2) - (max_line * (tiles_height+h_separator))
  if h_rest >= (tiles_height) then 
     max_line= max_line + 1
     h_rest= h_rest - tiles_height
  end
  if h_rest > 0 then
	  h_rest =h_rest / 2
  end	
  --find nb columns we can draw with tile of 4px width and 2 px separator (6px) and center them horizontaly
  local max_column=math.floor((width - h_margin*2)/6)
  local v_rest=(width- h_margin*2)-(max_column*( tiles_width + v_separator))
  if v_rest >= (tiles_width) then 
    max_column= max_column + 1
    v_rest= v_rest - tiles_width
  end
  if v_rest > 0 then
	  h_rest =h_rest / 2
  end	
  
  x=width-(tiles_width + v_rest)
  y=height -(v_margin +tiles_height + h_rest) 
  for i=1,max_column do
    for j=1,max_line do
      cairo_context:rectangle(x,y,4,2)
      y= y-(tiles_height + h_separator)
    end
      y=height -(v_margin + tiles_height + h_rest) 
      x=x-(tiles_width + v_separator)
  end
end

---Draw text on a rectangle which width and height depend on the text width and height.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param text the text to display
--@param x the x coordinate of the left of the text 
--@param y the y coordinate of the bottom of the text
--@param background_text_color a string "#rrggbb" or "#rrggbbaa" for the rectangle color
--@param text_color a string "#rrggbb" or "#rrggbbaa" for the text color
--@param show_text_centered_on_x a boolean value not mandatory (false by default) if true, x parameter is the coordinate of the middle of the text
--@param show_text_centered_on_y a boolean value not mandatory (false by default) if true, y parameter is the coordinate of the middle of the text
--@param show_text_on_left_of_x a boolean value not mandatory (false by default) if true, x parameter is the right of the text
--@param show_text_on_bottom_of_y a boolean value not mandatory (false by default) if true, y parameter is the top of the text
function draw_text_and_background(cairo_context, text, x, y, background_text_color, text_color, show_text_centered_on_x, show_text_centered_on_y, show_text_on_left_of_x, show_text_on_bottom_of_y)
    --Text background
    ext=cairo_context:text_extents(text)
    x_modif = 0
    y_modif = 0
    
    if show_text_centered_on_x == true then
      x_modif = ((ext.width + ext.x_bearing) / 2) + ext.x_bearing / 2 
      show_text_on_left_of_x = false
    else
      if show_text_on_left_of_x == true then
        x_modif = ext.width + 2 *ext.x_bearing     
      else 
        x_modif = x_modif
      end
    end
    
    if show_text_centered_on_y == true then
      y_modif = ((ext.height +ext.y_bearing)/2 ) + ext.y_bearing / 2
      show_text_on_left_of_y = false
    else
      if show_text_on_bottom_of_y == true then
        y_modif = ext.height + 2 *ext.y_bearing     
      else 
        y_modif = y_modif
      end
    end
    cairo_context:rectangle(x + ext.x_bearing - x_modif,y + ext.y_bearing - y_modif,ext.width, ext.height)
    r,g,b,a=hexadecimal_to_rgba_percent(background_text_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:fill()
    --Text
    cairo_context:new_path()
    cairo_context:move_to(x-x_modif,y-y_modif)
    r,g,b,a=hexadecimal_to_rgba_percent(text_color)
    cairo_context:set_source_rgba(r, g, b, a)
    cairo_context:show_text(text)
end

---Drawn one foreground arrow with a background arrow that depend on a value.
--If the value is egal to 0 then the foreground arrow is not drawn.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate in the cairo context where the arrow start
--@param y_bottom the bottom corrdinate of the arrows
--@param y_top the top coordinate of the arrows
--@param value a number 
--@param background_arrow_color the color of the background arrow, a string "#rrggbb" or "#rrggbbaa" 
--@param arrow_color the color of the foreground arrow, a string "#rrggbb" or "#rrggbbaa"
--@param arrow_line_color the color of the outline of the foreground arrow , a string "#rrggbb" or "#rrggbbaa"
--@param up boolean value if false draw a down arrow, if true draw a up arrow
function draw_up_down_arrows(cairo_context,x,y_bottom,y_top,value,background_arrow_color, arrow_color, arrow_line_color,up)
    if up ~= false then 
      invert = 1
    else
      invert= -1
    end
    --Draw the background arrow
    cairo_context:move_to(x,y_bottom)
    cairo_context:line_to(x,y_top )
    cairo_context:line_to(x-(6 * invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
    cairo_context:line_to(x-(3*invert), y_bottom)
    cairo_context:line_to(x,y_bottom)
    cairo_context:close_path()
    r,g,b,a = hexadecimal_to_rgba_percent(background_arrow_color)
    cairo_context:set_source_rgba(r, g, b, a)
    cairo_context:fill()
    --Draw the arrow if value is > 0
    if value > 0 then
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      r,g,b,a = hexadecimal_to_rgba_percent(arrow_color)
      cairo_context:set_source_rgba(r, g, b, a)
      cairo_context:fill()
      cairo_context:move_to(x,y_bottom)
      cairo_context:line_to(x,y_top )
      cairo_context:line_to(x-(6*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_top + (6 * invert))
      cairo_context:line_to(x-(3*invert), y_bottom)
      cairo_context:line_to(x,y_bottom)
      cairo_context:close_path()
      r,g,b,a = hexadecimal_to_rgba_percent(arrow_line_color)
      cairo_context:set_source_rgba(r, g, b, a)
      cairo_context:set_line_width(1)
      cairo_context:stroke()
  end
end

---Draw a vertical bar with gradient color, so it looks like a cylinder, and it's height depends on a value. 
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param h_margin the left and right margin of the bar in the cairo_context 
--@param v_margin the top and bottom margin of the bar in the cairo_context
--@param width the width used to display the left margin, the bar and the right margin
--@param height the height used to display the top margin, the bar and the bottom margin
--@param represent a table {background_bar_color = "#rrggbb" or "#rrggbbaa", color = "#rrggbb" or "#rrggbbaa", value =the value used to calculate the height of the bar}
function draw_vertical_bar(cairo_context,h_margin,v_margin, width,height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end

  cairo_context:rectangle(x,y,bar_width ,bar_height)
  gradient=cairo.pattern_create_linear(h_margin, height/2, width-h_margin, height/2)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cairo_context:set_source(gradient)
  cairo_context:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      y=v_margin 
    else
      y=height - (bar_height*represent["value"] + v_margin )
    end
    cairo_context:rectangle(x,y,bar_width,bar_height*represent["value"])
    r,g,b,a = hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(0, height/2,width, height/2)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cairo_context:set_source(gradient)
    cairo_context:fill()
  end  
end
---Draw an horizontal bar with gradient color, so it looks like a cylinder, and it's height depends on a value. 
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param h_margin the left and right margin of the bar in the cairo_context 
--@param v_margin the top and bottom margin of the bar in the cairo_context
--@param width the width used to display the left margin, the bar and the right margin
--@param height the height used to display the top margin, the bar and the bottom margin
--@param represent a table {background_bar_color = "#rrggbb" or "#rrggbbaa", color = "#rrggbb" or "#rrggbbaa", value =the value used to calculate the width of the bar}

function draw_horizontal_bar( cairo_context,h_margin,v_margin, width, height, represent)
  x=h_margin
  bar_width=width - 2*h_margin
  bar_height=height - 2*v_margin
  y=v_margin 
  if represent["background_bar_color"] == nil then
    r,g,b,a = hexadecimal_to_rgba_percent("#000000")
  else
    r,g,b,a = hexadecimal_to_rgba_percent(represent["background_bar_color"])
  end
  cairo_context:rectangle(x,y,bar_width,bar_height)
  gradient=cairo.pattern_create_linear( width /2,v_margin , width/2, height - v_margin)
  gradient:add_color_stop_rgba(0, r, g, b, 0.5)
  gradient:add_color_stop_rgba(0.5, 1, 1, 1, 0.5)
  gradient:add_color_stop_rgba(1, r, g, b, 0.5)
  cairo_context:set_source(gradient)
  cairo_context:fill()
  if represent["value"] ~= nil and represent["color"] ~= nil then
    x=h_margin
    bar_width=width - 2*h_margin
    bar_height=height - 2*v_margin
    if represent["invert"] == true then
      x=width - (h_margin + bar_width*represent["value"] )
    else
      x=h_margin
    end
    cairo_context:rectangle(x,y,bar_width*represent["value"],bar_height)
    r,g,b,a = hexadecimal_to_rgba_percent(represent["color"])
    gradient=cairo.pattern_create_linear(width /2,0 , width/2, height)
    gradient:add_color_stop_rgba(0, r, g, b, 0.1)
    gradient:add_color_stop_rgba(0.5, r, g, b, 1)
    gradient:add_color_stop_rgba(1, r, g, b, 0.1)
    cairo_context:set_source(gradient)
    cairo_context:fill()
  end  
end

---Draw a rectangle width rounded corners.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the rectangle
--@param height the height of the rectangle
--@param color a string "#rrggbb" or "#rrggbbaa" for the color of the rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
function draw_rounded_corners_rectangle(cairo_context,x,y,width, height, color, rounded_size)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  r,g,b,a=hexadecimal_to_rgba_percent(color)
  cairo_context:set_source_rgba(r,g,b,a)
  --top left corner
  cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cairo_context:close_path()
  cairo_context:fill()

end

---Set a rectangle width rounded corners that define the area to draw.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the rectangle
--@param height the height of the rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
function clip_rounded_corners_rectangle(cairo_context,x,y,width, height, rounded_size)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  --top left corner
  cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cairo_context:close_path()
  cairo_context:clip()

end


---Draw a foreground rounded corners rectangle which width depends on a value, and a background rounded corners rectangle.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the background rectangle and the maximal width of th foreground rectangle
--@param height the height of the background and the foreground rectangles
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param graph_color a string "#rrggbb" or "#rrggbbaa" for the color of the foreground rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
--@param value_to_represent the percent of the max width used to calculate the width of the foreground rectangle
--@param graph_line_color a string "#rrggbb" or "#rrggbbaa" for the outiline color of the background rectangle
function draw_rounded_corners_horizontal_graph(cairo_context,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  local rounded_size = rounded_size or 0.4
  if height > width then
    radius=0.5 * width
  else
    radius=0.5 * height
  end

  PI = 2*math.asin(1)
  --draw the background
  r,g,b,a=hexadecimal_to_rgba_percent(background_color)
  cairo_context:set_source_rgba(r,g,b,a)
  --top left corner
  cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
  --top right corner
  cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
  --bottom right corner
  cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
  --bottom left corner
  cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
  cairo_context:close_path()
  cairo_context:fill()
  --represent the value
  -- value in 0 -> 1
  --  radius*rounded_size |  width - 2*( radius*rounded) | radius * rounded_size
  --                  |               |                         |
  --                  |      _________|  _______________________|
  --                  |     |           |
  --                  v ____v_________  v
  --                  /|              |\
  --                 | |              | |               (... and yes I don't have a job)
  --                  \|______________|/
  --
  --1 => width/ width
  --limit_2 => width -radius / width
  --limit_1 => radius /width
  value = value_to_represent
  limit_2 = (width -(radius * rounded_size)) / width
  limit_1 = radius* rounded_size /width

  r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
  cairo_context:set_source_rgba(r,g,b,a)
 
  if value <= 1 and value > limit_2 then
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = (value - limit_2) / (1 - limit_2)
    cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
    cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  elseif value <= limit_2 and value > limit_1 then
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    ratio = value  / limit_2
    cairo_context:line_to(limit_2*width*ratio,y)
    cairo_context:line_to(limit_2*width*ratio,height)
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  elseif value <= limit_1 and value > 0 then
    ratio = value  / limit_1
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
  end
  if graph_line_color then
    r,g,b,a=hexadecimal_to_rgba_percent(graph_line_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:set_line_width(1)

    if value <= 1 and value > limit_2 then
      cairo_context:arc(x +1+ radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = (value - limit_2) / (1 - limit_2)
      cairo_context:arc(width-1 - radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI*1.5, PI *(1.5 +(0.5  * ratio)))
      cairo_context:arc(width-1 - radius*rounded_size,height-1 -  radius*rounded_size, radius*rounded_size,PI*(0.5 - (0.5 * ratio))  , PI * 0.5)
      cairo_context:arc(x+1 + radius*rounded_size,height-1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    elseif value <= limit_2 and value > limit_1 then
      cairo_context:arc(x +1+ radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
      ratio = value  / limit_2
      cairo_context:line_to(limit_2*width*ratio -1 ,y +1)
      cairo_context:line_to(limit_2*width*ratio -1 ,height -1 )
      cairo_context:arc(x +1 + radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cairo_context:arc(x +1 + radius*rounded_size,y +1 + radius*rounded_size, radius*rounded_size,PI, PI * (1+ (0.5*ratio)))
      cairo_context:arc(x +1 + radius*rounded_size,height +1 -  radius*rounded_size, radius*rounded_size,PI*(1-(0.5 * ratio)) , PI * 1)
      cairo_context:close_path()
      cairo_context:stroke()
    end
  end
end

---Draw a foreground rounded corners rectangle which height depends on a value, and a background rounded corners rectangle.
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param x the x coordinate of the left top corner
--@param y the y corrdinate of the left top corner
--@param width the width of the background and the foreground rectangles
--@param height the height of the background rectangle and the maximal height of the foreground rectangle
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param graph_color a string "#rrggbb" or "#rrggbbaa" for the color of the foreground rectangle
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
--@param value_to_represent the percent of the max height used to calculate the height of the foreground rectangle
--@param graph_line_color a string "#rrggbb" or "#rrggbbaa" for the outiline color of the background rectangle
function draw_rounded_corners_vertical_graph(cairo_context,x,y,width, height, background_color, graph_color, rounded_size, value_to_represent, graph_line_color)
--if rounded_size =0 it is a classical rectangle (whooooo!)  
  local height = height
  local width = width
  local x = x
  local y = y
  if rounded_size == nil or rounded_size == 0 then
    --draw the background:
    r,g,b,a=hexadecimal_to_rgba_percent(background_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:move_to(x,y)
    cairo_context:line_to(x,height)
    cairo_context:line_to(width,height)
    cairo_context:line_to(width,y)
    cairo_context:close_path()
    cairo_context:fill()
    --draw the graph:
    r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
    cairo_context:set_source_rgba(r,g,b,a)
    cairo_context:move_to(x,height)
    cairo_context:line_to(x, height -((height -y)* value_to_represent)  )
    cairo_context:line_to(width,height -((height - y)*value_to_represent) )
    cairo_context:line_to(width,height)
    cairo_context:close_path()
    cairo_context:fill()
    if graph_line_color then
      r,g,b,a=hexadecimal_to_rgba_percent(graph_line_color)
      cairo_context:set_source_rgba(r,g,b,a)
      cairo_context:move_to(x,height)
      cairo_context:line_to(x,height -((height -y)* value_to_represent) )
      cairo_context:line_to(width,height -((height -y)*value_to_represent) )
      cairo_context:line_to(width,height)
      cairo_context:close_path()
      cairo_context:set_line_width(1)
      cairo_context:stroke()
    end
  else
    local rounded_size = rounded_size or 0.4
    if height > width then
      radius=0.5 * width
    else
      radius=0.5 * height
    end

    PI = 2*math.asin(1)
    --draw the background
    r,g,b,a=hexadecimal_to_rgba_percent(background_color)
    cairo_context:set_source_rgba(r,g,b,a)
    --top left corner
    cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * 1.5)
    --top right corner
    cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*1.5, PI * 2)
    --bottom right corner
    cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0, PI * 0.5)
    --bottom left corner
    cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
    cairo_context:close_path()
    cairo_context:fill()
    --represent the value
    -- value in 0 -> 1
    --  radius*rounded_size |  height - 2*( radius*rounded) | radius * rounded_size
    --                  |               |                         |
    --                  |           ____|  _______________________|
    --                  |_______   |      |     
    --                   ___    |  |      |
    --                  /___\ <-   |      |
    --                 |     |     |      |
    --                 |     |<----       |
    --                 |_____|            |
    --                  \___/<------------
    --
    --1 => height/ height
    --limit_2 => height -radius / height
    --limit_1 => radius /height
    value = value_to_represent
    limit_2 = (height -(radius * rounded_size)) / height
    limit_1 = radius* rounded_size /height
    --dbg({value, limit_2, limit_1})
    r,g,b,a=hexadecimal_to_rgba_percent(graph_color)
    cairo_context:set_source_rgba(r,g,b,a)
 
    if value <= 1 and value > limit_2 then
      ratio = (value - limit_2) / (1 - limit_2)
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:arc(x + radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
      cairo_context:arc(width - radius*rounded_size,y + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
      cairo_context:close_path()
      cairo_context:fill()
    elseif value <= limit_2 and value > limit_1 then
      ratio = value  / limit_2
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:line_to(x,y + height - (height * ratio*limit_2) )
      cairo_context:line_to(width,y+ height - (height * ratio*limit_2) )
      cairo_context:close_path()
      cairo_context:fill()

    elseif value <= limit_1 and value > 0 then
      ratio = value  / limit_1
      cairo_context:arc(width - radius*rounded_size,height -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
      cairo_context:arc(x + radius*rounded_size,height - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
      cairo_context:close_path()
      cairo_context:fill()
    end
    if graph_line_color then
      r,g,b,a=hexadecimal_to_rgba_percent(graph_line_color)
      cairo_context:set_source_rgba(r,g,b,a)
      cairo_context:set_line_width(1)
      if value <= 1 and value > limit_2 then
        ratio = (value - limit_2) / (1 - limit_2)
        cairo_context:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cairo_context:arc(x+1 + radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
        cairo_context:arc(x+1 + radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI, PI * (1+(0.5* ratio)) )
        cairo_context:arc(width -1 - radius*rounded_size,y+1 + radius*rounded_size, radius*rounded_size,PI*(2 -(0.5* ratio)), PI *2)
        cairo_context:close_path()
        cairo_context:stroke()
      elseif value <= limit_2 and value > limit_1 then
        ratio = value  / limit_2
        cairo_context:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*0  , PI * 0.5)
        cairo_context:arc(x+1 + radius*rounded_size,height -1 - radius*rounded_size, radius*rounded_size,PI*0.5, PI * 1)
      cairo_context:line_to(x +1 ,y +1 + height - (height * ratio*limit_2) )
      cairo_context:line_to(width - 1,y +1 + height - (height * ratio*limit_2) )
      cairo_context:close_path()
      cairo_context:stroke()
      elseif value <= limit_1 and value > 0 then
        ratio = value  / limit_1
        cairo_context:arc(width -1 - radius*rounded_size,height -1 -  radius*rounded_size, radius*rounded_size,PI*(0.5-( 0.5*ratio))  , PI * 0.5)
        cairo_context:arc(x +1 + radius*rounded_size,height -1 - radius*rounded_size, radius*rounded_size,PI*0.5, PI *(0.5+ (0.5*ratio)))
        cairo_context:close_path()
        cairo_context:stroke()
      end
    end
  end
end

---Generate a text in front of a centered rectangle with rounded corners (or not).
--It returns a table ={ width = the width of the image, height = the height of the image, raw_image= the image in a raw format}
--@param cairo_context a cairo context already initialised with oocairo.context_create( )
--@param padding the left/right/top/bottom padding used to center the text in the background rectangle
--@param background_color a string "#rrggbb" or "#rrggbbaa" for the color of the background rectangle
--@param text_color a string "#rrggbb" or "#rrggbbaa" for the color of the text
--@param font_size define the size of the font
--@param rounded_size a float value from 0 to 1 (0 is no rounded corner)
function generate_rounded_rectangle_with_text_in_image(text, padding, background_color, text_color, font_size, rounded_size)
  local data={}
  local padding = padding or 2
  --find the height and width of the image:
  local cairo_surface=cairo.image_surface_create("argb32",20, 20)
  local cr = cairo.context_create(cairo_surface)
  cr:set_font_size(font_size)
  local ext = cr:text_extents(text)
  data.height = font_size + 2* padding
  data.width = ext.width +ext.x_bearing*2 + 2*padding
  
  --recreate the cairo context with good width and height:
  cairo_surface= nil
  cr=nil
  cairo_surface=cairo.image_surface_create("argb32",data.width, data.height)
  cr = cairo.context_create(cairo_surface)

  --draw the background
  draw_rounded_corners_rectangle(cr,0,0,data.width, data.height, background_color, rounded_size)
  
  --draw the text
  cr:move_to(padding, data.height - padding)
  r,g,b,a=hexadecimal_to_rgba_percent(text_color)
  cr:set_font_size(font_size)
  cr:set_source_rgba(r,g,b,a)
  cr:show_text(text)
  
  data.raw_image = cairo_surface:get_data()
  return data
end
--Remove an element from  a table using key.
--@param hash the table
--@param key the key to remove
function hash_remove(hash,key)
  local element = hash[key]
  hash[key] = nil
  return element
end

--Functions for date and calendar
local function is_leap_year(year)
  return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local days_in_m = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
---Get the number of days in a given month of a year.
--iT returns a number
--@param month the month we focus on ( 1 to 12 )
--@param year a number YYYY used to check if it's a leap year.
function get_days_in_month(month, year)
  if month == 2 and is_leap_year(year) then
    return 29
  else
    return days_in_m[month]
  end
end

---Find the weeks numbers of a given month.
--Week begin on monday
--http://fr.wikipedia.org/wiki/ISO_8601
-- find the week number of a date:
--1 find the day number (in the year) of the thursday of the same week of our date
--2 find the week day of the 04 january of the year of our date
--3 find the number of days between the 04-01 and the first monday before this date
--4 find the number of days between the 04-01 and the date we focus on
--5 add the two last value, add 3 and divide by 7
--First it checks the number of the first week of a month and then it calculate the next six weeks numbers. The value returned is a table of six number.
--@param month the month
--@param the year
function get_ISO8601_weeks_number_of_month(month,year)

  --the date we focus on
  local my_day=1
  local my_year = year
  local my_month = month 
  local day=my_day
  local year=my_year
  local month=my_month
  local w_day =os.date('*t', os.time{year=year,month=month, day=day})['wday']
  local thursday=5
--define nb days in month
  if is_leap_year(year) then
    days_in_m[2] = 29
  end

--1
  local closer_thursday = {}
  local difference=0

  if w_day ~= thursday then
    difference= thursday - w_day
    if difference > 0 then
      for i=1, difference do
        if day == days_in_m[month] then
          day=1
          month=month + 1
        else
          day = day +1
        end
      end
      closer_thursday = os.date('*t', os.time{year=year,month=month, day=day})
    else
      for i=1, math.abs(difference) do
        if day == 1 then
          month=month -1 
          day=days_in_m[month]
        else
          day = day -1
        end
      end
      closer_thursday = os.date('*t', os.time{year=year,month=month, day=day})
    end
  else
    closer_thursday = os.date('*t', os.time{year=year,month=month, day=day})
  end 
--2 find the week day of the 04 january of the year of our date
  local fourth_january=os.date('*t', os.time{year=year,month=01, day=04})
  local monday = 2
--3 find the number of days between the 04-01 and the first monday before this date
  local difference_one= monday - fourth_january.wday  
  if difference_one > 0 then
    difference_one = 7 - difference_one 
  else
    difference_one = difference_one*(-1)
  end
--4 find the number of days between the 04-01 and the date we focus on
  local difference_two=closer_thursday.yday - fourth_january.yday
--5 add the two last value, add 3 and divide by 7
  local current_week= (difference_two +3 + difference_one +1) / 7
  local weeks ={ current_week, current_week +1, current_week +2, current_week + 3, current_week + 4, current_week +5}
  return weeks
end
