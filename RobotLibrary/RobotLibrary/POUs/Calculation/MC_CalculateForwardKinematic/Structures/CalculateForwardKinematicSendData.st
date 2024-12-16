{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateForwardKinematicSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-05
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
TYPE CalculateForwardKinematicSendData EXTENDS CmdHeader:   
STRUCT
  /// Index of target tool
  /// • 0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Index of target frame
  /// • 0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Calculated cartesian position
  CartesianPosition  : RobotCartesianPosition;
END_STRUCT
END_TYPE


