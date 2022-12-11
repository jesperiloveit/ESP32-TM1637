--ESP32 NodeMCU minimal module for TM1637 using software I2C interface
--Author: jesperiloveit
--Usage example:
--  display=require "TM1637"
--  display:init(22,19) -- SDA, SCL gpio pins
--  display:send({2,3,5,9}, true) -- displays 23:59
--Dependencies: I2C
-------------------------------------------------------
TM1637 = {}
TM1637.i2c = i2c
-- 7 segment codes are a combination of:
--    _2_
-- 32|   |1
--   |_64| 
-- 16|   |4
--   |_8_|
-- digits: 0,1,2,3,4,5,6,7,8,9,blank,-,degree
local dnum = {0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F,
    0, 0x40, 0x63}

local bits={128,64,32,16,8,4,2,1} -- byte bit values

-- Reverse a byte LSB<->MSB byte order
local function revbyte(b)
  local a=0
  for i=1,8 do
    if b-bits[i]>=0 then
      b=b-bits[i]
      a=a+bits[9-i]
    end
  end
  return a
end

-- Initialize i2c interface
function TM1637.init(self, sda, scl)
  self.i2c.setup(i2c.SW, sda, scl, i2c.SLOW)
end

-- Send digits to display. digits={d,d,d,d}, colon=true if colon on
function TM1637.send(self, digits, colon)
  local d={}
  -- I2C uses MSB first, but TM1637 uses LSB so all bytes must be reversed
  for i=1,4 do
      d[i]=revbyte(dnum[digits[i]+1])
      if colon and i==2 then d[i]=d[i]+1 end
  end
  self.i2c.start(i2c.SW)
  local w1 = self.i2c.write(i2c.SW,2) -- =revbyte(0x40)
  -- data command - automatic address adding mode
  self.i2c.stop(i2c.SW)

  self.i2c.start(i2c.SW)
  w1 = w1 + self.i2c.write(i2c.SW, 3) --=revbyte(0xC0)
  -- address command - start at display zero (leftmost)
  for i=1,4 do
    w1 = w1 + self.i2c.write(i2c.SW, d[i]) --write 7 segment display code
  end
  self.i2c.stop(i2c.SW)

  self.i2c.start(i2c.SW)
  w1 = w1 + self.i2c.write(i2c.SW, 241) -- =revbyte(0x80 + 0x08 + 0x07)
  --control command - display on + max brightness
  self.i2c.stop(i2c.SW)

  return w1==7 --7 bytes written
end

return TM1637


