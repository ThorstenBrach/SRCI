/// Monitor enabled work areas
FUNCTION_BLOCK MC_MonitorWorkAreaFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MonitorWorkAreaFB                                       
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
  /// Set TRUE to activate monitoring of work areas
  Enable            : BOOL;
  /// Command parameter 
  ParCmd            : MonitorWorkAreaParCmd;
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values ActivationState MonitoringState
  Valid             : BOOL;
  /// FB is being processed
  Busy              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;  
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command results
  OutCmd            : MonitorWorkAreaOutCmd;    
END_VAR
VAR
  /// internal copy of command parameter 
 _parCmd            : MonitorWorkAreaParCmd;
  /// command data to send
 _command           : MonitorWorkAreaSendData;
  /// response data received
 _response          : MonitorWorkAreaRecvData;      
  /// Rising edge for enable
 _enable_R          : R_TRIG;
  /// Falling edge for enable
 _enable_F          : F_TRIG;
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-219: Sent CMD payload (PLC to RC) of "MonitorWorkArea"
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
// Byte 4  : BOOL  - Enable
// Byte 5  : USINT - WorkAreaNo

  // set command parameter 
  _command.CmdTyp     :=  CmdType.MonitorWorkArea;
  _command.ExecMode   :=  ExecMode;
  _command.ParSeq     := _command.ParSeq;
  _command.Priority   :=  Priority;
  _command.Enable     :=  Enable;
  _command.WorkAreaNo := _parCmd.WorkAreaNo;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.Enable
  CreateCommandPayload.AddBool(_command.Enable);
  // add command.WorkAreaNo
  CreateCommandPayload.AddUsint(_command.WorkAreaNo);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MonitorWorkAreaFB';
  
  ExecMode := ExecutionMode.PARALLEL;

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q )
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             Valid := TRUE;
             // Update results
             OutCmd.ActivationState := _response.ActivationState;
             OutCmd.MonitoringState := _response.MonitoringState;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
    03: // reset step counter
       _stepCmd := 0;
        // reset busy flag
        Busy := FALSE;    
        // reset buffered flag
        CommandBuffered := FALSE;  
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
  THEN
   _uniqueId           := 0;
   _stepCmd            := 0;
    Valid              := FALSE;
    Busy               := FALSE;
    CommandBuffered    := FALSE;
    Error              := FALSE;
    ErrorID            := 0;
    WarningID          := 0;
    InfoID             := 0;  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-220: Received CMD payload (RC to PLC) of "MonitorWorkArea"
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
// Byte 04 : WORD   - ActivationState LW HB
// Byte 05 :        - ActivationState LW LB
// Byte 06 : WORD   - MonitoringState LW HB
// Byte 07 :        - MonitoringState LW LB
// --------------------------
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
  
  // Get Response.ActivationState
  _response.ActivationState := ResponseData.GetWord();
  // Get Response.MonitoringState
  _response.MonitoringState := ResponseData.GetWord();

END_METHOD

