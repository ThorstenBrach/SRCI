/// Activate superimposed motion of TCP to defined motion
FUNCTION_BLOCK MC_MoveSuperImposedDynamicFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedDynamicFB                                       
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
  /// Start of the command at the rising edge
  Enable            : BOOL;  
  /// command parameter 
  ParCmd            : MoveSuperImposedDynamicParCmd;
END_VAR

VAR_OUTPUT
  /// FB is being processed
  Busy              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// The command takes control of the motion of the according axis group
  Active            : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command outputs
  OutCmd             : MoveSuperImposedDynamicOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : MoveSuperImposedDynamicParCmd;
  /// command data to send
 _command           : MoveSuperImposedDynamicSendData;
  /// response data received
 _response          : MoveSuperImposedDynamicRecvData;     
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
// Table 6-470: Sent CMD payload (PLC to RC) of "MoveSuperImposedDynamic"
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
// Byte 00 : UINT  Type;
// Byte 01 :       Type;
// Byte 02 : USINT Reserved ExecutionMode;
// Byte 03 : USINT ParSeq Priority;
// Byte 04 : UINT  VelocityRate;
// Byte 05 :       VelocityRate;
// Byte 06 :       VelocityRate;
// Byte 07 : UINT  AccelerationRate;
// Byte 08 :       AccelerationRate;
// Byte 09 :       AccelerationRate;
// Byte 10 : UINT  DecelerationRate;
// Byte 11 :       DecelerationRate;
// Byte 12 :       DecelerationRate;
// Byte 13 : UINT  JerkRate;
// Byte 14 :       JerkRate;
// Byte 15 :       JerkRate;
// Byte 16 : USINT ToolNo;
// Byte 17 : USINT FrameNo;
// Byte 18 : REAL  X;
// Byte 19 :       X;
// Byte 20 :       X;
// Byte 21 :       X;
// Byte 22 : REAL  Offset.X;
// Byte 23 :       Offset.X;
// Byte 24 :       Offset.X;
// Byte 25 :       Offset.X;
// Byte 26 : REAL  Offset.Y;
// Byte 27 :       Offset.Y;
// Byte 28 :       Offset.Y;
// Byte 29 :       Offset.Y;
// Byte 30 : REAL  Offset.Z;
// Byte 31 :       Offset.Z;
// Byte 32 :       Offset.Z;
// Byte 33 :       Offset.Z;
// Byte 34 : REAL  Offset.RX;
// Byte 35 :       Offset.RX;
// Byte 36 :       Offset.RX;
// Byte 37 :       Offset.RX;
// Byte 38 : REAL  Offset.RY;
// Byte 39 :       Offset.RY;
// Byte 40 :       Offset.RY;
// Byte 41 :       Offset.RY;
// Byte 42 : BYTE  - - - - - W E S;
// Byte 43 : BYTE  Reserved;
// Byte 44 : BYTE  Offset.TurnNumber[0];
// Byte 45 : BYTE  Offset.TurnNumber[1];
// Byte 46 : BYTE  Offset.TurnNumber[2];
// Byte 47 : BYTE  Offset.TurnNumber[3];
// Byte 48 : REAL  Offset.E1;
// Byte 49 :       Offset.E1;
// Byte 50 :       Offset.E1;
// Byte 51 :       Offset.E1;
// Byte 52 : USINT ReferenceType;
// Byte 53 : USINT InterpolationMode;
// Byte 54 : REAL  Offset.E2;
// Byte 55 :       Offset.E2;
// Byte 56 :       Offset.E2;
// Byte 57 :       Offset.E2;
// Byte 58 : REAL  Offset.E3;
// Byte 59 :       Offset.E3;
// Byte 60 :       Offset.E3;
// Byte 61 :       Offset.E3;
// Byte 62 : REAL  Offset.E4;
// Byte 63 :       Offset.E4;
// Byte 64 :       Offset.E4;
// Byte 65 :       Offset.E4;
// Byte 66 : REAL  Offset.E5;
// Byte 67 :       Offset.E5;
// Byte 68 :       Offset.E5;
// Byte 69 :       Offset.E5;
// Byte 70 : REAL  Offset.E6;
// Byte 71 :       Offset.E6;
// Byte 72 :       Offset.E6;
// Byte 73 :       Offset.E6;

  // set command parameter 
  _command.CmdTyp               :=  CmdType.MoveSuperImposedDynamic;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  _command.VelocityDiffRate     :=  REAL_TO_UINT(_parCmd.VelocityDiffRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationDiffRate :=  REAL_TO_UINT(_parCmd.AccelerationDiffRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationDiffRate :=  REAL_TO_UINT(_parCmd.DecelerationDiffRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkDiffRate         :=  REAL_TO_UINT(_parCmd.JerkDiffRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo               := _parCmd.ToolNo;
  _command.FrameNo              := _parCmd.FrameNo;
  _command.Reserve_X            := 0.0;
  _command.Offset               := _parCmd.Offset;
  _command.ReferenceType        := _parCmd.ReferenceType;
  _command.InterpolationMode    := _parCmd.InterpolationMode;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.VelocityDiffRate
  CreateCommandPayload.AddUint(_command.VelocityDiffRate);
  // add command.AccelerationDiffRate
  CreateCommandPayload.AddUint(_command.AccelerationDiffRate);
  // add command.DecelerationDiffRate
  CreateCommandPayload.AddUint(_command.DecelerationDiffRate);
  // add command.JerkDiffRate
  CreateCommandPayload.AddUint(_command.JerkDiffRate);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Reserve_X
  CreateCommandPayload.AddReal(_command.Reserve_X);
  // add command.Offset.X
  CreateCommandPayload.AddReal(_command.Offset.X);
  // add command.Offset.Y
  CreateCommandPayload.AddReal(_command.Offset.Y);
  // add command.Offset.Z
  CreateCommandPayload.AddReal(_command.Offset.Z);
  // add command.Offset.Rx
  CreateCommandPayload.AddReal(_command.Offset.Rx);
  // add command.Offset.Ry
  CreateCommandPayload.AddReal(_command.Offset.Ry);
  // add command.Offset.Rz
  CreateCommandPayload.AddReal(_command.Offset.Rz);
  // add command.Offset.Config
  CreateCommandPayload.AddArmConfig(_command.Offset.Config);
  // add command.Offset.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Offset.TurnNumber);
  // add command.Offset.E1
  CreateCommandPayload.AddReal(_command.Offset.E1);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.InterpolationMode
  CreateCommandPayload.AddUsint(_command.InterpolationMode);
  // add command.Offset.E2
  CreateCommandPayload.AddReal(_command.Offset.E2);
  // add command.Offset.E3
  CreateCommandPayload.AddReal(_command.Offset.E3);
  // add command.Offset.E4
  CreateCommandPayload.AddReal(_command.Offset.E4);
  // add command.Offset.E5
  CreateCommandPayload.AddReal(_command.Offset.E5);
  // add command.Offset.E6
  CreateCommandPayload.AddReal(_command.Offset.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveSuperImposedDynamicFB';

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
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.OffsetReached     := _response.OffsetReached;
             OutCmd.Progress          := _response.Progress;
             OutCmd.RemainingDistance := _response.RemainingDistance;
             
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
    Busy               := FALSE;
    CommandBuffered    := FALSE;
    Error              := FALSE;
    ErrorID            := 0;
    WarningID          := 0;
    InfoID             := 0;  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-471: Received CMD payload (RC to PLC) of "MoveSuperImposedDynamic"
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
// Byte 04 : UINT  - Progress HB
// Byte 05 : UINT  - Progress LB
// Byte 06 : REAL  - RemainingDistance HW HB
// Byte 07 :       - RemainingDistance HW LB
// Byte 08 :       - RemainingDistance LW HB
// Byte 09 :       - RemainingDistance LW LB
// Byte 10 : BOOL  - OffsetReached
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
  
  // Get Response.Progress
  _response.Progress := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance := ResponseData.GetReal();
  // Get Response.OffsetReached
  _response.OffsetReached := ResponseData.GetBool();

END_METHOD
