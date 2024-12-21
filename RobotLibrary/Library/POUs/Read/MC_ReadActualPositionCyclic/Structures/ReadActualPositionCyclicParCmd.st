{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionCyclicParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadActualPositionCyclicParCmd :
STRUCT
  /// Set TRUE (default) to activate cyclic transmission of cartesian position without external axes
  ReadCartesianPosition       : BOOL;
  /// Set TRUE to activate cyclic transmission of external axes values of cartesian position -  Default: False
  ReadCartesianPositionExt    : BOOL;
  ///Index of tool of returned position
  /// •     -1: Currently used tool on RC
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo                      : INT;
  /// Index of frame of returned position
  /// •     -1: Currently used frame on RC
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo                     : INT;
  /// Set TRUE (default) to activate cyclic transmission of joint position without external axes
  ReadJointPosition           : BOOL;
  /// Set TRUE to activate cyclic transmission of external axes values of joint position - Default: False
  ReadJointPositionExt        : BOOL;
END_STRUCT
END_TYPE


