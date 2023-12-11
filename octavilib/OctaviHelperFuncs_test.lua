-- https://github.com/cyberang3l/octavi-xplane-flywithlua
local script_path = debug.getinfo(1, "S").source:match("@(.*/)")
require(script_path .. "OctaviHelperFuncs")

local lu = require("luaunit")

TestHelperFuncs = {} -- class

function TestHelperFuncs:testBit()
  local testSet = {
    TestCase0 = { value = 0, expectValue = 1 },
    TestCase1 = { value = 1, expectValue = 2 },
    TestCase3 = { value = 3, expectValue = 8 },
    TestCase5 = { value = 5, expectValue = 32 },
    TestCase16 = { value = 16, expectValue = 65536 },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    lu.assertEquals(Bit(test.value), test.expectValue)
  end
end

function TestHelperFuncs:testHasValue()
  local testSet = {
    TestCase1_present = { value = 1, table = { 1, 2, 3, 4 }, expect = true },
    TestCase1_shuffle_present = { value = 1, table = { 2, 3, 4, 1 }, expect = true },
    TestCase1_absent = { value = 1, table = { 2, 3, 4 }, expect = false },
    TestCaseCOM1_present = { value = "COM1", table = { 2, 3, 4, 1, "COM1" }, expect = true },
    TestCaseCOM1_absent = { value = "COM1", table = { 2, 3, 4, 1, "COM2" }, expect = false },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    lu.assertEquals(HasValue(test.table, test.value), test.expect)
  end
end

function TestHelperFuncs:testHasBit()
  local testSet = {
    TestCase1 = { value = 1, expectTrue = { 0 } },
    TestCase3 = { value = 3, expectTrue = { 0, 1 } },
    TestCase16 = { value = 20, expectTrue = { 2, 4 } },
    TestCase255 = { value = 255, expectTrue = { 0, 1, 2, 3, 4, 5, 6, 7 } },
    TestCase256 = { value = 256, expectTrue = { 8 } },
  }

  print()
  for name, test in pairs(testSet) do
    print("Running test case " .. name)
    lu.assertEquals(type(test), "table")
    for i = 0, 15, 1 do
      if HasValue(test.expectTrue, i) then
        lu.assertEquals(HasBit(test.value, i), true)
      else
        lu.assertEquals(HasBit(test.value, i), false)
      end
    end
  end
end

os.exit(lu.LuaUnit.run())
