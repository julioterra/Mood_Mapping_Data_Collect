/******************************************************************************************
 * START WIRE FUNCTIONS - start functions that leverage wire library set-up and data requests 
 *********/

// hrmi_open: initialize the I2C library - this routine must be called before attempting to communicate with I2C 
static void hrmi_open() {
  Wire.begin();
}

// function that sends command requests with arguments to HRMI
static void hrmiCmdArg(byte addr, byte cmd, byte arg) {
  Wire.beginTransmission(addr); 
  Wire.send(cmd); 
  Wire.send(arg); 
  Wire.endTransmission(); 
}

// function that sends command requests without arguments to HRMI
static void hrmiCmd(byte addr, byte cmd) {
  Wire.beginTransmission(addr); 
  Wire.send(cmd); 
  Wire.endTransmission();
}

// function reads the specified number of bytes from HRMI
static int hrmiGetData(byte addr, byte numBytes, byte* dataArray) {
  Wire.requestFrom(addr, numBytes); 
  if (Wire.available()) {
    for (int i=0; i<numBytes; i++) dataArray[i] = Wire.receive();
    return(0); 
  }
  return(-1);
} 
  
/*********
 * END WIRE FUNCTIONS - end functions that leverage wire library set-up and data requests 
 ******************************************************************************************/

