# ESP32-TM1637
Lua module for the TM1637 4-digit LED display

### Usage example:
    display=require "TM1637"
    display:init(22,19) -- SDA, SCL gpio pins
    display:send({2,3,5,9}, true) -- displays 23:59

### Dependencies
I2C
