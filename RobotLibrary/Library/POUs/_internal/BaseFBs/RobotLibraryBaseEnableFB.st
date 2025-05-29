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
//             Licensed under the LGPL-3.0 license.
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
  /// Command is transferred and confirmed by the RC
//CommandBuffered   : BOOL;
  /// TRUE while function is active
  Enabled           : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
//ParameterAccepted : BOOL;
END_VAR

VAR
  /// Rising edge for enable
 _enable_R          : R_TRIG;
  /// Falling edge for enable
 _enable_F          : F_TRIG;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup; 
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
    ErrorID := RobotLibraryErrorIdEnum.ERR_COMMANDS_NOT_ENABLED;
    Error   := TRUE;
    Busy    := FALSE;
  END_IF
  
  
  // On execution started
  IF ( _enable_R.Q )
  THEN
    OnExecStart(AxesGroup := AxesGroup);
  END_IF
  
  
  // On execution cancel  
  IF (Busy) AND ( _enable_F.Q) 
  THEN
    // call Cancel
    OnExecCancel(AxesGroup := AxesGroup);
  END_IF
  
  
  // On execution error clear
  IF ( Error ) AND ( _enable_F.Q )
  THEN
    OnExecErrorClear(AxesGroup := AxesGroup);
  END_IF

END_METHOD

METHOD Protected OnExecCancel : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  OnExecCancel := Reset();
  
  // try to remove cmd
  AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
  
  
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Execution of FB {1} cancled ',
                          Para1       := MyType);

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  Reset();

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
  
  Busy    := FALSE;
  Enabled := FALSE;

END_METHOD

