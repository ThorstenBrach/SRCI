{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupMessageLog                                       
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
TYPE AxesGroupMessageLog :
STRUCT
  /// Amount of system log entries
  SystemLogEntries : UINT := DINT_TO_UINT(RobotLibraryParameter.SYSTEM_LOG_MAX);
  /// Amount of message log entries
  MessagesEntries  : UINT := DINT_TO_UINT(RobotLibraryParameter.MESSAGE_LOG_MAX);
  /// Logging level
  LogLevel         : LogLevel;
  /// System log
  SystemLog        : ARRAY[0..RobotLibraryParameter.SYSTEM_LOG_MAX] OF STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// Message Log
  Messages         : ARRAY[0..RobotLibraryParameter.MESSAGE_LOG_MAX] OF AlarmMessage;
  /// Interface to an external logger
  ExternalLogger   : IMessageLogger;
END_STRUCT
END_TYPE


