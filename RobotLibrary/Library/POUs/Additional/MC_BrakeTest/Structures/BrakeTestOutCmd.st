{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BrakeTestOutCmd                                       
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
TYPE BrakeTestOutCmd :
STRUCT
  /// Indicates the result of the brake test of the robot axes related to the brake test.
  /// • TRUE: The brake test has been realized successfully.
  /// • FALSE: The brake test failed. 
  /// See Table 6-735 for bit assignment.
  RobotAxesStatus    : RobotAxesFlags;
  /// Indicates the result of the brake test of the external robot axes related to the brake test.
  /// • TRUE: The brake test has been realized successfully.
  /// • FALSE: The brake test failed.
  /// See Table 6-735 for bit assignment.
  ExternalAxesStatus : ExternalAxesFlags;
  /// Indicates the warning messages availability related to the brake functionality of the robot axes reported by the RC.
  /// • TRUE: One or more warning messages are available.
  /// • FALSE: No warning message is available.
  /// See Table 6-735 for bit assignment.
  RobotAxesWarning   : RobotAxesFlags;
  /// Indicates the warning messages availability related to the brake functionality of the external robot axis reported by the RC.
  /// • TRUE: One or more warning messages are available.
  /// • FALSE: No warning message is available.
  /// See Table 6-735 for bit assignment.
  ExternalAxesWarning: ExternalAxesFlags;
END_STRUCT
END_TYPE


