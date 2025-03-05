{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SearchHardStopParCmd                                       
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
TYPE SearchHardStopJParCmd :
STRUCT
  /// Absolute end position of the robot in Joint position.
  JointPosition      : RobotJointPosition;
  /// Defines the type of collision detection, which parameter should be observed
  DetectionMode      : DetectionMode;
  /// Additional parameter for the detection of an end position. Defines the limits for seven joints, 
  /// where the robot stops when one of the limits is reached. Unit is depending on the "DetectionMode":
  /// • Torque (default) [Nm]  - Only positive values accepted
  /// • Force [N]              - Only positive values accepted
  /// • Electrical current [A] - Only positive values accepted
  /// • Following Error [mm]   - >0: Robot stops when the following error reached positive limit
  ///                          - <0: Robot stops when the following error reaches the negative limit
  DetectionVector    : ARRAY [0..5] OF REAL;
  /// TCP velocity in % of nominal velocity
  /// •  <0%: (default) - Use default velocity
  /// •   0%:           - Use internal minimal velocity
  /// • 100%:           - Use maximal reference velocity
  /// See chapter 5.5.7 Robot dynamics
  VelocityRate       : REAL;
  /// Acceleration for movement in % of nominal acceleration
  /// •  <0%: (default) - Use default acceleration
  /// •   0%:           - Use internal minimal acceleration
  /// • 100%:           - Use maximal reference acceleration
  /// See chapter 5.5.7 Robot dynamics
  AccelerationRate   : REAL;
  /// Deceleration for movement in % of nominal deceleration
  /// •  <0%: (default) - Use default deceleration 
  /// •   0%:           - Use internal minimal deceleration
  /// • 100%:           - Use maximal reference deceleration
  /// See chapter 5.5.7 Robot dynamics
  DecelerationRate   : REAL;
  /// Jerk of the movement in % of nominal jerk
  /// •  <0%: (default) - Use default jerk
  /// •   0%:           - Use internal minimal jerk
  /// • 100%:           - Use maximal reference jerk
  /// See chapter 5.5.7 Robot dynamics
  JerkRate           : REAL;
  /// Set TRUE to allow manipulation of this move command through superimposing functions.
  /// For more information see chapter 5.5.9.5
  Manipulation       : BOOL;
END_STRUCT
END_TYPE


