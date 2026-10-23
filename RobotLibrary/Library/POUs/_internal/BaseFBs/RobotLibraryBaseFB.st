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
//             Licensed under the MIT License.
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
            
          
VAR
  /// ST-FIX F74: message of the command for the message buffer
  _alarmMessage : AlarmMessage;
END_VAR
VAR
  /// ST-FIX F105: block type and command name for the messages
  _messageSource : STRING;
END_VAR

  OnCall               (AxesGroup := AxesGroup);
  OnExecRun            (AxesGroup := AxesGroup);
  // ST-FIX F53: no response of the RC within _timeoutCmd after the command was added
  // -> error (before: _timerCmd was started but never evaluated, the FB stayed Busy)
  IF ( _uniqueID <> 0 ) AND ( _rspHeader.State = CmdMessageState.EMPTY ) AND ( NOT Error )
  THEN
    IF ( CheckTimeout( rTimer := _timerCmd ) = RobotLibraryConstants.OK )
    THEN
      AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd( UniqueID := _uniqueID );
      SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_TIMEOUT_CMD, Overwrite := TRUE );
      // Create log entry
      CreateLogMessage ( Timestamp   := AxesGroup.State.SystemTime,
                         MessageType := MessageType.CMD,
                         Severity    := Severity.ERROR,
                         MessageCode := ErrorID,
                         MessageText := 'No response of the RC within the command timeout');
      OnUpdateStateFlags( State := CmdMessageState.ERROR );
    END_IF
  END_IF
  CheckParameterChanged(AxesGroup := AxesGroup);
  
  
  IF ( AxesGroup.State.OnlineChange_R.Q )
  THEN
    OnOnlineChange(AxesGroup := AxesGroup);
  END_IF
  // ST-FIX F61: Error follows ErrorID in the same cycle, and with Error the other state outputs
  // are reset (Busy/Active/Done/CommandAborted exclusive, spec table 5-45)
  Error := ErrorID <> RobotLibraryConstants.OK;
  IF ( Error )
  THEN
    OnUpdateStateFlags( State := CmdMessageState.ERROR );
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
  // ST-FIX F61: Error follows ErrorID in the same cycle, and with Error the other state outputs
  // are reset (Busy/Active/Done/CommandAborted exclusive, spec table 5-45)
  Error := ErrorID <> RobotLibraryConstants.OK;
  IF ( Error )
  THEN
    OnUpdateStateFlags( State := CmdMessageState.ERROR );
  END_IF

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
  
  // ST-FIX F48: undefined ExecutionMode (spec table 5-75) -> error, not sent
  CASE _cmdHeader.ExecMode OF
    ExecutionMode.SEQUENCE_PRIMARY, ExecutionMode.SEQUENCE_ABORT_OTHERS_PRIMARY,
    ExecutionMode.PARALLEL, ExecutionMode.CONTINUOUS, ExecutionMode.TRIGGER_MULTIPLE,
    ExecutionMode.SEQUENCE_SECONDARY, ExecutionMode.SEQUENCE_ABORT_OTHERS_SECONDARY,
    ExecutionMode.STOP_PARALLEL_CONTINUOUS_TRIGGER: ;
  ELSE
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_EXECUTION_MODE, Overwrite := TRUE );
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid ExecutionMode = {1}',
                            Para1       := EXECUTION_MODE_TO_STRING(_cmdHeader.ExecMode));
    OnUpdateStateFlags( State := CmdMessageState.ERROR );
  END_CASE

END_METHOD

PROPERTY PUBLIC HasError : Bool


GET
VAR
END_VAR

  HasError := ErrorID <> RobotLibraryErrorIdEnum.NO_ERROR;

END_GET

PROPERTY PUBLIC HasInfo : BOOL


GET
VAR
END_VAR

  HasInfo := InfoID <> RobotLibraryInfoIdEnum.NO_INFO;

END_GET

PROPERTY PUBLIC HasWarning : BOOL


GET
VAR
END_VAR

  HasWarning := WarningID <> RobotLibraryWarningIdEnum.NO_WARNING;

END_GET

METHOD PROTECTED OnApplyOutCmd
VAR_INPUT
  /// Command message state
  State : CmdMessageState;
