-- https://github.com/cyberang3l/octavi-xplane-flywithlua
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviDefinitions.lua")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviDatarefs.lua")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviHelperFuncs.lua")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviMainFuncs.lua")

local function calc_new_dir(dir, incr_coarse, incr_fine, step_coarse, step_fine)
  dir = dir + incr_coarse * step_coarse + incr_fine * step_fine
  if dir > 360 then
    dir = dir - 360
  elseif dir < 0 then
    dir = dir + 360
  end
  return dir
end

local function calc_new_xpdr_code(code, incr_coarse, incr_fine)
  local dec_code = OctToDec(code)
  dec_code = dec_code + incr_coarse * 64 + incr_fine
  if dec_code < 0 then
    dec_code = 4096 + code
  end
  if dec_code > 4096 then
    dec_code = dec_code - 4096
  end
  return DecToOct(dec_code)
end

KnobLastTriggeredTime = -1
IsOctaviConnected = false
ActiveFunction = FunctionID.INIT
IsPrimaryMode = true
local bytes_to_read = 8
local last_buttons = ButtonsInit
CurrentActiveButtons = ButtonsInit

-- find USB HID device based on vid/pid
local first_HID_dev = nil
for x in ipairs(ALL_HID_DEVICES) do
  if ALL_HID_DEVICES[x].vendor_id == VENDOR_ID and ALL_HID_DEVICES[x].product_id == DEVICE_ID then
    first_HID_dev = hid_open_path(ALL_HID_DEVICES[x].path)
    break
  end
end

if first_HID_dev == nil then
  print("Cannot find Octavi device!")
else
  IsOctaviConnected = true
  hid_set_nonblocking(first_HID_dev, 1)
  -- Write 8 bytes to the device to trigger an interrupt and update the state
  -- Seems like the 0x00000000000000ff sequence consistently triggers an interrupt
  -- without messing with any bits
  hid_write(first_HID_dev, 0, 0, 0, 0, 0, 0, 0, 255)
end

