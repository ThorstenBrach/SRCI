/// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
FUNCTION_BLOCK MC_SearchHardStopFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SearchHardStopFB                                       
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
  ParCmd             : SearchHardStopParCmd;
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
  OutCmd             : SearchHardStopOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : SearchHardStopParCmd;
  /// command data to send
 _command            : SearchHardStopSendData;
  /// response data received
 _response           : SearchHardStopRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.SearchHardstop;
  
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
// Table 6-405: Sent CMD payload (PLC to RC) of "SearchHardStop"
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
// Byte 04 : UINT  VelocityRate;
// Byte 05 :       VelocityRate;
// Byte 06 : UINT  AccelerationRate;
// Byte 07 :       AccelerationRate;
// Byte 08 : UINT  DecelerationRate;
// Byte 09 :       DecelerationRate;
// Byte 10 : UINT  JerkRate;
// Byte 11 :       JerkRate;
// Byte 12 : USINT ToolNo;
// Byte 13 : USINT FrameNo;
// Byte 14 : REAL  Position.X;
// Byte 15 :       Position.X;
// Byte 16 :       Position.X;
// Byte 17 :       Position.X;
// Byte 18 : REAL  Position.Y;
// Byte 19 :       Position.Y;
// Byte 20 :       Position.Y;
// Byte 21 :       Position.Y;
// Byte 22 : REAL  Position.Z;
// Byte 23 :       Position.Z;
// Byte 24 :       Position.Z;
// Byte 25 :       Position.Z;
// Byte 26 : REAL  Position.RX;
// Byte 27 :       Position.RX;
// Byte 28 :       Position.RX;
// Byte 29 :       Position.RX;
// Byte 30 : REAL  Position.RY;
// Byte 31 :       Position.RY;
// Byte 32 :       Position.RY;
// Byte 33 :       Position.RY;
// Byte 34 : REAL  Position.RZ;
// Byte 35 :       Position.RZ;
// Byte 36 :       Position.RZ;
// Byte 37 :       Position.RZ;
// Byte 38 : BYTE  - - - - - W E S;
// Byte 39 : BYTE  Reserved;
// Byte 40 : BYTE  Position.TurnNumber[0];
// Byte 41 : BYTE  Position.TurnNumber[1];
// Byte 42 : BYTE  Position.TurnNumber[2];
// Byte 43 : BYTE  Position.TurnNumber[3];
// Byte 44 : REAL  Position.E1;
// Byte 45 :       Position.E1;
// Byte 46 :       Position.E1;
// Byte 47 :       Position.E1;
// Byte 48 : USINT OriMode;
// Byte 49 : USINT DetectionMode;
// Byte 50 : BOOL  Manipulation;
// Byte 51 : BYTE  Reserved;
// Byte 52 : REAL  DetectionVector[0];
// Byte 53 :       DetectionVector[0];
// Byte 54 :       DetectionVector[0];
// Byte 55 :       DetectionVector[0];
// Byte 56 : REAL  DetectionVector[1];
// Byte 57 :       DetectionVector[1];
// Byte 58 :       DetectionVector[1];
// Byte 59 :       DetectionVector[1];
// Byte 60 : REAL  DetectionVector[2];
// Byte 61 :       DetectionVector[2];
// Byte 62 :       DetectionVector[2];
// Byte 63 :       DetectionVector[2];
// Byte 64 : REAL  DetectionVector[3];
// Byte 65 :       DetectionVector[3];
// Byte 66 :       DetectionVector[3];
// Byte 67 :       DetectionVector[3];
// Byte 68 : REAL  DetectionVector[4];
// Byte 69 :       DetectionVector[4];
// Byte 70 :       DetectionVector[4];
// Byte 71 :       DetectionVector[4];
// Byte 72 : REAL  DetectionVector[5];
// Byte 73 :       DetectionVector[5];
// Byte 74 :       DetectionVector[5];
// Byte 75 :       DetectionVector[5];
// Byte 76 : BYTE  ConfigMode[0];
// Byte 77 : BYTE  ConfigMode[1];
// Byte 78 : USINT TurnMode;
// Byte 79 : REAL  Position.E2;
// Byte 80 :       Position.E2;
// Byte 81 :       Position.E2;
// Byte 82 :       Position.E2;
// Byte 83 : REAL  Position.E3;
// Byte 84 :       Position.E3;
// Byte 85 :       Position.E3;
// Byte 86 :       Position.E3;
// Byte 87 : REAL  Position.E4;
// Byte 88 :       Position.E4;
// Byte 89 :       Position.E4;
// Byte 90 :       Position.E4;
// Byte 91 : REAL  Position.E5;
// Byte 92 :       Position.E5;
// Byte 93 :       Position.E5;
// Byte 94 :       Position.E5;
// Byte 95 : REAL  Position.E6;
// Byte 96 :       Position.E6;
// Byte 97 :       Position.E6;
// Byte 98 :       Position.E6;

  // set command parameter 
  _command.CmdTyp           :=  CmdType.SearchHardstop;
  _command.ExecMode         :=  ExecMode;
  _command.ParSeq           := _command.ParSeq;
  _command.Priority         :=  Priority;
  _command.VelocityRate     :=  REAL_TO_PERCENT_UINT(_parCmd.VelocityRate     , IsOptional := FALSE);
  _command.AccelerationRate :=  REAL_TO_PERCENT_UINT(_parCmd.AccelerationRate , IsOptional := FALSE);
  _command.DecelerationRate :=  REAL_TO_PERCENT_UINT(_parCmd.DecelerationRate , IsOptional := TRUE );
  _command.JerkRate         :=  REAL_TO_PERCENT_UINT(_parCmd.JerkRate         , IsOptional := TRUE );
  _command.ToolNo           := _parCmd.ToolNo;
  _command.FrameNo          := _parCmd.FrameNo;
  _command.Position         := _parCmd.Position;
  _command.OriMode          := _parCmd.OriMode;
  _command.DetectionMode    := _parCmd.DetectionMode;
  _command.Manipulation     := _parCmd.Manipulation;
  _command.Reserve          :=  0;
  _command.DetectionVector  := _parCmd.DetectionVector;
  _command.ConfigMode       :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.TurnMode         := _parCmd.TurnMode;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
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
  // add command.Position.Config
  CreateCommandPayload.AddArmConfig(_command.Position.Config);
  // add command.Position.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Position.TurnNumber);
  // add command.Position.E1
  CreateCommandPayload.AddReal(_command.Position.E1);
  // add command.OriMode
  CreateCommandPayload.AddUsint(_command.OriMode);
  // add command.DetectionMode
  CreateCommandPayload.AddUsint(_command.DetectionMode);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.DetectionVector[0]
  CreateCommandPayload.AddReal(_command.DetectionVector[0]);
  // add command.DetectionVector[1]
  CreateCommandPayload.AddReal(_command.DetectionVector[1]);
  // add command.DetectionVector[2]
  CreateCommandPayload.AddReal(_command.DetectionVector[2]);
  // add command.DetectionVector[3]
  CreateCommandPayload.AddReal(_command.DetectionVector[3]);
  // add command.DetectionVector[4]
  CreateCommandPayload.AddReal(_command.DetectionVector[4]);
  // add command.DetectionVector[5]
  CreateCommandPayload.AddReal(_command.DetectionVector[5]);
  // add command.ConfigMode[0]
  CreateCommandPayload.AddByte(_command.ConfigMode[0]);
  // add command.ConfigMode[1]
  CreateCommandPayload.AddByte(_command.ConfigMode[1]);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
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
  
  // Create log entry for Position.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.X));
  
  // Create log entry for Position.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Y));
  
  // Create log entry for Position.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Z));
  
  // Create log entry for Position.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rx));
  
  // Create log entry for Position.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Ry));
  
  // Create log entry for Position.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rz));
  
  // Create log entry for Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.Position.Config));
  
  // Create log entry for Position.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.Position.TurnNumber.J1Turns)));
  
  // Create log entry for Position.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J3Turns)));
  
  // Create log entry for Position.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J5Turns)));
  
  
  // Create log entry for Position.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Position.TurnNumber.E1Turns));
  
  // Create log entry for Position.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E1));
  
  
  // Create log entry for OriMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.OriMode = {1}',
                          Para1       :=  ORI_MODE_TO_STRING(_command.OriMode));
  
  // Create log entry for DetectionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DetectionMode = {1}',
                          Para1       :=  DETECTION_MODE_TO_STRING(_command.DetectionMode));
  
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
                          Para1       :=  USINT_TO_STRING(_command.Reserve));
  
  
  // Create log entry for DetectionVector[x]
  FOR _idx := 0 TO 5
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.DetectionVector[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_command.DetectionVector[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
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
                          
  // Create log entry for Position.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E2));
  
  // Create log entry for Position.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E3));
  
  // Create log entry for Position.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E4));
  
  // Create log entry for Position.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E5));
  
  // Create log entry for Position.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SearchHardStopFB';

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
             OutCmd.InClamping        := _response.InClamping;
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
// Table 6-406: Received CMD payload (RC to PLC) of "SearchHardStop"
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
// Byte 05 :         - Progress LW LB
// Byte 06 : REAL    - RemainingDistance HW HB
// Byte 07 :         - RemainingDistance HW LB
// Byte 08 :         - RemainingDistance LW HB
// Byte 09 :         - RemainingDistance LW LB
// Byte 10 : BOOL    - InClamping

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.Progress
  _response.Progress := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance := ResponseData.GetReal();
  // Get Response.InClamping
  _response.InClamping := ResponseData.GetBool();
  
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
  
  // Create log entry for InClamping
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InClamping = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.InClamping));

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

