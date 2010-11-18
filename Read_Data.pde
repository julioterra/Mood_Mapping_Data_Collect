/******************************************************************************************
 * BEGIN DATA READ FUNCTIONS - begin functions that read data from arduino and communicates status via serial
 *********/

// TIME READ WRITE: read and print
void timeRead() {
    currentTime = millis();
}


// GSR READ: read and print
void gsrRead() {
    gsrVal = analogRead(gsrPin);
}


// HRMI HEART BEAT READ WRITE: read and print
void heartBeatRead() {  
    hrmiCmdArg(hrmi_addr, 'G', (byte) numEntries);      // Request a set of heart rate values 
    numRspBytes = numEntries + 2;                       // Get the response from the HRMI
    heartRateReadStatus = hrmiGetData(hrmi_addr, numRspBytes, i2cRspArray);
}


// HRMI ANALOG INPUT READ WRITE: read and print
void analogInputRead(int _inputNumber){
    int accelRspBytes = 1;                       // Number of analog sensor response bytes expected from accelerometer
    byte accelCommand = 'A';                     // the command id for reading analog data from hrmi
    byte inputNumber = byte(_inputNumber);       // convert data from serial to a byte value         
    inputNumber = inputNumber - 48;                      
    // send the request for accelerometer data to the HRMI interface
    hrmiCmdArg(hrmi_addr, (byte) accelCommand, _inputNumber);    
    analogReadStatus = hrmiGetData(hrmi_addr, accelRspBytes, i2cAnalogArray);
}


void buttonsResponseRead () {
    for (int i = 0; i < 2; i++) { buttonResponseRead(i); }
}

void buttonResponseRead(int buttonNum) {  
  if (listenForButton) {
      buttonVal[buttonNum] = digitalRead(buttonPin[buttonNum]);
      if(buttonVal[buttonNum] == HIGH) {
          if (previousState[buttonNum] == LOW) {
              inputResponseStartTime = millis();
              inputResponseStarted = true; 
              previousState[buttonNum] = HIGH;
          } else if (previousState[buttonNum] == HIGH) { 
               if(millis() - inputResponseStartTime > inputResponseLength) { 
                   confirmButtonDataRead = true;
                   positiveNegative[buttonNum] = true;
                   emotionRecordTime = millis();
                   inputResponseStarted = false;
                   listenForButton = false;
               }
          }
      } else {
          inputResponseStarted = false;
          positiveNegative[buttonNum] = false;
          previousState[buttonNum] = LOW;
      }
  } 
  
  if (millis() - lastInputRequestTime > inputRequestRespondTime) { 
      listenForButton = false;
  }
}


/*********
 * END DATA FUNCTIONS - end functions that read data from arduino
 ******************************************************************************************/
