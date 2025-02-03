/// Move Joints relative to relative cartesian position (Relative cartesian PTP) (Joint interpolated movement)
FUNCTION_BLOCK MC_MoveDirectRelativeFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveDirectRelativeFB                                       
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
  ParCmd             : MoveDirectRelativeParCmd;       
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
  OutCmd             : MoveDirectRelativeOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveDirectRelativeParCmd;
  /// command data to send
 _command            : MoveDirectRelativeSendData;
  /// response data received
 _response           : MoveDirectRelativeRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.MoveDirectRelative;
  
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
// Table 6-297: Sent CMD payload (PLC to RC) of "MoveDirectRelative"
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
// Byte 21 : Byte       - Reserve
// Byte 22 : REAL       - BlendingParameter[0] HW HB
// Byte 23 :            - BlendingParameter[0] HW LB
// Byte 24 :            - BlendingParameter[0] LW HB
// Byte 25 :            - BlendingParameter[0] LW LB
// Byte 26 : REAL       - BlendingParameter[1] HW HB
// Byte 27 :            - BlendingParameter[1] HW LB
// Byte 28 :            - BlendingParameter[1] LW HB
// Byte 29 :            - BlendingParameter[1] LW LB
// Byte 30 : REAL       - Distance.X HW HB
// Byte 31 :            - Distance.X HW LB
// Byte 32 :            - Distance.X LW HB
// Byte 33 :            - Distance.X LW LB
// Byte 34 : REAL       - Distance.Y HW HB
// Byte 35 :            - Distance.Y HW LB
// Byte 36 :            - Distance.Y LW HB
// Byte 37 :            - Distance.Y LW LB
// Byte 38 : REAL       - Distance.Z HW HB
// Byte 39 :            - Distance.Z HW LB
// Byte 40 :            - Distance.Z LW HB
// Byte 41 :            - Distance.Z LW LB
// Byte 42 : REAL       - Distance.RX HW HB
// Byte 43 :            - Distance.RX HW LB
// Byte 44 :            - Distance.RX LW HB
// Byte 45 :            - Distance.RX LW LB
// Byte 46 : REAL       - Distance.RY HW HB
// Byte 47 :            - Distance.RY HW LB
// Byte 48 :            - Distance.RY LW HB
// Byte 49 :            - Distance.RY LW LB
// Byte 50 : REAL       - Distance.RZ HW HB
// Byte 51 :            - Distance.RZ HW LB
// Byte 52 :            - Distance.RZ LW HB
// Byte 53 :            - Distance.RZ LW LB
// Byte 54 : BYTE       - - - - - W E S
// Byte 55 : BYTE       - Reserved
// Byte 56 : BYTE       - Distance.TurnNumber[0]
// Byte 57 : BYTE       - Distance.TurnNumber[1]
// Byte 58 : BYTE       - Distance.TurnNumber[2]
// Byte 59 : BYTE       - Distance.TurnNumber[3]
// Byte 60 : REAL       - Distance.E1 HW HB
// Byte 61 :            - Distance.E1 HW LB
// Byte 62 :            - Distance.E1 LW HB
// Byte 63 :            - Distance.E1 LW LB
// Byte 64 : BOOL       - Manipulation
// Byte 65 : BYTE       - Reserved
// Byte 66 : BYTE       - ConfigMode[0]
// Byte 67 : BYTE       - ConfigMode[1]
// Byte 68 : USINT      - ReferenceType
// Byte 69 : USINT      - TurnMode
// Byte 70 : UINT       - Time HW HB
// Byte 71 :            - Time HW LB
// Byte 72 : REAL       - Distance.E2 HW HB
// Byte 73 :            - Distance.E2 HW LB
// Byte 74 :            - Distance.E2 LW HB
// Byte 75 :            - Distance.E2 LW LB
// Byte 76 : REAL       - Distance.E3 HW HB
// Byte 77 :            - Distance.E3 HW LB
// Byte 78 :            - Distance.E3 LW HB
// Byte 79 :            - Distance.E3 LW LB
// Byte 80 : REAL       - Distance.E4 HW HB
// Byte 81 :            - Distance.E4 HW LB
// Byte 82 :            - Distance.E4 LW HB
// Byte 83 :            - Distance.E4 LW LB
// Byte 84 : REAL       - Distance.E5 HW HB
// Byte 85 :            - Distance.E5 HW LB
// Byte 86 :            - Distance.E5 LW HB
// Byte 87 :            - Distance.E5 LW LB
// Byte 88 : REAL       - Distance.E6 HW HB
// Byte 89 :            - Distance.E6 HW LB
// Byte 90 :            - Distance.E6 LW HB
// Byte 91 :            - Distance.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.MoveDirectRelative;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.EmitterID         := _parCmd.EmitterID;
  _command.Reserve           := 0;
  _command.ListenerID        := 0; {warning 'ToDo'}
  _command.Reserve           := 0;
  _command.VelocityRate      := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate  := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate  := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate          := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo            := _parCmd.ToolNo;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.Reserve2          := 0;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.Distance          := _parCmd.Distance;
  _command.Manipulation      := _parCmd.Manipulation;
  _command.Reserve3          := 0;
  _command.ConfigMode        :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.ReferenceType     := _parCmd.ReferenceType;
  _command.TurnMode          := _parCmd.TurnMode;
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
  // add command.Reserve2
  CreateCommandPayload.AddByte(_command.Reserve2);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.Distance.X
  CreateCommandPayload.AddReal(_command.Distance.X);
  // add command.Distance.Y
  CreateCommandPayload.AddReal(_command.Distance.Y);
  // add command.Distance.Z
  CreateCommandPayload.AddReal(_command.Distance.Z);
  // add command.Distance.Rx
  CreateCommandPayload.AddReal(_command.Distance.Rx);
  // add command.Distance.Ry
  CreateCommandPayload.AddReal(_command.Distance.Ry);
  // add command.Distance.Rz
  CreateCommandPayload.AddReal(_command.Distance.Rz);
  // add command.Distance.Config
  CreateCommandPayload.AddArmConfig(_command.Distance.Config);
  // add command.Distance.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Distance.TurnNumber);
  // add command.Distance.E1
  CreateCommandPayload.AddReal(_command.Distance.E1);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.Reserve3
  CreateCommandPayload.AddByte(_command.Reserve3);
  // add command.ConfigMode[0]
  CreateCommandPayload.AddByte(_command.ConfigMode[0]);
  // add command.ConfigMode[1]
  CreateCommandPayload.AddByte(_command.ConfigMode[1]);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.Distance.E2
  CreateCommandPayload.AddReal(_command.Distance.E2);
  // add command.Distance.E3
  CreateCommandPayload.AddReal(_command.Distance.E3);
  // add command.Distance.E4
  CreateCommandPayload.AddReal(_command.Distance.E4);
  // add command.Distance.E5
  CreateCommandPayload.AddReal(_command.Distance.E5);
  // add command.Distance.E6
  CreateCommandPayload.AddReal(_command.Distance.E6);
  
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
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
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
  
  // Create log entry for Distance.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.X));
  
  // Create log entry for Distance.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.Y));
  
  // Create log entry for Distance.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.Z));
  
  // Create log entry for Distance.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.Rx));
  
  // Create log entry for Distance.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.Ry));
  
  // Create log entry for Distance.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.Rz));
  
  // Create log entry for Distance.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.Distance.Config));
  
  // Create log entry for Distance.Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for Distance.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Distance.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.Distance.TurnNumber.J1Turns)));
  
  // Create log entry for Distance.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Distance.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.Distance.TurnNumber.J3Turns)));
  
  // Create log entry for Distance.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferencePosition.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Distance.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.Distance.TurnNumber.J5Turns)));
  
  // Create log entry for Distance.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Distance.TurnNumber.E1Turns));
  
  // Create log entry for Distance.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E1));
  
  // Create log entry for Manipulation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Manipulation = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.Manipulation));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
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
                          Para1       :=  REFERENCE_TYPE_TO_STRING(_command.ReferenceType));
  
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
  
  // Create log entry for Distance.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E2));
  
  // Create log entry for Distance.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E3));
  
  // Create log entry for Distance.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E4));
  
  // Create log entry for Distance.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E5));
  
  // Create log entry for Distance.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Distance.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Distance.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveDirectRelativeFB';

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
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-298: Received CMD payload (RC to PLC) of "MoveDirectRelative"
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

