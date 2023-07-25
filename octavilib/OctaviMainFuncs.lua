local script_path = debug.getinfo(1, "S").source:match("@(.*/)")
dofile(script_path .. "OctaviDefinitions.lua")
dofile(script_path .. "OctaviHelperFuncs.lua")

--- @param b7 number -- value of byte 7 - We extract the currently active button value from b7
--- @param b2 number -- value of byte 2 - We check if the primary/secondary toggle button is pressed - that's the knob press
--- @param prev_is_primary boolean   -- The value of the previous primary/secondary mode - we need to know this in case we need to toggle the primary/secondary state
--- @returns the new active_function, active_function_button, is_primary
function ActivateFunction(b7, b2, prev_is_primary)
  -- The entire 7th byte is dedicated to the 8 function buttons
  local active_function_button = b7
  local is_primary = prev_is_primary
  local toggle_secondary_funcs = HasBit(b2, 1) -- look for knob press

  if toggle_secondary_funcs then
    is_primary = not is_primary
  end

  local active_function = FunctionPrimaryMap[active_function_button]
  if not is_primary then
    active_function = FunctionSecondaryMap[active_function_button]
  end

  return active_function, active_function_button, is_primary
end

--- Do not modify the ButtonsInit table - everything should be false here
ButtonsInit = {
  SHIFT = false,
  KNOB = false,
  AP = false,
  HDG = false,
  NAV = false,
  APR = false,
  ALT = false,
  VS = false,
  D = false,
  MENU = false,
  CLR = false,
  ENT = false,
  L_KNOB_ROTATE_RIGHT = false,
  L_KNOB_ROTATE_LEFT = false,
  S_KNOB_ROTATE_RIGHT = false,
  S_KNOB_ROTATE_LEFT = false,
}

--- @param b1 number -- value of byte 1
--- @param b2 number -- value of byte 2
--- @param b3 number -- value of byte 3
--- @param b5 number -- value of byte 5 - large knob rotate
--- @param b6 number -- value of byte 6 - small knob rotate
function GetButtonsPressed(b1, b2, b3, b5, b6)
  local button_values = {
    SHIFT = HasBit(b2, 0),
    KNOB = HasBit(b2, 1),
    AP = HasBit(b2, 6),
    HDG = HasBit(b2, 7),
    NAV = HasBit(b3, 0),
    APR = HasBit(b3, 1),
    ALT = HasBit(b3, 2),
    VS = HasBit(b3, 3),
    D = HasBit(b1, 4),
    MENU = HasBit(b1, 5),
    CLR = HasBit(b1, 6),
    ENT = HasBit(b1, 7),
    -- Large knob rotation
    L_KNOB_ROTATE_RIGHT = b5 == 1,
    L_KNOB_ROTATE_LEFT = b5 == 0xff,
    -- Small knob rotation
    S_KNOB_ROTATE_RIGHT = b6 == 1,
    S_KNOB_ROTATE_LEFT = b6 == 0xff,
  }
  return button_values
end

--- Function that calculates the LED register value that must be writted to the HID device
--- to turn on/off the correct leds based on the autopilot state
--- Documentation about the autopilot state (sim/cockpit/autopilot/autopilot_state dataref)
--- can be found at the following link:
--- https://developer.x-plane.com/article/accessing-the-x-plane-autopilot-from-datarefs/
---
--- @param ap_state number -- pass the dataref_table("sim/cockpit/autopilot/autopilot_state")[0] value
--- @param approach_status number -- pass the APPROACH_STATUS variable (dataref("APPROACH_STATUS", "sim/cockpit2/autopilot/approach_status"))
function GetLEDActivationValue(ap_state, approach_status)
  local led_register_value = 0
  -- For the classic Cessna 172 (no glass cockpit), when AP
  -- is deactivated, we get 0x200000
  if ap_state ~= 0x200000 then
    -- If the value is not 0x200000, activate the AP LED
    led_register_value = 1
  end
  if HasBit(ap_state, 1) then
    led_register_value = led_register_value + 2 -- HDG
  end
  if HasBit(ap_state, 8) or HasBit(ap_state, 9) or HasBit(ap_state, 19) then
    led_register_value = led_register_value + 4 -- NAV
  end
  if approach_status > 0 then
    led_register_value = led_register_value + 8 -- APR
  end
  if HasBit(ap_state, 5) or HasBit(ap_state, 14) then
    led_register_value = led_register_value + 16 -- ALT
  end
  if HasBit(ap_state, 4) then
    led_register_value = led_register_value + 32 -- VS
  end
  return led_register_value
end

--- @returns a function string from a function ID, or "UNKNOWN_FUNCTION"
--           if the function ID is not known
--- @param func number -- a FunctionID number
function GetOctaviFunctionString(func)
  local ret = FunctionStrings[func]
  if ret == nil then
    return "UNKNOWN_FUNCTION"
  end
  return ret
end

function CalcNewFreq(freq, coarse_min, coarse_max, incr_coarse, incr_fine, step_fine)
  local freq_fine = freq % 100
  local freq_coarse = freq - freq_fine

  -- freq received by the instrument is always floored... calculate the precise
  -- fine frequency based on the step_fine
  local fine_freq_err = freq_fine % step_fine
  if fine_freq_err > 0 then
    freq_fine = freq_fine - fine_freq_err + step_fine
  end

  -- Increase/decrease the coarse and fine frequencies
  freq_coarse = freq_coarse + (incr_coarse * 100)
  freq_fine = freq_fine + (incr_fine * step_fine)

  -- If the coarse overflows or underflows, set it to min/max respectively
  if freq_coarse >= coarse_max then
    freq_coarse = coarse_min
  elseif freq_coarse < coarse_min then
    freq_coarse = coarse_max - 100
  end

  -- Similarly, if the fine overflows or underflows, rollover
  if freq_fine >= 100 then
    freq_fine = freq_fine - 100
  elseif freq_fine < 0 then
    freq_fine = freq_fine + 100
  end

  -- return a floored frequency as expected by the instrument
  local ret = math.floor(freq_coarse + freq_fine)
  return ret
end
