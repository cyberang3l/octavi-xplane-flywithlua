local script_path = debug.getinfo(1, "S").source:match("@(.*/)")
require(script_path .. "OctaviDefinitions")
require(script_path .. "OctaviMainFuncs")

local lu = require("luaunit")

TestMainFuncs = {} -- class

function TestMainFuncs:testGetUnknownFunctionString()
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

os.exit(lu.LuaUnit.run())
