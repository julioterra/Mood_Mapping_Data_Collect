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


// **********************
// *** GPS CONNECT CLASS: Reads and parses data from the GPS unit
// **********************
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
}; 
// **********************



  // GLOBAL VARIABLES
  byte hrmi_addr = HRMI_I2C_ADDR;	  // I2C address to use
  unsigned long currentTime = millis();
  unsigned long intervalTime = 200;
  unsigned long intervalStart;
  
  // variables for reading data from hrmi
  byte i2cRspArray[34];	            // I2C response array, sized to read 32 HR values  
  int numEntries = 3;               // Number of HR values to request 
  int numRspBytes;                  // Number of Response bytes to read
  int HRCount = -1;                 // number assigned to each heart rate (cycles every 200 beats)
  int heartRateReadStatus = -1;     // status variable used to flag when there is an issue with reading heart rate data
  byte i2cAnalogArray[1];           // I2C response array for analog values, sized for single reading 
  int analogReadStatus = -1;        // status variable used to flag when there is an issue with reading analog data from hrmi
  
  // Variables that control the data request and heart rate alert (lights and vibrator)
  #define inputRequestMinInterval         2400000
  #define inputRequestIntervalBandwidth   2400000
  #define inputRequestRespondTime         60000
  #define inputResponseLength             5000

  boolean heartRateAlert = false;
  long unsigned lastHeartRateAlert = 0;
  long unsigned heartRateAlertInterval = 3600000;
  long unsigned lastInputRequestTime = 0;
  long unsigned nextInputRequestTime = 0;
  boolean inputRequestFlag = false;
  boolean listenForButton = false;
  boolean confirmButtonDataRead = false;

  // variables related to reading input from the buttons in response to the data request  
  long unsigned inputResponseStartTime = 0;
  boolean inputResponseStarted = false;
  
  // pin assignments - analog pins 4 and 5 are used for wire connection to HRMI
  int gsrPin = 0;
  int buttonPin[2] = {13, 3};   
  int ledPin = 4;
  int vibratePin = 6;
  int gpsPin[2] = {2, 12};
  
  // variables that holds values from input pins
  int gsrVal = 0;
  
  // button process variables
  int buttonVal[] = {LOW, LOW};
  int previousState[] = {LOW, LOW};             // previous of button for capturing button-press events
  boolean positiveNegative[] = {false, false};  // holds whether button press event has been accomplished fully
  long emotionRecordTime = 0;                   // time when emotion activity was recorded (button-press sequence successfully completed)
  long emotionReportTime = 2000;                // length of time that emotion flag should be displayed
  
  // light and vibration control variables
  long lightVibPulseLength = 400;               // length of light and vibrarion pulse when a button-push sequence is recorded
  long previousLightVibPulse = 0;
  int lightVibCount = 0;
  int lightVibConfirmCount = 4;
  int lightVibRequestCount = 10;
  boolean lightVibConfirmStart = false;
  boolean vibPulseState = false;
  
  // GPS Variables
  gpsConnect myGPS = gpsConnect(gpsPin[0], gpsPin[1]);
  unsigned long gpsStart;


// ********************
// * SETUP FUNCTION 
// ********************
void setup() {
    hrmi_open();                                                  // Initialize the I2C communication 
    Serial.begin(SERIAL_BAUDRATE);                                // Initialize the serial interface 
    myGPS.setupGPS(GPS_SERIAL_BAUDRATE);
  
    // initialize pins
    pinMode(buttonPin[0], INPUT);
    pinMode(buttonPin[1], INPUT);
    pinMode(ledPin, OUTPUT);
    pinMode(vibratePin, OUTPUT);
  
    intervalStart = millis();
    gpsStart = millis();
    nextInputRequestTime = random(inputRequestIntervalBandwidth);
    
    // Print to serial the title of each data column
    titlesWrite();
    
    delay(1000);
}


// ********************
// * LOOP FUNCTION 
// ********************
void loop() {
    timeRead();
    myGPS.readGPS();
  
    // if ready2read equals true then read heart rate and gsr data and print all data to serial 
    if (ready2read()) {
        inputRequestCheck();
        controlLights();    
        buttonsResponseRead();
        
        gsrRead();  
        heartBeatRead();
        
        timeWrite();
        gsrWrite();  
        heartBeatWrite();
        buttonsWrite();
        gpsWrite();
        Serial.println(); 
    }

}


boolean ready2read () {
  if (millis() - intervalStart > intervalTime) {
      intervalStart = millis();
      return true;
  } else { return false; }
}
