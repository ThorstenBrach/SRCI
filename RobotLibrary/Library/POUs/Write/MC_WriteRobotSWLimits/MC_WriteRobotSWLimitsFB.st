/// Change robot limits of robot axes (degree)
FUNCTION_BLOCK MC_WriteRobotSWLimitsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteRobotSWLimitsFB                                       
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
  ParCmd          : WriteRobotSWLimitsParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : WriteRobotSWLimitsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : WriteRobotSWLimitsParCmd;
  /// command data to send
 _command         : WriteRobotSWLimitsSendData;
  /// response data received
 _response        : WriteRobotSWLimitsRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.WriteRobotSWLimits;
  
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
    CommandData := CreateCommandPayload(); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-185: Sent CMD payload (PLC to RC) of "WriteRobotSWLimits"
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
// Byte 09 : REAL J1LowerLimit
// Byte 10 : 
// Byte 11 : 
// Byte 12 : REAL J2LowerLimit
// Byte 13 : 
// Byte 14 : 
// Byte 15 : REAL J3LowerLimit
// Byte 16 : 
// Byte 17 : 
// Byte 18 : REAL J4LowerLimit
// Byte 19 : 
// Byte 20 : 
// Byte 21 : REAL J5LowerLimit
// Byte 22 : 
// Byte 23 : 
// Byte 24 : REAL J6LowerLimit
// Byte 25 : 
// Byte 26 : 
// Byte 27 : REAL E1LowerLimit
// Byte 28 : 
// Byte 29 : 
// Byte 30 : REAL J1UpperLimit
// Byte 31 : 
// Byte 32 : 
// Byte 33 : REAL J2UpperLimit
// Byte 34 : 
// Byte 35 : 
// Byte 36 : REAL J3UpperLimit
// Byte 37 : 
// Byte 38 : 
// Byte 39 : REAL J4UpperLimit
// Byte 40 : 
// Byte 41 : 
// Byte 42 : REAL J5UpperLimit
// Byte 43 : 
// Byte 44 : 
// Byte 45 : REAL J6UpperLimit
// Byte 46 : 
// Byte 47 : 
// Byte 48 : REAL E1UpperLimit
// Byte 49 : 
// Byte 50 : 
// Byte 51 : REAL E2LowerLimit
// Byte 52 : 
// Byte 53 : 
// Byte 54 : REAL E3LowerLimit
// Byte 55 : 
// Byte 56 : 
// Byte 57 : REAL E4LowerLimit
// Byte 58 : 
// Byte 59 : 
// Byte 60 : REAL E5LowerLimit
// Byte 61 : 
// Byte 62 : 
// Byte 63 : REAL E6LowerLimit
// Byte 64 : 
// Byte 65 : 
// Byte 66 : REAL E2UpperLimit
// Byte 67 : 
// Byte 68 : 
// Byte 69 : REAL E3UpperLimit
// Byte 70 : 
// Byte 71 : 
// Byte 72 : REAL E4UpperLimit
// Byte 73 : 
// Byte 74 : 
// Byte 75 : REAL E5UpperLimit
// Byte 76 : 
// Byte 77 : 
// Byte 78 : REAL E6UpperLimit
// Byte 79 : 
// Byte 80 : 
// Byte 81 : 
// Byte 82 : BOOL ResetToFactoryDefault
// --------------------------

  // set command parameter 
  _command.CmdTyp                 :=  CmdType.WriteRobotSWLimits;
  _command.ExecMode               :=  ExecMode;
  _command.ParSeq                 := _command.ParSeq;
  _command.Priority               :=  Priority;
                                  
  _command.LimitValues            :=  _parCmd.LimitValues;
  _command.ResetToFactoryDefaults :=  _parCmd.ResetToFactoryDefaults;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.LimitValues.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.LimitValues.Timestamp.IEC_DATE);
  // add command.LimitValues.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.LimitValues.Timestamp.IEC_TIME);
  // add command.LimitValues.J1LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J1LowerLimit);
  // add command.LimitValues.J2LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J2LowerLimit);
  // add command.LimitValues.J3LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J3LowerLimit);
  // add command.LimitValues.J41LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J4LowerLimit);
  // add command.LimitValues.J5LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J5LowerLimit);
  // add command.LimitValues.J6LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J6LowerLimit);
  // add command.LimitValues.E1LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E1LowerLimit);
  // add command.LimitValues.J1UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J1UpperLimit);
  // add command.LimitValues.J2UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J2UpperLimit);
  // add command.LimitValues.J3UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J3UpperLimit);
  // add command.LimitValues.J4UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J4UpperLimit);
  // add command.LimitValues.J5UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J5UpperLimit);
  // add command.LimitValues.J6UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.J6UpperLimit);
  // add command.LimitValues.E1UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E1UpperLimit);
  // add command.LimitValues.E2LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E2LowerLimit);
  // add command.LimitValues.E3LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E3LowerLimit);
  // add command.LimitValues.E4LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E4LowerLimit);
  // add command.LimitValues.E5LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E5LowerLimit);
  // add command.LimitValues.E6LowerLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E6LowerLimit);
  // add command.LimitValues.E2UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E2UpperLimit);
  // add command.LimitValues.E3UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E3UpperLimit);
  // add command.LimitValues.E4UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E4UpperLimit);
  // add command.LimitValues.E5UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E5UpperLimit);
  // add command.LimitValues.E6UpperLimit
  CreateCommandPayload.AddReal(_command.LimitValues.E6UpperLimit);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteRobotSWLimitsFB';
  
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
             CommandData := CreateCommandPayload();
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
             OutCmd.RestartRequested  := _response.RestartRequested;
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
// Table 6-186: Received CMD payload (RC to PLC) of "WriteRobotSWLimits"
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
// Byte 04 : BOOL       - RestartRequested
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.RestartRequested
  _response.RestartRequested := ResponseData.GetBool();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

