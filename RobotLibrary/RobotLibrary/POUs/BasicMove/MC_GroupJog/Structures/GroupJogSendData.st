{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      GroupJogSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-17
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
TYPE GroupJogSendData EXTENDS CmdHeader:   
STRUCT
  Enable : BOOL;

  /// Relates to Mode 0 (JogFrame) and 1 (JogTool) Index of tool
  /// •      0: Flange (default):
  /// • 1..254: Tool frames
  ToolNo                 : USINT;
  /// Relates to Mode 0 (JogFrame) Index of frame
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo                : USINT;
  /// Specifies in which mode the robot is jogged
  Mode                   : JogMode;
  /// Increments for jogging translational axes for defined distance
  /// •  0: Incremental mode OFF (default) - Movement is active until "Control" is reset, or error occurs.
  /// • >0: Incremental mode ON            - Movement is active until distance defined by input value is reached without changes to "Control", "Control" is reset, or error occurs
  IncrementalTranslation : REAL;
  /// Increments for jogging rotational axes for defined distance
  /// • 0: Incremental mode OFF (default) - Movement is active until "Control" is reset, or error occurs.
  /// • >0 Incremental mode ON:           - Movement is active until distance defined by input value is reached without changes to "Control", "Control" is reset, or error occurs
  IncrementalRotation    : REAL;  
  /// Velocity in % of monitoring speed or ReferenceVelocity, depending on the currently active operation mode 
  /// (T1 External/T2 External: Monitoring speed; Automatic External: ReferenceVelocity )
  /// •    0%: No movement of the robot
  /// •   10%: default
  /// • ≤100%: use input parameter value
  Override               : UINT;
  /// Change to jog and define direction according to Mode. See Table 6-223
  JogControl             : ARRAY[0..2] OF BYTE;
END_STRUCT
END_TYPE


