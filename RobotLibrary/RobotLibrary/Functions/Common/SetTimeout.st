FUNCTION SetTimeout : DINT
VAR_INPUT
  /// Timeout to be set
  PT     : TIME;
  /// Reference to TON instance
  rTimer : REFERENCE TO TON;
END_VAR

  rTimer(IN := FALSE);          // Reset timer
  rTimer(PT := PT, IN := TRUE); // Start timer
  
  // assign return value
  SetTimeout := RobotLibraryConstants.OK;

END_FUNCTION

