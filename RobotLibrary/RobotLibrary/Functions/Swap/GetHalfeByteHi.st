FUNCTION GetHalfeByteHi : BYTE
VAR_INPUT
  /// Increase payload pointer 
  Value : BYTE;
END_VAR

  GetHalfeByteHi.0 := Value.4;
  GetHalfeByteHi.1 := Value.5;
  GetHalfeByteHi.2 := Value.6;
  GetHalfeByteHi.3 := Value.7;

END_FUNCTION

