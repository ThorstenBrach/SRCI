{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      OperationMode                                       
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
TYPE OperationMode :
(
 /// Test mode 1:
 /// • Maximum velocity of TCP is restricted to <250 mm/s
 /// • Robot can only be moved while enable switch is active
 /// • Designed for jogging, teaching program, verification
 /// • Safety door can be opened
 T1_LOCAL := 1,
 /// Test mode 2:
 /// • Maximum velocity of TCP not restricted (100%)
 /// • Robot can only be moved while enable switch is active
 /// • Designed for program verification (step mode)
 /// • Safety door can be opened
 T2_LOCAL := 2,
 /// Automatic mode:
 /// • Maximum velocity of TCP not restricted (100%)
 /// • Robot is executing user program automatically
 /// • Robot will stop if safety devices report error (e.g. safety door must be closed)
 AUTO := 3,
 /// External Automatic mode (PLC mode)
 /// • Robot is operated remotely only
 /// • Maximum velocity of TCP not restricted (100%)
 /// • Robot is executing user program automatically
 /// • Jogging possible
 /// • Robot will stop if safety devices report error (e.g. safety door must be closed)
 AUTO_EXT := 4,
 /// External Test mode 1 (PLC mode with T1 functionality)
 /// • Robot is operated remotely only
 /// • Maximum velocity of TCP is restricted to <250 mm/s
 /// • Robot can only be moved while enable switch is active
 /// • Designed for jogging, teaching, program verification
 /// • Safety door can be opened
 T1_EXT := 5,
 /// External Test mode 2:
 /// • Robot is operated remotely only
 /// • Maximum velocity of TCP not restricted (100%)
 /// • Robot can only be moved while enable switch is active
 /// • Designed for jogging, program verification (step mode)
 /// • Safety door can be opened
 T2_EXT := 6
)USINT;
END_TYPE


