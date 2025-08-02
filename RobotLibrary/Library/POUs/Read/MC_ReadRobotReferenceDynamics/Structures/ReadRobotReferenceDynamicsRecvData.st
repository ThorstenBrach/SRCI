{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRobotReferenceDynamicsRecvData                                       
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
TYPE ReadRobotReferenceDynamicsRecvData EXTENDS RspHeader :
STRUCT
  /// Timestamp
  Timestamp             : IEC_TIMESTAMP;
  /// Path velocity [mm/s](tangent) at 100%
  /// • <0: (default) - Do not change values
  /// • ≥0: Change values according to input value
  VelocityReference     : UINT;
  /// Path acceleration [mm/s2] at 100%
  /// • <0: (default) - Do not change values
  /// • ≥0: Change values according to input value
  AccelerationReference : UINT;
  /// Path deceleration [mm/s2] at 100%
  /// • <0: (default) - Do not change values
  /// • ≥0: Change values according to input value
  DecelerationReference : UINT;
  /// Jerk [mm/s3] at 100%
  /// • <0: (default) - Do not change values
  /// • ≥0: Change values according to input value
  JerkReference        : UINT;  
  /// The status bit "DataChanged" represents the modification state 
  DataChanged          : BOOL;
END_STRUCT
END_TYPE


