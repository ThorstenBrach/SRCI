{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ControlHalfByte                                       
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
TYPE ControlHalfByte :
(
  /// Default value, no control active
  NONE := 0,
  /// Initialization is requested by the client
  INITIALIZE := 1,
  /// Resume of operation is requested by the client
  RESUME := 2,
  /// Resetting of the RC is requested by the client. The RC must stop the motion, and clear all state.
  RESET := 3,
  /// Acknowledgement of a telegram state error
  ACK_ERROR := 4,
  /// Signaling that a client error occurred. The Server must respond by setting its RI state to NOT_INITIALIZED
  CLIENT_ERROR := 5
)BYTE;
END_TYPE


