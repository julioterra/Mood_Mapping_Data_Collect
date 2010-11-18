// button process variables
//  long intervalMin = 1500;                      // minimum length of time between the button-presses used to capture emotions 
//  long intervalMax = 4500;                      // maximum length of time between the button-presses used to capture emotions 
//  unsigned long intervalCurrent[] = {0, 0};     // time when last button-press related event happenned
//  int checkRead[2][3] = {0, 0, 0, 0, 0, 0};     // holds status of individual button-press events to confirm if full sequence has been done correctly


//// BUTTON READ PROCESS: read and print
//void buttonsReadPattern (int buttonNum) {
//    // logic: for a button read user needs to press button for 2 - 3 seconds, release for 2 - 3 seconds, and press again for 2 - 3 seconds
//  
//    buttonVal[buttonNum] = digitalRead(buttonPin[buttonNum]);
//  
//    // if button has just been pressed
//    if (buttonVal[buttonNum] == HIGH && previousState[buttonNum] == LOW) { 
//        // if no logic requirements had been met then start the interval counter
//        previousState[buttonNum] = HIGH; 
//        int intervalActual = currentTime - intervalCurrent[buttonNum];
//        if (checkRead[buttonNum][0] == 0) { 
//            intervalCurrent[buttonNum] = currentTime; 
//          }
//  
//        // if the first button requirement has been met and the interval time meets requirements
//        else if (checkRead[buttonNum][0] == 1 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
//            checkRead[buttonNum][1] = 1;
//            intervalCurrent[buttonNum] = currentTime;
//  
//        // otherwise re-initialize the requirements array and interval time counter
//        } else {
//            for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
//            intervalCurrent[buttonNum] = 0;
//        }  
//          
//    // if button has just been released
//    } else if (buttonVal[buttonNum] == LOW && previousState[buttonNum] == HIGH) { 
//        previousState[buttonNum] = LOW; 
//        int intervalActual = currentTime - intervalCurrent[buttonNum];
//  
//        // if the first requirement is not set to true and the interval time meets requirements
//        if (checkRead[buttonNum][0] == 0 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
//            checkRead[buttonNum][0] = 1;
//            intervalCurrent[buttonNum] = currentTime;
//  
//        // if the second requirement is not set to true and the interval time meets requirements
//        } else if (checkRead[buttonNum][1] == 1 && intervalActual >= intervalMin && intervalActual <= intervalMax) {
//            checkRead[buttonNum][2] = 1;
//  
//        // otherwise re-initialize the requirements array and interval time counter
//        } else { 
//            for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
//            intervalCurrent[buttonNum] = 0;
//        }  
//    }
//  
//    // checks if the button press requirements have been met for either positive or negative emotions and sets proper variables
//    if(checkRead[buttonNum][0] == 1 && checkRead[buttonNum][1] == 1 && checkRead[buttonNum][2] == 1) {
//        positiveNegative[buttonNum] = true;
//        emotionRecordTime = currentTime;
//        for (int j = 0; j < 3; j++) checkRead[buttonNum][j] = 0; 
//        intervalCurrent[buttonNum] = 0;
//    }
//}

