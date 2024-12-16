/// Commands specified reaction from RA when defined force/torque detected
FUNCTION_BLOCK MC_ForceLimitFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceLimitFB                                       
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
  /// Set TRUE to activate force limiting
  Enable            : BOOL;
  /// Command parameter 
  ParCmd            : ForceLimitParCmd;   
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values
  Valid             : BOOL;
  /// FB is being processed
  Busy              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// Command output 
  OutCmd            : ForceLimitOutCmd;      
END_VAR


VAR
  /// internal copy of command parameter 
 _parCmd            : ForceLimitParCmd;
  /// command data to send
 _command           : ForceLimitSendData;
  /// response data received
 _response          : ForceLimitRecvData;      
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
  CheckParameterChanged := ( MemCmp(ADR(ParCmd), ADR(_parCmd), SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
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

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-727: Sent CMD payload (PLC to RC) of "ForceLimit"
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
// Byte 004 : SINT       - EmitterID[0] 
// Byte 005 : SINT       - EmitterID[1] 
// Byte 006 : SINT       - EmitterID[2] 
// Byte 007 : SINT       - EmitterID[3]
// Byte 008 : SINT       - ListenerID
// Byte 009 : BYTE       - Reserve
// Byte 010 : USINT      - ToolNo
// Byte 011 : USINT      - FrameNo
// Byte 012 : USINT      - ConnectionMode
// Byte 013 : BOOL       - FixedSensor
// Byte 014 : REAL       - SensorFrame[0] HW HB
// Byte 015 :            - SensorFrame[0] HW LB
// Byte 016 :            - SensorFrame[0] LW HB
// Byte 017 :            - SensorFrame[0] LW LB
// Byte 018 : REAL       - SensorFrame[1] HW HB
// Byte 019 :            - SensorFrame[1] HW LB
// Byte 020 :            - SensorFrame[1] LW HB
// Byte 021 :            - SensorFrame[1] LW LB
// Byte 022 : REAL       - SensorFrame[2] HW HB
// Byte 023 :            - SensorFrame[2] HW LB
// Byte 024 :            - SensorFrame[2] LW HB
// Byte 025 :            - SensorFrame[2] LW LB
// Byte 026 : REAL       - SensorFrame[3] HW HB
// Byte 027 :            - SensorFrame[3] HW LB
// Byte 028 :            - SensorFrame[3] LW HB
// Byte 029 :            - SensorFrame[3] LW LB
// Byte 030 : REAL       - SensorFrame[4] HW HB
// Byte 031 :            - SensorFrame[4] HW LB
// Byte 032 :            - SensorFrame[4] LW HB
// Byte 033 :            - SensorFrame[4] LW LB
// Byte 034 : REAL       - SensorFrame[5] HW HB
// Byte 035 :            - SensorFrame[5] HW LB
// Byte 036 :            - SensorFrame[5] LW HB
// Byte 037 :            - SensorFrame[5] LW LB
// Byte 038 : USINT      - CalibrationData
// Byte 039 : USINT      - ReferenceType
// Byte 040 : REAL       - SensorValue[0] HW HB
// Byte 041 :            - SensorValue[0] HW LB
// Byte 042 :            - SensorValue[0] LW HB
// Byte 043 :            - SensorValue[0] LW LB
// Byte 044 : REAL       - SensorValue[1] HW HB
// Byte 045 :            - SensorValue[1] HW LB
// Byte 046 :            - SensorValue[1] LW HB
// Byte 047 :            - SensorValue[1] LW LB
// Byte 048 : REAL       - SensorValue[2] HW HB
// Byte 049 :            - SensorValue[2] HW LB
// Byte 050 :            - SensorValue[2] LW HB
// Byte 051 :            - SensorValue[2] LW LB
// Byte 052 : REAL       - SensorValue[3] HW HB
// Byte 053 :            - SensorValue[3] HW LB
// Byte 054 :            - SensorValue[3] LW HB
// Byte 055 :            - SensorValue[3] LW LB
// Byte 056 : REAL       - SensorValue[4] HW HB
// Byte 057 :            - SensorValue[4] HW LB
// Byte 058 :            - SensorValue[4] LW HB
// Byte 059 :            - SensorValue[4] LW LB
// Byte 060 : REAL       - SensorValue[5] HW HB
// Byte 061 :            - SensorValue[5] HW LB
// Byte 062 :            - SensorValue[5] LW HB
// Byte 063 :            - SensorValue[5] LW LB
// Byte 064 : REAL       - Limit[0] HW HB
// Byte 065 :            - Limit[0] HW LB
// Byte 066 :            - Limit[0] LW HB
// Byte 067 :            - Limit[0] LW LB
// Byte 068 : REAL       - Limit[1] HW HB
// Byte 069 :            - Limit[1] HW LB
// Byte 070 :            - Limit[1] LW HB
// Byte 071 :            - Limit[1] LW LB
// Byte 072 : REAL       - Limit[2] HW HB
// Byte 073 :            - Limit[2] HW LB
// Byte 074 :            - Limit[2] LW HB
// Byte 075 :            - Limit[2] LW LB
// Byte 076 : REAL       - Limit[3] HW HB
// Byte 077 :            - Limit[3] HW LB
// Byte 078 :            - Limit[3] LW HB
// Byte 079 :            - Limit[3] LW LB
// Byte 080 : REAL       - Limit[4] HW HB
// Byte 081 :            - Limit[4] HW LB
// Byte 082 :            - Limit[4] LW HB
// Byte 083 :            - Limit[4] LW LB
// Byte 084 : REAL       - Limit[5] HW HB
// Byte 085 :            - Limit[5] HW LB
// Byte 086 :            - Limit[5] LW HB
// Byte 087 :            - Limit[5] LW LB


// --------------------------

  // set command parameter 
  _command.CmdTyp          :=  CmdType.ForceLimit;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.EmitterID[0]    := _parCmd.EmitterID;
  _command.ListenerID      :=  0; {warning 'ToDo'} 
  _command.Reserve         :=  0; 
  _command.ToolNo          := _parCmd.ToolNo;
  _command.FrameNo         := _parCmd.FrameNo;
  _command.ConnectionMode  := _parCmd.ConnectionMode;
  _command.FixedSensor.0   := _parCmd.FixedSensor;
  _command.SensorFrame     := _parCmd.SensorFrame;
  _command.CalibrationData := _parCmd.CalibrationData;
  _command.ReferenceType   := _parCmd.ReferenceType;
  _command.SensorValue     := _parCmd.SensorValue;
  _command.ForceLimit      := _parCmd.ForceLimit;  
  
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  
  // add command.EmitterID[0]
  CreateCommandPayload.AddSint(_command.EmitterID[0]);
  // add command.EmitterID[1]
  CreateCommandPayload.AddSint(_command.EmitterID[1]);
  // add command.EmitterID[2]
  CreateCommandPayload.AddSint(_command.EmitterID[2]);
  // add command.EmitterID[3]
  CreateCommandPayload.AddSint(_command.EmitterID[3]);
  // add command.ListenerID
  CreateCommandPayload.AddSint(_command.ListenerID);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.ConnectionMode
  CreateCommandPayload.AddUsint(_command.ConnectionMode);
  // add command.FixedSensor
  CreateCommandPayload.AddByte(_command.FixedSensor);
  // add command.SensorFrame[0]
  CreateCommandPayload.AddReal(_command.SensorFrame[0]);
  // add command.SensorFrame[1]
  CreateCommandPayload.AddReal(_command.SensorFrame[1]);
  // add command.SensorFrame[2]
  CreateCommandPayload.AddReal(_command.SensorFrame[2]);
  // add command.SensorFrame[3]
  CreateCommandPayload.AddReal(_command.SensorFrame[3]);
  // add command.SensorFrame[4]
  CreateCommandPayload.AddReal(_command.SensorFrame[4]);
  // add command.SensorFrame[5]
  CreateCommandPayload.AddReal(_command.SensorFrame[5]);
  // add command.CalibrationData
  CreateCommandPayload.AddUsint(_command.CalibrationData);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.SensorValue[0]
  CreateCommandPayload.AddReal(_command.SensorValue[0]);
  // add command.SensorValue[1]
  CreateCommandPayload.AddReal(_command.SensorValue[1]);
  // add command.SensorValue[2]
  CreateCommandPayload.AddReal(_command.SensorValue[2]);
  // add command.SensorValue[3]
  CreateCommandPayload.AddReal(_command.SensorValue[3]);
  // add command.SensorValue[4]
  CreateCommandPayload.AddReal(_command.SensorValue[4]);
  // add command.SensorValue[5]
  CreateCommandPayload.AddReal(_command.SensorValue[5]);
  
  // add command.ForceLimit[0]
  CreateCommandPayload.AddReal(_command.ForceLimit[0]);
  // add command.ForceLimit[1]
  CreateCommandPayload.AddReal(_command.ForceLimit[1]);
  // add command.ForceLimit[2]
  CreateCommandPayload.AddReal(_command.ForceLimit[2]);
  // add command.ForceLimit[3]
  CreateCommandPayload.AddReal(_command.ForceLimit[3]);
  // add command.ForceLimit[4]
  CreateCommandPayload.AddReal(_command.ForceLimit[4]);
  // add command.ForceLimit[5]
  CreateCommandPayload.AddReal(_command.ForceLimit[5]);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ForceLimitFB';

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
           MemSet(ADR(OutCmd),0,SIZEOF(OutCmd));         
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
                                           Valid              := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN         
             // Update results
             OutCmd.ForceStatus.ForceControlEnabled         := _response.ForceStatus.0;
             OutCmd.ForceStatus.ForceLimitEnabled           := _response.ForceStatus.1;
             OutCmd.ForceStatus.ApplyingForce               := _response.ForceStatus.2;
             OutCmd.ForceStatus.MaxDeviationReached         := _response.ForceStatus.3;
             OutCmd.ForceStatus.SpecifiedForceTorqueReached := _response.ForceStatus.4;
             OutCmd.ForceStatus.SpecifiedForceLimitReached  := _response.ForceStatus.5;
             OutCmd.ForceStatus.Bit06                       := _response.ForceStatus.6;
             OutCmd.ForceStatus.Bit07                       := _response.ForceStatus.7;  
             OutCmd.FollowID                                := _response.OriginID; {warning 'ToDo'}
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
// Table 6-728: Received CMD payload (RC to PLC) of "ForceLimit"
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
// Byte 04 : USINT      - InvocationCounter 
// Byte 05 : USINT      - Reserved 
// Byte 06 : INT        - OriginID LW HB
// Byte 07 :            - OriginID LW LB 
// Byte 08 : BYTE       - ForceStatus 
// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RecvData;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserved
  _response.Reserved := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
  // Get Response.ForceStatus
  _response.ForceStatus := ResponseData.GetByte();

END_METHOD

