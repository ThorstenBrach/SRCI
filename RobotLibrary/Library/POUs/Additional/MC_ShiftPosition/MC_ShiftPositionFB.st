/// Transform a defined position in space
FUNCTION_BLOCK MC_ShiftPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ShiftPositionFB                                       
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
  ParCmd          : ShiftPositionParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command results
  OutCmd          : ShiftPositionOutCmd;    
END_VAR
VAR
  /// internal copy of command parameter 
 _parCmd          : ShiftPositionParCmd;
  /// command data to send
 _command         : ShiftPositionSendData;
  /// response data received
 _response        : ShiftPositionRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ShiftPosition;
  
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

  CheckParameterValid := TRUE;
  
  
  // Check ParCmd.Mode valid ? 
  IF (( ParCmd.Mode <> TransformMode.MIRROR_AT_POINT             ) AND  
      ( ParCmd.Mode <> TransformMode.MIRROR_AT_STRAIGHT_LINE     ) AND
      ( ParCmd.Mode <> TransformMode.MIRROR_AT_PLANE             ) AND
      ( ParCmd.Mode <> TransformMode.ROTATE_AROUND_STRAIGHT_LINE ) AND
      ( ParCmd.Mode <> TransformMode.SHIFT_BY_VECTOR             ))
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
                            Para1       :=  TRANSFORM_MODE_TO_STRING(ParCmd.Mode));
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
                            Para1       :=  USINT_TO_STRING(ParCmd.FrameNo));
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
                            Para1       :=  USINT_TO_STRING(ParCmd.TargetFrameNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_1.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.TransformationParameter_1.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_1.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.TransformationParameter_1.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.TransformationParameter_2 valid ? 
  IF (( ParCmd.TransformationParameter_2 <> ReferenceElement.NOT_USED ) AND  
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.X_AXIS   ) AND
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.Y_AXIS   ) AND
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.Z_AXIS   ) AND
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.XY_PLANE ) AND
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.XZ_PLANE ) AND
      ( ParCmd.TransformationParameter_2 <> ReferenceElement.YZ_PLANE ))
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
                            MessageText := 'Invalid Parameter ParCmd.TransformationParameter_2 = {1}',
                            Para1       := REFERENCE_ELEMENT_TO_STRING(ParCmd.TransformationParameter_2));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-668: Sent CMD payload (PLC to RC) of "ShiftPosition"
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
// Byte 04  : IEC_DATE  - TransformationParameter_1.Date
// Byte 05  :           - Reserved
// Byte 06  : IEC_TIME  - TransformationParameter_1.Time HW HB
// Byte 07  :           - TransformationParameter_1.Time HW LB
// Byte 08  :           - TransformationParameter_1.Time LW HB
// Byte 09  :           - TransformationParameter_1.Time LW LB
// Byte 10  : USINT     - TransformationParameter_1.ReferenceFrame
// Byte 11  : BYTE      - Reserved
// Byte 12  : REAL      - TransformationParameter_1.X HW HB
// Byte 13  :           - TransformationParameter_1.X HW LB
// Byte 14  :           - TransformationParameter_1.X LW HB
// Byte 15  :           - TransformationParameter_1.X LW LB
// Byte 16  : REAL      - TransformationParameter_1.Y HW HB
// Byte 17  :           - TransformationParameter_1.Y HW LB
// Byte 18  :           - TransformationParameter_1.Y LW HB
// Byte 19  :           - TransformationParameter_1.Y LW LB
// Byte 20  : REAL      - TransformationParameter_1.Z HW HB
// Byte 21  :           - TransformationParameter_1.Z HW LB
// Byte 22  :           - TransformationParameter_1.Z LW HB
// Byte 23  :           - TransformationParameter_1.Z LW LB
// Byte 24  : REAL      - TransformationParameter_1.RX HW HB
// Byte 25  :           - TransformationParameter_1.RX HW LB
// Byte 26  :           - TransformationParameter_1.RX LW HB
// Byte 27  :           - TransformationParameter_1.RX LW LB
// Byte 28  : REAL      - TransformationParameter_1.RY HW HB
// Byte 29  :           - TransformationParameter_1.RY HW LB
// Byte 30  :           - TransformationParameter_1.RY LW HB
// Byte 31  :           - TransformationParameter_1.RY LW LB
// Byte 32  : REAL      - TransformationParameter_1.RZ HW HB
// Byte 33  :           - TransformationParameter_1.RZ HW LB
// Byte 34  :           - TransformationParameter_1.RZ LW HB
// Byte 35  :           - TransformationParameter_1.RZ LW LB
// Byte 36  : USINT     - TransformationParameter_2
// Byte 37  : REAL      - RotationAngle HW HB
// Byte 38  :           - RotationAngle HW LB
// Byte 39  :           - RotationAngle LW HB
// Byte 40  :           - RotationAngle LW LB
// Byte 41  : SINT      - Mode
// Byte 42  : USINT     - FrameNo
// Byte 43  : USINT     - TargetFrameNo
// Byte 44  : REAL      - Position.X HW HB
// Byte 45  :           - Position.X HW LB
// Byte 46  :           - Position.X LW HB
// Byte 47  :           - Position.X LW LB
// Byte 48  : REAL      - Position.Y HW HB
// Byte 49  :           - Position.Y HW LB
// Byte 50  :           - Position.Y LW HB
// Byte 51  :           - Position.Y LW LB
// Byte 52  : REAL      - Position.Z HW HB
// Byte 53  :           - Position.Z HW LB
// Byte 54  :           - Position.Z LW HB
// Byte 55  :           - Position.Z LW LB
// Byte 56  : REAL      - Position.RX HW HB
// Byte 57  :           - Position.RX HW LB
// Byte 58  :           - Position.RX LW HB
// Byte 59  :           - Position.RX LW LB
// Byte 60  : REAL      - Position.RY HW HB
// Byte 61  :           - Position.RY HW LB
// Byte 62  :           - Position.RY LW HB
// Byte 63  :           - Position.RY LW LB
// Byte 64  : REAL      - Position.RZ HW HB
// Byte 65  :           - Position.RZ HW LB
// Byte 66  :           - Position.RZ LW HB
// Byte 67  :           - Position.RZ LW LB
// Byte 68  : ArmConfig - Position.Config
// Byte 69  :           -          Reserve
// Byte 70 : TurnNumber - Position.TurnNumber.J1 + J2  HW HB
// Byte 71 :            - Position.TurnNumber.J3 + J4  HW LB
// Byte 72 :            - Position.TurnNumber.J5 + J6  LW LB
// Byte 73 :            - Position.TurnNumber.E1       LW LB
// Byte 74  : REAL      - Position.E1 HW HB
// Byte 75  :           - Position.E1 HW LB
// Byte 76  :           - Position.E1 LW HB
// Byte 77  :           - Position.E1 LW LB
// Byte 78  : REAL      - Position.E2 HW HB
// Byte 79  :           - Position.E2 HW LB
// Byte 80  :           - Position.E2 LW HB
// Byte 81  :           - Position.E2 LW LB
// Byte 82  : REAL      - Position.E3 HW HB
// Byte 83  :           - Position.E3 HW LB
// Byte 84  :           - Position.E3 LW HB
// Byte 85  :           - Position.E3 LW LB
// Byte 86  : REAL      - Position.E4 HW HB
// Byte 87  :           - Position.E4 HW LB
// Byte 88  :           - Position.E4 LW HB
// Byte 89  :           - Position.E4 LW LB
// Byte 90  : REAL      - Position.E5 HW HB
// Byte 91  :           - Position.E5 HW LB
// Byte 92  :           - Position.E5 LW HB
// Byte 93  :           - Position.E5 LW LB
// Byte 94  : REAL      - Position.E6 HW HB
// Byte 95  :           - Position.E6 HW LB
// Byte 96  :           - Position.E6 LW HB
// Byte 97  :           - Position.E6 LW LB

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.ShiftPosition;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  _command.TransformationParameter_1 := _parCmd.TransformationParameter_1;
  _command.TransformationParameter_2 := _parCmd.TransformationParameter_2;
  _command.RotationAngle             := _parCmd.RotationAngle;
  _command.Mode                      := _parCmd.Mode;
  _command.FrameNo                   := _parCmd.FrameNo;
  _command.TargetFrameNo             := _parCmd.TargetFrameNo;
  _command.Position                  := _parCmd.Position;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.TransformationParameter_1.Timestamp.IEC_DATE
  CreateCommandPayload.AddIecDate(_command.TransformationParameter_1.Timestamp.IEC_DATE);
  // add command.TransformationParameter_1.Timestamp.IEC_TIME
  CreateCommandPayload.AddIecTime(_command.TransformationParameter_1.Timestamp.IEC_TIME);
  // add command.TransformationParameter_1.ReferenceFrame
  CreateCommandPayload.AddUsint(_command.TransformationParameter_1.ReferenceFrame);
  // add command.Reserve
  CreateCommandPayload.AddByte(0);
  // add command.TransformationParameter_1.X
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.X);
  // add command.TransformationParameter_1.Y
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Y);
  // add command.TransformationParameter_1.Z
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Z);
  // add command.TransformationParameter_1.Rx
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Rx);
  // add command.TransformationParameter_1.Ry
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Ry);
  // add command.TransformationParameter_1.Rz
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Rz);
  // add command.TransformationParameter_2
  CreateCommandPayload.AddUsint(_command.TransformationParameter_2);
  // add command.RotationAngle
  CreateCommandPayload.AddReal(_command.RotationAngle);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.TargetFrameNo
  CreateCommandPayload.AddUsint(_command.TargetFrameNo);
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
  // add command.Position.Config
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
    
  // Create log entry for TransformationParameter_1.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_command.TransformationParameter_1.Timestamp.IEC_DATE));
                         
  // Create log entry for TransformationParameter_1.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_command.TransformationParameter_1.Timestamp.IEC_TIME));
  
  // Create log entry for TransformationParameter_1.ReferenceFrame
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.ReferenceFrame = {1}',
                          Para1       :=  USINT_TO_STRING(_command.TransformationParameter_1.ReferenceFrame));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  USINT_TO_STRING(0));
  
  // Create log entry for TransformationParameter_1.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.X));
  
  // Create log entry for TransformationParameter_1.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.Y));
                         
  // Create log entry for TransformationParameter_1.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.Z));
  
  // Create log entry for TransformationParameter_1.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.Rx));
  
  // Create log entry for TransformationParameter_1.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.Ry));
  
  // Create log entry for TransformationParameter_1.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_1.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.TransformationParameter_1.Rz));
  
  // Create log entry for TransformationParameter_2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TransformationParameter_2 = {1}',
                          Para1       :=  USINT_TO_STRING(_command.TransformationParameter_2));
  
  // Create log entry for RotationAngle
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.RotationAngle = {1}',
                          Para1       :=  REAL_TO_STRING(_command.RotationAngle));
  
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  TRANSFORM_MODE_TO_STRING(_command.Mode));
  
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
  
  // Create log entry for TargetFrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.TargetFrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.TargetFrameNo));
                          
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
                          MessageText := 'Command.Config = {1}',
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

  MyType := 'MC_ShiftPositionFB';
  
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
             OutCmd.TransformedPosition := _response.TransformedPosition;
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
// Table 6-669: Received CMD payload (RC to PLC) of "ShiftPosition"
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
// Byte 04  : REAL      - TransformedPosition.X HW HB
// Byte 05  :           - TransformedPosition.X HW LB
// Byte 06  :           - TransformedPosition.X LW HB
// Byte 07  :           - TransformedPosition.X LW LB
// Byte 08  : REAL      - TransformedPosition.Y HW HB
// Byte 09  :           - TransformedPosition.Y HW LB
// Byte 10  :           - TransformedPosition.Y LW HB
// Byte 11  :           - TransformedPosition.Y LW LB
// Byte 12  : REAL      - TransformedPosition.Z HW HB
// Byte 13  :           - TransformedPosition.Z HW LB
// Byte 14  :           - TransformedPosition.Z LW HB
// Byte 15  :           - TransformedPosition.Z LW LB
// Byte 16  : REAL      - TransformedPosition.RX HW HB
// Byte 17  :           - TransformedPosition.RX HW LB
// Byte 18  :           - TransformedPosition.RX LW HB
// Byte 19  :           - TransformedPosition.RX LW LB
// Byte 20  : REAL      - TransformedPosition.RY HW HB
// Byte 21  :           - TransformedPosition.RY HW LB
// Byte 22  :           - TransformedPosition.RY LW HB
// Byte 23  :           - TransformedPosition.RY LW LB
// Byte 24  : REAL      - TransformedPosition.RZ HW HB
// Byte 25  :           - TransformedPosition.RZ HW LB
// Byte 26  :           - TransformedPosition.RZ LW HB
// Byte 27  :           - TransformedPosition.RZ LW LB
// Byte 28  : ArmConfig - TransformedPosition.Config
// Byte 29  :           - Reserved
// Byte 30  : TurnNumber- TransformedPosition.TurnNumber.J1 + J2  HW HB
// Byte 31  :           - TransformedPosition.TurnNumber.J3 + J4  HW LB
// Byte 32  :           - TransformedPosition.TurnNumber.J5 + J6  LW LB
// Byte 33  :           - TransformedPosition.TurnNumber.E1       LW LB
// Byte 34  : REAL      - TransformedPosition.E1 HW HB
// Byte 35  :           - TransformedPosition.E1 HW LB
// Byte 36  :           - TransformedPosition.E1 LW HB
// Byte 37  :           - TransformedPosition.E1 LW LB
// Byte 38  : REAL      - TransformedPosition.E2 HW HB
// Byte 39  :           - TransformedPosition.E2 HW LB
// Byte 40  :           - TransformedPosition.E2 LW HB
// Byte 41  :           - TransformedPosition.E2 LW LB
// Byte 42  : REAL      - TransformedPosition.E3 HW HB
// Byte 43  :           - TransformedPosition.E3 HW LB
// Byte 44  :           - TransformedPosition.E3 LW HB
// Byte 45  :           - TransformedPosition.E3 LW LB
// Byte 46  : REAL      - TransformedPosition.E4 HW HB
// Byte 47  :           - TransformedPosition.E4 HW LB
// Byte 48  :           - TransformedPosition.E4 LW HB
// Byte 49  :           - TransformedPosition.E4 LW LB
// Byte 50  : REAL      - TransformedPosition.E5 HW HB
// Byte 51  :           - TransformedPosition.E5 HW LB
// Byte 52  :           - TransformedPosition.E5 LW HB
// Byte 53  :           - TransformedPosition.E5 LW LB
// Byte 54  : REAL      - TransformedPosition.E6 HW HB
// Byte 55  :           - TransformedPosition.E6 HW LB
// Byte 56  :           - TransformedPosition.E6 LW HB
// Byte 57  :           - TransformedPosition.E6 LW LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.TransformedPosition.X
  _response.TransformedPosition.X := ResponseData.GetReal();
  // Get Response.TransformedPosition.Y
  _response.TransformedPosition.Y := ResponseData.GetReal();
  // Get Response.TransformedPosition.Z
  _response.TransformedPosition.Z := ResponseData.GetReal();
  // Get Response.TransformedPosition.Rx
  _response.TransformedPosition.Rx := ResponseData.GetReal();
  // Get Response.TransformedPosition.Ry
  _response.TransformedPosition.Ry := ResponseData.GetReal();
  // Get Response.TransformedPosition.Rz
  _response.TransformedPosition.Rz := ResponseData.GetReal();
  // Get Response.TransformedPosition.Config
  _response.TransformedPosition.Config := ResponseData.GetArmConfig();
  // Get Response.TransformedPosition.TurnNumber
  _response.TransformedPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get Response.TransformedPosition.E1
  _response.TransformedPosition.E1 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E2
  _response.TransformedPosition.E2 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E3
  _response.TransformedPosition.E3 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E4
  _response.TransformedPosition.E4 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E5
  _response.TransformedPosition.E5 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E6
  _response.TransformedPosition.E6 := ResponseData.GetReal();
  
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
                          
  // Create log entry for TransformedPosition.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.X));
  
  // Create log entry for TransformedPosition.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.Y));
  
  // Create log entry for TransformedPosition.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.Z));
  
  // Create log entry for TransformedPosition.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.Rx));
  
  // Create log entry for TransformedPosition.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.Ry));
  
  // Create log entry for TransformedPosition.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.Rz));
  
  
  // Create log entry for TransformedPosition.Config
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.Config = {1}',
                          Para1       :=  ARM_CONFIG_TO_STRING(_response.TransformedPosition.Config));
  
  // Create log entry for TransformedPosition.TurnNumber.J1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J1Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.J2Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J2Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J2Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.J3Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J3Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J3Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.J4Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J4Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J4Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.J5Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J5Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J5Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.J6Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.J6Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.J6Turns));
  
  // Create log entry for TransformedPosition.TurnNumber.E1Turns
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.TurnNumber.E1Turns = {1}',
                          Para1       :=  SINT_TO_STRING(_response.TransformedPosition.TurnNumber.E1Turns));
  
  // Create log entry for TransformedPosition.E1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E1 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E1));
  
  // Create log entry for TransformedPosition.E2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E2 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E2));
  
  // Create log entry for TransformedPosition.E3
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E3 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E3));
  
  // Create log entry for TransformedPosition.E4
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E4 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E4));
  
  // Create log entry for TransformedPosition.E5
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E5 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E5));
  
  // Create log entry for TransformedPosition.E6
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TransformedPosition.E6 = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TransformedPosition.E6));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

