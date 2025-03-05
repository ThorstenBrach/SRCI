/// Activate superimposed motion of TCP to defined motion
FUNCTION_BLOCK MC_MoveSuperImposedDynamicFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedDynamicFB                                       
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
  Enable            : BOOL;  
  /// command parameter 
  ParCmd            : MoveSuperImposedDynamicParCmd;
END_VAR

VAR_OUTPUT
  /// FB is being processed
  Busy              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// The command takes control of the motion of the according axis group
  Active            : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command outputs
  OutCmd             : MoveSuperImposedDynamicOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : MoveSuperImposedDynamicParCmd;
  /// command data to send
 _command           : MoveSuperImposedDynamicSendData;
  /// response data received
 _response          : MoveSuperImposedDynamicRecvData;     
  /// Rising edge for enable
 _enable_R          : R_TRIG;
  /// Falling edge for enable
 _enable_F          : F_TRIG; 
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.MoveSuperImposedDynamic;
  
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
  
  
  // Check ParCmd.Offset.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.X) = FALSE ) 
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
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
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.Offset.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E1 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E1) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E1 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E1));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E2 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E2) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E2 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E2));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E3 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E3) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E3 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E3));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E4 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E4) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E4 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E4));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E5 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E5) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E5 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E5));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.E6 valid ? 
  IF ( SysDepIsValidReal(ParCmd.Offset.E6) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.E6 = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Offset.E6));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Config.Shoulder valid ? 
  IF (( ParCmd.Offset.Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
      ( ParCmd.Offset.Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
      ( ParCmd.Offset.Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
      ( ParCmd.Offset.Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
      ( ParCmd.Offset.Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Config.Shoulder = {1}',
                            Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.Offset.Config.Shoulder));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Config.Elbow valid ? 
  IF (( ParCmd.Offset.Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
      ( ParCmd.Offset.Config.Elbow <> ArmConfigElbow.SAME       ) AND
      ( ParCmd.Offset.Config.Elbow <> ArmConfigElbow.FREE       ) AND
      ( ParCmd.Offset.Config.Elbow <> ArmConfigElbow.DOWN       ) AND
      ( ParCmd.Offset.Config.Elbow <> ArmConfigElbow.UP         ))
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Config.Elbow = {1}',
                            Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.Offset.Config.Elbow));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Offset.Config.Wrist valid ? 
  IF (( ParCmd.Offset.Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
      ( ParCmd.Offset.Config.Wrist <> ArmConfigWrist.SAME       ) AND
      ( ParCmd.Offset.Config.Wrist <> ArmConfigWrist.FREE       ) AND
      ( ParCmd.Offset.Config.Wrist <> ArmConfigWrist.FLIP       ) AND
      ( ParCmd.Offset.Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                            MessageText := 'Invalid Parameter ParCmd.Offset.Config.Wrist = {1}',
                            Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.Offset.Config.Wrist));
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
  
  
  // Check ParCmd.VelocityDiffRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.VelocityDiffRate) = FALSE )  OR
      ((                   ParCmd.VelocityDiffRate  <     0 )  AND 
       (                   ParCmd.VelocityDiffRate <>    -1 )) OR   
       (                   ParCmd.VelocityDiffRate  >   100 ))      
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
                            MessageText := 'Invalid Parameter ParCmd.VelocityDiffRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.VelocityDiffRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.AccelerationDiffRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.AccelerationDiffRate) = FALSE )  OR
      ((                   ParCmd.AccelerationDiffRate  <     0 )  AND 
       (                   ParCmd.AccelerationDiffRate <>    -1 )) OR   
       (                   ParCmd.AccelerationDiffRate  >   100 ))      
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
                            MessageText := 'Invalid Parameter ParCmd.AccelerationDiffRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.AccelerationDiffRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.DecelerationDiffRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.DecelerationDiffRate) = FALSE )  OR
      ((                   ParCmd.DecelerationDiffRate  <     0 )  AND 
       (                   ParCmd.DecelerationDiffRate <>    -1 )) OR   
       (                   ParCmd.DecelerationDiffRate  >   100 ))      
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
                            MessageText := 'Invalid Parameter ParCmd.DecelerationDiffRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.DecelerationDiffRate));                            
    RETURN;
  END_IF
  
  
  // Check ParCmd.JerkDiffRate valid ? 
  IF  (( SysDepIsValidReal(ParCmd.JerkDiffRate) = FALSE )  OR
      ((                   ParCmd.JerkDiffRate  <     0 )  AND 
       (                   ParCmd.JerkDiffRate <>    -1 )) OR   
       (                   ParCmd.JerkDiffRate  >   100 ))      
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
                            MessageText := 'Invalid Parameter ParCmd.JerkDiffRate = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.JerkDiffRate));                            
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
  
  
  // Check ParCmd.InterpolationMode valid ? 
  IF  (( ParCmd.InterpolationMode <> InterpolationMode.Linear_interpolation ) AND
       ( ParCmd.InterpolationMode <> InterpolationMode.Direct_interpolation ))     
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
                            MessageText := 'Invalid Parameter ParCmd.InterpolationMode = {1}',
                            Para1       := INTERPOLATION_MODE_TO_STRING(ParCmd.InterpolationMode));
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-470: Sent CMD payload (PLC to RC) of "MoveSuperImposedDynamic"
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
// Byte 04 : UINT  VelocityRate;
// Byte 05 :       VelocityRate;
// Byte 06 :       VelocityRate;
// Byte 07 : UINT  AccelerationRate;
// Byte 08 :       AccelerationRate;
// Byte 09 :       AccelerationRate;
// Byte 10 : UINT  DecelerationRate;
// Byte 11 :       DecelerationRate;
// Byte 12 :       DecelerationRate;
// Byte 13 : UINT  JerkRate;
// Byte 14 :       JerkRate;
// Byte 15 :       JerkRate;
// Byte 16 : USINT ToolNo;
// Byte 17 : USINT FrameNo;
// Byte 18 : REAL  X;
// Byte 19 :       X;
// Byte 20 :       X;
// Byte 21 :       X;
// Byte 22 : REAL  Offset.X;
// Byte 23 :       Offset.X;
// Byte 24 :       Offset.X;
// Byte 25 :       Offset.X;
// Byte 26 : REAL  Offset.Y;
// Byte 27 :       Offset.Y;
// Byte 28 :       Offset.Y;
// Byte 29 :       Offset.Y;
// Byte 30 : REAL  Offset.Z;
// Byte 31 :       Offset.Z;
// Byte 32 :       Offset.Z;
// Byte 33 :       Offset.Z;
// Byte 34 : REAL  Offset.RX;
// Byte 35 :       Offset.RX;
// Byte 36 :       Offset.RX;
// Byte 37 :       Offset.RX;
// Byte 38 : REAL  Offset.RY;
// Byte 39 :       Offset.RY;
// Byte 40 :       Offset.RY;
// Byte 41 :       Offset.RY;
// Byte 42 : BYTE  - - - - - W E S;
// Byte 43 : BYTE  Reserved;
// Byte 44 : BYTE  Offset.TurnNumber[0];
// Byte 45 : BYTE  Offset.TurnNumber[1];
// Byte 46 : BYTE  Offset.TurnNumber[2];
// Byte 47 : BYTE  Offset.TurnNumber[3];
// Byte 48 : REAL  Offset.E1;
// Byte 49 :       Offset.E1;
// Byte 50 :       Offset.E1;
// Byte 51 :       Offset.E1;
// Byte 52 : USINT ReferenceType;
// Byte 53 : USINT InterpolationMode;
// Byte 54 : REAL  Offset.E2;
// Byte 55 :       Offset.E2;
// Byte 56 :       Offset.E2;
// Byte 57 :       Offset.E2;
// Byte 58 : REAL  Offset.E3;
// Byte 59 :       Offset.E3;
// Byte 60 :       Offset.E3;
// Byte 61 :       Offset.E3;
// Byte 62 : REAL  Offset.E4;
// Byte 63 :       Offset.E4;
// Byte 64 :       Offset.E4;
// Byte 65 :       Offset.E4;
// Byte 66 : REAL  Offset.E5;
// Byte 67 :       Offset.E5;
// Byte 68 :       Offset.E5;
// Byte 69 :       Offset.E5;
// Byte 70 : REAL  Offset.E6;
// Byte 71 :       Offset.E6;
// Byte 72 :       Offset.E6;
// Byte 73 :       Offset.E6;

  // set command parameter 
  _command.CmdTyp               :=  CmdType.MoveSuperImposedDynamic;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  _command.VelocityDiffRate     :=  REAL_TO_PERCENT_UINT(_parCmd.VelocityDiffRate     , IsOptional := FALSE);
  _command.AccelerationDiffRate :=  REAL_TO_PERCENT_UINT(_parCmd.AccelerationDiffRate , IsOptional := FALSE);
  _command.DecelerationDiffRate :=  REAL_TO_PERCENT_UINT(_parCmd.DecelerationDiffRate , IsOptional := TRUE );
  _command.JerkDiffRate         :=  REAL_TO_PERCENT_UINT(_parCmd.JerkDiffRate         , IsOptional := TRUE );
  _command.ToolNo               := _parCmd.ToolNo;
  _command.FrameNo              := _parCmd.FrameNo;
  _command.Reserve_X            :=  0.0;
  _command.Offset               := _parCmd.Offset;
  _command.ReferenceType        := _parCmd.ReferenceType;
  _command.InterpolationMode    := _parCmd.InterpolationMode;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.VelocityDiffRate
  CreateCommandPayload.AddUint(_command.VelocityDiffRate);
  // add command.AccelerationDiffRate
  CreateCommandPayload.AddUint(_command.AccelerationDiffRate);
  // add command.DecelerationDiffRate
  CreateCommandPayload.AddUint(_command.DecelerationDiffRate);
  // add command.JerkDiffRate
  CreateCommandPayload.AddUint(_command.JerkDiffRate);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Reserve_X
  CreateCommandPayload.AddReal(_command.Reserve_X);
  // add command.Offset.X
  CreateCommandPayload.AddReal(_command.Offset.X);
  // add command.Offset.Y
  CreateCommandPayload.AddReal(_command.Offset.Y);
  // add command.Offset.Z
  CreateCommandPayload.AddReal(_command.Offset.Z);
  // add command.Offset.Rx
  CreateCommandPayload.AddReal(_command.Offset.Rx);
  // add command.Offset.Ry
  CreateCommandPayload.AddReal(_command.Offset.Ry);
  // add command.Offset.Rz
  CreateCommandPayload.AddReal(_command.Offset.Rz);
  // add command.Offset.Config
  CreateCommandPayload.AddArmConfig(_command.Offset.Config);
  // add command.Offset.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Offset.TurnNumber);
  // add command.Offset.E1
  CreateCommandPayload.AddReal(_command.Offset.E1);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.InterpolationMode
  CreateCommandPayload.AddUsint(_command.InterpolationMode);
  // add command.Offset.E2
  CreateCommandPayload.AddReal(_command.Offset.E2);
  // add command.Offset.E3
  CreateCommandPayload.AddReal(_command.Offset.E3);
  // add command.Offset.E4
  CreateCommandPayload.AddReal(_command.Offset.E4);
  // add command.Offset.E5
  CreateCommandPayload.AddReal(_command.Offset.E5);
  // add command.Offset.E6
  CreateCommandPayload.AddReal(_command.Offset.E6);
  
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
    
  // Create log entry for VelocityDiffRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VelocityDiffRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.VelocityDiffRate));
  
  // Create log entry for AccelerationDiffRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.AccelerationDiffRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.AccelerationDiffRate));
                          
  // Create log entry for DecelerationDiffRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DecelerationDiffRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.DecelerationDiffRate));
  
  // Create log entry for JerkDiffRate
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JerkDiffRate = {1}',
                          Para1       :=  UINT_TO_STRING(_command.JerkDiffRate));
  
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
  
  // Create log entry for Reserve_X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve_X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Reserve_X));
  
  // Create log entry for Offset.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.X));
  
  // Create log entry for Offset.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Y));
  
  // Create log entry for Offset.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Z));
  
  // Create log entry for Offset.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rx));
  
  // Create log entry for Offset.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Ry));
  
  // Create log entry for Offset.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.Rz));
  
  // Create log entry for Offset.Config
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_command.Offset.Config));
  
  // Create log entry for Offset.TurnNumber[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.TurnNumber[0] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Offset.TurnNumber.J2Turns,
                                                                          HalfSintLo := _command.Offset.TurnNumber.J1Turns)));
  
  // Create log entry for Offset.TurnNumber[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.TurnNumber[1] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Offset.TurnNumber.J4Turns, 
                                                                          HalfSintLo := _command.Offset.TurnNumber.J3Turns)));
  
  // Create log entry for Offset.TurnNumber[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.TurnNumber[2] = {1}',
                          Para1       :=  BYTE_TO_STRING(CombineHalfSints(HalfSintHi := _command.Offset.TurnNumber.J6Turns, 
                                                                          HalfSintLo := _command.Offset.TurnNumber.J5Turns)));
  
  // Create log entry for Offset.TurnNumber[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Position.TurnNumber[3] = {1}',
                          Para1       :=  SINT_TO_STRING(_command.Offset.TurnNumber.E1Turns));
  
  // Create log entry for Offset.E1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E1));
  
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  REFERENCE_TYPE_TO_STRING(_command.ReferenceType));
  
  // Create log entry for InterpolationMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.InterpolationMode = {1}',
                          Para1       :=  INTERPOLATION_MODE_TO_STRING(_command.InterpolationMode));
  
  // Create log entry for Offset.E2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E2));
  
  // Create log entry for Offset.E3
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E3));
  
  // Create log entry for Offset.E4
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E4));
  
  // Create log entry for Offset.E5
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E5));
  
  // Create log entry for Offset.E6
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Offset.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Offset.E6));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveSuperImposedDynamicFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q ) 
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
          
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
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.OffsetReached     := _response.OffsetReached;
             OutCmd.Progress          := _response.Progress;
             OutCmd.RemainingDistance := _response.RemainingDistance;
             
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
  
    02: IF (NOT Enable)
        THEN
          Reset();
  	    END_IF
  
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
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
// Table 6-471: Received CMD payload (RC to PLC) of "MoveSuperImposedDynamic"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : UINT  - Progress HB
// Byte 05 : UINT  - Progress LB
// Byte 06 : REAL  - RemainingDistance HW HB
// Byte 07 :       - RemainingDistance HW LB
// Byte 08 :       - RemainingDistance LW HB
// Byte 09 :       - RemainingDistance LW LB
// Byte 10 : BOOL  - OffsetReached
// --------------------------

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
  // Get Response.OffsetReached
  _response.OffsetReached := ResponseData.GetBool();
  
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
  
  // Create log entry for OffsetReached
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.OffsetReached = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.OffsetReached));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy              := FALSE;
  CommandBuffered   := FALSE;
  Active            := FALSE;
  ParameterAccepted := FALSE;

END_METHOD

