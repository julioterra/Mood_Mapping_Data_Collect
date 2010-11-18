
void inputRequestCheck() {
    if (millis() - lastInputRequestTime > inputRequestMinInterval || lastInputRequestTime == 0) {
        if (millis() > nextInputRequestTime) {          // check if heart rate has exceeded the heartRateThreshold
             inputRequestFlag = true;
             listenForButton = true;
             lastInputRequestTime = millis(); 
             nextInputRequestTime = random(inputRequestIntervalBandwidth) + inputRequestMinInterval + millis();
        }
    }
    if (millis() - lastHeartRateAlert > heartRateAlertInterval || lastHeartRateAlert == 0) {
        if (i2cRspArray[2] > heartRateThreshold) {          // check if heart rate has exceeded the heartRateThreshold
             inputRequestFlag = true;
             listenForButton = true;
             lastHeartRateAlert = millis();
             lastInputRequestTime = millis(); 
             nextInputRequestTime = random(inputRequestIntervalBandwidth) + inputRequestMinInterval + millis();
        }
    }
}



void controlLights () {
  int confirmVibLight = 1;
  int requestVibLight = 3;

  if (inputRequestFlag) {
      if (light_vibration_alert(requestVibLight)) { 
          inputRequestFlag = false; 
      }
  }

  if (confirmButtonDataRead) {
      if(light_vibration_alert(confirmVibLight)) { 
          confirmButtonDataRead = false; 
      }
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



