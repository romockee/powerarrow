local capi = { keygrabber = keygrabber, mouse=mouse, screen = screen, image = image} 
local util = require('awful.util') 
local button = require('awful.button') 
local table = table
local type = type
local os = require('os')
local wibox = wibox
local widget = widget
local layout = require('awful.widget.layout')
local string =string
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local helpers = require('blingbling.helpers')
local blingbling = { layout = require('blingbling.layout'), menu = require("blingbling.menu") }
local margins = awful.widget.layout.margins
local setmetatable = setmetatable
local beautiful = require('beautiful')
---A calendar widget
module('blingbling.calendar')

--Define the margin (top, right, bottom, left) in the wibox
--@class function
--@name set_margin
--@param calendar a calendar widget
--@param margin an integer

---Define the margin between all the table cell
--@class function
--@name set_inter_margin
--@param calendar a calendar widget
--@param inter_margin an integer

---Define the color of the common cells in the table
--@class function
--@name set_cell_background_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the padding between the text and the background
--@class function
--@name set_cell_padding
--@param calendar a calendar widget
--@param padding an integer

---Define the size of the rounded corners of the cells
--@class function
--@name set_rounded_size
--@param calendar a calendar widget
--@param rounded_size an integer

---Define the color of the text in common cells
--@class function 
--@name set_text_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the font size in common cells
--@class function
--@name set_font_size
--@param calendar a calendar widget
--@param font_size an integer

---Define the color of the title cells in the table
--@class function
--@name set_title_background_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the color of the text in title cells
--@class function 
--@name set_title_text_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the font size in title cells
--@class function
--@name set_title_font_size
--@param calendar a calendar widget
--@param font_size an integer

---Define the color of the columns and lines titles cells in the table
--@class function
--@name set_columns_lines_titles_background_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the color of the text in columns and lines titles cells
--@class function 
--@name set_columns_lines_titles_text_color
--@param calendar a calendar widget
--@param color a string like "#rrggbbaa" or "#rrggbb"

---Define the font size in title columns and lines cells
--@class function
--@name set_columns_lines_titles_font_size
--@param calendar a calendar widget
--@param font_size an integer

---Link calendar to remind and task warrior in order to get events informations for each day
--@class function
--@name set_link_to_external_calendar
--@param calendar a calendar widget
--@param boolean true or false (false by default)

local data = setmetatable( {}, { __mode = "k"})

local properties = { "width","margin", "inter_margin", "cell_background_color", "cell_padding", "rounded_size", "text_color", "font_size", "title_background_color", "title_text_color", "title_font_size", "columns_lines_titles_background_color", "columns_lines_titles_text_color", "columns_lines_titles_font_size", "link_to_external_calendar"}

menu_keys = { up = { "Up" },
              down = { "Down" },
              exec = { "Return", "Right" },
              back = { "Left" },
              close = { "Escape" } }

--need to add widget selection possibility
--local function grabber(mod, key, event)
--    if event == "release" then
--       return true
--    end

--    local sel = cur_menu.sel or 0
--    if util.table.hasitem(menu_keys.up, key) then
--        local sel_new = sel-1 < 1 and #cur_menu.items or sel-1
--        item_enter(cur_menu, sel_new)
--    elseif util.table.hasitem(menu_keys.down, key) then
--        local sel_new = sel+1 > #cur_menu.items and 1 or sel+1
--        item_enter(cur_menu, sel_new)
--    elseif sel > 0 and util.table.hasitem(menu_keys.exec, key) then
--        exec(cur_menu, sel)
--    elseif util.table.hasitem(menu_keys.back, key) then
--        cur_menu:hide()
--    elseif util.table.hasitem(menu_keys.close, key) then
--        get_parents(cur_menu):hide()
--    else
--        check_access_key(cur_menu, key)
--    end
--   
--    return true
--end
function bind_click_to_toggle_visibility(calendar)
  calendar.widget:buttons(util.table.join(
    button({ }, 1, function()
      if data[calendar].wibox then
        if data[calendar].wibox.visible ~= true then 
          calendar = generate_cal(calendar)
          data[calendar].wibox = calendar.wibox
            add_focus(calendar)
          data[calendar].wibox.visible = true
        else 
          data[calendar].wibox.visible = false
        end
      else
        calendar = generate_cal(calendar)
        data[calendar].wibox = calendar.wibox
            add_focus(calendar)
        data[calendar].wibox.visible= true
      end
      return calendar
    end
    )
))
end

