require("graphics")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviMainFuncs.lua")
dofile(SCRIPT_DIRECTORY .. "Octavi.lua")

local info_string = "Function selected"
OctaviInfoActive = true

function OctaviInfoEventHandler()
  info_string = "Function selected " .. GetOctaviFunctionString(ActiveFunction)
end

do_every_frame("OctaviInfoEventHandler()")

function PrintButtonSnifferSesult()
  if OctaviInfoActive then
    glColor4f(0, 0, 0, 255)
    draw_string_Helvetica_18(50 - 2, SCREEN_HIGHT - 100 - 2, info_string)
    draw_string_Helvetica_18(50 + 2, SCREEN_HIGHT - 100 + 2, info_string)
    draw_string_Helvetica_18(50 + 2, SCREEN_HIGHT - 100 - 2, info_string)
    draw_string_Helvetica_18(50 - 2, SCREEN_HIGHT - 100 + 2, info_string)
    if IsPrimaryMode then
      glColor4f(255, 255, 255, 255)
    else
      glColor4f(0, 255, 255, 255)
    end
    draw_string_Helvetica_18(50, SCREEN_HIGHT - 100, info_string)
  end
end

do_every_draw("PrintButtonSnifferSesult()")
add_macro("Show OCTAVI Info", "OctaviInfoActive = true", "OctaviInfoActive = false", "activate")
