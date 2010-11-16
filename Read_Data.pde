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


// HRMI ANALOG INPUT READ: read input from HRMI
void analogHRMIRead(int _inputNumber){
    int accelRspBytes = 1;                       // Number of analog sensor response bytes expected from accelerometer
    byte accelCommand = 'A';                     // the command id for reading analog data from hrmi
    byte inputNumber = byte(_inputNumber);       // convert data from serial to a byte value         
    inputNumber = inputNumber - 48;                      
    // send the request for accelerometer data to the HRMI interface
    hrmiCmdArg(hrmi_addr, (byte) accelCommand, _inputNumber);    
    analogReadStatus = hrmiGetData(hrmi_addr, accelRspBytes, i2cAnalogArray);
}



// BUTTON READ PROCESS: read and print
void buttonResponseRead (int buttonNum) {

  if (listenForButton) {

      buttonVal[buttonNum] = digitalRead(buttonPin[buttonNum]);  

      if (buttonVal[buttonNum] == HIGH) {
         if (lastButtonState[buttonNum] == LOW) { 
            lastButtonState[buttonNum] = HIGH; 
            buttonPressTime = millis();
         } else if ((millis() - buttonPressTime) > buttonPressLength) {
             positiveNegative[buttonNum] = true;
             confirmButtonDataRead = true;
             listenForButton = false;
             emotionRecordTime = currentTime;
        }
      } else { lastButtonState[buttonNum] = LOW; } 
            
      if ((millis() - lastHeartRateAlert) > inputInterval && (millis() - lastInputRequestTime) > inputInterval) {
          listenForButton = false;
      }

  }
}


/*********
 * END DATA FUNCTIONS - end functions that read data from arduino
 ******************************************************************************************/
