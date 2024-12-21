{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncDirection                                       
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
TYPE SyncDirection :
(
  /// No synchronization will be executed
  NO_SYNC := 0,
  /// Server data will be overwritten immediately by client data
  PLC_TO_ROB := 1,
  /// Client data will be overwritten immediately by server data
  ROB_TO_PLC := 2,
  /// Server or client data will be overwritten immediately by changed data
  AUTOMATIC := 3
);
END_TYPE