function display_new_month( calendar,month, year)
  
  local month_label = os.date("%B", os.time{year=year, month=month, day=01})
  local padding = data[calendar].cell_padding or 4 
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 2
  
  local columns_lines_titles_background_color = data[calendar].columns_lines_titles_background_color or background_color
  local columns_lines_titles_text_color = data[calendar].columns_lines_titles_text_color or text_color
  local columns_lines_titles_font_size = data[calendar].columns_lines_titles_font_size or font_size
  
  local calendar_title =""
  local month_labels = data[calendar].month_labels
  if data[calendar].calendar_title == nil then
    calendar_title = month_labels[month] .. " " .. year
  else
    calendar_title = string.gsub(data[calendar].calendar_title, "$year", year)
    calendar_title = string.gsub(calendar_title, "$month", month_labels[month])
  end
  
  local cell =helpers.generate_rounded_rectangle_with_text_in_image(calendar_title, 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].displayed_month_year.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
  
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month, year))
  local current_day_of_month= tonumber(os.date("%d")) 
  local current_month = tonumber(os.date("%m"))
  
  local d=os.date('*t',os.time{year=year,month=month,day=01})
  --We use Monday as first day of week
  first_day_of_month = d['wday'] - 1
  if first_day_of_month == 0 then first_day_of_month = 7 end 
  data[calendar].first_day_widget = first_day_of_month
  
  --Update week numbers:
  local weeks_numbers = helpers.get_ISO8601_weeks_number_of_month(month,year)
  for i=1,6 do 
    local cell = helpers.generate_rounded_rectangle_with_text_in_image(weeks_numbers[i], 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    data[calendar].weeks_numbers_widgets[i].image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
  end

  local day_of_month = 0 
  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      data[calendar].days_of_month[i].text = "--"
      data[calendar].days_of_month[i].bg_color = background_color
      data[calendar].days_of_month[i].fg_color = text_color
    end
    if i>= first_day_of_month and i < last_day_of_current_month + first_day_of_month then
      if i == current_day_of_month + first_day_of_month -1 and current_month == month then
        background = beautiful.bg_focus
        color = beautiful.fg_focus
      else  
        background = background_color
        color = text_color
      end
      day_of_month = day_of_month + 1
      --Had 0 before the day if the day is inf to 10
      if day_of_month < 10 then
        day_of_month = "0" .. day_of_month
      else
        day_of_month = day_of_month ..""
      end
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( day_of_month, 
                                                                        padding, 
                                                                        background, 
                                                                        color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      data[calendar].days_of_month[i].text = day_of_month 
      data[calendar].days_of_month[i].bg_color = background
      data[calendar].days_of_month[i].fg_color = color
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      data[calendar].days_of_month[i].text = "--"
      data[calendar].days_of_month[i].bg_color = background_color
      data[calendar].days_of_month[i].fg_color = text_color
    end
  end
end

function see_prev_month(calendar, month, year)
  if month == 1 then
    month = 12 
    year = year -1 
  else
    month = month - 1
  end
  data[calendar].month = month
  data[calendar].year = year
  display_new_month(calendar,month, year)
end
function see_next_month(calendar, month, year)
  if month == 12 then
    month = 1 
    year = year +1 
  else
    month = month + 1
  end
  data[calendar].month = month
  data[calendar].year = year
  display_new_month(calendar,month, year)
end

function generate_cal(calendar)
  --all data that we put in data[calendar] that can be access for  each instance of calendar objetcs:
  --data[calendar].displayed_month_year the widget image for month year title displayed
  --data[calendar].month = the month displayed
  --data[calendar].year = the year displayed
  --data[calendar].days_of_month a table containing the widget of the day of month (empty or not )
  --data[calendar].first_day_widget the number used as start for displaying day in the table data[calendar].days_of_month
  --data[calendar].prev_month widget used to change displayed month to previous month
  --data[calendar].next_month widget used to change displayed month to next month

  local wibox_margin = data[calendar].margin or 2
  local padding = data[calendar].cell_padding or 4 
  local inter_margin = data[calendar].inter_margin or 2
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 2
  local columns_lines_titles_background_color = data[calendar].columns_lines_titles_background_color or background_color
  local columns_lines_titles_text_color = data[calendar].columns_lines_titles_text_color or text_color
  local columns_lines_titles_font_size = data[calendar].columns_lines_titles_font_size or font_size
  --Get screen and position informations
  local current_screen = capi.mouse.screen
  local screen_geometry = capi.screen[current_screen].workarea
  local screen_w = screen_geometry.x + screen_geometry.width
  local screen_h = screen_geometry.y + screen_geometry.height
  local mouse_coords = capi.mouse.coords()
  local all_lines_height = 0
  local max_width = 0 
  --local day_labels = { "Mo", "Tu", "We", "Th", "Fr","Sa" , "Su"}
  local day_labels ={}
  day_labels = data[calendar].day_labels
--  for i=6,12 do 
--    table.insert(day_labels,(os.date("%a",os.time({month=2,day=i,year=2012})))) 
--  end
  --local month_label = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }
  local month_labels = {}
  month_labels = data[calendar].month_labels
--  for i=1,12 do 
--    table.insert(month_label,os.date("%B",os.time({month=i,day=1,year=2012}))) 
--  end
--  if data[calendar].day_labels ~= nil then
--    day_labels = data[calendar].day_labels
--  end
    
  data[calendar].days_of_month={}
  local weeks_of_year={}
  local current_day_of_month= tonumber(os.date("%d")) 
  local month_displayed = tonumber(os.date("%m"))
  local year_displayed = tonumber(os.date("%Y"))
  
  data[calendar].month = month_displayed
  data[calendar].year = year_displayed
  
  local first_day_of_month = 0
  --find the first week day of the month it is the number used as start for displaying day in the table data[calendar].days_of_month
  local d=os.date('*t',os.time{year=year_displayed,month=month_displayed,day=01})
  --We use Monday as first day of week
  first_day_of_month = d['wday'] - 1
  if first_day_of_month == 0 then first_day_of_month = 7 end 
  data[calendar].first_day_widget = first_day_of_month
  
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month_displayed, year_displayed))
  local max_day_cells = 42 
  local day_of_month = 0 
  local day_widgets={}
  local calendar_title =""
  if data[calendar].calendar_title == nil then
    calendar_title = month_labels[month_displayed] .. " " .. year_displayed
  else
    calendar_title = string.gsub(data[calendar].calendar_title, "$year", year_displayed)
    calendar_title = string.gsub(calendar_title, "$month", month_labels[month_displayed])
  end

  --generate title cells with displayed month and year
  local cell_month_year =helpers.generate_rounded_rectangle_with_text_in_image(calendar_title, 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].displayed_month_year= widget({ type ="imagebox", width=cell_month_year.width, height=cell_month_year.height })
  data[calendar].displayed_month_year.image = capi.image.argb32(cell_month_year.width, cell_month_year.height, cell_month_year.raw_image)
  margins[data[calendar].displayed_month_year]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  
  --generate cells for precedent month and next month:
  local cell_prev = helpers.generate_rounded_rectangle_with_text_in_image("<<", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].prev_month= widget({ type ="imagebox", width=cell_prev.width, height=cell_prev.height })
  data[calendar].prev_month.image = capi.image.argb32(cell_prev.width, cell_prev.height, cell_prev.raw_image)
  margins[data[calendar].prev_month]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  --Link action on the widget:
  data[calendar].prev_month:buttons(util.table.join(
       button({ }, 1, function()
        see_prev_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))

  
  local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(">>", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].next_month= widget({ type ="imagebox", width=cell_next.width, height=cell_next.height })
  data[calendar].next_month.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
  margins[data[calendar].next_month]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  --Link action on the widget:
  data[calendar].next_month:buttons(util.table.join(
       button({ }, 1, function()
        see_next_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))
  
  all_lines_height = margins[data[calendar].displayed_month_year].top + margins[data[calendar].displayed_month_year].bottom + cell_month_year.height+ all_lines_height
  max_width = wibox_margin + cell_next.width + cell_prev.width +cell_month_year.width + inter_margin *2 
  --generate cells with day label
  local days_widgets_line_height = 0
  local days_widgets_width = 0
  for i=1,7 do 
    local cell = helpers.generate_rounded_rectangle_with_text_in_image(day_labels[i], 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[cell_widget]={top = inter_margin, bottom = inter_margin + 2}
    table.insert(day_widgets,cell_widget)
    if cell.height + margins[cell_widget].top + margins[cell_widget].bottom > days_widgets_line_height then
      days_widgets_line_height = cell.height+ margins[cell_widget].top + margins[cell_widget].bottom
    end
    days_widgets_width = days_widgets_width + cell.width
  end
    all_lines_height = all_lines_height + days_widgets_line_height
  --generate empty cell (corner of days of week line and weeks of year column
    local cell = helpers.generate_rounded_rectangle_with_text_in_image("__|", 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local corner_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    corner_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[corner_widget]={top = inter_margin, bottom = inter_margin + 2}
    
    days_widgets_width = days_widgets_width + cell.width + 7*inter_margin
    
    if max_width < days_widgets_width then
      max_width = days_widgets_width
    end

  --generate cells for weeks numbers  
  data[calendar].weeks_numbers_widgets={}
  local weeks_numbers = helpers.get_ISO8601_weeks_number_of_month(month_displayed,year_displayed)
  for i=1,6 do 
    local cell = helpers.generate_rounded_rectangle_with_text_in_image(weeks_numbers[i], 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[cell_widget]={top = inter_margin}
    table.insert(data[calendar].weeks_numbers_widgets,cell_widget)
  end

  local classic_cell_height = 0
  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, {text = "--", widget = cell_widget, bg_color = background_color, fg_color = text_color})
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
    end
    if i>= first_day_of_month and i < last_day_of_current_month + first_day_of_month then
      if i == current_day_of_month + first_day_of_month -1 then
        background = beautiful.bg_focus
        color = beautiful.fg_focus
      else  
        background = background_color
        color = text_color
      end
      day_of_month = day_of_month + 1
      --Had 0 before the day if the day is inf to 10
      if day_of_month < 10 then
        day_of_month = "0" .. day_of_month
      else
        day_of_month = day_of_month ..""
      end
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( day_of_month, 
                                                                        padding, 
                                                                        background, 
                                                                        color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height, name=day_of_month })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, {text = day_of_month, widget = cell_widget, bg_color = background, fg_color = color})
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height, name = "--" })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, {text = "--", widget = cell_widget, bg_color = background_color, fg_color = text_color})
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
    end
  end
  all_lines_height =wibox_margin  +all_lines_height + classic_cell_height * 6 
  calendarbox=wibox({height = all_lines_height, width=(data[calendar].width or max_width) })
  calendarbox.widgets={}
  calendarbox.ontop =true

  calendarbox.widgets={
      {data[calendar].prev_month, data[calendar].displayed_month_year, data[calendar].next_month, layout = blingbling.layout.array.line_center },
      {corner_widget, day_widgets[1], day_widgets[2], day_widgets[3], day_widgets[4], 
       day_widgets[5], day_widgets[6], day_widgets[7], layout =blingbling.layout.array.line_center},
      {data[calendar].weeks_numbers_widgets[1], data[calendar].days_of_month[1].widget,data[calendar].days_of_month[2].widget, data[calendar].days_of_month[3].widget, data[calendar].days_of_month[4].widget,
       data[calendar].days_of_month[5].widget,data[calendar].days_of_month[6].widget,data[calendar].days_of_month[7].widget,layout =blingbling.layout.array.line_center}, 
      {data[calendar].weeks_numbers_widgets[2], data[calendar].days_of_month[8].widget,data[calendar].days_of_month[9].widget, data[calendar].days_of_month[10].widget, data[calendar].days_of_month[11].widget,
       data[calendar].days_of_month[12].widget,data[calendar].days_of_month[13].widget,data[calendar].days_of_month[14].widget,layout =blingbling.layout.array.line_center}, 
      {data[calendar].weeks_numbers_widgets[3], data[calendar].days_of_month[15].widget,data[calendar].days_of_month[16].widget, data[calendar].days_of_month[17].widget, data[calendar].days_of_month[18].widget,
       data[calendar].days_of_month[19].widget,data[calendar].days_of_month[20].widget,data[calendar].days_of_month[21].widget,layout =blingbling.layout.array.line_center}, 
      {data[calendar].weeks_numbers_widgets[4], data[calendar].days_of_month[22].widget,data[calendar].days_of_month[23].widget, data[calendar].days_of_month[24].widget, data[calendar].days_of_month[25].widget,
       data[calendar].days_of_month[26].widget,data[calendar].days_of_month[27].widget,data[calendar].days_of_month[28].widget,layout =blingbling.layout.array.line_center}, 
      {data[calendar].weeks_numbers_widgets[5], data[calendar].days_of_month[29].widget,data[calendar].days_of_month[30].widget, data[calendar].days_of_month[31].widget, data[calendar].days_of_month[32].widget,
       data[calendar].days_of_month[33].widget,data[calendar].days_of_month[34].widget,data[calendar].days_of_month[35].widget,layout =blingbling.layout.array.line_center},    
      {data[calendar].weeks_numbers_widgets[6], data[calendar].days_of_month[36].widget,data[calendar].days_of_month[37].widget, data[calendar].days_of_month[38].widget, data[calendar].days_of_month[39].widget,
       data[calendar].days_of_month[40].widget,data[calendar].days_of_month[41].widget,data[calendar].days_of_month[42].widget,layout =blingbling.layout.array.line_center},    
       layout = blingbling.layout.array.stack_lines 
                    }
   
  calendar_top_margin=0
  calendarbox.screen = current_screen

  --set the position of the wibox
  calendarbox.y = mouse_coords.y < screen_geometry.y and screen_geometry.y or mouse_coords.y
  calendarbox.x = mouse_coords.x < screen_geometry.x and screen_geometry.x or mouse_coords.x
  calendarbox.y = calendarbox.y + calendarbox.height > screen_h and screen_h - calendarbox.height or calendarbox.y
  calendarbox.x = calendarbox.x + calendarbox.width > screen_w and screen_w - calendarbox.width or calendarbox.x
  
  calendar.wibox = calendarbox
  return calendar
