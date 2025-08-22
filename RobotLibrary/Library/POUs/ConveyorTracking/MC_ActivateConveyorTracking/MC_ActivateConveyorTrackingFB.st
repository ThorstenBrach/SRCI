/// Activate conveyor tracking mode
FUNCTION_BLOCK MC_ActivateConveyorTrackingFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActivateConveyorTrackingFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
  /// Command parameter 
  ParCmd             : ActivateConveyorTrackingParCmd;      
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • TrackingStatusByte
  /// • RCEncoderValue
  Valid              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// Command output 
  OutCmd             : ActivateConveyorTrackingOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ActivateConveyorTrackingParCmd;
  /// command data to send
 _command            : ActivateConveyorTrackingSendData;
  /// response data received
 _response           : ActivateConveyorTrackingRecvData;  
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD INTERNAL CheckAddParameter : BOOL
VAR_INPUT
  /// Payload pointer
  PayloadPtr : UDINT;
END_VAR
VAR
  /// Payload as byte array
  Payload    : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Null Byte array 
  Null       : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Data length to compare
  DataLen    : UDINT;
END_VAR

  // Payload pointer must be decreased by one byte, because ADR(Payload) is already one byte !
  PayloadPtr := LIMIT (0, PayloadPtr - 1, SIZEOF(Payload) -1);
  // Convert command struct to payload array
  SysDepMemCpy( pDest := ADR(Payload), pSrc := ADR(_command), DataLen := SIZEOF(_command));
  // Calculate the data length to compare - at least one byte must be compared !
  DataLen := LIMIT(1, SIZEOF(Payload) - PayloadPtr, SIZEOF(Payload)); 
  // Compare Payload-Array with Null-Byte-Array
  CheckAddParameter := SysDepMemCmp( pData1 := ADR(Payload) + PayloadPtr , pData2 := ADR(Null), DataLen := DataLen) <>  RobotLibraryConstants.OK ;

