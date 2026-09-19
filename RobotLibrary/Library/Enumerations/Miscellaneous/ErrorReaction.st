{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ErrorReaction                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE ErrorReaction :
(
  /// Abort and move Abort active move command and delete commands buffered in sequence Move robot by specified ErrorVector
  ABORT_AND_MOVE := 0,
  /// 1: Abort
  /// Abort active move command and delete commands buffered in sequence
  /// No additional movements
  ABORT := 1,  
  /// 2: No reaction
  /// Error event is ignored by active move command
  NO_REACTION := 2
)USINT;
END_TYPE


