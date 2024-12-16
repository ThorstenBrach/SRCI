{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MeasuringInputResult                                       
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
TYPE MeasuringInputResult :
STRUCT
  /// Measured robot position value at the rising edge of the digital input in selected coordinate systems (see input parameters ToolNo and FrameNo).
  MeasuredCartesianPosition :  RobotCartesianPosition;
  /// Index of tool of returned position
  /// • 0: Flange
  /// • 1..254: Tool frames
  ToolNo                    : USINT;
  /// Index of frame of returned position
  /// • 0: WCS
  /// • 1..254: User frames
  FrameNo                   : USINT;
  /// Measured robot position value at the rising edge of the digital input in Joint position.
  MeasuredJointPosition     : RobotJointPosition;
END_STRUCT
END_TYPE


