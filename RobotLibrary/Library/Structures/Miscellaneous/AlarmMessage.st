{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AlarmMessage                                       
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
TYPE AlarmMessage :
STRUCT
  /// Timestamp
  Timestamp   : SystemTime;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);  
END_STRUCT
END_TYPE


