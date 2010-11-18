
void inputRequestCheck() {
    // check if it is time to request input
     if (millis() > nextInputRequestTime) {  
          inputRequestFlag = true;                        // set the input request flag to true
          listenForButton = true;                         // set the listen for button flag to true
          lastInputRequestTime = millis();                // set the current time as the time of the last input request

          // calculate the time for the next input request
          nextInputRequestTime = random(inputRequestIntervalBandwidth) + inputRequestMinInterval + millis();
     }

     // check if enough time has passed since last heart rate alert
     if (millis() - lastHeartRateAlert > heartRateAlertInterval || lastHeartRateAlert == 0) {
         if (i2cRspArray[2] > heartRateThreshold) {          // check if heart rate has exceeded the heartRateThreshold
              inputRequestFlag = true;                       // set the input request flag to true
              listenForButton = true;                        // set the listen for button flag to true
              lastInputRequestTime = millis();               // set the current time as the time of the last input request
              lastHeartRateAlert = millis();                 // set the current time as the time of the last heart rate alert

              // calculate the time for the next input request
              nextInputRequestTime = random(inputRequestIntervalBandwidth) + inputRequestMinInterval + millis();
         }
     }
}



void controlLights () {
  int confirmVibLight = 1;
  int requestVibLight = 3;

  if (inputRequestFlag) {
      if (light_vibration_alert(requestVibLight)) { inputRequestFlag = false; }
  }

  if (confirmButtonDataRead) {
      if(light_vibration_alert(confirmVibLight)) { confirmButtonDataRead = false; }
   }
}


// LIGHT VIBRATION ALERT FUNCTION
boolean light_vibration_alert(int _totalPulses) {
    int totalPulses = _totalPulses;
    if (lightVibCount == totalPulses) { 
        vibPulseState = false;
        lightVibCount = 0; 
        digitalWrite(ledPin, LOW);
        digitalWrite(vibratePin, LOW);
        return true; 
    } else if (lightVibCount < totalPulses) {
        if (currentTime - previousLightVibPulse > lightVibPulseLength) {
             if (!vibPulseState) {
                  digitalWrite(ledPin, HIGH);
                  digitalWrite(vibratePin, HIGH);
                  vibPulseState = true;
                  previousLightVibPulse = currentTime;
              } else { 
                  digitalWrite(ledPin, LOW);
                  digitalWrite(vibratePin, LOW);
                  vibPulseState = false;
                  previousLightVibPulse = currentTime;
                  lightVibCount++;
              }
        }
    } 
    return false;
}



