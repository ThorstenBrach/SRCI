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
TYPE OpenBrakeOutCmd :
STRUCT
  /// TRUE when "OpenBrake" is active.
  Enabled                   : BOOL;  
  /// Indicates the brake release status of the main robot axes.
  /// • TRUE: The brake of the axis is opened.
  /// • FALSE: The brake of the axis is closed.
  /// See Table 6-735 for bit assignment
  RobotAxesBrakeReleased    : RobotAxesFlags;
  /// Indicates the brake release status of the external robot axes.
  /// • TRUE: The brake of the axis is opened.
  /// • FALSE: The brake of the axis is closed/not supported
  /// See Table 6-735 for bit assignment
  ExternalAxesBrakeReleased : ExternalAxesFlags;
END_STRUCT
END_TYPE


