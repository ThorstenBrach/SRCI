FUNCTION SENSOR_CONNECTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SENSOR_CONNECTION_MODE_TO_STRING                                       
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
  /// SensorConnectionMode
  Value : SensorConnectionMode;
END_VAR

  CASE Value 
  OF
    SensorConnectionMode.RC_SENSOR_ALGORITHM     : SENSOR_CONNECTION_MODE_TO_STRING := StrReplace('RC_SENSOR_ALGORITHM ({0})'     ,'{0}' , USINT_TO_STRING(Value));
    SensorConnectionMode.PLC_SENSOR_RC_ALGORITHM : SENSOR_CONNECTION_MODE_TO_STRING := StrReplace('PLC_SENSOR_RC_ALGORITHM ({0})' ,'{0}' , USINT_TO_STRING(Value));
    SensorConnectionMode.PLC_SENSOR_ALGORITHM    : SENSOR_CONNECTION_MODE_TO_STRING := StrReplace('PLC_SENSOR_ALGORITHM ({0})'    ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    SENSOR_CONNECTION_MODE_TO_STRING := CONCAT('SENSOR_CONNECTION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

