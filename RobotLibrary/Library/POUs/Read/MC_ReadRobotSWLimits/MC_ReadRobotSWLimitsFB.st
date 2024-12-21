/// Read actual software limits of the axes Positive and negative Limit of Joint J1…J6, E1…E6
FUNCTION_BLOCK MC_ReadRobotSWLimitsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRobotSWLimitsFB                                       
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
  ParCmd          : ReadRobotSWLimitsParCmd;
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadRobotSWLimitsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadRobotSWLimitsParCmd;
  /// command data to send
 _command         : ReadRobotSWLimitsSendData;
  /// response data received
 _response        : ReadRobotSWLimitsRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  // Check ParCmd Size is > 0, becaue MemCmp does not work correctly with size = 0
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

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-178: Sent CMD payload (PLC to RC) of "ReadRobotSWLimits"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadRobotSWLimits;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadRobotSWLimitsFB';
  
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
           // set busy flag
           Busy := TRUE;
           // Reset command outputs
           SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
           // apply command parameter
          _parCmd := ParCmd;
           // init parameter sequence
          _command.ParSeq := 1;
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
       
    01:  // create command data
         CommandData := CreateCommandPayload();
         // Add command to active command register
        _uniqueID := AxesGroup.Acyclic.ActiveCommandRegister.AddCmd( pCommandFB := ADR(THIS^ ));     
         // set timeout
         SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
         // inc step counter
        _stepCmd := _stepCmd + 1; 
  
    02:  // Wait for responce received
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
             OutCmd.LimitValues := _response.LimitValues;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
    03: IF ( NOT Execute)
        THEN
          Reset();
        END_IF     
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  // Cancel 
  IF (Busy) AND (NOT Execute) 
  THEN
    // try to remove cmd
    AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
  END_IF
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-179: Received CMD payload (RC to PLC) of "WriteRobotSWLimits"
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
// Byte 04 : IEC_DATE -  Date HW HB;
// Byte 05 :             Date HW LB;
// Byte 06 : IED_TIME -  Time HW HB;
// Byte 07 :             Time HW LB;
// Byte 08 :             Time LW HB;
// Byte 09 :             Time LW LB;
// Byte 10 : REAL        J1LowerLimit HW HB;
// Byte 11 :             J1LowerLimit HW LB;
// Byte 12 :             J1LowerLimit LW HB;
// Byte 13 :             J1LowerLimit LW LB;
// Byte 14 : REAL        J2LowerLimit HW HB;
// Byte 15 :             J2LowerLimit HW LB;
// Byte 16 :             J2LowerLimit LW HB;
// Byte 17 :             J2LowerLimit LW LB;
// Byte 18 : REAL        J3LowerLimit HW HB;
// Byte 19 :             J3LowerLimit HW LB;
// Byte 20 :             J3LowerLimit LW HB;
// Byte 21 :             J3LowerLimit LW LB;
// Byte 22 : REAL        J4LowerLimit HW HB;
// Byte 23 :             J4LowerLimit HW LB;
// Byte 24 :             J4LowerLimit LW HB;
// Byte 25 :             J4LowerLimit LW LB;
// Byte 26 : REAL        J5LowerLimit HW HB;
// Byte 27 :             J5LowerLimit HW LB;
// Byte 28 :             J5LowerLimit LW HB;
// Byte 29 :             J5LowerLimit LW LB;
// Byte 30 : REAL        J6LowerLimit HW HB;
// Byte 31 :             J6LowerLimit HW LB;
// Byte 32 :             J6LowerLimit LW HB;
// Byte 33 :             J6LowerLimit LW LB;
// Byte 34 : REAL        E1LowerLimit HW HB;
// Byte 35 :             E1LowerLimit HW LB;
// Byte 36 :             E1LowerLimit LW HB;
// Byte 37 :             E1LowerLimit LW LB;
// Byte 38 : REAL        J1UpperLimit HW HB;
// Byte 39 :             J1UpperLimit HW LB;
// Byte 40 :             J1UpperLimit LW HB;
// Byte 41 :             J1UpperLimit LW LB;
// Byte 42 : REAL        J2UpperLimit HW HB;
// Byte 43 :             J2UpperLimit HW LB;
// Byte 44 :             J2UpperLimit LW HB;
// Byte 45 :             J2UpperLimit LW LB;
// Byte 46 : REAL        J3UpperLimit HW HB;
// Byte 47 :             J3UpperLimit HW LB;
// Byte 48 :             J3UpperLimit LW HB;
// Byte 49 :             J3UpperLimit LW LB;
// Byte 50 : REAL        J4UpperLimit HW HB;
// Byte 51 :             J4UpperLimit HW LB;
// Byte 52 :             J4UpperLimit LW HB;
// Byte 53 :             J4UpperLimit LW LB;
// Byte 54 : REAL        J5UpperLimit HW HB;
// Byte 55 :             J5UpperLimit HW LB;
// Byte 56 :             J5UpperLimit LW HB;
// Byte 57 :             J5UpperLimit LW LB;
// Byte 58 : REAL        J6UpperLimit HW HB;
// Byte 59 :             J6UpperLimit HW LB;
// Byte 60 :             J6UpperLimit LW HB;
// Byte 61 :             J6UpperLimit LW LB;
// Byte 62 : REAL        E1UpperLimit HW HB;
// Byte 63 :             E1UpperLimit HW LB;
// Byte 64 :             E1UpperLimit LW HB;
// Byte 65 :             E1UpperLimit LW LB;
// Byte 66 : REAL        E2LowerLimit HW HB;
// Byte 67 :             E2LowerLimit HW LB;
// Byte 68 :             E2LowerLimit LW HB;
// Byte 69 :             E2LowerLimit LW LB;
// Byte 70 : REAL        E3LowerLimit HW HB;
// Byte 71 :             E3LowerLimit HW LB;
// Byte 72 :             E3LowerLimit LW HB;
// Byte 73 :             E3LowerLimit LW LB;
// Byte 74 : REAL        E4LowerLimit HW HB;
// Byte 75 :             E4LowerLimit HW LB;
// Byte 76 :             E4LowerLimit LW HB;
// Byte 77 :             E4LowerLimit LW LB;
// Byte 78 : REAL        E5LowerLimit HW HB;
// Byte 79 :             E5LowerLimit HW LB;
// Byte 80 :             E5LowerLimit LW HB;
// Byte 81 :             E5LowerLimit LW LB;
// Byte 82 : REAL        E6LowerLimit HW HB;
// Byte 83 :             E6LowerLimit HW LB;
// Byte 84 :             E6LowerLimit LW HB;
// Byte 85 :             E6LowerLimit LW LB;
// Byte 86 : REAL        E2UpperLimit HW HB;
// Byte 87 :             E2UpperLimit HW LB;
// Byte 88 :             E2UpperLimit LW HB;
// Byte 89 :             E2UpperLimit LW LB;
// Byte 90 : REAL        E3UpperLimit HW HB;
// Byte 91 :             E3UpperLimit HW LB;
// Byte 92 :             E3UpperLimit LW HB;
// Byte 93 :             E3UpperLimit LW LB;
// Byte 94 : REAL        E4UpperLimit HW HB;
// Byte 95 :             E4UpperLimit HW LB;
// Byte 96 :             E4UpperLimit LW HB;
// Byte 97 :             E4UpperLimit LW LB;
// Byte 98 : REAL        E5UpperLimit HW HB;
// Byte 99 :             E5UpperLimit HW LB;
// Byte 100:             E5UpperLimit LW HB;
// Byte 101:             E5UpperLimit LW LB;
// Byte 102: REAL        E6UpperLimit HW HB;
// Byte 103:             E6UpperLimit HW LB;
// Byte 104:             E6UpperLimit LW HB;
// Byte 105:             E6UpperLimit LW LB;
// Byte 106: BOOL        DataChanged;
// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RecvData;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.LimitValues.Timestamp.IEC_DATE
  _response.LimitValues.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.LimitValues.Timestamp.IEC_TIME
  _response.LimitValues.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.LimitValues.J1LowerLimit
  _response.LimitValues.J1LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J2LowerLimit
  _response.LimitValues.J2LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J3LowerLimit
  _response.LimitValues.J3LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J4LowerLimit
  _response.LimitValues.J4LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J5LowerLimit
  _response.LimitValues.J5LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J6LowerLimit
  _response.LimitValues.J6LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E1LowerLimit
  _response.LimitValues.E1LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J1UpperLimit
  _response.LimitValues.J1UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J2UpperLimit
  _response.LimitValues.J2UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J3UpperLimit
  _response.LimitValues.J3UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J4UpperLimit
  _response.LimitValues.J4UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J5UpperLimit
  _response.LimitValues.J5UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.J6UpperLimit
  _response.LimitValues.J6UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E1UpperLimit
  _response.LimitValues.E1UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E2LowerLimit
  _response.LimitValues.E2LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E3LowerLimit
  _response.LimitValues.E3LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E4LowerLimit
  _response.LimitValues.E4LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E5LowerLimit
  _response.LimitValues.E5LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E6LowerLimit
  _response.LimitValues.E6LowerLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E2UpperLimit
  _response.LimitValues.E2UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E3UpperLimit
  _response.LimitValues.E3UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E4UpperLimit
  _response.LimitValues.E4UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E5UpperLimit
  _response.LimitValues.E5UpperLimit := ResponseData.GetReal();
  // Get Response.LimitValues.E6UpperLimit
  _response.LimitValues.E6UpperLimit := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

