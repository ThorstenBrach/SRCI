/// Read real values on RC
FUNCTION_BLOCK MC_ReadRealsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRealsFB                                       
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
  ParCmd             : ReadRealsParCmd;
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • Values
  Valid              : BOOL; 
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : ReadRealsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadRealsParCmd;
  /// command data to send
 _command            : ReadRealsSendData;
  /// response data received
 _response           : ReadRealsRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.ReadReals;
  
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
// Table 6-502: Sent CMD payload (PLC to RC) of "ReadReals"
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
// Byte 10 : USINT Index[0];
// Byte 11 : USINT Index[1];
// Byte 12 : USINT Index[2];
// Byte 13 : USINT Index[3];
// Byte 14 : USINT Index[4];
// Byte 14 : USINT Index[5];
// Byte 14 : USINT Index[6];
// --------------------------

  // set command parameter 
  _command.CmdTyp       :=  CmdType.ReadReals;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.EmitterID[0] := 0;
  _command.EmitterID[1] := 0;
  _command.EmitterID[2] := 0;
  _command.EmitterID[3] := 0;
  _command.Reserve      := 0;
  _command.ListenerID   := _parCmd.ListenerID;
  _command.Index        := _parCmd.Index;
  
  
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
  // add command.Index[0]
  CreateCommandPayload.AddUsint(_command.Index[0]);
  // add command.Index[1]
  CreateCommandPayload.AddUsint(_command.Index[1]);
  // add command.Index[2]
  CreateCommandPayload.AddUsint(_command.Index[2]);
  // add command.Index[3]
  CreateCommandPayload.AddUsint(_command.Index[3]);
  // add command.Index[4]
  CreateCommandPayload.AddUsint(_command.Index[4]);
  // add command.Index[5]
  CreateCommandPayload.AddUsint(_command.Index[5]);
  // add command.Index[6]
  CreateCommandPayload.AddUsint(_command.Index[6]);
  
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
  
  // Create log entry for Index[x]
  FOR _idx := 0 TO 6
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Index[{2}] = {1}',
                            Para1       :=  USINT_TO_STRING(_command.Index[_idx]),
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

  MyType := 'MC_ReadRealsFB';
  
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
             OutCmd.Values            := _response.Values;
             
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
// Table Table 6-503: Received CMD payload (RC to PLC) of "ReadReals"
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
// Byte 08 : REAL    - Values[0] HW HB;
// Byte 09 :         - Values[0] HW LB;
// Byte 10 :         - Values[0] LW HB;
// Byte 11 :         - Values[0] LW LB;
// Byte 12 : REAL    - Values[1] HW HB;
// Byte 13 :         - Values[1] HW LB;
// Byte 14 :         - Values[1] LW HB;
// Byte 15 :         - Values[1] LW LB;
// Byte 16 : REAL    - Values[2] HW HB;
// Byte 17 :         - Values[2] HW LB;
// Byte 18 :         - Values[2] LW HB;
// Byte 19 :         - Values[2] LW LB;
// Byte 20 : REAL    - Values[3] HW HB;
// Byte 21 :         - Values[3] HW LB;
// Byte 22 :         - Values[3] LW HB;
// Byte 23 :         - Values[3] LW LB;
// Byte 24 : REAL    - Values[4] HW HB;
// Byte 25 :         - Values[4] HW LB;
// Byte 26 :         - Values[4] LW HB;
// Byte 27 :         - Values[4] LW LB;
// Byte 28 : REAL    - Values[5] HW HB;
// Byte 29 :         - Values[5] HW LB;
// Byte 30 :         - Values[5] LW HB;
// Byte 31 :         - Values[5] LW LB;
// Byte 32 : REAL    - Values[6] HW HB;
// Byte 33 :         - Values[6] HW LB;
// Byte 34 :         - Values[6] LW HB;
// Byte 35 :         - Values[6] LW LB;
// --------------------------

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
  // Get Response.Values[0]
  _response.Values[0] := ResponseData.GetReal();
  // Get Response.Values[1]
  _response.Values[1] := ResponseData.GetReal();
  // Get Response.Values[2]
  _response.Values[2] := ResponseData.GetReal();
  // Get Response.Values[3]
  _response.Values[3] := ResponseData.GetReal();
  // Get Response.Values[4]
  _response.Values[4] := ResponseData.GetReal();
  // Get Response.Values[5]
  _response.Values[5] := ResponseData.GetReal();
  // Get Response.Values[6]
  _response.Values[6] := ResponseData.GetReal();

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

END_METHOD

