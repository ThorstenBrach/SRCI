/// Calculate cartesian position from existing cartesian position
FUNCTION_BLOCK MC_CalculateCartesianPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateCartesianPositionFB                                       
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
  /// Command parameter 
  ParCmd          : CalculateCartesianPositionParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateCartesianPositionOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateCartesianPositionParCmd;
  /// command data to send
 _command         : CalculateCartesianPositionSendData;
  /// response data received
 _response        : CalculateCartesianPositionRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD INTERNAL CheckAddParameter : BOOL
VAR_INPUT
  /// Payload pointer
  PayloadPtr : UDINT;
END_VAR
VAR
  /// Payload as byte array
  Payload    : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Null Byte array 
  Null       : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Data length to compare
  DataLen    : UDINT;
END_VAR

  // Payload pointer must be decreased by one byte, because ADR(Payload) is already one byte !
  PayloadPtr := LIMIT (0, PayloadPtr - 1, SIZEOF(Payload) -1);
  // Convert command struct to payload array
  SysDepMemCpy( pDest := ADR(Payload), pSrc := ADR(_command), DataLen := SIZEOF(_command));
  // Calculate the data length to compare - at least one byte must be compared !
  DataLen := LIMIT(1, SIZEOF(Payload) - PayloadPtr, SIZEOF(Payload)); 
  // Compare Payload-Array with Null-Byte-Array
  CheckAddParameter := SysDepMemCmp( pData1 := ADR(Payload) + PayloadPtr , pData2 := ADR(Null), DataLen := DataLen) <>  RobotLibraryConstants.OK ;

