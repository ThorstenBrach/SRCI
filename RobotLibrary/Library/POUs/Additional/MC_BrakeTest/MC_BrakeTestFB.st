/// Activate robot cycle brake test and give feedback to PLC
FUNCTION_BLOCK MC_BrakeTestFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BrakeTest                                       
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
  /// Command parameter 
  ParCmd             : BrakeTestParCmd;
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands.
  AbortingMode       : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;  
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// During the realization of the brake test, the command controls the motion of the respective axis group.
  /// TRUE: The brake test is being realized
  /// FALSE: The brake test is not realized
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL; 
  /// Command output 
  OutCmd             : BrakeTestOutCmd;
END_VAR

var
  /// internal copy of command parameter 
 _parCmd             : BrakeTestParCmd;
  /// command data to send
 _command            : BrakeTestSendData;
  /// response data received
 _response           : BrakeTestRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.BrakeTest;
  
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

  CheckParameterValid := TRUE;
  
  // Check ParCmd.SequenceFlag valid ? 
  IF (( SequenceFlag <> SequenceFlagEnum.PRIMARY_SEQUENCE   ) AND  
      ( SequenceFlag <> SequenceFlagEnum.SECONDARY_SEQUENCE ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_SEQFLAG_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter SequenceFlag = {1}',
                            Para1       := SEQUENCE_FLAG_TO_STRING (SequenceFlag));
    RETURN;                          
  END_IF
  
  
  // Check AbortingMode valid ? 
  IF (( AbortingMode <> AbortingModeEnum.BUFFER ) AND  
      ( AbortingMode <> AbortingModeEnum.ABORT  ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_ABORTINGMODE_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter AbortingMode = {1}',
                            Para1       := ABORTING_MODE_TO_STRING(AbortingMode));
    RETURN;                          
  END_IF
  
  
  // Check RobotAxesActive valid ? 
  IF ((( ParCmd.RobotAxesActive.AxisJ1 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J1 )) OR
      (( ParCmd.RobotAxesActive.AxisJ2 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J2 )) OR
      (( ParCmd.RobotAxesActive.AxisJ3 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J3 )) OR
      (( ParCmd.RobotAxesActive.AxisJ4 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J4 )) OR
      (( ParCmd.RobotAxesActive.AxisJ5 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J5 )) OR
      (( ParCmd.RobotAxesActive.AxisJ6 ) AND ( NOT AxesGroup.State.RobotData.AxisJointUsed.J6 )))  
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
                            MessageText := 'Invalid Parameter ParCmd.RobotAxesActive = {1}',
                            Para1       := ROBOT_AXES_FLAGS_TO_STRING(ParCmd.RobotAxesActive));
    RETURN;                          
  END_IF
  
  
  // Check ExternalAxesActive valid ? 
  IF ((( ParCmd.ExternalAxesActive.AxisE1 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E1 )) OR
      (( ParCmd.ExternalAxesActive.AxisE2 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E2 )) OR
      (( ParCmd.ExternalAxesActive.AxisE3 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E3 )) OR
      (( ParCmd.ExternalAxesActive.AxisE4 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E4 )) OR
      (( ParCmd.ExternalAxesActive.AxisE5 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E5 )) OR
      (( ParCmd.ExternalAxesActive.AxisE6 ) AND ( NOT AxesGroup.State.RobotData.AxisExternalUsed.E6 )))  
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
                            MessageText := 'Invalid Parameter ParCmd.ExternalAxesActive = {1}',
                            Para1       := EXTERNAL_AXES_FLAGS_TO_STRING(ParCmd.ExternalAxesActive));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-740: Sent CMD payload (PLC to RC) of "BrakeTest"
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
// Byte 04 : BYTE - RobotAxesActive
// Byte 05 : BYTE - ExternalAxesActive
// --------------------------

  // set command parameter 
  _command.CmdTyp               :=  CmdType.BrakeTest;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  _command.RobotAxesActive.0    := _parCmd.RobotAxesActive.Bit00;
  _command.RobotAxesActive.1    := _parCmd.RobotAxesActive.AxisJ1;
  _command.RobotAxesActive.2    := _parCmd.RobotAxesActive.AxisJ2;
  _command.RobotAxesActive.3    := _parCmd.RobotAxesActive.AxisJ3;
  _command.RobotAxesActive.4    := _parCmd.RobotAxesActive.AxisJ4;
  _command.RobotAxesActive.5    := _parCmd.RobotAxesActive.AxisJ5;
  _command.RobotAxesActive.6    := _parCmd.RobotAxesActive.AxisJ6;
  _command.RobotAxesActive.7    := _parCmd.RobotAxesActive.Bit07;
  _command.ExternalAxesActive.0 := _parCmd.ExternalAxesActive.Bit00;
  _command.ExternalAxesActive.1 := _parCmd.ExternalAxesActive.AxisE1;
  _command.ExternalAxesActive.2 := _parCmd.ExternalAxesActive.AxisE2;
  _command.ExternalAxesActive.3 := _parCmd.ExternalAxesActive.AxisE3;
  _command.ExternalAxesActive.4 := _parCmd.ExternalAxesActive.AxisE4;
  _command.ExternalAxesActive.5 := _parCmd.ExternalAxesActive.AxisE5;
  _command.ExternalAxesActive.6 := _parCmd.ExternalAxesActive.AxisE6;
  _command.ExternalAxesActive.7 := _parCmd.ExternalAxesActive.Bit07;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.EmitterID[0]
  CreateCommandPayload.AddByte(_command.RobotAxesActive);
  // add command.EmitterID[1]
  CreateCommandPayload.AddByte(_command.ExternalAxesActive);
  
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the following parameter(s) :');
    
  // Create log entry for RobotAxesActive
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.RobotAxesActive = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.RobotAxesActive));
  
  // Create log entry for ExternalAxesActive
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ExternalAxesActive = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ExternalAxesActive));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_BrakeTestFB';

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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : Active             := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN 
             // reset busy flag          
             Busy := FALSE;
             // Update results
             OutCmd.RobotAxesStatus.Bit00     := _response.RobotAxesStatus.0;
             OutCmd.RobotAxesStatus.AxisJ1    := _response.RobotAxesStatus.1;
             OutCmd.RobotAxesStatus.AxisJ2    := _response.RobotAxesStatus.2;
             OutCmd.RobotAxesStatus.AxisJ3    := _response.RobotAxesStatus.3;
             OutCmd.RobotAxesStatus.AxisJ4    := _response.RobotAxesStatus.4;
             OutCmd.RobotAxesStatus.AxisJ5    := _response.RobotAxesStatus.5;
             OutCmd.RobotAxesStatus.AxisJ6    := _response.RobotAxesStatus.6;
             OutCmd.RobotAxesStatus.Bit07     := _response.RobotAxesStatus.7;
             
             OutCmd.RobotAxesWarning.Bit00     := _response.RobotAxesWarning.0;
             OutCmd.RobotAxesWarning.AxisJ1    := _response.RobotAxesWarning.1;
             OutCmd.RobotAxesWarning.AxisJ2    := _response.RobotAxesWarning.2;
             OutCmd.RobotAxesWarning.AxisJ3    := _response.RobotAxesWarning.3;
             OutCmd.RobotAxesWarning.AxisJ4    := _response.RobotAxesWarning.4;
             OutCmd.RobotAxesWarning.AxisJ5    := _response.RobotAxesWarning.5;
             OutCmd.RobotAxesWarning.AxisJ6    := _response.RobotAxesWarning.6;
             OutCmd.RobotAxesWarning.Bit07     := _response.RobotAxesWarning.7;
  
             OutCmd.ExternalAxesStatus.Bit00   := _response.ExternalAxesStatus.0;
             OutCmd.ExternalAxesStatus.AxisE1  := _response.ExternalAxesStatus.1;
             OutCmd.ExternalAxesStatus.AxisE2  := _response.ExternalAxesStatus.2;
             OutCmd.ExternalAxesStatus.AxisE3  := _response.ExternalAxesStatus.3;
             OutCmd.ExternalAxesStatus.AxisE4  := _response.ExternalAxesStatus.4;
             OutCmd.ExternalAxesStatus.AxisE5  := _response.ExternalAxesStatus.5;
             OutCmd.ExternalAxesStatus.AxisE6  := _response.ExternalAxesStatus.6;
             OutCmd.ExternalAxesStatus.Bit07   := _response.ExternalAxesStatus.7;
  
             OutCmd.ExternalAxesWarning.Bit00  := _response.ExternalAxesWarning.0;
             OutCmd.ExternalAxesWarning.AxisE1 := _response.ExternalAxesWarning.1;
             OutCmd.ExternalAxesWarning.AxisE2 := _response.ExternalAxesWarning.2;
             OutCmd.ExternalAxesWarning.AxisE3 := _response.ExternalAxesWarning.3;
             OutCmd.ExternalAxesWarning.AxisE4 := _response.ExternalAxesWarning.4;
             OutCmd.ExternalAxesWarning.AxisE5 := _response.ExternalAxesWarning.5;
             OutCmd.ExternalAxesWarning.AxisE6 := _response.ExternalAxesWarning.6;
             OutCmd.ExternalAxesWarning.Bit07  := _response.ExternalAxesWarning.7;
             
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
// Table 6-741: Received CMD payload (RC to PLC) of "BrakeTest"
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
// Byte 04 : BYTE  - RobotAxesStatus
// Byte 05 : BYTE  - ExternalAxesStatus
// Byte 06 : BYTE  - RobotAxesWarning
// Byte 07 : BYTE  - ExternalAxesWarning
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get RobotAxesStatus
  _response.RobotAxesStatus     := ResponseData.GetByte();
  // Get ExternalAxesStatus
  _response.ExternalAxesStatus  := ResponseData.GetByte();
  // Get RobotAxesWarning
  _response.RobotAxesWarning    := ResponseData.GetByte();
  // Get ExternalAxesWarning
  _response.ExternalAxesWarning := ResponseData.GetByte();
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
                          
  // Create log entry for RobotAxesStatus
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RobotAxesStatus = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.RobotAxesStatus));
  
  // Create log entry for ExternalAxesStatus
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ExternalAxesStatus = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.ExternalAxesStatus));
  
  // Create log entry for RobotAxesWarning
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RobotAxesWarning = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.RobotAxesWarning));
  
  // Create log entry for ExternalAxesWarning
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ExternalAxesWarning = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.ExternalAxesWarning));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Active             := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

