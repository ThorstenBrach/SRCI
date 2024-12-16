{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ProcessingMode                                       
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
TYPE ProcessingMode :
(
  /// Command is buffered in sequence buffer and executed once
  BUFFERED := 0,
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer, and is executed once
  ABORTING := 1,
  /// Command is buffered in parallel buffer and executed once
  PARALLEL := 2,
  /// Command is buffered in parallel buffer and executed repeatedly until deliberate deactivation by user
  CONTINUOUS := 3,
  /// CMD execution is stopped and/or CMD is removed from the buffer
  DEACTIVATE := 9,
  /// Command is buffered in sequence buffer and executed once (Trigger based)
  TRIGGER_BUFFERED := 10,
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer, and is executed once (Trigger based)
  TRIGGER_ABORTING := 11,
  /// Command is buffered in parallel buffer and executed once (Trigger based)
  TRIGGER_ONCE := 12,
  /// Command is buffered in parallel buffer and executed repeatedly until deliberate deactivation by user (Trigger based)
  TRIGGER_CONTINUOUS := 13,
  /// Command is buffered and executed multiple times when triggered. The CMD remains in the buffer until removed by the user.
  TRIGGER_MULTIPLE := 14
)USINT;
END_TYPE


