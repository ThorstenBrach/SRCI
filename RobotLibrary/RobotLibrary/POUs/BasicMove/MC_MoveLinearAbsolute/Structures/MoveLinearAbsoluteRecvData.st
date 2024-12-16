{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveLinearAbsoluteRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-07-30
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
TYPE MoveLinearAbsoluteRecvData EXTENDS RspHeader :
STRUCT
  /// Relates to ListenerID >0
  /// Number of successful trigger-based command invocations - For more information refer TO chapter 5.5.12.4
  InvocationCounter : USINT;  
  /// Reserve
  Reserve           : SINT;
  /// Unique system-generated ID of the "Action" when the function is triggered.
  /// • >0: The "Action" is started by the trigger funcrion with identical FollowID.
  /// • <0: The "Action" is stopped by the trigger function with identical FollowID.
  /// For more information see chapter 5.5.12.4 EmitterID, ListenerID, FollowID and OriginID
  OriginID          : INT;
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress          : UINT;
  /// Distance-to-go of the current job.
  /// • -1: No valid value because move command is not yet active (valid values are pending) or not supported by RC
  /// • >0: Actual distance between current and target position
  /// •  0: Target position reached
  RemainingDistance  : REAL;
END_STRUCT
END_TYPE


