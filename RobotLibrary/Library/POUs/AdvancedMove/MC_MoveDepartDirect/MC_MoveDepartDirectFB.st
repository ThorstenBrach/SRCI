/// Direct Move from actual position to destination through auxiliary
/// position defined by offset in all dimensions (movement to the target position PTP)
FUNCTION_BLOCK MC_MoveDepartDirectFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveDepartDirectFB                                       
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
  ParCmd             : MoveDepartDirectParCmd;       
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
  OutCmd             : MoveDepartDirectOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveDepartDirectParCmd;
  /// command data to send
 _command            : MoveDepartDirectSendData;
  /// response data received
 _response           : MoveDepartDirectRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.MoveDepartDirect;
  
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
  
  
  // Check ParCmd.TargetPosition.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.TargetPosition.X) = FALSE ) 
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.TargetPosition.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.TargetPosition.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Rz));
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
  IF (( ParCmd.BlendingMode <> BlendingMode.EXACT_STOP           ) AND   
      ( ParCmd.BlendingMode <> BlendingMode.DEFINED_VELOCITY     ) AND
      ( ParCmd.BlendingMode <> BlendingMode.CORNER_DISTANCE      ) AND
      ( ParCmd.BlendingMode <> BlendingMode.MAX_CORNER_DEVIATION ) AND
      ( ParCmd.BlendingMode <> BlendingMode.CORNER_DISTANCE_2R   ) AND
      ( ParCmd.BlendingMode <> BlendingMode.RAMP_OVERLAP         ) AND
      ( ParCmd.BlendingMode <> BlendingMode.CORNER_DISTANCE_1R   ))    
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
                            MessageText := 'Invalid Parameter ParCmd.BlendingMode = {1}',
                            Para1       := BLENDING_MODE_TO_STRING(ParCmd.BlendingMode));                            
    RETURN;
  END_IF
  
  
  FOR _idx := 0 TO 1 
  DO
    // Check ParCmd.BlendingParameter valid ? 
    IF  ( SysDepIsValidReal(ParCmd.BlendingParameter[_idx]) = FALSE ) 
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_JERK_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.BlendingParameter[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.JerkRate),
                              Para2       := DINT_TO_STRING(_idx));       
      EXIT;                     
      RETURN;
    END_IF
  END_FOR
  
  
  // Check ParCmd.AuxCornerDistance valid ? 
  IF  ( SysDepIsValidReal(ParCmd.AuxCornerDistance) = FALSE )
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
                            MessageText := 'Invalid Parameter ParCmd.AuxCornerDistance = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.AuxCornerDistance));                            
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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
  
  
  // Check ParCmd.VelocityCoefficient valid ? 
  IF  ( SysDepIsValidReal(ParCmd.VelocityCoefficient) = FALSE )
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
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
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
VAR
  /// internal index for loops
 _idx          : DINT;
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-396: Sent CMD payload (PLC to RC) of "MoveDepartDirect"
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
  _command.CmdTyp               :=  CmdType.MoveDepartDirect;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  _command.EmitterID            := _parCmd.EmitterID;
  _command.ListenerID           := 0; 
  _command.VelocityRate         := REAL_TO_PERCENT_UINT(_parCmd.VelocityRate     , IsOptional := FALSE);
  _command.AccelerationRate     := REAL_TO_PERCENT_UINT(_parCmd.AccelerationRate , IsOptional := FALSE);
  _command.DecelerationRate     := REAL_TO_PERCENT_UINT(_parCmd.DecelerationRate , IsOptional := TRUE );
  _command.JerkRate             := REAL_TO_PERCENT_UINT(_parCmd.JerkRate         , IsOptional := TRUE );
  _command.ToolNo               := _parCmd.ToolNo;
  _command.FrameNo              := _parCmd.FrameNo;
  _command.BlendingMode         := _parCmd.BlendingMode;
  _command.OriMode              := _parCmd.OriMode;
  _command.BlendingParameter    := _parCmd.BlendingParameter;
  _command.TargetPosition       := _parCmd.TargetPosition;
  _command.Offset               := _parCmd.Offset;
  _command.AuxCornerDistance    := _parCmd.AuxCornerDistance;
  _command.VelocityCoefficient  := _parCmd.VelocityCoefficient;
  _command.Manipulation         := _parCmd.Manipulation;
  _command.ConfigMode           :=  ArmConfigParameterToBytes(_parCmd.ConfigMode);
  _command.TurnMode             := _parCmd.TurnMode;
  _command.ReferenceType        := _parCmd.ReferenceType.0;
  _command.MoveTime             := TIME_TO_UINT(_parCmd.MoveTime);
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.EmitterID[x]
      CreateCommandPayload.AddSint(_command.EmitterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ListenerID
    CreateCommandPayload.AddSint(_command.ListenerID);
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
    // add command.mFrameNo
    CreateCommandPayload.AddUsint(_command.FrameNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.BlendingMode
    CreateCommandPayload.AddUsint(_command.BlendingMode);
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
    // add command.BlendingParameter[0]
    CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.BlendingParameter[1]
    CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.X
    CreateCommandPayload.AddReal(_command.TargetPosition.X);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Y
    CreateCommandPayload.AddReal(_command.TargetPosition.Y);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Z
    CreateCommandPayload.AddReal(_command.TargetPosition.Z);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Rx
    CreateCommandPayload.AddReal(_command.TargetPosition.Rx);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Ry
    CreateCommandPayload.AddReal(_command.TargetPosition.Ry);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Rz
    CreateCommandPayload.AddReal(_command.TargetPosition.Rz);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.Config
    CreateCommandPayload.AddArmConfig(_command.TargetPosition.Config);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.TurnNumber
    CreateCommandPayload.AddTurnNumber(_command.TargetPosition.TurnNumber);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E1
    CreateCommandPayload.AddReal(_command.TargetPosition.E1);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.X
    CreateCommandPayload.AddReal(_command.Offset.X);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.Y
    CreateCommandPayload.AddReal(_command.Offset.Y);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.Z
    CreateCommandPayload.AddReal(_command.Offset.Z);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.Rx
    CreateCommandPayload.AddReal(_command.Offset.Rx);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.Ry
    CreateCommandPayload.AddReal(_command.Offset.Ry);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Offset.Rz
    CreateCommandPayload.AddReal(_command.Offset.Rz);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.AuxCornerDistance
    CreateCommandPayload.AddReal(_command.AuxCornerDistance);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.VelocityCoefficient
    CreateCommandPayload.AddReal(_command.VelocityCoefficient);
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
    // add command.ReferenceType
    CreateCommandPayload.AddBool(_command.ReferenceType);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.MoveTime
    CreateCommandPayload.AddUint(_command.MoveTime);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E2
    CreateCommandPayload.AddReal(_command.TargetPosition.E2);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E3
    CreateCommandPayload.AddReal(_command.TargetPosition.E3);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E4
    CreateCommandPayload.AddReal(_command.TargetPosition.E4);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E5
    CreateCommandPayload.AddReal(_command.TargetPosition.E5);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.TargetPosition.E6
    CreateCommandPayload.AddReal(_command.TargetPosition.E6);
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
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.EmitterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
                          
  
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
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  
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
  // Create log entry for BlendingMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingMode = {1}',
                          Para1       :=  BLENDING_MODE_TO_STRING(_command.BlendingMode));
  
  
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
  // Create log entry for BlendingParameter[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingParameter[0] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.BlendingParameter[0]));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for BlendingParameter[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BlendingParameter[1] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.BlendingParameter[1]));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Y));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Rx));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.TargetPosition.Config));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J1Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J3Turns)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Position.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.TargetPosition.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.TargetPosition.TurnNumber.J5Turns)));
  
  
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
                          Para1       :=  SINT_TO_STRING(_command.TargetPosition.TurnNumber.E1Turns));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E1));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.X));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Y));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Z));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rx));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Ry));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Offset.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rz));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for AuxCornerDistance
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AuxCornerDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_command.AuxCornerDistance));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for VelocityCoefficient
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VelocityCoefficient = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VelocityCoefficient));
  
  
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
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  REFERENCE_TYPE_TO_STRING(BOOL_TO_BYTE(_command.ReferenceType)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for MoveTime
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MoveTime = {1}',
                          Para1       :=  UINT_TO_STRING(_command.MoveTime));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E2));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E3));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E4));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TargetPosition.E5));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TargetPosition.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
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

  MyType := 'MC_MoveDepartDirectFB';
  
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
             CmdMessageState.BUFFERED    : CommandBuffered          := TRUE;
             CmdMessageState.ACTIVE      : Active                   := TRUE;
                                           // Update results
                                           OutCmd.Progress          :=  PERCENT_UINT_TO_REAL( Value := _response.Progress, IsOptional := FALSE);
                                           OutCmd.FollowID          := _response.OriginID;
                                           OutCmd.RemainingDistance := _response.RemainingDistance;
             
             CmdMessageState.INTERRUPTED : CommandInterrupted       := TRUE;           
             CmdMessageState.DONE        : Done                     := TRUE;
             CmdMessageState.ABORTED     : CommandAborted           := TRUE;
             CmdMessageState.ERROR       : Error                    := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy Flag
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
// Table 6-397: Received CMD payload (RC to PLC) of "MoveDepartDirect"
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
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get Response.InvocationCounter 
   _response.InvocationCounter := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get Response.Reserve
   _response.Reserve := ResponseData.GetSint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN
    // Get Response.OriginID
   _response.OriginID := ResponseData.GetInt();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
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
  // Create log entry for InvocationCounter
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InvocationCounter = {1}',
                          Para1       :=  USINT_TO_STRING(_response.InvocationCounter));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  SINT_TO_STRING(_response.Reserve));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for OriginID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.OriginID = {1}',
                          Para1       :=  INT_TO_STRING(_response.OriginID));
  
  
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

