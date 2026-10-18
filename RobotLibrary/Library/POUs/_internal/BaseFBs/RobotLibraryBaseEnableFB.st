FUNCTION_BLOCK RobotLibraryBaseEnableFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryBaseFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-11
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Set TRUE to activate / Set False to deactivate
  Enable            : BOOL;
END_VAR

VAR_OUTPUT
  /// FB is being processed
  Busy              : BOOL;
  /// TRUE while function is active
  Enabled           : BOOL;
END_VAR

VAR
  /// Rising edge for enable
  {attribute 'hide'}
 _enable_R          : R_TRIG;
  /// Falling edge for enable
  {attribute 'hide'}
 _enable_F          : F_TRIG;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

VAR
  /// internal return value
 _retVal : DINT;
END_VAR

  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  
  // Check command execution is allowed ?
  IF ((     Enable                                 ) AND
      ( NOT AxesGroup.State.Initialized            ) AND
      ( NOT AxesGroup.State.Synchronized           ) AND
      (     MyType <> 'MC_ExchangeConfigurationFB' ) AND // is part of init sequence
      (     MyType <> 'MC_ReadMessagesFB'          ) AND // is part of init sequence
      (     MyType <> 'MC_ReadRobotDataFB'         ))    // is part of init sequence
  THEN
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_COMMANDS_NOT_ENABLED, Overwrite := TRUE );
    Error   := TRUE;
    Busy    := FALSE; 
  END_IF
  
  
  // On execution started
  IF ( _enable_R.Q )
  THEN
    // ST-FIX F23: a new enable ends a pending cancel / error clear of the previous enable
    _cancel := FALSE;
    _stepCancel := 0;
    _clearError := FALSE;
    _stepClearError := 0;
    // ST-FIX F78: an error of the previous enable that is still being cleared (falling edge, up
    // to 5 s) is cleared now - otherwise the block (start only without Error) consumes the
    // rising edge and the new enable is ignored (not sent, no Busy, no Error)
    IF ( Error ) AND ( ErrorID <> RobotLibraryErrorIdEnum.ERR_COMMANDS_NOT_ENABLED )
    THEN
      Reset();
    END_IF
    OnExecStart(AxesGroup := AxesGroup);
  END_IF
  
  
  // On execution cancel  
  IF ( Busy ) AND ( _enable_F.Q ) 
  THEN
    // set cancel flag
   _cancel := TRUE;
  END_IF
  
  IF ( _cancel )
  THEN
    // call Cancel
   _retVal := OnExecCancel(AxesGroup := AxesGroup);
    
    // done or error ?
    IF ( _retVal <> RobotLibraryConstants.RUNNING )
    THEN
      // reset cancel flag
     _cancel := FALSE;
  	END_IF
  END_IF
  
  
  // On execution error clear
  IF ( Error ) AND ( _enable_F.Q )
  THEN
    // set ClearError flag
   _clearError := TRUE;
  END_IF
  
  IF ( _clearError )
  THEN
   _retVal := OnExecErrorClear(AxesGroup := AxesGroup); 
  
    // done or error ?
    IF ( _retVal <> RobotLibraryConstants.RUNNING )
    THEN
      // reset ClearError flag
     _clearError := FALSE;
  	END_IF
  END_IF

END_METHOD

METHOD Protected OnExecCancel : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal return value 
 _retVal    : DINT;
END_VAR

  OnExecCancel := Reset();
  
  // Create log entry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Execution of {1} cancled ',
                          Para1       := MyType);                 
  
  // try to remove cmd
  _retVal := AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
  
  IF (_retVal = RobotLibraryConstants.OK)
  THEN
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := '{1} successfully removed from ACR',
                            Para1       := MyType);                 
  ELSE
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := '{1} was not removed from ACR because execution was already in progress',
                            Para1       := MyType);                 
  END_IF

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  OnExecErrorClear := RobotLibraryConstants.RUNNING;
  
  CASE _stepClearError OF
    
    0:  // Reset 
        Reset();
        // trigger parameter update to disable FB
       _parameterUpdateInternal := TRUE;
        // call Check Parameter changed method to trigger the parameter update to deactivate jogging mode
        CheckParameterChanged(AxesGroup := AxesGroup);
        // set timeout
        SetTimeout(PT := _timeoutClearError, rTimer := _timerClearError);
        // inc step counter
       _stepClearError := _stepClearError + 1; 
        
    1: IF ( _responseReceived )
       THEN     
         // reset response received flag
        _responseReceived := FALSE;
         // reset step counter
        _stepClearError := 0;
         // finished
         OnExecErrorClear := RobotLibraryConstants.OK;
       ELSE
         // timeout exceeded ? 
         IF (CheckTimeout(_timerClearError) = RobotLibraryConstants.OK)
         THEN
           OnExecErrorClear := RobotLibraryConstants.HAS_ERROR;
         END_IF
  	   END_IF
  ELSE
    // invalid step
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP, Overwrite := TRUE );
  END_CASE
  
  
  // reset step counter
  IF (OnExecErrorClear <> RobotLibraryConstants.RUNNING)
  THEN
   _stepClearError := 0;
  END_IF

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR


END_METHOD

METHOD PROTECTED OnExecStart : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // ST-FIX F71: Priority (1 = very high ... 4 = low, table 7-1)
  IF ( Priority < PriorityLevel.VERY_HIGH )
  THEN
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_PRIORITY_TOO_HIGH, Overwrite := TRUE );
    // Create log entry
    CreateLogMessage ( Timestamp   := AxesGroup.State.SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.ERROR,
                       MessageCode := ErrorID,
                       MessageText := 'Invalid input Priority: higher than VERY_HIGH');
    Error := TRUE;
  ELSIF ( Priority > PriorityLevel.LOW )
  THEN
    SetError( ErrorID := RobotLibraryErrorIdEnum.ERR_PRIORITY_TOO_LOW, Overwrite := TRUE );
    // Create log entry
    CreateLogMessage ( Timestamp   := AxesGroup.State.SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.ERROR,
                       MessageCode := ErrorID,
                       MessageText := 'Invalid input Priority: lower than LOW');
    Error := TRUE;
  END_IF

END_METHOD

METHOD PROTECTED OnUpdateStateFlags
VAR_INPUT
  /// Command message state
  State : CmdMessageState;
END_VAR

  CASE State OF
  
    // No operation or process is active
    CmdMessageState.EMPTY               :;
    // Created but not yet started
    CmdMessageState.CREATED             :;
    // Buffered and awaiting execution
    CmdMessageState.BUFFERED            :;
    // Buffered in planner for future execution
    CmdMessageState.BUFFERED_IN_PLANNER :;
    // Currently active and in progress
    CmdMessageState.ACTIVE              :;
    // Interrupted and awaiting continuation
    CmdMessageState.INTERRUPTED         :;
    // Requested for abort
    CmdMessageState.ABORT_REQUEST       :;
    // Successfully completed
    CmdMessageState.DONE                : Busy := FALSE;
    // Aborted before completion
    CmdMessageState.ABORTED             : Busy := FALSE;
    // Encountered an error during execution
    CmdMessageState.ERROR               : Busy := FALSE;
  END_CASE

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy    := FALSE;
  Enabled := FALSE;

END_METHOD

