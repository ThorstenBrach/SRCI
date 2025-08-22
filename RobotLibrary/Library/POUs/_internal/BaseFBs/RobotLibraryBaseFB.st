FUNCTION_BLOCK RobotLibraryBaseFB EXTENDS RobotLibraryLogFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryBaseFB                                       
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
VAR_INPUT
  /// User defined command name
  Name         : STRING(80);
  /// Execution Mode
  ExecMode     : ExecutionMode;
  /// Priority
  Priority     : PriorityLevel;
END_VAR
VAR_OUTPUT
  /// Command data
  CommandData  : RobotLibraryCommandDataFB;
  /// response data
  ResponseData : RobotLibraryResponseDataFB;
  /// An error occurred during the execution of the command
  Error        : BOOL;
  /// ErrorID reported by RC for error identification according to Table 7-1
  ErrorID      : WORD;
  ErrorIdEnum  : RobotLibraryErrorIdEnum;  
  ErrorAddTxt  : STRING(RobotLibraryConstants.MAX_ADD_TEXT_LENGTH);
  
  /// WarningID for warning identification reported during execution of command according to Table 7-3
  WarningID    : WORD;
  WarningIdEnum: RobotLibraryWarningIdEnum;  
  /// InfoID for info identification reported during execution of command according to Table 7-5
  InfoID       : WORD;    
  InfoIdEnum   : RobotLibraryInfoIdEnum;  
END_VAR
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

VAR
  /// Rising edge for error
  {attribute 'hide'}
 _error_R                  : R_TRIG;
  /// Rising edge for warning
  {attribute 'hide'}
 _warning_R                : R_TRIG;
  /// Rising edge for information
  {attribute 'hide'}
 _info_R                   : R_TRIG;
  /// clear error active
 _clearError               : BOOL;
  /// cancel active
 _cancel                   : BOOL; 
  /// unique ID
 _uniqueID                 : UDINT;  
  /// flag for response received
 _responseReceived         : BOOL;
  /// internal step counter
 _stepCmd                  : DINT;
  /// internal timer  
  {attribute 'hide'}
 _timerCmd                 : TON;
  /// internal timeout 
  {attribute 'hide'}
 _timeoutCmd               : TIME := T#5S;
  /// internal step counter for ClearError
 _stepClearError           : DINT;
  /// internal timer for ClearError
  {attribute 'hide'}
 _timerClearError          : TON;
  /// internal timeout for ClearError 
  {attribute 'hide'}
 _timeoutClearError        : TIME := T#5S;

  /// internal step counter for Cancel
 _stepCancel               : DINT;
  /// internal timer for Cancel  
  {attribute 'hide'}
 _timerCancel              : TON;
  /// internal timeout for Cancel 
  {attribute 'hide'}
 _timeoutCancel            : TIME := T#5S;

  /// internal command header
 _cmdHeader                : CmdHeader;  
  /// internal response header
 _rspHeader                : RspHeader;
  /// internal flag for send a parameter update
 _parameterUpdateInternal  : BOOL; 
  /// internal flag for parameter has changed
 _parameterChanged         : BOOL;
  /// internal flag for parameter are valid
 _parameterValid           : BOOL;
END_VAR

  OnCall               (AxesGroup := AxesGroup);
  OnExecRun            (AxesGroup := AxesGroup);
  CheckParameterChanged(AxesGroup := AxesGroup);
  
  
  IF ( AxesGroup.State.OnlineChange_R.Q )
  THEN
    OnOnlineChange(AxesGroup := AxesGroup);
  END_IF

END_FUNCTION_BLOCK

METHOD PUBLIC CallBack : DINT
VAR_INPUT
  /// Response data
  RspData   : AxesGroupAcyclicAcrEntryRspBuffer;  
  /// Timestamp
  Timestamp : SystemTime;
END_VAR

  // Create log entry
  CreateLogMessagePara2 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Callback reveiced in FB {1} <{2}>',
                          Para1       := MyType,
                          Para2       := Name);
  
                     
                     
  ResponseData.Reset();
  ResponseData.Payload    := RspData.Payload; 
  ResponseData.PayloadLen := RspData.PayloadLen;
  ParseResponsePayload( ResponseData :=  ResponseData , Timestamp := Timestamp);
  
  // set flag for response received
  _responseReceived := TRUE;

END_METHOD

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  Error       := TRUE;
  ErrorID     := RobotLibraryErrorIdEnum.ERR_FUNCTION_NOT_SUPPORTED;
  ErrorAddTxt := CONCAT(THIS^._myType, ' ');
  ErrorAddTxt := CONCAT(ErrorAddTxt , THIS^.Name);
  
  
  // Create log entry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Execution canceled, because function <{1}> is not supported by the robot controller',
                          Para1       :=  _myType);

END_METHOD

