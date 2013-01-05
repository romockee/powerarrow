local helpers =require("blingbling.helpers")
local string = require("string")
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type=type
local cairo = require "oocairo"
local capi = { image = image, widget = widget, timer=timer }
local layout = require("awful.widget.layout")
---Not ready for now --
module("blingbling.clock")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin","h_margin", "background_color", "filled", "filled_color", "tiles", "tiles_color", "c_graph_color", "c_graph_line_color", "show_text", "text_color", "background_text_color" ,"label", "font_size"}

local function update(c_graph)
  
  local c_graph_surface=cairo.image_surface_create("argb32",data[c_graph].width, data[c_graph].height)
  local c_graph_context = cairo.context_create(c_graph_surface)
  
  local v_margin = 2 
  if data[c_graph].v_margin then 
    v_margin = data[c_graph].v_margin 
  end
  local h_margin = 0
  if data[c_graph].h_margin and data[c_graph].h_margin <= data[c_graph].width / 3 then 
    h_margin = data[c_graph].h_margin 
  end

--Generate Background (background widget)
  if data[c_graph].background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[c_graph].background_color)
    --helpers.dbg({r,g,b,a})
    c_graph_context:set_source_rgba(r,g,b,a)
    c_graph_context:paint()
  end
  
  
  --Draw nothing, tiles (default) or c_graph background (filled) 
  data[c_graph].filled = true
  if data[c_graph].filled  == true then
    --fill the c_graph background
    c_graph_context:rectangle(h_margin,v_margin, data[c_graph].width - (2*h_margin), data[c_graph].height - (2* v_margin))

   -- if data[c_graph].filled_color then
   --       r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[c_graph].filled_color)
   --       c_graph_context:set_source_rgba(r, g, b,a)
   -- else
   --       c_graph_context:set_source_rgba(0, 0, 0,1)
   -- end
    --c_graph_context:LinearGradient(0.25, 0.35, 0.75, 0.65)
    gradient=cairo.pattern_create_linear (data[c_graph].width/2, 0, data[c_graph].width/2, data[c_graph].height - (0))
    gradient:add_color_stop_rgba(0,  0, 0, 0, 0.5)
    gradient:add_color_stop_rgba(0.5,  0, 0, 0, 0)
    gradient:add_color_stop_rgba(1,  0, 0, 0, 0.5)
    c_graph_context:set_source(gradient)
    c_graph_context:fill()
  elseif data[c_graph].filled ~= true and data[c_graph].tiles== false then
      --draw nothing
      else
      --draw tiles
        if data[c_graph].tiles_color then
          r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[c_graph].tiles_color)
          c_graph_context:set_source_rgba(r, g, b,a)
        else
          c_graph_context:set_source_rgba(0, 0, 0,0.5)
        end
		helpers.draw_background_tiles(c_graph_context, data[c_graph].height, v_margin, data[c_graph].width ,h_margin )
        c_graph_context:fill()
  end
  data[c_graph].show_text =true
  if data[c_graph].show_text == true then
  --Draw Text and it's background
    if data[c_graph].font_size == nil then
      data[c_graph].font_size = 9
    end
    c_graph_context:set_font_size(data[c_graph].font_size)
    
    if data[c_graph].background_text_color == nil then
     data[c_graph].background_text_color = "#00000000" 
    end
    if data[c_graph].text_color == nil then
     data[c_graph].text_color = "#7fb219" 
    end    
    
    --local value = data[c_graph].values[1] * 100
    if data[c_graph].label then
      text=string.gsub(data[c_graph].label,"$percent", value)
    else
      text="  22:15  "
    end

    helpers.draw_text_and_background(c_graph_context, 
                                        text, 
                                        h_margin, 
                                        (data[c_graph].height/2) + (data[c_graph].font_size)/2, 
                                        data[c_graph].background_text_color, 
                                        data[c_graph].text_color,
                                        false,
                                        false)
  end
  c_graph.widget.image = capi.image.argb32(data[c_graph].width, data[c_graph].height, c_graph_surface:get_data())
end

local function update_clock(c_graph)
  if not c_graph then return end
  data[c_graph].clock_timer=capi.timer({timeout = 1})
  data[c_graph].clock_timer:add_signal("timeout", function() 
    update(c_graph)
  end)
  data[c_graph].clock_timer:start()
  return c_graph
end

function set_height(c_graph, height)
    if height >= 5 then
        data[c_graph].height = height
        update(c_graph)
    end
    return c_graph
end

function set_width(c_graph, width)
    if width >= 5 then
        data[c_graph].width = width
        update(c_graph)
    end
    return c_graph
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(c_graph, value)
            data[c_graph][prop] = value
            update(c_graph)
            return c_graph
        end
    end
end

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local c_graph = {}
    c_graph.widget = capi.widget(args)
    c_graph.widget.resize = false

    data[c_graph] = { width = width, height = height, values = {} }

    -- Set methods

    for _, prop in ipairs(properties) do
        c_graph["set_" .. prop] = _M["set_" .. prop]
    end

    c_graph.layout = args.layout or layout.horizontal.leftright
    update_clock(c_graph)
    return c_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
