{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      StopMode                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
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
TYPE StopMode :
(
  /// 0: Stop via JobID (default)
  /// TargetID is interpreted as JobID
  /// All instances of the defined JobID are stopped
  STOP_JOB_ID := 0,  
  /// 1: Stop via InstanceID
  /// TargetID is interpreted as InstanceID
  /// The instance of the defined InstanceID is stopped
  STOP_INSTANCE_ID := 1,  
  /// 2: Stop all subprograms
  /// All subprograms independent of the input parameter value of TargetID are stopped
  STOP_ALL_SUBPROGRAMS := 2
)USINT;
END_TYPE


