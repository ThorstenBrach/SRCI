/// Returns the given string, filled up on the right side to the given total length with the given substring
FUNCTION StrPadRight : STRING(255)
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

