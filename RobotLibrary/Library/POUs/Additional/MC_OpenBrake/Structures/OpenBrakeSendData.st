{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BrakeTestSendData                                       
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
TYPE OpenBrakeSendData EXTENDS CmdHeader:   
STRUCT
  /// Defines which brake of the robot axes must be released.
  /// • TRUE: Open the brake of the axis.
  /// • FALSE (default): Close the brake of the axis.
  RobotAxesBrakeRelease    : BYTE;
  /// Defines which brake of the external robot axis must be released.
  /// • TRUE: Open the brake of the axis.
  /// • FALSE (default): Close the brake of the axis.
  /// See Table 6-676 for bit assignment.
  ExternalAxesBrakeRelease : BYTE;
END_STRUCT
END_TYPE


