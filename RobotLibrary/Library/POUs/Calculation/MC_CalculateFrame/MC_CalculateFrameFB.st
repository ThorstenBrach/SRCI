/// Calculate frame with three-point method
FUNCTION_BLOCK MC_CalculateFrameFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateFrameFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
  ParCmd          : CalculateFrameParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateFrameOutCmd;    
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateFrameParCmd;
  /// command data to send
 _command         : CalculateFrameSendData;
  /// response data received
 _response        : CalculateFrameRecvData;      
  /// Incremented with each position of the input parameter "PositionsArray" sent from the PLC to the RC.
  /// Default: 0
 _dataIndex       : USINT;
  /// Set TRUE by the client, when according to the user selected "Mode" the final position of the input parameter "PositionsArray" is sent to the RC.
  /// Default: FALSE
 _dataComplete    : BOOL;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.CalculateFrame;
  
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
  
  // Check ParCmd.Mode valid ? 
  IF (( ParCmd.Mode <> FrameCalculationMode.THREE_POINT_METHOD ) AND
      ( ParCmd.Mode <> FrameCalculationMode. FOUR_POINT_METHOD ) AND
      ( ParCmd.Mode <> FrameCalculationMode.  ONE_POINT_METHOD ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMECALCULATIONMODE_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.Mode = {1}',
                            Para1       := FRAME_CALCULATION_MODE_TO_STRING(ParCmd.Mode));
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
  
  
  // Check ParCmd.Position_X.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_X.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_X.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Config.Shoulder valid ? 
  IF (( ParCmd.Position_X.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.Position_X.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.Position_X.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.Position_X.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.Position_X.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.Position_X.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Config.Elbow valid ? 
  IF (( ParCmd.Position_X.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.Position_X.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.Position_X.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.Position_X.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.Position_X.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.Position_X.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_X.Config.Wrist valid ? 
  IF (( ParCmd.Position_X.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.Position_X.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.Position_X.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.Position_X.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.Position_X.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_X.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.Position_X.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Position_XY.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Position_XY.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Config.Shoulder valid ? 
  IF (( ParCmd.Position_XY.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.Position_XY.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.Position_XY.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.Position_XY.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.Position_XY.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.Position_XY.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Config.Elbow valid ? 
  IF (( ParCmd.Position_XY.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.Position_XY.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.Position_XY.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.Position_XY.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.Position_XY.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.Position_XY.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Position_XY.Config.Wrist valid ? 
  IF (( ParCmd.Position_XY.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.Position_XY.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.Position_XY.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.Position_XY.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.Position_XY.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.Position_XY.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.Position_XY.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Origin.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Origin.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Config.Shoulder valid ? 
  IF (( ParCmd.Origin.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.Origin.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.Origin.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.Origin.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.Origin.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.Origin.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Config.Elbow valid ? 
  IF (( ParCmd.Origin.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.Origin.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.Origin.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.Origin.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.Origin.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.Origin.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Origin.Config.Wrist valid ? 
  IF (( ParCmd.Origin.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.Origin.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.Origin.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.Origin.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.Origin.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.Origin.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.Origin.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.OriginShift.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.OriginShift.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Config.Shoulder valid ? 
  IF (( ParCmd.OriginShift.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.OriginShift.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.OriginShift.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.OriginShift.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.OriginShift.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.OriginShift.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Config.Elbow valid ? 
  IF (( ParCmd.OriginShift.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.OriginShift.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.OriginShift.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.OriginShift.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.OriginShift.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.OriginShift.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.OriginShift.Config.Wrist valid ? 
  IF (( ParCmd.OriginShift.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.OriginShift.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.OriginShift.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.OriginShift.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.OriginShift.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.OriginShift.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.OriginShift.Config.Wrist));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReferenceFrame valid ? 
  IF (( ParCmd.ReferenceFrame <   0 ) OR   
      ( ParCmd.ReferenceFrame > 254 ))
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
                            MessageText := 'Invalid Parameter ParCmd.ReferenceFrame = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.ReferenceFrame));                            
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-656: Sent CMD payload (PLC to RC) of "CalculateFrame"
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
// Byte 04 : USIN       - DataIndex
// Byte 05 : BOOL       - DataComplete
// Byte 06 : BYTE       - Reserve
// Byte 07 : USINT      - FrameNo
// Byte 08 : USINT      - ReferenceFrame
// Byte 09 : SINT       - Mode
// Byte 10 : REAL       - Position X  HW HB
// Byte 11 :            - Position X  HW LB
// Byte 12 :            - Position X  LW HB
// Byte 13 :            - Position X  LW LB
// Byte 14 : REAL       - Position Y  HW HB
// Byte 15 :            - Position Y  HW LB
// Byte 16 :            - Position Y  LW HB
// Byte 17 :            - Position Y  LW LB
// Byte 18 : REAL       - Position Z  HW HB
// Byte 19 :            - Position Z  HW LB
// Byte 20 :            - Position Z  LW HB
// Byte 21 :            - Position Z  LW LB
// Byte 22 : REAL       - Position Rx HW HB
// Byte 23 :            - Position Rx HW LB
// Byte 24 :            - Position Rx LW HB
// Byte 25 :            - Position Rx LW LB
// Byte 26 : REAL       - Position Ry HW HB
// Byte 27 :            - Position Ry HW LB
// Byte 28 :            - Position Ry LW HB
// Byte 29 :            - Position Ry LW LB
// Byte 30 : REAL       - Position Rz HW HB
// Byte 31 :            - Position Rz HW LB
// Byte 32 :            - Position Rz LW HB
// Byte 33 :            - Position Rz LW LB
// Byte 34 : Config     - ArmConfig   LW HB
// Byte 35 :            - ArmConfig   LW LB
// Byte 36 : TurnNumber - J1 + J2     LW HB
// Byte 37 :            - J3 + J4     LW LB
// Byte 38 :            - J5 + J6     LW LB
// Byte 39 :            - E1          LW LB
// Byte 40 : REAL       - Position E1 HW HB
// Byte 41 :            - Position E1 HW LB
// Byte 42 :            - Position E1 LW HB
// Byte 43 :            - Position E1 LW LB
// Byte 44 : REAL       - Position E2 HW HB
// Byte 45 :            - Position E2 HW LB
// Byte 46 :            - Position E2 LW HB
// Byte 47 :            - Position E2 LW LB
// Byte 48 : REAL       - Position E3 HW HB
// Byte 49 :            - Position E3 HW LB
// Byte 50 :            - Position E3 LW HB
// Byte 51 :            - Position E3 LW LB
// Byte 52 : REAL       - Position E4 HW HB
// Byte 53 :            - Position E4 HW LB
// Byte 54 :            - Position E4 LW HB
// Byte 55 :            - Position E4 LW LB
// Byte 56 : REAL       - Position E5 HW HB
// Byte 57 :            - Position E5 HW LB
// Byte 58 :            - Position E5 LW HB
// Byte 59 :            - Position E5 LW LB
// Byte 60 : REAL       - Position E6 HW HB
// Byte 61 :            - Position E6 HW LB
// Byte 62 :            - Position E6 LW HB
// Byte 63 :            - Position E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.CalculateFrame;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.FrameNo        := _parCmd.FrameNo;
  _command.DataIndex      := _dataIndex;
  _command.DataComplete.0 := _dataComplete;
  _command.Reserve        := 0;
  _command.FrameNo        := _parCmd.FrameNo;                 
  _command.ReferenceFrame := _parCmd.ReferenceFrame;
  _command.Mode           := _parCmd.Mode;
  
  CASE _parCmd.Mode OF
    
    FrameCalculationMode.THREE_POINT_METHOD :
  
      CASE _dataIndex OF
        
        1: _command.Position := _parCmd.Origin;
        2: _command.Position := _parCmd.Position_X;
        3: _command.Position := _parCmd.Position_XY;
        
      END_CASE
    
    FrameCalculationMode.FOUR_POINT_METHOD  :
  
      CASE _dataIndex OF
        
        1: _command.Position := _parCmd.Origin;
        2: _command.Position := _parCmd.Position_X;
        3: _command.Position := _parCmd.Position_XY;
        4: _command.Position := _parCmd.OriginShift;      
  
      END_CASE
    
    FrameCalculationMode.ONE_POINT_METHOD   :
    
     _command.Position := _parCmd.Origin;
  
  END_CASE
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.DataIndex
  CreateCommandPayload.AddUsint(_command.DataIndex);
  // add command.DataComplete
  CreateCommandPayload.AddByte(_command.DataComplete);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.ReferenceFrame
  CreateCommandPayload.AddUsint(_command.ReferenceFrame);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
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

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the following parameter(s) :');
  
  // Create log entry for DataIndex
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DataIndex = {1}',
                          Para1       :=  USINT_TO_STRING(_command.DataIndex));
  
  // Create log entry for DataComplete
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DataComplete = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.DataComplete));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
  
  // Create log entry for ReferenceFrame
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceFrame = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ReferenceFrame));
  
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  FRAME_CALCULATION_MODE_TO_STRING(_command.Mode));
  
  
  // Create log entry for Position.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.X));
  
  // Create log entry for Position.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Y));
  
  // Create log entry for Position.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Z));
  
  // Create log entry for Position.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rx));
  
  // Create log entry for Position.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Ry));
  
  // Create log entry for Position.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.Rz));
  
  // Create log entry for Position.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.Position.Config));
  
  // Create log entry for Position.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J2Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J1Turns)));
  
  // Create log entry for Position.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J3Turns)));
  
  // Create log entry for Position.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Position.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.Position.TurnNumber.J5Turns)));
  
  // Create log entry for Position.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Position.TurnNumber.E1Turns));
  
  // Create log entry for Position.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E1));
  
  // Create log entry for Position.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E2));
  
  // Create log entry for Position.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E3));
  
  // Create log entry for Position.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E4));
  
  // Create log entry for Position.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Position.E5));
  
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

  MyType := 'MC_CalculateFrameFB';
  
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
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
       
  
    01: // inc data index 
       _dataIndex := _dataIndex + 1;
  
        CASE _parCmd.Mode OF
          FrameCalculationMode.ONE_POINT_METHOD   :
            _dataComplete := _dataIndex >= 1;
          FrameCalculationMode.THREE_POINT_METHOD :
            _dataComplete := _dataIndex >= 3;
          FrameCalculationMode.FOUR_POINT_METHOD  :
            _dataComplete := _dataIndex >= 4; 
        END_CASE
  
         // create command data
         CommandData := CreateCommandPayload(AxesGroup := AxesGroup);
         // Add command to active command register
        _uniqueID := AxesGroup.Acyclic.ActiveCommandRegister.AddCmd( pCommandFB := ADR(THIS^ ));     
         // set timeout
         SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
         // inc step counter
        _stepCmd := _stepCmd + 1; 
  
  
    02:  // Wait for responce received
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
             // Reset Busy Flag
             Busy := FALSE;
             // Update results
             OutCmd.IEC_Date       := _response.IEC_Date;
             OutCmd.IEC_TIME       := _response.IEC_TIME;
             OutCmd.ReferenceFrame := _response.ReferenceFrame;
             OutCmd.Position       := _response.Position;
  
             IF ( _dataComplete ) OR (_response.State = CmdMessageState.ABORTED )
             THEN
               // set timeout
               SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
               // inc step counter
              _stepCmd := _stepCmd + 1; 
             ELSE
               // set timeout
               SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
               // dec step counter
              _stepCmd := _stepCmd - 1; 
             END_IF
           END_IF
         END_IF
  
  
    03: IF ( NOT Execute)
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
// Table 6-657: Received CMD payload (RC to PLC) of "CalculateFrame"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT     - ParSeq | State     
// Byte 01 : SINT      - AlarmMessageSeverity    
// Byte 02 : UINT      - AlarmMessageCode HB
// Byte 03 :           - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : IEC_DATE  - FrameData.Date HB
// Byte 05 :           - FrameData.Date LB
// Byte 06 : IEC_TIME  - FrameData.Time HB HW
// Byte 07 :           - FrameData.Time HB LW
// Byte 08 :           - FrameData.Time LW HB
// Byte 09 :           - FrameData.Time LW LB
// Byte 10 : USINT     - FrameData.ReferenceFrame
// Byte 11 : BYTE      - Reserve
// Byte 12 : REAL      - FrameData.X  HB HW
// Byte 13 :           - FrameData.X  HB LW
// Byte 14 :           - FrameData.X  LW HB
// Byte 15 :           - FrameData.X  LW LB
// Byte 16 : REAL      - FrameData.Y  HB HW
// Byte 17 :           - FrameData.Y  HB LW
// Byte 18 :           - FrameData.Y  LW HB
// Byte 19 :           - FrameData.Y  LW LB
// Byte 20 : REAL      - FrameData.Z  HB HW
// Byte 21 :           - FrameData.Z  HB LW
// Byte 22 :           - FrameData.Z  LW HB
// Byte 23 :           - FrameData.Z  LW LB
// Byte 24 : REAL      - FrameData.Rx HB HW
// Byte 25 :           - FrameData.Rx HB LW
// Byte 26 :           - FrameData.Rx LW HB
// Byte 27 :           - FrameData.Rx LW LB
// Byte 28 : REAL      - FrameData.Ry HB HW
// Byte 29 :           - FrameData.Ry HB LW
// Byte 30 :           - FrameData.Ry LW HB
// Byte 31 :           - FrameData.Ry LW LB
// Byte 32 : REAL      - FrameData.Rz HB HW
// Byte 33 :           - FrameData.Rz HB LW
// Byte 34 :           - FrameData.Rz LW HB
// Byte 35 :           - FrameData.Rz LW LB
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get response.IEC_Date
  _response.IEC_Date   := ResponseData.GetIecDate();
  // Get response.IEC_TIME
  _response.IEC_TIME   := ResponseData.GetIecTime();
  // Get response.ReferenceFrame
  _response.ReferenceFrame := ResponseData.GetUsint();
  // Get response.Reserve
  _response.Reserve := ResponseData.GetByte();
  // Get response.Position.X
  _response.Position.X := ResponseData.GetReal();
  // Get response.Position.Y
  _response.Position.Y := ResponseData.GetReal();
  // Get response.Position.Z
  _response.Position.Z := ResponseData.GetReal();
  // Get response.Position.Rx
  _response.Position.Rx := ResponseData.GetReal();
  // Get response.Position.Ry
  _response.Position.Ry := ResponseData.GetReal();
  // Get response.Position.Rz
  _response.Position.Rz := ResponseData.GetReal();
  
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
  
  // Create log entry for IEC_Date
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.IEC_Date = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_response.IEC_Date));
  
  // Create log entry for IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_response.IEC_TIME));
  
  // Create log entry for ReferenceFrame
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ReferenceFrame = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ReferenceFrame));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve));
  
  // Create log entry for Position.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.X));
  
  // Create log entry for Position.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.Y));
  
  // Create log entry for Position.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.Z));
  
  // Create log entry for Position.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.Rx));
  
  // Create log entry for Position.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.Ry));
  
  // Create log entry for Position.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Position.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.Position.Rz));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