end


function show_events(calendar,day_label, month, year, function_index)
  local day = tonumber(day_label)
  local month = month
  local year = year

  if function_index == nil then 
    data[calendar].get_events_function_index = 1 
  elseif function_index == 1 and data[calendar].get_events_function_index == #data[calendar].get_events_from then
    data[calendar].get_events_function_index = 1
  elseif function_index == -1 and data[calendar].get_events_function_index == 1 then
    data[calendar].get_events_function_index = #data[calendar].get_events_from 
  else
    data[calendar].get_events_function_index = data[calendar].get_events_function_index + function_index
  end
  
  day_events=data[calendar].get_events_from[data[calendar].get_events_function_index](day,month,year)
  data[calendar].menu_events = blingbling.menu({ items = { {day_events,""}  }})
  data[calendar].menu_events:show()
end
function hide_events(calendar)
  if data[calendar].menu_events ~= nil then
  data[calendar].menu_events:hide()
  data[calendar].menu_events = nil
  end
end
function add_focus(calendar)
  local padding = data[calendar].cell_padding or 4 
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 2
  
  --data[calendar].prev_month widget used to change displayed month to previous month
  data[calendar].prev_month:add_signal("mouse::enter", function()
    local cell_prev = helpers.generate_rounded_rectangle_with_text_in_image("<<", 
                                                                    padding, 
                                                                    beautiful.bg_focus, 
                                                                    beautiful.fg_focus, 
                                                                    title_font_size, 
                                                                    rounded_size)
    data[calendar].prev_month.image = capi.image.argb32(cell_prev.width, cell_prev.height, cell_prev.raw_image)
  end)
  data[calendar].prev_month:add_signal("mouse::leave", function()
    local cell_prev = helpers.generate_rounded_rectangle_with_text_in_image("<<", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
    data[calendar].prev_month.image = capi.image.argb32(cell_prev.width, cell_prev.height, cell_prev.raw_image)
  end)

  --data[calendar].next_month widget used to change displayed month to next month
 data[calendar].next_month:add_signal("mouse::enter", function()
    local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(">>", 
                                                                    padding, 
                                                                    beautiful.bg_focus, 
                                                                    beautiful.fg_focus, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].next_month.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
    
  end)
  data[calendar].next_month:add_signal("mouse::leave", function()
    local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(">>", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
    data[calendar].next_month.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
  end)
  --data[calendar].days_of_month a table containing the widget of the day of month (empty or not )
  --data[calendar].first_day_widget the number used as start for displaying day in the table data[calendar].days_of_month
  if data[calendar].link_to_external_calendar == true then
    for i=1,42 do
        data[calendar].days_of_month[i].widget:add_signal("mouse::enter", function()
          if data[calendar].days_of_month[i].text ~= "--" then
            local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(data[calendar].days_of_month[i].text, 
                                                                    padding, 
                                                                    beautiful.bg_focus, 
                                                                    beautiful.fg_focus, 
                                                                    font_size, 
                                                                    rounded_size)
            data[calendar].days_of_month[i].widget.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
            show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year)
            
            data[calendar].days_of_month[i].widget:buttons(util.table.join(
              button({ }, 4, function()
              hide_events(calendar)
              show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year, 1)
              end),
              button({ }, 5, function()
              hide_events(calendar)
              show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year, (-1))
              end)
            ))
          end
        end)
          
        data[calendar].days_of_month[i].widget:add_signal("mouse::leave", function()
          local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(data[calendar].days_of_month[i].text, 
                                                                    padding, 
                                                                    data[calendar].days_of_month[i].bg_color, 
                                                                    data[calendar].days_of_month[i].fg_color, 
                                                                    font_size, 
                                                                    rounded_size)
          data[calendar].days_of_month[i].widget.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
          hide_events(calendar)
        end)
    end
  end
