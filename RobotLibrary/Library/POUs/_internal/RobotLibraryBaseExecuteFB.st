FUNCTION_BLOCK RobotLibraryBaseExecuteFB extends RobotLibraryBaseFB
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
  /// step counter for finite state machine
 _fsmState        : FsmState;
  /// Rising edge for execute
 _execute_R       : R_TRIG;
  /// Falling edge for execute
 _execute_F       : F_TRIG;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD INTERNAL ApplyOutCmd
VAR_INPUT
END_VAR


END_METHOD

METHOD INTERNAL ApplyParCmd
VAR_INPUT
END_VAR


END_METHOD

METHOD internal FSM : DINT
VAR
  /// internal return value
 _retVal : DINT;
END_VAR

  CASE _fsmState 
  OF
  
    FsmState.READY :
    
      // Await start
      IF (( NOT Busy        ) AND 
          ( NOT Error       ) AND 
          (    _execute_R.Q ))
      THEN
        // inc fsm step
       _fsmState := FsmState.START;
      END_IF
        
    FsmState.START :
     
     _retVal := OnExecStart();
      
      IF ( _retVal = RobotLibraryConstants.OK )
      THEN
       _fsmState := FsmState.RUNNING;
      ELSE
        // Cancel
        IF ((      Busy        ) AND
            (  NOT Error       ) AND
            (     _execute_F.Q ))
        THEN
         _fsmState := FsmState.CANCEL;
          RETURN;
        END_IF
      
        // check error 
        IF (_retVal < RobotLibraryConstants.OK)
        THEN
         _fsmState := FsmState.ERROR;
          RETURN;
        END_IF
      END_IF
  
     FsmState.RUNNING :
  
        _retVal := OnExecRun();
      
         IF (_retVal = RobotLibraryConstants.OK )
         THEN
          _fsmState := FsmState.DONE;
         ELSE
           // Cancel
           IF ((      Busy        ) AND
               (  NOT Error       ) AND
               (     _execute_F.Q ))
           THEN
            _fsmState := FsmState.CANCEL;
             RETURN;
           END_IF
           
           // error 
           IF (_retVal < RobotLibraryConstants.OK)
           THEN
            _fsmState := 99;
             RETURN;
           END_IF         
         END_IF
  
    FsmState.DONE :
    
     _fsmState := FsmState.READY;
  
    FsmState.CANCEL :
  
     _retVal := OnExecCancel();
      
      IF (_retVal = RobotLibraryConstants.OK )
      THEN
        _fsmState := FsmState.READY;
      END_IF
      
    FsmState.ERROR :
    
      IF (NOT Execute)
      THEN
       _fsmState := FsmState.ERROR_CLEAR;
      END_IF
  
    FsmState.ERROR_CLEAR :
  
     _retVal := OnExecErrorClear();
      
      IF (_retVal = RobotLibraryConstants.OK )
      THEN
        _fsmState := FsmState.READY;
      END_IF
         
  ELSE
    ;
  END_CASE

END_METHOD

// Base implementation must be called ! 
METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup; 
END_VAR

  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _execute_R( CLK := Execute);
  _execute_F( CLK := EXecute);
  
  // call state machine
  FSM();
  
  // Abort execution 
  IF (Busy) AND (_execute_F.Q) 
  THEN
    // try to remove cmd
    AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
  END_IF

END_METHOD

METHOD PROTECTED OnExecCancel : DINT
VAR_INPUT
END_VAR

  OnExecCancel := Reset();
  
  
  // Create log entry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Execution of FB {1} cancled ',
                          Para1       := MyType);

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_INPUT
END_VAR

  Reset();

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_INPUT
END_VAR


END_METHOD

METHOD PROTECTED OnExecStart : DINT
VAR_INPUT
END_VAR


END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done := FALSE;
  Busy := FALSE;

END_METHOD

