{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WorkAreaReactionMode                                       
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
TYPE WorkAreaReactionMode :
(
  /// 0: No reaction (default)
  /// • RC reports violation
  /// • Robot is not stopped
  NO_REACTION := 0,
  /// 
  /// 1: Abort
  /// • RC reports violation
  /// • RC returns error
  /// • Robot is stopped
  /// • Sequence buffer emptied
  ABORT := 1,
  /// 2: Interrupt
  /// • RC reports violation
  /// • Robot movement is paused
  /// • Movement can be continued by function GroupContinue
   INTERRUPT := 2
)USINT;
END_TYPE


