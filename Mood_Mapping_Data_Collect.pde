#include "Wire.h" 
#include <NewSoftSerial.h>
#include <TinyGPS.h>

// GLOBAL CONSTANTS
#define SERIAL_BAUDRATE      9600  // data rate of connection between Arduino and computer
#define GPS_SERIAL_BAUDRATE  4800  // data rate of connection between Arduino and computer
#define HRMI_I2C_ADDR        127   // IC2 address of the HRMI interface

// GLOBAL VARIABLES
byte hrmi_addr = HRMI_I2C_ADDR;	  // I2C address to use
unsigned long intervalTime = 150;
unsigned long previousPause;

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
int buttonPin[2] = {13, 3};   
int ledPin = 4;
int vibratePin = 6;

int gsrVal = 0;
int buttonVal[2] = {0, 0};
int ledVal = 0;

// button process variables
long intervalMin = 2000;
long intervalMax = 2000;
unsigned long intervalCurrent[] = {0, 0};
int previousState[] = {LOW, LOW};
boolean checkRead[2][3] = {false, false, false, false, false, false};
boolean positiveNegative[] = {false, false};

// GPS Variables
TinyGPS gps;
NewSoftSerial nss(2, 12);

void gpsdump(TinyGPS &gps);
bool feedgps();
void printFloat(double f, int digits = 2);


void setup() {
  hrmi_open();                                                           // Initialize the I2C communication 
  Serial.begin(SERIAL_BAUDRATE);                                      // Initialize the serial interface 
  nss.begin(GPS_SERIAL_BAUDRATE);
  previousPause = millis();

  pinMode(buttonPin[0], INPUT);
  pinMode(buttonPin[1], INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(vibratePin, OUTPUT);

  // Print to serial the title of each data column
  Serial.print("time, ");
  Serial.print("gsr, "); 
  Serial.print("heart beat, ");
  Serial.print("accel x, accel y, accel z, "); 
  Serial.print("button 1, ");
  Serial.print("button 2, ");
  delay(1000);
}


/** LOOP FUNCTION **/
void loop() {
  bool newdata = false;
  unsigned long start = millis();

  for (int i = 0; i < 2; i++) { buttonsReadProcess(i); }
  controlLights();  

  // if ready2read equals true then read heart rate and gsr data and print all data to serial 
  if (ready2read) {
    timeReadWrite();
    gsrReadWrite();  
    heartBeatReadWrite();
    for (int i = 0; i < 3; i++) { analogInputReadWrite(i); }
    for (int i = 0; i < 2; i++) { buttonReadWrite(i); }
    Serial.println(); 
  }

}


boolean ready2read () {
  if (millis() - previousPause > intervalTime) {
      previousPause = millis();
      return true;
  } else { return false; }
}
