/// Returns the given string, filled up on the right side to the given total length with the given substring
FUNCTION StrPadRight : STRING(255)
VAR_INPUT
  /// content string
  Str    : STRING(255);
  /// sub string
  SubStr : STRING(255);
  /// Length
  Length : INT; 
END_VAR

  WHILE(LEN(Str) < Length)
  DO
   Str := CONCAT(Str, SubStr);
  END_WHILE
  
  StrPadRight := Str;

END_FUNCTION

