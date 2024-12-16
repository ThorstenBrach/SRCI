FUNCTION GetHalfeByteLo : BYTE
VAR_INPUT
  /// Increase payload pointer 
  Value : BYTE;
END_VAR

  GetHalfeByteLo.0 := Value.0;
  GetHalfeByteLo.1 := Value.1;
  GetHalfeByteLo.2 := Value.2;
  GetHalfeByteLo.3 := Value.3;

END_FUNCTION

