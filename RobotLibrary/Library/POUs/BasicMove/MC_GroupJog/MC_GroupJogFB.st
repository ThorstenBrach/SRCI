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
  _command.Override               := _parCmd.Override;
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
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.Enable
  CreateCommandPayload.AddBool(_command.Enable);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.Mode);
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
  
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;           
           END_CASE
  
           // Update results
           Enabled                := _response.Status.0;
           OutCmd.DistanceReached := _response.Status.1;
           OutCmd.MotionActive    := _response.Status.2;
           
                   
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
            _stepCmd := _stepCmd + 1;
           END_IF
          END_IF
  
          // Check enable flag 
          IF (_enable_F.Q)
          THEN
            // trigger parameter update to disable GroupJog
            SysDepMemSet( pDest := ADR(_parCmd), Value := 0, DataLen := SIZEOF(_parCmd));
            // reset the falling edge
           _enable_F();       
          END_IF
  
    03:  IF (NOT Enable)
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
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.Status
  _response.Status := ResponseData.GetByte();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

