{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CmdMessageState                                       
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
TYPE CmdMessageState :
(
  /// No operation or process is active
  EMPTY := 0,
  /// Created but not yet started
  CREATED := 1,
  /// Buffered and awaiting execution
  BUFFERED := 2,
  /// Buffered in planner for future execution
  BUFFERED_IN_PLANNER := 3,
  /// Currently active and in progress
  ACTIVE := 4,
  /// Interrupted and awaiting continuation
  INTERRUPTED := 5,
  /// Requested for abort
  ABORT_REQUEST := 6,
  /// Successfully completed
  DONE := 10,
  /// Aborted before completion
  ABORTED := 14,
  /// Encountered an error during execution
  ERROR := 15
)USINT;
END_TYPE