END_METHOD

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ActivateConveyorTracking;
  
  IF ( NOT CheckFunctionSupported )
  THEN
    // call base implementation for set error and create log entry
    SUPER^.CheckFunctionSupported(AxesGroup := AxesGroup);
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  // Check ParCmd Size is > 0, because MemCmp does not work correctly with size = 0
  IF (SIZEOF(ParCmd) = 0) OR (_stepCmd = 0)
  THEN 
    RETURN;
  END_IF
  
  // compare memory 
  _parameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCmd), pData2 := ADR(_parCmd), DataLen := SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
  // check parameter valid ?
  _parameterValid   := CheckParameterValid( AxesGroup := AxesGroup );
  
  IF ((  _parameterChanged        )  AND 
      (  _parameterValid          )) OR
      (  _parameterUpdateInternal )  
  THEN  
    // reset internal flag for send parameter update
   _parameterUpdateInternal := FALSE;
    // update internal copy of parameters 
   _parCmd := ParCmd;
    // inc parameter sequence
   _command.ParSeq := _command.ParSeq + 1;
    // update command data  
    CommandData := CreateCommandPayload(AxesGroup := AxesGroup); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckParameterValid := TRUE;
  
  
  // Check ParCmd.ConveyorNo valid ? 
  IF (( ParCmd.ConveyorNo <   0 ) OR  
      ( ParCmd.ConveyorNo > 255 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ConveyorNo = {1}',
                            Para1       :=  SINT_TO_STRING(ParCmd.ConveyorNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConnectionMode valid ? 
  IF (( ParCmd.ConnectionMode <> ConnectionMode.RC_CONNECTED ) AND  
      ( ParCmd.ConnectionMode <> ConnectionMode.PLC_CONNECTED ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ConnectionMode = {1}',
                            Para1       :=  CONNECTION_MODE_TO_STRING(ParCmd.ConnectionMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.PLCEncoderValue valid ? 
  IF ( SysDepIsValidReal(ParCmd.PLCEncoderValue) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.PLCEncoderValue = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.PLCEncoderValue));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-438: Sent CMD payload (PLC to RC) of "ActivateConveyorTracking"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 04 : SINT  - ConveyorNo
// Byte 05 : SINT  - ConnectionMode
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ActivateConveyorTracking;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.ConveyorNo     := _parCmd.ConveyorNo;
  _command.ConnectionMode := _parCmd.ConnectionMode;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ConveyorNo
    CreateCommandPayload.AddSint(_command.ConveyorNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ConnectionMode
    CreateCommandPayload.AddSint(_command.ConnectionMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog 
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR_INPUT
  /// Parameter count
  ParameterCnt : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ConveyorNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorNo = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ConveyorNo));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ConnectionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConnectionMode = {1}',
                          Para1       :=  CONNECTION_MODE_TO_STRING(_command.ConnectionMode));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ActivateConveyorTrackingFB';
  
  ExecMode := ExecutionMode.CONTINUOUS;
  Priority := PriorityLevel.NORMAL;

END_METHOD

METHOD Protected OnExecCancel : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal return value 
 _retVal    : DINT;
END_VAR

  OnExecCancel := RobotLibraryConstants.RUNNING;
  
  CASE _stepCancel OF
    
    0: // set busy flag
       Busy := TRUE;
      
       // Create log entry
       CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                               MessageType := MessageType.CMD,
                               Severity    := Severity.DEBUG,
                               MessageCode := 0,
                               MessageText := 'Execution of {1} cancled ',
                               Para1       := MyType);                 
      
       // try to remove cmd
      _retVal := AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
    
       // check result of removement       
       IF ( _retVal = RobotLibraryConstants.OK )
       THEN
         // Reset step counter
        _stepCancel := 0;
         // finished okay
         OnExecCancel := RobotLibraryConstants.OK;
       
         // Create log entry
         CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                                 MessageType := MessageType.CMD,
                                 Severity    := Severity.DEBUG,
                                 MessageCode := 0,
                                 MessageText := '{1} successfully removed from ACR',
                                 Para1       := MyType);                 
       ELSE
         // set timeout
         SetTimeout(PT := _timeoutCancel, rTimer := _timerCancel);
         // inc step counter
        _stepCancel := _stepCancel + 1; 
       
         // Create log entry
         CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                                 MessageType := MessageType.CMD,
                                 Severity    := Severity.DEBUG,
                                 MessageCode := 0,
                                 MessageText := '{1} was not removed from ACR because execution was already in progress',
                                 Para1       := MyType);                 
       END_IF       
    
       
   1:  // call clear error 
       OnExecCancel := OnExecErrorClear(AxesGroup := AxesGroup);  
   
       IF ( OnExecCancel = RobotLibraryConstants.OK)
       THEN
         // Reset busy flag
         Busy := FALSE;
         // Reset step counter
        _stepCancel := 0;
         // finished okay
         OnExecCancel := RobotLibraryConstants.OK;
       END_IF  
    
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE  
  
  
                          
  // reset step counter
  IF (OnExecCancel <> RobotLibraryConstants.RUNNING)
  THEN
    // Reset FB variables
    Reset();
    // Reset step counter
   _stepCancel := 0;
  END_IF

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  OnExecErrorClear := RobotLibraryConstants.RUNNING;
  
  CASE _stepClearError OF
    
    0:  // set busy flag
        Busy := TRUE;
        // trigger parameter update to disable FB
       _parameterUpdateInternal := TRUE;
        // call Check Parameter changed method to trigger the parameter update to disable the function
        CheckParameterChanged(AxesGroup := AxesGroup);
        // set timeout
        SetTimeout(PT := _timeoutClearError, rTimer := _timerClearError);
        // inc step counter
       _stepClearError := _stepClearError + 1; 
        
    1: IF ( _responseReceived )
       THEN
         // reset response received flag
        _responseReceived := FALSE;
         // reset step counter
        _stepClearError := 0;
         // finished
         OnExecErrorClear := RobotLibraryConstants.OK;
       ELSE
         // timeout exceeded ? 
         IF (CheckTimeout(_timerClearError) = RobotLibraryConstants.OK)
         THEN
           OnExecErrorClear := RobotLibraryConstants.HAS_ERROR;
         END_IF
  	   END_IF
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE
  
  
  // reset step counter
  IF (OnExecErrorClear <> RobotLibraryConstants.RUNNING)
  THEN
    // Reset 
    Reset();     
    // reset step counter
   _stepClearError := 0;
  END_IF

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q ) AND ( NOT Error) 
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
  
           // Check function is supported and parameter are valid ?
           IF (( CheckFunctionSupported( AxesGroup := AxesGroup )) AND
               ( CheckParameterValid   ( AxesGroup := AxesGroup )))      
           THEN
             // set busy flag
             Busy := TRUE;
             // Reset command outputs
             SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
             // apply command parameter
            _parCmd := ParCmd;
             // init parameter sequence
            _command.ParSeq := 1;
             // create command data
             CommandData := CreateCommandPayload(AxesGroup := AxesGroup);
             // Add command to active command register
            _uniqueID := AxesGroup.Acyclic.ActiveCommandRegister.AddCmd( pCommandFB := ADR(THIS^ ));     
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1;
           END_IF 
         END_IF
       
  
    01:  // Wait for responce received
         IF ( _responseReceived )
         THEN
           // reset response received flag
          _responseReceived := FALSE;
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Update results
           OutCmd.TrackingStatus := _response.TrackingStatus;
           // Update enable flag
           Enabled := _response.TrackingStatus.ConveyorTrackingEnabled;
           
          
           // Enabled or Error ? -> Reset Busy flag  
           IF (( Enabled ) OR 
               ( Error   ))
           THEN  
             Busy := FALSE;
  				 END_IF
                  
         END_IF
  
         // do not abort directly, so that the ParSeq update can be send
         IF ( _enable_F.Q ) 
         THEN
           // Set Busy flag
           Busy := TRUE;
           // trigger parameter update to disable FB
          _parameterUpdateInternal := TRUE;
           // reset the falling edge
          _enable_F();
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
         
         
        // Wait for response received or timeout or not Initialized
    02: IF ((    _responseReceived                                   )  OR 
            (     CheckTimeout(_timerCmd) = RobotLibraryConstants.OK )) OR 
           (( NOT AxesGroup.State.Initialized                        )  AND
            ( NOT AxesGroup.State.Synchronized                       ))
        THEN
          Reset();   
  	    END_IF
              
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE
  
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-439: Received CMD payload (RC to PLC) of "ActivateConveyorTracking"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : BYTE  - TrackingStatusByte
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get Response.Enabled
   _response.TrackingStatus := ResponseData.GetTrackingStatus();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
  /// Parameter count
  ParameterCnt : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '{1} parameter(s) to parse from the response data:',
                          Para1       := DINT_TO_STRING(ParameterCnt));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.ConveyorTrackingEnabled
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.ConveyorTrackingEnabled = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.ConveyorTrackingEnabled));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.WaitingForSynchronization
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.WaitingForSynchronization = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.WaitingForSynchronization));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.Synchronizing
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.Synchronizing = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.Synchronizing));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.Synchronous
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.Synchronous = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.Synchronous));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.Desynchronizing
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.Desynchronizing = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.Desynchronizing));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.SyncOutZoneEntered
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.SyncOutZoneEntered = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.SyncOutZoneEntered));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.SyncOutZoneLeft
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.SyncOutZoneLeft = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.SyncOutZoneLeft));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrackingStatus.NotUsed
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrackingStatus.NotUsed = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrackingStatus.NotUsed));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Valid              := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

