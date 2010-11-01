/******************************************************************************************
 * BEGIN DATA PROCESSING FUNCTIONS - begin functions that process and outputs data from arduino
 *********/


void controlLights () {
  // turn on light if either button pressed
  if (buttonVal[0] == HIGH || buttonVal[1] == HIGH) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }
  
  // New Logic Notes:
  
  // if heart rate or galvanic skin response exceeds a given threshold 
      // make lights blink on and off every second until one of the following things happens
          // 1. user inputs a positive or negative emotion selection
          // 2. the heart rate or galvanic skin response dips below the threshold
      // only request another response if the vitals have gone below threshold and at least 30 minutes have passed
          
  // if a new positive or negative emotion reading is captured then
      // blink button three times a second for 5 seconds
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

