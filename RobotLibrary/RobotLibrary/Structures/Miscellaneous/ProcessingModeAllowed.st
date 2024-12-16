{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ProcessingModeAllowed                                       
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
TYPE ProcessingModeAllowed :
STRUCT
  /// Command is buffered in sequence buffer and executed once
  BUFFERED           : BOOL;
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer, and is executed once
  ABORTING           : BOOL;
  /// Command is buffered in parallel buffer and executed once
  PARALLEL           : BOOL;
  /// Command is buffered in parallel buffer and executed repeatedly until deliberate deactivation by user
  CONTINUOUS         : BOOL;
  /// CMD execution is stopped and/or CMD is removed from the buffer
  DEACTIVATE         : BOOL;
  /// Command is buffered in sequence buffer and executed once (Trigger based)
  TRIGGER_BUFFERED   : BOOL;
  /// Command is buffered in sequence buffer, aborts and empties previous commands in sequence buffer, and is executed once (Trigger based)
  TRIGGER_ABORTING   : BOOL;
  /// Command is buffered in parallel buffer and executed once (Trigger based)
  TRIGGER_ONCE       : BOOL;
  /// Command is buffered in parallel buffer and executed repeatedly until deliberate deactivation by user (Trigger based)
  TRIGGER_CONTINUOUS : BOOL;
  /// Command is buffered and executed multiple times when triggered. The CMD remains in the buffer until removed by the user.
  TRIGGER_MULTIPLE   : BOOL;  
END_STRUCT
END_TYPE


