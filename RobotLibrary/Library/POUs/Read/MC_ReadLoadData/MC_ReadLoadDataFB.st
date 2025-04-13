/// Read content of selected payload number
FUNCTION_BLOCK MC_ReadLoadDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadLoadDataFB                                       
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
  ParCmd          : ReadLoadDataParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadLoadDataOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadLoadDataParCmd;
  /// command data to send
 _command         : ReadLoadDataSendData;
  /// response data received
 _response        : ReadLoadDataRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ReadLoadData;
  
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
  
  // Check ParCmd.LoadNo valid ? 
  IF (( ParCmd.LoadNo <  -1 ) OR  
      ( ParCmd.LoadNo > 254 ))
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
                            MessageText := 'Invalid Parameter ParCmd.LoadNo = {1}',
                            Para1       :=  INT_TO_STRING(ParCmd.LoadNo));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-171: Sent CMD payload (PLC to RC) of "ReadLoadData"
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
// Byte 04 : USINT  LoadNo;
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadLoadData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  _command.LoadNo   := INT_TO_USINT(_parCmd.LoadNo);
  
  IF (_parCmd.LoadNo = -1)
  THEN
    _command.LoadNo := 255; // -1 is mapped to 255, see specification
  END_IF
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
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
  CreateLogMessage      ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the following parameter(s) :');
    
  // Create log entry for LoadNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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

  MyType := 'MC_ReadLoadDataFB';
  
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
             CmdMessageState.BUFFERED : CommandBuffered := TRUE;
             CmdMessageState.DONE     : Done            := TRUE;
             CmdMessageState.ERROR    : Error           := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.LoadNoReturn := _response.LoadNoReturn;
             OutCmd.LoadData     := _response.LoadData;
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
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// TTable 6-172: Received CMD payload (RC to PLC) of "ReadLoadData"
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
// Byte 04 : DATE    - LoadData.Date LW HB;
// Byte 05 :         - LoadData.Date LW LB;
// Byte 06 : TOD     - LoadData.Time LW HB;
// Byte 07 :         - LoadData.Time LW LB;
// Byte 08 :         - LoadData.Time LW HB;
// Byte 09 :         - LoadData.Time LW LB;
// Byte 10 : REAL    - LoadData.X HW HB;
// Byte 11 :         - LoadData.X HW LB;
// Byte 12 :         - LoadData.X LW HB;
// Byte 13 :         - LoadData.X LW LB;
// Byte 14 : REAL    - LoadData.Y HW HB;
// Byte 15 :         - LoadData.Y HW LB;
// Byte 16 :         - LoadData.Y LW HB;
// Byte 17 :         - LoadData.Y LW LB;
// Byte 18 : REAL    - LoadData.Z HW HB;
// Byte 19 :         - LoadData.Z HW LB;
// Byte 20 :         - LoadData.Z LW HB;
// Byte 21 :         - LoadData.Z LW LB;
// Byte 22 : REAL    - LoadData.RX HW HB;
// Byte 23 :         - LoadData.RX HW LB;
// Byte 24 :         - LoadData.RX LW HB;
// Byte 25 :         - LoadData.RX LW LB;
// Byte 26 : REAL    - LoadData.RY HW HB;
// Byte 27 :         - LoadData.RY HW LB;
// Byte 28 :         - LoadData.RY LW HB;
// Byte 29 :         - LoadData.RY LW LB;
// Byte 30 : REAL    - LoadData.RZ HW HB;
// Byte 31 :         - LoadData.RZ HW LB;
// Byte 32 :         - LoadData.RZ LW HB;
// Byte 33 :         - LoadData.RZ LW LB;
// Byte 34 : REAL    - LoadData.Mass HW HB;
// Byte 35 :         - LoadData.Mass HW LB;
// Byte 36 :         - LoadData.Mass LW HB;
// Byte 37 :         - LoadData.Mass LW LB;
// Byte 38 : REAL    - LoadData.IX HW HB;
// Byte 39 :         - LoadData.IX HW LB;
// Byte 40 :         - LoadData.IX LW HB;
// Byte 41 :         - LoadData.IX LW LB;
// Byte 42 : REAL    - LoadData.IY HW HB;
// Byte 43 :         - LoadData.IY HW LB;
// Byte 44 :         - LoadData.IY LW HB;
// Byte 45 :         - LoadData.IY LW LB;
// Byte 46 : REAL    - LoadData.IZ HW HB;
// Byte 47 :         - LoadData.IZ HW LB;
// Byte 48 :         - LoadData.IZ LW HB;
// Byte 49 :         - LoadData.IZ LW LB;
// Byte 50 : USINT   - LoadNo;
// Byte 51 : BOOL    - DataChanged;
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.LoadData.Timestamp.IEC_DATE
  _response.LoadData.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.LoadData.Timestamp.IEC_TIME
  _response.LoadData.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.LoadData.X
  _response.LoadData.X := ResponseData.GetReal();
  // Get Response.LoadData.Y
  _response.LoadData.Y := ResponseData.GetReal();
  // Get Response.LoadData.Z
  _response.LoadData.Z := ResponseData.GetReal();
  // Get Response.LoadData.Rx
  _response.LoadData.Rx := ResponseData.GetReal();
  // Get Response.LoadData.Ry
  _response.LoadData.Ry := ResponseData.GetReal();
  // Get Response.LoadData.Rz
  _response.LoadData.Rz := ResponseData.GetReal();
  // Get Response.LoadData.Mass
  _response.LoadData.Mass := ResponseData.GetReal();
  // Get Response.LoadData.Ix
  _response.LoadData.Ix := ResponseData.GetReal();
  // Get Response.LoadData.Iy
  _response.LoadData.Iy := ResponseData.GetReal();
  // Get Response.LoadData.Iz
  _response.LoadData.Iz := ResponseData.GetReal();
  // Get Response.LoadNoReturn
  _response.LoadNoReturn := ResponseData.GetUsint();
  // Get Response.DataChanged
  _response.DataChanged := ResponseData.GetBool();
  
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
  
  // Create log entry for LoadData.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_response.LoadData.Timestamp.IEC_DATE));
  
  // Create log entry for LoadData.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_response.LoadData.Timestamp.IEC_TIME));
                          
  // Create log entry for LoadData.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.X));
  
  // Create log entry for LoadData.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Y));
  
  // Create log entry for LoadData.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Z));
  
  // Create log entry for LoadData.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Rx));
  
  // Create log entry for LoadData.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Ry));
  
  // Create log entry for LoadData.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Rz));
  
  // Create log entry for LoadData.Mass
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Mass = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Mass));
  
  // Create log entry for LoadData.Ix
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Ix = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Ix));
  
  // Create log entry for LoadData.Iz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Iz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Iz));
  
  // Create log entry for LoadData.Iy
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadData.Iy = {1}',
                          Para1       :=  REAL_TO_STRING(_response.LoadData.Iy));
  
    // Create log entry for LoadNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LoadNoReturn = {1}',
                          Para1       :=  USINT_TO_STRING(_response.LoadNoReturn));
  
    // Create log entry for DataChanged
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataChanged = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataChanged));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

