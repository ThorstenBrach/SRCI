FUNCTION CheckTimeout : DINT
VAR_INPUT
  /// Reference to TON instance
  rTimer : REFERENCE TO TON;
END_VAR

  // Call timer 
  rTimer();
  
  // check if timer elapsed
  IF (rTimer.Q = TRUE)
  THEN
    // assign return value
    CheckTimeout := RobotLibraryConstants.OK;
  ELSE
    // assign return value
    CheckTimeout := RobotLibraryConstants.RUNNING;
  END_IF

END_FUNCTION

