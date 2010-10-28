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