end

---Modify the label for the days
--@class function
--@name set_day_labels
--@param calendar a calendar widget
--@param your_day_labels a table with seven elements

--function set_day_labels(calendar, your_day_labels )
--  if type(your_day_labels) ~= "table" then
--    data[calendar].day_labels =nil
--  else
--    nb_val = 0
--    for i,v in ipairs(your_day_labels) do
--      nb_val = 1 + nb_val
--    end
--    if nb_val ~= 7 then
--      data[calendar].day_labels =nil
--    else
--      data[calendar].day_labels ={}
--      for i,v in ipairs(your_day_labels) do
--        --check the length for utf-8 string
--        local _,utf8_str_len =string.gsub(v, "[^\128-\193]","")
--        if utf8_str_len >= 2 then
--          --get 2 first utf-8 char and set them in a string
--          local uchar =""
--          local index = 0
--          local utf8_str =""
--          for uchar in string.gfind(v, "([%z\1-\127\194-\244][\128-\191]*)") do
--            index = index + 1
--            if index <= 2 then
--              utf8_str = utf8_str .. uchar 
--            else
--              break
--            end
--          end
--          table.insert(data[calendar].day_labels,utf8_str) 
--        else
--          table.insert(data[calendar].day_labels,v .. " ")
--        end
--      end
--    end
--  end
--end
---Modify the label for the months 
--@class function
--@name set_month_labels
--@param calendar a calendar widget
--@param your_month_labels a table with twelve elements

