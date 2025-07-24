/// Create and move spline on RC simultaneously
FUNCTION_BLOCK MC_DynamicSplineFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DynamicSplineFB                                       
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
  /// Start of the command at the rising edge
  Execute            : BOOL;
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands
  AbortingMode       : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter 
  ParCmd             : DynamicSplineParCmd;
END_VAR
VAR_OUTPUT
  /// FB is being processed
  Busy               : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Function is enabled and new input values will be transmitted.
  Enabled            : BOOL;
  /// The command takes control of the motion of the according axis group
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command results
  OutCmd             : DynamicSplineOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : DynamicSplineParCmd;
  /// command data to send
 _command            : DynamicSplineSendData;
  /// response data received
 _response           : DynamicSplineRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.DynamicSpline;
  
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
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
                              Para1       := VALID_REAL_TO_STRING(ParCmd.BlendingParameter[_idx]),
                              Para2       := DINT_TO_STRING(_idx));       
      EXIT;                     
      RETURN;
    END_IF
  END_FOR
  
  // Check ParCmd.Mode valid ? 
  IF (( ParCmd.Mode <> SplineMode.DISCRETE_POINTS      ) AND
      ( ParCmd.Mode <> SplineMode.BEZIER_SPLINE        ) AND 
      ( ParCmd.Mode <> SplineMode.B_SPLINES            ) AND 
      ( ParCmd.Mode <> SplineMode.CUBIC_HERMITE_SPLINE ) AND 
      ( ParCmd.Mode <> SplineMode.C_SPLINES    ))  
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
                            MessageText := 'Invalid Parameter ParCmd.Mode = {1}',
                            Para1       := SPLINE_MODE_TO_STRING(ParCmd.Mode));
    RETURN;                          
  END_IF
  
  FOR _idx := 0 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // Check ParCmd.SplineData[x].Position.X valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.X) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.[{2}].Position.X = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.X),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Y valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.Y) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Y = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.Y),
                              Para2       := DINT_TO_STRING(_idx)); 
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Z valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.Z) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Z = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.Z));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Rx valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.Rx) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Rx = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.Rx),
                              Para2       := DINT_TO_STRING(_idx)); 
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Ry valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.Ry) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Ry = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.Ry),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Rz valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.Rz) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Rz = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.Rz),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.E1 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E1) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E1 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E1),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.E2 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E2) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E2 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E2),
                              Para2       := DINT_TO_STRING(_idx)); 
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[_idx].Position.E3 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E3) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E3 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E3),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.E4 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E4) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E4 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E4),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.E5 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E5) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E5 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E5),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.E6 valid ? 
    IF ( SysDepIsValidReal(ParCmd.SplineData[_idx].Position.E6) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.E6 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].Position.E6),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Config.Shoulder valid ? 
    IF (( ParCmd.SplineData[_idx].Position.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
        ( ParCmd.SplineData[_idx].Position.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_SHOULDER_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Config.Shoulder = {1}',
                              Para1       := ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.SplineData[_idx].Position.Config.Shoulder),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Config.Elbow valid ? 
    IF (( ParCmd.SplineData[_idx].Position.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
        ( ParCmd.SplineData[_idx].Position.Config.Elbow <> ArmConfigElbow.SAME       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Elbow <> ArmConfigElbow.FREE       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Elbow <> ArmConfigElbow.UP         ))
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_ELBOW_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Config.Elbow = {1}',
                              Para1       := ARM_CONFIG_ELBOW_TO_STRING(ParCmd.SplineData[_idx].Position.Config.Elbow),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.SplineData[x].Position.Config.Wrist valid ? 
    IF (( ParCmd.SplineData[_idx].Position.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
        ( ParCmd.SplineData[_idx].Position.Config.Wrist <> ArmConfigWrist.SAME       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Wrist <> ArmConfigWrist.FREE       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
        ( ParCmd.SplineData[_idx].Position.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_CONFIGMODE_WRIST_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].Position.Config.Wrist = {1}',
                              Para1       := ARM_CONFIG_WRIST_TO_STRING(ParCmd.SplineData[_idx].Position.Config.Wrist),
                              Para2       := DINT_TO_STRING(_idx));      
      EXIT;                            
      RETURN;                          
    END_IF
  
    
    // Check ParCmd.SplineData[x].VelocityRate valid ? 
    IF  (( SysDepIsValidReal(ParCmd.SplineData[_idx].VelocityRate) = FALSE )  OR
        ((                   ParCmd.SplineData[_idx].VelocityRate  <     0 )  AND 
         (                   ParCmd.SplineData[_idx].VelocityRate <>    -1 )) OR   
         (                   ParCmd.SplineData[_idx].VelocityRate  >   100 ))      
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].VelocityRate = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].VelocityRate),
                              Para2       := DINT_TO_STRING(_idx));                            
      EXIT;                            
      RETURN;
    END_IF
    
    
    // Check ParCmd.SplineData[x].AccelerationRate valid ? 
    IF  (( SysDepIsValidReal(ParCmd.SplineData[_idx].AccelerationRate) = FALSE )  OR
        ((                   ParCmd.SplineData[_idx].AccelerationRate  <     0 )  AND 
         (                   ParCmd.SplineData[_idx].AccelerationRate <>    -1 )) OR   
         (                   ParCmd.SplineData[_idx].AccelerationRate  >   100 ))      
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_ACCELERATION_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].AccelerationRate = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].AccelerationRate),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;
    END_IF
    
    
    // Check ParCmd.SplineData[x].DecelerationRate valid ? 
    IF  (( SysDepIsValidReal(ParCmd.SplineData[_idx].DecelerationRate) = FALSE )  OR
        ((                   ParCmd.SplineData[_idx].DecelerationRate  <     0 )  AND 
         (                   ParCmd.SplineData[_idx].DecelerationRate <>    -1 )) OR   
         (                   ParCmd.SplineData[_idx].DecelerationRate  >   100 ))      
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_DECELERATION_INVALID;
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].DecelerationRate = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].DecelerationRate),
                              Para2       := DINT_TO_STRING(_idx));                            
      EXIT;                            
      RETURN;
    END_IF
    
    
    // Check ParCmd.SplineData[x].JerkRate valid ? 
    IF  (( SysDepIsValidReal(ParCmd.SplineData[_idx].JerkRate) = FALSE )  OR
        ((                   ParCmd.SplineData[_idx].JerkRate  <     0 )  AND 
         (                   ParCmd.SplineData[_idx].JerkRate <>    -1 )) OR   
         (                   ParCmd.SplineData[_idx].JerkRate  >   100 ))      
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].JerkRate = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SplineData[_idx].JerkRate),
                              Para2       := DINT_TO_STRING(_idx));                            
      EXIT;                            
      RETURN;
    END_IF
    
    
    // Check ParCmd.SplineData[x].ToolNo valid ? 
    IF (( ParCmd.SplineData[_idx].ToolNo <   0 ) OR   
        ( ParCmd.SplineData[_idx].ToolNo > 254 ))
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].ToolNo = {1}',
                              Para1       := USINT_TO_STRING(ParCmd.SplineData[_idx].ToolNo),
                              Para2       := DINT_TO_STRING(_idx));                           
      EXIT;                            
      RETURN;
    END_IF
    
    
    // Check ParCmd.SplineData[x].FrameNo valid ? 
    IF (( ParCmd.SplineData[_idx].FrameNo <   0 ) OR   
        ( ParCmd.SplineData[_idx].FrameNo > 254 ))
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].FrameNo = {1}',
                              Para1       := USINT_TO_STRING(ParCmd.SplineData[_idx].FrameNo),
                              Para2       := DINT_TO_STRING(_idx));                            
      EXIT;                            
      RETURN;
    END_IF
  
      
    // Check ParCmd.SplineData[x].MoveTime valid ? 
    IF  ( ParCmd.SplineData[_idx].MoveTime < T#0S )
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
                              MessageText := 'Invalid Parameter ParCmd.SplineData[{2}].MoveTime = {1}',
                              Para1       := TIME_TO_STRING(ParCmd.SplineData[_idx].MoveTime),
                              Para2       := DINT_TO_STRING(_idx));                           
      EXIT;                            
      RETURN;
    END_IF  
  END_FOR
  
  
  // Check ParCmd.StartPosition valid ? 
  IF (( ParCmd.StartPosition < 0                                     ) OR
      ( ParCmd.StartPosition > RobotLibraryParameter.SPLINE_DATA_MAX ))
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
                            MessageText := 'Invalid Parameter ParCmd.StartPosition = {1}',
                            Para1       := INT_TO_STRING(ParCmd.StartPosition));
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
// Table 6-772: Sent CMD payload (PLC to RC) of "DynamicSpline"
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
// Byte 00 : UINT  Type;
// Byte 01 :       Type;
// Byte 02 : USINT Reserved ExecutionMode;
// Byte 03 : USINT ParSeq Priority;
// Byte 04 : UINT  Mode;
// Byte 05 : USINT BlendingMode;
// Byte 06 : REAL  BlendingParameter[0];
// Byte 07 :       BlendingParameter[0];
// Byte 08 :       BlendingParameter[0];
// Byte 09 :       BlendingParameter[0];
// Byte 10 : REAL  BlendingParameter[1];
// Byte 11 :       BlendingParameter[1];
// Byte 12 :       BlendingParameter[1];
// Byte 13 :       BlendingParameter[1];
// Byte 14 : UINT  Time;
// Byte 15 :       Time;
// Byte 16 : INT   StartPosition;
// Byte 17 :       StartPosition;
// Byte 18 : UINT  SplineData.VelocityRate;
// Byte 19 :       SplineData.VelocityRate;
// Byte 20 : UINT  SplineData.AccelerationRate;
// Byte 21 :       SplineData.AccelerationRate;
// Byte 22 : UINT  SplineData.DecelerationRate;
// Byte 23 :       SplineData.DecelerationRate;
// Byte 24 : UINT  SplineData.JerkRate;
// Byte 25 :       SplineData.JerkRate;
// Byte 26 : USINT SplineData.ToolNo;
// Byte 27 : USINT SplineData.FrameNo;
// Byte 28 : REAL  SplineData.X;
// Byte 29 :       SplineData.X;
// Byte 30 :       SplineData.X;
// Byte 31 :       SplineData.X;
// Byte 32 : REAL  SplineData.Y;
// Byte 33 :       SplineData.Y;
// Byte 34 :       SplineData.Y;
// Byte 35 :       SplineData.Y;
// Byte 36 : REAL  SplineData.Z;
// Byte 37 :       SplineData.Z;
// Byte 38 :       SplineData.Z;
// Byte 39 :       SplineData.Z;
// Byte 40 : REAL  SplineData.RX;
// Byte 41 :       SplineData.RX;
// Byte 42 :       SplineData.RX;
// Byte 43 :       SplineData.RX;
// Byte 44 : REAL  SplineData.RY;
// Byte 45 :       SplineData.RY;
// Byte 46 :       SplineData.RY;
// Byte 47 :       SplineData.RY;
// Byte 48 : REAL  SplineData.RZ;
// Byte 49 :       SplineData.RZ;
// Byte 50 :       SplineData.RZ;
// Byte 51 :       SplineData.RZ;
// Byte 52 : BYTE  - - - - - W E S;
// Byte 53 : BYTE  Reserved;
// Byte 54 : BYTE  SplineData.TurnNumber[0];
// Byte 55 : BYTE  SplineData.TurnNumber[1];
// Byte 56 : BYTE  SplineData.TurnNumber[2];
// Byte 57 : BYTE  SplineData.TurnNumber[3];
// Byte 58 : REAL  SplineData.E1;
// Byte 59 :       SplineData.E1;
// Byte 60 :       SplineData.E1;
// Byte 61 :       SplineData.E1;
// Byte 62 : UINT  SplineData.Time;
// Byte 63 :       SplineData.Time;
// Byte 64 : REAL  SplineData.E2;
// Byte 65 :       SplineData.E2;
// Byte 66 :       SplineData.E2;
// Byte 67 :       SplineData.E2;
// Byte 68 : REAL  SplineData.E3;
// Byte 69 :       SplineData.E3;
// Byte 70 :       SplineData.E3;
// Byte 71 :       SplineData.E3;
// Byte 72 : REAL  SplineData.E4;
// Byte 73 :       SplineData.E4;
// Byte 74 :       SplineData.E4;
// Byte 75 :       SplineData.E4;
// Byte 76 : REAL  SplineData.E5;
// Byte 77 :       SplineData.E5;
// Byte 78 :       SplineData.E5;
// Byte 79 :       SplineData.E5;
// Byte 80 : REAL  SplineData.E6;
// Byte 81 :       SplineData.E6;
// Byte 82 :       SplineData.E6;
// Byte 83 :       SplineData.E6;
VAR
  /// internal index for loops
  _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp            :=  CmdType.DynamicSpline;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.Mode              := _parCmd.Mode;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.MoveTime          := TIME_TO_UINT(_parCmd.MoveTime);
  _command.StartPosition     := _parCmd.StartPosition;
  
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
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Mode
    CreateCommandPayload.AddUint(_command.Mode);
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
    // add command.MoveTime
    CreateCommandPayload.AddUint(_command.MoveTime);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.StartPosition
    CreateCommandPayload.AddInt(_command.StartPosition);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.VelocityRate
      CreateCommandPayload.AddUint(_command.SplineData[_idx].VelocityRate);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.AccelerationRate
      CreateCommandPayload.AddUint(_command.SplineData[_idx].AccelerationRate);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.DecelerationRate
      CreateCommandPayload.AddUint(_command.SplineData[_idx].DecelerationRate);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.JerkRate
      CreateCommandPayload.AddUint(_command.SplineData[_idx].JerkRate);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.ToolNo
      CreateCommandPayload.AddUsint(_command.SplineData[_idx].ToolNo);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.FrameNo
      CreateCommandPayload.AddUsint(_command.SplineData[_idx].FrameNo);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.X
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.X);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Y
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Y);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Z
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Z);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Rx
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rx);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Ry
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Ry);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Rz
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rz);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.Config
      CreateCommandPayload.AddArmConfig(_command.SplineData[_idx].Position.Config);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.TurnNumber
      CreateCommandPayload.AddTurnNumber(_command.SplineData[_idx].Position.TurnNumber);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E1
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E1);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].MoveTime
      CreateCommandPayload.AddUint(_command.SplineData[_idx].MoveTime);  
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E2
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E2);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E3
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E3);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E4
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E4);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E5
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E5);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
    
  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SplineData[_idx].Position.E6
      CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E6);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
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
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  SPLINE_MODE_TO_STRING(_command.Mode));
  
  
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
  // Create log entry for MoveTime
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MoveTime = {1}',
                          Para1       :=  REAL_TO_STRING(_command.MoveTime));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for StartPosition
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.StartPosition = {1}',
                          Para1       :=  INT_TO_STRING(_command.StartPosition));
  
  // Create log entry for SplineData[x]
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for VelocityRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].VelocityRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].VelocityRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for AccelerationRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].AccelerationRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].AccelerationRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for DecelerationRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].DecelerationRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].DecelerationRate),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for JerkRate
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].JerkRate = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].JerkRate),
                            Para2       :=  DINT_TO_STRING(_idx));
  
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for ToolNo
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].ToolNo = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SplineData[_idx].ToolNo),
                            Para2       :=  DINT_TO_STRING(_idx));
    
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for FrameNo
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].FrameNo = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SplineData[_idx].FrameNo),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.X
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.X = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.X),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Y
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Y = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Y),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Z
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Z = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Z),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Rx
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Rx = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Rx),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Ry
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Ry = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Ry),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Rz
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Rz = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.Rz),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.Config
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.Config = {1}',
                            Para1       :=  ARM_CONFIG_TO_STRING(_command.SplineData[_idx].Position.Config),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.TurnNumber[0]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[0] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J2Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J1Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.TurnNumber[1]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[1] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J4Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J3Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
  
                            
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.TurnNumber[2]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[2] = {1}',
                            Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.SplineData[_idx].Position.TurnNumber.J6Turns,
                                                                            HalfSintLo := _command.SplineData[_idx].Position.TurnNumber.J5Turns)),                          
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.TurnNumber[3]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.TurnNumber[3] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.SplineData[_idx].Position.TurnNumber.E1Turns),                          
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E1
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E1 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E1),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for MoveTime
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].MoveTime = {1}',
                            Para1       :=  UINT_TO_STRING(_command.SplineData[_idx].MoveTime),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E2
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E2 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E2),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E3
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E3 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E3),
                            Para2       :=  DINT_TO_STRING(_idx));
  
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E4
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E4 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E4),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E5
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SplineData[{2}].Position.E5 = {1}',
                            Para1       :=  REAL_TO_STRING(_command.SplineData[_idx].Position.E5),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
  
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Position.E6
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
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

  MyType := 'MC_DynamicSplineFB';
  
  ExecMode     := ExecutionMode.CONTINUOUS;
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
    
    00:  IF ( Execute ) AND ( NOT Error)  
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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.SegmentProgress     := _response.SegmentProgress;
             OutCmd.RemainingDistance   := _response.RemainingDistance;
             OutCmd.Buffered            := _response.Buffered;
             OutCmd.Calculated          := _response.Calculated;
             OutCmd.ActiveIndex         := _response.ActiveIndex;
             OutCmd.TrajectoryCompleted := _response.TrajectoryCompleted;
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
   _uniqueId           := 0;
   _stepCmd            := 0;
    Busy               := FALSE;
    CommandBuffered    := FALSE;  
    CommandAborted     := FALSE;
    CommandInterrupted := FALSE;
    Error              := FALSE;
    ErrorID            := 0;
    WarningID          := 0;
    InfoID             := 0;  
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
// Table 6-773: Received CMD payload (RC to PLC) of "DynamicSpline"
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
   _response.SegmentProgress := ResponseData.GetUint();
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
    // Get Response.Buffered
   _response.Buffered := ResponseData.GetInt();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Calculated
   _response.Calculated := ResponseData.GetInt();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.ActiveIndex
   _response.ActiveIndex := ResponseData.GetSint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.TrajectoryCompleted
   _response.TrajectoryCompleted := ResponseData.GetBool();
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
  // Create log entry for SegmentProgress
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.SegmentProgress = {1}',
                          Para1       :=  REAL_TO_STRING(_response.SegmentProgress));
  
  
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
  // Create log entry for Buffered
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Buffered = {1}',
                          Para1       :=  INT_TO_STRING(_response.Buffered));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Calculated
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Calculated = {1}',
                          Para1       :=  INT_TO_STRING(_response.Calculated));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ActiveIndex
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ActiveIndex = {1}',
                          Para1       :=  SINT_TO_STRING(_response.ActiveIndex));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for TrajectoryCompleted
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TrajectoryCompleted = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.TrajectoryCompleted));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  Active             := FALSE;
  Enabled            := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

