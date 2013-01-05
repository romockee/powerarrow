local helpers = require("blingbling.helpers")
local awful = require("awful")
local naughty = require("naughty")
local blingbling ={ menu = require("blingbling.menu") }
local string = string
local math = math
local ipairs = ipairs
local next = next
local pairs = pairs
local type = type
local setmetatable = setmetatable
local table = table
local capi = { image = image , widget= widget}
---Task warrior menu
module("blingbling.task_warrior")

local data = setmetatable( {}, { __mode = "k"})

--Get projects list from task warrior
local function get_projects(tw_menu)
  data[tw_menu].projects={}
  local my_projects=awful.util.pread("task projects")
  --remove first line
  my_projects=string.gsub(my_projects,
                          "\nProject%s*Tasks%s*Pri%:None%s*Pri%:L%s*Pri%:M%s*Pri%:H%s*",
                          "")
  --generate the list of projects
  for project, project_tasks in string.gmatch(my_projects,"\n([%w%(%)%-%_%.]*)%s%s+(%d*)","%1 %2") do
    project=string.gsub(project,"\n","")
    table.insert(data[tw_menu].projects, {name =project, nb_tasks = project_tasks} )
  end
end

local function generate_tasks_management_submenu(tw_menu, task_id)
  management_submenu={}
  table.insert(management_submenu,{ "Task "..task_id..": set done", "task " ..task_id.. " done", data[tw_menu].task_done_icon })
 return management_submenu
end
local function get_tasks(tw_menu, project)
  local tasks={}
  if project=="\(none\)" then
    project=""
  end
  local my_tasks=awful.util.pread("task rc.defaultwidth=0 project:\"".. project.."\" minimal")
  --escape specific char ( need to be extend)
  project_pattern=string.gsub(project,"%-","%%%-")
  project_pattern=string.gsub(project_pattern,"%_","%%%_")
  project_pattern=string.gsub(project_pattern,"%.","%%%.")

  --if project == "" then
  --  project_pattern="%s+"
  --end
  each_tasks={}
  each_tasks=helpers.split(my_tasks,"\n")
  for i,v in ipairs(each_tasks) do
    for my_task_id, my_task in string.gmatch(v,"%s*(%d*)%s+"..project_pattern.."%s+(.*)$","%1 %2") do
    table.insert(tasks, {my_task ,generate_tasks_management_submenu(tw_menu,my_task_id),data[tw_menu].task_icon})
    end
  end
  return tasks
end
local function generate_menu(tw_menu)
  my_menu={}
  my_submenu={}
  
  get_projects(tw_menu)
  
  for i,v in ipairs(data[tw_menu].projects) do
    my_submenu=get_tasks(tw_menu,v.name)
    table.insert(my_menu,{v.name .. " (" ..v.nb_tasks ..")", my_submenu, data[tw_menu].project_icon })
  end

  data[tw_menu].menu= blingbling.menu({ items = my_menu })
  return tw_menu 
end

local function display_menu(tw_menu)
  tw_menu.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if data[tw_menu].menu_visible == "false" then
        data[tw_menu].menu_visible = "true"
        generate_menu(tw_menu )
        data[tw_menu].menu:show()
      else
        data[tw_menu].menu:hide()  
        data[tw_menu].menu_visible = "false" 
      end
    end),
    awful.button({ }, 3, function()
        data[tw_menu].menu:hide()  
        data[tw_menu].menu_visible = "false" 
    end)
))
end

--Set the icon for "set task done" action 
--my_tasks:set_task_done_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function set_task_done_icon(tw_menu,an_image)
  data[tw_menu].task_done_icon=an_image
  return tw_menu
end

---Set the icon for project
--my_tasks:set_project_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function set_project_icon(tw_menu,an_image)
  data[tw_menu].project_icon=an_image
  return tw_menu
end

---Set the icon for task
--my_tasks:set_task_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function set_task_icon(tw_menu,an_image)
  data[tw_menu].task_icon=an_image
  return tw_menu
end
---Create new task warrior menu:
--my_tasks=blingbling.task_warrior.new(an_image_file_name)
--@param menu_icon an image file 
--@return tw_menu a task warrior menu
function new(menu_icon)
  local tw_menu={}
  tw_menu.widget=capi.widget({ type = "imagebox"})
  tw_menu.widget.image=capi.image(menu_icon)
  
  tw_menu.image = menu_icon 
  data[tw_menu]={ image = menu_icon, 
                  projects= {},
                  tasks={},
                  menu_visible = "false", 
                  menu={},
                  project_icon = nil,
                  task_icon = nil,
                  task_done_icon=nil,
                  } 
  tw_menu.set_task_done_icon = set_task_done_icon
  tw_menu.set_task_icon = set_task_icon
  tw_menu.set_project_icon = set_project_icon
  generate_menu(tw_menu)
  display_menu(tw_menu)
  return tw_menu 
end
