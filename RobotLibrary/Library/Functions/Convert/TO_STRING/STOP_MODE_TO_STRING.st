FUNCTION STOP_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      STOP_MODE_TO_STRING                                       
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
  /// StopMode
  Value : StopMode;
END_VAR

  CASE Value 
  OF
    StopMode.STOP_ALL_SUBPROGRAMS : STOP_MODE_TO_STRING := StrReplace('STOP_ALL_SUBPROGRAMS ({0})','{0}' , USINT_TO_STRING(Value));
    StopMode.STOP_INSTANCE_ID     : STOP_MODE_TO_STRING := StrReplace('STOP_INSTANCE_ID ({0})'    ,'{0}' , USINT_TO_STRING(Value));
    StopMode.STOP_JOB_ID          : STOP_MODE_TO_STRING := StrReplace('STOP_JOB_ID ({0})'         ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    STOP_MODE_TO_STRING := CONCAT('STOP_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

