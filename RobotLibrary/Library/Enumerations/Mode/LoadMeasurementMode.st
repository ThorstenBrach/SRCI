{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementMode                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE  LoadMeasurementMode :
(
  /// 0: One Position (default)
  /// Use one defined position and optional axes ranges
  ONE_POSITION := 0,  
  /// 1: Configuration Angle
  /// Use one defined position and optional axes ranges
  CONFIGURATION_ANGLE := 1,  
  /// 2: Area
  /// Use a defined area for the measurement
  AREA := 2,  
  /// 3: Two Positions
  /// Use defined positions for the measurement
  TWO_POSITIONS := 3
)USINT;
END_TYPE


