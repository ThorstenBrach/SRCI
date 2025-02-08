/// Change configuration of selected payload number
FUNCTION_BLOCK MC_WriteLoadDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteLoadDataFB                                       
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
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// Processing Mode
  ProcessingMode     : ProcessingMode;
  /// command parameter 
  ParCmd             : WriteLoadDataParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : WriteLoadDataOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteLoadDataParCmd;
  /// command data to send
 _command            : WriteLoadDataSendData;
  /// response data received
 _response           : WriteLoadDataRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.WriteLoadData;
  
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-132: Sent CMD payload (PLC to RC) of "WriteLoadData"
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
// Byte 04 : DATE LoadData.Date
// Byte 05 : 
// Byte 06 : TIME_OF_DAY LoadData.Time
// Byte 07 : 
// Byte 08 : 
// Byte 09 : REAL LoadData.X
// Byte 10 : 
// Byte 11 : 
// Byte 12 : 
// Byte 13 : REAL LoadData.Y
// Byte 14 : 
// Byte 15 : 
// Byte 16 : 
// Byte 17 : REAL LoadData.Z
// Byte 18 : 
// Byte 19 : 
// Byte 20 : 
// Byte 21 : REAL LoadData.RX
// Byte 22 : 
// Byte 23 : 
// Byte 24 : 
// Byte 25 : REAL LoadData.RY
// Byte 26 : 
// Byte 27 : 
// Byte 28 : 
// Byte 29 : REAL LoadData.RZ
// Byte 30 : 
// Byte 31 : 
// Byte 32 : 
// Byte 33 : REAL LoadData.Mass
// Byte 34 : 
// Byte 35 : 
// Byte 36 : 
// Byte 37 : REAL LoadData.IX
// Byte 38 : 
// Byte 39 : 
// Byte 40 : 
// Byte 41 : REAL LoadData.IY
// Byte 42 : 
// Byte 43 : 
// Byte 44 : 
// Byte 45 : REAL LoadData.IZ
// Byte 46 : 
// Byte 47 : 
// Byte 48 : 
// Byte 49 : USINT LoadNo
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.WriteLoadData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  _command.LoadData := _parCmd.LoadData;
  _command.LoadNo   := _parCmd.LoadNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.LoadData.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.LoadData.Timestamp.IEC_DATE);
  // add command.LoadData.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.LoadData.Timestamp.IEC_TIME);
  // add command.LoadData.X
  CreateCommandPayload.AddReal(_command.LoadData.X);
  // add command.LoadData.Y
  CreateCommandPayload.AddReal(_command.LoadData.Y);
  // add command.LoadData.Z
  CreateCommandPayload.AddReal(_command.LoadData.Z);
  // add command.LoadData.Rx
  CreateCommandPayload.AddReal(_command.LoadData.Rx);
  // add command.LoadData.Ry
  CreateCommandPayload.AddReal(_command.LoadData.Ry);
  // add command.LoadData.Rz
  CreateCommandPayload.AddReal(_command.LoadData.Rz);
  // add command.LoadData.Mass
  CreateCommandPayload.AddReal(_command.LoadData.Mass);
  // add command.LoadData.Ix
  CreateCommandPayload.AddReal(_command.LoadData.Ix);
  // add command.LoadData.Iy
  CreateCommandPayload.AddReal(_command.LoadData.Iy);
  // add command.LoadData.Iz
  CreateCommandPayload.AddReal(_command.LoadData.Iz);
  // add command.LoadNo
  CreateCommandPayload.AddUsint(_command.LoadNo);
  
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
    
  // Create log entry for LoadData.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_command.LoadData.Timestamp.IEC_DATE));
  
  // Create log entry for LoadData.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_command.LoadData.Timestamp.IEC_TIME));
  
  // Create log entry for LoadData.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.X));
  
  // Create log entry for LoadData.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Y));
  
  // Create log entry for LoadData.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Z));
  
  // Create log entry for LoadData.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Rx));
  
  // Create log entry for LoadData.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Ry));
  
  // Create log entry for LoadData.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Rz));
  
  // Create log entry for LoadData.Mass
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Mass = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Mass));
                          
  // Create log entry for LoadData.Ix
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Ix = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Ix));                        
                          
  // Create log entry for LoadData.Iy
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Iy = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Iy));                                                
                          
  // Create log entry for LoadData.Iz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadData.Iz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LoadData.Iz));
                          
  // Create log entry for LoadNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LoadNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.LoadNo));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteLoadDataFB';
  
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
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
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
// Table 6-133: Received CMD payload (RC to PLC) of "WriteLoadData"
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
// Byte 04 : USINT      - InvocationCounter
// Byte 05 : SINT       - Reserved
// Byte 06 : INT        - OriginID HW HB
// Byte 07 :            - OriginID HW LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
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
                          
  // Create log entry for no parameter 
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'This command has no parameter to parse...');

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

