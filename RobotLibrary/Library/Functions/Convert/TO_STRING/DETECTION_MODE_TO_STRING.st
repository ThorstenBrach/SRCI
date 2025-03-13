FUNCTION DETECTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DETECTION_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-01
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
  /// DetectionMode
  Value : DetectionMode;
END_VAR

  CASE Value 
  OF
    DetectionMode.TORQUE             : DETECTION_MODE_TO_STRING := StrReplace('TORQUE ({0})'             ,'{0}' , USINT_TO_STRING(Value));
    DetectionMode.FORCE              : DETECTION_MODE_TO_STRING := StrReplace('FORCE ({0})'              ,'{0}' , USINT_TO_STRING(Value));
    DetectionMode.ELECTRICAL_CURRENT : DETECTION_MODE_TO_STRING := StrReplace('ELECTRICAL_CURRENT ({0})' ,'{0}' , USINT_TO_STRING(Value));
    DetectionMode.FOLLOWING_ERROR    : DETECTION_MODE_TO_STRING := StrReplace('FOLLOWING_ERROR ({0})'    ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    DETECTION_MODE_TO_STRING := CONCAT('DETECTION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

