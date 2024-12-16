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

METHOD CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  // Check ParCmd Size is > 0, becaue MemCmp does not work correctly with size = 0
  IF (SIZEOF(ParCmd) = 0) 
  THEN 
    RETURN;
  END_IF
  
  // compare memory 
  CheckParameterChanged := ( MemCmp(ADR(ParCmd), ADR(_parCmd), SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
  IF ( CheckParameterChanged )
  THEN  
    // update internal copy of parameters 
   _parCmd := ParCmd;
    // inc parameter sequence
   _command.ParSeq := _command.ParSeq + 1;
    // update command data  
    CommandData := CreateCommandPayload(); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
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
  _command.Sensitivity          :=  REAL_TO_INT(_parCmd.Sensitivity        * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[0]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[0] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[1]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[1] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[2]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[2] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[3]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[3] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[4]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[4] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[5]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[5] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.SensitivityAxis[6]   :=  REAL_TO_INT(_parCmd.SensitivityAxis[6] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.LimitAxis[0]         :=  _parCmd.LimitAxis[0];
  _command.LimitAxis[1]         :=  _parCmd.LimitAxis[1];
  _command.LimitAxis[2]         :=  _parCmd.LimitAxis[2];
  _command.LimitAxis[3]         :=  _parCmd.LimitAxis[3];
  _command.LimitAxis[4]         :=  _parCmd.LimitAxis[4];
  _command.LimitAxis[5]         :=  _parCmd.LimitAxis[5];
  _command.LimitAxis[6]         :=  _parCmd.LimitAxis[6];
  
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
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

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _execute_R.Q ) 
         THEN
           // set busy flag
           Busy := TRUE;
           // Reset command outputs
           MemSet(ADR(OutCmd),0,SIZEOF(OutCmd));         
           // apply command parameter
          _parCmd := ParCmd;
           // init parameter sequence
          _command.ParSeq := 1;
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
  	     END_IF
       
    01:  // create command data
         CommandData := CreateCommandPayload();
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
  
    03: IF ( NOT Execute)
        THEN
          Reset();
  			END_IF     
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  // Cancel 
  IF (Busy) AND (NOT Execute) 
  THEN
    // try to remove cmd
    AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
  END_IF
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-791: Received CMD payload (RC to PLC) of "CollisionDetection"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
VAR_INPUT
  /// Response data
  ResponseData : RecvData;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;

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