--function set_month_labels(calendar, your_month_labels )
--  if type(your_month_labels) ~= "table" then
--    data[calendar].month_labels =nil
--  else
--    nb_val = 0
--    for i,v in ipairs(your_month_labels) do
--      nb_val = 1 + nb_val
--    end
--    if nb_val ~= 12 then
--      data[calendar].month_labels =nil
--    else
--      data[calendar].month_labels ={}
--      for i,v in ipairs(your_month_labels) do
--        table.insert(data[calendar].month_labels,v) 
--      end
--    end
--  end
--  return calendar
--end
---Define the format of the calendar
--User can set a string containing $month and $year
--@class function
--@param calendar a calendar widget
--@param your_string a string
function set_calendar_title(calendar, your_string )
  data[calendar].calendar_title =""
  if type(your_string) == "string" and your_string ~= nil then
    data[calendar].calendar_title = your_string
  else
    data[calendar].calendar_title = nil
  end
  return calendar
end

function set_calendar_locale(calendar, your_local)
  os.setlocale(your_local)
  data[calendar].day_labels ={}
  --variable for lenght check --> hungarian abbreviate day name not the same length
  local max_day_lenght=0

  for i=6,12 do 
    table.insert(data[calendar].day_labels,(os.date("%a",os.time({month=2,day=i,year=2012})))) 
    --check the length for utf-8 string
    local _,utf8_str_len =string.gsub(os.date("%a",os.time({month=2,day=i,year=2012})), "[^\128-\193]","")
    if utf8_str_len > max_day_lenght then
      max_day_lenght = utf8_str_len
    end
  end
  --check length and add space at the begining
  for i,v in ipairs(data[calendar].day_labels) do
   local _,utf8_str_len =string.gsub(v, "[^\128-\193]","") 
   local diff = max_day_lenght - utf8_str_len
   if diff ~= 0 then
    data[calendar].day_labels[i]=string.rep(" ",diff) .. v
   end
  end
  data[calendar].month_labels = {}
  for i=1,12 do 
    table.insert(data[calendar].month_labels,os.date("%B",os.time({month=i,day=1,year=2012}))) 
  end
  return calendar
