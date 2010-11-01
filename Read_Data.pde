/******************************************************************************************
 * BEGIN DATA READ FUNCTIONS - begin functions that read data from arduino and communicates status via serial
 *********/

// TIME READ WRITE: read and print
void timeRead() {
    currentTime = millis();
}


// GSR READ WRITE: read and print
void gsrReadWrite() {
    gsrVal = analogRead(gsrPin);
    Serial.print(gsrVal);
    Serial.print(", ");
}


// HRMI HEART BEAT READ WRITE: read and print
void heartBeatReadWrite() {  
    hrmiCmdArg(hrmi_addr, 'G', (byte) numEntries);      // Request a set of heart rate values 
    numRspBytes = numEntries + 2;                       // Get the response from the HRMI
    if (hrmiGetData(hrmi_addr, numRspBytes, i2cRspArray) != -1) {
      // send the results via the serial interface in ASCII form 
      if (HRCount != i2cRspArray[1]) {                  // if the heart beat count does not equal the count of the current heart beat
        Serial.print(i2cRspArray[2], DEC);                  // then print the heart beat to serial
        HRCount = i2cRspArray[1];                           // and reset the heart count variable
      } else { Serial.print(0, DEC); }                  // if heart beat count does equal count of current heart rate than print "0"
    Serial.print(", "); 
    } 
    if (i2cRspArray[2] > heartRateThreshold) {
      if (currentTime - previousHeartRateAlert > heartRateAlertInterval || previousHeartRateAlert == 0) {
          heartRateAlert = true;
          previousHeartRateAlert = currentTime;
      }
    }
}


// HRMI ANALOG INPUT READ WRITE: read and print
void analogInputReadWrite(int _inputNumber){
    // convert data from serial to a byte value 
    byte inputNumber = byte(_inputNumber);           
    inputNumber = inputNumber - 48;                      

    // send the request for accelerometer data to the HRMI interface
    hrmiCmdArg(hrmi_addr, (byte) accelCommand, _inputNumber);    
    accelRspBytes = 1;                              // set number of expected responses
    if (hrmiGetData(hrmi_addr, accelRspBytes, i2cAnalogArray) != -1) {
       Serial.print(byte(_inputNumber));
       Serial.print(i2cAnalogArray[0], DEC);
       Serial.print(", ");
    }
}


// BUTTON READ PROCESS: read and print
void buttonsReadProcess (int buttonNum) {
  // logic: for a button read user needs to press button for 2 - 3 seconds, release for 2 - 3 seconds, and press again for 2 - 3 seconds

  buttonVal[buttonNum] = digitalRead(buttonPin[buttonNum]);

  // if button has just been pressed
  if (buttonVal[buttonNum] == HIGH && previousState[buttonNum] == LOW) { 
      // if no logic requirements had been met then start the interval counter
      previousState[buttonNum] = HIGH; 
      int intervalActual = currentTime - intervalCurrent[buttonNum];
      if (checkRead[buttonNum][0] == 0) { 
          intervalCurrent[buttonNum] = currentTime; 
        }

      // if the first button requirement has been met and the interval time meets requirements
      else if (checkRead[buttonNum][0] == 1 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
          checkRead[buttonNum][1] = 1;
          intervalCurrent[buttonNum] = currentTime;

      // otherwise re-initialize the requirements array and interval time counter
      } else {
          for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
          intervalCurrent[buttonNum] = 0;
      }  
        
  // if button has just been released
  } else if (buttonVal[buttonNum] == LOW && previousState[buttonNum] == HIGH) { 
      previousState[buttonNum] = LOW; 
      int intervalActual = currentTime - intervalCurrent[buttonNum];

      // if the first requirement is not set to true and the interval time meets requirements
      if (checkRead[buttonNum][0] == 0 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
          checkRead[buttonNum][0] = 1;
          intervalCurrent[buttonNum] = currentTime;

      // if the second requirement is not set to true and the interval time meets requirements
      } else if (checkRead[buttonNum][1] == 1 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
          checkRead[buttonNum][2] = 1;

      // otherwise re-initialize the requirements array and interval time counter
      } else { 
          for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
          intervalCurrent[buttonNum] = 0;
      }  
  }

  // checks if the button press requirements have been met for either positive or negative emotions and sets proper variables
  if(checkRead[buttonNum][0] == 1 && checkRead[buttonNum][1] == 1 && checkRead[buttonNum][2] == 1) {
      positiveNegative[buttonNum] = true;
      emotionRecordTime = currentTime;
      for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
      intervalCurrent[buttonNum] = 0;
  }
}

/*********
 * END DATA FUNCTIONS - end functions that read data from arduino
 ******************************************************************************************/
