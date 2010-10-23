/***************************************************************
 *
 * MOOD MAPPER - Heart Rate, Accelerometer & GSR Sensor Readings
 *
 * I2C CONNECTION DETAILS:  
 * +5            +5 (Power for the HRMI)
 * GND           GND
 * Analog In 5   TX (I2C SCL) (recommend 4.7 kOhm pullup)
 * Analog In 4   RX (I2C SDA) (recommend 4.7 kOhm pullup)
 *
 * Note: By default the Arduino Wiring library is limited to a maximum
 *     I2C read of 32 bytes. The Get Heartrate command is limited
 *     by this code to a maximum of 30 values (for a max I2C packet of 32 bytes).
 *
 ***************************************************************/
