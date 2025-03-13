FUNCTION TRIGGER_MODE_MEASUREMENT_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRIGGER_MODE_MEASUREMENT_TO_STRING                                       
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
  /// TriggerMode
  Value : TriggerModeMeasurement;
END_VAR

  CASE Value 
  OF
    TriggerModeMeasurement.NO_TRIGGER                   : TRIGGER_MODE_MEASUREMENT_TO_STRING := StrReplace('NO_TRIGGER ({0})'                   ,'{0}' , USINT_TO_STRING(Value));
    TriggerModeMeasurement.POSITIVE_START_NEGATIVE_STOP : TRIGGER_MODE_MEASUREMENT_TO_STRING := StrReplace('POSITIVE_START_NEGATIVE_STOP ({0})' ,'{0}' , USINT_TO_STRING(Value));
    TriggerModeMeasurement.POSITIVE_START_STOP          : TRIGGER_MODE_MEASUREMENT_TO_STRING := StrReplace('POSITIVE_START_STOP ({0})'          ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    TRIGGER_MODE_MEASUREMENT_TO_STRING := CONCAT('TRIGGER_MODE_MEASUREMENT_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

