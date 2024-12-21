{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateCartesianPositionParCmd                                       
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
TYPE CalculateCartesianPositionParCmd :
STRUCT
  /// Index of initial frame
  /// • 0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Index of target frame
  /// • 0: WCS (default)
  /// • 1..254: User frames
  TargetFrameNo          : USINT;  
  /// Robot cartesian position.
  CartesianPosition      : RobotCartesianPosition;
END_STRUCT
END_TYPE


