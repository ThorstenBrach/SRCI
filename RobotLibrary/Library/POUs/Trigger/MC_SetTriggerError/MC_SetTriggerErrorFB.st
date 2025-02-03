/// Trigger "Actions" based on incoming error event
FUNCTION_BLOCK MC_SetTriggerErrorFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerErrorFB                                       
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
  ParCmd           : SetTriggerErrorParCmd;
  /// Processing mode
  ProcessingMode   : ProcessingMode;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered  : BOOL;
  /// TRUE, when the monitoring of the input parameter values is active.
  MonitoringActive : BOOL;
  /// command results
  OutCmd           : SetTriggerErrorOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd           : SetTriggerErrorParCmd;
  /// command data to send
 _command          : SetTriggerErrorSendData;
  /// response data received
 _response         : SetTriggerErrorRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.SetTriggerError;
  
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
  CheckParameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCmd), pData2 := ADR(_parCmd), DataLen := SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
  IF ( CheckParameterChanged )
  THEN  
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-598: Sent CMD payload (PLC to RC) of "SetTriggerError"
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
// Byte 09 : BYTE  Reserved;
// Byte 10 : SINT  Mode;
// Byte 11 : BOOL  IncludeParameterValidation;
// Byte 12 : DWORD MessageCode[0];
// Byte 13 :       MessageCode[0];
// Byte 14 :       MessageCode[0];
// Byte 15 :       MessageCode[0];
// Byte 16 : DWORD MessageCode[1];
// Byte 17 :       MessageCode[1];
// Byte 18 :       MessageCode[1];
// Byte 19 :       MessageCode[1];
// Byte 20 : DWORD MessageCode[2];
// Byte 21 :       MessageCode[2];
// Byte 22 :       MessageCode[2];
// Byte 23 :       MessageCode[2];
// Byte 24 : DWORD MessageCode[3];
// Byte 25 :       MessageCode[3];
// Byte 26 :       MessageCode[3];
// Byte 27 :       MessageCode[3];
// Byte 28 : DWORD MessageCode[4];
// Byte 29 :       MessageCode[4];
// Byte 30 :       MessageCode[4];
// Byte 31 :       MessageCode[4];
// Byte 32 : DWORD MessageCode[5];
// Byte 33 :       MessageCode[5];
// Byte 34 :       MessageCode[5];
// Byte 35 :       MessageCode[5];
// Byte 36 : DWORD MessageCode[6];
// Byte 37 :       MessageCode[6];
// Byte 38 :       MessageCode[6];
// Byte 39 :       MessageCode[6];
// Byte 40 : DWORD MessageCode[7];
// Byte 41 :       MessageCode[7];
// Byte 42 :       MessageCode[7];
// Byte 43 :       MessageCode[7];
// Byte 44 : DWORD MessageCode[8];
// Byte 45 :       MessageCode[8];
// Byte 46 :       MessageCode[8];
// Byte 47 :       MessageCode[8];
// Byte 48 : DWORD MessageCode[9];
// Byte 49 :       MessageCode[9];
// Byte 50 :       MessageCode[9];
// Byte 51 :       MessageCode[9];
// Byte 52 : DWORD MessageCode[10];
// Byte 53 :       MessageCode[10];
// Byte 54 :       MessageCode[10];
// Byte 55 :       MessageCode[10];
// Byte 56 : DWORD MessageCode[11];
// Byte 57 :       MessageCode[11];
// Byte 58 :       MessageCode[11];
// Byte 59 :       MessageCode[11];
// Byte 60 : DWORD MessageCode[12];
// Byte 61 :       MessageCode[12];
// Byte 62 :       MessageCode[12];
// Byte 63 :       MessageCode[12];
// Byte 64 : DWORD MessageCode[13];
// Byte 65 :       MessageCode[13];
// Byte 66 :       MessageCode[13];
// Byte 67 :       MessageCode[13];
// Byte 68 : DWORD MessageCode[14];
// Byte 69 :       MessageCode[14];
// Byte 70 :       MessageCode[14];
// Byte 71 :       MessageCode[14];
// Byte 72 : DWORD MessageCode[15];
// Byte 73 :       MessageCode[15];
// Byte 74 :       MessageCode[15];
// Byte 75 :       MessageCode[15];
 VAR
   /// internal index for loops
  _idx : DINT;
 END_VAR

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.SetTriggerError;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  
  _command.EmitterID[0]              := _parCmd.EmitterID;
  _command.EmitterID[1]              := 0;
  _command.EmitterID[2]              := 0;
  _command.EmitterID[3]              := 0;
  _command.ListenerID                := _parCmd.ListenerID;
  _command.Reserve                   := 0;
  _command.Mode                      := _parCmd.Mode;
  _command.IncludeParameterValidation:= _parCmd.IncludeParameterValidation;
  _command.MessageCodes              := _parCmd.MessageCodes;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.EmitterID[0]
  CreateCommandPayload.AddSint(_command.EmitterID[0]);
  // add command.EmitterID[1]
  CreateCommandPayload.AddSint(_command.EmitterID[1]);
  // add command.EmitterID[2]
  CreateCommandPayload.AddSint(_command.EmitterID[2]);
  // add command.EmitterID[3]
  CreateCommandPayload.AddSint(_command.EmitterID[3]);
  // add command.ListenerID
  CreateCommandPayload.AddSint(_command.ListenerID);
  // add command.Reserve
  CreateCommandPayload.AddSint(_command.Reserve);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.IncludeParameterValidation
  CreateCommandPayload.AddBool(_command.IncludeParameterValidation);
  
  FOR _idx := 0 TO RobotLibraryParameter.MESSAGE_CODES_MAX
  DO
    // add command.MessageCodes[_idx]
    CreateCommandPayload.AddDword(_command.MessageCodes[_idx]);
  END_FOR
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR 
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'CreateCommandPayload with the following parameter(s) :');
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
                          
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Reserve));
  
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  ERROR_TRIGGER_MODE_TO_STRING(_command.Mode));
  
  // Create log entry for IncludeParameterValidation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.IncludeParameterValidation = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.IncludeParameterValidation));
  
  // add command.MessageCodes[_idx]
  FOR _idx := 0 TO RobotLibraryParameter.MESSAGE_CODES_MAX
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.MessageCodes[{2}] = {1}',
                            Para1       :=  DWORD_TO_STRING(_command.MessageCodes[_idx]),
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

  MyType := 'MC_SetTriggerErrorFB';
  
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
             OutCmd.FollowID          := _response.OriginID;
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.InvocationCounter := _response.InvocationCounter;
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
// 6-599: Received CMD payload (RC to PLC) of "SetTriggerError" 
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
// Byte 04 : USINT   - InvocationCounter
// Byte 05 : SINT    - Reserve
// Byte 06 : INT     - OriginID LW HB
// Byte 07 :         - OriginID LW LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done             := FALSE;
  Busy             := FALSE;
  CommandBuffered  := FALSE;
  MonitoringActive := FALSE;

END_METHOD

