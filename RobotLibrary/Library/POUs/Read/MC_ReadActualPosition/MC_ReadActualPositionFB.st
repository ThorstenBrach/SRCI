/// Read the actual position – TCP: X…RZ + config/Turn, … Joint: (J1…E6)
FUNCTION_BLOCK MC_ReadActualPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionFB                                       
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
  /// Processing mode - For more information see chapter 5.6.4.5.
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;  
  /// command parameter 
  ParCmd             : ReadActualPositionParCmd;
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values
  /// • ActualCartesianPosition
  /// • ToolNoReturn
  /// • FrameNoReturn
  /// • ActualJointPosition
  Valid              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;  
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command outputs
  OutCmd             : ReadActualPositionOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadActualPositionParCmd;
  /// command data to send
 _command            : ReadActualPositionSendData;
  /// response data received
 _response           : ReadActualPositionRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ReadActualPosition;
  
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
  
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <  -1                                                ) OR  
      ( ParCmd.ToolNo > 254                                                ) OR
      ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex ) OR
      ( ParCmd.ToolNo > RobotLibraryParameter.TOOL_MAX -1                  ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check ToolNo available on RC ? 
    IF ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ToolNo = {1}',
                            Para1       :=  INT_TO_STRING(ParCmd.ToolNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <  -1                                                 ) OR  
      ( ParCmd.FrameNo > 254                                                 ) OR
      ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex ) OR
      ( ParCmd.FrameNo > RobotLibraryParameter.FRAME_MAX -1                  ))         
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check FrameNo available on RC ? 
    IF ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.FrameNo = {1}',
                            Para1       :=  INT_TO_STRING(ParCmd.FrameNo));
    RETURN;                          
  END_IF
  
  
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
// Table 6-38: Sent CMD payload (PLC to RC) of "ReadActualPosition"
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
// Byte 10 : USINT ToolNo
// Byte 11 : USINT FrameNo
// --------------------------

  // set command parameter 
  _command.CmdTyp       :=  CmdType.ReadActualPosition;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.EmitterID[0] := 0;
  _command.EmitterID[1] := 0;
  _command.EmitterID[2] := 0;
  _command.EmitterID[3] := 0;
  _command.Reserve      := 0;
  _command.ListenerID   := _parCmd.ListenerID;
  _command.ToolNo       := INT_TO_USINT(_parCmd.ToolNo);
  _command.FrameNo      := INT_TO_USINT(_parCmd.FrameNo);
  
  IF (_parCmd.ToolNo = -1 )
  THEN
   _command.ToolNo := 255; // -1 is mapped to 255, see specification
  END_IF
  
  IF (_parCmd.FrameNo = -1 )
  THEN
   _command.FrameNo := 255; // -1 is mapped to 255, see specification
  END_IF
  
  
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
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Index[0]
    CreateCommandPayload.AddUsint(_command.ToolNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Index[1]
    CreateCommandPayload.AddUsint(_command.FrameNo);
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
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ToolNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ToolNo));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadActualPositionFB';
  
  ExecMode       := ExecutionMode.PARALLEL;
  Priority       := PriorityLevel.NORMAL;
  ProcessingMode := ProcessingModeEnum.PARALLEL;
  SequenceFlag := SequenceFlagEnum.NO_SEQUENCE;

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
             OutCmd.OriginID                := _response.OriginID;
             OutCmd.InvocationCounter       := _response.InvocationCounter;
             OutCmd.ToolNoReturn            := _response.ToolNoReturn;
             OutCmd.FrameNoReturn           := _response.FrameNoReturn;
             OutCmd.ActualCartesianPosition := _response.ActualCartesianPosition;
             OutCmd.ActualJointPosition     := _response.ActualJointPosition;
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
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-39: Received CMD payload (RC to PLC) of "ReadActualPosition"
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
// Byte 04 : USINT   - InvocationCounter;
// Byte 05 : SINT    - Reserved;
// Byte 06 : INT     - OriginID HW HB;
// Byte 07 :         - OriginID HW LB;
// Byte 08 : USINT   - ToolNoReturn;
// Byte 09 : USINT   - FrameNoReturn;
// Byte 10 : REAL    - ActualCartesianPosition.X HW HB;
// Byte 11 :         - ActualCartesianPosition.X HW LB;
// Byte 12 :         - ActualCartesianPosition.X LW HB;
// Byte 13 :         - ActualCartesianPosition.X LW LB;
// Byte 14 : REAL    - ActualCartesianPosition.Y HW HB;
// Byte 15 :         - ActualCartesianPosition.Y HW LB;
// Byte 16 :         - ActualCartesianPosition.Y LW HB;
// Byte 17 :         - ActualCartesianPosition.Y LW LB;
// Byte 18 : REAL    - ActualCartesianPosition.Z HW HB;
// Byte 19 :         - ActualCartesianPosition.Z HW LB;
// Byte 20 :         - ActualCartesianPosition.Z LW HB;
// Byte 21 :         - ActualCartesianPosition.Z LW LB;
// Byte 22 : REAL    - ActualCartesianPosition.RX HW HB;
// Byte 23 :         - ActualCartesianPosition.RX HW LB;
// Byte 24 :         - ActualCartesianPosition.RX LW HB;
// Byte 25 :         - ActualCartesianPosition.RX LW LB;
// Byte 26 : REAL    - ActualCartesianPosition.RY HW HB;
// Byte 27 :         - ActualCartesianPosition.RY HW LB;
// Byte 28 :         - ActualCartesianPosition.RY LW HB;
// Byte 29 :         - ActualCartesianPosition.RY LW LB;
// Byte 30 : REAL    - ActualCartesianPosition.RZ HW HB;
// Byte 31 :         - ActualCartesianPosition.RZ HW LB;
// Byte 32 :         - ActualCartesianPosition.RZ LW HB;
// Byte 33 :         - ActualCartesianPosition.RZ LW LB;
// Byte 34 : BYTE    - W E S;
// Byte 35 : BYTE    - Reserved;
// Byte 36 : BYTE    - ActualCartesianPosition.TurnNumber[0];
// Byte 37 : BYTE    - ActualCartesianPosition.TurnNumber[1];
// Byte 38 : BYTE    - ActualCartesianPosition.TurnNumber[2];
// Byte 39 : BYTE    - ActualCartesianPosition.TurnNumber[3];
// Byte 40 : REAL    - ActualJointPosition.J1 HW HB;
// Byte 41 :         - ActualJointPosition.J1 HW LB;
// Byte 42 :         - ActualJointPosition.J1 LW HB;
// Byte 43 :         - ActualJointPosition.J1 LW LB;
// Byte 44 : REAL    - ActualJointPosition.J2 HW HB;
// Byte 45 :         - ActualJointPosition.J2 HW LB;
// Byte 46 :         - ActualJointPosition.J2 LW HB;
// Byte 47 :         - ActualJointPosition.J2 LW LB;
// Byte 48 : REAL    - ActualJointPosition.J3 HW HB;
// Byte 49 :         - ActualJointPosition.J3 HW LB;
// Byte 50 :         - ActualJointPosition.J3 LW HB;
// Byte 51 :         - ActualJointPosition.J3 LW LB;
// Byte 52 : REAL    - ActualJointPosition.J4 HW HB;
// Byte 53 :         - ActualJointPosition.J4 HW LB;
// Byte 54 :         - ActualJointPosition.J4 LW HB;
// Byte 55 :         - ActualJointPosition.J4 LW LB;
// Byte 56 : REAL    - ActualJointPosition.J5 HW HB;
// Byte 57 :         - ActualJointPosition.J5 HW LB;
// Byte 58 :         - ActualJointPosition.J5 LW HB;
// Byte 59 :         - ActualJointPosition.J5 LW LB;
// Byte 60 : REAL    - ActualJointPosition.J6 HW HB;
// Byte 61 :         - ActualJointPosition.J6 HW LB;
// Byte 62 :         - ActualJointPosition.J6 LW HB;
// Byte 63 :         - ActualJointPosition.J6 LW LB;
// Byte 64 : REAL    - ActualCartesianPosition.E1 HW HB;
// Byte 65 :         - ActualCartesianPosition.E1 HW LB;
// Byte 66 :         - ActualCartesianPosition.E1 LW HB;
// Byte 67 :         - ActualCartesianPosition.E1 LW LB;
// Byte 68 : REAL    - ActualCartesianPosition.E2 HW HB;
// Byte 69 :         - ActualCartesianPosition.E2 HW LB;
// Byte 70 :         - ActualCartesianPosition.E2 LW HB;
// Byte 71 :         - ActualCartesianPosition.E2 LW LB;
// Byte 72 : REAL    - ActualCartesianPosition.E3 HW HB;
// Byte 73 :         - ActualCartesianPosition.E3 HW LB;
// Byte 74 :         - ActualCartesianPosition.E3 LW HB;
// Byte 75 :         - ActualCartesianPosition.E3 LW LB;
// Byte 76 : REAL    - ActualCartesianPosition.E4 HW HB;
// Byte 77 :         - ActualCartesianPosition.E4 HW LB;
// Byte 78 :         - ActualCartesianPosition.E4 LW HB;
// Byte 79 :         - ActualCartesianPosition.E4 LW LB;
// Byte 80 : REAL    - ActualCartesianPosition.E5 HW HB;
// Byte 81 :         - ActualCartesianPosition.E5 HW LB;
// Byte 82 :         - ActualCartesianPosition.E5 LW HB;
// Byte 83 :         - ActualCartesianPosition.E5 LW LB;
// Byte 84 : REAL    - ActualCartesianPosition.E6 HW HB;
// Byte 85 :         - ActualCartesianPosition.E6 HW LB;
// Byte 86 :         - ActualCartesianPosition.E6 LW HB;
// Byte 87 :         - ActualCartesianPosition.E6 LW LB;
// Byte 88 : REAL    - ActualJointPosition.E1 HW HB;
// Byte 89 :         - ActualJointPosition.E1 HW LB;
// Byte 90 :         - ActualJointPosition.E1 LW HB;
// Byte 91 :         - ActualJointPosition.E1 LW LB;
// Byte 92 : REAL    - ActualJointPosition.E2 HW HB;
// Byte 93 :         - ActualJointPosition.E2 HW LB;
// Byte 94 :         - ActualJointPosition.E2 LW HB;
// Byte 95 :         - ActualJointPosition.E2 LW LB;
// Byte 96 : REAL    - ActualJointPosition.E3 HW HB;
// Byte 97 :         - ActualJointPosition.E3 HW LB;
// Byte 98 :         - ActualJointPosition.E3 LW HB;
// Byte 99 :         - ActualJointPosition.E3 LW LB;
// Byte 100: REAL    - ActualJointPosition.E4 HW HB;
// Byte 101:         - ActualJointPosition.E4 HW LB;
// Byte 102:         - ActualJointPosition.E4 LW HB;
// Byte 103:         - ActualJointPosition.E4 LW LB;
// Byte 104: REAL    - ActualJointPosition.E5 HW HB;
// Byte 105:         - ActualJointPosition.E5 HW LB;
// Byte 106:         - ActualJointPosition.E5 LW HB;
// Byte 107:         - ActualJointPosition.E5 LW LB;
// Byte 108: REAL    - ActualJointPosition.E6 HW HB;
// Byte 109:         - ActualJointPosition.E6 HW LB;
// Byte 110:         - ActualJointPosition.E6 LW HB;
// Byte 111:         - ActualJointPosition.E6 LW LB;
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
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ToolNoReturn
   _response.ToolNoReturn := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.FrameNoReturn
   _response.FrameNoReturn := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.X
   _response.ActualCartesianPosition.X := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Y
   _response.ActualCartesianPosition.Y := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Z
   _response.ActualCartesianPosition.Z := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Rx
   _response.ActualCartesianPosition.Rx := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Ry
   _response.ActualCartesianPosition.Ry := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Rz
   _response.ActualCartesianPosition.Rz := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.Config
   _response.ActualCartesianPosition.Config := ResponseData.GetArmConfig();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.TurnNumber
   _response.ActualCartesianPosition.TurnNumber := ResponseData.GetTurnNumbers();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E1
   _response.ActualCartesianPosition.E1 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J1
   _response.ActualJointPosition.J1 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J2
   _response.ActualJointPosition.J2 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J3
   _response.ActualJointPosition.J3 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J4
   _response.ActualJointPosition.J4 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J5
   _response.ActualJointPosition.J5 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.J6
   _response.ActualJointPosition.J6 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E2
   _response.ActualCartesianPosition.E2 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E3
   _response.ActualCartesianPosition.E3 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E4
   _response.ActualCartesianPosition.E4 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E5
   _response.ActualCartesianPosition.E5 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualCartesianPosition.E6
   _response.ActualCartesianPosition.E6 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E1
   _response.ActualJointPosition.E1 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E2
   _response.ActualJointPosition.E2 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E3
   _response.ActualJointPosition.E3 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E4
   _response.ActualJointPosition.E4 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E5
   _response.ActualJointPosition.E5 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ActualJointPosition.E6
   _response.ActualJointPosition.E6 := ResponseData.GetReal();
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
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ToolNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolNoReturn = {1}',
                          Para1       :=  INT_TO_STRING(_response.ToolNoReturn));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for FrameNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.FrameNoReturn = {1}',
                          Para1       :=  INT_TO_STRING(_response.FrameNoReturn));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.Y));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.Rx));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.Config
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_response.ActualCartesianPosition.Config));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J2Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J2Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J2Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J3Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J3Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J3Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J4Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J4Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J4Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J5Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J5Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J5Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.J6Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.J6Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.J6Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.TurnNumber.E1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.TurnNumber.E1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActualCartesianPosition.TurnNumber.E1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J1 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J2 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J3
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J3 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J4
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J4 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J5
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J5 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.J6
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.J6 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.J6));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E2));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E3
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E4
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E5
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualCartesianPosition.E6
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualCartesianPosition.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualCartesianPosition.E6));           
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E3
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E3));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E4
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E5
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E5));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActualJointPosition.E6
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActualJointPosition.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ActualJointPosition.E6));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE;
  ParameterAccepted  := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

