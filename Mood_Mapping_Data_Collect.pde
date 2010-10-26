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
byte accelCommand = 'A';
int accelRspBytes;               // Number of analog sensor response bytes
byte i2cAnalogArray[1];           // I2C response array for analog values, sized for single reading 

// pin assignments
// analog pins 4 and 5 are used for wire connection to HRMI
int gsrPin = 0;
int buttonPin1 = 2;
int buttonPin2 = 3;
int ledPin = 4;

int gsrVal = 0;
int buttonVal1 = 0;
int buttonVal2 = 0;
int ledVal = 0;


void setup() {
  hrmi_open();                                                           // Initialize the I2C communication 
  Serial.begin(HRMI_HOST_BAUDRATE);                                      // Initialize the serial interface 

  pinMode(buttonPin1, INPUT);
  pinMode(buttonPin2, INPUT);
  pinMode(ledPin, OUTPUT);

  // Print to serial the title of each data column
  Serial.print("time, ");
  Serial.print("gsr, "); 
  Serial.print("accel x, accel y, accel z, "); 
  Serial.print("heart beat, ");
  Serial.print("button 1, ");
  Serial.print("button 2, ");
  delay(1000);
}



/* * Arduino main code loop */
void loop() {

  // print time in milliseconds
  Serial.print(millis());
  Serial.print(", ");

  // read data and print to serial
  gsrRead();  
  Serial.print(", ");

  for (int i = 0; i < 3; i++) { 
    analogInputRead(i);
    Serial.print(", "); 
 }

  heartBeatRead();
  Serial.print(", "); 

  buttonVal1 = digitalRead(buttonPin1);
  Serial.print(buttonVal1);
  Serial.print(", "); 

  buttonVal2 = digitalRead(buttonPin2);
  Serial.print(buttonVal2);

  Serial.println(';'); 

  // turn on light if either button pressed
  if (buttonVal1 == HIGH || buttonVal2 == HIGH) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }

  delay(150);        // Delay 150 milliseconds between commands
}








