/// Read configuration of defined work areas
FUNCTION_BLOCK MC_ReadWorkAreaFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadWorkAreaFB                                       
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
  ParCmd          : ReadWorkAreaParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadWorkAreaOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadWorkAreaParCmd;
  /// command data to send
 _command         : ReadWorkAreaSendData;
  /// response data received
 _response        : ReadWorkAreaRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.ReadWorkArea;
  
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
  
  
  // Check ParCmd.WorkAreaNo valid ? 
  IF (( ParCmd.WorkAreaNo < 0   ) OR
      ( ParCmd.WorkAreaNo > 254 ))
        
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.WorkAreaNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.WorkAreaNo));
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-199: Sent CMD payload (PLC to RC) of "ReadWorkArea"
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
// Byte 04 : USINT  WorkAreaNo
// --------------------------

  // set command parameter 
  _command.CmdTyp     :=  CmdType.ReadWorkArea;
  _command.ExecMode   :=  ExecMode;
  _command.ParSeq     := _command.ParSeq;
  _command.Priority   :=  Priority;
  _command.WorkAreaNo := _parCmd.WorkAreaNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.WorkAreaNo
  CreateCommandPayload.AddUsint(_command.WorkAreaNo);
  
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
                         
  // Create log entry for WorkAreaNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.WorkAreaNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.WorkAreaNo));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadWorkAreaFB';
  
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
             OutCmd.WorkAreaData     := _response.WorkAreaData;
             OutCmd.WorkAreaNoReturn := _response.WorkAreaNoReturn;
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
// Table 6-200: Received CMD payload (RC to PLC) of "ReadWorkArea"
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
// Byte 04 : USINT    - WorkAreaNo;
// Byte 05 : BYTE     - Reserved;
// Byte 06 : DATE     - Data.Date HW HB;
// Byte 07 :          - Data.Date HW LB;
// Byte 08 : IED_TIME - Data.Time HW HB;
// Byte 09 :          - Data.Time HW LB;
// Byte 10 :          - Data.Time LW HB;
// Byte 11 :          - Data.Time LW LB;
// Byte 12 : USINT    - Data.AreaType;
// Byte 13 : BOOL     - Data.AreaMode;
// Byte 14 : USINT    - Data.ReactionMode;
// Byte 15 : BOOL     - Data.ActiveModification;
// Byte 16 : USINT    - Data.DefinitionMode;
// Byte 17 : USINT    - Data.FrameNo;
// Byte 18 : REAL     - Data.ZeroPointX HW HB;
// Byte 19 :          - Data.ZeroPointX HW LB;
// Byte 20 :          - Data.ZeroPointX LW HB;
// Byte 21 :          - Data.ZeroPointX LW LB;
// Byte 22 : REAL     - Data.ZeroPointY HW HB;
// Byte 23 :          - Data.ZeroPointY HW LB;
// Byte 24 :          - Data.ZeroPointY LW HB;
// Byte 25 :          - Data.ZeroPointY LW LB;
// Byte 26 : REAL     - Data.ZeroPointZ HW HB;
// Byte 27 :          - Data.ZeroPointZ HW LB;
// Byte 28 :          - Data.ZeroPointZ LW HB;
// Byte 29 :          - Data.ZeroPointZ LW LB;
// Byte 30 : REAL     - Data.X1 HW HB;
// Byte 31 :          - Data.X1 HW LB;
// Byte 32 :          - Data.X1 LW HB;
// Byte 33 :          - Data.X1 LW LB;
// Byte 34 : REAL     - Data.X2 HW HB;
// Byte 35 :          - Data.X2 HW LB;
// Byte 36 :          - Data.X2 LW HB;
// Byte 37 :          - Data.X2 LW LB;
// Byte 38 : REAL     - Data.Y1 HW HB;
// Byte 39 :          - Data.Y1 HW LB;
// Byte 40 :          - Data.Y1 LW HB;
// Byte 41 :          - Data.Y1 LW LB;
// Byte 42 : REAL     - Data.Y2 HW HB;
// Byte 43 :          - Data.Y2 HW LB;
// Byte 44 :          - Data.Y2 LW HB;
// Byte 45 :          - Data.Y2 LW LB;
// Byte 46 : REAL     - Data.Z1 HW HB;
// Byte 47 :          - Data.Z1 HW LB;
// Byte 48 :          - Data.Z1 LW HB;
// Byte 49 :          - Data.Z1 LW LB;
// Byte 50 : REAL     - Data.Z2 HW HB;
// Byte 51 :          - Data.Z2 HW LB;
// Byte 52 :          - Data.Z2 LW HB;
// Byte 53 :          - Data.Z2 LW LB;
// Byte 54 : REAL     - Data.Radius HW HB;
// Byte 55 :          - Data.Radius HW LB;
// Byte 56 :          - Data.Radius LW HB;
// Byte 57 :          - Data.Radius LW LB;
// Byte 58 : REAL     - Data.JointLowerLimit.J1 HW HB;
// Byte 59 :          - Data.JointLowerLimit.J1 HW LB;
// Byte 60 :          - Data.JointLowerLimit.J1 LW HB;
// Byte 61 :          - Data.JointLowerLimit.J1 LW LB;
// Byte 62 : REAL     - Data.JointLowerLimit.J2 HW HB;
// Byte 63 :          - Data.JointLowerLimit.J2 HW LB;
// Byte 64 :          - Data.JointLowerLimit.J2 LW HB;
// Byte 65 :          - Data.JointLowerLimit.J2 LW LB;
// Byte 66 : REAL     - Data.JointLowerLimit.J3 HW HB;
// Byte 67 :          - Data.JointLowerLimit.J3 HW LB;
// Byte 68 :          - Data.JointLowerLimit.J3 LW HB;
// Byte 69 :          - Data.JointLowerLimit.J3 LW LB;
// Byte 70 : REAL     - Data.JointLowerLimit.J4 HW HB;
// Byte 71 :          - Data.JointLowerLimit.J4 HW LB;
// Byte 72 :          - Data.JointLowerLimit.J4 LW HB;
// Byte 73 :          - Data.JointLowerLimit.J4 LW LB;
// Byte 74 : REAL     - Data.JointLowerLimit.J5 HW HB;
// Byte 75 :          - Data.JointLowerLimit.J5 HW LB;
// Byte 76 :          - Data.JointLowerLimit.J5 LW HB;
// Byte 77 :          - Data.JointLowerLimit.J5 LW LB;
// Byte 78 : REAL     - Data.JointLowerLimit.J6 HW HB;
// Byte 79 :          - Data.JointLowerLimit.J6 HW LB;
// Byte 80 :          - Data.JointLowerLimit.J6 LW HB;
// Byte 81 :          - Data.JointLowerLimit.J6 LW LB;
// Byte 82 : REAL     - Data.JointLowerLimit.E1 HW HB;
// Byte 83 :          - Data.JointLowerLimit.E1 HW LB;
// Byte 84 :          - Data.JointLowerLimit.E1 LW HB;
// Byte 85 :          - Data.JointLowerLimit.E1 LW LB;
// Byte 86 : REAL     - Data.JointUpperLimit.J1 HW HB;
// Byte 87 :          - Data.JointUpperLimit.J1 HW LB;
// Byte 88 :          - Data.JointUpperLimit.J1 LW HB;
// Byte 89 :          - Data.JointUpperLimit.J1 LW LB;
// Byte 90 : REAL     - Data.JointUpperLimit.J2 HW HB;
// Byte 91 :          - Data.JointUpperLimit.J2 HW LB;
// Byte 92 :          - Data.JointUpperLimit.J2 LW HB;
// Byte 93 :          - Data.JointUpperLimit.J2 LW LB;
// Byte 94 : REAL     - Data.JointUpperLimit.J3 HW HB;
// Byte 95 :          - Data.JointUpperLimit.J3 HW LB;
// Byte 96 :          - Data.JointUpperLimit.J3 LW HB;
// Byte 97 :          - Data.JointUpperLimit.J3 LW LB;
// Byte 98 : REAL     - Data.JointUpperLimit.J4 HW HB;
// Byte 99 :          - Data.JointUpperLimit.J4 HW LB;
// Byte 100:          - Data.JointUpperLimit.J4 LW HB;
// Byte 101:          - Data.JointUpperLimit.J4 LW LB;
// Byte 102: REAL     - Data.JointUpperLimit.J5 HW HB;
// Byte 103:          - Data.JointUpperLimit.J5 HW LB;
// Byte 104:          - Data.JointUpperLimit.J5 LW HB;
// Byte 105:          - Data.JointUpperLimit.J5 LW LB;
// Byte 106: REAL     - Data.JointUpperLimit.J6 HW HB;
// Byte 107:          - Data.JointUpperLimit.J6 HW LB;
// Byte 108:          - Data.JointUpperLimit.J6 LW HB;
// Byte 109:          - Data.JointUpperLimit.J6 LW LB;
// Byte 110: REAL     - Data.JointUpperLimit.E1 HW HB;
// Byte 111:          - Data.JointUpperLimit.E1 HW LB;
// Byte 112:          - Data.JointUpperLimit.E1 LW HB;
// Byte 113:          - Data.JointUpperLimit.E1 LW LB;
// Byte 114: REAL     - Data.JointLowerLimit.E2 HW HB;
// Byte 115:          - Data.JointLowerLimit.E2 HW LB;
// Byte 116:          - Data.JointLowerLimit.E2 LW HB;
// Byte 117:          - Data.JointLowerLimit.E2 LW LB;
// Byte 118: REAL     - Data.JointLowerLimit.E3 HW HB;
// Byte 119:          - Data.JointLowerLimit.E3 HW LB;
// Byte 120:          - Data.JointLowerLimit.E3 LW HB;
// Byte 121:          - Data.JointLowerLimit.E3 LW LB;
// Byte 122: REAL     - Data.JointLowerLimit.E4 HW HB;
// Byte 123:          - Data.JointLowerLimit.E4 HW LB;
// Byte 124:          - Data.JointLowerLimit.E4 LW HB;
// Byte 125:          - Data.JointLowerLimit.E4 LW LB;
// Byte 126: REAL     - Data.JointLowerLimit.E5 HW HB;
// Byte 127:          - Data.JointLowerLimit.E5 HW LB;
// Byte 128:          - Data.JointLowerLimit.E5 LW HB;
// Byte 129:          - Data.JointLowerLimit.E5 LW LB;
// Byte 130: REAL     - Data.JointLowerLimit.E6 HW HB;
// Byte 131:          - Data.JointLowerLimit.E6 HW LB;
// Byte 132:          - Data.JointLowerLimit.E6 LW HB;
// Byte 133:          - Data.JointLowerLimit.E6 LW LB;
// Byte 134: REAL     - Data.JointUpperLimit.E2 HW HB;
// Byte 135:          - Data.JointUpperLimit.E2 HW LB;
// Byte 136:          - Data.JointUpperLimit.E2 LW HB;
// Byte 137:          - Data.JointUpperLimit.E2 LW LB;
// Byte 138: REAL     - Data.JointUpperLimit.E3 HW HB;
// Byte 139:          - Data.JointUpperLimit.E3 HW LB;
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.WorkAreaNoReturn
  _response.WorkAreaNoReturn := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetByte();
  // Get Response.WorkAreaData.Timestamp.IEC_DATE
  _response.WorkAreaData.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.WorkAreaData.Timestamp.IEC_TIME
  _response.WorkAreaData.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.WorkAreaData.AreaType
  _response.WorkAreaData.AreaType := ResponseData.GetUsint();
  // Get Response.WorkAreaData.AreaMode
  _response.WorkAreaData.AreaMode := ResponseData.GetBool();
  // Get Response.WorkAreaData.ReactionMode
  _response.WorkAreaData.ReactionMode := ResponseData.GetUsint();
  // Get Response.WorkAreaData.ActiveModification
  _response.WorkAreaData.ActiveModification := ResponseData.GetBool();
  // Get Response.WorkAreaData.DefinitionMode
  _response.WorkAreaData.DefinitionMode := ResponseData.GetUsint();
  // Get Response.WorkAreaData.FrameNo
  _response.WorkAreaData.FrameNo := ResponseData.GetUsint();
  // Get Response.WorkAreaData.ZeroPointX
  _response.WorkAreaData.ZeroPointX := ResponseData.GetReal();
  // Get Response.WorkAreaData.ZeroPointY
  _response.WorkAreaData.ZeroPointY := ResponseData.GetReal();
  // Get Response.WorkAreaData.ZeroPointZ
  _response.WorkAreaData.ZeroPointZ := ResponseData.GetReal();
  // Get Response.WorkAreaData.X.LowerLimit
  _response.WorkAreaData.X.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.X.UpperLimit
  _response.WorkAreaData.X.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.Y.LowerLimit
  _response.WorkAreaData.Y.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.Y.UpperLimit
  _response.WorkAreaData.Y.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.Z.LowerLimit
  _response.WorkAreaData.Z.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.Z.UpperLimit
  _response.WorkAreaData.Z.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.Radiust
  _response.WorkAreaData.Radius := ResponseData.GetReal();
  // Get Response.WorkAreaData.J1Limit.LowerLimit
  _response.WorkAreaData.J1Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J2Limit.LowerLimit
  _response.WorkAreaData.J2Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J3Limit.LowerLimit
  _response.WorkAreaData.J3Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J4Limit.LowerLimit
  _response.WorkAreaData.J4Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J5Limit.LowerLimit
  _response.WorkAreaData.J5Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J6Limit.LowerLimit
  _response.WorkAreaData.J6Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E1Limit.LowerLimit
  _response.WorkAreaData.E1Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J1Limit.UpperLimit
  _response.WorkAreaData.J1Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J2Limit.UpperLimit
  _response.WorkAreaData.J2Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J3Limit.UpperLimit
  _response.WorkAreaData.J3Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J4Limit.UpperLimit
  _response.WorkAreaData.J4Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J5Limit.UpperLimit
  _response.WorkAreaData.J5Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.J6Limit.UpperLimit
  _response.WorkAreaData.J6Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E1Limit.UpperLimit
  _response.WorkAreaData.E1Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E2Limit.LowerLimit
  _response.WorkAreaData.E2Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E3Limit.LowerLimit
  _response.WorkAreaData.E3Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E4Limit.LowerLimit
  _response.WorkAreaData.E4Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E5Limit.LowerLimit
  _response.WorkAreaData.E5Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E6Limit.LowerLimit
  _response.WorkAreaData.E6Limit.LowerLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E2Limit.UpperLimit
  _response.WorkAreaData.E2Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E3Limit.UpperLimit
  _response.WorkAreaData.E3Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E4Limit.UpperLimit
  _response.WorkAreaData.E4Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E5Limit.UpperLimit
  _response.WorkAreaData.E5Limit.UpperLimit := ResponseData.GetReal();
  // Get Response.WorkAreaData.E6Limit.UpperLimit
  _response.WorkAreaData.E6Limit.UpperLimit := ResponseData.GetReal();
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
                          
  // Create log entry for WorkAreaNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaNoReturn = {1}',
                          Para1       :=  USINT_TO_STRING(_response.WorkAreaNoReturn));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve));
  
  // Create log entry for WorkAreaData.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_response.WorkAreaData.Timestamp.IEC_DATE));
  
  // Create log entry for WorkAreaData.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_response.WorkAreaData.Timestamp.IEC_TIME));
  
  // Create log entry for WorkAreaData.AreaType
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.AreaType = {1}',
                          Para1       :=  USINT_TO_STRING(_response.WorkAreaData.AreaType));
  
  // Create log entry for WorkAreaData.AreaMode
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.AreaMode = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.WorkAreaData.AreaMode));
                          
  // Create log entry for WorkAreaData.ReactionMode
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.ReactionMode = {1}',
                          Para1       :=  WORK_AREA_REACTION_MODE_TO_STRING(_response.WorkAreaData.ReactionMode));
  
  // Create log entry for WorkAreaData.ActiveModification
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.ActiveModification = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.WorkAreaData.ActiveModification));
  
  // Create log entry for WorkAreaData.DefinitionMode
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.DefinitionMode = {1}',
                          Para1       := DEFINITION_MODE_TO_STRING(_response.WorkAreaData.DefinitionMode));
  
  // Create log entry for WorkAreaData.FrameNo
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_response.WorkAreaData.FrameNo));
  
  // Create log entry for WorkAreaData.ZeroPointX
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.ZeroPointX = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.ZeroPointX));
  
  // Create log entry for WorkAreaData.ZeroPointY
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.ZeroPointY = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.ZeroPointY));
  
  // Create log entry for WorkAreaData.ZeroPointZ
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.ZeroPointZ = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.ZeroPointZ));
  
  // Create log entry for WorkAreaData.X.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.X.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.X.LowerLimit));
  
  // Create log entry for WorkAreaData.X.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.X.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.X.UpperLimit));
  
  // Create log entry for WorkAreaData.Y.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Y.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.Y.LowerLimit));
  
  // Create log entry for WorkAreaData.Y.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Y.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.Y.UpperLimit));
  
  // Create log entry for WorkAreaData.Z.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Z.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.Z.LowerLimit));
  
  // Create log entry for WorkAreaData.Z.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Z.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.Z.UpperLimit));
  
  // Create log entry for WorkAreaData.Radius
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.Radius = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.Radius));
  
  // Create log entry for WorkAreaData.J1Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J1Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J1Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J2Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J2Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J2Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J3Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J3Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J3Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J4Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J4Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J4Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J5Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J5Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J5Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J6Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J6Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J6Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E1Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E1Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E1Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.J1Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J1Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J1Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.J2Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J2Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J2Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.J3Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J3Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J3Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.J4Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J4Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J4Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.J5Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J5Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J5Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.J6Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.J6Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.J6Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E1Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E1Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E1Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E2Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E2Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E2Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E3Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E3Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E3Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E4Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E4Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E4Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E5Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E5Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E5Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E6Limit.LowerLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E6Limit.LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E6Limit.LowerLimit));
  
  // Create log entry for WorkAreaData.E2Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E2Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E2Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E3Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E3Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E3Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E4Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E4Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E4Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E5Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E5Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E5Limit.UpperLimit));
  
  // Create log entry for WorkAreaData.E6Limit.UpperLimit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.WorkAreaData.E6Limit.UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_response.WorkAreaData.E6Limit.UpperLimit));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

