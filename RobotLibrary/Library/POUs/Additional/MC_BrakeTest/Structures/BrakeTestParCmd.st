{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BrakeTestParCmd                                       
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
TYPE BrakeTestParCmd :
STRUCT
  /// Defines which of the robot axis should be activated for the brake test.
  /// • TRUE (default): Axis activated.
  /// • FALSE: Axis deactivated.
  /// See Table 6-735 for bit assignment.
  RobotAxesActive    : RobotAxesFlags;
  /// Defines which of the external robot axis should be activated for the brake test.
  /// • TRUE: Axis activated.
  /// • FALSE (default): Axis deactivated.
  /// See Table 6-735 for bit assignment.   
  ExternalAxesActive : ExternalAxesFlags;
END_STRUCT
END_TYPE


