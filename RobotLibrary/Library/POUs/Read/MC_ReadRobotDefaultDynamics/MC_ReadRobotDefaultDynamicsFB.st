/// Read default values of dynamic parameters used by move commands
FUNCTION_BLOCK MC_ReadRobotDefaultDynamicsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRobotDefaultDynamicsFB                                       
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
  ParCmd          : ReadRobotDefaultDynamicsParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadRobotDefaultDynamicsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadRobotDefaultDynamicsParCmd;
  /// command data to send
 _command         : ReadRobotDefaultDynamicsSendData;
  /// response data received
 _response        : ReadRobotDefaultDynamicsRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.ReadRobotDefaultDynamics;
  
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
  IF (SIZEOF(ParCmd) = 0) 
  THEN 
    RETURN;
  END_IF
  
  // compare memory 
  CheckParameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCmd), pData2 := ADR(_parCmd), DataLen := SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-153: Sent CMD payload (PLC to RC) of "ReadRobotDefaultDynamics"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadRobotDefaultDynamics;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadRobotDefaultDynamicsFB';
  
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
             CommandData := CreateCommandPayload();
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
             OutCmd.DynamicValues.Timestamp        := _response.Timestamp;
  
             OutCmd.DynamicValues.VelocityRate     := INT_TO_REAL(UINT_TO_INT(_response.VelocityRate )) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; {warning 'ToDo: check conversation is correct ?'}
             OutCmd.DynamicValues.AccelerationRate := INT_TO_REAL(UINT_TO_INT(_response.AccelerationRate )) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; {warning 'ToDo: check conversation is correct ?'}
  
             IF ( _response.DecelerationRate <> 16#FFFF ) // Robot returns 16#FFFF ( -1 ) for not supported values
             THEN
               OutCmd.DynamicValues.DecelerationRate := INT_TO_REAL(UINT_TO_INT(_response.DecelerationRate )) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; {warning 'ToDo: check conversation is correct ?'}
             ELSE
               OutCmd.DynamicValues.DecelerationRate := INT_TO_REAL(UINT_TO_INT(_response.DecelerationRate ));
  					 END_IF
  
             IF ( _response.JerkRate <> 16#FFFF ) // Robot returns 16#FFFF ( -1 ) for not supported values
             THEN
               OutCmd.DynamicValues.JerkRate := INT_TO_REAL(UINT_TO_INT(_response.JerkRate )) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; {warning 'ToDo: check conversation is correct ?'}
             ELSE
               OutCmd.DynamicValues.JerkRate := INT_TO_REAL(UINT_TO_INT(_response.JerkRate ));
  					 END_IF
  
             
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
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-154: Received CMD payload (RC to PLC) of "ReadRobotDefaultDynamics"
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
// Byte 04 : DATE        Date HW HB;
// Byte 05 :             Date HW LB;
// Byte 06 : TIME_OF_DAY Time HW HB;
// Byte 07 :             Time HW LB;
// Byte 08 :             Time LW HB;
// Byte 09 :             Time LW LB;
// Byte 10 : UINT        VelocityRate HW HB;
// Byte 11 :             VelocityRate HW LB;
// Byte 12 : UINT        AccelerationRate HW HB;
// Byte 13 :             AccelerationRate HW LB;
// Byte 14 : UINT        DecelerationRate HW HB;
// Byte 15 :             DecelerationRate HW LB;
// Byte 16 : UINT        JerkRate HW HB;
// Byte 17 :             JerkRate HW LB;
// Byte 18 : USINT       DataChanged;
// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.DynamicValues.Timestamp.IEC_DATE
  _response.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.DynamicValues.Timestamp.IEC_TIME
  _response.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.DynamicValues.VelocityRate
  _response.VelocityRate := ResponseData.GetUint();
  // Get Response.DynamicValues.AccelerationRate
  _response.AccelerationRate := ResponseData.GetUint();
  // Get Response.DynamicValues.DecelerationRate
  _response.DecelerationRate := ResponseData.GetUint();
  // Get Response.DynamicValues.JerkRate
  _response.JerkRate := ResponseData.GetUint();
  // Get Response.DataChanged
  _response.DataChanged := ResponseData.GetBool();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

