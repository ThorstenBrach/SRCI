FUNCTION_BLOCK AxesGroupMessageLogFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupMessageLogFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-05
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Logging level
  LogLevel         : LogLevel;
  /// Interface to an external logger
  ExternalLogger   : IMessageLogger;
END_VAR


VAR_OUTPUT
  /// Amount of system log entries
  SystemLogEntries : UINT := 0;
  /// Amount of message log entries
  MessagesEntries  : UINT := 0;
  /// System log
  SystemLogs       : ARRAY[0..RobotLibraryParameter.SYSTEM_LOG_MAX] OF STRING(255);
  /// Message Log
  Messages         : ARRAY[0..RobotLibraryParameter.MESSAGE_LOG_MAX] OF AlarmMessage;  
END_VAR


END_FUNCTION_BLOCK

METHOD PUBLIC AddMessage
VAR_INPUT
  Message : ReadMessagesRecvData;
END_VAR

VAR
  /// internal index
 _idx            : DINT;
  /// internal index to delete
 _idxFound       : DINT;
  /// lowest Severity
 _lowestSeverity : Severity := Severity.FATAL_ERROR;
END_VAR

  // Check entry must be added ? 
  IF (( LogLevel  <= Message.Severity        ) AND
      ( LogLevel  >  LogLevelEnum.DEACTIVATE ))
  THEN
    // Check message buffer is full ? 
    IF ( MessagesEntries >= RobotLibraryParameter.MESSAGE_LOG_MAX )
    THEN
      // find lowest Severity
      FOR _idx := 1 TO RobotLibraryParameter.MESSAGE_LOG_MAX
      DO
        // check entry has a lower severity ? 
       _lowestSeverity := MIN( Messages[_idx].Severity, _lowestSeverity );
  		END_FOR
  
      // search for the oldes message with a lower Severity 
      FOR _idx := RobotLibraryParameter.MESSAGE_LOG_MAX TO 1 BY -1
      DO
        // message found ?
        IF (( Messages[_idx].Severity <  Message.Severity ) AND
            ( Messages[_idx].Severity <=  _lowestSeverity ))
        THEN
          // save index to delete 
         _idxFound := _idx;
          EXIT;
  			END_IF
  		END_FOR
      
      // check message must be deleted ? 
      IF ( _idxFound > 0 )
      THEN
        // shift all messages starting from the found index one position forwards
        FOR _idx := _idxFound TO RobotLibraryParameter.MESSAGE_LOG_MAX -1
        DO
          Messages[_idx] := Messages[_idx +1];
  			END_FOR
  		END_IF
    END_IF  
  
  
    // shift all messages one position backwards
    FOR _idx := RobotLibraryParameter.MESSAGE_LOG_MAX TO 1 BY -1
    DO
      Messages[_idx] := Messages[_idx-1]; 
    END_FOR
  
    // Add new message 
    Messages[0].Timestamp   := IEC_TIMESTAMP_TO_DT(Message.Timestamp);           
    Messages[0].MessageType :=                     Message.MsgType;
    Messages[0].Severity    :=                     Message.Severity;
    Messages[0].MessageText :=                     Message.Text;
    Messages[0].MessageCode :=                     Message.ErrorCode;
    
    // inc message counter
    MessagesEntries := DINT_TO_UINT(LIMIT(0, MessagesEntries + 1, RobotLibraryParameter.MESSAGE_LOG_MAX));
  END_IF

END_METHOD

METHOD PUBLIC AddSystemLog
VAR_INPUT
  SystemLog : STRING(255);
END_VAR

VAR
  /// internal index
 _idx : DINT;
END_VAR

  FOR _idx := RobotLibraryParameter.SYSTEM_LOG_MAX TO 1 BY -1
  DO
    SystemLogs[_idx] := SystemLogs[_idx-1]; 
  END_FOR
  
  SystemLogs[0] := SystemLog;           
  
  // inc SystemLog counter
  SystemLogEntries := DINT_TO_UINT(LIMIT(0, SystemLogEntries + 1, RobotLibraryParameter.SYSTEM_LOG_MAX));

END_METHOD

METHOD PUBLIC DeleteMessages
VAR_INPUT
END_VAR

  // reset messages
  SysDepMemSet(ADR(Messages), 0, SIZEOF(Messages));
  // reset message counter
  MessagesEntries := 0;

END_METHOD

METHOD DeleteSystemLogs
VAR_INPUT
END_VAR

  // reset SystemLogs
  SysDepMemSet(ADR(SystemLogs), 0, SIZEOF(SystemLogs));
  // reset SystemLogs counter
  SystemLogEntries := 0;

END_METHOD

