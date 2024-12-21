{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WaitTimeRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-30
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
TYPE WaitTimeRecvData EXTENDS RspHeader :
STRUCT
  /// Current value of time [ms] that has elapsed since processing of the command has started.
  ElapsedTime : UDINT;
  /// Reserve
  Reserve1    : BYTE;
  /// Reserve
  Reserve2    : BYTE;
  /// Reserve
  Reserve3    : BYTE;
  /// Reserve
  Reserve4    : BYTE;  
END_STRUCT
END_TYPE


