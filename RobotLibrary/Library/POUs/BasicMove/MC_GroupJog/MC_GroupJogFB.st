/// Jog robot manually
FUNCTION_BLOCK MC_GroupJogFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      GroupJogFB                                       
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
  /// Command parameter 
  ParCmd            : GroupJogParCmd;    
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// The active movement was aborted by another command
  CommandAborted    : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// The command takes control of the motion of the according axis group.
  Active            : BOOL;
  /// Command output 
  OutCmd            : GroupJogOutCmd;      
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : GroupJogParCmd;
  /// command data to send
 _command           : GroupJogSendData;
  /// response data received
 _response          : GroupJogRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.GroupJog;
  
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckParameterValid := TRUE;
  
  // Check ParCmd.Override valid ? 
  IF  (( SysDepIsValidReal(ParCmd.Override) = FALSE )  OR
       (                   ParCmd.Override  <     0 )  OR 
       (                   ParCmd.Override  >   100 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.Override = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Override));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.Control valid ? 
  IF  (( ParCmd.Control. X_J1_Neg) AND ( ParCmd.Control. X_J1_Pos ))  OR
      (( ParCmd.Control. Y_J2_Neg) AND ( ParCmd.Control. Y_J2_Pos ))  OR
      (( ParCmd.Control. Z_J3_Neg) AND ( ParCmd.Control. Z_J3_Pos ))  OR
      (( ParCmd.Control.Rx_J4_Neg) AND ( ParCmd.Control.Rx_J4_Pos ))  OR
      (( ParCmd.Control.Ry_J5_Neg) AND ( ParCmd.Control.Ry_J5_Pos ))  OR
      (( ParCmd.Control.Rz_J6_Neg) AND ( ParCmd.Control.Rz_J6_Pos )) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.Control = {1}',
                            Para1       := JOG_CONTROL_TO_STRING(ParCmd.Control));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <   0 ) OR   
      ( ParCmd.ToolNo > 254 ))
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
                            MessageText := 'Invalid Parameter ParCmd.ToolNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.ToolNo));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <   0 ) OR   
      ( ParCmd.FrameNo > 254 ))
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
                            MessageText := 'Invalid Parameter ParCmd.FrameNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.FrameNo));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.IncrementalTranslation valid ? 
  IF  (( SysDepIsValidReal(ParCmd.IncrementalTranslation) = FALSE )  OR
       (                   ParCmd.IncrementalTranslation  <     0 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.IncrementalTranslation = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.IncrementalTranslation));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.IncrementalRotation valid ? 
  IF  (( SysDepIsValidReal(ParCmd.IncrementalRotation) = FALSE )  OR
       (                   ParCmd.IncrementalRotation  <     0 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.IncrementalRotation = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.IncrementalRotation));                            
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-236: Sent CMD payload (PLC to RC) of "GroupJog"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT       - Type HB     
// Byte 01 :            - Type LB    
// Byte 02 : USINT      - Reserve | ExecutionMode
// Byte 03 : USINT      - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 04 : BOOL       - Enable
// Byte 05 : USINT      - ToolNo
// Byte 06 : USINT      - FrameNo
// Byte 07 : USINT      - Mode
// Byte 08 : REAL       - IncrementalTranslation HW HB
// Byte 09 :            - IncrementalTranslation HW LB
// Byte 10 :            - IncrementalTranslation LW HB
// Byte 11 :            - IncrementalTranslation LW LB
// Byte 12 : REAL       - IncrementalRotation HW HB
// Byte 13 :            - IncrementalRotation HW LB
// Byte 14 :            - IncrementalRotation LW HB
// Byte 15 :            - IncrementalRotation LW LB
// Byte 16 : USINT      - Override
// Byte 17 : BYTE       - JogControl[0]
// Byte 18 : BYTE       - JogControl[1]
// Byte 19 : BYTE       - JogControl[2]
// --------------------------

  // set command parameter 
  _command.CmdTyp                 :=  CmdType.GroupJog;
  _command.ExecMode               :=  ExecMode;
  _command.ParSeq                 := _command.ParSeq;
  _command.Priority               :=  Priority;
                           
  _command.Enable                 :=  Enable;
  _command.ToolNo                 := _parCmd.ToolNo; 
  _command.FrameNo                := _parCmd.FrameNo;
  _command.Mode                   := _parCmd.Mode;
  _command.IncrementalTranslation := _parCmd.IncrementalTranslation;
  _command.IncrementalRotation    := _parCmd.IncrementalRotation;
  _command.Override               := _parCmd.Override * 100;
  _command.JogControl[0].0        := _parCmd.Control.X_J1_Pos;
  _command.JogControl[0].1        := _parCmd.Control.Y_J2_Pos;
  _command.JogControl[0].2        := _parCmd.Control.Z_J3_Pos;
  _command.JogControl[0].3        := _parCmd.Control.Rx_J4_Pos;
  _command.JogControl[0].4        := _parCmd.Control.Ry_J5_Pos;
  _command.JogControl[0].5        := _parCmd.Control.Rz_J6_Pos;
  _command.JogControl[0].6        := _parCmd.Control.X_J1_Neg;
  _command.JogControl[0].7        := _parCmd.Control.Y_J2_Neg;
  _command.JogControl[1].0        := _parCmd.Control.Z_J3_Neg;
  _command.JogControl[1].1        := _parCmd.Control.Rx_J4_Neg;
  _command.JogControl[1].2        := _parCmd.Control.Ry_J5_Neg;
  _command.JogControl[1].3        := _parCmd.Control.Rz_J6_Neg;
  _command.JogControl[1].4        := _parCmd.Control.E1_Pos;
  _command.JogControl[1].5        := _parCmd.Control.E2_Pos;
  _command.JogControl[1].6        := _parCmd.Control.E3_Pos;
  _command.JogControl[1].7        := _parCmd.Control.E4_Pos;
  _command.JogControl[2].0        := _parCmd.Control.E5_Pos;
  _command.JogControl[2].1        := _parCmd.Control.E6_Pos;
  _command.JogControl[2].2        := _parCmd.Control.E1_Neg;
  _command.JogControl[2].3        := _parCmd.Control.E2_Neg;
  _command.JogControl[2].4        := _parCmd.Control.E3_Neg;
  _command.JogControl[2].5        := _parCmd.Control.E4_Neg;
  _command.JogControl[2].6        := _parCmd.Control.E5_Neg;
  _command.JogControl[2].7        := _parCmd.Control.E6_Neg;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.Enable
  CreateCommandPayload.AddBool(_command.Enable);
  // add command.Reserve 
  CreateCommandPayload.AddByte(0); {warning 'ToDo: Not in SRCI Spec V1.3'}
  
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.Mode);
  // add command.Reserve 
  CreateCommandPayload.AddByte(0); {warning 'ToDo: Not in SRCI Spec V1.3'}
  
  // add command.IncrementalTranslation
  CreateCommandPayload.AddReal(_command.IncrementalTranslation);
  // add command.IncrementalRotation
  CreateCommandPayload.AddReal(_command.IncrementalRotation);
  // add command.Override
  CreateCommandPayload.AddUint(_command.Override);
  // add command.JogControl[0]
  CreateCommandPayload.AddByte(_command.JogControl[0]);
  // add command.JogControl[1]
  CreateCommandPayload.AddByte(_command.JogControl[1]);
  // add command.JogControl[2]
  CreateCommandPayload.AddByte(_command.JogControl[2]);
  
  
  // Create log entry for Parameter start
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
    
  // Create log entry for Enable
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Enable = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.Enable));
  
  // Create log entry for ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ToolNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ToolNo));
  
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
  
  // Create log entry for JogMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JogMode = {1}',
                          Para1       :=  JOG_MODE_TO_STRING(_command.Mode));
  
  // Create log entry for IncrementalTranslation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.IncrementalTranslation = {1}',
                          Para1       :=  REAL_TO_STRING(_command.IncrementalTranslation));
  
  // Create log entry for IncrementalRotation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.IncrementalRotation = {1}',
                          Para1       :=  REAL_TO_STRING(_command.IncrementalRotation));
  
  // Create log entry for Override
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Override = {1}',
                          Para1       :=  UINT_TO_STRING(_command.Override));
  
  // Create log entry for JogControl[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JogControl[0] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.JogControl[0]));
  
  // Create log entry for JogControl[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JogControl[1] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.JogControl[1]));
  
  // Create log entry for JogControl[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JogControl[2] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.JogControl[2]));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_GroupJogFB';
  
  ExecMode := ExecutionMode.SEQUENCE_SECONDARY;

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q ) AND ( NOT Error)
         THEN
           // reset the rising edge
          _enable_R();       
    
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
  
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
                                           Active             := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;           
           END_CASE
  
           // Update Enable flag
           Enabled := _response.Status.0;
  
           // Update results
           OutCmd.DistanceReached := _response.Status.1;
           OutCmd.MotionActive    := _response.Status.2;        
           
           // Enabled ? -> Reset Busy flag  
           IF (Enabled)
           THEN  
             Busy := FALSE;
  				 END_IF
                   
           // Done, Aborted or Error ?
           IF  ( _response.State >= CmdMessageState.DONE ) 
           THEN
             // reset busy flag
             Enabled := FALSE; 
             // reset busy flag
             Busy := FALSE;   
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 2;
           END_IF
          END_IF
  
         // do not abort directly, so that the ParSeq update can be send
         IF ( _enable_F.Q ) 
         THEN
           // Set Busy flag
           Busy := TRUE;
           // trigger parameter update to disable FB
          _parameterUpdateInternal := TRUE;
           // reset the falling edge
          _enable_F();
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
  
        // Wait for response received or timeout or not Initialized
    02: IF ((   _responseReceived                                    ) OR 
            (     CheckTimeout(_timerCmd) = RobotLibraryConstants.OK ) OR 
            ( NOT AxesGroup.InternalData.Initialized                 ))
        THEN
          Reset();   
  	    END_IF
        
        // Wait for Enable = FALSE
    03: IF ( NOT Enable )
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
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-237: Received CMD payload (RC to PLC) of "GroupJog"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT      - ParSeq | State     
// Byte 01 : SINT       - AlarmMessageSeverity    
// Byte 02 : UINT       - AlarmMessageCode HB
// Byte 03 :            - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : USINT      -  Status 
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.Status
  _response.Status := ResponseData.GetByte();
  
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
                          
  // Create log entry for Status
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Status = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Status));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

