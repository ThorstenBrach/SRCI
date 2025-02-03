/// Activate conveyor tracking mode
FUNCTION_BLOCK MC_ActivateConveyorTrackingFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActivateConveyorTrackingFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
  /// SSet TRUE to activate conveyor tracking functionality
  Enable             : BOOL;
  /// Command parameter 
  ParCmd             : ActivateConveyorTrackingParCmd;      
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • TrackingStatusByte
  /// • RCEncoderValue
  Valid              : BOOL;
  /// FB is being processed
  Busy               : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// Command output 
  OutCmd             : ActivateConveyorTrackingOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ActivateConveyorTrackingParCmd;
  /// command data to send
 _command            : ActivateConveyorTrackingSendData;
  /// response data received
 _response           : ActivateConveyorTrackingRecvData;  
  /// Rising edge for enable
 _enable_R          : R_TRIG;
  /// Falling edge for enable
 _enable_F          : F_TRIG;    
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.ActivateConveyorTracking;
  
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-438: Sent CMD payload (PLC to RC) of "ActivateConveyorTracking"
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
// Byte 04 : SINT  - ConveyorNo
// Byte 05 : SINT  - ConnectionMode
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ActivateConveyorTracking;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.ConveyorNo     := _parCmd.ConveyorNo;
  _command.ConnectionMode := _parCmd.ConnectionMode;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // add command.ConveyorNo
  CreateCommandPayload.AddSint(_command.ConveyorNo);
  // add command.ConnectionMode
  CreateCommandPayload.AddSint(_command.ConnectionMode);
  
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
                          MessageText := 'CreateCommandPayload with the following parameter(s) :');
  
  // Create log entry for ConveyorNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorNo = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ConveyorNo));
                          
  // Create log entry for ConnectionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConnectionMode = {1}',
                          Para1       :=  CONNECTION_MODE_TO_STRING(_command.ConnectionMode));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ActivateConveyorTrackingFB';

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
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.TrackingStatus := _response.TrackingStatus;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
  
    02: IF (NOT Enable)
        THEN
          Reset();
  	    END_IF
        
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
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
// Table 6-439: Received CMD payload (RC to PLC) of "ActivateConveyorTracking"
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
// Byte 04 : BYTE  - TrackingStatusByte
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.Enabled
  _response.TrackingStatus := ResponseData.GetTrackingStatus();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Valid              := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

