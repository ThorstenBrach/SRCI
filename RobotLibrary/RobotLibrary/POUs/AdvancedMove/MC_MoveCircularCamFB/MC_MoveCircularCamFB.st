/// Set a trigger in a defined position of a circular path.
FUNCTION_BLOCK MC_MoveCircularCamFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveCircularCamFB                                       
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
  ParCmd             : MoveCircularCamParCmd;       
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
  OutCmd             : MoveCircularCamOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveCircularCamParCmd;
  /// command data to send
 _command            : MoveCircularCamSendData;
  /// response data received
 _response           : MoveCircularCamRecvData;      
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
// Table 6-541: Sent CMD payload (PLC to RC) of "MoveCircularCam"
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
// Byte 04 : UINT       - VelocityRate HW HB
// Byte 05 :            - VelocityRate HW LB
// Byte 06 : UINT       - AccelerationRate HW HB
// Byte 07 :            - AccelerationRate HW LB
// Byte 08 : UINT       - DecelerationRate HW HB
// Byte 09 :            - DecelerationRate HW LB
// Byte 10 : UINT       - JerkRate HW HB
// Byte 11 :            - JerkRate HW LB
// Byte 12 : USINT      - ToolNo
// Byte 13 : USINT      - FrameNo
// Byte 14 : USINT      - BlendingMode
// Byte 15 : USINT      - OriMode
// Byte 16 : REAL       - BlendingParameter[0] HW HB
// Byte 17 :            - BlendingParameter[0] HW LB
// Byte 18 :            - BlendingParameter[0] LW HB
// Byte 19 :            - BlendingParameter[0] LW LB
// Byte 20 : REAL       - BlendingParameter[1] HW HB
// Byte 21 :            - BlendingParameter[1] HW LB
// Byte 22 :            - BlendingParameter[1] LW HB
// Byte 23 :            - BlendingParameter[1] LW LB
// Byte 24 : REAL       - AuxPoint.X HW HB
// Byte 25 :            - AuxPoint.X HW LB
// Byte 26 :            - AuxPoint.X LW HB
// Byte 27 :            - AuxPoint.X LW LB
// Byte 28 : REAL       - AuxPoint.Y HW HB
// Byte 29 :            - AuxPoint.Y HW LB
// Byte 30 :            - AuxPoint.Y LW HB
// Byte 31 :            - AuxPoint.Y LW LB
// Byte 32 : REAL       - AuxPoint.Z HW HB
// Byte 33 :            - AuxPoint.Z HW LB
// Byte 34 :            - AuxPoint.Z LW HB
// Byte 35 :            - AuxPoint.Z LW LB
// Byte 36 : REAL       - AuxPoint.RX HW HB
// Byte 37 :            - AuxPoint.RX HW LB
// Byte 38 :            - AuxPoint.RX LW HB
// Byte 39 :            - AuxPoint.RX LW LB
// Byte 40 : REAL       - AuxPoint.RY HW HB
// Byte 41 :            - AuxPoint.RY HW LB
// Byte 42 :            - AuxPoint.RY LW HB
// Byte 43 :            - AuxPoint.RY LW LB
// Byte 44 : REAL       - AuxPoint.RZ HW HB
// Byte 45 :            - AuxPoint.RZ HW LB
// Byte 46 :            - AuxPoint.RZ LW HB
// Byte 47 :            - AuxPoint.RZ LW LB
// Byte 48 : BYTE       - - - - - W E S
// Byte 49 : BYTE       - Reserved
// Byte 50 : BYTE       - AuxPoint.TurnNumber[0]
// Byte 51 : BYTE       - AuxPoint.TurnNumber[1]
// Byte 52 : BYTE       - AuxPoint.TurnNumber[2]
// Byte 53 : BYTE       - AuxPoint.TurnNumber[3]
// Byte 54 : REAL       - AuxPoint.E1 HW HB
// Byte 55 :            - AuxPoint.E1 HW LB
// Byte 56 :            - AuxPoint.E1 LW HB
// Byte 57 :            - AuxPoint.E1 LW LB
// Byte 58 : REAL       - EndPoint.X HW HB
// Byte 59 :            - EndPoint.X HW LB
// Byte 60 :            - EndPoint.X LW HB
// Byte 61 :            - EndPoint.X LW LB
// Byte 62 : REAL       - EndPoint.Y HW HB
// Byte 63 :            - EndPoint.Y HW LB
// Byte 64 :            - EndPoint.Y LW HB
// Byte 65 :            - EndPoint.Y LW LB
// Byte 66 : REAL       - EndPoint.Z HW HB
// Byte 67 :            - EndPoint.Z HW LB
// Byte 68 :            - EndPoint.Z LW HB
// Byte 69 :            - EndPoint.Z LW LB
// Byte 70 : REAL       - EndPoint.RX HW HB
// Byte 71 :            - EndPoint.RX HW LB
// Byte 72 :            - EndPoint.RX LW HB
// Byte 73 :            - EndPoint.RX LW LB
// Byte 74 : REAL       - EndPoint.RY HW HB
// Byte 75 :            - EndPoint.RY HW LB
// Byte 76 :            - EndPoint.RY LW HB
// Byte 77 :            - EndPoint.RY LW LB
// Byte 78 : REAL       - EndPoint.RZ HW HB
// Byte 79 :            - EndPoint.RZ HW LB
// Byte 80 :            - EndPoint.RZ LW HB
// Byte 81 :            - EndPoint.RZ LW LB
// Byte 82 : BYTE       - - - - - W E S
// Byte 83 : BYTE       - Reserved
// Byte 84 : BYTE       - EndPoint.TurnNumber[0]
// Byte 85 : BYTE       - EndPoint.TurnNumber[1]
// Byte 86 : BYTE       - EndPoint.TurnNumber[2]
// Byte 87 : BYTE       - EndPoint.TurnNumber[3]
// Byte 88 : REAL       - EndPoint.E1 HW HB
// Byte 89 :            - EndPoint.E1 HW LB
// Byte 90 :            - EndPoint.E1 LW HB
// Byte 91 :            - EndPoint.E1 LW LB
// Byte 92 : UINT       - TriggerDelay LW HB
// Byte 93 : UINT       - TriggerDelay LW LB
// Byte 94 : REAL       - TriggerDistance HW HB
// Byte 95 :            - TriggerDistance HW LB
// Byte 96 :            - TriggerDistance LW HB
// Byte 97 :            - TriggerDistance LW LB
// Byte 98 : SINT       - CircMode
// Byte 99 : SINT       - CircPlane
// Byte 100: REAL       - Tolerance HW HB
// Byte 101:            - Tolerance HW LB
// Byte 102:            - Tolerance LW HB
// Byte 103:            - Tolerance LW LB
// Byte 104: REAL       - Angle HW HB
// Byte 105:            - Angle HW LB
// Byte 106:            - Angle LW HB
// Byte 107:            - Angle LW LB
// Byte 108: BOOL       - PathChoice
// Byte 109: USINT      - Index
// Byte 110: BOOL       - RelativePosition
// Byte 111: BYTE       - OutputBitmask
// Byte 112: BYTE       - Value
// Byte 113: BOOL       - Manipulation
// Byte 114: BYTE       - ConfigMode[0]
// Byte 115: BYTE       - ConfigMode[1]
// Byte 116: USINT      - TurnMode
// Byte 117: BYTE       - Reserved
// Byte 118: UINT       - Time HW HB
// Byte 119:            - Time HW LB
// Byte 120: REAL       - AuxPoint.E2 HW HB
// Byte 121:            - AuxPoint.E2 HW LB
// Byte 122:            - AuxPoint.E2 LW HB
// Byte 123:            - AuxPoint.E2 LW LB
// Byte 124: REAL       - AuxPoint.E3 HW HB
// Byte 125:            - AuxPoint.E3 HW LB
// Byte 126:            - AuxPoint.E3 LW HB
// Byte 127:            - AuxPoint.E3 LW LB
// Byte 128: REAL       - AuxPoint.E4 HW HB
// Byte 129:            - AuxPoint.E4 HW LB
// Byte 130:            - AuxPoint.E4 LW HB
// Byte 131:            - AuxPoint.E4 LW LB
// Byte 132: REAL       - AuxPoint.E5 HW HB
// Byte 133:            - AuxPoint.E5 HW LB
// Byte 134:            - AuxPoint.E5 LW HB
// Byte 135:            - AuxPoint.E5 LW LB
// Byte 136: REAL       - AuxPoint.E6 HW HB
// Byte 137:            - AuxPoint.E6 HW LB
// Byte 138:            - AuxPoint.E6 LW HB
// Byte 139:            - AuxPoint.E6 LW LB
// Byte 140: REAL       - EndPoint.E2 HW HB
// Byte 141:            - EndPoint.E2 HW LB
// Byte 142:            - EndPoint.E2 LW HB
// Byte 143:            - EndPoint.E2 LW LB
// Byte 144: REAL       - EndPoint.E3 HW HB
// Byte 145:            - EndPoint.E3 HW LB
// Byte 146:            - EndPoint.E3 LW HB
// Byte 147:            - EndPoint.E3 LW LB
// Byte 148: REAL       - EndPoint.E4 HW HB
// Byte 149:            - EndPoint.E4 HW LB
// Byte 150:            - EndPoint.E4 LW HB
// Byte 151:            - EndPoint.E4 LW LB
// Byte 152: REAL       - EndPoint.E5 HW HB
// Byte 153:            - EndPoint.E5 HW LB
// Byte 154:            - EndPoint.E5 LW HB
// Byte 155:            - EndPoint.E5 LW LB
// Byte 156: REAL       - EndPoint.E6 HW HB
// Byte 157:            - EndPoint.E6 HW LB
// Byte 158:            - EndPoint.E6 LW HB
// Byte 159:            - EndPoint.E6 LW LB

  // set command parameter 
  _command.CmdTyp            :=  CmdType.MoveCircularCam;
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
  _command.OriMode           := _parCmd.OriMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.AuxPoint          := _parCmd.AuxPoint;
  _command.EndPoint          := _parCmd.EndPoint;
  _command.TriggerDelay      := _parCmd.TriggerDelay;
  _command.TriggerDistance   := _parCmd.TriggerDistance;
  _command.CircMode          := _parCmd.CircMode;
  _command.CircPlane         := _parCmd.CircPlane;
  _command.Tolerance         := _parCmd.Tolerance;
  _command.Angle             := _parCmd.Angle;
  _command.PathChoice        := _parCmd.PathChoice.0;
  _command.Index             := _parCmd.Index;
  _command.RelativePosition  := _parCmd.RelativePosition;
  _command.OutputBitmask     := _parCmd.OutputBitmask;
  _command.Value             := _parCmd.Value;
  _command.Manipulation      := _parCmd.Manipulation;
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
  
  
  _command.TurnMode          := _parCmd.TurnMode;
  _command.Reserve           := 0;
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
  // add command.mFrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.BlendingMode
  CreateCommandPayload.AddUsint(_command.BlendingMode);
  // add command.OriMode
  CreateCommandPayload.AddUsint(_command.OriMode);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.AuxPoint.X
  CreateCommandPayload.AddReal(_command.AuxPoint.X);
  // add command.AuxPoint.Y
  CreateCommandPayload.AddReal(_command.AuxPoint.Y);
  // add command.AuxPoint.Z
  CreateCommandPayload.AddReal(_command.AuxPoint.Z);
  // add command.AuxPoint.Rx
  CreateCommandPayload.AddReal(_command.AuxPoint.Rx);
  // add command.AuxPoint.Ry
  CreateCommandPayload.AddReal(_command.AuxPoint.Ry);
  // add command.AuxPoint.Rz
  CreateCommandPayload.AddReal(_command.AuxPoint.Rz);
  // add command.AuxPoint.Config
  CreateCommandPayload.AddArmConfig(_command.AuxPoint.Config);
  // add command.AuxPoint.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.AuxPoint.TurnNumber);
  // add command.AuxPoint.E1
  CreateCommandPayload.AddReal(_command.AuxPoint.E1);
  // add command.EndPoint.X
  CreateCommandPayload.AddReal(_command.EndPoint.X);
  // add command.EndPoint.Y
  CreateCommandPayload.AddReal(_command.EndPoint.y);
  // add command.EndPoint.Z
  CreateCommandPayload.AddReal(_command.EndPoint.Z);
  // add command.EndPoint.Rx
  CreateCommandPayload.AddReal(_command.EndPoint.Rx);
  // add command.EndPoint.Ry
  CreateCommandPayload.AddReal(_command.EndPoint.Ry);
  // add command.EndPoint.Rz
  CreateCommandPayload.AddReal(_command.EndPoint.Rz);
  // add command.EndPoint.Config
  CreateCommandPayload.AddArmConfig(_command.EndPoint.Config);
  // add command.EndPoint.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.EndPoint.TurnNumber);
  // add command.EndPoint.E1
  CreateCommandPayload.AddReal(_command.EndPoint.E1);
  // add command.TriggerDelay
  CreateCommandPayload.AddUint(_command.TriggerDelay);
  // add command.TriggerDistance
  CreateCommandPayload.AddReal(_command.TriggerDistance);
  // add command.CircMode
  CreateCommandPayload.AddSint(_command.CircMode);
  // add command.CircPlane
  CreateCommandPayload.AddSint(_command.CircPlane);
  // add command.Tolerance
  CreateCommandPayload.AddReal(_command.Tolerance);
  // add command.Angle
  CreateCommandPayload.AddReal(_command.Angle);
  // add command.PathChoice
  CreateCommandPayload.AddBool(_command.PathChoice);
  // add command.Index
  CreateCommandPayload.AddUsint(_command.Index);
  // add command.RelativePosition
  CreateCommandPayload.AddBool(_command.RelativePosition);
  // add command.OutputBitmask
  CreateCommandPayload.AddByte(_command.OutputBitmask);
  // add command.Value
  CreateCommandPayload.AddByte(_command.Value);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.ConfigMode[0]
  CreateCommandPayload.AddByte(_command.ConfigMode[0]);
  // add command.ConfigMode[1]
  CreateCommandPayload.AddByte(_command.ConfigMode[1]);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.AuxPoint.E2
  CreateCommandPayload.AddReal(_command.AuxPoint.E2);
  // add command.AuxPoint.E3
  CreateCommandPayload.AddReal(_command.AuxPoint.E3);
  // add command.AuxPoint.E4
  CreateCommandPayload.AddReal(_command.AuxPoint.E4);
  // add command.AuxPoint.E5
  CreateCommandPayload.AddReal(_command.AuxPoint.E5);
  // add command.AuxPoint.E6
  CreateCommandPayload.AddReal(_command.AuxPoint.E6);
  // add command.EndPoint.E2
  CreateCommandPayload.AddReal(_command.EndPoint.E2);
  // add command.EndPoint.E3
  CreateCommandPayload.AddReal(_command.EndPoint.E3);
  // add command.EndPoint.E4
  CreateCommandPayload.AddReal(_command.EndPoint.E4);
  // add command.EndPoint.E5
  CreateCommandPayload.AddReal(_command.EndPoint.E5);
  // add command.EndPoint.E6
  CreateCommandPayload.AddReal(_command.EndPoint.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveCircularCamFB';

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
// Table 6-542: Received CMD payload (RC to PLC) of "MoveCircularCam"
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
// Byte 04 : UINT    - Progress LW HB
// Byte 05 :           Progress LW LB
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

