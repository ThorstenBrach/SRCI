FUNCTION_BLOCK RobotLibraryLogFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryLogFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-10
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
VAR_INPUT
  /// Interface to an external logger
  ExternalLogger : IMessageLogger;  
  /// Logging level
  LogLevel       : LogLevelEnum := LogLevelEnum.INFO; 
END_VAR

VAR
  /// Type of the function block
 _myType         : STRING;
END_VAR


END_FUNCTION_BLOCK

METHOD CreateLogMessage
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
END_VAR

VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  IF (( ExternalLogger <> 0        ) AND 
      ( LogLevel       <= Severity )) {warning 'ToDo: LogLevel and Severity are the same -> use an alias for it'}
  THEN
   _logMessage.Timestamp   := Timestamp;
   _logMessage.MessageType := MessageType;
   _logMessage.Severity    := Severity;
   _logMessage.MessageCode := MessageCode;
   _logMessage.MessageText := StrPadRight(MyType,' ', RobotLibraryDefines.MaxTypeNameLength);
   _logMessage.MessageText := CONCAT(_logMessage.MessageText, ': ');
   _logMessage.MessageText := CONCAT(_logMessage.MessageText,MessageText);
    
    ExternalLogger.AddMessageLog( _logMessage);
  END_IF

END_METHOD

METHOD CreateLogMessagePara1
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(255);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{1}', Para1);
  
  CreateLogMessage( Timestamp   := Timestamp,
                    MessageType := MessageType,
                    Severity    := Severity,
                    MessageCode := MessageCode,
                    MessageText := MessageText);

END_METHOD

METHOD CreateLogMessagePara2 : BOOL
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(255);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(255);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{2}', Para2);
  
  CreateLogMessagePara1( Timestamp   := Timestamp,
                         MessageType := MessageType,
                         Severity    := Severity,
                         MessageCode := MessageCode,
                         MessageText := MessageText,
                         Para1       := Para1);

END_METHOD

METHOD CreateLogMessagePara3
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(255);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(255);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(255);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{3}', Para3);
  
  CreateLogMessagePara2( Timestamp   := Timestamp,
                         MessageType := MessageType,
                         Severity    := Severity,
                         MessageCode := MessageCode,
                         MessageText := MessageText,
                         Para1       := Para1,
                         Para2       := Para2);

END_METHOD

METHOD CreateLogMessagePara4 : BOOL
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(255);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(255);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(255);
  /// sub string which will replace the placeholder {4}
  Para4       : STRING(255);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{4}', Para4);
  
  CreateLogMessagePara3( Timestamp   := Timestamp,
                         MessageType := MessageType,
                         Severity    := Severity,
                         MessageCode := MessageCode,
                         MessageText := MessageText,
                         Para1       := Para1,
                         Para2       := Para2,
                         Para3       := Para3);

END_METHOD

METHOD CreateLogMessagePara5 
VAR_INPUT
  /// Timestamp
  Timestamp   : DT;
  /// Type of message according to Table 5-46:
  MessageType : MessageType;
  /// Severity of message according to Table 5-47: Debug, Info, Warning, Error, Fatal error
  Severity    : Severity;
  /// Code of messages
  MessageCode : DWORD;
  /// Static text of message
  MessageText : STRING(255);  
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(255);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(255);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(255);
  /// sub string which will replace the placeholder {4}
  Para4       : STRING(255);
  /// sub string which will replace the placeholder {5}
  Para5       : STRING(255);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{5}', Para5);
  
  CreateLogMessagePara4( Timestamp   := Timestamp,
                         MessageType := MessageType,
                         Severity    := Severity,
                         MessageCode := MessageCode,
                         MessageText := MessageText,
                         Para1       := Para1,
                         Para2       := Para2,
                         Para3       := Para3,
                         Para4       := Para4);

END_METHOD

PROPERTY PROTECTED MyType : STRING


GET
VAR
END_VAR

  MyType := _myType;

END_GET

SET
VAR
END_VAR

  _myType := MyType;
  
  // set the max type name length 
  RobotLibraryDefines.MaxTypeNameLength := MAX(LEN(_myType), RobotLibraryDefines.MaxTypeNameLength);

END_SET

