{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotDynamics                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-10-15
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE RobotDynamics :
STRUCT
  /// TCP velocity in % of nominal velocity
  /// •  <0% (default) o Use default velocity
  /// •   0%           o Use internal minimal velocity
  /// • 100%           o Use maximal reference velocity
  /// See chapter 5.5.7 Robot dynamics
  VelocityRate     : REAL;
  /// Acceleration for movement in % of nominal acceleration
  /// •  <0% (default) o Use default acceleration
  /// •   0%           o Use internal minimal acceleration
  /// • 100%:          o Use maximal reference acceleration
  /// See chapter 5.5.7 Robot dynamics
  AccelerationRate : REAL;
  /// Deceleration for movement in % of nominal deceleration
  /// •  <0% (default) o Use default deceleration
  /// •   0%           o Use internal minimal deceleration
  /// • 100%           o Use maximal reference deceleration
  /// See chapter 5.5.7 Robot dynamics
  DecelerationRate : REAL;
  /// Jerk of the movement in % of nominal jerk
  /// •  <0% (default) o Use default jerk
  /// •   0%           o Use internal minimal jerk
  /// • 100%           o Use maximal reference jerk
  /// See chapter 5.5.7 Robot dynamics
  JerkRate         : REAL;  
END_STRUCT
END_TYPE


