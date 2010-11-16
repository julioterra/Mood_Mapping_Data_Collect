#include <Wire.h> 
#include <NewSoftSerial.h>

// GLOBAL CONSTANTS
#define SERIAL_BAUDRATE          9600  // data rate of connection between Arduino and computer
#define GPS_SERIAL_BAUDRATE      4800  // data rate of connection between Arduino and computer
#define HRMI_I2C_ADDR            127   // IC2 address of the HRMI interface

#define rateRequestIDFirst       9
#define rateRequestIDSecond      10
#define rateRequestMode          13
#define rateRequestRateFirst     15
#define rateRequestRateSecond    16

#define NMEAmsgArrayLength       300

#define GGAtimeLoc               7
#define GGAlattitudeLoc          18
#define GGAlongitudeLoc          30
#define GGAfixValidLoc           43

#define RMCtimeOrderPos          1
#define RMCgpsStatusOrderPos     2
#define RMClattitudeOrderPos     3
#define RMCsouthNorthOrderPos    4
#define RMClongitudeOrderPos     5
#define RMCeastWestOrderPos      6
#define RMCdateOrderPos          9

#define heartRateThreshold       95

// GPS CONNECT CLASS: Reads and parses data from the GPS unit
class gpsConnect {
    NewSoftSerial mySerial;
   
  public:
    // variables for printing out data from GPS
    char gpsStatus[1];
    char lattitude[9];
    char northSouth[1];
    char longitude[10];
    char eastWest[1];
    char timeStamp[10];
    char dateStamp[6];
    boolean locValid;
    char lastValidReading[10];
    boolean newData;

    gpsConnect(byte rxPin, byte txPin) : mySerial(rxPin, txPin){  }
    void setupGPS(int);
    void readGPS();
    void publishMsg(char[], int);
    void printMsg(char[], int );
    void requestMsg(char );
    void changeRateMsg(char, int );    
  
  private:
    // variables for reading in data from GPS
    char nmeaMsg[NMEAmsgArrayLength];
    int msgIndex;
    char checksumMsg[2];
    int checksumIndex;
    boolean msgStart;
    boolean msgEnd;
    
    int get_checksum(char*, int);
    void checksum_hex_to_ascii(int, char*);
    boolean confirm_checksum(char*, int);
    void read_msg(char);
    void parse_msg();
    void parse_element(int, char*, int);
    void parse_element_complex(int, char*, int);
    void print_gps_data();
    void sendMsg(char, int, int);
}; // GPS CONNECT CLASS END


// GLOBAL VARIABLES
byte hrmi_addr = HRMI_I2C_ADDR;	  // I2C address to use
unsigned long currentTime = millis();
unsigned long intervalTime = 200;
unsigned long intervalStart;

// heart rate variables
int numEntries = 3;               // Number of HR values to request 
int numRspBytes;                  // Number of Response bytes to read
byte i2cRspArray[34];	          // I2C response array, sized to read 32 HR values  
int HRCount = -1;
byte accelCommand = 'A';
int accelRspBytes;               // Number of analog sensor response bytes
byte i2cAnalogArray[1];           // I2C response array for analog values, sized for single reading 

// Variables that control the heart rate alert (lights and vibrator)
boolean heartRateAlert = false;
long unsigned previousHeartRateAlert = 0;
long unsigned heartRateAlertInterval = 3600000;

// pin assignments
// analog pins 4 and 5 are used for wire connection to HRMI
int gsrPin = 0;
int buttonPin[2] = {13, 3};   
int ledPin = 4;
int vibratePin = 6;
int gpsPin[2] = {2, 12};

int gsrVal = 0;
int buttonVal[2] = {0, 0};
int ledVal = 0;

// button process variables
long intervalMin = 1500;                      // minimum length of time between the button-presses used to capture emotions 
long intervalMax = 4500;                      // maximum length of time between the button-presses used to capture emotions 
unsigned long intervalCurrent[] = {0, 0};     // time when last button-press related event happenned
int previousState[] = {LOW, LOW};             // previous of button for capturing button-press events
int checkRead[2][3] = {0, 0, 0, 0, 0, 0};     // holds status of individual button-press events to confirm if full sequence has been done correctly
boolean positiveNegative[] = {false, false};  // holds whether button press event has been accomplished fully
long emotionRecordTime = 0;                   // time when emotion activity was recorded (button-press sequence successfully completed)
long emotionReportTime = 1000;                // length of time that emotion flag should be displayed

// light and vibration control variables
long lightVibPulseLength = 400;                     // length of light and vibrarion pulse when a button-push sequence is recorded
long previousLightVibPulse = 0;
int lightVibCount = 0;
int lightVibConfirmCount = 4;
int lightVibRequestCount = 10;
boolean lightVibConfirmStart = false;
boolean vibPulseState = false;

// GPS Variables
gpsConnect myGPS = gpsConnect(gpsPin[0], gpsPin[1]);
unsigned long gpsStart;


/** SETUP FUNCTION **/
void setup() {
  hrmi_open();                                                           // Initialize the I2C communication 
  Serial.begin(SERIAL_BAUDRATE);                                      // Initialize the serial interface 
  myGPS.setupGPS(GPS_SERIAL_BAUDRATE);

  pinMode(buttonPin[0], INPUT);
  pinMode(buttonPin[1], INPUT);
  pinMode(ledPin, OUTPUT);
  pinMode(vibratePin, OUTPUT);

  intervalStart = millis();
  gpsStart = millis();

  // Print to serial the title of each data column
  print_titles();
  
  delay(1000);
}


/** LOOP FUNCTION **/
void loop() {
  timeRead();
  myGPS.readGPS();
  for (int i = 0; i < 2; i++) { buttonsReadProcess(i); }
  controlLights();    

  // if ready2read equals true then read heart rate and gsr data and print all data to serial 
  if (ready2read()) {
    timeWrite();
    gsrReadWrite();  
    heartBeatReadWrite();
    for (int i = 0; i < 3; i++) { analogInputReadWrite(i); }
    for (int i = 0; i < 2; i++) { buttonWrite(i); }
    print_gps_data();
    Serial.println(); 
  }


}


boolean ready2read () {
  if (millis() - intervalStart > intervalTime) {
      intervalStart = millis();
      return true;
  } else { return false; }
}
