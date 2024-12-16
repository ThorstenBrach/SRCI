/// Enables the RC to apply user defined force/ torque through RA’s TCP movement
FUNCTION_BLOCK MC_ForceControlFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceControlFB                                       
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
  /// Set TRUE to activate ForceControl
  Enable             : BOOL;
  /// Command parameter 
  ParCmd             : ForceControlParCmd;      
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// - ForceStatus
  Valid              : BOOL;
  /// FB is being processed
  Busy               : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// Command output 
  OutCmd             : ForceControlOutCmd;    
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : ForceControlParCmd;
  /// command data to send
 _command           : ForceControlSendData;
  /// response data received
 _response          : ForceControlRecvData;      
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
// Table 6-719: Sent CMD payload (PLC to RC) of "ForceControl"
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
// Byte 004 : USINT      - ToolNo 
// Byte 005 : USINT      - FrameNo 
// Byte 006 : USINT      - ConnectionMode 
// Byte 007 : BOOL       - FixedSensor
// Byte 008 : REAL       - SensorFrame[0] HW HB
// Byte 009 :            - SensorFrame[0] HW LB
// Byte 010 :            - SensorFrame[0] LW HB
// Byte 011 :            - SensorFrame[0] LW LB
// Byte 012 : REAL       - SensorFrame[1] HW HB
// Byte 013 :            - SensorFrame[1] HW LB
// Byte 014 :            - SensorFrame[1] LW HB
// Byte 015 :            - SensorFrame[1] LW LB
// Byte 016 : REAL       - SensorFrame[2] HW HB
// Byte 017 :            - SensorFrame[2] HW LB
// Byte 018 :            - SensorFrame[2] LW HB
// Byte 019 :            - SensorFrame[2] LW LB
// Byte 020 : REAL       - SensorFrame[3] HW HB
// Byte 021 :            - SensorFrame[3] HW LB
// Byte 022 :            - SensorFrame[3] LW HB
// Byte 023 :            - SensorFrame[3] LW LB
// Byte 024 : REAL       - SensorFrame[4] HW HB
// Byte 025 :            - SensorFrame[4] HW LB
// Byte 026 :            - SensorFrame[4] LW HB
// Byte 027 :            - SensorFrame[4] LW LB
// Byte 028 : REAL       - SensorFrame[5] HW HB
// Byte 029 :            - SensorFrame[5] HW LB
// Byte 030 :            - SensorFrame[5] LW HB
// Byte 031 :            - SensorFrame[5] LW LB
// Byte 032 :            - CalibrationData
// Byte 033 :            - ReferenceType
// Byte 034 : REAL       - SensorValue[0] HW HB
// Byte 035 :            - SensorValue[0] HW LB
// Byte 036 :            - SensorValue[0] LW HB
// Byte 037 :            - SensorValue[0] LW LB
// Byte 038 : REAL       - SensorValue[1] HW HB
// Byte 039 :            - SensorValue[1] HW LB
// Byte 040 :            - SensorValue[1] LW HB
// Byte 041 :            - SensorValue[1] LW LB
// Byte 042 : REAL       - SensorValue[2] HW HB
// Byte 043 :            - SensorValue[2] HW LB
// Byte 044 :            - SensorValue[2] LW HB
// Byte 045 :            - SensorValue[2] LW LB
// Byte 046 : REAL       - SensorValue[3] HW HB
// Byte 047 :            - SensorValue[3] HW LB
// Byte 048 :            - SensorValue[3] LW HB
// Byte 049 :            - SensorValue[3] LW LB
// Byte 050 : REAL       - SensorValue[4] HW HB
// Byte 051 :            - SensorValue[4] HW LB
// Byte 052 :            - SensorValue[4] LW HB
// Byte 053 :            - SensorValue[4] LW LB
// Byte 054 : REAL       - SensorValue[5] HW HB
// Byte 055 :            - SensorValue[5] HW LB
// Byte 056 :            - SensorValue[5] LW HB
// Byte 057 :            - SensorValue[5] LW LB
// Byte 058 : REAL       - SensorValue[5] HW HB
// Byte 059 :            - SensorValue[5] HW LB
// Byte 060 :            - SensorValue[5] LW HB
// Byte 061 :            - SensorValue[5] LW LB
// Byte 062 : REAL       - TargetValue[0] HW HB
// Byte 063 :            - TargetValue[0] HW LB
// Byte 064 :            - TargetValue[0] LW HB
// Byte 065 :            - TargetValue[0] LW LB
// Byte 066 : REAL       - TargetValue[1] HW HB
// Byte 067 :            - TargetValue[1] HW LB
// Byte 068 :            - TargetValue[1] LW HB
// Byte 069 :            - TargetValue[1] LW LB
// Byte 070 : REAL       - TargetValue[2] HW HB
// Byte 071 :            - TargetValue[2] HW LB
// Byte 072 :            - TargetValue[2] LW HB
// Byte 073 :            - TargetValue[2] LW LB
// Byte 074 : REAL       - TargetValue[3] HW HB
// Byte 075 :            - TargetValue[3] HW LB
// Byte 076 :            - TargetValue[3] LW HB
// Byte 077 :            - TargetValue[3] LW LB
// Byte 078 : REAL       - TargetValue[4] HW HB
// Byte 079 :            - TargetValue[4] HW LB
// Byte 080 :            - TargetValue[4] LW HB
// Byte 081 :            - TargetValue[4] LW LB
// Byte 082 : REAL       - TargetValue[5] HW HB
// Byte 083 :            - TargetValue[5] HW LB
// Byte 084 :            - TargetValue[5] LW HB
// Byte 085 :            - TargetValue[5] LW LB
// Byte 086 : UINT       - MaxVelocity LW HB
// Byte 087 :            - MaxVelocity LW LB
// Byte 088 : REAL       - MaxDeviation[0] HW HB
// Byte 089 :            - MaxDeviation[0] HW LB
// Byte 090 :            - MaxDeviation[0] LW HB
// Byte 091 :            - MaxDeviation[0] LW LB
// Byte 092 : REAL       - MaxDeviation[1] HW HB
// Byte 093 :            - MaxDeviation[1] HW LB
// Byte 094 :            - MaxDeviation[1] LW HB
// Byte 095 :            - MaxDeviation[1] LW LB
// Byte 096 : REAL       - MaxDeviation[2] HW HB
// Byte 097 :            - MaxDeviation[2] HW LB
// Byte 098 :            - MaxDeviation[2] LW HB
// Byte 099 :            - MaxDeviation[2] LW LB
// Byte 100 : REAL       - MaxDeviation[3] HW HB
// Byte 101 :            - MaxDeviation[3] HW LB
// Byte 102 :            - MaxDeviation[3] LW HB
// Byte 103 :            - MaxDeviation[3] LW LB
// Byte 104 : REAL       - MaxDeviation[4] HW HB
// Byte 105 :            - MaxDeviation[4] HW LB
// Byte 106 :            - MaxDeviation[4] LW HB
// Byte 107 :            - MaxDeviation[4] LW LB
// Byte 108 : REAL       - MaxDeviation[5] HW HB
// Byte 109 :            - MaxDeviation[5] HW LB
// Byte 110 :            - MaxDeviation[5] LW HB
// Byte 111 :            - MaxDeviation[5] LW LB
// Byte 112 : USINT      - ErrorReaction
// Byte 113 : USINT      - ErrorReferenceType
// Byte 114 : REAL       - ErrorVector[0] HW HB
// Byte 115 :            - ErrorVector[0] HW LB
// Byte 116 :            - ErrorVector[0] LW HB
// Byte 117 :            - ErrorVector[0] LW LB
// Byte 118 : REAL       - ErrorVector[1] HW HB
// Byte 119 :            - ErrorVector[1] HW LB
// Byte 120 :            - ErrorVector[1] LW HB
// Byte 121 :            - ErrorVector[1] LW LB
// Byte 122 : REAL       - ErrorVector[2] HW HB
// Byte 123 :            - ErrorVector[2] HW LB
// Byte 124 :            - ErrorVector[2] LW HB
// Byte 125 :            - ErrorVector[2] LW LB
// Byte 126 : REAL       - ErrorVector[3] HW HB
// Byte 127 :            - ErrorVector[3] HW LB
// Byte 128 :            - ErrorVector[3] LW HB
// Byte 129 :            - ErrorVector[3] LW LB
// Byte 130 : REAL       - ErrorVector[4] HW HB
// Byte 131 :            - ErrorVector[4] HW LB
// Byte 132 :            - ErrorVector[4] LW HB
// Byte 133 :            - ErrorVector[4] LW LB
// Byte 134 : REAL       - ErrorVector[5] HW HB
// Byte 135 :            - ErrorVector[5] HW LB
// Byte 136 :            - ErrorVector[5] LW HB
// Byte 137 :            - ErrorVector[5] LW LB
// Byte 138 : USINT      - ErrorToolNo
// Byte 139 : USINT      - ErrorFrameNo
// Byte 140 : BYTE       - CompliantAxes
// --------------------------

  // set command parameter 
  _command.CmdTyp             :=  CmdType.ForceControl;
  _command.ExecMode           :=  ExecMode;
  _command.ParSeq             := _command.ParSeq;
  _command.Priority           :=  Priority;
  _command.ToolNo             := _parCmd.ToolNo;
  _command.FrameNo            := _parCmd.FrameNo;
  _command.ConnectionMode     := _parCmd.ConnectionMode;
  _command.FixedSensor.0      := _parCmd.FixedSensor;
  _command.SensorFrame        := _parCmd.SensorFrame;
  _command.CalibrationData    := _parCmd.CalibrationData;
  _command.ReferenceType      := _parCmd.ReferenceType;
  _command.SensorValue        := _parCmd.SensorValue;
  _command.TargetValue        := _parCmd.TargetValue;
  _command.MaxVelocity        := _parCmd.MaxVelocity;
  _command.MaxDeviation       := _parCmd.MaxDeviation;
  _command.ErrorReaction      := _parCmd.ErrorReaction;
  _command.ErrorReferenceType := _parCmd.ErrorReferenceType;
  _command.ErrorVector        := _parCmd.ErrorVector;
  _command.ErrorToolNo        := _parCmd.ErrorToolNo;
  _command.ErrorFrameNo       := _parCmd.ErrorFrameNo;
  _command.CompliantAxes      := _parCmd.CompliantAxes;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  
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
  // add command.CalibrationData
  CreateCommandPayload.AddUInt(_command.ReferenceType);
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
  // add command.TargetValue[0]
  CreateCommandPayload.AddReal(_command.TargetValue[0]);
  // add command.TargetValue[1]
  CreateCommandPayload.AddReal(_command.TargetValue[1]);
  // add command.TargetValue[2]
  CreateCommandPayload.AddReal(_command.TargetValue[2]);
  // add command.TargetValue[3]
  CreateCommandPayload.AddReal(_command.TargetValue[3]);
  // add command.TargetValue[4]
  CreateCommandPayload.AddReal(_command.TargetValue[4]);
  // add command.TargetValue[5]
  CreateCommandPayload.AddReal(_command.TargetValue[5]);
  // add command.MaxVelocity
  CreateCommandPayload.AddUInt(_command.MaxVelocity);
  // add command.MaxDeviation[0]
  CreateCommandPayload.AddReal(_command.MaxDeviation[0]);
  // add command.MaxDeviation[1]
  CreateCommandPayload.AddReal(_command.MaxDeviation[1]);
  // add command.MaxDeviation[2]
  CreateCommandPayload.AddReal(_command.MaxDeviation[2]);
  // add command.MaxDeviation[3]
  CreateCommandPayload.AddReal(_command.MaxDeviation[3]);
  // add command.MaxDeviation[4]
  CreateCommandPayload.AddReal(_command.MaxDeviation[4]);
  // add command.MaxDeviation[5]
  CreateCommandPayload.AddReal(_command.MaxDeviation[5]);
  // add command.ErrorReaction
  CreateCommandPayload.AddUsint(_command.ErrorReaction);
  // add command.ErrorReferenceType
  CreateCommandPayload.AddUsint(_command.ErrorReferenceType);
  // add command.ErrorVector[0]
  CreateCommandPayload.AddReal(_command.ErrorVector[0]);
  // add command.ErrorVector[1]
  CreateCommandPayload.AddReal(_command.ErrorVector[1]);
  // add command.ErrorVector[2]
  CreateCommandPayload.AddReal(_command.ErrorVector[2]);
  // add command.ErrorVector[3]
  CreateCommandPayload.AddReal(_command.ErrorVector[3]);
  // add command.ErrorVector[4]
  CreateCommandPayload.AddReal(_command.ErrorVector[4]);
  // add command.ErrorVector[5]
  CreateCommandPayload.AddReal(_command.ErrorVector[5]);
  // add command.ErrorToolNo
  CreateCommandPayload.AddUsint(_command.ErrorToolNo);
  // add command.ErrorFrameNo
  CreateCommandPayload.AddUsint(_command.ErrorFrameNo);
  // add command.CompliantAxes
  CreateCommandPayload.AddByte(_command.CompliantAxes);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ForceControlFB';

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
// Table 6-720: Received CMD payload (RC to PLC) of "ForceControl"
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
// Byte 04 : USINT      - ForceStatus 
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
  
  // Get Response.ForceStatus
  _response.ForceStatus := ResponseData.GetByte();

END_METHOD

