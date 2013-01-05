    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
--{{  Awesome Powerarrow theme by Rom Ockee - based on Awesome Zenburn and Need_Aspirin themes }}---
    --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

green = "#7fb219"
cyan  = "#7f4de6"
red   = "#e04613"
lblue = "#6c9eab"
dblue = "#00ccff"
black = "#3f3f3f"
lgrey = "#d2d2d2"
dgrey = "#333333"
white = "#ffffff"

theme = {}

theme.wallpaper_cmd = { "awsetbg /home/rom/.config/awesome/themes/powerarrow/wallpapers/wallpaper-2552963.jpg" }

theme.font                                  = "Terminus 9"
theme.fg_normal                             = "#AAAAAA"
theme.fg_focus                              = "#F0DFAF"
theme.fg_urgent                             = "#CC9393"
theme.bg_normal                             = "#222222"
theme.bg_focus                              = "#1E2320"
theme.bg_urgent                             = "#3F3F3F"
theme.border_width                          = "0"
theme.border_normal                         = "#3F3F3F"
theme.border_focus                          = "#6F6F6F"
theme.border_marked                         = "#CC9393"
theme.titlebar_bg_focus                     = "#3F3F3F"
theme.titlebar_bg_normal                    = "#3F3F3F"
theme.binclock_bg                           = "#777e76"
theme.binclock_fga                          = "#CCCCCC"
theme.binclock_fgi                          = "#444444"
-- theme.taglist_bg_focus                      = black 
theme.taglist_fg_focus                      = dblue
theme.tasklist_bg_focus                     = "#222222" 
theme.tasklist_fg_focus                     = dblue
theme.textbox_widget_as_label_font_color    = white 
theme.textbox_widget_margin_top             = 1
theme.text_font_color_1                     = green
theme.text_font_color_2                     = dblue
theme.text_font_color_3                     = white
theme.notify_font_color_1                   = green
theme.notify_font_color_2                   = dblue
theme.notify_font_color_3                   = black
theme.notify_font_color_4                   = white
theme.notify_font                           = "Monaco 7"
theme.notify_fg                             = theme.fg_normal
theme.notify_bg                             = theme.bg_normal
theme.notify_border                         = theme.border_focus
theme.awful_widget_bckgrd_color             = dgrey
theme.awful_widget_border_color             = dgrey
theme.awful_widget_color                    = dblue
theme.awful_widget_gradien_color_1          = orange
theme.awful_widget_gradien_color_2          = orange
theme.awful_widget_gradien_color_3          = orange
theme.awful_widget_height                   = 14
theme.awful_widget_margin_top               = 2

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- Example:
-- theme.taglist_bg_focus = "#CC9393"
-- }}}

