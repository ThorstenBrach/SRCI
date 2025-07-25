/// Trigger "Actions" based on physical events (e.g. force limit reached)
FUNCTION_BLOCK MC_SetTriggerLimitFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerLimitFB                                       
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
  /// command parameter 
  ParCmd           : SetTriggerLimitParCmd;
  /// Processing mode
  ProcessingMode   : ProcessingMode;
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • Data
  Valid            : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered  : BOOL;
  /// TRUE, when the monitoring of the input parameter values is active.
  MonitoringActive : BOOL;
  /// command results
  OutCmd           : SetTriggerLimitOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd           : SetTriggerLimitParCmd;
  /// command data to send
 _command          : SetTriggerLimitSendData;
  /// response data received
 _response         : SetTriggerLimitRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.SetTriggerLimit;
  
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
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  CheckParameterValid := TRUE;
  
  // Check ProcessingMode valid ? 
  IF (( ProcessingMode <> ProcessingModeEnum.DEACTIVATE       ) AND 
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_ONCE     ) AND  
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_MULTIPLE ))  
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_PROCESSINGMODE_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ProcessingMode = {1}',
                            Para1       := PROCESSING_MODE_TO_STRING(ProcessingMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReactionMode valid ? 
  IF (( ParCmd.TriggerMode <> TriggerModeLimit.INVALID         ) AND
      ( ParCmd.TriggerMode <> TriggerModeLimit.JOINT_CURRENT   ) AND
      ( ParCmd.TriggerMode <> TriggerModeLimit.FORCE           ) AND
      ( ParCmd.TriggerMode <> TriggerModeLimit.FOLLOWING_ERROR ) AND
      ( ParCmd.TriggerMode <> TriggerModeLimit.TEMPERATURE     ))
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
                            MessageText := 'Invalid Parameter ParCmd.TriggerMode = {1}',
                            Para1       := TRIGGER_MODE_LIMIT_TO_STRING(ParCmd.TriggerMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.EvaluateStartCondition
  // -> no plausibility check for boolean
  
  FOR _idx := 0 TO 11
  DO
    // Check ParCmd.Data_1[_idx] valid ? 
    IF ( SysDepIsValidReal(ParCmd.Data_1[_idx]) = FALSE ) 
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.Data_1[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.Data_1[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  
    // Check ParCmd.Data_2[_idx] valid ? 
    IF ( SysDepIsValidReal(ParCmd.Data_2[_idx]) = FALSE ) 
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.Data_2[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.Data_2[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  END_FOR
  
  // Check ParCmd.ListenerID valid ? 
  IF  (( ParCmd.ListenerID <   0 ) OR
       ( ParCmd.ListenerID > 127 ))     
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
                            MessageText := 'Invalid Parameter ParCmd.ListenerID = {1}',
                            Para1       := SINT_TO_STRING(ParCmd.ListenerID));
    RETURN;
  END_IF
  
  
  // Check ParCmd.EmitterID valid ? 
  IF  (( ParCmd.EmitterID < -127 ) OR
       ( ParCmd.EmitterID >  127 ))     
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
                            MessageText := 'Invalid Parameter ParCmd.EmitterID = {1}',
                            Para1       := SINT_TO_STRING(ParCmd.EmitterID));
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx          : DINT;
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-585: Sent CMD payload (PLC to RC) of "SetTriggerLimit"
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
 // Byte 00 : UINT  Type;
 // Byte 01 :       Type;
 // Byte 02 : USINT Reserved ExecutionMode;
 // Byte 03 : USINT ParSeq Priority;
 // Byte 04 : SINT  EmitterID[0];
 // Byte 05 : SINT  EmitterID[1];
 // Byte 06 : SINT  EmitterID[2];
 // Byte 07 : SINT  EmitterID[3];
 // Byte 08 : SINT  ListenerID;
 // Byte 09 : REAL  Data_1[0];
 // Byte 10 :       Data_1[0];
 // Byte 11 :       Data_1[0];
 // Byte 12 :       Data_1[0];
 // Byte 13 : REAL  Data_1[1];
 // Byte 14 :       Data_1[1];
 // Byte 15 :       Data_1[1];
 // Byte 16 :       Data_1[1];
 // Byte 17 : REAL  Data_1[2];
 // Byte 18 :       Data_1[2];
 // Byte 19 :       Data_1[2];
 // Byte 20 :       Data_1[2];
 // Byte 21 : REAL  Data_1[3];
 // Byte 22 :       Data_1[3];
 // Byte 23 :       Data_1[3];
 // Byte 24 :       Data_1[3];
 // Byte 25 : REAL  Data_1[4];
 // Byte 26 :       Data_1[4];
 // Byte 27 :       Data_1[4];
 // Byte 28 :       Data_1[4];
 // Byte 29 : REAL  Data_1[5];
 // Byte 30 :       Data_1[5];
 // Byte 31 :       Data_1[5];
 // Byte 32 :       Data_1[5];
 // Byte 33 : REAL  Data_1[6];
 // Byte 34 :       Data_1[6];
 // Byte 35 :       Data_1[6];
 // Byte 36 :       Data_1[6];
 // Byte 37 : REAL  Data_1[7];
 // Byte 38 :       Data_1[7];
 // Byte 39 :       Data_1[7];
 // Byte 40 :       Data_1[7];
 // Byte 41 : REAL  Data_1[8];
 // Byte 42 :       Data_1[8];
 // Byte 43 :       Data_1[8];
 // Byte 44 :       Data_1[8];
 // Byte 45 : REAL  Data_1[9];
 // Byte 46 :       Data_1[9];
 // Byte 47 :       Data_1[9];
 // Byte 48 :       Data_1[9];
 // Byte 49 : REAL  Data_1[10];
 // Byte 50 :       Data_1[10];
 // Byte 51 :       Data_1[10];
 // Byte 52 :       Data_1[10];
 // Byte 53 : REAL  Data_1[11];
 // Byte 54 :       Data_1[11];
 // Byte 55 :       Data_1[11];
 // Byte 56 :       Data_1[11];
 // Byte 57 : REAL  Data_2[0];
 // Byte 58 :       Data_2[0];
 // Byte 59 :       Data_2[0];
 // Byte 60 :       Data_2[0];
 // Byte 61 : REAL  Data_2[1];
 // Byte 62 :       Data_2[1];
 // Byte 63 :       Data_2[1];
 // Byte 64 :       Data_2[1];
 // Byte 65 : REAL  Data_2[2];
 // Byte 66 :       Data_2[2];
 // Byte 67 :       Data_2[2];
 // Byte 68 :       Data_2[2];
 // Byte 69 : REAL  Data_2[3];
 // Byte 70 :       Data_2[3];
 // Byte 71 :       Data_2[3];
 // Byte 72 :       Data_2[3];
 // Byte 73 : REAL  Data_2[4];
 // Byte 74 :       Data_2[4];
 // Byte 75 :       Data_2[4];
 // Byte 76 :       Data_2[4];
 // Byte 77 : REAL  Data_2[5];
 // Byte 78 :       Data_2[5];
 // Byte 79 :       Data_2[5];
 // Byte 80 :       Data_2[5];
 // Byte 81 : REAL  Data_2[6];
 // Byte 82 :       Data_2[6];
 // Byte 83 :       Data_2[6];
 // Byte 84 :       Data_2[6];
 // Byte 85 : REAL  Data_2[7];
 // Byte 86 :       Data_2[7];
 // Byte 87 :       Data_2[7];
 // Byte 88 :       Data_2[7];
 // Byte 89 : REAL  Data_2[8];
 // Byte 90 :       Data_2[8];
 // Byte 91 :       Data_2[8];
 // Byte 92 :       Data_2[8];
 // Byte 93 : REAL  Data_2[9];
 // Byte 94 :       Data_2[9];
 // Byte 95 :       Data_2[9];
 // Byte 96 :       Data_2[9];
 // Byte 97 : REAL  Data_2[10];
 // Byte 98 :       Data_2[10];
 // Byte 99 :       Data_2[10];
 // Byte 100:       Data_2[10];
 // Byte 101: REAL  Data_2[11];
 // Byte 102:       Data_2[11];
 // Byte 103:       Data_2[11];
 // Byte 104:       Data_2[11];
 // Byte 105: SINT  TriggerMode;
 // Byte 106: BOOL  EvaluateStartCondition;

  // set command parameter 
  _command.CmdTyp                 :=  CmdType.SetTriggerLimit;
  _command.ExecMode               :=  ExecMode;
  _command.ParSeq                 := _command.ParSeq;
  _command.Priority               :=  Priority;                                
  _command.EmitterID[0]           := _parCmd.EmitterID;
  _command.EmitterID[1]           := 0;
  _command.EmitterID[2]           := 0;
  _command.EmitterID[3]           := 0;
  _command.ListenerID             := _parCmd.ListenerID;
  _command.Data_1                 := _parCmd.Data_1;
  _command.Data_2                 := _parCmd.Data_2;
  _command.TriggerMode            := _parCmd.TriggerMode;
  _command.EvaluateStartCondition := _parCmd.EvaluateStartCondition;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.EmitterID[x]
      CreateCommandPayload.AddSint(_command.EmitterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ListenerID
    CreateCommandPayload.AddSint(_command.ListenerID);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  FOR _idx := 0 TO 11 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_1[_idx]
      CreateCommandPayload.AddReal(_command.Data_1[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 11 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_2[_idx]
      CreateCommandPayload.AddReal(_command.Data_2[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TriggerMode
    CreateCommandPayload.AddSint(_command.TriggerMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.EvaluateStartCondition
    CreateCommandPayload.AddBool(_command.EvaluateStartCondition);
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
VAR 
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.EmitterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
                          
  // Create log entry for Command.Data_1[x]
  FOR _idx := 0 TO 11 
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_1
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_1[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_command.Data_1[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Command.Data_2[x]
  FOR _idx := 0 TO 11 
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_2
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_2[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_command.Data_2[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SetTriggerLimitFB';
  
  ExecMode       := ExecutionMode.PARALLEL;
  Priority       := PriorityLevel.NORMAL;
  ProcessingMode := ProcessingModeEnum.TRIGGER_ONCE;

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _execute_R.Q ) AND ( NOT Error)  
         THEN
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
           // reset MonitoringActive flag
           MonitoringActive := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED : CommandBuffered  := TRUE;
             CmdMessageState.ACTIVE   : MonitoringActive := TRUE;
             CmdMessageState.DONE     : Done             := TRUE;
             CmdMessageState.ERROR    : Error            := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.FollowID          := 0; {warning 'ToDo'}
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.OriginID          := _response.OriginID;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
  
    02: IF ( NOT Execute)
        THEN
          Reset();
        END_IF     
  
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE
  
  
  // Reset FB
  IF ( NOT Execute )
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
  /// internal index for loops
 _idx          : DINT;
  /// Parameter count
 _parameterCnt : DINT;
END_VAR// Table 6-586: Received CMD payload (RC to PLC) of "SetTriggerLimit"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT   - ParSeq | State     
// Byte 01 : SINT    - AlarmMessageSeverity    
// Byte 02 : UINT    - AlarmMessageCode HB
// Byte 03 :         - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : USINT InvocationCounter;
// Byte 05 : SINT  Reserved;
// Byte 06 : INT   OriginID;
// Byte 07 :       OriginID;
// Byte 08 : REAL  Data[0];
// Byte 09 :       Data[0];
// Byte 10 :       Data[0];
// Byte 11 :       Data[0];
// Byte 12 : REAL  Data[1];
// Byte 13 :       Data[1];
// Byte 14 :       Data[1];
// Byte 15 :       Data[1];
// Byte 16 : REAL  Data[2];
// Byte 17 :       Data[2];
// Byte 18 :       Data[2];
// Byte 19 :       Data[2];
// Byte 20 : REAL  Data[3];
// Byte 21 :       Data[3];
// Byte 22 :       Data[3];
// Byte 23 :       Data[3];
// Byte 24 : REAL  Data[4];
// Byte 25 :       Data[4];
// Byte 26 :       Data[4];
// Byte 27 :       Data[4];
// Byte 28 : REAL  Data[5];
// Byte 29 :       Data[5];
// Byte 30 :       Data[5];
// Byte 31 :       Data[5];

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
    // Get Response.InvocationCounter
    _response.InvocationCounter := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Reserve
   _response.Reserve := ResponseData.GetSint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.OriginID
   _response.OriginID := ResponseData.GetInt();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  FOR _idx := 0 TO 11
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.OriginID
     _response.Data[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF  
  END_FOR
  
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
VAR 
  /// internal index for loops
 _idx : DINT;
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
  // Create log entry for InvocationCounter
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InvocationCounter = {1}',
                          Para1       :=  USINT_TO_STRING(_response.InvocationCounter));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  SINT_TO_STRING(_response.Reserve));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for OriginID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.OriginID = {1}',
                          Para1       :=  INT_TO_STRING(_response.OriginID));
  
  // Create log entry for Data[x]
  FOR _idx := 0 TO 11
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Response.Data
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Data[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done              := FALSE;
  Busy              := FALSE;
  Valid             := FALSE;
  CommandBuffered   := FALSE;
  MonitoringActive  := FALSE;

END_METHOD

