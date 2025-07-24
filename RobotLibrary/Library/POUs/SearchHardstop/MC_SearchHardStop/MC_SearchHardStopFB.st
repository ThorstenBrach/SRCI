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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.SearchHardstop;
  
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter SequenceFlag = {1}',
                            Para1       := SEQUENCE_FLAG_TO_STRING(SequenceFlag));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Config.Shoulder valid ? 
  IF (( ParCmd.Position.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.Position.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.Position.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.Position.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.Position.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.Position.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Config.Elbow valid ? 
  IF (( ParCmd.Position.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.Position.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.Position.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.Position.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.Position.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.Position.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position.Config.Wrist valid ? 
  IF (( ParCmd.Position.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.Position.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.Position.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.Position.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.Position.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.Position.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DetectionMode valid ? 
  IF (( ParCmd.DetectionMode <> DetectionMode.TORQUE             ) AND
      ( ParCmd.DetectionMode <> DetectionMode.FORCE              ) AND 
      ( ParCmd.DetectionMode <> DetectionMode.ELECTRICAL_CURRENT ) AND 
      ( ParCmd.DetectionMode <> DetectionMode.FOLLOWING_ERROR    ))  
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
                            MessageText := 'Invalid Parameter ParCmd.DetectionMode = {1}',
                            Para1       := DETECTION_MODE_TO_STRING(ParCmd.DetectionMode));
    RETURN;                          
  END_IF
  
  
  FOR _idx := 0 TO 6
  DO
    // Check ParCmd.DetectionVector[x] valid ? 
    IF ( SysDepIsValidReal(ParCmd.DetectionVector[_idx]) = FALSE ) 
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.DetectionVector[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.DetectionVector[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      RETURN;                          
    END_IF
  END_FOR
  
  
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.JerkRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.JerkRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <   0                                                ) OR   
      ( ParCmd.ToolNo > 254                                                ) OR
      ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex ) OR
      ( ParCmd.ToolNo > RobotLibraryParameter.TOOL_MAX -1                  ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check ToolNo available on RC ? 
    IF ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ToolNo = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.ToolNo));                            
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TurnMode = {1}',
                            Para1       :=  TURN_MODE_TO_STRING(ParCmd.TurnMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Manipulation
  // -> no plausibility check for boolean

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
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.VelocityRate
    CreateCommandPayload.AddUint(_command.VelocityRate);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.AccelerationRate
    CreateCommandPayload.AddUint(_command.AccelerationRate);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DecelerationRate
    CreateCommandPayload.AddUint(_command.DecelerationRate);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.JerkRate
    CreateCommandPayload.AddUint(_command.JerkRate);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ToolNo
    CreateCommandPayload.AddUsint(_command.ToolNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
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
    // add command.Position.X
    CreateCommandPayload.AddReal(_command.Position.X);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Y
    CreateCommandPayload.AddReal(_command.Position.Y);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Z
    CreateCommandPayload.AddReal(_command.Position.Z);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Rx
    CreateCommandPayload.AddReal(_command.Position.Rx);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Ry
    CreateCommandPayload.AddReal(_command.Position.Ry);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Rz
    CreateCommandPayload.AddReal(_command.Position.Rz);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.Config
    CreateCommandPayload.AddArmConfig(_command.Position.Config);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.TurnNumber
    CreateCommandPayload.AddTurnNumber(_command.Position.TurnNumber);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E1
    CreateCommandPayload.AddReal(_command.Position.E1);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.OriMode
    CreateCommandPayload.AddUsint(_command.OriMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionMode
    CreateCommandPayload.AddUsint(_command.DetectionMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Manipulation
    CreateCommandPayload.AddBool(_command.Manipulation);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Reserve
    CreateCommandPayload.AddByte(_command.Reserve);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[0]
    CreateCommandPayload.AddReal(_command.DetectionVector[0]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[1]
    CreateCommandPayload.AddReal(_command.DetectionVector[1]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[2]
    CreateCommandPayload.AddReal(_command.DetectionVector[2]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[3]
    CreateCommandPayload.AddReal(_command.DetectionVector[3]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[4]
    CreateCommandPayload.AddReal(_command.DetectionVector[4]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.DetectionVector[5]
    CreateCommandPayload.AddReal(_command.DetectionVector[5]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ConfigMode[0]
    CreateCommandPayload.AddByte(_command.ConfigMode[0]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ConfigMode[1]
    CreateCommandPayload.AddByte(_command.ConfigMode[1]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TurnMode
    CreateCommandPayload.AddUsint(_command.TurnMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E2
    CreateCommandPayload.AddReal(_command.Position.E2);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E3
    CreateCommandPayload.AddReal(_command.Position.E3);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E4
    CreateCommandPayload.AddReal(_command.Position.E4);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E5
    CreateCommandPayload.AddReal(_command.Position.E5);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Position.E6
    CreateCommandPayload.AddReal(_command.Position.E6);
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
VAR 
  /// internal index for loops
 _idx : DINT;
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
  // Create log entry for VelocityRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VelocityRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.VelocityRate));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for AccelerationRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AccelerationRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.AccelerationRate));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for DecelerationRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DecelerationRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.DecelerationRate));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for JerkRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JerkRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.JerkRate));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ToolNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ToolNo));
  
  
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
  // Create log entry for Position.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Y));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rx));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.Position.Config));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.Position.TurnNumber.J1Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J3Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J5Turns)));
  
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Position.TurnNumber.E1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E1));
  
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for OriMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.OriMode = {1}',
                          Para1       :=  ORI_MODE_TO_STRING(_command.OriMode));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for DetectionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DetectionMode = {1}',
                          Para1       :=  DETECTION_MODE_TO_STRING(_command.DetectionMode));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Manipulation
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Manipulation = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.Manipulation));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  USINT_TO_STRING(_command.Reserve));
  
  
  
  // Create log entry for DetectionVector[x]
  FOR _idx := 0 TO 5
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.DetectionVector
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.DetectionVector[{2}] = {1}',
                            Para1       :=  REAL_TO_STRING(_command.DetectionVector[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ConfigMode[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConfigMode[0] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ConfigMode[0]));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ConfigMode[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConfigMode[1] = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ConfigMode[1]));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TurnMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TurnMode = {1}',
                          Para1       :=  TURN_MODE_TO_STRING(_command.TurnMode));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
  
  ExecMode     := ExecutionMode.SEQUENCE_PRIMARY;
  Priority     := PriorityLevel.NORMAL;
  AbortingMode := AbortingModeEnum.BUFFER;
  SequenceFlag := SequenceFlagEnum.PRIMARY_SEQUENCE;

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
             OutCmd.Progress          :=  PERCENT_UINT_TO_REAL( Value := _response.Progress, IsOptional := FALSE);
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
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Progress
   _response.Progress := ResponseData.GetUint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.RemainingDistance
   _response.RemainingDistance := ResponseData.GetReal();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.InClamping
   _response.InClamping := ResponseData.GetBool();
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
  // Create log entry for Progress
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Progress = {1}',
                          Para1       :=  UINT_TO_STRING(_response.Progress));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for RemainingDistance
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RemainingDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_response.RemainingDistance));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
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

