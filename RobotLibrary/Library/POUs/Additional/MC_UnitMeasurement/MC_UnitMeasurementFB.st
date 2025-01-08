/// Measure the length of objects in the cartesian space, execution time for specified section of a job or signal output time of a specified signal
FUNCTION_BLOCK MC_UnitMeasurementFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UnitMeasurementFB                                       
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
  /// command results
  ParCmd            : UnitMeasurementParCmd;
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command results
  OutCmd            : UnitMeasurementOutCmd;
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : UnitMeasurementParCmd;
  /// command data to send
 _command           : UnitMeasurementSendData;
  /// response data received
 _response          : UnitMeasurementRecvData;
  /// measurement number
 _measurementNo     : USINT; 
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-803: Sent CMD payload (PLC to RC) of "UnitMeasurement"
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
// Byte 04 : SINT   - EmitterID[0]
// Byte 05 : SINT   - EmitterID[1]
// Byte 06 : SINT   - EmitterID[2]
// Byte 07 : SINT   - EmitterID[3]
// Byte 08 : SINT   - ListenerID
// Byte 09 : BYTE   - Reserved
// Byte 10 : USINT  - TriggerMode
// Byte 11 : USINT  - MeasurementNo
// Byte 12 : USINT  - MeasuringMode

  // set command parameter 
  _command.CmdTyp          :=  CmdType.UnitMeasurement;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.EmitterID[0]    :=  0; {warning 'ToDo'}
  _command.EmitterID[1]    :=  0; {warning 'ToDo'}
  _command.EmitterID[2]    :=  0; {warning 'ToDo'}
  _command.EmitterID[3]    :=  0; {warning 'ToDo'}
  _command.ListenerID      :=  _parCmd.ListenerID;
  _command.Reserve         :=  0;
  _command.TriggerMode     :=  _parCmd.TriggerMode;
  _command.MeasurementNo   :=  _measurementNo;
  _command.MeasuringMode   :=  _parCmd.MeasuringMode;
  
  
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.EmitterID[0]
  CreateCommandPayload.AddSint(_command.EmitterID[0]);
  // add command.EmitterID[1]
  CreateCommandPayload.AddSint(_command.EmitterID[1]);
  // add command.EmitterID[2]
  CreateCommandPayload.AddSint(_command.EmitterID[2]);
  // add command.EmitterID[3]
  CreateCommandPayload.AddSint(_command.EmitterID[3]);
  // add command.ListenerID
  CreateCommandPayload.AddSint(_command.ListenerID);
  // add command.Reserved
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.TriggerMode
  CreateCommandPayload.AddUsint(_command.TriggerMode);
  // add command.MeasurementNo
  CreateCommandPayload.AddUsint(_command.MeasurementNo);
  // add command.MeasuringMode
  CreateCommandPayload.AddUsint(_command.MeasuringMode);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_UnitMeasurementFB';
  
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
    
    00:  IF ( _enable_R.Q )  
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
           // set busy flag
           Busy := TRUE;
           // Reset command outputs
           SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
           // inc measurement number
          _measurementNo := _measurementNo + 1;
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
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE; 
                                           Enabled            := TRUE;          
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
  
           // Update results
           OutCmd.MeasurementActive := _response.MeasurementActive;
           OutCmd.Result            := _response.Result;
           OutCmd.OriginID          := _response.OriginID;
           OutCmd.InvocationCounter := _response.InvocationCounter;
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Enabled flag
             Enabled := FALSE;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
         // Check enable flag 
         IF (_enable_F.Q)
         THEN
           // trigger parameter update to disable GroupJog
           SysDepMemSet( pDest := ADR(_parCmd), Value := 0, DataLen := SIZEOF(_parCmd));
           // reset the falling edge
          _enable_F();       
        END_IF
  
    03: IF (NOT Enable)
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

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-804: Received CMD payload (RC to PLC) of "UnitMeasurement"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : USINT  - InvocationCounter
// Byte 05 : SINT   - Reserved
// Byte 06 : INT    - OriginID HW HB
// Byte 07 :        - OriginID HW LB
// Byte 08 : REAL   - Result HW HB
// Byte 09 :        - Result HW LB
// Byte 10 :        - Result LW HB
// Byte 11 :        - Result LW LB
// Byte 12 : BOOL   - MeasurementActive
// Byte 13 : USINT  - ResultNo
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
  // Get Response.Result
  _response.Result := ResponseData.GetReal();
  // Get Response.MeasurementActive
  _response.MeasurementActive := ResponseData.GetBool();
  // Get Response.ResultNo
  _response.ResultNo := ResponseData.GetUsint();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

