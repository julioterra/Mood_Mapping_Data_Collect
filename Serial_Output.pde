/******************************************************************************************
 * BEGIN DATA PROCESSING FUNCTIONS - begin functions that process and outputs data from arduino
 *********/


/******************************************************************************************
 * SERIAL PRINT FUNCTIONS 
 * 
 *************************/


void titlesWrite() {
  Serial.print("millis, ");
  Serial.print("gsr, "); 
  Serial.print("heart beat, ");
  Serial.print("emotion, "); 
  Serial.print("time, ");
  Serial.print("date, ");
  Serial.print("gps status, ");
  Serial.print("lattitude, ");  
  Serial.print("south or north, ");
  Serial.print("longitude, ");
  Serial.print("west or east, ");
  Serial.println();
}


void timeWrite() {
    Serial.print(currentTime);
    Serial.print(", ");
}


// GSR READ WRITE: read and print
void gsrWrite() {
    Serial.print(gsrVal);                             // print the gsr value to serial
    Serial.print(", ");                               // add a comma
}


void heartBeatWrite() {
    if (heartRateReadStatus != -1) {
        if (HRCount != i2cRspArray[1]) {                  // if a new heart beat was captured (the heart beat count has increased)
            Serial.print(i2cRspArray[2], DEC);                  // print the heart rate to serial
            HRCount = i2cRspArray[1];                           // and reset the heart count variable (which holds the number of the previous heart rate count)
        } else { Serial.print(0, DEC); }                  // if heart beat count has not increased then return "0"
    } else { Serial.print(heartRateReadStatus, DEC); }    // print -1 if not able to connect to hrmi device
    Serial.print(", ");                                   // add comma  
}

void analogHRMIWrite (int _inputNumber) { 
    if (analogReadStatus = -1) {                           // if new analog data has been received
        Serial.print(i2cAnalogArray[0], DEC);                  // print the analog value to serial port
    } else { Serial.print(analogReadStatus); }             // print -1 if not able to connect to hrmi to read analog data
    Serial.print(", ");                                    // print comma
}


// PRINT GPS DATA: print the gps data to the serial port
void gpsWrite() {
    // print all data elements on the serial port
    if (myGPS.newData) {
        publishMsg(myGPS.timeStamp, sizeof(myGPS.timeStamp));
        publishMsg(myGPS.dateStamp, sizeof(myGPS.dateStamp));
        publishMsg(myGPS.gpsStatus, sizeof(myGPS.gpsStatus));
        publishMsg(myGPS.lattitude, sizeof(myGPS.lattitude));
        publishMsg(myGPS.northSouth, sizeof(myGPS.northSouth));
        publishMsg(myGPS.longitude, sizeof(myGPS.longitude));
        publishMsg(myGPS.eastWest, sizeof(myGPS.eastWest));
        myGPS.newData = false;
    } else {
        char tempData [1] = {'0'};
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        publishMsg(tempData, sizeof(tempData));
        
    } 
}


void buttonsWrite() {
    boolean buttonStatus = false;
    for (int i = 0; i < 2; i++) { 
        if(buttonWrite(i)) buttonStatus = true; 
    }
    if (!buttonStatus) {
       if (listenForButton) Serial.print("R");
       else Serial.print("0");
    }
    Serial.print(", ");    
}


// BUTTON WRITE: read and print
boolean buttonWrite (int buttonNum) {
  if(positiveNegative[buttonNum]) {
      if (buttonNum == 0) { Serial.print("P"); }
      if (buttonNum == 1) { Serial.print("N"); }
      if (currentTime - emotionRecordTime > emotionReportTime) { 
          positiveNegative[buttonNum] = false; 
      }
      return true;
  } 
  return false;
  // else {  Serial.print("0"); }
  // Serial.print(", "); 
  
}

// OUTPUT CODE: publish the proper message to the serial port for logging
void publishMsg(char *msg, int len) {
      for(int i = 0; i < len; i++) {
          if(msg[i] == byte(13)) break;
          Serial.print(msg[i]);           
      }
      Serial.print(", ");
}