function ChangeFreqs()
  --[[

  USB Report Structure:
  Byte order: big endian

  VAR/BYTE    DESC
  b0          Report ID (always 11)
  b1-b3       Buttons (big endian)
  b4          Doesn't seem to be used for anything
  b5          Large knob (coarse)
  b6          Small knob (fine)
  b7          State

  --]]
  local nov, b0, b1, b2, b3, b4, b5, b6, b7 = 0, 0, 0, 0, 0, 0, 0, 0, 0
  if IsOctaviConnected then
    nov, b0, b1, b2, b3, b4, b5, b6, b7 = hid_read(first_HID_dev, bytes_to_read)
  end

  -- if number of values (nov) received > 0, enter loop
  if nov > 0 then
    assert(b0 == 0x0b, "The first byte didn't return the expected 0x0b value")
    ActiveFunction, _, IsPrimaryMode = ActivateFunction(b7, b2, IsPrimaryMode)
    local buttons = GetButtonsPressed(b1, b2, b3, b5, b6)
    CurrentActiveButtons = buttons
    -- print(nov)
    -- print(G430_NCS[0])
    -- convert encoder differentials to signed int 8
    local large_inc = 0
    local small_inc = 0

    if buttons.L_KNOB_ROTATE_RIGHT then
      -- Record the time we last rotated the knob
      KnobLastTriggeredTime = os.clock()
      large_inc = 1
    elseif buttons.L_KNOB_ROTATE_LEFT then
      -- Record the time we last rotated the knob
      KnobLastTriggeredTime = os.clock()
      large_inc = -1
    end

    if buttons.S_KNOB_ROTATE_RIGHT then
      -- Record the time we last rotated the knob
      KnobLastTriggeredTime = os.clock()
      small_inc = 1
    elseif buttons.S_KNOB_ROTATE_LEFT then
      -- Record the time we last rotated the knob
      KnobLastTriggeredTime = os.clock()
      small_inc = -1
    end

    if ActiveFunction == FunctionID.COM1 then
      -- Function Button 1 Primary
      if G430_NCS[0] == 1 then
        command_once("sim/GPS/g430n1_nav_com_tog")
      end
      COM1[0] = CalcNewFreq(COM1[0], 11800, 13600, large_inc, small_inc, 2.5)
      if buttons.SHIFT then
        command_once("sim/radios/com1_standy_flip")
      end
    elseif ActiveFunction == FunctionID.HDG then
      -- Function Button 1 Secondary
      HDG1[0] = calc_new_dir(HDG1[0], large_inc, small_inc, 10, 1)
    elseif ActiveFunction == FunctionID.COM2 then
      -- Function Button 2 Primary
      if G430_NCS[1] == 1 then
        command_once("sim/GPS/g430n2_nav_com_tog")
      end
      COM2[0] = CalcNewFreq(COM2[0], 11800, 13600, large_inc, small_inc, 2.5)
      if buttons.SHIFT then
        command_once("sim/radios/com2_standy_flip")
      end
    elseif ActiveFunction == FunctionID.BARO then
      -- Function Button 2 Secondary
      if buttons.L_KNOB_ROTATE_RIGHT or buttons.S_KNOB_ROTATE_RIGHT then
        command_once("sim/instruments/barometer_up")
      elseif buttons.L_KNOB_ROTATE_LEFT or buttons.S_KNOB_ROTATE_LEFT then
        command_once("sim/instruments/barometer_down")
      end
    elseif ActiveFunction == FunctionID.NAV1 then
      -- Function Button 3 Primary
      if G430_NCS[0] == 0 then
        command_once("sim/GPS/g430n1_nav_com_tog")
      end
      NAV1[0] = CalcNewFreq(NAV1[0], 10800, 11700, large_inc, small_inc, 5)
      if buttons.SHIFT then
        command_once("sim/radios/nav1_standy_flip")
      end
    elseif ActiveFunction == FunctionID.CRS1 then
      -- Function Button 3 Secondary
      NAV1_OBS = calc_new_dir(NAV1_OBS, large_inc, small_inc, 10, 1)
    elseif ActiveFunction == FunctionID.NAV2 then
      if G430_NCS[1] == 0 then
        command_once("sim/GPS/g430n2_nav_com_tog")
      end
      NAV2[0] = CalcNewFreq(NAV2[0], 10800, 11700, large_inc, small_inc, 5)
      if buttons.SHIFT then
        command_once("sim/radios/nav2_standy_flip")
      end
    elseif ActiveFunction == FunctionID.CRS2 then
      NAV2_OBS = calc_new_dir(NAV2_OBS, large_inc, small_inc, 10, 1)
    elseif ActiveFunction == FunctionID.FMS1 then
      -- Bindings for GNS430
      if buttons.L_KNOB_ROTATE_RIGHT then
        command_once("sim/GPS/g430n1_chapter_up")
      elseif buttons.L_KNOB_ROTATE_LEFT then
        command_once("sim/GPS/g430n1_chapter_dn")
      end
      if buttons.S_KNOB_ROTATE_RIGHT then
        command_once("sim/GPS/g430n1_page_up")
      elseif buttons.S_KNOB_ROTATE_LEFT then
        command_once("sim/GPS/g430n1_page_dn")
      end

      if buttons.KNOB then
        command_once("sim/GPS/g430n1_cursor")
      end

      -- Shift + AP zooms in
      if buttons.SHIFT and buttons.AP then
        command_once("sim/GPS/g430n1_zoom_in")
      elseif buttons.AP and not last_buttons.AP then
        -- The AP button is treated as CDI here
        command_once("sim/GPS/g430n1_cdi")
      end

      -- Shift + HDG zooms in
      if buttons.SHIFT and buttons.HDG then
        command_once("sim/GPS/g430n1_zoom_out")
      elseif buttons.HDG and not last_buttons.HDG then
        -- The HDG button is treated as OBS here
        command_once("sim/GPS/g430n1_obs")
      end

      -- The NAV button is treated as MSG here
      if buttons.NAV and not last_buttons.NAV then
        command_once("sim/GPS/g430n1_msg")
      end
      -- The APR button is treated as FPL here
      if buttons.APR and not last_buttons.APR then
        command_once("sim/GPS/g430n1_fpl")
      end
      -- The ALT button is treated as VNAV here
      if buttons.ALT and not last_buttons.ALT then
        command_once("sim/GPS/g430n1_vnav")
      end
      -- The VS button is treated as PROC here
      if buttons.VS and not last_buttons.VS then
        command_once("sim/GPS/g430n1_proc")
      end

      if buttons.D and not last_buttons.D then
        command_once("sim/GPS/g430n1_direct")
      end
      if buttons.MENU and not last_buttons.MENU then
        command_once("sim/GPS/g430n1_menu")
      end
      if buttons.CLR and not last_buttons.CLR then
        command_once("sim/GPS/g430n1_clr")
      end
      if buttons.ENT and not last_buttons.ENT then
        command_once("sim/GPS/g430n1_ent")
      end
    elseif ActiveFunction == FunctionID.FMS2 then
      -- Bindings for GNS430
      if buttons.L_KNOB_ROTATE_RIGHT then
        command_once("sim/GPS/g430n2_chapter_up")
      elseif buttons.L_KNOB_ROTATE_LEFT then
        command_once("sim/GPS/g430n2_chapter_dn")
      end
      if buttons.S_KNOB_ROTATE_RIGHT then
        command_once("sim/GPS/g430n2_page_up")
      elseif buttons.S_KNOB_ROTATE_LEFT then
        command_once("sim/GPS/g430n2_page_dn")
      end

      if buttons.KNOB then
        command_once("sim/GPS/g430n2_cursor")
      end

      -- Shift + AP zooms in
      if buttons.SHIFT and buttons.AP then
        command_once("sim/GPS/g430n2_zoom_in")
      elseif buttons.AP and not last_buttons.AP then
        -- The AP button is treated as CDI here
        command_once("sim/GPS/g430n2_cdi")
      end

      -- Shift + HDG zooms in
      if buttons.SHIFT and buttons.HDG then
        command_once("sim/GPS/g430n2_zoom_out")
      elseif buttons.HDG and not last_buttons.HDG then
        -- The HDG button is treated as OBS here
        command_once("sim/GPS/g430n2_obs")
      end

      -- The NAV button is treated as MSG here
      if buttons.NAV and not last_buttons.NAV then
        command_once("sim/GPS/g430n2_msg")
      end
      -- The APR button is treated as FPL here
      if buttons.APR and not last_buttons.APR then
        command_once("sim/GPS/g430n2_fpl")
      end
      -- The ALT button is treated as VNAV here
      if buttons.ALT and not last_buttons.ALT then
        command_once("sim/GPS/g430n2_vnav")
      end
      -- The VS button is treated as PROC here
      if buttons.VS and not last_buttons.VS then
        command_once("sim/GPS/g430n2_proc")
      end

      if buttons.D and not last_buttons.D then
        command_once("sim/GPS/g430n2_direct")
      end
      if buttons.MENU and not last_buttons.MENU then
        command_once("sim/GPS/g430n2_menu")
      end
      if buttons.CLR and not last_buttons.CLR then
        command_once("sim/GPS/g430n2_clr")
      end
      if buttons.ENT and not last_buttons.ENT then
        command_once("sim/GPS/g430n2_ent")
      end
    elseif ActiveFunction == FunctionID.AP then
      AP_ALT[0] = AP_ALT[0] + large_inc * 100
      AP_VS[0] = AP_VS[0] + small_inc * 100
      if buttons.AP and not last_buttons.AP then
        command_once("sim/autopilot/servos_toggle")
      end
      if buttons.HDG and not last_buttons.HDG then
        command_once("sim/autopilot/heading")
      end
      if buttons.NAV and not last_buttons.NAV then
        command_once("sim/autopilot/NAV")
      end
      if buttons.APR and not last_buttons.APR then
        command_once("sim/autopilot/approach")
      end
      if buttons.ALT and not last_buttons.ALT then
        command_once("sim/autopilot/altitude_hold")
      end
      if buttons.VS and not last_buttons.VS then
        command_once("sim/autopilot/vertical_speed")
      end
    elseif ActiveFunction == FunctionID.XPDR then
      XPDR[0] = calc_new_xpdr_code(XPDR[0], large_inc, small_inc)
    elseif ActiveFunction == FunctionID.MODE then
      if buttons.S_KNOB_ROTATE_RIGHT or buttons.L_KNOB_ROTATE_RIGHT then
        command_once("sim/transponder/transponder_up")
      elseif buttons.S_KNOB_ROTATE_LEFT or buttons.L_KNOB_ROTATE_LEFT then
        command_once("sim/transponder/transponder_dn")
      end
    end
  end
end

if IsOctaviConnected then
  do_every_frame("ChangeFreqs()")
end

local last_active_ap_leds = 0
ActiveAPLeds = 0

function ChangeLeds()
  ActiveAPLeds = GetLEDActivationValue(AP_STATE[0], APPROACH_STATUS)
  if ActiveAPLeds ~= last_active_ap_leds then
    hid_write(first_HID_dev, 11, ActiveAPLeds)
    last_active_ap_leds = ActiveAPLeds
  end
end

if IsOctaviConnected then
  do_every_frame("ChangeLeds()")
end
