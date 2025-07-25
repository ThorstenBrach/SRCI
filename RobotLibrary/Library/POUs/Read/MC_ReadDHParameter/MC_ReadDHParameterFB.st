/// Read DH (Denavit–Hartenberg) parameters of robot
FUNCTION_BLOCK MC_ReadDHParameterFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadDHParameterFB                                       
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
  ParCmd          : ReadDHParameterParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadDHParameterOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadDHParameterParCmd;
  /// command data to send
 _command         : ReadDHParameterSendData;
  /// response data received
 _response        : ReadDHParameterRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ReadDHParameter;
  
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
  
  // Check ParCmd.ModifiedConvention valid ? 
  IF (( ParCmd.ModifiedConvention <> FALSE ) AND 
      ( ParCmd.ModifiedConvention <> TRUE  ))
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
                            MessageText := 'Invalid Parameter ParCmd.ModifiedConvention = {1}',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ModifiedConvention));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-51: Sent CMD payload (PLC to RC) of "ReadDHParameter"
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
// Byte 04 : BOOL  - ModifiedConvention
// --------------------------

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.ReadDHParameter;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  _command.ModifiedConvention        := _parCmd.ModifiedConvention;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ModifiedConvention
    CreateCommandPayload.AddBool(_command.ModifiedConvention);
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

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
    
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ModifiedConvention
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ModifiedConvention = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.ModifiedConvention));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadDHParameterFB';
  
  ExecMode := ExecutionMode.PARALLEL;
  Priority := PriorityLevel.NORMAL;

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
             OutCmd.DHParameter := _response.DHParameter;
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
  _idx         : DINT;
  /// Parameter count
 _parameterCnt : DINT;
