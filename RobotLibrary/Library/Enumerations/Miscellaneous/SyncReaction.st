{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncReaction                                       
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
TYPE SyncReaction :
(
  /// • System behavior unaffected
  NO_REACTION := 0,
  /// • No automatic disable
  /// • Reaction will only apply when RA is disabled
  /// • RA can only be enabled if client and server are synchronized
  REACTION_TYPE_1 := 1,  
  /// • No automatic disable
  /// • RA can only be enabled if client and server are synchronized
  /// • RA sequence state will change to interrupted when no command is buffered in the active sequence
  /// • Continuation is only possible if client and server are synchronized
  REACTION_TYPE_2 := 2,  
  /// • No automatic disable
  /// • RA can only be enabled if client and server are synchronized
  /// • RA sequence state will change to interrupted
  /// • Continuation is only possible if client and server are synchronized
  REACTION_TYPE_3 := 3
)USINT;
END_TYPE


