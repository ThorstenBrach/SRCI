{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActivateNextCommandOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//             Licensed under the LGPL-3.0 license.
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE ActivateNextCommandOutCmd :
STRUCT
  /// Unique system-generated ID of the "Action" when the function is triggered.
  /// • >0: The "Action" is started by the trigger function with identical FollowID.
  /// • <0: The "Action" is stopped by the trigger function with identical FollowID.
  /// For more information see chapter 5.5.12.4 EmitterID, ListenerID, FollowID and OriginID
  OriginID           : INT;
  /// Relates to ListenerID >0
  /// Number of successful trigger -based command invocations
  /// For more information refer to chapter 5.5.12.4.
  InvocationCounter  : USINT;
END_STRUCT
END_TYPE

