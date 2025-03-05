/// Read the actual position cyclically
FUNCTION_BLOCK MC_ReadActualPositionCyclicFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionCyclicFB                                       
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
  ParCmd   : ReadActualPositionCyclicParCmd;
END_VAR

VAR_OUTPUT
  /// command outputs
  OutCmd   : ReadActualPositionCyclicOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd   : ReadActualPositionCyclicParCmd;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.ReadActualPositionCyclic;
  
  IF ( NOT CheckFunctionSupported )
  THEN
    // call base implementation for set error and create log entry
    SUPER^.CheckFunctionSupported(AxesGroup := AxesGroup);
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
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
    // Set busy flag
    Busy := TRUE;
    // reset enable flag
    Enabled := FALSE;
    // update internal copy of parameters 
   _parCmd := ParCmd;
    // update tool number 
    AxesGroup.Cyclic.PlcToRob.ToolNo  := _parCmd.ToolNo;
    // update frame number 
    AxesGroup.Cyclic.PlcToRob.FrameNo := _parCmd.FrameNo;
    // Create logging
    CreateCommandParameterLog(AxesGroup := AxesGroup);
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckParameterValid := TRUE;
  
  
  // Check ParCmd.ReadCartesianPosition valid ? 
  IF ( ParCmd.ReadCartesianPosition ) AND ( NOT AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Active) 
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
                            MessageText := 'Invalid Parameter ParCmd.ReadCartesianPosition = {1} but CyclicOptional.RobToPlc.CartesianPosition = FALSE',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ReadCartesianPosition));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReadCartesianPositionExt valid ? 
  IF ( ParCmd.ReadCartesianPositionExt ) AND ( NOT AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active) 
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
                            MessageText := 'Invalid Parameter ParCmd.ReadCartesianPositionExt = {1} but CyclicOptional.RobToPlc.CartesianPositionExt = FALSE',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ReadCartesianPositionExt));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <  -1 ) OR  
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
                            Para1       :=  INT_TO_STRING(ParCmd.ToolNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <  -1 ) OR  
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
                            Para1       :=  INT_TO_STRING(ParCmd.FrameNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReadJointPosition valid ? 
  IF ( ParCmd.ReadJointPosition ) AND ( NOT AxesGroup.CyclicOptional.RobToPlc.JointPosition.Active) 
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
                            MessageText := 'Invalid Parameter ParCmd.ReadJointPosition = {1} but CyclicOptional.RobToPlc.JointPosition = FALSE',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ReadJointPosition));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReadJointPositionExt valid ? 
  IF ( ParCmd.ReadJointPositionExt ) AND ( NOT AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.Active) 
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
                            MessageText := 'Invalid Parameter ParCmd.ReadJointPositionExt = {1} but CyclicOptional.RobToPlc.JointPositionExt = FALSE',
                            Para1       :=  BOOL_TO_STRING(ParCmd.ReadJointPositionExt));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandParameterLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Update position with the following parameter(s) :');
                          
  // Create log entry for _parCmd.ReadCartesianPosition
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.ReadCartesianPosition = {1}',
                          Para1       :=  BOOL_TO_STRING(_parCmd.ReadCartesianPosition));
  
  // Create log entry for _parCmd.ReadCartesianPositionExt
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.ReadCartesianPositionExt = {1}',
                          Para1       :=  BOOL_TO_STRING(_parCmd.ReadCartesianPositionExt));
  
  // Create log entry for _parCmd.ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.ToolNo = {1}',
                          Para1       :=  INT_TO_STRING(_parCmd.ToolNo));
  
  // Create log entry for _parCmd.FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.FrameNo = {1}',
                          Para1       :=  INT_TO_STRING(_parCmd.FrameNo));
  
  // Create log entry for _parCmd.ReadJointPosition
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.ReadJointPosition = {1}',
                          Para1       :=  BOOL_TO_STRING(_parCmd.ReadJointPosition));
  
  // Create log entry for _parCmd.ReadJointPositionExt
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '_parCmd.ReadJointPositionExt = {1}',
                          Para1       :=  BOOL_TO_STRING(_parCmd.ReadJointPositionExt));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadActualPositionCyclicFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  SUPER^.OnCall(AxesGroup := AxesGroup);
  
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
             // set parameter
             AxesGroup.Cyclic.PlcToRob.ToolNo  := _parCmd.ToolNo;
             AxesGroup.Cyclic.PlcToRob.FrameNo := _parCmd.FrameNo;   
             // Create logging
             CreateCommandParameterLog(AxesGroup := AxesGroup);  
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF 
         END_IF
       
  
    01:  // Wait for FrameNo and ToolNo set
         IF ((  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.FrameNo = _parCmd.FrameNo )  AND
             (  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.ToolNo  = _parCmd.ToolNo  )) OR
             ( _parCmd.ReadCartesianPosition                                                 = FALSE           ) 
         THEN
           // busy 
           Busy := FALSE;
           // reset busy flag
           Enabled := TRUE;          
           // Reset command outputs
           SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
           // set ToolNo and FrameNo
           OutCmd.CurrentCoordinateSystem.FrameNo := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.FrameNo;
           OutCmd.CurrentCoordinateSystem.ToolNo  := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.ToolNo;
           
           // Set cartesian position
           IF ( _parCmd.ReadCartesianPosition )  
           THEN
              OutCmd.ReadingCartesianPosition     := TRUE;
              OutCmd.CartesianPosition.X          := OutCmd.CartesianPositionShort.X          := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.X;
              OutCmd.CartesianPosition.Y          := OutCmd.CartesianPositionShort.Y          := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Y;         
              OutCmd.CartesianPosition.Z          := OutCmd.CartesianPositionShort.Z          := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Z;
              OutCmd.CartesianPosition.Rx         := OutCmd.CartesianPositionShort.Rx         := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Rx;
              OutCmd.CartesianPosition.Ry         := OutCmd.CartesianPositionShort.Ry         := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Ry;
              OutCmd.CartesianPosition.Rz         := OutCmd.CartesianPositionShort.Rz         := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Rz;
              OutCmd.CartesianPosition.Config     := OutCmd.CartesianPositionShort.Config     := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Config;
              OutCmd.CartesianPosition.TurnNumber := OutCmd.CartesianPositionShort.TurnNumber := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber;            
              OutCmd.CartesianPosition.E1         := OutCmd.CartesianPositionShort.E1         := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.E1;
           END_IF
           
           // Set extended cartesian position
           IF ( _parCmd.ReadCartesianPositionExt )  
           THEN
              OutCmd.ReadingCartesianPositionExt  := TRUE;
              OutCmd.CartesianPosition.E2         := OutCmd.CartesianPositionExt.E2           := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E2;
              OutCmd.CartesianPosition.E3         := OutCmd.CartesianPositionExt.E3           := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E3;
              OutCmd.CartesianPosition.E4         := OutCmd.CartesianPositionExt.E4           := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E4;
              OutCmd.CartesianPosition.E5         := OutCmd.CartesianPositionExt.E5           := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E5;
              OutCmd.CartesianPosition.E6         := OutCmd.CartesianPositionExt.E6           := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E6;    
           END_IF      
  
           // Set joint position
           IF ( _parCmd.ReadJointPosition )  
           THEN
              OutCmd.ReadingJointPosition         := TRUE;         
              OutCmd.JointPosition.J1             := OutCmd.JointPositionShort.J1             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J1;
              OutCmd.JointPosition.J2             := OutCmd.JointPositionShort.J2             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J2;
              OutCmd.JointPosition.J3             := OutCmd.JointPositionShort.J3             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J3;
              OutCmd.JointPosition.J4             := OutCmd.JointPositionShort.J4             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J4;
              OutCmd.JointPosition.J5             := OutCmd.JointPositionShort.J5             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J5;
              OutCmd.JointPosition.J6             := OutCmd.JointPositionShort.J6             := AxesGroup.CyclicOptional.RobToPlc.JointPosition.J6;    
           END_IF    
    
           // Set extended joint position
           IF ( _parCmd.ReadJointPositionExt )  
           THEN         
              OutCmd.ReadingCartesianPositionExt  := TRUE;         
              OutCmd.JointPosition.E2             := OutCmd.JointPositionExt.E2               := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E2;
              OutCmd.JointPosition.E3             := OutCmd.JointPositionExt.E3               := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E3;
              OutCmd.JointPosition.E4             := OutCmd.JointPositionExt.E4               := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E4;
              OutCmd.JointPosition.E5             := OutCmd.JointPositionExt.E5               := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E5;
              OutCmd.JointPosition.E6             := OutCmd.JointPositionExt.E6               := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E6;    
           END_IF
         END_IF
         
         IF ( NOT Enable)
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
  
  
    02:  IF (NOT Enable)
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

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  // Reset command outputs
  SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));

END_METHOD

