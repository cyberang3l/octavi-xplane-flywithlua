-- https://github.com/cyberang3l/octavi-xplane-flywithlua
local script_path = debug.getinfo(1, "S").source:match("@(.*/)")
require(script_path .. "OctaviDefinitions")
require(script_path .. "OctaviMainFuncs")

local lu = require("luaunit")

TestMainFuncs = {} -- class

function TestMainFuncs:testGetUnknownFunctionString()
  lu.assertEquals(GetOctaviFunctionString(FunctionID.INIT), "INIT")
  lu.assertEquals(GetOctaviFunctionString(FunctionID.COM1), "COM1")
  lu.assertEquals(GetOctaviFunctionString(FunctionID.COM2), "COM2")
  lu.assertEquals(GetOctaviFunctionString(FunctionID.AP), "AP")
  lu.assertEquals(GetOctaviFunctionString(1000), "UNKNOWN_FUNCTION")
end

function TestMainFuncs:testActivateFunction()
  local testSet = {
    BTN0PrimaryNoChangeReturnCOM1 = {
      b7 = FunctionButtonValue.BTN0,
      b2 = 0,
      prev_is_primary = true,
      expect_active_function = FunctionID.COM1,
      expect_active_function_button = FunctionButtonValue.BTN0,
      expect_is_primary = true,
    },
    BTN0TogglePrimaryGetSecondaryHDG = {
      b7 = FunctionButtonValue.BTN0,
      b2 = 0x02,
      prev_is_primary = true,
      expect_active_function = FunctionID.HDG,
      expect_active_function_button = FunctionButtonValue.BTN0,
      expect_is_primary = false,
    },
    BTN0InSecondaryNoToggleRemainInSecondaryHDG = {
      b7 = FunctionButtonValue.BTN0,
      b2 = 0x00,
      prev_is_primary = false,
      expect_active_function = FunctionID.HDG,
      expect_active_function_button = FunctionButtonValue.BTN0,
      expect_is_primary = false,
    },
    BTN0InSecondaryToggleBackToPrimaryCOM1 = {
      b7 = FunctionButtonValue.BTN0,
      b2 = 0xc2,
      prev_is_primary = false,
      expect_active_function = FunctionID.COM1,
      expect_active_function_button = FunctionButtonValue.BTN0,
      expect_is_primary = true,
    },
    BTN1TogglePrimaryGetSecondaryBARO = {
      b7 = FunctionButtonValue.BTN1,
      b2 = 0x42,
      prev_is_primary = true,
      expect_active_function = FunctionID.BARO,
      expect_active_function_button = FunctionButtonValue.BTN1,
      expect_is_primary = false,
    },
    BTN6NoToggleChangeToAP = {
      b7 = FunctionButtonValue.BTN6,
      b2 = 0x80,
      prev_is_primary = true,
      expect_active_function = FunctionID.AP,
      expect_active_function_button = FunctionButtonValue.BTN6,
      expect_is_primary = true,
    },
    BTN6TogglePrimaryChangeToAP = { -- There is no secondary function on the AP button
      b7 = FunctionButtonValue.BTN6,
      b2 = 0x02,
      prev_is_primary = true,
      expect_active_function = FunctionID.AP,
      expect_active_function_button = FunctionButtonValue.BTN6,
      expect_is_primary = false,
    },
    BTN6InSecondaryToggleBackPrimaryRemainsToAP = { -- There is no secondary function on the AP button
      b7 = FunctionButtonValue.BTN6,
      b2 = 0x02,
      prev_is_primary = false,
      expect_active_function = FunctionID.AP,
      expect_active_function_button = FunctionButtonValue.BTN6,
      expect_is_primary = true,
    },
    BTN7PrimaryNoToggleChangeToXPDR = {
      b7 = FunctionButtonValue.BTN7,
      b2 = 0x00,
      prev_is_primary = true,
      expect_active_function = FunctionID.XPDR,
      expect_active_function_button = FunctionButtonValue.BTN7,
      expect_is_primary = true,
    },
    BTN7InSecondaryNoToggleChangeToMODE = {
      b7 = FunctionButtonValue.BTN7,
      b2 = 0x00,
      prev_is_primary = false,
      expect_active_function = FunctionID.MODE,
      expect_active_function_button = FunctionButtonValue.BTN7,
      expect_is_primary = false,
    },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    local active_function, active_function_button, is_primary = ActivateFunction(test.b7, test.b2, test.prev_is_primary)
    lu.assertEquals(active_function, test.expect_active_function)
    lu.assertEquals(active_function_button, test.expect_active_function_button)
    lu.assertEquals(is_primary, test.expect_is_primary)
  end
end

function TestMainFuncs:testChangeFrequency()
  local coarse_min_freq = 11800
  local coarse_max_freq = 13600

  local testSet = {
    NoFreqChange_freq_12002 = {
      prev_freq = 12002,
      incr_coarse = 0,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 12002,
    },
    NoFreqChange_freq_11800 = {
      prev_freq = 11800,
      incr_coarse = 0,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 11800,
    },
    NoFreqChange_freq_13597 = {
      prev_freq = 13597,
      incr_coarse = 0,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 13597,
    },
    FreqFineIncrease_0_to_2 = {
      prev_freq = 13500,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 13502,
    },
    FreqFineIncrease_2_to_5 = {
      prev_freq = 13502,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 13505,
    },
    FreqFineIncrease_5_to_7 = {
      prev_freq = 13505,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 13507,
    },
    FreqFineIncrease_7_to_0 = {
      prev_freq = 13507,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 13510,
    },
    FreqFineIncreaseRolloverMaxCoarseFreq = {
      prev_freq = 13597,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 13500,
    },
    FineIncreaseRolloverMinCoarseFreq = {
      prev_freq = 11897,
      incr_coarse = 0,
      incr_fine = 1,
      step_fine = 2.5,
      expect_new_freq = 11800,
    },
    FreqFineDecrease_2_to_0 = {
      prev_freq = 13502,
      incr_coarse = 0,
      incr_fine = -1,
      step_fine = 2.5,
      expect_new_freq = 13500,
    },
    FreqFineDecrease_5_to_2 = {
      prev_freq = 13505,
      incr_coarse = 0,
      incr_fine = -1,
      step_fine = 2.5,
      expect_new_freq = 13502,
    },
    FreqFineDecrease_0_to_7 = {
      prev_freq = 13510,
      incr_coarse = 0,
      incr_fine = -1,
      step_fine = 2.5,
      expect_new_freq = 13507,
    },
    FreqFineDecreaseRolloverMaxCoarseFreq = {
      prev_freq = 13500,
      incr_coarse = 0,
      incr_fine = -1,
      step_fine = 2.5,
      expect_new_freq = 13597,
    },
    FreqFineDecreaseRolloverMinCoarseFreq = {
      prev_freq = 11800,
      incr_coarse = 0,
      incr_fine = -1,
      step_fine = 2.5,
      expect_new_freq = 11897,
    },
    FreqCoarseIncreaseRolloverMaxFineFreq = {
      prev_freq = 13597,
      incr_coarse = 1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 11897,
    },
    FreqCoarseIncreaseRolloverMinFineFreq = {
      prev_freq = 13500,
      incr_coarse = 1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 11800,
    },
    FreqCoarseDecreaseRolloverMaxFineFreq = {
      prev_freq = 11897,
      incr_coarse = -1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 13597,
    },
    FreqCoarseDecreaseRolloverMinFineFreq = {
      prev_freq = 11800,
      incr_coarse = -1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 13500,
    },
    FreqCoarseIncrease = {
      prev_freq = 12897,
      incr_coarse = 1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 12997,
    },
    FreqCoarseDecrease = {
      prev_freq = 12225,
      incr_coarse = -1,
      incr_fine = 0,
      step_fine = 2.5,
      expect_new_freq = 12125,
    },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    local new_freq =
      CalcNewFreq(test.prev_freq, coarse_min_freq, coarse_max_freq, test.incr_coarse, test.incr_fine, test.step_fine)
    lu.assertEquals(new_freq, test.expect_new_freq)
  end
end

function TestMainFuncs:testGetLEDActivationValue()
  local ap_state = 0x200000
  local approach_status = 0

  local testSet = {
    ALL_LEDS_OFF = {
      ap_state = 0x200000,
      approach_status = 0,
      expect_led_activation_value = 0x0000,
    },
    AP_LED_ON = {
      ap_state = 0x100000, -- non 0x200000 value should turn the AP LDE on
      approach_status = 0,
      expect_led_activation_value = 0x01,
    },
    AP_HDG_LED_ON = {
      ap_state = 0x2,
      approach_status = 0,
      expect_led_activation_value = 0x03,
    },
    AP_NAV_LED_ON_BIT_8 = {
      ap_state = 0x0100,
      approach_status = 0,
      expect_led_activation_value = 0x05,
    },
    AP_NAV_LED_ON_BIT_9 = {
      ap_state = 0x0200,
      approach_status = 0,
      expect_led_activation_value = 0x05,
    },
    AP_NAV_LED_ON_BIT_19 = {
      ap_state = 0x80000,
      approach_status = 0,
      expect_led_activation_value = 0x05,
    },
    AP_APR_LED_ON = {
      ap_state = 0,
      approach_status = 1,
      expect_led_activation_value = 0x09,
    },
    AP_ALT_LED_ON_BIT_5 = {
      ap_state = 0x20,
      approach_status = 0,
      expect_led_activation_value = 0x11,
    },
    AP_ALT_LED_ON_BIT_14 = {
      ap_state = 0x4000,
      approach_status = 0,
      expect_led_activation_value = 0x11,
    },
    AP_VS_LED_ON = {
      ap_state = 0x10,
      approach_status = 0,
      expect_led_activation_value = 0x21,
    },
    AP_NAV_VS_COMBINED = {
      ap_state = 0x0110,
      approach_status = 0,
      expect_led_activation_value = 0x25,
    },
    AP_HDG_ALT_COMBINED = {
      ap_state = 0x22,
      approach_status = 0,
      expect_led_activation_value = 0x13,
    },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    local led_activation_value = GetLEDActivationValue(test.ap_state, test.approach_status)
    lu.assertEquals(led_activation_value, test.expect_led_activation_value)
  end
end

function TestMainFuncs:testGetButtonsPressed()
  local testSet = {
    NoButtonPress = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
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
      },
    },
    ShiftPress = {
      b1 = 0x00,
      b2 = 0x01,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = true,
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
      },
    },
    KnobPress = {
      b1 = 0x00,
      b2 = 0x02,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = true,
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
      },
    },
    APPress = {
      b1 = 0x00,
      b2 = 0x40,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = true,
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
      },
    },
    HDGPress = {
      b1 = 0x00,
      b2 = 0x80,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = true,
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
      },
    },
    NAVPress = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x01,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = true,
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
      },
    },
    APRPress = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x02,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = false,
        APR = true,
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
      },
    },
    ALTPress = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x04,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = false,
        APR = false,
        ALT = true,
        VS = false,
        D = false,
        MENU = false,
        CLR = false,
        ENT = false,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    VSPress = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x08,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = false,
        APR = false,
        ALT = false,
        VS = true,
        D = false,
        MENU = false,
        CLR = false,
        ENT = false,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    DPress = {
      b1 = 0x10,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = false,
        APR = false,
        ALT = false,
        VS = false,
        D = true,
        MENU = false,
        CLR = false,
        ENT = false,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    MENUPress = {
      b1 = 0x20,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = false,
        KNOB = false,
        AP = false,
        HDG = false,
        NAV = false,
        APR = false,
        ALT = false,
        VS = false,
        D = false,
        MENU = true,
        CLR = false,
        ENT = false,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    CLRPress = {
      b1 = 0x40,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
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
        CLR = true,
        ENT = false,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    ENTPress = {
      b1 = 0x80,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
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
        ENT = true,
        L_KNOB_ROTATE_RIGHT = false,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    L_KNOB_RIGHT_Rotate = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x01,
      b6 = 0x00,
      expect_button_states = {
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
        L_KNOB_ROTATE_RIGHT = true,
        L_KNOB_ROTATE_LEFT = false,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    L_KNOB_LEFT_Rotate = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0xff,
      b6 = 0x00,
      expect_button_states = {
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
        L_KNOB_ROTATE_LEFT = true,
        S_KNOB_ROTATE_RIGHT = false,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    S_KNOB_RIGHT_Rotate = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x01,
      expect_button_states = {
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
        S_KNOB_ROTATE_RIGHT = true,
        S_KNOB_ROTATE_LEFT = false,
      },
    },
    S_KNOB_LEFT_Rotate = {
      b1 = 0x00,
      b2 = 0x00,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0xff,
      expect_button_states = {
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
        S_KNOB_ROTATE_LEFT = true,
      },
    },
    ShiftAPPress = {
      b1 = 0x00,
      b2 = 0x41,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = true,
        KNOB = false,
        AP = true,
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
      },
    },
    ShiftHDGPress = {
      b1 = 0x00,
      b2 = 0x81,
      b3 = 0x00,
      b5 = 0x00,
      b6 = 0x00,
      expect_button_states = {
        SHIFT = true,
        KNOB = false,
        AP = false,
        HDG = true,
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
      },
    },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    local buttons_pressed = GetButtonsPressed(test.b1, test.b2, test.b3, test.b5, test.b6)
    lu.assertEquals(buttons_pressed, test.expect_button_states)
  end
end

os.exit(lu.LuaUnit.run())