METHOD PROTECTED CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  IF ( CheckParameterChanged )
  THEN
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckParameterValid := TRUE;

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  // Reset all variables
  CreateCommandPayload.Reset();
  // Add CmdType
  CreateCommandPayload.AddUint(_cmdHeader.CmdTyp);
  // Add Reserve_ExecMode
  CreateCommandPayload.AddHalfBytes(  0               , _cmdHeader.ExecMode);
  // Add ParSeq_Priority
  CreateCommandPayload.AddHalfBytes( _cmdHeader.ParSeq, _cmdHeader.Priority);

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // map numeric value to enum, so that the corresponding message text is directly shown by the tooltip
  ErrorIdEnum   := ErrorId;
  WarningIdEnum := WarningId;
  InfoIdEnum    := InfoId;
  
  Error := ErrorID <> RobotLibraryConstants.OK;
  
  InternalLogger   := AxesGroup.MessageLog; 
  ExternalLogger   := AxesGroup.MessageLog.ExternalLogger;
  LogLevel         := AxesGroup.MessageLog.LogLevel;
  
  // building rising edges for error, warning, info number detected
  _error_R  ( CLK := ErrorID   <> RobotLibraryConstants.OK );
  _warning_R( CLK := WarningID <> RobotLibraryConstants.OK );
  _info_R   ( CLK := InfoID    <> RobotLibraryConstants.OK );
  
  
  // Log Command events to message log 
  IF  ( LogLevel < _rspHeader.AlarmMessageSeverity ) AND
     (( _error_R  .Q                               ) OR 
      ( _warning_R.Q                               ) OR 
      ( _info_R   .Q                               ))
  THEN
    // Add command message to message buffer       
    AxesGroup.MessageLog
      .AddMessageLogByParameter(  Timestamp   :=   AxesGroup.State.SystemTime,
                                  MessageType :=   MessageType.CMD,
                                  MessageCode :=  _rspHeader.AlarmMessageCode,
                                  MessageText :=   CONCAT(MyType, CONCAT(' : ' , MESSAGE_CODE_TO_STRING(_rspHeader.AlarmMessageCode))),
                                  Severity    :=  _rspHeader.AlarmMessageSeverity ); 
  END_IF 
  
  
  IF ( _error_R.Q)
  THEN
    // Create log entry
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Error with ID: 16#{1} in FB {2} received ',
                            Para1       := WORD_TO_STRING_HEX(ErrorID),
                            Para2       := MyType);                        
  END_IF
  
  IF ( _warning_R.Q)
  THEN
    // Create log entry
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Warning with ID: 16#{1} in FB {2} received ',
                            Para1       := WORD_TO_STRING_HEX(WarningID),
                            Para2       := MyType);                        
  END_IF
  
  IF ( _info_R.Q)
  THEN
    // Create log entry
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Info with ID: 16#{1} in FB {2} received ',
                            Para1       := WORD_TO_STRING_HEX(InfoID),
                            Para2       := MyType);                        
  END_IF

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR


END_METHOD

METHOD OnOnlineChange : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // update pointer to command FB
  AxesGroup.Acyclic.ActiveCommandRegister.OnOnlineChange( UniqueID := _uniqueID, pCommandFB := ADR(THIS^));

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // reset message IDs 
  InfoID    := 0;
  WarningID := 0;
  ErrorID   := 0;
  
  // get State
  _rspHeader.State                := ResponseData.GetHalfeByte1(IncPayloadPtr := FALSE);
  // get ParSeq
  _rspHeader.ParSeq               := ResponseData.GetHalfeByte2(IncPayloadPtr := TRUE);
  // get AlarmMessageSeverity
  _rspHeader.AlarmMessageSeverity := ResponseData.GetSint();
  // get AlarmMessageCode
  _rspHeader.AlarmMessageCode     := ResponseData.GetUint();
  
  
  // Update InfoID / WarningID / ErrorID
  CASE _rspHeader.AlarmMessageSeverity OF
  
    // Informative message
    Severity.INFO        : InfoID    := _rspHeader.AlarmMessageCode;
    // Warning message
    Severity.WARNING     : WarningID := _rspHeader.AlarmMessageCode;
    // Error message
    Severity.ERROR       : ErrorID   := _rspHeader.AlarmMessageCode; 
    // Fataö error message
    Severity.FATAL_ERROR : ErrorID   := _rspHeader.AlarmMessageCode;
  
  END_CASE
  
  
  ParseResponsePayload := ResponseData.PayloadPtr;

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  _parameterUpdateInternal := FALSE;
  _responseReceived := FALSE;
  
  _uniqueId := 0;
  _stepCmd  := 0;
  Error     := FALSE;
  ErrorID   := 0;
  WarningID := 0;
  InfoID    := 0;  
  
  Reset := RobotLibraryConstants.OK;

END_METHOD