END_METHOD

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.CalculateCartesianPosition;
  
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
  IF (SIZEOF(ParCmd) = 0) OR (_stepCmd = 0)
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

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  CheckParameterValid := TRUE;
  
  // Check ParCmd.CartesianPosition.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.X) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.Y) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.Z) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.Rx) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.Ry) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.Rz) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E1) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E2) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E3) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E4) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E5) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.CartesianPosition.E6) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.CartesianPosition.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Config.Shoulder valid ? 
  IF (( ParCmd.CartesianPosition.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.CartesianPosition.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.CartesianPosition.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.CartesianPosition.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.CartesianPosition.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_SHOULDER_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.CartesianPosition.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Config.Elbow valid ? 
  IF (( ParCmd.CartesianPosition.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.CartesianPosition.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.CartesianPosition.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.CartesianPosition.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.CartesianPosition.Config.Elbow <> ArmConfigElbow.UP         ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_ELBOW_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.CartesianPosition.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CartesianPosition.Config.Wrist valid ? 
  IF (( ParCmd.CartesianPosition.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.CartesianPosition.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.CartesianPosition.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.CartesianPosition.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.CartesianPosition.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_WRIST_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CartesianPosition.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.CartesianPosition.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <   0                                                 ) OR   
      ( ParCmd.FrameNo > 254                                                 ) OR
      ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex ) OR
      ( ParCmd.FrameNo > RobotLibraryParameter.FRAME_MAX -1                  ))         
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check FrameNo available on RC ? 
    IF ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.FrameNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.FrameNo));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.TargetFrameNo valid ? 
  IF (( ParCmd.TargetFrameNo <   0 ) OR   
      ( ParCmd.TargetFrameNo > 254 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetFrameNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.TargetFrameNo));                            
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-645: Received CMD payload (RC to PLC) of "CalculateCartesianPosition"
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
// Byte 04 : USINT      - FrameNo
// Byte 05 : USINT      - TargetFrameNo
// Byte 06 : REAL       - Position.X  HW HB
// Byte 07 :            - Position.X  HW LB
// Byte 08 :            - Position.X  LW HB
// Byte 09 :            - Position.X  LW LB
// Byte 10 : REAL       - Position.Y  HW HB
// Byte 11 :            - Position.Y  HW LB
// Byte 12 :            - Position.Y  LW HB
// Byte 13 :            - Position.Y  LW LB
// Byte 14 : REAL       - Position.Z  HW HB
// Byte 15 :            - Position.Z  HW LB
// Byte 16 :            - Position.Z  LW HB
// Byte 17 :            - Position.Z  LW LB
// Byte 18 : REAL       - Position.Rx HW HB
// Byte 19 :            - Position.Rx HW LB
// Byte 20 :            - Position.Rx LW HB
// Byte 21 :            - Position.Rx LW LB
// Byte 22 : REAL       - Position.Ry HW HB
// Byte 23 :            - Position.Ry HW LB
// Byte 24 :            - Position.Ry LW HB
// Byte 25 :            - Position.Ry LW LB
// Byte 26 : REAL       - Position.Rz HW HB
// Byte 27 :            - Position.Rz HW LB
// Byte 28 :            - Position.Rz LW HB
// Byte 29 :            - Position.Rz LW LB
// Byte 30 : Config     - ArmConfig   LW HB
// Byte 31 :            - ArmConfig   LW LB
// Byte 32 : TurnNumber - J1 + J2     LW HB
// Byte 33 :            - J3 + J4     LW LB
// Byte 34 :            - J5 + J6     LW LB
// Byte 35 :            - E1          LW LB
// Byte 36 : REAL       - Position.E1 HW HB
// Byte 37 :            - Position.E1 HW LB
// Byte 38 :            - Position.E1 LW HB
// Byte 39 :            - Position.E1 LW LB
// Byte 40 : REAL       - Position.E2 HW HB
// Byte 41 :            - Position.E2 HW LB
// Byte 42 :            - Position.E2 LW HB
// Byte 43 :            - Position.E2 LW LB
// Byte 44 : REAL       - Position.E3 HW HB
// Byte 45 :            - Position.E3 HW LB
// Byte 46 :            - Position.E3 LW HB
// Byte 47 :            - Position.E3 LW LB
// Byte 48 : REAL       - Position.E4 HW HB
// Byte 49 :            - Position.E4 HW LB
// Byte 50 :            - Position.E4 LW HB
// Byte 51 :            - Position.E4 LW LB
// Byte 52 : REAL       - Position.E5 HW HB
// Byte 53 :            - Position.E5 HW LB
// Byte 54 :            - Position.E5 LW HB
// Byte 55 :            - Position.E5 LW LB
// Byte 56 : REAL       - Position.E6 HW HB
// Byte 57 :            - Position.E6 HW LB
// Byte 58 :            - Position.E6 LW HB
// Byte 59 :            - Position.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.CalculateCartesianPosition;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.TargetFrameNo     := _parCmd.TargetFrameNo;
  _command.CartesianPosition := _parCmd.CartesianPosition;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.FrameNo
    CreateCommandPayload.AddUsint(_command.FrameNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetFrameNo
    CreateCommandPayload.AddUsint(_command.TargetFrameNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.X
    CreateCommandPayload.AddReal(_command.CartesianPosition.X);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Y
    CreateCommandPayload.AddReal(_command.CartesianPosition.Y);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Z
    CreateCommandPayload.AddReal(_command.CartesianPosition.Z);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Rx
    CreateCommandPayload.AddReal(_command.CartesianPosition.Rx);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Ry
    CreateCommandPayload.AddReal(_command.CartesianPosition.Ry);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Rz
    CreateCommandPayload.AddReal(_command.CartesianPosition.Rz);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.Config
    CreateCommandPayload.AddArmConfig(_command.CartesianPosition.Config);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.TurnNumber
    CreateCommandPayload.AddTurnNumber(_command.CartesianPosition.TurnNumber);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E1
    CreateCommandPayload.AddReal(_command.CartesianPosition.E1);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E2
    CreateCommandPayload.AddReal(_command.CartesianPosition.E2);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E3
    CreateCommandPayload.AddReal(_command.CartesianPosition.E3);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E4
    CreateCommandPayload.AddReal(_command.CartesianPosition.E4);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E5
    CreateCommandPayload.AddReal(_command.CartesianPosition.E5);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CartesianPosition.E6
    CreateCommandPayload.AddReal(_command.CartesianPosition.E6);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
    
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog 
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR_INPUT
  /// Parameter count
  ParameterCnt : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetFrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetFrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.TargetFrameNo));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.Y));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.Rx));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.CartesianPosition.Config));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.CartesianPosition.TurnNumber.J2Turns, 
                                                                          HalfSintLo := _command.CartesianPosition.TurnNumber.J1Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.CartesianPosition.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.CartesianPosition.TurnNumber.J3Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.CartesianPosition.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.CartesianPosition.TurnNumber.J5Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.CartesianPosition.TurnNumber.E1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPosition.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CartesianPosition.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.CartesianPosition.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CalculateCartesianPositionFB';
  
  ExecMode := ExecutionMode.PARALLEL;
  Priority := PriorityLevel.NORMAL;

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _execute_R.Q ) AND ( NOT Error)  
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
             // Update results
             OutCmd.TargetToolNoReturn      := _response.TargetToolNoReturn;
             OutCmd.TargetFrameNoReturn     := _response.TargetFrameNoReturn;
             OutCmd.CartesianPositionReturn := _response.CartesianPositionReturn;
  
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
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
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
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-645: Received CMD payload (RC to PLC) of "CalculateCartesianPosition"
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
// Byte 04 : USINT      - TargetToolNoReturn
// Byte 05 : USINT      - TargetFrameNoReturn
// Byte 06 : REAL       - Position.X  HW HB
// Byte 07 :            - Position.X  HW LB
// Byte 08 :            - Position.X  LW HB
// Byte 09 :            - Position.X  LW LB
// Byte 10 : REAL       - Position.Y  HW HB
// Byte 11 :            - Position.Y  HW LB
// Byte 12 :            - Position.Y  LW HB
// Byte 13 :            - Position.Y  LW LB
// Byte 14 : REAL       - Position.Z  HW HB
// Byte 15 :            - Position.Z  HW LB
// Byte 16 :            - Position.Z  LW HB
// Byte 17 :            - Position.Z  LW LB
// Byte 18 : REAL       - Position.Rx HW HB
// Byte 19 :            - Position.Rx HW LB
// Byte 20 :            - Position.Rx LW HB
// Byte 21 :            - Position.Rx LW LB
// Byte 22 : REAL       - Position.Ry HW HB
// Byte 23 :            - Position.Ry HW LB
// Byte 24 :            - Position.Ry LW HB
// Byte 25 :            - Position.Ry LW LB
// Byte 26 : REAL       - Position.Rz HW HB
// Byte 27 :            - Position.Rz HW LB
// Byte 28 :            - Position.Rz LW HB
// Byte 29 :            - Position.Rz LW LB
// Byte 30 : Config     - ArmConfig   LW HB
// Byte 31 :            - ArmConfig   LW LB
// Byte 32 : TurnNumber - J1 + J2     LW HB
// Byte 33 :            - J3 + J4     LW LB
// Byte 34 :            - J5 + J6     LW LB
// Byte 35 :            - E1          LW LB
// Byte 36 : REAL       - Position.E1 HW HB
// Byte 37 :            - Position.E1 HW LB
// Byte 38 :            - Position.E1 LW HB
// Byte 39 :            - Position.E1 LW LB
// Byte 40 : REAL       - Position.E2 HW HB
// Byte 41 :            - Position.E2 HW LB
// Byte 42 :            - Position.E2 LW HB
// Byte 43 :            - Position.E2 LW LB
// Byte 44 : REAL       - Position.E3 HW HB
// Byte 45 :            - Position.E3 HW LB
// Byte 46 :            - Position.E3 LW HB
// Byte 47 :            - Position.E3 LW LB
// Byte 48 : REAL       - Position.E4 HW HB
// Byte 49 :            - Position.E4 HW LB
// Byte 50 :            - Position.E4 LW HB
// Byte 51 :            - Position.E4 LW LB
// Byte 52 : REAL       - Position.E5 HW HB
// Byte 53 :            - Position.E5 HW LB
// Byte 54 :            - Position.E5 LW HB
// Byte 55 :            - Position.E5 LW LB
// Byte 56 : REAL       - Position.E6 HW HB
// Byte 57 :            - Position.E6 HW LB
// Byte 58 :            - Position.E6 LW HB
// Byte 59 :            - Position.E6 LW LB
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get TargetToolNoReturn
   _response.TargetToolNoReturn   := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get TargetFrameNoReturn
   _response.TargetFrameNoReturn  := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.X
   _response.CartesianPositionReturn.X := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Y
   _response.CartesianPositionReturn.Y := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Z
   _response.CartesianPositionReturn.Z := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Rx
   _response.CartesianPositionReturn.Rx := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Ry
   _response.CartesianPositionReturn.Ry := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Rz
   _response.CartesianPositionReturn.Rz := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.Config
   _response.CartesianPositionReturn.Config := ResponseData.GetArmConfig();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.TurnNumber
   _response.CartesianPositionReturn.TurnNumber := ResponseData.GetTurnNumbers();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E1
   _response.CartesianPositionReturn.E1 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E2
   _response.CartesianPositionReturn.E2 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E3
   _response.CartesianPositionReturn.E3 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E4
   _response.CartesianPositionReturn.E4 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E5
   _response.CartesianPositionReturn.E5 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get CartesianPositionReturn.E6
   _response.CartesianPositionReturn.E6 := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
   
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
  /// Parameter count
  ParameterCnt : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '{1} parameter(s) to parse from the response data:',
                          Para1       := DINT_TO_STRING(ParameterCnt));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetToolNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TargetToolNoReturn = {1}',
                          Para1       :=  USINT_TO_STRING(_response.TargetToolNoReturn));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetFrameNoReturn
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TargetFrameNoReturn = {1}',
                          Para1       :=  USINT_TO_STRING(_response.TargetFrameNoReturn));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.Y));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.Rx));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.Config
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_response.CartesianPositionReturn.Config));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J2Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J2Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J2Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J3Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J3Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J3Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J4Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J4Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J4Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J5Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J5Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J5Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.J6Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.J6Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.J6Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.TurnNumber.E1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.TurnNumber.E1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.CartesianPositionReturn.TurnNumber.E1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E3
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E4
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E5
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CartesianPositionReturn.E6
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.CartesianPositionReturn.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.CartesianPositionReturn.E6));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

