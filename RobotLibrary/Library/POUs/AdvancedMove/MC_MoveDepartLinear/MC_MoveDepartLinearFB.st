/// Linear Move from actual position to destination through auxiliary position,
/// defined by offset in all dimensions (movement to target position linear)
FUNCTION_BLOCK MC_MoveDepartLinearFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveDepartLinearFB                                       
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
  ParCmd             : MoveDepartLinearParCmd;       
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
  OutCmd             : MoveDepartLinearOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveDepartLinearParCmd;
  /// command data to send
 _command            : MoveDepartLinearSendData;
  /// response data received
 _response           : MoveDepartLinearRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.MoveDepartLinear;
  
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
    CommandData := CreateCommandPayload(); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-378: Sent CMD payload (PLC to RC) of "MoveDepartLinear"
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
// Byte 04 : SINT       - EmitterID[0]
// Byte 05 : SINT       - EmitterID[1]
// Byte 06 : SINT       - EmitterID[2]
// Byte 07 : SINT       - EmitterID[3]
// Byte 08 : SINT       - ListenerID
// Byte 09 : BYTE       - Reserved
// Byte 10 : UINT       - VelocityRate HW HB
// Byte 11 :            - VelocityRate HW LB
// Byte 12 : UINT       - AccelerationRate HW HB
// Byte 13 :            - AccelerationRate HW LB
// Byte 14 : UINT       - DecelerationRate HW HB
// Byte 15 :            - DecelerationRate HW LB
// Byte 16 : UINT       - JerkRate HW HB
// Byte 17 :            - JerkRate HW LB
// Byte 18 : USINT      - ToolNo
// Byte 19 : USINT      - FrameNo
// Byte 20 : USINT      - BlendingMode
// Byte 21 : USINT      - OriMode
// Byte 22 : REAL       - BlendingParameter[0] HW HB
// Byte 23 :            - BlendingParameter[0] HW LB
// Byte 24 :            - BlendingParameter[0] LW HB
// Byte 25 :            - BlendingParameter[0] LW LB
// Byte 26 : REAL       - BlendingParameter[1] HW HB
// Byte 27 :            - BlendingParameter[1] HW LB
// Byte 28 :            - BlendingParameter[1] LW HB
// Byte 29 :            - BlendingParameter[1] LW LB
// Byte 30 : REAL       - TargetPosition.X HW HB
// Byte 31 :            - TargetPosition.X HW LB
// Byte 32 :            - TargetPosition.X LW HB
// Byte 33 :            - TargetPosition.X LW LB
// Byte 34 : REAL       - TargetPosition.Y HW HB
// Byte 35 :            - TargetPosition.Y HW LB
// Byte 36 :            - TargetPosition.Y LW HB
// Byte 37 :            - TargetPosition.Y LW LB
// Byte 38 : REAL       - TargetPosition.Z HW HB
// Byte 39 :            - TargetPosition.Z HW LB
// Byte 40 :            - TargetPosition.Z LW HB
// Byte 41 :            - TargetPosition.Z LW LB
// Byte 42 : REAL       - TargetPosition.RX HW HB
// Byte 43 :            - TargetPosition.RX HW LB
// Byte 44 :            - TargetPosition.RX LW HB
// Byte 45 :            - TargetPosition.RX LW LB
// Byte 46 : REAL       - TargetPosition.RY HW HB
// Byte 47 :            - TargetPosition.RY HW LB
// Byte 48 :            - TargetPosition.RY LW HB
// Byte 49 :            - TargetPosition.RY LW LB
// Byte 50 : REAL       - TargetPosition.RZ HW HB
// Byte 51 :            - TargetPosition.RZ HW LB
// Byte 52 :            - TargetPosition.RZ LW HB
// Byte 53 :            - TargetPosition.RZ LW LB
// Byte 54 : BYTE       - W E S
// Byte 55 : BYTE       - Reserved
// Byte 56 : BYTE       - TargetPosition.TurnNumber[0]
// Byte 57 : BYTE       - TargetPosition.TurnNumber[1]
// Byte 58 : BYTE       - TargetPosition.TurnNumber[2]
// Byte 59 : BYTE       - TargetPosition.TurnNumber[3]
// Byte 60 : REAL       - TargetPosition.E1 HW HB
// Byte 61 :            - TargetPosition.E1 HW LB
// Byte 62 :            - TargetPosition.E1 LW HB
// Byte 63 :            - TargetPosition.E1 LW LB
// Byte 64 : REAL       - Offset.X HW HB
// Byte 65 :            - Offset.X HW LB
// Byte 66 :            - Offset.X LW HB
// Byte 67 :            - Offset.X LW LB
// Byte 68 : REAL       - Offset.Y HW HB
// Byte 69 :            - Offset.Y HW LB
// Byte 70 :            - Offset.Y LW HB
// Byte 71 :            - Offset.Y LW LB
// Byte 72 : REAL       - Offset.Z HW HB
// Byte 73 :            - Offset.Z HW LB
// Byte 74 :            - Offset.Z LW HB
// Byte 75 :            - Offset.Z LW LB
// Byte 76 : REAL       - Offset.RX HW HB
// Byte 77 :            - Offset.RX HW LB
// Byte 78 :            - Offset.RX LW HB
// Byte 79 :            - Offset.RX LW LB
// Byte 80 : REAL       - Offset.RY HW HB
// Byte 81 :            - Offset.RY HW LB
// Byte 82 :            - Offset.RY LW HB
// Byte 83 :            - Offset.RY LW LB
// Byte 84 : REAL       - Offset.RZ HW HB
// Byte 85 :            - Offset.RZ HW LB
// Byte 86 :            - Offset.RZ LW HB
// Byte 87 :            - Offset.RZ LW LB
// Byte 88 : REAL       - AuxCornerDistance HW HB
// Byte 89 :            - AuxCornerDistance HW LB
// Byte 90 :            - AuxCornerDistance LW HB
// Byte 91 :            - AuxCornerDistance LW LB
// Byte 92 : REAL       - VelocityCoefficient HW HB
// Byte 93 :            - VelocityCoefficient HW LB
// Byte 94 :            - VelocityCoefficient LW HB
// Byte 95 :            - VelocityCoefficient LW LB
// Byte 96 : BOOL       - Manipulation
// Byte 97 : BYTE       - ConfigMode[0]
// Byte 98 : BYTE       - ConfigMode[1]
// Byte 99 : USINT      - TurnMode
// Byte 100: USINT      - ReferenceType
// Byte 101: UINT       - Time HW HB
// Byte 102:            - Time HW LB
// Byte 103: REAL       - TargetPosition.E2 HW HB
// Byte 104:            - TargetPosition.E2 HW LB
// Byte 105:            - TargetPosition.E2 LW HB
// Byte 106:            - TargetPosition.E2 LW LB
// Byte 107: REAL       - TargetPosition.E3 HW HB
// Byte 108:            - TargetPosition.E3 HW LB
// Byte 109:            - TargetPosition.E3 LW HB
// Byte 110:            - TargetPosition.E3 LW LB
// Byte 111: REAL       - TargetPosition.E4 HW HB
// Byte 112:            - TargetPosition.E4 HW LB
// Byte 113:            - TargetPosition.E4 LW HB
// Byte 114:            - TargetPosition.E4 LW LB
// Byte 115: REAL       - TargetPosition.E5 HW HB
// Byte 116:            - TargetPosition.E5 HW LB
// Byte 117:            - TargetPosition.E5 LW HB
// Byte 118:            - TargetPosition.E5 LW LB
// Byte 119: REAL       - TargetPosition.E6 HW HB
// Byte 120:            - TargetPosition.E6 HW LB
// Byte 121:            - TargetPosition.E6 LW HB
// Byte 122:            - TargetPosition.E6 LW LB

  // set command parameter 
  _command.CmdTyp              :=  CmdType.MoveDepartLinear;
  _command.ExecMode            :=  ExecMode;
  _command.ParSeq              := _command.ParSeq;
  _command.Priority            :=  Priority;
  _command.EmitterID           := _parCmd.EmitterID;
  _command.ListenerID          := 0; {warning 'ToDo'}
  _command.VelocityRate        := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate    := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate    := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate            := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo              := _parCmd.ToolNo;
  _command.FrameNo             := _parCmd.FrameNo;
  _command.BlendingMode        := _parCmd.BlendingMode;
  _command.OriMode             := _parCmd.OriMode;
  _command.BlendingParameter   := _parCmd.BlendingParameter;
  _command.TargetPosition      := _parCmd.TargetPosition;
  _command.Offset              := _parCmd.Offset;
  _command.AuxCornerDistance   := _parCmd.AuxCornerDistance;
  _command.VelocityCoefficient := _parCmd.VelocityCoefficient;
  _command.Manipulation        := _parCmd.Manipulation;
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
  _command.TurnMode            := _parCmd.TurnMode;
  _command.ReferenceType       := _parCmd.ReferenceType.0;
  _command.MoveTime            := TIME_TO_UINT(_parCmd.MoveTime);
  
  
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
  // add command.TargetPosition.X
  CreateCommandPayload.AddReal(_command.TargetPosition.X);
  // add command.TargetPosition.Y
  CreateCommandPayload.AddReal(_command.TargetPosition.Y);
  // add command.TargetPosition.Z
  CreateCommandPayload.AddReal(_command.TargetPosition.Z);
  // add command.TargetPosition.Rx
  CreateCommandPayload.AddReal(_command.TargetPosition.Rx);
  // add command.TargetPosition.Ry
  CreateCommandPayload.AddReal(_command.TargetPosition.Ry);
  // add command.TargetPosition.Rz
  CreateCommandPayload.AddReal(_command.TargetPosition.Rz);
  // add command.TargetPosition.Config
  CreateCommandPayload.AddArmConfig(_command.TargetPosition.Config);
  // add command.TargetPosition.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.TargetPosition.TurnNumber);
  // add command.TargetPosition.E1
  CreateCommandPayload.AddReal(_command.TargetPosition.E1);
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
  // add command.AuxCornerDistance
  CreateCommandPayload.AddReal(_command.AuxCornerDistance);
  // add command.VelocityCoefficient
  CreateCommandPayload.AddReal(_command.VelocityCoefficient);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.ConfigMode[0]
  CreateCommandPayload.AddByte(_command.ConfigMode[0]);
  // add command.ConfigMode[1]
  CreateCommandPayload.AddByte(_command.ConfigMode[1]);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
  // add command.ReferenceType
  CreateCommandPayload.AddBool(_command.ReferenceType);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.TargetPosition.E2
  CreateCommandPayload.AddReal(_command.TargetPosition.E2);
  // add command.TargetPosition.E3
  CreateCommandPayload.AddReal(_command.TargetPosition.E3);
  // add command.TargetPosition.E4
  CreateCommandPayload.AddReal(_command.TargetPosition.E4);
  // add command.TargetPosition.E5
  CreateCommandPayload.AddReal(_command.TargetPosition.E5);
  // add command.TargetPosition.E6
  CreateCommandPayload.AddReal(_command.TargetPosition.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveDepartLinearFB';

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
             CommandData := CreateCommandPayload();
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
             OutCmd.FollowID          := _response.OriginID;
             OutCmd.RemainingDistance := _response.RemainingDistance;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
         
  
    02: IF ( NOT Execute)
        THEN
          Reset();
        END_IF     
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-379: Received CMD payload (RC to PLC) of "MoveDepartLinear"
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
// Byte 04 : USINT      - InvocationCounter
// Byte 05 : SINT       - Reserved
// Byte 06 : INT        - OriginID HW HB
// Byte 07 :            - OriginID HW LB
// Byte 08 : UINT       - Progress HW HB
// Byte 09 :            - Progress HW LB
// Byte 10 : REAL       - RemainingDistance HW HB
// Byte 11 :            - RemainingDistance HW LB
// Byte 12 :            - RemainingDistance LW HB
// Byte 13 :            - RemainingDistance LW LB
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
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

