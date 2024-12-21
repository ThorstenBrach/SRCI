{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AbortingMode                                       
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
TYPE AbortingMode :
(
  /// The current movement command as well as all stored movements are executed as programmed. 
  /// The new motion command is queued in the motion buffer.
  BUFFER := 0,
  /// The current movement command is aborted. All buffered motion movements are discarded. 
  /// The new target position is approached, depending on the motion command.
  ABORT  := 1
)SINT;
END_TYPE


