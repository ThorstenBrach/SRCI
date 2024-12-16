/// Set trigger in defined position of path (L = Linear Path) (cartesian) switch periphery.
FUNCTION_BLOCK MC_MoveLinearCamFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveLinearCamFB                                       
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
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands
  AbortingMode       : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter
  ParCmd             : MoveLinearCamParCmd;       
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command takes control of the motion of the according axis group
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : MoveLinearCamOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : MoveLinearCamParCmd;
  /// command data to send
 _command            : MoveLinearCamSendData;
  /// response data received
 _response           : MoveLinearCamRecvData;      
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-523: Sent CMD payload (PLC to RC) of "MoveLinearCam"
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
// Byte 04 : UINT  - VelocityRate HW HB
// Byte 05 :       - VelocityRate HW LB
// Byte 06 : UINT  - AccelerationRate HW HB
// Byte 07 :       - AccelerationRate HW LB
// Byte 08 : UINT  - DecelerationRate HW HB
// Byte 09 :       - DecelerationRate HW LB
// Byte 10 : UINT  - JerkRate HW HB
// Byte 11 :       - JerkRate HW LB
// Byte 12 : USINT - ToolNo
// Byte 13 : USINT - FrameNo
// Byte 14 : USINT - BlendingMode
// Byte 15 : USINT - OriMode
// Byte 16 : REAL  - BlendingParameter[0] HW HB
// Byte 17 :       - BlendingParameter[0] HW LB
// Byte 18 :       - BlendingParameter[0] LW HB
// Byte 19 :       - BlendingParameter[0] LW LB
// Byte 20 : REAL  - BlendingParameter[1] HW HB
// Byte 21 :       - BlendingParameter[1] HW LB
// Byte 22 :       - BlendingParameter[1] LW HB
// Byte 23 :       - BlendingParameter[1] LW LB
// Byte 24 : REAL  - Position.X HW HB
// Byte 25 :       - Position.X HW LB
// Byte 26 :       - Position.X LW HB
// Byte 27 :       - Position.X LW LB
// Byte 28 : REAL  - Position.Y HW HB
// Byte 29 :       - Position.Y HW LB
// Byte 30 :       - Position.Y LW HB
// Byte 31 :       - Position.Y LW LB
// Byte 32 : REAL  - Position.Z HW HB
// Byte 33 :       - Position.Z HW LB
// Byte 34 :       - Position.Z LW HB
// Byte 35 :       - Position.Z LW LB
// Byte 36 : REAL  - Position.RX HW HB
// Byte 37 :       - Position.RX HW LB
// Byte 38 :       - Position.RX LW HB
// Byte 39 :       - Position.RX LW LB
// Byte 40 : REAL  - Position.RY HW HB
// Byte 41 :       - Position.RY HW LB
// Byte 42 :       - Position.RY LW HB
// Byte 43 :       - Position.RY LW LB
// Byte 44 : REAL  - Position.RZ HW HB
// Byte 45 :       - Position.RZ HW LB
// Byte 46 :       - Position.RZ LW HB
// Byte 47 :       - Position.RZ LW LB
// Byte 48 : BYTE  - W E S
// Byte 49 : BYTE  - Reserved
// Byte 50 : BYTE  - Position.TurnNumber[0]
// Byte 51 : BYTE  - Position.TurnNumber[1]
// Byte 52 : BYTE  - Position.TurnNumber[2]
// Byte 53 : BYTE  - Position.TurnNumber[3]
// Byte 54 : REAL  - Position.E1 HW HB
// Byte 55 :       - Position.E1 HW LB
// Byte 56 :       - Position.E1 LW HB
// Byte 57 :       - Position.E1 LW LB
// Byte 58 : UINT  - TriggerDelay HW HB
// Byte 59 :       - TriggerDelay HW LB
// Byte 60 : REAL  - TriggerDistance HW HB
// Byte 61 :       - TriggerDistance HW LB
// Byte 62 :       - TriggerDistance LW HB
// Byte 63 :       - TriggerDistance LW LB
// Byte 64 : USINT - Index
// Byte 65 : BOOL  - RelativePosition
// Byte 66 : BYTE  - OutputBitmask
// Byte 67 : BYTE  - Value
// Byte 68 : BYTE  - ConfigMode[0]
// Byte 69 : BYTE  - ConfigMode[1]
// Byte 70 : BOOL  - Manipulation
// Byte 71 : USINT - TurnMode
// Byte 72 : UINT  - Time HW HB
// Byte 73 :       - Time HW LB
// Byte 74 : REAL  - Position.E2 HW HB
// Byte 75 :       - Position.E2 HW LB
// Byte 76 :       - Position.E2 LW HB
// Byte 77 :       - Position.E2 LW LB
// Byte 78 : REAL  - Position.E3 HW HB
// Byte 79 :       - Position.E3 HW LB
// Byte 80 :       - Position.E3 LW HB
// Byte 81 :       - Position.E3 LW LB
// Byte 82 : REAL  - Position.E4 HW HB
// Byte 83 :       - Position.E4 HW LB
// Byte 84 :       - Position.E4 LW HB
// Byte 85 :       - Position.E4 LW LB
// Byte 86 : REAL  - Position.E5 HW HB
// Byte 87 :       - Position.E5 HW LB
// Byte 88 :       - Position.E5 LW HB
// Byte 89 :       - Position.E5 LW LB
// Byte 90 : REAL  - Position.E6 HW HB
// Byte 91 :       - Position.E6 HW LB
// Byte 92 :       - Position.E6 LW HB
// Byte 93 :       - Position.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.MoveLinearCam;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.VelocityRate      := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate  := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate  := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate          := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo            := _parCmd.ToolNo;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.OriMode           := _parcmd.OriMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.Position          := _parCmd.Position;
  _command.TriggerDelay      := _parCmd.TriggerDelay;
  _command.TriggerDistance   := _parCmd.TriggerDistance;
  _command.Index             := _parCmd.Index;
  _command.RelativePosition  := _parCmd.RelativePosition;
  _command.OutputBitmask     := _parCmd.OutputBitmask;
  _command.Value             := _parCmd.Value;
  _command.ConfigMode[0].0   := _parCmd.ConfigMode.Shoulder.0;
  _command.ConfigMode[0].1   := _parCmd.ConfigMode.Shoulder.1;
  _command.ConfigMode[0].2   := _parCmd.ConfigMode.Shoulder.2;
  _command.ConfigMode[0].3   := _parCmd.ConfigMode.Shoulder.3;
  _command.ConfigMode[0].4   := _parCmd.ConfigMode.Elbow.0;
  _command.ConfigMode[0].5   := _parCmd.ConfigMode.Elbow.1;
  _command.ConfigMode[0].6   := _parCmd.ConfigMode.Elbow.2;
  _command.ConfigMode[0].7   := _parCmd.ConfigMode.Elbow.3;
  _command.ConfigMode[1].0   := _parCmd.ConfigMode.Wrist.0;
  _command.ConfigMode[1].1   := _parCmd.ConfigMode.Wrist.1;
  _command.ConfigMode[1].2   := _parCmd.ConfigMode.Wrist.2;
  _command.ConfigMode[1].3   := _parCmd.ConfigMode.Wrist.3;
  _command.ConfigMode[1].4   := FALSE;
  _command.ConfigMode[1].5   := FALSE;
  _command.ConfigMode[1].6   := FALSE;
  _command.ConfigMode[1].7   := FALSE;
  _command.Manipulation      := _parCmd.Manipulation;
  _command.TurnMode          := _parCmd.TurnMode;
  _command.MoveTime          := TIME_TO_UINT(_parCmd.MoveTime);
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.VelocityRate
  CreateCommandPayload.AddUint(_command.VelocityRate);
  // add command.AccelerationRate
  CreateCommandPayload.AddUint(_command.AccelerationRate);
  // add command.DecelerationRate
  CreateCommandPayload.AddUint(_command.DecelerationRate);
  // add command.JerkRate
  CreateCommandPayload.AddUint(_command.JerkRate);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.BlendingMode
  CreateCommandPayload.AddUsint(_command.BlendingMode);
  // add command.OriMode
  CreateCommandPayload.AddUsint(_command.OriMode);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.Position.X
  CreateCommandPayload.AddReal(_command.Position.X);
  // add command.Position.Y
  CreateCommandPayload.AddReal(_command.Position.Y);
  // add command.Position.Z
  CreateCommandPayload.AddReal(_command.Position.Z);
  // add command.Position.Rx
  CreateCommandPayload.AddReal(_command.Position.Rx);
  // add command.Position.Ry
  CreateCommandPayload.AddReal(_command.Position.Ry);
  // add command.Position.Rz
  CreateCommandPayload.AddReal(_command.Position.Rz);
  // add command.Position.E1
  CreateCommandPayload.AddReal(_command.Position.E1);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.Position.E2
  CreateCommandPayload.AddReal(_command.Position.E2);
  // add command.Position.E3
  CreateCommandPayload.AddReal(_command.Position.E3);
  // add command.Position.E4
  CreateCommandPayload.AddReal(_command.Position.E4);
  // add command.Position.E5
  CreateCommandPayload.AddReal(_command.Position.E5);
  // add command.Position.E6
  CreateCommandPayload.AddReal(_command.Position.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveLinearCamFB';

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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : Active             := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.Progress          := _response.Progress;
             OutCmd.RemainingDistance := _response.RemainingDistance;
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
// Table 6-524: Received CMD payload (RC to PLC) of "MoveLinearCam"
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
// Byte 04 : UINT    - Progress HW HB
// Byte 05 :         - Progress HW LB
// Byte 06 : REAL    - RemainingDistance HW HB
// Byte 07 :         - RemainingDistance HW LB
// Byte 08 :         - RemainingDistance LW HB
// Byte 09 :         - RemainingDistance LW LB
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

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Active             := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

