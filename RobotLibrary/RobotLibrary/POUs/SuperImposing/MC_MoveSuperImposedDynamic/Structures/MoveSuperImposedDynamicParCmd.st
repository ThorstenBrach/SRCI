{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedDynamicParCmd                                       
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
TYPE MoveSuperImposedDynamicParCmd :
STRUCT
  /// Additional distance and orientation for superimposed positioning
  Offset             : RobotCartesianPosition;
  /// Defines type of reference coordinate system of the offset position.
  ReferenceType      : ReferenceType;
  /// Value of the maximum velocity difference of the additional motion (not necessary reached).
  /// • > 0% Use specified value.
  /// • ≤ 0% Use the velocity defined by the move command that is superimposed. If no motion is active, use internal minimal velocity. (default)
 /// See chapter 5.5.7 Robot dynamics
  VelocityDiffRate   : REAL;
  /// Value of the maximum acceleration difference of the additional motion (not necessary reached).
  ///  •  <0% Use default acceleration (default)
  ///  •   0% Use internal minimal acceleration
  ///  • 100% Use maximal reference acceleration
  /// See chapter 5.5.7 Robot dynamics
  AccelerationDiffRate: REAL;
  /// Value of the maximum deceleration difference of the additional motion (not necessary reached).
  /// •  <0% Use default deceleration (default)
  /// •   0% Use internal minimal deceleration
  /// • 100% Use maximal reference deceleration
  /// See chapter 5.5.7 Robot dynamics
  DecelerationDiffRate: REAL;
  /// Value of the maximum jerk difference of the additional motion (not necessary reached).
  /// •  <0% Use default jerk (default) 
  /// •   0% Use internal minimal jerk
  /// • 100% Use maximal reference jerk
  /// See chapter 5.5.7 Robot dynamics
  JerkDiffRate        : REAL;
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Index of frame
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Define the interpolation mode for the superimposed motion
  InterpolationMode  : InterpolationMode;
END_STRUCT
END_TYPE


