{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SensorConnectionMode                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
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
TYPE SensorConnectionMode :
(
  /// RC sensor and algorithm
  /// Force-Torque-Sensor connected to RC
  /// Control algorithm in RC
  RC_SENSOR_ALGORITHM := 0,
  
  /// PLC sensor and RC algorithm
  /// Force-Torque-Sensor connected to PLC
  /// Control algorithm in RC
  PLC_SENSOR_RC_ALGORITHM := 1,
  
  /// PLC sensor and algorithm
  /// Force-Torque-Sensor connected to PLC
  /// Control algorithm in PLC
  PLC_SENSOR_ALGORITHM := 2
)USINT;
END_TYPE


