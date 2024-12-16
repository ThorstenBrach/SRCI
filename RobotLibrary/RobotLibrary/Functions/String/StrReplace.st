/// Returns a given string where a given substing is replaced by another substring
FUNCTION StrReplace : STRING(255)
VAR_INPUT
  /// content string
  Str      : STRING(255);
  /// sub string with the old characters
  SubStr1  : STRING(255);
  /// sub string with the new characters
  SubStr2  : STRING(255);
END_VAR

  WHILE (FIND(Str, SubStr1) > 0)
  DO  
    Str := Replace(Str, SubStr2, LEN(SubStr1), FIND(Str, SubStr1)); 
  END_WHILE
  
  StrReplace := Str;

END_FUNCTION