end
-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
         _M["set_" .. prop] = function(calendar, value)
             data[calendar][prop] = value
             bind_click_to_toggle_visibility(calendar)
             return calendar
       end
   end
end

---Add new function in order to get events from external application
--This method let the taskwarrior and remind links intact and add your founction
--@usage my_cal:append_function_get_events_from(function(day, month, year)
--s="third function ".. " " .. day .. " " .. month .." " ..year
--return s
--end)
--This  function display in the menu the string "third function 26 11 2011" for example.
--@param calendar a calendar
--@param my_function a function that you write
function append_function_get_events_from(calendar, my_function)
  table.insert(data[calendar].get_events_from, my_function)
  return calendar
end

---Add new function in order to get events from external application and remove the existing function
--@param calendar a calendar
--@param my_function a function that you write
function clear_and_add_function_get_events_from(calendar, my_function)
  data[calendar].get_events_from={}
  table.insert(data[calendar].get_events_from, my_function)
  return calendar
end

---Create new calendar widget
--@param args a table like {type = "imagebox", image = an image file name} or {type = "textbox", text = a string}
--@return calendar a calendar 
function new(args)
  local args =args or {}
  local calendar={}
  data[calendar]={}
  if  args == nil or args.type == "textbox" then
    calendar.widget=widget({ type = "textbox" })
    calendar.widget.text = args.text or "Calendar"
  elseif args.type == "imagebox" then
    calendar.widget=widget({ type = "imagebox" })
    calendar.widget.image=capi.image(args.image)
  end
  
  data[calendar].day_labels ={}
    --variable for lenght check --> hungarian abbreviate day name not the same length
  local max_day_lenght=0
  for i=6,12 do 
    table.insert(data[calendar].day_labels,(os.date("%a",os.time({month=2,day=i,year=2012})))) 
    --check the length for utf-8 string
    local _,utf8_str_len =string.gsub(os.date("%a",os.time({month=2,day=i,year=2012})), "[^\128-\193]","")
    if utf8_str_len > max_day_lenght then
      max_day_lenght = utf8_str_len
    end
  end
  --check length and add space at the begining
  for i,v in ipairs(data[calendar].day_labels) do
    local _,utf8_str_len =string.gsub(v, "[^\128-\193]","") 
    local diff = max_day_lenght - utf8_str_len
    if diff ~= 0 then
      data[calendar].day_labels[i]=string.rep(" ",diff) .. v
    end
  end
  
  data[calendar].month_labels = {}
  for i=1,12 do 
    table.insert(data[calendar].month_labels,os.date("%B",os.time({month=i,day=1,year=2012}))) 
  end
  
  for _, prop in ipairs(properties) do
    calendar["set_" .. prop] = _M["set_" .. prop]
  end
  data[calendar].link_to_external_calendar = false
  --This table contains the functions to access event from different agenda, can be extended.
  data[calendar].get_events_from={
  --reminds
  function(day,month,year)
  local day_events=util.pread('remind ~/.reminders ' .. day .. " " .. os.date("%B",os.time{year=year,month=month,day=day}) .." " .. year)
  day_events = string.gsub(day_events,"\n\n+","\n")
  day_events  =string.gsub(day_events,"\n*$","")
  day_events="Remind:\n\n" .. day_events
  return day_events
  end,
  --task_warrior
  function(day,month,year)
  local day_events=util.pread('task overdue due:' .. os.date("%m",os.time{year=year,month=month,day=day}) .."/"..day.."/" .. year)
  local day_events = "Task warrior:\n" .. day_events 
  return day_events
  end,
  }
 
  bind_click_to_toggle_visibility(calendar)
  calendar.append_function_get_events_from = append_function_get_events_from
  --calendar.set_day_labels = set_day_labels
  --calendar.set_month_labels = set_month_labels
  calendar.set_calendar_title = set_calendar_title
  calendar.set_calendar_locale =set_calendar_locale
  calendar.clear_and_add_function_get_events_from = clear_and_add_function_get_events_from
  return calendar
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
