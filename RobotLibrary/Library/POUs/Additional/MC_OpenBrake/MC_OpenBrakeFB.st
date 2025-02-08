/// Release robot arm’s brakes.
FUNCTION_BLOCK MC_OpenBrakeFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      OpenBrakeFB                                       
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
  ParCmd             : OpenBrakeParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// Command output 
  OutCmd            : OpenBrakeOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : OpenBrakeParCmd;
  /// command data to send
 _command            : OpenBrakeSendData;
  /// response data received
 _response           : OpenBrakeRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.OpenBrake;
  
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
  IF (SIZEOF(ParCmd) = 0) 
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-681: Sent CMD payload (PLC to RC) of "OpenBrake"
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
// Byte 04 : BYTE  - RobotAxesBrakeRelease
// Byte 05 : BYTE  - ExternalAxesBrakeRelease
// --------------------------

  // set command parameter 
  _command.CmdTyp                     :=  CmdType.OpenBrake;
  _command.ExecMode                   :=  ExecMode;
  _command.ParSeq                     := _command.ParSeq;
  _command.Priority                   :=  Priority;
  _command.RobotAxesBrakeRelease.0    := _parCmd.RobotAxesBrakeRelease   .Bit00;
  _command.RobotAxesBrakeRelease.1    := _parCmd.RobotAxesBrakeRelease   .AxisJ1;
  _command.RobotAxesBrakeRelease.2    := _parCmd.RobotAxesBrakeRelease   .AxisJ2;
  _command.RobotAxesBrakeRelease.3    := _parCmd.RobotAxesBrakeRelease   .AxisJ3;
  _command.RobotAxesBrakeRelease.4    := _parCmd.RobotAxesBrakeRelease   .AxisJ4;
  _command.RobotAxesBrakeRelease.5    := _parCmd.RobotAxesBrakeRelease   .AxisJ5;
  _command.RobotAxesBrakeRelease.6    := _parCmd.RobotAxesBrakeRelease   .AxisJ6;
  _command.RobotAxesBrakeRelease.7    := _parCmd.RobotAxesBrakeRelease   .Bit07;
  _command.ExternalAxesBrakeRelease.0 := _parCmd.ExternalAxesBrakeRelease.Bit00;
  _command.ExternalAxesBrakeRelease.1 := _parCmd.ExternalAxesBrakeRelease.AxisE1;
  _command.ExternalAxesBrakeRelease.2 := _parCmd.ExternalAxesBrakeRelease.AxisE2;
  _command.ExternalAxesBrakeRelease.3 := _parCmd.ExternalAxesBrakeRelease.AxisE3;
  _command.ExternalAxesBrakeRelease.4 := _parCmd.ExternalAxesBrakeRelease.AxisE4;
  _command.ExternalAxesBrakeRelease.5 := _parCmd.ExternalAxesBrakeRelease.AxisE5;
  _command.ExternalAxesBrakeRelease.6 := _parCmd.ExternalAxesBrakeRelease.AxisE6;
  _command.ExternalAxesBrakeRelease.7 := _parCmd.ExternalAxesBrakeRelease.Bit07;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.EmitterID[0]
  CreateCommandPayload.AddByte(_command.RobotAxesBrakeRelease);
  // add command.EmitterID[1]
  CreateCommandPayload.AddByte(_command.ExternalAxesBrakeRelease);
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the following parameter(s) :');
    
  // Create log entry for RobotAxesBrakeRelease
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.RobotAxesBrakeRelease = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.RobotAxesBrakeRelease));
                          
  // Create log entry for ExternalAxesBrakeRelease
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ExternalAxesBrakeRelease = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ExternalAxesBrakeRelease));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_OpenBrakeFB';
  
  ExecMode := ExecutionMode.PARALLEL;

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _execute_R.Q )  
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
             CmdMessageState.DONE        : Done               := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
  
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.Enabled                          := _response.Enabled.0;
             OutCmd.RobotAxesBrakeReleased.Bit00     := _response.RobotAxesBrakeReleased.0;
             OutCmd.RobotAxesBrakeReleased.AxisJ1    := _response.RobotAxesBrakeReleased.1;
             OutCmd.RobotAxesBrakeReleased.AxisJ2    := _response.RobotAxesBrakeReleased.2;
             OutCmd.RobotAxesBrakeReleased.AxisJ3    := _response.RobotAxesBrakeReleased.3;
             OutCmd.RobotAxesBrakeReleased.AxisJ4    := _response.RobotAxesBrakeReleased.4;
             OutCmd.RobotAxesBrakeReleased.AxisJ5    := _response.RobotAxesBrakeReleased.5;
             OutCmd.RobotAxesBrakeReleased.AxisJ6    := _response.RobotAxesBrakeReleased.6;
             OutCmd.RobotAxesBrakeReleased.Bit07     := _response.RobotAxesBrakeReleased.7;
             OutCmd.ExternalAxesBrakeReleased.Bit00  := _response.ExternalAxesBrakeReleased.0;
             OutCmd.ExternalAxesBrakeReleased.AxisE1 := _response.ExternalAxesBrakeReleased.1;
             OutCmd.ExternalAxesBrakeReleased.AxisE2 := _response.ExternalAxesBrakeReleased.2;
             OutCmd.ExternalAxesBrakeReleased.AxisE3 := _response.ExternalAxesBrakeReleased.3;
             OutCmd.ExternalAxesBrakeReleased.AxisE4 := _response.ExternalAxesBrakeReleased.4;
             OutCmd.ExternalAxesBrakeReleased.AxisE5 := _response.ExternalAxesBrakeReleased.5;
             OutCmd.ExternalAxesBrakeReleased.AxisE6 := _response.ExternalAxesBrakeReleased.6;
             OutCmd.ExternalAxesBrakeReleased.Bit07  := _response.ExternalAxesBrakeReleased.7;
  
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
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
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
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-682: Received CMD payload (RC to PLC) of "OpenBrake"
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
// Byte 04 : BOOL  - Enabled
// Byte 05 : BYTE  - RobotAxesBrakeReleased
// Byte 06 : BYTE  - ExternalAxesBrakeReleased
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get RobotAxesStatus
  _response.RobotAxesBrakeReleased     := ResponseData.GetByte();
  // Get ExternalAxesStatus
  _response.ExternalAxesBrakeReleased  := ResponseData.GetByte();
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
                          
  
  // Create log entry for RobotAxesBrakeReleased
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RobotAxesBrakeReleased = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.RobotAxesBrakeReleased));
  
  // Create log entry for ExternalAxesBrakeReleased
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ExternalAxesBrakeReleased = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.ExternalAxesBrakeReleased));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