END_VAR


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
  
  
  // ST-FIX F105: the user defined command name belongs into the message text (spec 5.5.11,
  // table 5-47 "[Robot] [Client] [MoveLinAbs] [MoveToP1] [text]")
  _messageSource := MyType;
  IF ( Name <> '' )
  THEN
    _messageSource := CONCAT(MyType, CONCAT(' [', CONCAT(Name, ']')));
  END_IF
  
  // ST-FIX F74: every message of the command - also the client-side ones (e.g. parameter errors,
  // before: only with the severity of the last response of the RC) - goes into the message
  // buffer, with ACR entry and command type
  IF ( _error_R.Q ) AND ( LogLevel < Severity.ERROR )
  THEN
    _alarmMessage.Severity    := Severity.ERROR;
    IF ( ErrorID = _rspHeader.AlarmMessageCode ) AND ( _rspHeader.AlarmMessageSeverity > Severity.ERROR )
    THEN
      _alarmMessage.Severity  := _rspHeader.AlarmMessageSeverity; // e.g. fatal error of the RC
    END_IF
    _alarmMessage.Timestamp   := AxesGroup.State.SystemTime;
    _alarmMessage.MessageType := MessageType.CMD;
    _alarmMessage.MessageCode := ErrorID;
    _alarmMessage.AcrID       := UDINT_TO_UINT(_uniqueID);
    _alarmMessage.CmdType     := _cmdHeader.CmdTyp;
    _alarmMessage.MessageText := CONCAT(_messageSource, CONCAT(' : ', MESSAGE_CODE_TO_STRING(ErrorID))); // ST-FIX F105
    AxesGroup.MessageLog.AddMessageLog( MessageLog := _alarmMessage );
  END_IF
  IF ( _warning_R.Q ) AND ( LogLevel < Severity.WARNING )
  THEN
    _alarmMessage.Severity    := Severity.WARNING;
    IF ( WarningID = _rspHeader.AlarmMessageCode ) AND ( _rspHeader.AlarmMessageSeverity > Severity.WARNING )
    THEN
      _alarmMessage.Severity  := _rspHeader.AlarmMessageSeverity; // e.g. fatal error of the RC
    END_IF
    _alarmMessage.Timestamp   := AxesGroup.State.SystemTime;
    _alarmMessage.MessageType := MessageType.CMD;
    _alarmMessage.MessageCode := WarningID;
    _alarmMessage.AcrID       := UDINT_TO_UINT(_uniqueID);
    _alarmMessage.CmdType     := _cmdHeader.CmdTyp;
    _alarmMessage.MessageText := CONCAT(_messageSource, CONCAT(' : ', MESSAGE_CODE_TO_STRING(WarningID))); // ST-FIX F105
    AxesGroup.MessageLog.AddMessageLog( MessageLog := _alarmMessage );
  END_IF
  IF ( _info_R.Q ) AND ( LogLevel < Severity.INFO )
  THEN
    _alarmMessage.Severity    := Severity.INFO;
    IF ( InfoID = _rspHeader.AlarmMessageCode ) AND ( _rspHeader.AlarmMessageSeverity > Severity.INFO )
    THEN
      _alarmMessage.Severity  := _rspHeader.AlarmMessageSeverity; // e.g. fatal error of the RC
    END_IF
    _alarmMessage.Timestamp   := AxesGroup.State.SystemTime;
    _alarmMessage.MessageType := MessageType.CMD;
    _alarmMessage.MessageCode := InfoID;
    _alarmMessage.AcrID       := UDINT_TO_UINT(_uniqueID);
    _alarmMessage.CmdType     := _cmdHeader.CmdTyp;
    _alarmMessage.MessageText := CONCAT(_messageSource, CONCAT(' : ', MESSAGE_CODE_TO_STRING(InfoID))); // ST-FIX F105
    AxesGroup.MessageLog.AddMessageLog( MessageLog := _alarmMessage );
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

METHOD PROTECTED OnUpdateStateFlags
VAR_INPUT
  /// Command message state
  State : CmdMessageState;
END_VAR


END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // reset message IDs 
  // ST-FIX F62: InfoID/WarningID/ErrorID are held until the falling edge of Execute/Enable
  // (Reset), a response without message must not clear them (spec 5.5.10)
  
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
    Severity.INFO        : SetInfo   ( InfoID    := _rspHeader.AlarmMessageCode, Overwrite := TRUE );
    // Warning message
    Severity.WARNING     : SetWarning( WarningID := _rspHeader.AlarmMessageCode, Overwrite := TRUE );
    // Error message
    Severity.ERROR       : SetError  ( ErrorID   := _rspHeader.AlarmMessageCode, Overwrite := TRUE ); 
    // Fataö error message
    Severity.FATAL_ERROR : SetError  ( ErrorID   := _rspHeader.AlarmMessageCode, Overwrite := TRUE );
  
  END_CASE
  
  // ST-FIX F61: state ERROR without error code (or with severity INFO/WARNING) -> 16#8613
  IF ( _rspHeader.State = CmdMessageState.ERROR ) AND ( ErrorID = RobotLibraryConstants.OK )
  THEN
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_ROBOT_ERROR_NO_ID, Overwrite := TRUE );
    // Create log entry
    CreateLogMessage ( Timestamp   := Timestamp,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.ERROR,
                       MessageCode := ErrorID,
                       MessageText := 'Response of the RC with state ERROR but without error code');
  END_IF
  ParseResponsePayload := ResponseData.PayloadPtr;

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  _parameterUpdateInternal := FALSE;
  _responseReceived := FALSE;
  
  _uniqueId := 0;
  _rspHeader.State := CmdMessageState.EMPTY; // ST-FIX F53: no response yet
  _stepCmd  := 0;
  Error     := FALSE;
  ErrorID   := 0;
  WarningID := 0;
  InfoID    := 0;  
  
  Reset := RobotLibraryConstants.OK;

END_METHOD

METHOD PUBLIC SetError
VAR_INPUT
  /// ErrorID reported by RC for error identification according to Table 7-1
  ErrorID   : WORD;
  /// TRUE = overwrite an existing error 
  Overwrite : BOOL;
END_VAR

  IF ( NOT HasError ) OR ( Overwrite )
  THEN
    THIS^.ErrorID := ErrorID;
  END_IF

END_METHOD

METHOD PUBLIC SetInfo
VAR_INPUT
  /// InfoID for info identification reported during execution of command according to Table 7-5
  InfoID    : WORD;
  /// TRUE = overwrite an existing info 
  Overwrite : BOOL;
END_VAR

  IF ( NOT HasInfo ) OR ( Overwrite )
  THEN
    THIS^.InfoID := InfoID;
  END_IF

END_METHOD

METHOD PUBLIC SetWarning
VAR_INPUT
  /// WarningID for warning identification reported during execution of command according to Table 7-3
  WarningID : WORD;
  /// TRUE = overwrite an existing warning 
  Overwrite : BOOL;
END_VAR

  IF ( NOT HasWarning ) OR ( Overwrite )
  THEN
    THIS^.WarningID := WarningID;
  END_IF

END_METHOD

