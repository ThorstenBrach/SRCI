{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MessageLevel                                       
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
TYPE MessageLevel :
(
  /// Debugging messages, Informative messages, Warning messages, Error messages, Fatal error messages
	DEBUG := 4,
  /// Informative messages, Warning messages, Error messages, Fatal error messages 
  INFO := 5, 
  /// Warning messages, Error messages, Fatal error messages
  WARNING := 20,
  /// Error messages, Fatal error messages 
  ERROR := 28 
)USINT;
END_TYPE


