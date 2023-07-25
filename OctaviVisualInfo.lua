require("graphics")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviMainFuncs.lua")
dofile(SCRIPT_DIRECTORY .. "Octavi.lua")

local info_string = "Octavi Info"
OctaviInfoActive = true

function OctaviInfoEventHandler()
  if IsOctaviConnected then
    local active_function_string = GetOctaviFunctionString(ActiveFunction)
    if active_function_string == "INIT" then
      info_string = "Octavi initialized - please press a button on OCTAVI to read initial state"
    else
      info_string = "Function selected " .. active_function_string
    end
  else
    info_string =
      "Octavi device not found - please connect the device (or free it if it's in use by another program) and reload this lua script"
  end
end

do_every_frame("OctaviInfoEventHandler()")

function DrawOctaviState()
  if OctaviInfoActive then
    glColor4f(0, 0, 0, 255)
    draw_string_Helvetica_18(50 - 2, SCREEN_HIGHT - 100 - 2, info_string)
    draw_string_Helvetica_18(50 + 2, SCREEN_HIGHT - 100 + 2, info_string)
    draw_string_Helvetica_18(50 + 2, SCREEN_HIGHT - 100 - 2, info_string)
    draw_string_Helvetica_18(50 - 2, SCREEN_HIGHT - 100 + 2, info_string)
    if IsOctaviConnected then
      if IsPrimaryMode then
        -- White text if on primary mode
        glColor4f(255, 255, 255, 255)
      else
        -- Cyan text if on secondary mode
        glColor4f(0, 255, 255, 255)
      end
    else
      -- Red text if not connected
      glColor4f(255, 0, 0, 255)
    end
    draw_string_Helvetica_18(50, SCREEN_HIGHT - 100, info_string)
  end
end

do_every_draw("DrawOctaviState()")
add_macro("Show OCTAVI Info", "OctaviInfoActive = true", "OctaviInfoActive = false", "activate")
