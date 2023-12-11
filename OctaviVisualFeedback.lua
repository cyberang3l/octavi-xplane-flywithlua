-- https://github.com/cyberang3l/octavi-xplane-flywithlua
require("graphics")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviMainFuncs.lua")
dofile(SCRIPT_DIRECTORY .. "octavilib/OctaviHelperFuncs.lua")
dofile(SCRIPT_DIRECTORY .. "Octavi.lua")

local info_string = "Octavi Info"
OctaviInfoActive = true
OctaviVisualFeedbackActive = false
ActiveFunctionString = "UNKNOWN"

function OctaviInfoEventHandler()
  if IsOctaviConnected then
    ActiveFunctionString = GetOctaviFunctionString(ActiveFunction)
    if ActiveFunctionString == "INIT" then
      info_string = "Octavi initialized - please press a button on OCTAVI to read initial state"
    else
      info_string = "Function selected " .. ActiveFunctionString
    end
  else
    info_string =
      "Octavi device not found - please connect the device (or free it if it's in use by another program) and reload this lua script"
  end
end

do_every_frame("OctaviInfoEventHandler()")

local base_dev_w = 114
local base_dev_h = 75
local base_sbutton_w = 13
local base_sbutton_h = 5
local base_lbutton_w = 13
local base_lbutton_h = 7
local base_windows_size_multiplier = 5

wnd = nil
function ShowVisualInfo()
  if not wnd then
    wnd =
      float_wnd_create(base_dev_w * base_windows_size_multiplier, base_dev_h * base_windows_size_multiplier, 1, true)
    if float_wnd_is_vr(wnd) then
      float_wnd_set_positioning_mode(wnd, 5, -1)
      -- reduce the window size multiplier in vr! Otherwise the window shows too large
      base_windows_size_multiplier = 3
      float_wnd_set_geometry(wnd, base_dev_w * base_windows_size_multiplier, base_dev_h * base_windows_size_multiplier)
    end
    float_wnd_set_position(wnd, 100, 1000)
    float_wnd_set_title(wnd, "Octavi visual feedback")
    float_wnd_set_imgui_builder(wnd, "build_octavi_wnd")
    float_wnd_set_onclose(wnd, "closed_octavi_info")
  end
  OctaviVisualFeedbackActive = true
end

function HideVisualInfo()
  if wnd then
    float_wnd_destroy(wnd)
    wnd = nil
  end
  OctaviVisualFeedbackActive = false
end
local function drawButton(cntx, base_w, base_h, scale_factor, button_def)
  local w = Round(base_w * scale_factor)
  local h = Round(base_h * scale_factor)
  local start_x = button_def.start_x * base_dev_w * scale_factor
  local start_y = button_def.start_y * base_dev_h * scale_factor
  local btn_text_color = 0xff000000
  cntx.DrawList_AddRectFilled(start_x, start_y, start_x + w, start_y + h, button_def.color, 0.2)

  cntx.PushStyleColor(imgui.constant.Col.Text, btn_text_color)
  local txt = string.format("%s", button_def.label)
  local text_w, text_h = imgui.CalcTextSize(txt)

  local txt_x = start_x + (((start_x + w) - start_x) - text_w) / 2
  local txt_y = start_y + (((start_y + h) - start_y) - text_h) / 2
  cntx.SetCursorPos(txt_x, txt_y)
  cntx.SetWindowFontScale(scale_factor / 2.5)
  cntx.TextUnformatted(txt)
  cntx.PopStyleColor()
end

local function drawKnob(cntx, scale_factor, knob_def)
  -- Parameters: x1, y1, r, color
  diameter = knob_def.r * 2
  x = knob_def.x * base_dev_w * scale_factor
  y = knob_def.y * base_dev_h * scale_factor
  r = knob_def.r * scale_factor
  cntx.DrawList_AddCircleFilled(x, y, r, knob_def.color)
end

