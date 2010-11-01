/******************************************************************************************
 * BEGIN DATA PROCESSING FUNCTIONS - begin functions that process and outputs data from arduino
 *********/

void controlLights () {
  if (heartRateAlert) {
      if (light_vibration_alert(lightVibRequestCount)) {
          heartRateAlert = false;  
      }    
  }

  if (lightVibConfirmStart) {
      if (light_vibration_alert(lightVibConfirmCount)) {
          lightVibConfirmStart = false;  
      }
   }
}


// LIGHT VIBRATION ALERT FUNCTION
boolean light_vibration_alert(int totalPulses) {
    if (lightVibCount == 0) {
        previousLightVibPulse = currentTime;
        digitalWrite(ledPin, HIGH);
        digitalWrite(vibratePin, HIGH);
        vibPulseState = true;
        lightVibCount++;
    } else if (lightVibCount < totalPulses) {
        if (currentTime - previousLightVibPulse > lightVibPulseLength) {
           if (vibPulseState) {
                digitalWrite(ledPin, LOW);
                digitalWrite(vibratePin, LOW);
                vibPulseState = false;
                previousLightVibPulse = currentTime;
              } else { 
                digitalWrite(ledPin, HIGH);
                digitalWrite(vibratePin, HIGH);
                vibPulseState = true;
                previousLightVibPulse = currentTime;
             }
             lightVibCount++;
       }
    } else { 
         lightVibCount = 0; 
         return true;
    }
    return false;
}


void print_titles() {
  Serial.print("millis, ");
  Serial.print("gsr, "); 
  Serial.print("heart beat, ");
  Serial.print("accel x, accel y, accel z, "); 
  Serial.print("button 1, ");
  Serial.print("button 2, ");
  Serial.print("time gps, ");
  Serial.print("lattitude, ");
  Serial.print("south or north, ");
  Serial.print("longitude, ");
  Serial.print("west or east, ");
  Serial.print("fix time, ");
  Serial.println();
}


// BUTTON WRITE: read and print
void buttonWrite (int buttonNum) {
  if(positiveNegative[buttonNum]) {
     if (buttonNum == 0) { Serial.print("P"); }
     if(buttonNum == 1) { Serial.print("N"); }
     lightVibConfirmStart = true;
  } else { Serial.print("0"); }
  Serial.print(", "); 
  if (currentTime - emotionRecordTime > emotionReportTime) {positiveNegative[buttonNum] = false;}
}


void timeWrite() {
    Serial.print(currentTime);
    Serial.print(", ");
}


// PRINT GPS DATA: print the gps data to the serial port
void print_gps_data() {
    // print all data elements on the serial port
    if (myGPS.newData) {
        publishMsg(myGPS.timeStamp, sizeof(myGPS.timeStamp));
        publishMsg(myGPS.lattitude, sizeof(myGPS.lattitude));
        publishMsg(myGPS.longitude, sizeof(myGPS.longitude));
        publishMsg(myGPS.lastValidReading, sizeof(myGPS.lastValidReading));
        myGPS.newData = false;
    } else {
        char tempData [1] = {'0'};
        publishMsg(tempData, 1);
        publishMsg(tempData, 1);
        publishMsg(tempData, 1);
        publishMsg(tempData, 1);
    } 
}


// OUTPUT CODE: publish the proper message to the serial port for logging
void publishMsg(char msg[], int len) {
      for(int i = 0; i < len; i++) {
          if(msg[i] != byte(13)) Serial.print(msg[i]); 
          else break;
      }
      Serial.print(',');
}

