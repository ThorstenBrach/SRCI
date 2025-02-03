/// Linear Move to target position through auxiliary position defined by offset in all dimensions (movement to target position linear)
FUNCTION_BLOCK MC_MoveApproachLinearFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveApproachLinearFB                                       
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
  ParCmd             : MoveApproachLinearParCmd;     
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
  /// command results
  OutCmd             : MoveApproachLinearOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : MoveApproachLinearParCmd;
  /// command data to send
 _command            : MoveApproachLinearSendData;
  /// response data received
 _response           : MoveApproachLinearRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.MoveApproachLinear;
  
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-369: Sent CMD payload (PLC to RC) of "MoveApproachLinear"
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
// Byte 54 : ArmConfig  - Config
// Byte 55 :            - Reserved
// Byte 56 : TurnNumber - TargetPosition.TurnNumber[0]
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
  _command.CmdTyp                    :=  CmdType.MoveApproachLinear;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  _command.EmitterID[0]              := _parCmd.EmitterID[0];
  _command.EmitterID[1]              := _parCmd.EmitterID[1];
  _command.EmitterID[2]              := _parCmd.EmitterID[2];
  _command.EmitterID[3]              := _parCmd.EmitterID[3];
  _command.ListenerID                := 0; {warning 'ToDo'}
  _command.Reserve                   := 0;
  _command.VelocityRate              := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate          := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate          := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate                  := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo                    := _parCmd.ToolNo;
  _command.FrameNo                   := _parCmd.FrameNo;
  _command.BlendingMode              := _parCmd.BlendingMode;
  _command.OriMode                   := _parCmd.OriMode;
  _command.BlendingParameter         := _parCmd.BlendingParameter;
  _command.TargetPosition            := _parCmd.TargetPosition;
  _command.Offset                    := _parCmd.Offset;
  _command.AuxCornerDistance         := _parCmd.AuxCornerDistance;
  _command.VelocityCoefficient       := _parCmd.VelocityCoefficient;
  _command.Manipulation              := _parCmd.Manipulation;
  _command.ConfigMode                :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.TurnMode                  := _parCmd.TurnMode;
  _command.ReferenceType             := _parCmd.ReferenceType;
  _command.MoveTime                  := TIME_TO_UINT(_parCmd.MoveTime);
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
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
  // add command.FrameNo
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
  CreateCommandPayload.AddUsint(_command.ReferenceType);
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
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR 
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'CreateCommandPayload with the following parameter(s) :');
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
                          
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for VelocityRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VelocityRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.VelocityRate));
  
  // Create log entry for AccelerationRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AccelerationRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.AccelerationRate));
                          
  // Create log entry for DecelerationRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DecelerationRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.DecelerationRate));
  
  // Create log entry for JerkRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JerkRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.JerkRate));
  
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
  
  // Create log entry for BlendingMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingMode = {1}',
                          Para1       :=  BLENDING_MODE_TO_STRING(_command.BlendingMode));
  
  // Create log entry for OriMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.OriMode = {1}',
                          Para1       :=  ORI_MODE_TO_STRING(_command.OriMode));
  
  // Create log entry for BlendingParameter[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingParameter[0] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.BlendingParameter[0]));
  
  // Create log entry for BlendingParameter[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingParameter[1] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.BlendingParameter[1]));
  
  // Create log entry for TargetPosition.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.X));
  
  // Create log entry for TargetPosition.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Y));
  
  // Create log entry for TargetPosition.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Z));
  
  // Create log entry for TargetPosition.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Rx));
  
  // Create log entry for TargetPosition.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Ry));
  
  // Create log entry for TargetPosition.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Rz));
  
  // Create log entry for Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.TargetPosition.Config));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for Position.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J2Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J1Turns)));
  
  // Create log entry for Position.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J3Turns)));
  
  // Create log entry for Position.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J5Turns)));
  
  
  // Create log entry for Position.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.TargetPosition.TurnNumber.E1Turns));
  
  // Create log entry for TargetPosition.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E1));
  
  // Create log entry for Offset.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.X));
  
  // Create log entry for Offset.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Y));
                          
  // Create log entry for Offset.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Z));
  
  // Create log entry for Offset.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rx));
  
  // Create log entry for Offset.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Ry));
  
  // Create log entry for Offset.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rz));
  
  // Create log entry for AuxCornerDistance
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxCornerDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxCornerDistance));
  
  // Create log entry for VelocityCoefficient
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VelocityCoefficient = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VelocityCoefficient));
  
  // Create log entry for Manipulation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Manipulation = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.Manipulation));
  
  // Create log entry for ConfigMode[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConfigMode[0] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ConfigMode[0]));
  
  // Create log entry for ConfigMode[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConfigMode[1] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ConfigMode[1]));
  
  // Create log entry for TurnMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TurnMode = {1}',
                          Para1       :=  TURN_MODE_TO_STRING(_command.TurnMode));
  
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  REFERENCE_TYPE_TO_STRING(_command.ReferenceType));
  
  // Create log entry for MoveTime
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MoveTime = {1}',
                          Para1       :=  UINT_TO_STRING(_command.MoveTime));
  
  // Create log entry for TargetPosition.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E2));
  
  // Create log entry for TargetPosition.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E3));
  
  // Create log entry for TargetPosition.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E4));
  
  // Create log entry for TargetPosition.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E5));
  
  // Create log entry for TargetPosition.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveApproachLinearFB';

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
             OutCmd.FollowID          := _response.OriginID;
             OutCmd.Progress          := _response.Progress;
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
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-370: Received CMD payload (RC to PLC) of "MoveApproachLinear"
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
// Byte 04 : USINT   - InvocationCounter
// Byte 05 : SINT    - Reserve
// Byte 06 : INT     - OriginID LW HB
// Byte 07 :         - OriginID LW LB
// Byte 08 : UINT    - Progress LW HB
// Byte 09 :         - Progress LW LB
// Byte 10 : REAL    - RemainingDistance HW HB
// Byte 11 :         - RemainingDistance HW LB
// Byte 12 :         - RemainingDistance LW HB
// Byte 13 :         - RemainingDistance LW LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
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

