{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateFrameSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
TYPE CalculateFrameSendData EXTENDS CmdHeader:   
STRUCT
  /// Incremented with each position of the input parameter "PositionsArray" sent from the PLC to the RC.
  /// Default: 0
  DataIndex          : USINT;
  
  /// Set TRUE by the client, when according to the user selected "Mode" the final position of the input parameter "PositionsArray" is sent to the RC.
  /// Default: FALSE
  DataComplete       : BYTE;
  ///
  Reserve            : BYTE;
  /// Index of target frame
  /// • 0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Index of frame on which the calculated frame is depending
  /// •      0: WCS (default)
  /// • 1..254: User frames
  ReferenceFrame     : USINT;
  /// Define which method should be used to calculate the frame coordinate system: M
  /// • 0: Three-Point-Method (default) O
  /// • 1: Four-Point-Method O
  /// • 2: One-Point-Method
  Mode               : SINT;  
  /// Cartesian position
  Position           : RobotCartesianPosition;  
END_STRUCT
END_TYPE


