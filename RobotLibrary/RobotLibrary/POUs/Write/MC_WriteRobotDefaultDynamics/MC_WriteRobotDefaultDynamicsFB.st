/// Write default values of dynamic parameters used by move commands
FUNCTION_BLOCK MC_WriteRobotDefaultDynamicsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteRobotDefaultDynamicsFB                                       
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
  /// Processing Mode
  ProcessingMode     : ProcessingMode;
  /// command parameter 
  ParCmd             : WriteRobotDefaultDynamicsParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : WriteRobotDefaultDynamicsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteRobotDefaultDynamicsParCmd;
  /// command data to send
 _command            : WriteRobotDefaultDynamicsSendData;
  /// response data received
 _response           : WriteRobotDefaultDynamicsRecvData;      
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
// Table 6-146: Sent CMD payload (PLC to RC) of "WriteRobotDefaultDynamics"
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
// Byte 04 : DATE Date
// Byte 05 : 
// Byte 06 : TIME_OF_DAY Time
// Byte 07 : 
// Byte 08 : 
// Byte 09 : UINT VelocityRate
// Byte 10 : 
// Byte 11 : 
// Byte 12 : UINT AccelerationRate
// Byte 13 : 
// Byte 14 : 
// Byte 15 : UINT DecelerationRate
// Byte 16 : 
// Byte 17 : 
// Byte 18 : UINT JerkRate
// --------------------------

  // set command parameter 
  _command.CmdTyp           :=  CmdType.WriteRobotDefaultDynamics;
  _command.ExecMode         :=  ExecMode;
  _command.ParSeq           := _command.ParSeq;
  _command.Priority         :=  Priority;
  _command.Timestamp        := _parCmd.DynamicValues.Timestamp;
  _command.VelocityRate     := REAL_TO_UINT(_parCmd.DynamicValues.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate := REAL_TO_UINT(_parCmd.DynamicValues.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate := REAL_TO_UINT(_parCmd.DynamicValues.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate         := REAL_TO_UINT(_parCmd.DynamicValues.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.DynamicValues.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.Timestamp.IEC_DATE);
  // add command.DynamicValues.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.Timestamp.IEC_TIME);
  // add command.DynamicValues.VelocityRate
  CreateCommandPayload.AddUint(_command.VelocityRate);
  // add command.DynamicValues.AccelerationRate
  CreateCommandPayload.AddUint(_command.AccelerationRate);
  // add command.DynamicValues.DecelerationRate
  CreateCommandPayload.AddUint(_command.DecelerationRate);
  // add command.DynamicValues.JerkRate
  CreateCommandPayload.AddUint(_command.JerkRate);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteRobotDefaultDynamicsFB';
  
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
             // Update results
             OutCmd.DefaultDynamicValues.VelocityRate     := UINT_TO_REAL(_response.VelocityRate     ) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; 
             OutCmd.DefaultDynamicValues.AccelerationRate := UINT_TO_REAL(_response.AccelerationRate ) / RobotLibraryConstants.REAL_CONVERSION_FACTOR;
             OutCmd.DefaultDynamicValues.DecelerationRate := UINT_TO_REAL(_response.DecelerationRate ) / RobotLibraryConstants.REAL_CONVERSION_FACTOR;
             OutCmd.DefaultDynamicValues.JerkRate         := UINT_TO_REAL(_response.JerkRate         ) / RobotLibraryConstants.REAL_CONVERSION_FACTOR;
  
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
// Table 6-147: Received CMD payload (RC to PLC) of "WriteRobotDefaultDynamics"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT   - ParSeq | State     
// Byte 01 : SINT    - AlarmMessageSeverity    
// Byte 02 : UINT    - AlarmMessageCode HB
// Byte 03 :         - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : UINT VelocityRate
// Byte 05 : 
// Byte 06 : UINT AccelerationRate
// Byte 07 : 
// Byte 08 : UINT DecelerationRate
// Byte 09 : 
// Byte 10 : UINT JerkRate
// Byte 11 : 
// --------------------------
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
  
  // Get Response.VelocityRate
  _response.VelocityRate     := ResponseData.GetUint();
  // Get Response.AccelerationRate
  _response.AccelerationRate := ResponseData.GetUint();
  // Get Response.DecelerationRate
  _response.DecelerationRate := ResponseData.GetUint();
  // Get Response.JerkRate
  _response.JerkRate         := ResponseData.GetUint();

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

