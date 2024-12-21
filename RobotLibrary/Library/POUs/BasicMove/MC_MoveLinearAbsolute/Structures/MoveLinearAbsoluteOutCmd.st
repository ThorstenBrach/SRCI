{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveLinearAbsoluteOutCmd                                       
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
TYPE MoveLinearAbsoluteOutCmd :
STRUCT
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress           : REAL;  
  /// Distance-to-go of the current job.
  /// • -1: No valid value because move command is not yet active (valid values are pending) or not supported by RC
  /// • >0: Actual distance between current and target position
  /// •  0: Target position reached
  RemainingDistance  : REAL;  
  /// Unique system-generated ID of the trigger function when the function is called by the user.
  /// For more information see chapter 5.5.12.4.
  FollowID           : DINT;  
END_STRUCT
END_TYPE