END_VAR// Table 6-52: Received CMD payload (RC to PLC) of "ReadDHParameter"
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
// Byte 04 : REAL    - DHParameterAlpha[0] HW HB;
// Byte 05 :         - DHParameterAlpha[0] HW LB;
// Byte 06 :         - DHParameterAlpha[0] LW HB;
// Byte 07 :         - DHParameterAlpha[0] LW LB;
// Byte 08 : REAL    - DHParameterAlpha[1] HW HB;
// Byte 09 :         - DHParameterAlpha[1] HW LB;
// Byte 10 :         - DHParameterAlpha[1] LW HB;
// Byte 11 :         - DHParameterAlpha[1] LW LB;
// Byte 12 : REAL    - DHParameterAlpha[2] HW HB;
// Byte 13 :         - DHParameterAlpha[2] HW LB;
// Byte 14 :         - DHParameterAlpha[2] LW HB;
// Byte 15 :         - DHParameterAlpha[2] LW LB;
// Byte 16 : REAL    - DHParameterAlpha[3] HW HB;
// Byte 17 :         - DHParameterAlpha[3] HW LB;
// Byte 18 :         - DHParameterAlpha[3] LW HB;
// Byte 19 :         - DHParameterAlpha[3] LW LB;
// Byte 20 : REAL    - DHParameterAlpha[4] HW HB;
// Byte 21 :         - DHParameterAlpha[4] HW LB;
// Byte 22 :         - DHParameterAlpha[4] LW HB;
// Byte 23 :         - DHParameterAlpha[4] LW LB;
// Byte 24 : REAL    - DHParameterAlpha[5] HW HB;
// Byte 25 :         - DHParameterAlpha[5] HW LB;
// Byte 26 :         - DHParameterAlpha[5] LW HB;
// Byte 27 :         - DHParameterAlpha[5] LW LB;
// Byte 28 : REAL    - DHParameterAlpha[6] HW HB;
// Byte 29 :         - DHParameterAlpha[6] HW LB;
// Byte 30 :         - DHParameterAlpha[6] LW HB;
// Byte 31 :         - DHParameterAlpha[6] LW LB;
// Byte 32 : REAL    - DHParameterA[0] HW HB;
// Byte 33 :         - DHParameterA[0] HW LB;
// Byte 34 :         - DHParameterA[0] LW HB;
// Byte 35 :         - DHParameterA[0] LW LB;
// Byte 36 : REAL    - DHParameterA[1] HW HB;
// Byte 37 :         - DHParameterA[1] HW LB;
// Byte 38 :         - DHParameterA[1] LW HB;
// Byte 39 :         - DHParameterA[1] LW LB;
// Byte 40 : REAL    - DHParameterA[2] HW HB;
// Byte 41 :         - DHParameterA[2] HW LB;
// Byte 42 :         - DHParameterA[2] LW HB;
// Byte 43 :         - DHParameterA[2] LW LB;
// Byte 44 : REAL    - DHParameterA[3] HW HB;
// Byte 45 :         - DHParameterA[3] HW LB;
// Byte 46 :         - DHParameterA[3] LW HB;
// Byte 47 :         - DHParameterA[3] LW LB;
// Byte 48 : REAL    - DHParameterA[4] HW HB;
// Byte 49 :         - DHParameterA[4] HW LB;
// Byte 50 :         - DHParameterA[4] LW HB;
// Byte 51 :         - DHParameterA[4] LW LB;
// Byte 52 : REAL    - DHParameterA[5] HW HB;
// Byte 53 :         - DHParameterA[5] HW LB;
// Byte 54 :         - DHParameterA[5] LW HB;
// Byte 55 :         - DHParameterA[5] LW LB;
// Byte 56 : REAL    - DHParameterA[6] HW HB;
// Byte 57 :         - DHParameterA[6] HW LB;
// Byte 58 :         - DHParameterA[6] LW HB;
// Byte 59 :         - DHParameterA[6] LW LB;
// Byte 60 : REAL    - DHParameterD[0] HW HB;
// Byte 61 :         - DHParameterD[0] HW LB;
// Byte 62 :         - DHParameterD[0] LW HB;
// Byte 63 :         - DHParameterD[0] LW LB;
// Byte 64 : REAL    - DHParameterD[1] HW HB;
// Byte 65 :         - DHParameterD[1] HW LB;
// Byte 66 :         - DHParameterD[1] LW HB;
// Byte 67 :         - DHParameterD[1] LW LB;
// Byte 68 : REAL    - DHParameterD[2] HW HB;
// Byte 69 :         - DHParameterD[2] HW LB;
// Byte 70 :         - DHParameterD[2] LW HB;
// Byte 71 :         - DHParameterD[2] LW LB;
// Byte 72 : REAL    - DHParameterD[3] HW HB;
// Byte 73 :         - DHParameterD[3] HW LB;
// Byte 74 :         - DHParameterD[3] LW HB;
// Byte 75 :         - DHParameterD[3] LW LB;
// Byte 76 : REAL    - DHParameterD[4] HW HB;
// Byte 77 :         - DHParameterD[4] HW LB;
// Byte 78 :         - DHParameterD[4] LW HB;
// Byte 79 :         - DHParameterD[4] LW LB;
// Byte 80 : REAL    - DHParameterD[5] HW HB;
// Byte 81 :         - DHParameterD[5] HW LB;
// Byte 82 :         - DHParameterD[5] LW HB;
// Byte 83 :         - DHParameterD[5] LW LB;
// Byte 84 : REAL    - DHParameterD[6] HW HB;
// Byte 85 :         - DHParameterD[6] HW LB;
// Byte 86 :         - DHParameterD[6] LW HB;
// Byte 87 :         - DHParameterD[6] LW LB;
// Byte 88 : REAL    - DHParameterTheta[0] HW HB;
// Byte 89 :         - DHParameterTheta[0] HW LB;
// Byte 90 :         - DHParameterTheta[0] LW HB;
// Byte 91 :         - DHParameterTheta[0] LW LB;
// Byte 92 : REAL    - DHParameterTheta[1] HW HB;
// Byte 93 :         - DHParameterTheta[1] HW LB;
// Byte 94 :         - DHParameterTheta[1] LW HB;
// Byte 95 :         - DHParameterTheta[1] LW LB;
// Byte 96 : REAL    - DHParameterTheta[2] HW HB;
// Byte 97 :         - DHParameterTheta[2] HW LB;
// Byte 98 :         - DHParameterTheta[2] LW HB;
// Byte 99 :         - DHParameterTheta[2] LW LB;
// Byte 100: REAL    - DHParameterTheta[3] HW HB;
// Byte 101:         - DHParameterTheta[3] HW LB;
// Byte 102:         - DHParameterTheta[3] LW HB;
// Byte 103:         - DHParameterTheta[3] LW LB;
// Byte 104: REAL    - DHParameterTheta[4] HW HB;
// Byte 105:         - DHParameterTheta[4] HW LB;
// Byte 106:         - DHParameterTheta[4] LW HB;
// Byte 107:         - DHParameterTheta[4] LW LB;
// Byte 108: REAL    - DHParameterTheta[5] HW HB;
// Byte 109:         - DHParameterTheta[5] HW LB;
// Byte 110:         - DHParameterTheta[5] LW HB;
// Byte 111:         - DHParameterTheta[5] LW LB;
// Byte 112: REAL    - DHParameterTheta[6] HW HB;
// Byte 113:         - DHParameterTheta[6] HW LB;
// Byte 114:         - DHParameterTheta[6] LW HB;
// Byte 115:         - DHParameterTheta[6] LW LB;
// Byte 116: REAL    - JointZeroPosition[0] HW HB;
// Byte 117:         - JointZeroPosition[0] HW LB;
// Byte 118:         - JointZeroPosition[0] LW HB;
// Byte 119:         - JointZeroPosition[0] LW LB;
// Byte 120: REAL    - JointZeroPosition[1] HW HB;
// Byte 121:         - JointZeroPosition[1] HW LB;
// Byte 122:         - JointZeroPosition[1] LW HB;
// Byte 123:         - JointZeroPosition[1] LW LB;
// Byte 124: REAL    - JointZeroPosition[2] HW HB;
// Byte 125:         - JointZeroPosition[2] HW LB;
// Byte 126:         - JointZeroPosition[2] LW HB;
// Byte 127:         - JointZeroPosition[2] LW LB;
// Byte 128: REAL    - JointZeroPosition[3] HW HB;
// Byte 129:         - JointZeroPosition[3] HW LB;
// Byte 130:         - JointZeroPosition[3] LW HB;
// Byte 131:         - JointZeroPosition[3] LW LB;
// Byte 132: REAL    - JointZeroPosition[4] HW HB;
// Byte 133:         - JointZeroPosition[4] HW LB;
// Byte 134:         - JointZeroPosition[4] LW HB;
// Byte 135:         - JointZeroPosition[4] LW LB;
// Byte 136: REAL    - JointZeroPosition[5] HW HB;
// Byte 137:         - JointZeroPosition[5] HW LB;
// Byte 138:         - JointZeroPosition[5] LW HB;
// Byte 139:         - JointZeroPosition[5] LW LB;
// Byte 140: REAL    - JointZeroPosition[6] HW HB;
// Byte 141:         - JointZeroPosition[6] HW LB;
// Byte 142:         - JointZeroPosition[6] LW HB;
// Byte 143:         - JointZeroPosition[6] LW LB;
// Byte 144: BYTE    - PositiveJointDirection;
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DHParameter.Alpha
     _response.DHParameter.Alpha[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DHParameter.A
     _response.DHParameter.A[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DHParameter.D
     _response.DHParameter.D[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN
      // Get Response.DHParameter.Theta
     _response.DHParameter.Theta[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DHParameter.JointZeroPosition
     _response.DHParameter.JointZeroPosition[_idx] := ResponseData.GetReal();
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 6
  DO
    // Check payload remaining ? 
    IF ( ResponseData.IsPayloadRemaining)
    THEN  
      // Get Response.DHParameter.PositiveJointDirection[_idx]
     _response.DHParameter.PositiveJointDirection[_idx] := ResponseData.GetBool();
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
                  
          
  // Create log entry for DHParameter.Alpha[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.Aplpha
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.Alpha[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.DHParameter.Alpha[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for DHParameter.A[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.A
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.A[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.DHParameter.A[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for DHParameter.D[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.D
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.D[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.DHParameter.D[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for DHParameter.Theta[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.Theta
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.Theta[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.DHParameter.Theta[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for DHParameter.JointZeroPosition[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.JointZeroPosition
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.JointZeroPosition[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_response.DHParameter.JointZeroPosition[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for DHParameter.PositiveJointDirection[{x}]
  FOR _idx := 0 TO 6
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // create log entry for Response.DHParameter.PositiveJointDircetion
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.DHParameter.PositiveJointDirection[{2}] = {1}',
                            Para1       :=  BOOL_TO_STRING(_response.DHParameter.PositiveJointDirection[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

