  GsrFilter::GsrFilter() {
      gsr_raw = 0;
      gsr_filtered = 0;
      startupCounter = 0;
      maxStartupCounter = 200;
      timeElapsed = 0;
      previousMillis = 0;
      dataBuffer = 0.0;  // current skin resistance value
      meanData = 0.0;    // average skin resistance value
      smoothPeriod = 1.0;
      maxTimeSmoothPeriod = 50;
      normPeriod = 1.0;
      maxTimeNormPeriod = 100;
  }

  float GsrFilter::apply_highpass(unsigned int tempData) {
      unsigned long currentMillis = millis();
      unsigned long timeElapsed = currentMillis-previousMillis;
      gsr_raw = tempData;

      // DATA SMOOTHING
      // add new gsr_reading, weighted, into the databuffer     
      dataBuffer = dataBuffer * (smoothPeriod-1.0);   
      dataBuffer = dataBuffer + ((float) tempData);
      dataBuffer = dataBuffer/smoothPeriod;
      if (smoothPeriod < maxTimeSmoothPeriod) smoothPeriod = smoothPeriod + 1.0;

      // DATA AVERAGING
      // average the data to calculate baseline skin resistance    
      else {
          meanData = meanData*(normPeriod-1.0);
          meanData = meanData + dataBuffer;
          meanData = meanData/normPeriod;
          if (normPeriod-maxTimeSmoothPeriod < maxTimeNormPeriod) normPeriod = normPeriod + 1.0;
      }    

      // if startup is not complete print calibrating
      if (startupCounter < maxStartupCounter) {
          startupCounter++;
          return 0;
      }
      // else print the latest readings and calculations 
      else {
        gsr_filtered = meanData - dataBuffer;
        return gsr_filtered;
      }
  }

  void GsrFilter::print_all_serial() {
      print_serial("time: ", timeElapsed);
      print_serial("gsr val: ", gsr_raw);
      print_serial("dataBuffer: ", dataBuffer);
      print_serial("meanData: ", meanData);
      Serial.println(gsr_filtered, 5);
  }
  
  void GsrFilter::print_serial(String _name, long _value) {
      Serial.print(_name);
      Serial.print(": ");
      Serial.print(_value, DEC);
      Serial.print(" ");
  }