-- {{{ Widgets
-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
-- theme.fg_widget        = "#AECF96"
-- theme.fg_center_widget = "#88A175"
-- theme.fg_end_widget    = "#FF5656"
-- theme.bg_widget        = "#494B4F"
-- theme.border_widget    = "#3F3F3F"

theme.mouse_finder_color = "#CC9393"
-- mouse_finder_[timeout|animate_timeout|radius|factor]

-- theme.menu_bg_normal    = ""
-- theme.menu_bg_focus     = ""
-- theme.menu_fg_normal    = ""
-- theme.menu_fg_focus     = ""
-- theme.menu_border_color = ""
-- theme.menu_border_width = ""
theme.menu_height       = "16"
theme.menu_width        = "140"

--{{--- Theme icons ------------------------------------------------------------------------------------------

theme.awesome_icon                              = themes_dir .. "/powerarrow/icons/powerarrow/awesome-icon.png"
theme.clear_icon                                = themes_dir .. "/powerarrow/icons/powerarrow/clear.png"
-- theme.clear_icon                                = themes_dir .. "/powerarrow/icons/powerarrow/llauncher.png"
theme.menu_submenu_icon                         = themes_dir .. "/powerarrow/icons/powerarrow/submenu.png"
theme.tasklist_floating_icon                    = themes_dir .. "/powerarrow/icons/powerarrow/floatingm.png"
theme.titlebar_close_button_focus               = themes_dir .. "/powerarrow/icons/powerarrow/close_focus.png"
theme.titlebar_close_button_normal              = themes_dir .. "/powerarrow/icons/powerarrow/close_normal.png"
theme.titlebar_ontop_button_focus_active        = themes_dir .. "/powerarrow/icons/powerarrow/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = themes_dir .. "/powerarrow/icons/powerarrow/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = themes_dir .. "/powerarrow/icons/powerarrow/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = themes_dir .. "/powerarrow/icons/powerarrow/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = themes_dir .. "/powerarrow/icons/powerarrow/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = themes_dir .. "/powerarrow/icons/powerarrow/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = themes_dir .. "/powerarrow/icons/powerarrow/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = themes_dir .. "/powerarrow/icons/powerarrow/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = themes_dir .. "/powerarrow/icons/powerarrow/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = themes_dir .. "/powerarrow/icons/powerarrow/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = themes_dir .. "/powerarrow/icons/powerarrow/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = themes_dir .. "/powerarrow/icons/powerarrow/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = themes_dir .. "/powerarrow/icons/powerarrow/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = themes_dir .. "/powerarrow/icons/powerarrow/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = themes_dir .. "/powerarrow/icons/powerarrow/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = themes_dir .. "/powerarrow/icons/powerarrow/maximized_normal_inactive.png"
theme.taglist_squares_sel                       = themes_dir .. "/powerarrow/icons/powerarrow/square_sel.png"
theme.taglist_squares_unsel                     = themes_dir .. "/powerarrow/icons/powerarrow/square_unsel.png"
theme.layout_floating                           = themes_dir .. "/powerarrow/icons/powerarrow/floating.png"
theme.layout_tile                               = themes_dir .. "/powerarrow/icons/powerarrow/tile.png"
theme.layout_tileleft                           = themes_dir .. "/powerarrow/icons/powerarrow/tileleft.png"
theme.layout_tilebottom                         = themes_dir .. "/powerarrow/icons/powerarrow/tilebottom.png"
theme.layout_tiletop                            = themes_dir .. "/powerarrow/icons/powerarrow/tiletop.png"
theme.widget_battery                            = themes_dir .. "/powerarrow/icons/powerarrow/battery.png"
theme.widget_mem                                = themes_dir .. "/powerarrow/icons/powerarrow/mem.png"
theme.widget_cpu                                = themes_dir .. "/powerarrow/icons/powerarrow/cpu.png"
theme.widget_temp                               = themes_dir .. "/powerarrow/icons/powerarrow/temp.png"
theme.widget_net                                = themes_dir .. "/powerarrow/icons/powerarrow/net.png"
theme.widget_hdd                                = themes_dir .. "/powerarrow/icons/powerarrow/hdd.png"
theme.widget_music                              = themes_dir .. "/powerarrow/icons/powerarrow/music.png"
theme.widget_task                               = themes_dir .. "/powerarrow/icons/powerarrow/task.png"
theme.widget_mail                               = themes_dir .. "/powerarrow/icons/powerarrow/mail.png"
theme.arr1                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr1.png"
theme.arr2                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr2.png"
theme.arr3                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr3.png"
theme.arr4                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr4.png"
theme.arr5                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr5.png"
theme.arr6                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr6.png"
theme.arr7                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr7.png"
theme.arr8                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr8.png"
theme.arr9                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr9.png"
theme.arr0                                      = themes_dir .. "/powerarrow/icons/powerarrow/arr0.png"

--{{--- User icons ------------------------------------------------------------------------------------------

theme.goldendict_icon           = themes_dir .. "/powerarrow/icons/goldendict.png"
theme.books_icon                = themes_dir .. "/powerarrow/icons/books_brown.png"
theme.xfe_icon                  = themes_dir .. "/powerarrow/icons/xfe.png"
theme.xferoot_icon              = themes_dir .. "/powerarrow/icons/xfe-root.png"
theme.htop_icon                 = themes_dir .. "/powerarrow/icons/activity_monitor.png"
theme.audacious_icon            = themes_dir .. "/powerarrow/icons/audacious.png"
theme.deadbeef_icon             = themes_dir .. "/powerarrow/icons/deadbeef.png"
theme.vlc_icon                  = themes_dir .. "/powerarrow/icons/vlc.png"
theme.xfburn_icon               = themes_dir .. "/powerarrow/icons/xfburn.png"
theme.myedu_icon                = themes_dir .. "/powerarrow/icons/nucleus24.png"
theme.ideaCE_icon               = themes_dir .. "/powerarrow/icons/ideaCE.png"
theme.ideaUE_icon               = themes_dir .. "/powerarrow/icons/ideaUE.png"
theme.pycharm_icon              = themes_dir .. "/powerarrow/icons/PyCharm_16.png"
theme.emacs_icon                = themes_dir .. "/powerarrow/icons/emacs.png"
theme.sublime_icon              = themes_dir .. "/powerarrow/icons/SublimeText2old.png"
theme.eclipse_icon              = themes_dir .. "/powerarrow/icons/eclipse.png"
theme.galculator_icon           = themes_dir .. "/powerarrow/icons/accessories-calculator.png"
theme.spacefm_icon              = themes_dir .. "/powerarrow/icons/file-manager.png"
theme.gedit_icon                = themes_dir .. "/powerarrow/icons/text-editor.png"
theme.terminal_icon             = themes_dir .. "/powerarrow/icons/gnome-terminal.png"
theme.terminalroot_icon         = themes_dir .. "/powerarrow/icons/gksu-root-terminal.png"
theme.system_icon               = themes_dir .. "/powerarrow/icons/processor.png"
theme.android_icon              = themes_dir .. "/powerarrow/icons/android_hdpi.png"
theme.gcolor_icon               = themes_dir .. "/powerarrow/icons/icon.png"
theme.gimp_icon                 = themes_dir .. "/powerarrow/icons/gimp.png"
theme.inkscape_icon             = themes_dir .. "/powerarrow/icons/inkscape.png"
theme.recordmydesktop_icon      = themes_dir .. "/powerarrow/icons/gtk-recordmydesktop.png"
theme.screengrab_icon           = themes_dir .. "/powerarrow/icons/screengrab.png"
theme.xmag_icon                 = themes_dir .. "/powerarrow/icons/xmag.png"
theme.mydevmenu_icon            = themes_dir .. "/powerarrow/icons/safety_helmet.png"
theme.mymultimediamenu_icon     = themes_dir .. "/powerarrow/icons/emblem_multimedia.png"
theme.mygraphicsmenu_icon       = themes_dir .. "/powerarrow/icons/graphics.png"
theme.nvidia_icon               = themes_dir .. "/powerarrow/icons/nvidia-settings.png"
theme.myofficemenu_icon         = themes_dir .. "/powerarrow/icons/applications_office.png"
theme.mytoolsmenu_icon          = themes_dir .. "/powerarrow/icons/tool_box.png"
theme.mywebmenu_icon            = themes_dir .. "/powerarrow/icons/web.png"
theme.mysettingsmenu_icon       = themes_dir .. "/powerarrow/icons/hammer_screwdriver.png"
-- theme.celestia_icon           = themes_dir .. "/powerarrow/icons/celestia.png"
-- theme.geogebra_icon           = themes_dir .. "/powerarrow/icons/geogebra.png"
theme.rosetta_icon              = themes_dir .. "/powerarrow/icons/rosetta.png"
theme.stellarium_icon           = themes_dir .. "/powerarrow/icons/stellarium.png"
theme.mathematica_icon          = themes_dir .. "/powerarrow/icons/Mathematica_Icon.png"
theme.acroread_icon             = themes_dir .. "/powerarrow/icons/acroread.png"
theme.djview_icon               = themes_dir .. "/powerarrow/icons/djvulibre-djview4.png"
theme.kchmviewer_icon           = themes_dir .. "/powerarrow/icons/kchmviewer.png"
theme.leafpad_icon              = themes_dir .. "/powerarrow/icons/leafpad.png"
theme.librebase_icon            = themes_dir .. "/powerarrow/icons/libreoffice-base.png"
theme.librecalc_icon            = themes_dir .. "/powerarrow/icons/libreoffice-calc.png"
theme.libredraw_icon            = themes_dir .. "/powerarrow/icons/libreoffice-draw.png"
theme.libreimpress_icon         = themes_dir .. "/powerarrow/icons/libreoffice-impress.png"
theme.libremath_icon            = themes_dir .. "/powerarrow/icons/libreoffice-math.png"
theme.librewriter_icon          = themes_dir .. "/powerarrow/icons/libreoffice-writer.png"
theme.gparted_icon              = themes_dir .. "/powerarrow/icons/gparted.png"
theme.peazip_icon               = themes_dir .. "/powerarrow/icons/PeaZip.png"
theme.teamviewer_icon           = themes_dir .. "/powerarrow/icons/teamview.png"
theme.virtualbox_icon           = themes_dir .. "/powerarrow/icons/virtualbox.png"
-- theme.vmware_icon             = themes_dir .. "/powerarrow/icons/vmware-workstation.png"
theme.unetbootin_icon           = themes_dir .. "/powerarrow/icons/unetbootin.png"
theme.cups_icon                 = themes_dir .. "/powerarrow/icons/cupsprinter.png"
theme.java_icon                 = themes_dir .. "/powerarrow/icons/sun_java.png"
theme.qt_icon                   = themes_dir .. "/powerarrow/icons/qtassistant.png"
theme.filezilla_icon            = themes_dir .. "/powerarrow/icons/filezilla.png"
theme.firefox_icon              = themes_dir .. "/powerarrow/icons/firefox.png"
theme.thunderbird_icon          = themes_dir .. "/powerarrow/icons/thunderbird.png"
theme.luakit_icon               = themes_dir .. "/powerarrow/icons/luakit.png"
theme.gajim_icon                = themes_dir .. "/powerarrow/icons/gajim.png"
theme.skype_icon                = themes_dir .. "/powerarrow/icons/skype.png"
theme.vidalia_icon              = themes_dir .. "/powerarrow/icons/vidalia_icon.png"
theme.weechat_icon              = themes_dir .. "/powerarrow/icons/weechat.png"
theme.meld_icon                 = themes_dir .. "/powerarrow/icons/meld.png"
theme.umplayer_icon             = themes_dir .. "/powerarrow/icons/umplayer.png"
theme.qalculate_icon            = themes_dir .. "/powerarrow/icons/qalculate.png"
theme.wicd_icon                 = themes_dir .. "/powerarrow/icons/wicd.png"
theme.opera_icon                = themes_dir .. "/powerarrow/icons/opera.png"
theme.qtcreator_icon            = themes_dir .. "/powerarrow/icons/qtcreator.png"
theme.florence_icon             = themes_dir .. "/powerarrow/icons/keyboard.png"
theme.texworks_icon             = themes_dir .. "/powerarrow/icons/TeXworks.png"
theme.vym_icon                  = themes_dir .. "/powerarrow/icons/vym.png"
theme.wmsmixer_icon             = themes_dir .. "/powerarrow/icons/wmsmixer.png"
theme.cherrytree_icon           = themes_dir .. "/powerarrow/icons/cherrytree.png"
theme.scantailor_icon           = themes_dir .. "/powerarrow/icons/scantailor.png"
theme.gucharmap_icon            = themes_dir .. "/powerarrow/icons/gucharmap.png"
theme.sigil_icon                = themes_dir .. "/powerarrow/icons/sigil.png"
theme.dwb_icon                  = themes_dir .. "/powerarrow/icons/dwb.png"
theme.qpdfview_icon             = themes_dir .. "/powerarrow/icons/qpdfview.png"
theme.ghex_icon                 = themes_dir .. "/powerarrow/icons/ghex.png"
theme.qtlinguist_icon           = themes_dir .. "/powerarrow/icons/linguist.png"
theme.xfw_icon                  = themes_dir .. "/powerarrow/icons/xfw.xpm"
theme.free42_icon               = themes_dir .. "/powerarrow/icons/free42.png"
theme.fontypython_icon          = themes_dir .. "/powerarrow/icons/fontypython.png"
theme.windows_icon              = themes_dir .. "/powerarrow/icons/windows.png"
theme.tinymount_icon            = themes_dir .. "/powerarrow/icons/tinymount.png"
theme.pgadmin3_icon             = themes_dir .. "/powerarrow/icons/pgadmin3.png"
theme.chromium_icon             = themes_dir .. "/powerarrow/icons/chromium.png"
theme.dropbox_icon              = themes_dir .. "/powerarrow/icons/dropbox.png"
theme.gpick_icon                = themes_dir .. "/powerarrow/icons/gpick.png"
theme.projects_icon             = themes_dir .. "/powerarrow/icons/projects.png"
theme.qbittorrent_icon          = themes_dir .. "/powerarrow/icons/qbittorrent.png"
theme.tkdiff_icon               = themes_dir .. "/powerarrow/icons/tkdiff.png"
theme.kdiff3_icon               = themes_dir .. "/powerarrow/icons/kdiff3.png"
theme.rubymine_icon             = themes_dir .. "/powerarrow/icons/rubymine.png"
theme.multiplemonitors_icon     = themes_dir .. "/powerarrow/icons/multiple_monitors.png"
theme.xnview_icon               = themes_dir .. "/powerarrow/icons/xnview_2.png"
theme.mystuffmenu_icon          = themes_dir .. "/powerarrow/icons/creative_suite.png"
theme.assembler_icon            = themes_dir .. "/powerarrow/icons/assembler_icon.png"
theme.dlang_icon                = themes_dir .. "/powerarrow/icons/dlang.png"
theme.erlang_icon               = themes_dir .. "/powerarrow/icons/erlang.png"
theme.databases_icon            = themes_dir .. "/powerarrow/icons/databases.png"
theme.ruby_icon                 = themes_dir .. "/powerarrow/icons/ruby.png"
theme.linux_icon                = themes_dir .. "/powerarrow/icons/linux.png"
theme.html_icon                 = themes_dir .. "/powerarrow/icons/html.png"
theme.androidmobile_icon        = themes_dir .. "/powerarrow/icons/android.png"
theme.quiterss_icon             = themes_dir .. "/powerarrow/icons/quiterss.png"
theme.anki_icon                 = themes_dir .. "/powerarrow/icons/anki.png"
theme.binclock_bgicon           = themes_dir .. "/powerarrow/icons/transbinclock.png"
theme.task_icon                 = themes_dir .. "/powerarrow/icons/task.png"
theme.task_done_icon            = themes_dir .. "/powerarrow/icons/task_done.png"
theme.project_icon              = themes_dir .. "/powerarrow/icons/project.png"
theme.udisks_glue               = themes_dir .. "/powerarrow/icons/usb10.png"
theme.usb                       = themes_dir .. "/powerarrow/icons/usb.png"
theme.calendar_icon             = themes_dir .. "/powerarrow/icons/calendar4.png"
theme.cdrom                     = themes_dir .. "/powerarrow/icons/disc.png"
theme.docsmenu_icon             = themes_dir .. "/powerarrow/icons/docsmenu.png"
theme.xmind_icon                = themes_dir .. "/powerarrow/icons/xmind.png"
theme.c_icon                    = themes_dir .. "/powerarrow/icons/text-x-c.png"
theme.js_icon                   = themes_dir .. "/powerarrow/icons/text-x-javascript.png"
theme.py_icon                   = themes_dir .. "/powerarrow/icons/text-x-python.png"
theme.learning_icon             = themes_dir .. "/powerarrow/icons/add.png"
theme.cpp_icon                  = themes_dir .. "/powerarrow/icons/text-x-c++.png"
theme.markup_icon               = themes_dir .. "/powerarrow/icons/text-xml.png"

--{{----------------------------------------------------------------------------

return theme


