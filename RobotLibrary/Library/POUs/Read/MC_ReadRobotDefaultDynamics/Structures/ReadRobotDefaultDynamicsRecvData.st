{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRobotDefaultDynamicsRecvData                                       
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
TYPE ReadRobotDefaultDynamicsRecvData EXTENDS RspHeader :
STRUCT
  /// Timestamp
  Timestamp        : IEC_TIMESTAMP;
  /// Maximum velocity for the axes.
  /// Range [%]: 
  /// •  <0% : Use default velocity given by the user
  /// •   0% : Use internal minimal velocity
  /// • 100% : Use the entire reference velocity, given by the user
  VelocityRate     : UINT;
  /// Maximum acceleration.
  /// Range [%]:
  /// •  <0% : Use default acceleration given by the user
  /// •   0% : Use internal minimal acceleration
  /// • 100% : Use the entire reference acceleration, given by the user
  AccelerationRate : UINT;
  /// Maximum deceleration.
  /// Range [%] : 
  /// •  <0% : Use default deceleration given by the user
  /// •   0% : Use internal minimal deceleration
  /// • 100% : Use the entire reference deceleration, given by the user
  DecelerationRate : UINT;
  /// Maximum jerk
  /// Range [%] : 
  /// •  <0% : Use default jerk given by the user
  /// •   0% : Use internal minimal jerk
  /// • 100% : Use the entire reference jerk, given by the user (Trapezoidal if possible) 
  JerkRate         : UINT;  
  /// ToDo
  DataChanged      : BOOL;
END_STRUCT
END_TYPE


