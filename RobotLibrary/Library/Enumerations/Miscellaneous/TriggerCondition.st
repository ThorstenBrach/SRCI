{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TriggerCondition                                       
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
TYPE TriggerCondition :
(
  /// 5: Time in ms  - point reference is target position
  TARGET_POSITION_TIME_MS := -5,
  /// 4: TCP velocity in mm/s - point reference is target position
  TARGET_POSITION_TCP_VELOCITY_ABSOLUTE := -4,
  /// 3: TCP velocity in % of reference velocity - point reference is target position
  TARGET_POSITION_TCP_VELOCITY_PERCENT := -3,
  /// 2: Distance in mm of trajectory - point reference is target position
  TARGET_POSITION_DISTANCE_ABSOLUTE := -2,
  /// 1: Distance in % of trajectory - point reference is target position
  TARGET_POSITION_DISTANCE_PERCENT := -1,
  /// 0: Undfined 
  UNDEFINED := 0,
  /// 1: Distance in % of trajectory - point reference is start position
  START_POSITION_DISTANCE_PERCENT := 1,
  /// 2: Distance in mm of trajectory - point reference is start position
  START_POSITION_DISTANCE_ABSOLUTE := 2,
  /// 3: TCP velocity in % of reference velocity - point reference is start position
  START_POSITION_TCP_VELOCITY_PERCENT := 3,
  /// 4: TCP velocity in mm/s - point reference is start position
  START_POSITION_TCP_VELOCIT_ABSOLUTE := 4,
  /// 5: Time in ms - point reference is start position
  START_POSITION_TIME_MS := 5
)SINT;
END_TYPE


