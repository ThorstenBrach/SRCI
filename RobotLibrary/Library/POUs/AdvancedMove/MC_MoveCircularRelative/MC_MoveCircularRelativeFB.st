/// Move the TCP relative to the actual cartesian position (circular interpolation) 
FUNCTION_BLOCK MC_MoveCircularRelativeFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveCircularRelativeFB                                       
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
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands
  AbortingMode       : AbortingMode;
  /// command para,eter
  ParCmd             : MoveCircularRelativeParCmd;       
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
  OutCmd             : MoveCircularRelativeOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveCircularRelativeParCmd;
  /// command data to send
 _command            : MoveCircularRelativeSendData;
  /// response data received
 _response           : MoveCircularRelativeRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.MoveCircularRelative;
  
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-335: Sent CMD payload (PLC to RC) of "MoveCircularRelative"
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
// Byte 30 : REAL       - AuxPoint.X HW HB
// Byte 31 :            - AuxPoint.X HW LB
// Byte 32 :            - AuxPoint.X LW HB
// Byte 33 :            - AuxPoint.X LW LB
// Byte 34 : REAL       - AuxPoint.Y HW HB
// Byte 35 :            - AuxPoint.Y HW LB
// Byte 36 :            - AuxPoint.Y LW HB
// Byte 37 :            - AuxPoint.Y LW LB
// Byte 38 : REAL       - AuxPoint.Z HW HB
// Byte 39 :            - AuxPoint.Z HW LB
// Byte 40 :            - AuxPoint.Z LW HB
// Byte 41 :            - AuxPoint.Z LW LB
// Byte 42 : REAL       - AuxPoint.RX HW HB
// Byte 43 :            - AuxPoint.RX HW LB
// Byte 44 :            - AuxPoint.RX LW HB
// Byte 45 :            - AuxPoint.RX LW LB
// Byte 46 : REAL       - AuxPoint.RY HW HB
// Byte 47 :            - AuxPoint.RY HW LB
// Byte 48 :            - AuxPoint.RY LW HB
// Byte 49 :            - AuxPoint.RY LW LB
// Byte 50 : REAL       - AuxPoint.RZ HW HB
// Byte 51 :            - AuxPoint.RZ HW LB
// Byte 52 :            - AuxPoint.RZ LW HB
// Byte 53 :            - AuxPoint.RZ LW LB
// Byte 54 : BYTE       - - - - - W E S
// Byte 55 : BYTE       - Reserved
// Byte 56 : BYTE       - AuxPoint.TurnNumber[0]
// Byte 57 : BYTE       - AuxPoint.TurnNumber[1]
// Byte 58 : BYTE       - AuxPoint.TurnNumber[2]
// Byte 59 : BYTE       - AuxPoint.TurnNumber[3]
// Byte 60 : REAL       - AuxPoint.E1 HW HB
// Byte 61 :            - AuxPoint.E1 HW LB
// Byte 62 :            - AuxPoint.E1 LW HB
// Byte 63 :            - AuxPoint.E1 LW LB
// Byte 64 : REAL       - EndPoint.X HW HB
// Byte 65 :            - EndPoint.X HW LB
// Byte 66 :            - EndPoint.X LW HB
// Byte 67 :            - EndPoint.X LW LB
// Byte 68 : REAL       - EndPoint.Y HW HB
// Byte 69 :            - EndPoint.Y HW LB
// Byte 70 :            - EndPoint.Y LW HB
// Byte 71 :            - EndPoint.Y LW LB
// Byte 72 : REAL       - EndPoint.Z HW HB
// Byte 73 :            - EndPoint.Z HW LB
// Byte 74 :            - EndPoint.Z LW HB
// Byte 75 :            - EndPoint.Z LW LB
// Byte 76 : REAL       - EndPoint.RX HW HB
// Byte 77 :            - EndPoint.RX HW LB
// Byte 78 :            - EndPoint.RX LW HB
// Byte 79 :            - EndPoint.RX LW LB
// Byte 80 : REAL       - EndPoint.RY HW HB
// Byte 81 :            - EndPoint.RY HW LB
// Byte 82 :            - EndPoint.RY LW HB
// Byte 83 :            - EndPoint.RY LW LB
// Byte 84 : REAL       - EndPoint.RZ HW HB
// Byte 85 :            - EndPoint.RZ HW LB
// Byte 86 :            - EndPoint.RZ LW HB
// Byte 87 :            - EndPoint.RZ LW LB
// Byte 88 : BYTE       - - - - - W E S
// Byte 89 : BYTE       - Reserved
// Byte 90 : BYTE       - EndPoint.TurnNumber[0]
// Byte 91 : BYTE       - EndPoint.TurnNumber[1]
// Byte 92 : BYTE       - EndPoint.TurnNumber[2]
// Byte 93 : BYTE       - EndPoint.TurnNumber[3]
// Byte 94 : REAL       - EndPoint.E1 HW HB
// Byte 95 :            - EndPoint.E1 HW LB
// Byte 96 :            - EndPoint.E1 LW HB
// Byte 97 :            - EndPoint.E1 LW LB
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
// Byte 109: BOOL       - Manipulation
// Byte 110: BYTE       - ConfigMode[0]
// Byte 111: BYTE       - ConfigMode[1]
// Byte 112: BOOL       - ReferenceType
// Byte 113: USINT      - TurnMode
// Byte 114: UINT       - Time HW HB
// Byte 115:            - Time HW LB
// Byte 116: REAL       - AuxPoint.E2 HW HB
// Byte 117:            - AuxPoint.E2 HW LB
// Byte 118:            - AuxPoint.E2 LW HB
// Byte 119:            - AuxPoint.E2 LW LB
// Byte 120: REAL       - AuxPoint.E3 HW HB
// Byte 121:            - AuxPoint.E3 HW LB
// Byte 122:            - AuxPoint.E3 LW HB
// Byte 123:            - AuxPoint.E3 LW LB
// Byte 124: REAL       - AuxPoint.E4 HW HB
// Byte 125:            - AuxPoint.E4 HW LB
// Byte 126:            - AuxPoint.E4 LW HB
// Byte 127:            - AuxPoint.E4 LW LB
// Byte 128: REAL       - AuxPoint.E5 HW HB
// Byte 129:            - AuxPoint.E5 HW LB
// Byte 130:            - AuxPoint.E5 LW HB
// Byte 131:            - AuxPoint.E5 LW LB
// Byte 132: REAL       - AuxPoint.E6 HW HB
// Byte 133:            - AuxPoint.E6 HW LB
// Byte 134:            - AuxPoint.E6 LW HB
// Byte 135:            - AuxPoint.E6 LW LB
// Byte 136: REAL       - EndPoint.E2 HW HB
// Byte 137:            - EndPoint.E2 HW LB
// Byte 138:            - EndPoint.E2 LW HB
// Byte 139:            - EndPoint.E2 LW LB
// Byte 140: REAL       - EndPoint.E3 HW HB
// Byte 141:            - EndPoint.E3 HW LB
// Byte 142:            - EndPoint.E3 LW HB
// Byte 143:            - EndPoint.E3 LW LB
// Byte 144: REAL       - EndPoint.E4 HW HB
// Byte 145:            - EndPoint.E4 HW LB
// Byte 146:            - EndPoint.E4 LW HB
// Byte 147:            - EndPoint.E4 LW LB
// Byte 148: REAL       - EndPoint.E5 HW HB
// Byte 149:            - EndPoint.E5 HW LB
// Byte 150:            - EndPoint.E5 LW HB
// Byte 151:            - EndPoint.E5 LW LB
// Byte 152: REAL       - EndPoint.E6 HW HB
// Byte 153:            - EndPoint.E6 HW LB
// Byte 154:            - EndPoint.E6 LW HB
// Byte 155:            - EndPoint.E6 LW LB

  // set command parameter 
  _command.CmdTyp            :=  CmdType.MoveCircularRelative;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.EmitterID         := _parCmd.EmitterID;
  _command.ListenerID        := 0; {warning 'ToDo'}
  _command.VelocityRate      := REAL_TO_PERCENT_UINT(_parCmd.VelocityRate     , IsOptional := FALSE);
  _command.AccelerationRate  := REAL_TO_PERCENT_UINT(_parCmd.AccelerationRate , IsOptional := FALSE);
  _command.DecelerationRate  := REAL_TO_PERCENT_UINT(_parCmd.DecelerationRate , IsOptional := TRUE );
  _command.JerkRate          := REAL_TO_PERCENT_UINT(_parCmd.JerkRate         , IsOptional := TRUE );
  _command.ToolNo            := _parCmd.ToolNo;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.OriMode           := _parCmd.OriMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.AuxPoint          := _parCmd.AuxPoint;
  _command.EndPoint          := _parCmd.EndPoint;
  _command.CircMode          := _parCmd.CircMode;
  _command.CircPlane         := _parCmd.CircPlane;
  _command.Tolerance         := _parCmd.Tolerance;
  _command.Angle             := _parCmd.Angle;
  _command.Manipulation      := _parCmd.Manipulation;
  _command.PathChoice        := _parCmd.PathChoice.0;
  _command.ConfigMode        :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.ReferenceType     := _parCmd.ReferenceType.0;
  _command.TurnMode          := _parCmd.TurnMode;
  _command.Reserve           := 0;
  _command.MoveTime          := TIME_TO_UINT(_parCmd.MoveTime);
  
  
  
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
  CreateCommandPayload.AddReal(_command.EndPoint.Y);
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
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.ConfigMode[0]
  CreateCommandPayload.AddByte(_command.ConfigMode[0]);
  // add command.ConfigMode[1]
  CreateCommandPayload.AddByte(_command.ConfigMode[1]);
  // add command.ReferenceType
  CreateCommandPayload.AddBool(_command.ReferenceType);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
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
                          MessageText := 'Create command payload with the following parameter(s) :');
    
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
  
  // Create log entry for AuxPoint.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.X));
  
  // Create log entry for AuxPoint.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.Y));
  
  // Create log entry for AuxPoint.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.Z));
  
  // Create log entry for AuxPoint.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.Rx));
  
  // Create log entry for AuxPoint.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.Ry));
  
  // Create log entry for AuxPoint.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.Rz));
  
  // Create log entry for AuxPoint.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.AuxPoint.Config));
  
  // Create log entry for AuxPoint.Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.Config = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for AuxPoint.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.AuxPoint.TurnNumber.J2Turns, 
                                                                          HalfSintLo := _command.AuxPoint.TurnNumber.J1Turns)));
  
  // Create log entry for AuxPoint.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.AuxPoint.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.AuxPoint.TurnNumber.J3Turns)));
  
  // Create log entry for AuxPoint.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.AuxPoint.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.AuxPoint.TurnNumber.J5Turns)));
  
  // Create log entry for AuxPoint.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.AuxPoint.TurnNumber.E1Turns));
  
  // Create log entry for AuxPoint.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E1));
  
  // Create log entry for EndPoint.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.X));
  
  // Create log entry for EndPoint.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.Y));
  
  // Create log entry for EndPoint.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.Z));
  
  // Create log entry for EndPoint.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.Rx));
  
  // Create log entry for EndPoint.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.Ry));
  
  // Create log entry for EndPoint.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.Rz));
  
  // Create log entry for EndPoint.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.EndPoint.Config));
  
  // Create log entry for EndPoint.Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.Config = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for EndPoint.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.EndPoint.TurnNumber.J2Turns, 
                                                                          HalfSintLo := _command.EndPoint.TurnNumber.J1Turns)));
  
  // Create log entry for EndPoint.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.EndPoint[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.EndPoint.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.EndPoint.TurnNumber.J3Turns)));
  
  // Create log entry for EndPoint.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.EndPoint.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.EndPoint.TurnNumber.J5Turns)));
  
  // Create log entry for EndPoint.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.EndPoint.TurnNumber.E1Turns));
  
  // Create log entry for EndPoint.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E1));
  
  // Create log entry for CircMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CircMode = {1}',
                          Para1       :=  CIRC_MODE_TO_STRING(_command.CircMode));
  
  // Create log entry for CircPlane
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CircPlane = {1}',
                          Para1       :=  CIRC_PLANE_TO_STRING(_command.CircPlane));
  
  // Create log entry for Tolerance
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Tolerance = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Tolerance));
  
  // Create log entry for Angle
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Angle = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Angle));
  
  // Create log entry for PathChoice
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.PathChoice = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.PathChoice));
  
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
  
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  REFERENCE_TYPE_TO_STRING(BOOL_TO_BYTE(_command.ReferenceType)));
  
  // Create log entry for TurnMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TurnMode = {1}',
                          Para1       :=  TURN_MODE_TO_STRING(_command.TurnMode));
                          
  // Create log entry for MoveTime
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MoveTime = {1}',
                          Para1       :=  UINT_TO_STRING(_command.MoveTime));
                          
  // Create log entry for AuxPoint.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E2));
                          
  // Create log entry for AuxPoint.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E3));
                          
  // Create log entry for AuxPoint.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E4));                        
                          
  // Create log entry for AuxPoint.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E5));                        
                          
  // Create log entry for AuxPoint.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxPoint.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxPoint.E6));
  
  // Create log entry for EndPoint.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E2));
                          
  // Create log entry for EndPoint.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E3));
                          
  // Create log entry for EndPoint.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E4));                        
                          
  // Create log entry for EndPoint.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E5));                        
                          
  // Create log entry for EndPoint.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndPoint.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndPoint.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveCircularRelativeFB';

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
// Table 6-336: Received CMD payload (RC to PLC) of "MoveCircularRelative"
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
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
                          
  // Create log entry for InvocationCounter
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InvocationCounter = {1}',
                          Para1       :=  USINT_TO_STRING(_response.InvocationCounter));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  SINT_TO_STRING(_response.Reserve));
  
  // Create log entry for OriginID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.OriginID = {1}',
                          Para1       :=  INT_TO_STRING(_response.OriginID));
  
  // Create log entry for Progress
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Progress = {1}',
                          Para1       :=  UINT_TO_STRING(_response.Progress));
  
  // Create log entry for RemainingDistance
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RemainingDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_response.RemainingDistance));

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

