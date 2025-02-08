{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      Severity                                       
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
TYPE Severity : 
(
  /// No events will be logged
  DEACTIVATE  := 0,
  /// Debug message
  /// • No user action required
  DEBUG := 4, 
  /// Informative message
  /// • No user action required
  INFO := 5,
  /// Warning message
  /// • User action will be required at some point
  WARNING := 20,
  /// Error message
  /// • User action required immediately
  ERROR := 28,
  ///  Fatal error message
  /// • User action required immediately
  /// • Reinitialization OF RI required
  FATAL_ERROR := 29
)SINT;
END_TYPE


