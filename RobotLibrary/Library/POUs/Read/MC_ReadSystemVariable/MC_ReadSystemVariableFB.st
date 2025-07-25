/// Read specific parameter of the robot
FUNCTION_BLOCK MC_ReadSystemVariableFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadSystemVariableFB                                       
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
  /// Processing Mode
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter 
  ParCmd             : ReadSystemVariableParCmd;
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • DataType
  /// • Data_0
  /// • Data_1
  /// • Data_2
  /// • Data_3
  /// • Data_4
  /// • Data_5
  /// • Data_6
  /// • Data_7
  Valid              : BOOL; 
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command outputs
  OutCmd             : ReadSystemVariableOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadSystemVariableParCmd;
  /// command data to send
 _command            : ReadSystemVariableSendData;
  /// response data received
 _response           : ReadSystemVariableRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ReadSystemVariable;
  
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
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  CheckParameterValid := TRUE;
  
  
  // Check ProcessingMode valid ? 
  IF (( ProcessingMode <> ProcessingModeEnum.BUFFERED           ) AND  
      ( ProcessingMode <> ProcessingModeEnum.ABORTING           ) AND  
      ( ProcessingMode <> ProcessingModeEnum.PARALLEL           ) AND
      ( ProcessingMode <> ProcessingModeEnum.CONTINUOUS         ) AND
      ( ProcessingMode <> ProcessingModeEnum.DEACTIVATE         ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_ONCE       ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_CONTINUOUS ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_MULTIPLE   ))  
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
                            MessageText := 'Invalid Parameter ProcessingMode = {1}',
                            Para1       :=  PROCESSING_MODE_TO_STRING(ProcessingMode));
    RETURN;                          
  END_IF
  
  
  // Check SequenceFlag valid ? 
  IF (( SequenceFlag <> SequenceFlagEnum.       NO_SEQUENCE ) AND  
      ( SequenceFlag <> SequenceFlagEnum.  PRIMARY_SEQUENCE ) AND  
      ( SequenceFlag <> SequenceFlagEnum.SECONDARY_SEQUENCE ))
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
                            MessageText := 'Invalid Parameter SequenceFlag = {1}',
                            Para1       :=  SEQUENCE_FLAG_TO_STRING(SequenceFlag));
    RETURN;                          
  END_IF
  
  
  FOR _idx := 0 TO 7
  DO
    // Check ParCmd.ParameterID valid ? 
    IF (( ParCmd.ParameterID[_idx] <   0   ) OR  
        ( ParCmd.ParameterID[_idx] > 65535 ))
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
                              MessageText := 'Invalid Parameter ParCmd.ParameterID[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.ParameterID[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  END_FOR
  
  
  // Check ParCmd.RCParameter
  // -> no plausibility check for boolean
  
  
  FOR _idx := 0 TO 7
  DO
    // Check ParCmd.SubParameterID valid ? 
    IF (( ParCmd.SubParameterID[_idx] <   0   ) OR  
        ( ParCmd.SubParameterID[_idx] > 65535 ))
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
                              MessageText := 'Invalid Parameter ParCmd.SubParameterID[{2}] = {1}',
                              Para1       := USINT_TO_STRING(ParCmd.SubParameterID[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  END_FOR
  
  
  // Check ParCmd.ListenerID valid ? 
  IF (( ParCmd.ListenerID <   0 ) OR  
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
                            Para1       :=  SINT_TO_STRING(ParCmd.ListenerID));
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
// Table 6-618: Sent CMD payload (PLC to RC) of "ReadSystemVariable"
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
// Byte 04 : SINT  EmitterID[0];
// Byte 05 : SINT  EmitterID[1];
// Byte 06 : SINT  EmitterID[2];
// Byte 07 : SINT  EmitterID[3];
// Byte 08 : SINT  ListenerID;
// Byte 09 : BYTE  Reserved;
// Byte 10 : UINT  ParameterID[0] HW HB;
// Byte 11 :       ParameterID[0] HW LB;
// Byte 12 : UINT  ParameterID[1] HW HB;
// Byte 13 :       ParameterID[1] HW LB;
// Byte 14 : UINT  ParameterID[2] HW HB;
// Byte 15 :       ParameterID[2] HW LB;
// Byte 16 : UINT  ParameterID[3] HW HB;
// Byte 17 :       ParameterID[3] HW LB;
// Byte 18 : UINT  ParameterID[4] HW HB;
// Byte 19 :       ParameterID[4] HW LB;
// Byte 20 : UINT  ParameterID[5] HW HB;
// Byte 21 :       ParameterID[5] HW LB;
// Byte 22 : UINT  ParameterID[6] HW HB;
// Byte 23 :       ParameterID[6] HW LB;
// Byte 24 : UINT  ParameterID[7] HW HB;
// Byte 25 :       ParameterID[7] HW LB;
// Byte 26 : USINT SubParameterID[0];
// Byte 27 : USINT SubParameterID[1];
// Byte 28 : USINT SubParameterID[2];
// Byte 29 : USINT SubParameterID[3];
// Byte 30 : USINT SubParameterID[4];
// Byte 31 : USINT SubParameterID[5];
// Byte 32 : USINT SubParameterID[6];
// Byte 33 : USINT SubParameterID[7];
// Byte 34 : BOOL  RCParameter;

// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ReadSystemVariable;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.EmitterID[0]   := 0;
  _command.EmitterID[1]   := 0;
  _command.EmitterID[2]   := 0;
  _command.EmitterID[3]   := 0;
  _command.Reserve        := 0;
  _command.ListenerID     := _parCmd.ListenerID;
  _command.ParameterID    := _parCmd.ParameterID;
  _command.SubParameterID := _parCmd.SubParameterID;
  _command.RCParameter    := _parCmd.RCParameter;
  
  
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
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Reserve
    CreateCommandPayload.AddByte(_command.Reserve);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  FOR _idx := 0 TO 7 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.ParameterID[_idx]
      CreateCommandPayload.AddUint(_command.ParameterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SubParameterID[_idx]
      CreateCommandPayload.AddUsint(_command.SubParameterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.RCParameter
    CreateCommandPayload.AddBool(_command.RCParameter);
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
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for ParameterID[x]
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.ParameterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.ParameterID[{2}] = {1}',
                            Para1       :=  UINT_TO_STRING(_command.ParameterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for SubParameterID[x]
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.SubParameterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SubParameterID[{2}] = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SubParameterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for RCParameter
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.RCParameter = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.RCParameter));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadSystemVariableFB';
  
  ExecMode       := ExecutionMode.PARALLEL;
  Priority       := PriorityLevel.NORMAL;
  ProcessingMode := ProcessingModeEnum.PARALLEL;
  SequenceFlag   := SequenceFlagEnum.NO_SEQUENCE;

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
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.DataType          := _response.DataType;
             OutCmd.Data_0            := _response.Data_0;
             OutCmd.Data_1            := _response.Data_1;
             OutCmd.Data_2            := _response.Data_2;
             OutCmd.Data_3            := _response.Data_3;
             OutCmd.Data_4            := _response.Data_4;
             OutCmd.Data_5            := _response.Data_5;
             OutCmd.Data_6            := _response.Data_6;
             OutCmd.Data_7            := _response.Data_7;
             
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
END_VAR// Table 6-619: Received CMD payload (RC to PLC) of "ReadSystemVariable"
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
// Byte 06 : INT   OriginID HW HB;
// Byte 07 :       OriginID HW LB;
// Byte 08 : USINT DataType[0];
// Byte 09 : USINT DataType[1];
// Byte 10 : USINT DataType[2];
// Byte 11 : USINT DataType[3];
// Byte 12 : USINT DataType[4];
// Byte 13 : USINT DataType[5];
// Byte 14 : USINT DataType[6];
// Byte 15 : USINT DataType[7];
// Byte 16 : BYTE  Data_0[0];
// Byte 17 : BYTE  Data_0[1];
// Byte 18 : BYTE  Data_0[2];
// Byte 19 : BYTE  Data_0[3];
// Byte 20 : BYTE  Data_1[0];
// Byte 21 : BYTE  Data_1[1];
// Byte 22 : BYTE  Data_1[2];
// Byte 23 : BYTE  Data_1[3];
// Byte 24 : BYTE  Data_2[0];
// Byte 25 : BYTE  Data_2[1];
// Byte 26 : BYTE  Data_2[2];
// Byte 27 : BYTE  Data_2[3];
// Byte 28 : BYTE  Data_3[0];
// Byte 29 : BYTE  Data_3[1];
// Byte 30 : BYTE  Data_3[2];
// Byte 31 : BYTE  Data_3[3];
// Byte 32 : BYTE  Data_4[0];
// Byte 33 : BYTE  Data_4[1];
// Byte 34 : BYTE  Data_4[2];
// Byte 35 : BYTE  Data_4[3];
// Byte 36 : BYTE  Data_5[0];
// Byte 37 : BYTE  Data_5[1];
// Byte 38 : BYTE  Data_5[2];
// Byte 39 : BYTE  Data_5[3];
// Byte 40 : BYTE  Data_6[0];
// Byte 41 : BYTE  Data_6[1];
// Byte 42 : BYTE  Data_6[2];
// Byte 43 : BYTE  Data_6[3];
// Byte 44 : BYTE  Data_7[0];
// Byte 45 : BYTE  Data_7[1];
// Byte 46 : BYTE  Data_7[2];
// Byte 47 : BYTE  Data_7[3];
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
  
   
  FOR _idx := 0 TO 7
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.DataType[_idx] := ResponseData.GetUsint();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_0[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_1[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_2[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_3[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_4[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_5[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_6[_idx] := ResponseData.GetByte();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DataType[_idx] 
     _response.Data_7[_idx] := ResponseData.GetByte();
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
  
  // Create log entry for DataType
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log messag for Response.DataType
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DataType[{2}] = {1}',
                            Para1       :=  USINT_TO_STRING(_response.DataType[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  END_FOR
  
  // Create log entry for Data_0
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    //  Create log entry for Responde.Data_0
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_0[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_0[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_1
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_1
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_1[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_1[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_2
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_2
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_2[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_2[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_3
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_3
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_3[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_3[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_4
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_4
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_4[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_4[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_5
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_5
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_5[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_5[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_6
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_6
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_6[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_6[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_7
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Respnose.Data_7
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Data_7[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_response.Data_7[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE; 
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

