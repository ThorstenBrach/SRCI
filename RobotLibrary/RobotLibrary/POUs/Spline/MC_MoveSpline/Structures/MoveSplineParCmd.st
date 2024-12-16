{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSplineParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE MoveSplineParCmd :
STRUCT
  /// Index of the spline data set, on which the spline trajectory is based
  SplineID           : SINT;
  /// Parameter which determines the transition behavior at the end of the movement to be sent to the next command. 
  /// The user can choose a transition type between exact stop and different blend possibilities.
  BlendingMode       : BlendingMode;
  /// Additional parameter for the blending mode, to define i.e. velocity limit (%) or blending radius
  /// • [0]: default 10
  /// • [1]: default 0
  BlendingParameter  : ARRAY [0..1] OF REAL;
  /// Parameter is used if it is greater than 0 (default):
  /// • Velocity input is ignored
  /// • Parameter defines the time for the movement to reach the target position 
  /// Error is sent by the RC, if the time cannot be kept.
  MoveTime           : TIME;
END_STRUCT
END_TYPE


