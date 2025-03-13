FUNCTION LIMIT_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LIMIT_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-24
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// LimitMode
  Value : LimitMode;
END_VAR

  CASE Value 
  OF
    LimitMode.LIMIT_DEFINED    : LIMIT_MODE_TO_STRING := StrReplace('LIMIT_DEFINED ({0})'    ,'{0}' , USINT_TO_STRING(Value));
    LimitMode.NO_LIMIT_DEFINED : LIMIT_MODE_TO_STRING := StrReplace('NO_LIMIT_DEFINED ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    LIMIT_MODE_TO_STRING := CONCAT('LIMIT_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

