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
  /// Interface to an internal logger
  InternalLogger : IMessageLogger;  
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

METHOD CreateLogMessage : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
END_VAR

VAR
  /// internal log message 
 _message    : AlarmMessage;
  /// internal string
 _tmpString  : STRING(255);
END_VAR

  IF ( LogLevel <= Severity )
  THEN
   _message.Timestamp   := Timestamp;
   _message.MessageType := MessageType;
   _message.Severity    := Severity;
   _message.MessageCode := MessageCode;
   _message.MessageText := StrPadRight(MyType,' ', RobotLibraryDefines.MaxTypeNameLength);
   _message.MessageText := CONCAT(_message.MessageText, ': ');
   _message.MessageText := CONCAT(_message.MessageText,MessageText);
  
    // return log message
    CreateLogMessage := ALARM_MESSAGE_TO_STRING(_message);
    
    // Check internal logger valid ? 
    IF ( InternalLogger <> 0 )
    THEN  
      InternalLogger.AddSystemLog( SystemLog := ALARM_MESSAGE_TO_STRING(_message));
    END_IF
  
    // Check external logger valid ? 
    IF ( ExternalLogger <> 0 )
    THEN  
      ExternalLogger.AddSystemLog( SystemLog := ALARM_MESSAGE_TO_STRING(_message));
    END_IF
  END_IF

END_METHOD

METHOD CreateLogMessagePara1 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{1}', Para1);
  
  CreateLogMessagePara1 
    := CreateLogMessage( Timestamp   := Timestamp,
                         MessageType := MessageType,
                         Severity    := Severity,
                         MessageCode := MessageCode,
                         MessageText := MessageText);

END_METHOD

METHOD CreateLogMessagePara2 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{2}', Para2);
  
  CreateLogMessagePara2 
    := CreateLogMessagePara1( Timestamp   := Timestamp,
                              MessageType := MessageType,
                              Severity    := Severity,
                              MessageCode := MessageCode,
                              MessageText := MessageText,
                              Para1       := Para1);

END_METHOD

METHOD CreateLogMessagePara3 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{3}', Para3);
  
  CreateLogMessagePara3
    := CreateLogMessagePara2( Timestamp   := Timestamp,
                              MessageType := MessageType,
                              Severity    := Severity,
                              MessageCode := MessageCode,
                              MessageText := MessageText,
                              Para1       := Para1,
                              Para2       := Para2);

END_METHOD

METHOD CreateLogMessagePara4 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {4}
  Para4       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{4}', Para4);
  
  CreateLogMessagePara4
    := CreateLogMessagePara3( Timestamp   := Timestamp,
                              MessageType := MessageType,
                              Severity    := Severity,
                              MessageCode := MessageCode,
                              MessageText := MessageText,
                              Para1       := Para1,
                              Para2       := Para2,
                              Para3       := Para3);

END_METHOD

METHOD CreateLogMessagePara5 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {4}
  Para4       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {5}
  Para5       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{5}', Para5);
  
  CreateLogMessagePara5
    := CreateLogMessagePara4( Timestamp   := Timestamp,
                              MessageType := MessageType,
                              Severity    := Severity,
                              MessageCode := MessageCode,
                              MessageText := MessageText,
                              Para1       := Para1,
                              Para2       := Para2,
                              Para3       := Para3,
                              Para4       := Para4);

END_METHOD

METHOD CreateLogMessagePara6 : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
VAR_INPUT
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
  /// sub string which will replace the placeholder {1}
  Para1       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {2}
  Para2       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {3}
  Para3       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {4}
  Para4       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {5}
  Para5       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
  /// sub string which will replace the placeholder {6}
  Para6       : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
END_VAR
VAR
  /// internal log message 
 _logMessage : AlarmMessage;
END_VAR

  MessageText := StrReplace(MessageText,'{6}', Para6);
  
  CreateLogMessagePara6
    := CreateLogMessagePara5( Timestamp   := Timestamp,
                              MessageType := MessageType,
                              Severity    := Severity,
                              MessageCode := MessageCode,
                              MessageText := MessageText,
                              Para1       := Para1,
                              Para2       := Para2,
                              Para3       := Para3,
                              Para4       := Para4,
                              Para5       := Para5);

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

