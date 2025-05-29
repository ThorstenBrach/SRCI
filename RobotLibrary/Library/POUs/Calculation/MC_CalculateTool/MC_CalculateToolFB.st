/// Calculate tool (TCP) with four-point method
FUNCTION_BLOCK MC_CalculateToolFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateToolFB                                       
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
  /// Command parameter 
  ParCmd          : CalculateToolParCmd;      
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateToolOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateToolParCmd;
  /// command data to send
 _command         : CalculateToolSendData;
  /// response data received
 _response        : CalculateToolRecvData;      
  /// Incremented with each position of the input parameter "PositionsArray" sent from the PLC to the RC.
  /// • Default: 0
 _dataIndex       : USINT;
  /// Set TRUE by the client, when according to the user selected "Mode" the final position of the input parameter "PositionsArray" is sent to the RC.
  /// • Default: FALSE
 _dataComplete    : BOOL;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.CalculateTool;
  
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
  IF (( ParCmd.Mode <> ToolCalculationMode.  TWO_POINT_Z_METHOD ) AND  
      ( ParCmd.Mode <> ToolCalculationMode.  THREE_POINT_METHOD ) AND
      ( ParCmd.Mode <> ToolCalculationMode.   FOUR_POINT_METHOD ) AND
      ( ParCmd.Mode <> ToolCalculationMode.   FIVE_POINT_METHOD ) AND
      ( ParCmd.Mode <> ToolCalculationMode.    SIX_POINT_METHOD ) AND
      ( ParCmd.Mode <> ToolCalculationMode.    ABC_WORLD_METHOD ) AND
      ( ParCmd.Mode <> ToolCalculationMode.ABC_TWO_POINT_METHOD ))
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
                            Para1       :=  TOOL_CALCULATION_MODE_TO_STRING(ParCmd.Mode));
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
  
  
  // Check ParCmd.ExternalTCP valid ? 
  IF (( ParCmd.ExternalTCP <> FALSE ) AND  
      ( ParCmd.ExternalTCP <> TRUE  ))
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
                            MessageText := 'Invalid Parameter ParCmd.ExternalTCP = {1}',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ExternalTCP));
    RETURN;                          
  END_IF
  
  FOR _idx := 0 TO 5 
  DO 
    // Check ParCmd.PositionsArray[x].X valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].X) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].X = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].X),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
  
    // Check ParCmd.PositionsArray[x].Y valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].Y) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Y = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].Y),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.PositionsArray[x].Z valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].Z) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Z = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].Z),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.PositionsArray[x].Rx valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].Rx) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Rx = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].Rx),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    // Check ParCmd.PositionsArray[x].Ry valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].Ry) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Ry = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].Ry),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.PositionsArray[x].Rz valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].Rz) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Rz = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].Rz),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
  
    // Check ParCmd.PositionsArray[x].E1 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E1) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E1 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E1),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
  
    // Check ParCmd.PositionsArray[x].E2 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E1) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E2 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E2),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
    
    // Check ParCmd.PositionsArray[x].E3 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E3) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E3 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E3),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
    
    // Check ParCmd.PositionsArray[x].E4 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E4) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E4 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E4),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
    
    // Check ParCmd.PositionsArray[x].E5 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E5) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E5 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E5),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  
    
    // Check ParCmd.PositionsArray[x].E6 valid ? 
    IF ( SysDepIsValidReal(ParCmd.PositionsArray[_idx].E6) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].E6 = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.PositionsArray[_idx].E6),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.PositionsArray[x].Config.Shoulder valid ? 
    IF (( ParCmd.PositionsArray[_idx].Config.Shoulder <> ArmConfigShoulder.USE_CONFIG ) AND  
        ( ParCmd.PositionsArray[_idx].Config.Shoulder <> ArmConfigShoulder.SAME       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Shoulder <> ArmConfigShoulder.FREE       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Shoulder <> ArmConfigShoulder.BACK       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Shoulder <> ArmConfigShoulder.FRONT      ))
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Config.Shoulder = {1}',
                              Para1       :=  ARM_CONFIG_SHOULDER_TO_STRING(ParCmd.PositionsArray[_idx].Config.Shoulder),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
    
    
    // Check ParCmd.PositionsArray[x].Config.Elbow valid ? 
    IF (( ParCmd.PositionsArray[_idx].Config.Elbow <> ArmConfigElbow.USE_CONFIG ) AND  
        ( ParCmd.PositionsArray[_idx].Config.Elbow <> ArmConfigElbow.SAME       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Elbow <> ArmConfigElbow.FREE       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Elbow <> ArmConfigElbow.DOWN       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Elbow <> ArmConfigElbow.UP         ))
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2]].Config.Elbow = {1}',
                              Para1       :=  ARM_CONFIG_ELBOW_TO_STRING(ParCmd.PositionsArray[_idx].Config.Elbow),
                              Para2       :=  DINT_TO_STRING(_idx));
                              
      EXIT;                            
      RETURN;                          
    END_IF
  
      
    // Check ParCmd.PositionsArray[x].Config.Wrist valid ? 
    IF (( ParCmd.PositionsArray[_idx].Config.Wrist <> ArmConfigWrist.USE_CONFIG ) AND  
        ( ParCmd.PositionsArray[_idx].Config.Wrist <> ArmConfigWrist.SAME       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Wrist <> ArmConfigWrist.FREE       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Wrist <> ArmConfigWrist.FLIP       ) AND
        ( ParCmd.PositionsArray[_idx].Config.Wrist <> ArmConfigWrist.NON_FLIP   ))
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
                              MessageText := 'Invalid Parameter ParCmd.PositionsArray[{2}].Config.Wrist = {1}',
                              Para1       :=  ARM_CONFIG_WRIST_TO_STRING(ParCmd.PositionsArray[_idx].Config.Wrist),
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
// Table 6-650: Sent CMD payload (PLC to RC) of "CalculateTool"
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
// Byte 04 : USINT      - DataIndex
// Byte 05 : BOOL       - DataComplete
// Byte 06 : USINT      - ToolNo
// Byte 07 : USINT      - FrameNo
// Byte 08 : SINT       - Mode
// Byte 09 : USINT      - ExternalTCP
// Byte 10 : REAL       - Position.X  HW HB
// Byte 11 :            - Position.X  HW LB
// Byte 12 :            - Position.X  LW HB
// Byte 13 :            - Position.X  LW LB
// Byte 14 : REAL       - Position.Y  HW HB
// Byte 15 :            - Position.Y  HW LB
// Byte 16 :            - Position.Y  LW HB
// Byte 17 :            - Position.Y  LW LB
// Byte 18 : REAL       - Position.Z  HW HB
// Byte 19 :            - Position.Z  HW LB
// Byte 20 :            - Position.Z  LW HB
// Byte 21 :            - Position.Z  LW LB
// Byte 22 : REAL       - Position.Rx HW HB
// Byte 23 :            - Position.Rx HW LB
// Byte 24 :            - Position.Rx LW HB
// Byte 25 :            - Position.Rx LW LB
// Byte 26 : REAL       - Position.Ry HW HB
// Byte 27 :            - Position.Ry HW LB
// Byte 28 :            - Position.Ry LW HB
// Byte 29 :            - Position.Ry LW LB
// Byte 30 : REAL       - Position.Rz HW HB
// Byte 31 :            - Position.Rz HW LB
// Byte 32 :            - Position.Rz LW HB
// Byte 33 :            - Position.Rz LW LB
// Byte 34 : Config     - ArmConfig   LW HB
// Byte 35 :            - ArmConfig   LW LB
// Byte 36 : TurnNumber - J1 + J2     LW HB
// Byte 37 :            - J3 + J4     LW LB
// Byte 38 :            - J5 + J6     LW LB
// Byte 39 :            - E1          LW LB
// Byte 40 : REAL       - Position.E1 HW HB
// Byte 41 :            - Position.E1 HW LB
// Byte 42 :            - Position.E1 LW HB
// Byte 43 :            - Position.E1 LW LB
// Byte 44 : REAL       - Position.E2 HW HB
// Byte 45 :            - Position.E2 HW LB
// Byte 46 :            - Position.E2 LW HB
// Byte 47 :            - Position.E2 LW LB
// Byte 48 : REAL       - Position.E3 HW HB
// Byte 49 :            - Position.E3 HW LB
// Byte 50 :            - Position.E3 LW HB
// Byte 51 :            - Position.E3 LW LB
// Byte 52 : REAL       - Position.E4 HW HB
// Byte 53 :            - Position.E4 HW LB
// Byte 54 :            - Position.E4 LW HB
// Byte 55 :            - Position.E4 LW LB
// Byte 56 : REAL       - Position.E5 HW HB
// Byte 57 :            - Position.E5 HW LB
// Byte 58 :            - Position.E5 LW HB
// Byte 59 :            - Position.E5 LW LB
// Byte 60 : REAL       - Position.E6 HW HB
// Byte 61 :            - Position.E6 HW LB
// Byte 62 :            - Position.E6 LW HB
// Byte 63 :            - Position.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.CalculateTool;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.DataIndex      := _dataIndex;
  _command.DataComplete.0 := _dataComplete;
  _command.ToolNo         := _parCmd.ToolNo;
  _command.FrameNo        := _parCmd.FrameNo;
  _command.Mode           := _parCmd.Mode;
  _command.ExternalTCP.0  := _parCmd.ExternalTCP;
    
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.TargetFrameNo
  CreateCommandPayload.AddUsint(_command.DataIndex);
  // add command.DataComplete
  CreateCommandPayload.AddByte(_command.DataComplete);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.ExternalTCP);
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
  CreateCommandPayload.AddArmConfig (_command.Position.Config);
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
  
  // Create log entry for ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ToolNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ToolNo));
  
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
  
  // Create log entry for Mode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Mode = {1}',
                          Para1       :=  TOOL_CALCULATION_MODE_TO_STRING(_command.Mode));
  
  // Create log entry for ExternalTCP
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ExternalTCP = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.ExternalTCP.0));
  
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

  MyType := 'MC_CalculateToolFB';
  
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
  
          ToolCalculationMode.TWO_POINT_Z_METHOD :
            _dataComplete := _dataIndex >= 2;
          
          ToolCalculationMode.THREE_POINT_METHOD :
            _dataComplete := _dataIndex >= 3;
  
          ToolCalculationMode.FOUR_POINT_METHOD :
            _dataComplete := _dataIndex >= 4;        
  
          ToolCalculationMode.FIVE_POINT_METHOD :        
            _dataComplete := _dataIndex >= 5;
  
          ToolCalculationMode.SIX_POINT_METHOD :        
            _dataComplete := _dataIndex >= 6;
  
          ToolCalculationMode.ABC_WORLD_METHOD :
            _dataComplete := _dataIndex >= 1;
          
          ToolCalculationMode.ABC_TWO_POINT_METHOD :
            _dataComplete := _dataIndex >= 2;
  
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
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.TCPMaxError    := _response.TCPMaxError;
             OutCmd.TCPMeanError   := _response.TCPMeanError;
             OutCmd.ToolData       := _response.ToolData;
             
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
// Table 6-651: Received CMD payload (RC to PLC) of "CalculateTool"
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
// Byte 04 : IEC_DATE   - ToolData.Date LW HB
// Byte 05 :            - ToolData.Date LW LB
// Byte 06 : REAL       - TCPMaxError   HW HB
// Byte 07 :            - TCPMaxError   HW LB
// Byte 08 :            - TCPMaxError   LW HB
// Byte 09 :            - TCPMaxError   LW LB
// Byte 10 : REAL       - TCPMeanError  HW HB
// Byte 11 :            - TCPMeanError  HW LB
// Byte 12 :            - TCPMeanError  LW HB
// Byte 13 :            - TCPMeanError  LW LB
// Byte 14 : IEC_TIME   - ToolData.Time HW HB
// Byte 15 :            - ToolData.Time HW LB
// Byte 16 :            - ToolData.Time LW HB
// Byte 17 :            - ToolData.Time LW LB


