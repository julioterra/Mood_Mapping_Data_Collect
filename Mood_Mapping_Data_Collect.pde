#include "Wire.h" 

// GLOBAL CONSTANTS
#define HRMI_HOST_BAUDRATE   9600  // data rate of connection between Arduino and computer
#define HRMI_I2C_ADDR        127   // IC2 address of the HRMI interface

// GLOBAL VARIABLES
byte hrmi_addr = HRMI_I2C_ADDR;	  // I2C address to use

// heart rate variables
int numEntries = 3;               // Number of HR values to request 
int numRspBytes;                  // Number of Response bytes to read
byte i2cRspArray[34];	          // I2C response array, sized to read 32 HR values  
int HRCount = -1;

// accelerometer variables
byte accelCommand = 'A';
int accelRspBytes;               // Number of analog sensor response bytes
byte i2cAnalogArray[1];           // I2C response array for analog values, sized for single reading 

// galvanic skin response variables
int gsrPin = 0;
int gsrVal = 0;


// OPEN THE WIRE AND SERIAL COMMUNICATION CHANNELS
void setup() {
  hrmi_open();                                                           // Initialize the I2C communication 
  Serial.begin(HRMI_HOST_BAUDRATE);                                      // Initialize the serial interface 

  // Print to serial the title of each data column
  Serial.print("time, ");
  Serial.print("gsr, "); 
  Serial.print("accel x, accel y, accel z, "); 
  Serial.print("heart beat");
  delay(1000);
}


/* * Arduino main code loop */
void loop() {

  // print time in milliseconds
  Serial.print(millis());
  Serial.print(", ");

  // read data and print to serial
  gsrRead();  
  for (int i = 1; i < 4; i++) { analogInputRead(i); }
  heartBeatRead();
  Serial.println(';'); 
  delay(150);        // Delay 1 second between commands
}








