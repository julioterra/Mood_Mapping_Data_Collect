/************************************************************************
 * SETUP GPS - initialize variables 
 ************/
void gpsConnect::setupGPS(int baudRate) {
  mySerial.begin(baudRate);     // initialize serial port for GPS
  
  //  for (int i = 0; i < sizeof(lastValidReading); i++) {lastValidReading[i] = '0';}
  msgIndex = 0;
  checksumIndex = 0;
  msgStart = false;
  msgEnd = false;
  locValid = false;
}


/************************************************************************
 * READ FUNCTION - read data from the GPS unit 
 ************/
void gpsConnect::readGPS()                     
{
  if (mySerial.available()) { read_msg((char)mySerial.read()); }
}


/************************************************************************
 * GET_CHECKSUM FUNCTION - calculates the checksum of messages to be sent 
 ************/
int gpsConnect::get_checksum(char msg[], int len) {

  byte checksum = 0;                                   // create checksum variable and set it to 0
  for (int i = 0; i < len; i++) {                      // loop through each element in the message
    if (msg[i] == '$') {                               // IF start characters is found ('$')
      i++; checksum = msg[i]; }                            // set the checksum to using the first character in the message
    else if (msg[i] == '*') { break; }                 // ELSE IF the end of the message has been found ('*') get out of the loop
    else { checksum ^= msg[i]; }                       // ELSE IF msgStarted is set to true then calculate the checksum
  }    
  return checksum;                                        // return the checksum
}


/***********************************************************************
 * GET_HEX_TO_ASCII FUNCTION - converts the checksum integer into two 
 * chars that are the hexidecimal representation
 ***********/
void gpsConnect::checksum_hex_to_ascii(int checkInt, char *checkSum) {
  int highBit = checkInt/16;
    if (highBit > 9) { checkSum[0] = char(highBit - 9) + byte(96); } 
    else {checkSum[0] = char(highBit) + byte(48); }
  int lowBit = checkInt - (highBit*16);
    if (lowBit > 9) { checkSum[1] = char(lowBit - 9) + byte(96); } 
    else {checkSum[1] = char(lowBit) + byte(48); }
}


/***********************************************************************
 * CONFIRM_CHECKSUM FUNCTION - converts the checksum integer into two 
 * chars that are the hexidecimal representation
 ************/
boolean gpsConnect::confirm_checksum(char msg[], int len){
  char hexChecksumCalc [2] = {0,0}; 
  char hexChecksumOrig [2] = {0,0}; 
  int checksumPos = 0;
  int tempChecksum = 0;
  
  tempChecksum = get_checksum(msg, len);
  checksum_hex_to_ascii(tempChecksum, hexChecksumCalc);

  for(int i = 0; i < len; i++) { if (msg[i] == '*') checksumPos = i + 1; }
  hexChecksumOrig[0] = msg[checksumPos];
  hexChecksumOrig[1] = msg[checksumPos+1];

  if (hexChecksumCalc[0] == hexChecksumOrig[0] && hexChecksumCalc[0] == hexChecksumOrig[0]) 
    return true;
  return false;  
}

/***********************************************************************
 * READ MESSAGE FUNCTION - reads incoming message and examines the checksum.
 * If checksum is true then parse message.
 ************/
void gpsConnect::read_msg(char newChar) {
  if(msgStart == false && newChar == '$') {
      msgStart = true;
      msgEnd = false;
      msgIndex = 0;
      nmeaMsg[msgIndex] = newChar;
      msgIndex++;    
  } else if (msgStart == true && msgEnd == false) {
     if (newChar != byte(10)) {
          nmeaMsg[msgIndex] = newChar;
          msgIndex++;    
      }  else if (newChar == byte(10)) { msgEnd = true; }
  } else if (msgStart == true && msgEnd == true) {
      if (confirm_checksum(nmeaMsg, sizeof(nmeaMsg))) {
         parse_msg();
      } 
      msgStart = false;
  }
}


/***********************************************************************
 * PARSE MESSAGE FUNCTION - parses location information and time from the
 * GGA messages sent by the GPS module.
 ************/
void gpsConnect::parse_msg() {
    // parse all elements into the appropriate variables
    parse_element(GGAtimeLoc, timeStamp, sizeof(timeStamp));
    parse_element(GGAlattitudeLoc, lattitude, sizeof(lattitude));
    parse_element(GGAlongitudeLoc, longitude, sizeof(longitude));
    if (nmeaMsg[GGAfixValidLoc] == '1' || nmeaMsg[GGAfixValidLoc] == '2') { 
        for (int i = 0; i < sizeof(timeStamp); i++) lastValidReading[i] = timeStamp[i]; }
    else { locValid = false; }

    newData = true;

    /***************************
     * REMOVE PRINT ELEMENTS ONCE CODE IS UPDATED
     ***************************/
//    print_gps_data();
//    Serial.println();

}


/***********************************************************************
 * PARSE ELEMENT FUNCTION - parses individual elements from GGA messages
 * when provided with the index location, length of the data and an array
 * pointer to where the data will be saved
 ************/
void gpsConnect::parse_element(int indexLoc, char *elementArray, int arrayLength) {
    for(int i = 0; i < arrayLength; i++) { elementArray[i] = nmeaMsg[i + indexLoc]; }
}