// Byte 18 : REAL       - ToolData.X  HW HB
// Byte 19 :            - ToolData.X  HW LB
// Byte 20 :            - ToolData.X  LW HB
// Byte 21 :            - ToolData.X  LW LB
// Byte 22 : REAL       - ToolData.Y  HW HB
// Byte 23 :            - ToolData.Y  HW LB
// Byte 24 :            - ToolData.Y  LW HB
// Byte 25 :            - ToolData.Y  LW LB
// Byte 26 : REAL       - ToolData.Z  HW HB
// Byte 27 :            - ToolData.Z  HW LB
// Byte 28 :            - ToolData.Z  LW HB
// Byte 29 :            - ToolData.Z  LW LB
// Byte 30 : REAL       - ToolData.Rx HW HB
// Byte 31 :            - ToolData.Rx HW LB
// Byte 32 :            - ToolData.Rx LW HB
// Byte 33 :            - ToolData.Rx LW LB
// Byte 34 : REAL       - ToolData.Ry HW HB
// Byte 35 :            - ToolData.Ry HW LB
// Byte 36 :            - ToolData.Ry LW HB
// Byte 37 :            - ToolData.Ry LW LB
// Byte 38 : REAL       - ToolData.Rz HW HB
// Byte 39 :            - ToolData.Rz HW LB
// Byte 40 :            - ToolData.Rz LW HB
// Byte 41 :            - ToolData.Rz LW LB
// Byte 42 : USINT      - ToolData.ID
// Byte 43 : USINT      - ToolData.LoadNo
// Byte 44 : BOOL       - ToolData.ExternalTCP
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.IEC_Date
  _response.ToolData.Timestamp.IEC_Date := ResponseData.GetIecDate();
  // Get Response.TCPMaxError
  _response.TCPMaxError := ResponseData.GetReal();
  // Get Response.TCPMeanError
  _response.TCPMeanError := ResponseData.GetReal();
  // Get Response.ToolData.Time
  _response.ToolData.Timestamp.IEC_Time := ResponseData.GetIecTime();
  // Get Response.ToolData.X
  _response.ToolData.X := ResponseData.GetReal();
  // Get Response.ToolData.Y            
  _response.ToolData.Y := ResponseData.GetReal();
  // Get Response.ToolData.Z            
  _response.ToolData.Z := ResponseData.GetReal();
  // Get Response.ToolData.Rx           
  _response.ToolData.Rx := ResponseData.GetReal();
  // Get Response.ToolData.Ry           
  _response.ToolData.Ry := ResponseData.GetReal();
  // Get Response.ToolData.Rz           
  _response.ToolData.Rz := ResponseData.GetReal();
  // Get Response.ToolData.ID           
  _response.ToolData.ID := ResponseData.GetUsint();
  // Get Response.ToolData.LoadNo       
  _response.ToolData.LoadNo := ResponseData.GetUsint();
  // Get Response.ToolData.ExternalTCP
  _response.ToolData.ExternalTCP := ResponseData.GetBool();
  
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
                          MessageText := 'Response.ToolData.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_response.ToolData.Timestamp.IEC_DATE));
  
  // Create log entry for TCPMaxError
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TCPMaxError = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TCPMaxError));
  
  // Create log entry for TCPMeanError
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.TCPMeanError = {1}',
                          Para1       :=  REAL_TO_STRING(_response.TCPMeanError));
  
  // Create log entry for IEC_Time
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_response.ToolData.Timestamp.IEC_TIME));
  
  // Create log entry for ToolData.X
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.X = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.X));
  
  // Create log entry for ToolData.Y
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.Y));
  
  // Create log entry for ToolData.Z
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.Z));
  
  // Create log entry for ToolData.Rx
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.Rx));
  
  // Create log entry for ToolData.Ry
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.Ry));
  
  // Create log entry for ToolData.Rz
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_response.ToolData.Rz));
  
  // Create log entry for ToolData.ID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.ID = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ToolData.ID));
  
  // Create log entry for ToolData.LoadNo
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.LoadNo = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ToolData.LoadNo));
  
  // Create log entry for ToolData.ExternalTCP
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ToolData.ExternalTCP = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.ToolData.ExternalTCP));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

