/// Write reference values of robot dynamics for path movement
FUNCTION_BLOCK MC_WriteRobotReferenceDynamicsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteRobotReferenceDynamicsFB                                       
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
  /// internal copy of command parameter 
  ParCmd             : WriteRobotReferenceDynamicsParCmd; 
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : WriteRobotReferenceDynamicsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteRobotReferenceDynamicsParCmd;
  /// command data to send
 _command            : WriteRobotReferenceDynamicsSendData;
  /// response data received
 _response           : WriteRobotReferenceDynamicsRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.WriteRobotReferenceDynamics;
  
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
  
  
  // Check ParCmd.DynamicValues.VelocityReference ? 
  IF ( SysDepIsValidReal(ParCmd.DynamicValues.VelocityReference) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DynamicValues.VelocityReference = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DynamicValues.VelocityReference));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DynamicValues.AccelerationReference ? 
  IF ( SysDepIsValidReal(ParCmd.DynamicValues.AccelerationReference) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_ACCELERATION_INVALID;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DynamicValues.AccelerationReference = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DynamicValues.AccelerationReference));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DynamicValues.DecelerationReference ? 
  IF ( SysDepIsValidReal(ParCmd.DynamicValues.DecelerationReference) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_DECELERATION_INVALID;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DynamicValues.DecelerationReference = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DynamicValues.DecelerationReference));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DynamicValues.JerkReference ? 
  IF ( SysDepIsValidReal(ParCmd.DynamicValues.JerkReference) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_JERK_INVALID;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DynamicValues.JerkReference = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DynamicValues.JerkReference));
  
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-139: Sent CMD payload (PLC to RC) of "WriteRobotReferenceDynamics"
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
// Byte 04 : DATE Date
// Byte 05 : 
// Byte 06 : TIME_OF_DAY Time
// Byte 07 : 
// Byte 08 : 
// Byte 09 : REAL VelocityReference
// Byte 10 : 
// Byte 11 : 
// Byte 12 : REAL AccelerationReference
// Byte 13 : 
// Byte 14 : 
// Byte 15 : REAL DecelerationReference
// Byte 16 : 
// Byte 17 : 
// Byte 18 : REAL JerkReference
// Byte 19 : 
// Byte 20 : 
// Byte 21 : 
// Byte 22 : REAL 
// Byte 23 : 
// Byte 24 : 
// Byte 25 : 
// --------------------------

  // set command parameter 
  _command.CmdTyp                :=  CmdType.WriteRobotReferenceDynamics;
  _command.ExecMode              :=  ExecMode;
  _command.ParSeq                := _command.ParSeq;
  _command.Priority              :=  Priority;
  
  _command.DynamicValues         := _parCmd.DynamicValues; {warning 'ToDo: Check if this is a mistake in the SRCI specification ? '}
  
  (*
   _command.Timestamp             := _parCmd.DynamicValues.Timestamp;
   _command.VelocityReference     := REAL_TO_PERCENT_UINT(_parCmd.DynamicValues.VelocityReference     , IsOptional := FALSE);
   _command.AccelerationReference := REAL_TO_PERCENT_UINT(_parCmd.DynamicValues.AccelerationReference , IsOptional := FALSE);
   _command.JerkReference         := REAL_TO_PERCENT_UINT(_parCmd.DynamicValues.JerkReference         , IsOptional := TRUE );
   _command.DecelerationReference := REAL_TO_PERCENT_UINT(_parCmd.DynamicValues.DecelerationReference , IsOptional := TRUE );
  *)
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.DynamicValues.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.DynamicValues.Timestamp.IEC_DATE);
  // add command.DynamicValues.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.DynamicValues.Timestamp.IEC_TIME);
  // add command.DynamicValues.VelocityReference
  CreateCommandPayload.AddReal(_command.DynamicValues.VelocityReference);
  // add command.DynamicValues.AccelerationReference
  CreateCommandPayload.AddReal(_command.DynamicValues.AccelerationReference);
  // add command.DynamicValues.DecelerationRate
  CreateCommandPayload.AddReal(_command.DynamicValues.DecelerationReference);
  // add command.DynamicValues.JerkRate
  CreateCommandPayload.AddReal(_command.DynamicValues.JerkReference);
  
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
    
  // Create log entry for DynamicValues.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DynamicValues.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_command.DynamicValues.Timestamp.IEC_DATE));
  
  // Create log entry for DynamicValues.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DynamicValues.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_command.DynamicValues.Timestamp.IEC_TIME));
  
  // Create log entry for DynamicValues.VelocityReference
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command..DynamicValues.VelocityReference = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DynamicValues.VelocityReference));
  
  // Create log entry for DynamicValues.AccelerationReference
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DynamicValues.AccelerationReference = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DynamicValues.AccelerationReference));
  
  // Create log entry for DynamicValues.DecelerationReference
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DynamicValues.DecelerationReference = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DynamicValues.DecelerationReference));
  
  // Create log entry for DynamicValues.JerkReference
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DynamicValues.JerkReference = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DynamicValues.JerkReference));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteRobotReferenceDynamicsFB';
  
  ExecMode := ExecutionMode.PARALLEL;

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
             OutCmd.ReferenceDynamicValues.VelocityReference     := _response.ReferenceDynamicValues.VelocityReference; 
             OutCmd.ReferenceDynamicValues.AccelerationReference := _response.ReferenceDynamicValues.AccelerationReference;
             OutCmd.ReferenceDynamicValues.DecelerationReference := _response.ReferenceDynamicValues.DecelerationReference;
             OutCmd.ReferenceDynamicValues.JerkReference         := _response.ReferenceDynamicValues.JerkReference;
  
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
// Table 6-140: Received CMD payload (RC to PLC) of "WriteRobotReferenceDynamics"
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
// Byte 04 : REAL VelocityReference
// Byte 05 : 
// Byte 06 : 
// Byte 07 : 
// Byte 08 : REAL AccelerationReference
// Byte 09 : 
// Byte 10 : 
// Byte 11 : 
// Byte 12 : REAL DecelerationReference
// Byte 13 : 
// Byte 14 : 
// Byte 15 : 
// Byte 16 : REAL JerkReference
// Byte 17 : 
// Byte 18 : 
// Byte 19 : 
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.ReferenceDynamicValues.VelocityReference
  _response.ReferenceDynamicValues.VelocityReference := ResponseData.GetReal();
  // Get Response.ReferenceDynamicValues.AccelerationReference
  _response.ReferenceDynamicValues.AccelerationReference := ResponseData.GetReal();
  // Get Response.ReferenceDynamicValues.DecelerationReference
  _response.ReferenceDynamicValues.DecelerationReference := ResponseData.GetReal();
  // Get ReferenceDynamicValues.JerkReference
  _response.ReferenceDynamicValues.JerkReference := ResponseData.GetReal();
  
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
  
  // Create log entry for ReferenceDynamicValues.VelocityReference
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ReferenceDynamicValues.VelocityReference = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ReferenceDynamicValues.VelocityReference));
  
  // Create log entry for ReferenceDynamicValues.AccelerationReference
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ReferenceDynamicValues.AccelerationReference = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ReferenceDynamicValues.AccelerationReference));
                          
  // Create log entry for ReferenceDynamicValues.DecelerationReference
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ReferenceDynamicValues.DecelerationReference = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ReferenceDynamicValues.DecelerationReference));
  
  // Create log entry for ReferenceDynamicValues.JerkReference
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ReferenceDynamicValues.JerkReference = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ReferenceDynamicValues.JerkReference));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

