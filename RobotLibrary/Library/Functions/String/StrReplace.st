/// Returns a given string where a given substing is replaced by another substring
FUNCTION StrReplace : STRING(255)
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SwapBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-18
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
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

