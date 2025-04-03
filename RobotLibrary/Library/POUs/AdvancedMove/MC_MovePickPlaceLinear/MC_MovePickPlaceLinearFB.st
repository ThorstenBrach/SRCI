/// Command several interpolated movement of robot arm on linear paths from actual position
FUNCTION_BLOCK MC_MovePickPlaceLinearFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MovePickPlaceLinearFB                                       
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
  ParCmd             : MovePickPlaceLinearParCmd;       
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
  OutCmd             : MovePickPlaceLinearOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MovePickPlaceLinearParCmd;
  /// command data to send
 _command            : MovePickPlaceLinearSendData;
  /// response data received
 _response           : MovePickPlaceLinearRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.MovePickPlaceLinear;
  
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
  
  // Check AbortingMode valid ? 
  IF (( AbortingMode <> AbortingModeEnum.BUFFER ) AND
      ( AbortingMode <> AbortingModeEnum.ABORT  ))  
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_ABORTINGMODE_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter AbortingMode = {1}',
                            Para1       := ABORTING_MODE_TO_STRING(AbortingMode));
    RETURN;                          
  END_IF
  
  
  // Check SequenceFlag valid ? 
  IF (( SequenceFlag <> SequenceFlagEnum.PRIMARY_SEQUENCE   ) AND
      ( SequenceFlag <> SequenceFlagEnum.SECONDARY_SEQUENCE ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_SEQFLAG_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter SequenceFlag = {1}',
                            Para1       := SEQUENCE_FLAG_TO_STRING(SequenceFlag));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.X) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.Y) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.Z) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.Rx) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.Ry) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.Rz) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E1) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E2) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E3) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E4) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E5) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.E6) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TargetPosition.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Config.Shoulder valid ? 
  IF (( ParCmd.TargetPosition.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.TargetPosition.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.TargetPosition.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.TargetPosition.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.TargetPosition.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_SHOULDER_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.TargetPosition.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Config.Elbow valid ? 
  IF (( ParCmd.TargetPosition.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.TargetPosition.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.TargetPosition.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.TargetPosition.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.TargetPosition.Config.Elbow <> ArmConfigElbow.UP         ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_ELBOW_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.TargetPosition.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TargetPosition.Config.Wrist valid ? 
  IF (( ParCmd.TargetPosition.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.TargetPosition.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.TargetPosition.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.TargetPosition.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.TargetPosition.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_WRIST_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.TargetPosition.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.X) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.Y) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.Z) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.Rx) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.Ry) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ApproachOffset.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.ApproachOffset.Rz) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ApproachOffset.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ApproachOffset.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.X) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.Y) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.Z) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.Rx) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.Ry) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DepartOffset.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.DepartOffset.Rz) = FALSE ) 
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DepartOffset.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DepartOffset.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReferenceType valid ? 
  IF (( ParCmd.ReferenceType <> ReferenceType.TOOL  ) AND
      ( ParCmd.ReferenceType <> ReferenceType.FRAME ))  
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ReferenceType = {1}',
                            Para1       := REFERENCE_TYPE_TO_STRING(ParCmd.ReferenceType));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.VelocityRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.VelocityRate) = FALSE )  OR
      ((                   ParCmd.VelocityRate  <     0 )  AND 
       (                   ParCmd.VelocityRate <>    -1 )) OR   
       (                   ParCmd.VelocityRate  >   100 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.VelocityRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.VelocityRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.AccelerationRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.AccelerationRate) = FALSE )  OR
      ((                   ParCmd.AccelerationRate  <     0 )  AND 
       (                   ParCmd.AccelerationRate <>    -1 )) OR   
       (                   ParCmd.AccelerationRate  >   100 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_ACCELERATION_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.AccelerationRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.AccelerationRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.DecelerationRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.DecelerationRate) = FALSE )  OR
      ((                   ParCmd.DecelerationRate  <     0 )  AND 
       (                   ParCmd.DecelerationRate <>    -1 )) OR   
       (                   ParCmd.DecelerationRate  >   100 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_DECELERATION_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.DecelerationRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DecelerationRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.JerkRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.JerkRate) = FALSE )  OR
      ((                   ParCmd.JerkRate  <     0 )  AND 
       (                   ParCmd.JerkRate <>    -1 )) OR   
       (                   ParCmd.JerkRate  >   100 ))      
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_JERK_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.JerkRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.JerkRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <   0 ) OR   
      ( ParCmd.ToolNo > 254 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ToolNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.ToolNo));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <   0 ) OR   
      ( ParCmd.FrameNo > 254 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.FrameNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.FrameNo));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.AuxCornerDistance_1 valid ? 
  IF  ( SysDepIsValidReal(ParCmd.AuxCornerDistance_1) = FALSE )
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.AuxCornerDistance_1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.AuxCornerDistance_1));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.AuxCornerDistance_2 valid ? 
  IF  ( SysDepIsValidReal(ParCmd.AuxCornerDistance_2) = FALSE )
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.AuxCornerDistance_2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.AuxCornerDistance_2));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.MoveTime valid ? 
  IF  ( ParCmd.MoveTime < T#0S )
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.MoveTime = {1}',
                            Para1       := TIME_TO_STRING(ParCmd.MoveTime));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.BlendingMode valid ? 
  IF (( ParCmd.OriMode <> OriMode.LINEAR_INTERPOLATED ) AND   
      ( ParCmd.OriMode <> OriMode.JOINT_INTERPOLATED  ) AND
      ( ParCmd.OriMode <> OriMode.FIX                 ) AND
      ( ParCmd.OriMode <> OriMode.PATH                ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.OriMode = {1}',
                            Para1       := ORI_MODE_TO_STRING(ParCmd.OriMode));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.ConfigMode.Shoulder valid ? 
  IF (( ParCmd.ConfigMode.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.ConfigMode.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.ConfigMode.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.ConfigMode.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.ConfigMode.Shoulder <> ArmConfigShoulder.FRONT      ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ConfigMode.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.ConfigMode.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConfigMode.Elbow valid ? 
  IF (( ParCmd.ConfigMode.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.ConfigMode.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.ConfigMode.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.ConfigMode.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.ConfigMode.Elbow <> ArmConfigElbow.UP         ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ConfigMode.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.ConfigMode.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConfigMode.Wrist valid ? 
  IF (( ParCmd.ConfigMode.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.ConfigMode.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.ConfigMode.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.ConfigMode.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.ConfigMode.Wrist <> ArmConfigWrist.NON_FLIP   ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ConfigMode.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.ConfigMode.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TurnMode valid ? 
  IF (( ParCmd.TurnMode <> TurnMode.USE_TURN_NUMBER ) AND  
      ( ParCmd.TurnMode <> TurnMode.SAME            ) AND
      ( ParCmd.TurnMode <> TurnMode.FREE            ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TurnMode = {1}',
                            Para1       :=  TURN_MODE_TO_STRING(ParCmd.TurnMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.VelocityCoefficient valid ? 
  IF  ( SysDepIsValidReal(ParCmd.VelocityCoefficient) = FALSE )
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_JERK_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.VelocityCoefficient = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.VelocityCoefficient));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.Manipulation
  // -> no plausibility check for boolean
  
  
  FOR _idx := 0 TO 3 
  DO
    // Check ParCmd.EmitterID valid ? 
    IF  (( ParCmd.EmitterID[_idx] < -127 ) OR
         ( ParCmd.EmitterID[_idx] >  127 ))     
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.EmitterID[{2}] = {1}',
                              Para1       := SINT_TO_STRING(ParCmd.EmitterID[_idx]),
                              Para2       := DINT_TO_STRING(_idx));       
      EXIT;                     
      RETURN;
    END_IF
  END_FOR

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-421: Sent CMD payload (PLC to RC) of "MovePickPlaceLinear"
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
// Byte 04 : SINT  - EmitterID[0];
// Byte 05 : SINT  - EmitterID[1];
// Byte 06 : SINT  - EmitterID[2];
// Byte 07 : SINT  - EmitterID[3];
// Byte 08 : SINT  - ListenerID;
// Byte 09 : BYTE  - Reserved;
// Byte 10 : UINT  - VelocityRate HB;
// Byte 11 :       - VelocityRate LB;
// Byte 12 : UINT  - AccelerationRate HW HB;
// Byte 13 :       - AccelerationRate HW LB;
// Byte 14 : UINT  - DecelerationRate HW HB;
// Byte 15 :       - DecelerationRate HW LB;
// Byte 16 : UINT  - JerkRate HB;
// Byte 17 :       - JerkRate LB;
// Byte 18 : USINT - ToolNo;
// Byte 19 : USINT - FrameNo;
// Byte 20 : USINT - BlendingMode;
// Byte 21 : USINT - OriMode;
// Byte 22 : REAL  - BlendingParameter[0] HW HB;
// Byte 23 :       - BlendingParameter[0] HW LB;
// Byte 24 :       - BlendingParameter[0] LW HB;
// Byte 25 :       - BlendingParameter[0] LW LB;
// Byte 26 : REAL  - BlendingParameter[1] HW HB;
// Byte 27 :       - BlendingParameter[1] HW LB;
// Byte 28 :       - BlendingParameter[1] LW HB;
// Byte 29 :       - BlendingParameter[1] LW LB;
// Byte 30 : REAL  - TargetPosition.X HW HB;
// Byte 31 :       - TargetPosition.X HW LB;
// Byte 32 :       - TargetPosition.X LW HB;
// Byte 33 :       - TargetPosition.X LW LB;
// Byte 34 : REAL  - TargetPosition.Y HW HB;
// Byte 35 :       - TargetPosition.Y HW LB;
// Byte 36 :       - TargetPosition.Y LW HB;
// Byte 37 :       - TargetPosition.Y LW LB;
// Byte 38 : REAL  - TargetPosition.Z HW HB;
// Byte 39 :       - TargetPosition.Z HW LB;
// Byte 40 :       - TargetPosition.Z LW HB;
// Byte 41 :       - TargetPosition.Z LW LB;
// Byte 42 : REAL  - TargetPosition.RX HW HB;
// Byte 43 :       - TargetPosition.RX HW LB;
// Byte 44 :       - TargetPosition.RX LW HB;
// Byte 45 :       - TargetPosition.RX LW LB;
// Byte 46 : REAL  - TargetPosition.RY HW HB;
// Byte 47 :       - TargetPosition.RY HW LB;
// Byte 48 :       - TargetPosition.RY LW HB;
// Byte 49 :       - TargetPosition.RY LW LB;
// Byte 50 : REAL  - TargetPosition.RZ HW HB;
// Byte 51 :       - TargetPosition.RZ HW LB;
// Byte 52 :       - TargetPosition.RZ LW HB;
// Byte 53 :       - TargetPosition.RZ LW LB;
// Byte 54 : BYTE  - - - - - - W E S;
// Byte 55 : BYTE  - Reserved;
// Byte 56 : BYTE  - TargetPosition.TurnNumber[0];
// Byte 57 : BYTE  - TargetPosition.TurnNumber[1];
// Byte 58 : BYTE  - TargetPosition.TurnNumber[2];
// Byte 59 : BYTE  - TargetPosition.TurnNumber[3];
// Byte 60 : REAL  - TargetPosition.E1 HW HB;
// Byte 61 :       - TargetPosition.E1 HW LB;
// Byte 62 :       - TargetPosition.E1 LW HB;
// Byte 63 :       - TargetPosition.E1 LW LB;
// Byte 64 : REAL  - ApproachOffset.X HW HB;
// Byte 65 :       - ApproachOffset.X HW LB;
// Byte 66 :       - ApproachOffset.X LW HB;
// Byte 67 :       - ApproachOffset.X LW LB;
// Byte 68 : REAL  - ApproachOffset.Y HW HB;
// Byte 69 :       - ApproachOffset.Y HW LB;
// Byte 70 :       - ApproachOffset.Y LW HB;
// Byte 71 :       - ApproachOffset.Y LW LB;
// Byte 72 : REAL  - ApproachOffset.Z HW HB;
// Byte 73 :       - ApproachOffset.Z HW LB;
// Byte 74 :       - ApproachOffset.Z LW HB;
// Byte 75 :       - ApproachOffset.Z LW LB;
// Byte 76 : REAL  - ApproachOffset.RX HW HB;
// Byte 77 :       - ApproachOffset.RX HW LB;
// Byte 78 :       - ApproachOffset.RX LW HB;
// Byte 79 :       - ApproachOffset.RX LW LB;
// Byte 80 : REAL  - ApproachOffset.RY HW HB;
// Byte 81 :       - ApproachOffset.RY HW LB;
// Byte 82 :       - ApproachOffset.RY LW HB;
// Byte 83 :       - ApproachOffset.RY LW LB;
// Byte 84 : REAL  - ApproachOffset.RZ HW HB;
// Byte 85 :       - ApproachOffset.RZ HW LB;
// Byte 86 :       - ApproachOffset.RZ LW HB;
// Byte 87 :       - ApproachOffset.RZ LW LB;
// Byte 88 : REAL  - DepartOffset.X HW HB;
// Byte 89 :       - DepartOffset.X HW LB;
// Byte 90 :       - DepartOffset.X LW HB;
// Byte 91 :       - DepartOffset.X LW LB;
// Byte 92 : REAL  - DepartOffset.Y HW HB;
// Byte 93 :       - DepartOffset.Y HW LB;
// Byte 94 :       - DepartOffset.Y LW HB;
// Byte 95 :       - DepartOffset.Y LW LB;
// Byte 96 : REAL  - DepartOffset.Z HW HB;
// Byte 97 :       - DepartOffset.Z HW LB;
// Byte 98 :       - DepartOffset.Z LW HB;
// Byte 99 :       - DepartOffset.Z LW LB;
// Byte 100: REAL  - DepartOffset.RX HW HB;
// Byte 101:       - DepartOffset.RX HW LB;
// Byte 102:       - DepartOffset.RX LW HB;
// Byte 103:       - DepartOffset.RX LW LB;
// Byte 104: REAL  - DepartOffset.RY HW HB;
// Byte 105:       - DepartOffset.RY HW LB;
// Byte 106:       - DepartOffset.RY LW HB;
// Byte 107:       - DepartOffset.RY LW LB;
// Byte 108: REAL  - DepartOffset.RZ HW HB;
// Byte 109:       - DepartOffset.RZ HW LB;
// Byte 110:       - DepartOffset.RZ LW HB;
// Byte 111:       - DepartOffset.RZ LW LB;
// Byte 112: REAL  - AuxCornerDistance_1 HW HB;
// Byte 113:       - AuxCornerDistance_1 HW LB;
// Byte 114:       - AuxCornerDistance_1 LW HB;
// Byte 115:       - AuxCornerDistance_1 LW LB;
// Byte 116: REAL  - AuxCornerDistance_2 HW HB;
// Byte 117:       - AuxCornerDistance_2 HW LB;
// Byte 118:       - AuxCornerDistance_2 LW HB;
// Byte 119:       - AuxCornerDistance_2 LW LB;
// Byte 120: REAL  - VelocityCoefficient HW HB;
// Byte 121:       - VelocityCoefficient HW LB;
// Byte 122:       - VelocityCoefficient LW HB;
// Byte 123:       - VelocityCoefficient LW LB;
// Byte 124: BOOL  - Manipulation;
// Byte 125: BYTE  - ConfigMode[0];
// Byte 126: BYTE  - ConfigMode[1];
// Byte 127: BYTE  - ReferenceType;
// Byte 128: USINT - TurnMode;
// Byte 129: UINT  - Time HB;
// Byte 130:       - Time LB;
// Byte 131: REAL  - TargetPosition.E2 HW HB;
// Byte 132:       - TargetPosition.E2 HW LB;
// Byte 133:       - TargetPosition.E2 LW HB;
// Byte 134:       - TargetPosition.E2 LW LB;
// Byte 135: REAL  - TargetPosition.E3 HW HB;
// Byte 136:       - TargetPosition.E3 HW LB;
// Byte 137:       - TargetPosition.E3 LW HB;
// Byte 138:       - TargetPosition.E3 LW LB;
// Byte 139: REAL  - TargetPosition.E4 HW HB;
// Byte 140:       - TargetPosition.E4 HW LB;
// Byte 141:       - TargetPosition.E4 LW HB;
// Byte 142:       - TargetPosition.E4 LW LB;
// Byte 143: REAL  - TargetPosition.E5 HW HB;
// Byte 144:       - TargetPosition.E5 HW LB;
// Byte 145:       - TargetPosition.E5 LW HB;
// Byte 146:       - TargetPosition.E5 LW LB;
// Byte 147: REAL  - TargetPosition.E6 HW HB;
// Byte 148:       - TargetPosition.E6 HW LB;
// Byte 149:       - TargetPosition.E6 LW HB;
// Byte 150:       - TargetPosition.E6 LW LB;
// --------------------------

  // set command parameter 
  _command.CmdTyp              :=  CmdType.MovePickPlaceLinear;
  _command.ExecMode            :=  ExecMode;
  _command.ParSeq              := _command.ParSeq;
  _command.Priority            :=  Priority;
  _command.EmitterID           := _parCmd.EmitterID;
  _command.Reserve             :=  0;
  _command.ListenerID          :=  0; {warning 'ToDo'}
  _command.Reserve             :=  0;
  _command.VelocityRate        :=  REAL_TO_PERCENT_UINT(_parCmd.VelocityRate     , IsOptional := FALSE);
  _command.AccelerationRate    :=  REAL_TO_PERCENT_UINT(_parCmd.AccelerationRate , IsOptional := FALSE);
  _command.DecelerationRate    :=  REAL_TO_PERCENT_UINT(_parCmd.DecelerationRate , IsOptional := TRUE );
  _command.JerkRate            :=  REAL_TO_PERCENT_UINT(_parCmd.JerkRate         , IsOptional := TRUE );
  _command.ToolNo              := _parCmd.ToolNo;
  _command.FrameNo             := _parCmd.FrameNo;
  _command.BlendingMode        := _parCmd.BlendingMode;
  _command.OriMode             := _parCmd.OriMode;
  _command.BlendingParameter   := _parCmd.BlendingParameter;
  _command.TargetPosition      := _parCmd.TargetPosition;
  _command.ApproachOffset      := _parCmd.ApproachOffset;
  _command.DepartOffset        := _parCmd.DepartOffset;
  _command.AuxCornerDistance_1 := _parCmd.AuxCornerDistance_1;
  _command.AuxCornerDistance_2 := _parCmd.AuxCornerDistance_2;
  _command.VelocityCoefficient := _parCmd.VelocityCoefficient;
  _command.Manipulation        := _parCmd.Manipulation;
  _command.ConfigMode          :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.ReferenceType       := _parCmd.ReferenceType;
  _command.TurnMode            := _parCmd.TurnMode;
  _command.MoveTime            := TIME_TO_UINT(_parCmd.MoveTime);
  
  
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
  // add command.ApproachOffset.X
  CreateCommandPayload.AddReal(_command.ApproachOffset.X);
  // add command.ApproachOffset.Y
  CreateCommandPayload.AddReal(_command.ApproachOffset.Y);
  // add command.ApproachOffset.Z
  CreateCommandPayload.AddReal(_command.ApproachOffset.Z);
  // add command.ApproachOffset.Rx
  CreateCommandPayload.AddReal(_command.ApproachOffset.Rx);
  // add command.ApproachOffset.Ry
  CreateCommandPayload.AddReal(_command.ApproachOffset.Ry);
  // add command.ApproachOffset.Rz
  CreateCommandPayload.AddReal(_command.ApproachOffset.Rz);
  // add command.DepartOffset.X
  CreateCommandPayload.AddReal(_command.DepartOffset.X);
  // add command.DepartOffset.Y
  CreateCommandPayload.AddReal(_command.DepartOffset.Y);
  // add command.DepartOffset.Z
  CreateCommandPayload.AddReal(_command.DepartOffset.Z);
  // add command.DepartOffset.Rx
  CreateCommandPayload.AddReal(_command.DepartOffset.Rx);
  // add command.DepartOffset.Ry
  CreateCommandPayload.AddReal(_command.DepartOffset.Ry);
  // add command.DepartOffset.Rz
  CreateCommandPayload.AddReal(_command.DepartOffset.Rz);
  // add command.AuxCornerDistance_1
  CreateCommandPayload.AddReal(_command.AuxCornerDistance_1);
  // add command.AuxCornerDistance_2
  CreateCommandPayload.AddReal(_command.AuxCornerDistance_2);
  // add command.VelocityCoefficient
  CreateCommandPayload.AddReal(_command.VelocityCoefficient);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
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
  
  // Create log entry for TargetPosition.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.TargetPosition.Config));
  
  // Create log entry for TargetPosition.Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(0));
  
  // Create log entry for TargetPosition.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J1Turns)));
  
  // Create log entry for TargetPosition.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J3Turns)));
  
  // Create log entry for TargetPosition.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J5Turns)));
  
  // Create log entry for TargetPosition.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.TargetPosition.TurnNumber.E1Turns));
  
  // Create log entry for TargetPosition.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E1));
                          
  // Create log entry for ApproachOffset.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.X));
  
  // Create log entry for ApproachOffset.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.Y));
  
  // Create log entry for ApproachOffset.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.Z));
  
  // Create log entry for ApproachOffset.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.Rx));
  
  // Create log entry for ApproachOffset.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.Ry));
  
  // Create log entry for ApproachOffset.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ApproachOffset.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ApproachOffset.Rz));                        
  
  // Create log entry for DepartOffset.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.X));
  
  // Create log entry for DepartOffset.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.Y));
  
  // Create log entry for DepartOffset.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.Z));
  
  // Create log entry for DepartOffset.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.Rx));
  
  // Create log entry for DepartOffset.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.Ry));
  
  // Create log entry for DepartOffset.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DepartOffset.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.DepartOffset.Rz));
  
  // Create log entry for AuxCornerDistance_1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxCornerDistance_1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxCornerDistance_1));
  
  // Create log entry for AuxCornerDistance_2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxCornerDistance_2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxCornerDistance_2));
                         
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

  MyType := 'MC_MovePickPlaceLinearFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
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
             OutCmd.Progress          :=  PERCENT_UINT_TO_REAL( Value := _response.Progress, IsOptional := FALSE);
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
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-422: Received CMD payload (RC to PLC) of "MovePickPlaceLinear"
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
// Byte 06 : INT        - OriginID HB
// Byte 07 :            - OriginID LB
// Byte 08 : UINT       - Progress HB
// Byte 09 :            - Progress LB
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
  ResponseData : RobotLibraryResponseDataFB;
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

