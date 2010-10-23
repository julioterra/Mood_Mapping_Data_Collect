/******************************************************************************************
 * BEGIN DATA FUNCTIONS - begin functions that read data from arduino
 *********/

// GSR: read and print
void gsrRead() {
    gsrVal = analogRead(gsrPin);
    Serial.print(gsrVal);
    Serial.print(", ");
}

// Heart Rate: read and print
void heartBeatRead() {  
    hrmiCmdArg(hrmi_addr, 'G', (byte) numEntries);      // Request a set of heart rate values 
    numRspBytes = numEntries + 2;                       // Get the response from the HRMI
    if (hrmiGetData(hrmi_addr, numRspBytes, i2cRspArray) != -1) {
      // send the results via the serial interface in ASCII form 
      if (HRCount != i2cRspArray[1]) {                  // if the heart beat count does not equal the count of the current heart beat
        Serial.print(i2cRspArray[2], DEC);                  // then print the heart beat to serial
        HRCount = i2cRspArray[1];                           // and reset the heart count variable
      } else { Serial.print(0, DEC); }                  // if heart beat count does equal count of current heart rate than print "0"
    } 
}

void analogInputRead(int _inputNumber){
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

/*********
 * END DATA FUNCTIONS - end functions that read data from arduino
 ******************************************************************************************/
