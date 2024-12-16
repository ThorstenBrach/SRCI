{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExecutionMode                                       
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
TYPE ExecutionMode :
(
  /// Command is buffered in sequence buffer and executed once
  SEQUENCE_PRIMARY := 0,
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer, and is executed once
  SEQUENCE_ABORT_OTHERS_PRIMARY := 1,
  /// Command is buffered in parallel buffer and executed once. The execution may also be Trigger based.
  PARALLEL := 2,
  /// Command is buffered in parallel buffer and executed repeatedly until deliberate deactivation by user. The de- and activation may also be Trigger based.
  CONTINUOUS := 3,
  /// Command is buffered and executed once when triggered. The CMD remains in the buffer until removed by the user.
  TRIGGER_MULTIPLE := 5,
  /// Command is buffered in sequence buffer and executed once (Secondary)
  SEQUENCE_SECONDARY := 7,
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer and is executed once (Secondary)
  SEQUENCE_ABORT_OTHERS_SECONDARY := 8,
  /// CMD execution is stopped and/or CMD is removed from the buffer.
  STOP_PARALLEL_CONTINUOUS_TRIGGER := 9
)USINT;
END_TYPE


