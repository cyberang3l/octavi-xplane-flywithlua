-- http://lua-users.org/wiki/BitwiseOperators
--- @param bit_index number
function Bit(bit_index)
  return 2 ^ bit_index -- 0-based indexing
end

--- HasBit returns true if the value 'val' contains the bit 'bit'
--- You would typically call this function as 'if hasbit(x, 3) then'
--- @param val number
--- @param bit number -- a zero based index
function HasBit(val, bit)
  local bit_val = Bit(bit)
  return val % (bit_val + bit_val) >= bit_val
end

--- @param value number
function OctToDec(value)
  local base = 8
  local octal_string = tostring(value)
  local decimal = 0
  for char in octal_string:gmatch(".") do
    local n = tonumber(char, base)
    if not n then
      return 0
    end
    decimal = decimal * base + n
  end
  return decimal
end

--- @param value number
function DecToOct(value)
  local base = 10
  local decimal_string = string.format("%o", value)
  local octal = 0
  for char in decimal_string:gmatch(".") do
    local n = tonumber(char, base)
    if not n then
      return 0
    end
    octal = octal * base + n
  end
  return octal
end

--- HaveValue returns true of the value 'val' is in the table 'arr'
--- @param table table
--- @param val any
function HasValue(table, val)
  for _, value in ipairs(table) do
    if value == val then
      return true
    end
  end

  return false
end
