INTERFACE IMessageLogger


METHOD AddMessageLog
VAR_INPUT
  /// Message to add to the log
  MessageLog : AlarmMessage;
END_VAR

END_METHOD

METHOD AddSystemLog
VAR_INPUT
  /// System messafe to add to the log
  SystemLog : STRING(255);
END_VAR

END_METHOD