local function drawKnobRotate(cntx, scale_factor, direction, color)
  local base_line_width = 26
  local base_line_thickness = 2
  local start_x = 0.08 * base_dev_w * scale_factor
  local start_y = 0.08 * base_dev_h * scale_factor
  local end_x = start_x + base_line_width * scale_factor
  -- Parameters: x1, y1, x2, y2, color, thickness
  cntx.DrawList_AddLine(start_x, start_y, end_x, start_y, color, base_line_thickness * scale_factor)
  if direction == "right" then
    -- Parameters: x1, y1, x2, y2, x3, y3, color
    cntx.DrawList_AddTriangleFilled(
      end_x + scale_factor * 2,
      start_y,
      end_x - scale_factor * 2,
      start_y + scale_factor * 2,
      end_x - scale_factor * 2,
      start_y - scale_factor * 2,
      color
    )
  else
    cntx.DrawList_AddTriangleFilled(
      start_x - scale_factor * 2,
      start_y,
      start_x + scale_factor * 2,
      start_y + scale_factor * 2,
      start_x + scale_factor * 2,
      start_y - scale_factor * 2,
      color
    )
  end
end

local t_now = -1

function build_octavi_wnd(wnd, x, y)
  t_now = os.clock()
  local device_width_height_ratio = base_dev_w / base_dev_h
  local win_width = imgui.GetWindowWidth()
  local win_height = imgui.GetWindowHeight()
  local ratio = win_width / win_height
  local scale_factor = 1
  if ratio < device_width_height_ratio then
    -- width is the limitting dimension
    scale_factor = win_width / base_dev_w
  else
    -- height is the limitting dimension
    scale_factor = win_height / base_dev_h
  end

  local btn_color = 0xffaaaaaa
  local secondary_color = 0xffefae00
  local btn_press_color = 0xff555555
  local led_on_color = 0xffffffff
  local rotate_color = 0xff6146df
  local activeFunctionButtonMap = FunctionPrimaryMap
  if not IsPrimaryMode then
    activeFunctionButtonMap = FunctionSecondaryMap
  end
  local COM1_FUNC_BTN = {
    -- start x/y percentage of total width from the top/left of the device
    start_x = 0.43,
    start_y = 0.11,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN0]),
    color = btn_color,
  }
  local COM2_FUNC_BTN = {
    start_x = 0.59,
    start_y = 0.11,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN1]),
    color = btn_color,
  }
  local D_BTN = {
    start_x = 0.80,
    start_y = 0.11,
    id = ButtonID.D,
    label = GetOctaviButtonString(ButtonID.D),
    color = btn_color,
  }
  local NAV1_FUNC_BTN = {
    start_x = 0.43,
    start_y = 0.26,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN2]),
    color = btn_color,
  }
  local NAV2_FUNC_BTN = {
    start_x = 0.59,
    start_y = 0.26,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN3]),
    color = btn_color,
  }
  local MENU_BTN = {
    start_x = 0.80,
    start_y = 0.26,
    id = ButtonID.MENU,
    label = GetOctaviButtonString(ButtonID.MENU),
    color = btn_color,
  }
  local FMS1_FUNC_BTN = {
    start_x = 0.43,
    start_y = 0.41,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN4]),
    color = btn_color,
  }
  local FMS2_FUNC_BTN = {
    start_x = 0.59,
    start_y = 0.41,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN5]),
    color = btn_color,
  }
  local CLR_BTN = {
    start_x = 0.80,
    start_y = 0.41,
    id = ButtonID.CLR,
    label = GetOctaviButtonString(ButtonID.CLR),
    color = btn_color,
  }
  local AP_FUNC_BTN = {
    start_x = 0.43,
    start_y = 0.56,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN6]),
    color = btn_color,
  }
  local XPDR_FUNC_BTN = {
    start_x = 0.59,
    start_y = 0.56,
    label = GetOctaviFunctionString(activeFunctionButtonMap[FunctionButtonValue.BTN7]),
    color = btn_color,
  }
  local ENT_BTN = {
    start_x = 0.80,
    start_y = 0.56,
    id = ButtonID.ENT,
    label = GetOctaviButtonString(ButtonID.ENT),
    color = btn_color,
  }
  local SHIFT_BTN = {
    start_x = 0.14,
    start_y = 0.50,
    id = ButtonID.SHIFT,
    label = GetOctaviButtonString(ButtonID.SHIFT),
    color = btn_color,
  }
  local AP_BTN = {
    start_x = 0.06,
    start_y = 0.78,
    id = ButtonID.AP,
    led_bit_idx = 0,
    label = GetOctaviButtonString(ButtonID.AP),
    color = btn_color,
  }
  local HDG_BTN = {
    start_x = 0.21,
    start_y = 0.78,
    led_bit_idx = 1,
    id = ButtonID.HDG,
    label = GetOctaviButtonString(ButtonID.HDG),
    color = btn_color,
  }
  local NAV_BTN = {
    start_x = 0.36,
    start_y = 0.78,
    led_bit_idx = 2,
    id = ButtonID.NAV,
    label = GetOctaviButtonString(ButtonID.NAV),
    color = btn_color,
  }
  local APR_BTN = {
    start_x = 0.51,
    start_y = 0.78,
    led_bit_idx = 3,
    id = ButtonID.APR,
    label = GetOctaviButtonString(ButtonID.APR),
    color = btn_color,
  }
  local ALT_BTN = {
    start_x = 0.66,
    start_y = 0.78,
    led_bit_idx = 4,
    id = ButtonID.ALT,
    label = GetOctaviButtonString(ButtonID.ALT),
    color = btn_color,
  }
  local VS_BTN = {
    start_x = 0.81,
    start_y = 0.78,
    led_bit_idx = 5,
    id = ButtonID.VS,
    label = GetOctaviButtonString(ButtonID.VS),
    color = btn_color,
  }

  if ActiveFunction == FunctionID.FMS1 or ActiveFunction == FunctionID.FMS2 then
    AP_BTN.label = GetOctaviButtonString(ButtonID.CDI)
    AP_BTN.id = ButtonID.CDI
    HDG_BTN.label = GetOctaviButtonString(ButtonID.OBS)
    HDG_BTN.id = ButtonID.OBS
    NAV_BTN.label = GetOctaviButtonString(ButtonID.MSG)
    NAV_BTN.id = ButtonID.MSG
    APR_BTN.label = GetOctaviButtonString(ButtonID.FPL)
    APR_BTN.id = ButtonID.FPL
    ALT_BTN.label = GetOctaviButtonString(ButtonID.VNAV)
    ALT_BTN.id = ButtonID.VNAV
    VS_BTN.label = GetOctaviButtonString(ButtonID.PROC)
    VS_BTN.id = ButtonID.PROC
  end

  local largeBtns = {
    SHIFT_BTN,
    D_BTN,
    MENU_BTN,
    CLR_BTN,
    ENT_BTN,
  }

  local smallBtns = {
    AP_BTN,
    HDG_BTN,
    NAV_BTN,
    APR_BTN,
    ALT_BTN,
    VS_BTN,
  }

  local funcBtns = {
    COM1_FUNC_BTN,
    COM2_FUNC_BTN,
    NAV1_FUNC_BTN,
    NAV2_FUNC_BTN,
    FMS1_FUNC_BTN,
    FMS2_FUNC_BTN,
    AP_FUNC_BTN,
    XPDR_FUNC_BTN,
  }

  local activeFuncStr = GetOctaviFunctionString(ActiveFunction)
  for i, _ in ipairs(funcBtns) do
    if not IsPrimaryMode then
      funcBtns[i].color = secondary_color
    end
    if funcBtns[i].label == activeFuncStr then
      funcBtns[i].color = led_on_color
    end

    drawButton(imgui, base_lbutton_w, base_lbutton_h, scale_factor, funcBtns[i])
  end

  for i, _ in ipairs(smallBtns) do
    if ActiveFunction == FunctionID.FMS1 or ActiveFunction == FunctionID.FMS2 then
      smallBtns[i].color = secondary_color
    else
      if HasBit(ActiveAPLeds, smallBtns[i].led_bit_idx) then
        smallBtns[i].color = led_on_color
      end
    end

    if CurrentActiveButtons[ButtonIDToButtonName[smallBtns[i].id]] then
      smallBtns[i].color = btn_press_color
    end
    drawButton(imgui, base_sbutton_w, base_sbutton_h, scale_factor, smallBtns[i])
  end

  for i, _ in ipairs(largeBtns) do
    if CurrentActiveButtons[ButtonIDToButtonName[largeBtns[i].id]] then
      largeBtns[i].color = btn_press_color
    end
    drawButton(imgui, base_lbutton_w, base_lbutton_h, scale_factor, largeBtns[i])
  end

  S_KNOB_BTN = {
    x = 0.195,
    y = 0.28,
    r = 7,
    color = btn_color,
  }
  if CurrentActiveButtons[ButtonIDToButtonName[ButtonID.KNOB]] then
    S_KNOB_BTN.color = btn_press_color
  end
  L_KNOB_BTN = {
    x = 0.195,
    y = 0.28,
    r = 10,
    color = btn_color - 0x55555555,
  }
  if t_now - KnobLastTriggeredTime > 2 then
    -- Only show the knob rotation arrows for a max of 2 seconds
    KnobLastTriggeredTime = -1
  end
  if
    (CurrentActiveButtons.L_KNOB_ROTATE_RIGHT or CurrentActiveButtons.S_KNOB_ROTATE_RIGHT)
    and KnobLastTriggeredTime ~= -1
  then
    drawKnobRotate(imgui, scale_factor, "right", rotate_color)
    if CurrentActiveButtons.L_KNOB_ROTATE_RIGHT then
      L_KNOB_BTN.color = rotate_color
    elseif CurrentActiveButtons.S_KNOB_ROTATE_RIGHT then
      S_KNOB_BTN.color = rotate_color
    end
  elseif
    (CurrentActiveButtons.L_KNOB_ROTATE_LEFT or CurrentActiveButtons.S_KNOB_ROTATE_LEFT)
    and KnobLastTriggeredTime ~= -1
  then
    drawKnobRotate(imgui, scale_factor, "left", rotate_color)
    if CurrentActiveButtons.L_KNOB_ROTATE_LEFT then
      L_KNOB_BTN.color = rotate_color
    elseif CurrentActiveButtons.S_KNOB_ROTATE_LEFT then
      S_KNOB_BTN.color = rotate_color
    end
  end
  drawKnob(imgui, scale_factor, L_KNOB_BTN)
  drawKnob(imgui, scale_factor, S_KNOB_BTN)
end

function closed_octavi_info(wnd)
  local _ = wnd -- Reference to window, which triggered the call.
  -- This function is called when the user closes the window. Drawing or calling imgui
  --     -- functions is not allowed in this function as the window is already destroyed.
  HideVisualInfo()
end

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

function ToggleOctaviVisualInfo()
  if OctaviVisualFeedbackActive then
    HideVisualInfo()
  else
    ShowVisualInfo()
  end
end

do_every_draw("DrawOctaviState()")
add_macro("Show Octavi Text Info", "OctaviInfoActive = true", "OctaviInfoActive = false", "activate")
add_macro("Toggle Octavi Visual Info", "ToggleOctaviVisualInfo()")
create_command("FlyWithLua/octavi/show_toggle", "Toggle Octavi Visual Info", "ToggleOctaviVisualInfo()", "", "")
