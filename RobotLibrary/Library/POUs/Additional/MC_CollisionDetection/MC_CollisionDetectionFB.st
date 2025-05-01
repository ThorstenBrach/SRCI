/// Turn on/off the collision detection
FUNCTION_BLOCK MC_CollisionDetectionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CollisionDetectionFB                                       
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
  /// Processing mode
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag; 
  /// Command parameter 
  ParCmd             : CollisionDetectionParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;  
  /// command results
  OutCmd             : CollisionDetectionOutCmd;      
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : CollisionDetectionParCmd;
  /// command data to send
 _command            : CollisionDetectionSendData;
  /// response data received
 _response           : CollisionDetectionRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.CollisionDetection;
  
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
  
  // Check ProcessingMode valid ? 
  IF (( ProcessingMode <> ProcessingModeEnum.BUFFERED ) AND
      ( ProcessingMode <> ProcessingModeEnum.ABORTING ) AND  
      ( ProcessingMode <> ProcessingModeEnum.PARALLEL ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_PROCESSINGMODE_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ProcessingMode = {1}',
                            Para1       := PROCESSING_MODE_TO_STRING(ProcessingMode));
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
  
  
  // Check ParCmd.ReactionMode valid ? 
  IF (( ParCmd.ReactionMode < CollisionReactionMode.STANDING_STILL    ) OR  
      ( ParCmd.ReactionMode > CollisionReactionMode.REVERSED_MOVEMENT ))
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
                            MessageText := 'Invalid Parameter ParCmd.ReactionMode = {1}',
                            Para1       :=  COLLISION_REACTION_MODE_TO_STRING(ParCmd.ReactionMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ThresholdMode valid ? 
  IF (( ParCmd.ThresholdMode <> ThresholdMode.AUTOMATIC ) AND  
      ( ParCmd.ThresholdMode <> ThresholdMode.MANUAL    ))
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
                            MessageText := 'Invalid Parameter ParCmd.ThresholdMode = {1}',
                            Para1       := THRESHOLD_MODE_TO_STRING(ParCmd.ThresholdMode));
    RETURN;                          
  END_IF
  
  
  
  // Check ParCmd.Sensitivity valid ? 
  IF (( SysDepIsValidReal(ParCmd.Sensitivity) = FALSE ) OR
      ( ParCmd.Sensitivity                    <     0 ) OR  
      ( ParCmd.Sensitivity                    >   200 ))
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
                            MessageText := 'Invalid Parameter ParCmd.Sensitivity = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Sensitivity));
    RETURN;                          
  END_IF
  
  
  
  FOR _idx := 0 TO 6
  DO
    // Check ParCmd.SensitivityAxis valid ? 
    IF (( SysDepIsValidReal(ParCmd.SensitivityAxis[_idx]) = FALSE ) OR
        (                   ParCmd.SensitivityAxis[_idx]  <     0 ) OR  
        (                   ParCmd.SensitivityAxis[_idx]  >   200 ))      
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
                              MessageText := 'Invalid Parameter ParCmd.SensitivityAxis[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SensitivityAxis[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  END_FOR  
  
  
  FOR _idx := 0 TO 6
  DO
    // Check ParCmd.LimitAxis valid ? 
    IF (( SysDepIsValidReal(ParCmd.LimitAxis[_idx]) = FALSE ))
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
                              MessageText := 'Invalid Parameter ParCmd.LimitAxis[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.LimitAxis[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;
      RETURN;                          
    END_IF
  END_FOR  
  
  
  // Check ParCmd.UnitLimitAxis valid ? 
  IF (( ParCmd.UnitLimitAxis <> UnitLimitAxis.PERCENTAGE  ) AND  
      ( ParCmd.UnitLimitAxis <> UnitLimitAxis.NEWTONMETER ) AND
      ( ParCmd.UnitLimitAxis <> UnitLimitAxis.MILLIAMPERE ))
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
                            MessageText := 'Invalid Parameter ParCmd.UnitLimitAxis = {1}',
                            Para1       := THRESHOLD_MODE_TO_STRING(ParCmd.UnitLimitAxis));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-790: Sent CMD payload (PLC to RC) of "CollisionDetection"
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
// Byte 04 : BOOL      - ActivateMonitoring
// Byte 05 : USINT     - UnitLimitAxis
// Byte 06 : USINT     - ThresholdMode
// Byte 07 : USINT     - ReactionMode
// Byte 08 : INT       - Sensitivity
// Byte 09 :           - Reserved
// Byte 10 : INT       - SensitivityAxis[0]
// Byte 11 :           - Reserved
// Byte 12 : INT       - SensitivityAxis[1]
// Byte 13 :           - Reserved
// Byte 14 : INT       - SensitivityAxis[2]
// Byte 15 :           - Reserved
// Byte 16 : INT       - SensitivityAxis[3]
// Byte 17 :           - Reserved
// Byte 18 : INT       - SensitivityAxis[4]
// Byte 19 :           - Reserved
// Byte 20 : INT       - SensitivityAxis[5]
// Byte 21 :           - Reserved
// Byte 22 : INT       - SensitivityAxis[6]
// Byte 23 :           - Reserved
// Byte 24 : REAL      - LimitAxis[0] HW HB
// Byte 25 :           - LimitAxis[0] HW LB
// Byte 26 :           - LimitAxis[0] LW HB
// Byte 27 :           - LimitAxis[0] LW LB
// Byte 28 : REAL      - LimitAxis[1] HW HB
// Byte 29 :           - LimitAxis[1] HW LB
// Byte 30 :           - LimitAxis[1] LW HB
// Byte 31 :           - LimitAxis[1] LW LB
// Byte 32 : REAL      - LimitAxis[2] HW HB
// Byte 33 :           - LimitAxis[2] HW LB
// Byte 34 :           - LimitAxis[2] LW HB
// Byte 35 :           - LimitAxis[2] LW LB
// Byte 36 : REAL      - LimitAxis[3] HW HB
// Byte 37 :           - LimitAxis[3] HW LB
// Byte 38 :           - LimitAxis[3] LW HB
// Byte 39 :           - LimitAxis[3] LW LB
// Byte 40 : REAL      - LimitAxis[4] HW HB
// Byte 41 :           - LimitAxis[4] HW LB
// Byte 42 :           - LimitAxis[4] LW HB
// Byte 43 :           - LimitAxis[4] LW LB
// Byte 44 : REAL      - LimitAxis[5] HW HB
// Byte 45 :           - LimitAxis[5] HW LB
// Byte 46 :           - LimitAxis[5] LW HB
// Byte 47 :           - LimitAxis[5] LW LB
// Byte 48 : REAL      - LimitAxis[6] HW HB
// Byte 49 :           - LimitAxis[6] HW LB
// Byte 50 :           - LimitAxis[6] LW HB
// Byte 51 :           - LimitAxis[6] LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp               :=  CmdType.CollisionDetection;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  
  _command.ActivateMonitoring   := _parCmd.ActivateMonitoring;
  _command.UnitLimitAxis        := _parCmd.UnitLimitAxis;
  _command.ThresholdMode        := _parCmd.ThresholdMode;
  _command.ReactionMode         := _parCmd.ReactionMode;
  _command.Sensitivity          :=  REAL_TO_PERCENT_INT(_parCmd.Sensitivity        , IsOptional := TRUE);
  _command.SensitivityAxis[0]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[0] , IsOptional := TRUE);
  _command.SensitivityAxis[1]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[1] , IsOptional := TRUE);
  _command.SensitivityAxis[2]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[2] , IsOptional := TRUE);
  _command.SensitivityAxis[3]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[3] , IsOptional := TRUE);
  _command.SensitivityAxis[4]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[4] , IsOptional := TRUE);
  _command.SensitivityAxis[5]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[5] , IsOptional := TRUE);
  _command.SensitivityAxis[6]   :=  REAL_TO_PERCENT_INT(_parCmd.SensitivityAxis[6] , IsOptional := TRUE);
  _command.LimitAxis[0]         := _parCmd.LimitAxis[0];
  _command.LimitAxis[1]         := _parCmd.LimitAxis[1];
  _command.LimitAxis[2]         := _parCmd.LimitAxis[2];
  _command.LimitAxis[3]         := _parCmd.LimitAxis[3];
  _command.LimitAxis[4]         := _parCmd.LimitAxis[4];
  _command.LimitAxis[5]         := _parCmd.LimitAxis[5];
  _command.LimitAxis[6]         := _parCmd.LimitAxis[6];
  
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.ActivateMonitoring
  CreateCommandPayload.AddBool(_command.ActivateMonitoring);
  // add command.UnitLimitAxis
  CreateCommandPayload.AddUsint(_command.UnitLimitAxis);
  // add command.ThresholdMode
  CreateCommandPayload.AddUsint(_command.ThresholdMode);
  // add command.ReactionMode
  CreateCommandPayload.AddUsint(_command.ReactionMode);
  // add command.Sensitivity
  CreateCommandPayload.AddInt(_command.Sensitivity);
  // add command.SensitivityAxis[0]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[0]);
  // add command.SensitivityAxis[1]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[1]);
  // add command.SensitivityAxis[2]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[2]);
  // add command.SensitivityAxis[3]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[3]);
  // add command.SensitivityAxis[4]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[4]);
  // add command.SensitivityAxis[5]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[5]);
  // add command.SensitivityAxis[6]
  CreateCommandPayload.AddInt(_command.SensitivityAxis[6]);
  // add command.LimitAxis[0]
  CreateCommandPayload.AddReal(_command.LimitAxis[0]);
  // add command.LimitAxis[1]
  CreateCommandPayload.AddReal(_command.LimitAxis[1]);
  // add command.LimitAxis[2]
  CreateCommandPayload.AddReal(_command.LimitAxis[2]);
  // add command.LimitAxis[3]
  CreateCommandPayload.AddReal(_command.LimitAxis[3]);
  // add command.LimitAxis[4]
  CreateCommandPayload.AddReal(_command.LimitAxis[4]);
  // add command.LimitAxis[5]
  CreateCommandPayload.AddReal(_command.LimitAxis[5]);
  // add command.LimitAxis[6]
  CreateCommandPayload.AddReal(_command.LimitAxis[6]);
  
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
    
  // Create log entry for ActivateMonitoring
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ActivateMonitoring = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.ActivateMonitoring));
  
  // Create log entry for UnitLimitAxis
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.UnitLimitAxis = {1}',
                          Para1       :=  USINT_TO_STRING(_command.UnitLimitAxis));
  
  // Create log entry for ThresholdMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ThresholdMode = {1}',
                          Para1       :=  THRESHOLD_MODE_TO_STRING(_command.ThresholdMode)); 
  
  // Create log entry for ReactionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReactionMode = {1}',
                          Para1       :=  COLLISION_REACTION_MODE_TO_STRING(_command.ReactionMode)); 
  
  // Create log entry for Sensitivity
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Sensitivity = {1}',
                          Para1       :=  INT_TO_STRING(_command.Sensitivity)); 
  
  // Create log entry for SensitivityAxis[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[1] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[1]));
   
  // Create log entry for SensitivityAxis[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[2] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[2]));
                          
  // Create log entry for SensitivityAxis[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[3] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[3]));
                          
  // Create log entry for SensitivityAxis[4]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[4] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[4])); 
   
  // Create log entry for SensitivityAxis[5]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[5] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[5]));
  
  // Create log entry for SensitivityAxis[6]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SensitivityAxis[6] = {1}',
                          Para1       :=  INT_TO_STRING(_command.SensitivityAxis[6]));
                          
  // Create log entry for LimitAxis[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[1] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[1]));
  
  // Create log entry for LimitAxis[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[2] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[2]));
                          
  // Create log entry for LimitAxis[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[3] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[3]));
                          
  // Create log entry for LimitAxis[4]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[4] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[4]));
  
  // Create log entry for LimitAxis[5]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[5] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[5]));
  
  // Create log entry for LimitAxis[6]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitAxis[6] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitAxis[6]));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CollisionDetectionFB';
  
  ExecMode := ExecutionMode.PARALLEL;

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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
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
// Table 6-791: Received CMD payload (RC to PLC) of "CollisionDetection"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
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
                          
  // Create log entry for no parameter 
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'This command has no parameter to parse...');

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

