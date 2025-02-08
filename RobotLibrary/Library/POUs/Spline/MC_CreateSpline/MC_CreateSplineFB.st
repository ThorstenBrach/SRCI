/// Create spline on RC from positions stored in PLC
FUNCTION_BLOCK MC_CreateSplineFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CreateSplineFB                                       
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
  /// command parameter 
  ParCmd          : CreateSplineParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command results
  OutCmd          : CreateSplineOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CreateSplineParCmd;
  /// command data to send
 _command         : CreateSplineSendData;
  /// response data received
 _response        : CreateSplineRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.CreateSpline;
  
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
// Table 6-754: Sent CMD payload (PLC to RC) of "CreateSpline"
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
// Byte 04 : UINT  Mode;
// Byte 05 : SINT  SplineID;
// Byte 06 : UINT  SplineData.VelocityRate;
// Byte 07 :       SplineData.VelocityRate;
// Byte 08 : UINT  SplineData.AccelerationRate;
// Byte 09 :       SplineData.AccelerationRate;
// Byte 10 : UINT  SplineData.DecelerationRate;
// Byte 11 :       SplineData.DecelerationRate;
// Byte 12 : UINT  SplineData.JerkRate;
// Byte 13 :       SplineData.JerkRate;
// Byte 14 : USINT SplineData.ToolNo;
// Byte 15 : USINT SplineData.FrameNo;
// Byte 16 : REAL  SplineData.X;
// Byte 17 :       SplineData.X;
// Byte 18 :       SplineData.X;
// Byte 19 :       SplineData.X;
// Byte 20 : REAL  SplineData.Y;
// Byte 21 :       SplineData.Y;
// Byte 22 :       SplineData.Y;
// Byte 23 :       SplineData.Y;
// Byte 24 : REAL  SplineData.Z;
// Byte 25 :       SplineData.Z;
// Byte 26 :       SplineData.Z;
// Byte 27 :       SplineData.Z;
// Byte 28 : REAL  SplineData.RX;
// Byte 29 :       SplineData.RX;
// Byte 30 :       SplineData.RX;
// Byte 31 :       SplineData.RX;
// Byte 32 : REAL  SplineData.RY;
// Byte 33 :       SplineData.RY;
// Byte 34 :       SplineData.RY;
// Byte 35 :       SplineData.RY;
// Byte 36 : REAL  SplineData.RZ;
// Byte 37 :       SplineData.RZ;
// Byte 38 :       SplineData.RZ;
// Byte 39 :       SplineData.RZ;
// Byte 40 : BYTE  - - - - - W E S;
// Byte 41 : BYTE  Reserved;
// Byte 42 : BYTE  SplineData.TurnNumber[0];
// Byte 43 : BYTE  SplineData.TurnNumber[1];
// Byte 44 : BYTE  SplineData.TurnNumber[2];
// Byte 45 : BYTE  SplineData.TurnNumber[3];
// Byte 46 : REAL  SplineData.E1;
// Byte 47 :       SplineData.E1;
// Byte 48 :       SplineData.E1;
// Byte 49 :       SplineData.E1;
// Byte 50 : UINT  SplineData.Time;
// Byte 51 :       SplineData.Time;
// Byte 52 : REAL  SplineData.E2;
// Byte 53 :       SplineData.E2;
// Byte 54 :       SplineData.E2;
// Byte 55 :       SplineData.E2;
// Byte 56 : REAL  SplineData.E3;
// Byte 57 :       SplineData.E3;
// Byte 58 :       SplineData.E3;
// Byte 59 :       SplineData.E3;
// Byte 60 : REAL  SplineData.E4;
// Byte 61 :       SplineData.E4;
// Byte 62 :       SplineData.E4;
// Byte 63 :       SplineData.E4;
// Byte 64 : REAL  SplineData.E5;
// Byte 65 :       SplineData.E5;
// Byte 66 :       SplineData.E5;
// Byte 67 :       SplineData.E5;
// Byte 68 : REAL  SplineData.E6;
// Byte 69 :       SplineData.E6;
// Byte 70 :       SplineData.E6;
// Byte 71 :       SplineData.E6;
VAR
  /// internal index for loops
  _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp   :=  CmdType.CreateSpline;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  _command.Mode     := _parCmd.Mode;
  _command.SplineID := _parCmd.SplineID;
  
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    _command.SplineData[_idx].VelocityRate     := REAL_TO_PERCENT_UINT(_parCmd.SplineData[_idx].VelocityRate     , IsOptional := FALSE);
    _command.SplineData[_idx].AccelerationRate := REAL_TO_PERCENT_UINT(_parCmd.SplineData[_idx].AccelerationRate , IsOptional := FALSE);
    _command.SplineData[_idx].DecelerationRate := REAL_TO_PERCENT_UINT(_parCmd.SplineData[_idx].DecelerationRate , IsOptional := TRUE );
    _command.SplineData[_idx].JerkRate         := REAL_TO_PERCENT_UINT(_parCmd.SplineData[_idx].JerkRate         , IsOptional := TRUE );
    _command.SplineData[_idx].ToolNo           :=              _parCmd.SplineData[_idx].ToolNo;
    _command.SplineData[_idx].FrameNo          :=              _parCmd.SplineData[_idx].FrameNo;
    _command.SplineData[_idx].MoveTime         := TIME_TO_UINT(_parCmd.SplineData[_idx].MoveTime);
  END_FOR
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // add command.Mode
  CreateCommandPayload.AddUint(_command.Mode);
  // add command.SplineID
  CreateCommandPayload.AddSint(_command.SplineID);
  
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // add command.VelocityRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].VelocityRate);
    // add command.AccelerationRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].AccelerationRate);
    // add command.DecelerationRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].DecelerationRate);
    // add command.JerkRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].JerkRate);
    // add command.ToolNo
    CreateCommandPayload.AddUsint(_command.SplineData[_idx].ToolNo);
    // add command.FrameNo
    CreateCommandPayload.AddUsint(_command.SplineData[_idx].FrameNo);
    // add command.SplineData[_idx].Position.X
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.X);
    // add command.SplineData[_idx].Position.Y
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Y);
    // add command.SplineData[_idx].Position.Z
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Z);
    // add command.SplineData[_idx].Position.Rx
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rx);
    // add command.SplineData[_idx].Position.Ry
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Ry);
    // add command.SplineData[_idx].Position.Rz
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rz);
    // add command.SplineData[_idx].Position.Config
    CreateCommandPayload.AddArmConfig(_command.SplineData[_idx].Position.Config);
    // add command.SplineData[_idx].Position.TurnNumber
    CreateCommandPayload.AddTurnNumber(_command.SplineData[_idx].Position.TurnNumber);
    // add command.SplineData[_idx].Position.E1
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E1);
    // add command.SplineData[_idx].MoveTime
    CreateCommandPayload.AddUint(_command.SplineData[_idx].MoveTime);  
    // add command.SplineData[_idx].Position.E2
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E2);
    // add command.SplineData[_idx].Position.E3
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E3);
    // add command.SplineData[_idx].Position.E4
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E4);
    // add command.SplineData[_idx].Position.E5
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E5);
    // add command.SplineData[_idx].Position.E6
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E6);
  END_FOR
  
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
  
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  SPLINE_MODE_TO_STRING(_command.Mode));
  
  // Create log entry for SplineID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SplineID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.SplineID));
  
  // Create log entry for SplineData[x]
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // Create log entry for VelocityRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].VelocityRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].VelocityRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for AccelerationRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].AccelerationRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].AccelerationRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for DecelerationRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].DecelerationRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].DecelerationRate),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for JerkRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].JerkRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].JerkRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
                            
    // Create log entry for ToolNo
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].ToolNo = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SplineData[_idx].ToolNo),
                            Para2       :=  DINT_TO_STRING(_idx));
    
    // Create log entry for FrameNo
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].FrameNo = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SplineData[_idx].FrameNo),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.X
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.X = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.X),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.Y
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Y = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Y),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.Z
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Z = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Z),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.Rx
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Rx = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Rx),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.Ry
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Ry = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Ry),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.Rz
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Rz = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Rz),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.Config
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Config = {1}',
                            Para1       :=  ARM_CONFIG_TO_STRING(_command.SplineData[_idx].Position.Config),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.TurnNumber[0]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[0] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J2Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J1Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.TurnNumber[1]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[1] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J4Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J3Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.TurnNumber[2]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[2] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J6Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J5Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.TurnNumber[3]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[3] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.SplineData[_idx].Position.TurnNumber.E1Turns),                          
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.E1
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E1 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E1),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for MoveTime
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].MoveTime = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].MoveTime),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.E2
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E2 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E2),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.E3
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E3 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E3),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Position.E4
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E4 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E4),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.E5
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E5 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E5),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Position.E6
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E6 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E6),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CreateSplineFB';
  
  ExecMode := ExecutionMode.PARALLEL;

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
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED : CommandBuffered := TRUE;
             CmdMessageState.DONE     : Done            := TRUE;
             CmdMessageState.ERROR    : Error           := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
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
// Table 6-755: Received CMD payload (RC to PLC) of "CreateSpline"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT   - ParSeq | State     
// Byte 01 : SINT    - AlarmMessageSeverity    
// Byte 02 : UINT    - AlarmMessageCode HB
// Byte 03 :         - AlarmMessageCode LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
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
                          
  // Create log entry for no parameter 
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'This command has no parameter to parse...');

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

