{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadMessagesRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadMessagesRecvData EXTENDS RspHeader :
STRUCT
  /// Set TRUE to read messages from RC.
  Enabled                : BOOL;
  /// ID for function specific acknowledgement mechanism
  MsgId                  : USINT;
  /// Number of pending errors on RC
  NumberOfActiveErrors   : USINT;
  /// Number if pending warnings in RC
  NumberOfActiveWarnings : USINT;
  /// Timestamp
  Timestamp              : IEC_TIMESTAMP;
  /// Message Type
  MsgType                : USINT;
  /// Severity of returned message according to .Table 5-47.
  Severity               : SINT;
  /// ErrorCode
  ErrorCode              : DWORD;
  /// Test
  Text                   : STRING(150);
END_STRUCT
END_TYPE


