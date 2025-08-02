FUNCTION_BLOCK RobotLibraryBaseExecuteFB EXTENDS RobotLibraryBaseFB
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
  Execute         : BOOL;
END_VAR
VAR_OUTPUT
  /// The command has been completed successfully
  Done            : BOOL;
  /// FB is being processed
  Busy            : BOOL;
  /// Command is transferred and confirmed by the RC
//  CommandBuffered : BOOL;  
END_VAR


VAR
  /// Rising edge for execute
  {attribute 'hide'}
 _execute_R       : R_TRIG;
  /// Falling edge for execute
  {attribute 'hide'}
 _execute_F       : F_TRIG;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

// Base implementation must be called ! 
METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup; 
END_VAR

VAR
  /// internal return value
 _retVal : DINT;
END_VAR

  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _execute_R( CLK := Execute);
  _execute_F( CLK := Execute);
  
  
  // Check command execution is allowed ?
  IF ((     Execute                                ) AND
      ( NOT AxesGroup.State.CMDsEnabled            ) AND
      (     MyType <> 'MC_ExchangeConfigurationFB' ) AND // is part of init sequence
      (     MyType <> 'MC_ReadMessagesFB'          ) AND // is part of init sequence
      (     MyType <> 'MC_ReadRobotDataFB'         ))    // is part of init sequence
  THEN
    ErrorID := RobotLibraryErrorIdEnum.ERR_COMMANDS_NOT_ENABLED;
    Error   := TRUE;
    Busy    := FALSE;
  END_IF
  
  
  // On execution started
  IF ( _execute_R.Q )
  THEN
    OnExecStart(AxesGroup := AxesGroup);
  END_IF
  
  
  // On execution cancel  
  IF ( Busy ) AND ( _execute_F.Q ) 
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
  IF ( Error ) AND ( _execute_F.Q )
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

METHOD PROTECTED OnExecCancel : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal return value 
 _retVal    : DINT;
END_VAR

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
                            MessageText := '{1} successfully removed from ARC',
                            Para1       := MyType);                 
  ELSE
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := '{1} was not removed from ARC because execution was already in progress',
                            Para1       := MyType);                 
  END_IF
  
  
  OnExecCancel := Reset();

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  OnExecErrorClear := Reset();

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


END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done := FALSE;
  Busy := FALSE;

END_METHOD

