/// Read actual force/torque at TCP
FUNCTION_BLOCK MC_ReadActualForceFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualForceFB                                       
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
  /// Command parameter 
  ParCmd            : ReadActualForceParCmd;   
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// - ActualForce
  Valid             : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// Command output 
  OutCmd            : ReadActualForceOutCmd;        
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : ReadActualForceParCmd;
  /// command data to send
 _command           : ReadActualForceSendData;
  /// response data received
 _response          : ReadActualForceRecvData;      
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
// Table 6-733: Sent CMD payload (PLC to RC) of "ReadActualForce"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT       - Type HB     
// Byte 01 :            - Type LB    
// Byte 02 : USINT      - Reserve | ExecutionMode
// Byte 03 : USINT      - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 04 : SINT       - EmitterID[0]
// Byte 05 : SINT       - EmitterID[1]
// Byte 06 : SINT       - EmitterID[2]
// Byte 07 : SINT       - EmitterID[3]
// Byte 08 : SINT       - ListenerID
// Byte 09 : BYTE       - Reserved
// Byte 10 : USINT      - ToolNo
// Byte 11 : USINT      - FrameNo
// Byte 12 : USINT      - CalibrationData
// Byte 13 : USINT      - ReferenceType
// --------------------------

  // set command parameter 
  _command.CmdTyp          :=  CmdType.ReadActualForce;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.EmitterID[0]    := 0; {warning 'ToDo'}
  _command.EmitterID[1]    := 0; {warning 'ToDo'}
  _command.EmitterID[2]    := 0; {warning 'ToDo'}
  _command.EmitterID[3]    := 0; {warning 'ToDo'}
  _command.ListenerID      := _parCmd.ListenerID;
  _command.Reserve         := 0;
  _command.ToolNo          := _parCmd.ToolNo;
  _command.FrameNo         := _parCmd.FrameNo;
  _command.CalibrationData := _parCmd.CalibrationData;
  _command.FrameNo         := _parCmd.FrameNo;
  _command.ReferenceType   := _parCmd.ReferenceType;
  
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
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.CalibrationData
  CreateCommandPayload.AddUsint(_command.CalibrationData);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadActualForceFB';
  
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
           SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
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
             CmdMessageState.BUFFERED : CommandBuffered   := TRUE;
             CmdMessageState.ACTIVE   : ParameterAccepted := TRUE;
             CmdMessageState.Done     : Done              := TRUE;
             CmdMessageState.ERROR    : Error             := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.ActualForce       := _response.ActualForce;
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
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-734: Received CMD payload (RC to PLC) of "ReadActualForce"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT      - ParSeq | State     
// Byte 01 : SINT       - AlarmMessageSeverity    
// Byte 02 : UINT       - AlarmMessageCode HB
// Byte 03 :            - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : USINT      - InvocationCounter
// Byte 05 : SINT       - Reserved
// Byte 06 : INT        - OriginID LW HB
// Byte 07 :            - OriginID LW LB
// Byte 08 : REAL       - ActualForce[0] HW HB
// Byte 09 :            - ActualForce[0] HW LB
// Byte 10 :            - ActualForce[0] LW HB
// Byte 11 :            - ActualForce[0] LW LB
// Byte 12 : REAL       - ActualForce[1] HW HB
// Byte 13 :            - ActualForce[1] HW LB
// Byte 24 :            - ActualForce[1] LW HB
// Byte 15 :            - ActualForce[1] LW LB
// Byte 16 : REAL       - ActualForce[2] HW HB
// Byte 17 :            - ActualForce[2] HW LB
// Byte 18 :            - ActualForce[2] LW HB
// Byte 19 :            - ActualForce[2] LW LB
// Byte 20 : REAL       - ActualForce[3] HW HB
// Byte 21 :            - ActualForce[3] HW LB
// Byte 22 :            - ActualForce[3] LW HB
// Byte 23 :            - ActualForce[3] LW LB
// Byte 24 : REAL       - ActualForce[4] HW HB
// Byte 25 :            - ActualForce[4] HW LB
// Byte 26 :            - ActualForce[4] LW HB
// Byte 27 :            - ActualForce[4] LW LB
// Byte 28 : REAL       - ActualForce[5] HW HB
// Byte 29 :            - ActualForce[5] HW LB
// Byte 30 :            - ActualForce[5] LW HB
// Byte 31 :            - ActualForce[5] LW LB


// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserved
  _response.Reserved := ResponseData.GetSint();
  // Get Response.InvocationCounter
  _response.OriginID := ResponseData.GetInt();
  // Get Response.ActualForce[0]
  _response.ActualForce[0] := ResponseData.GetReal();
  // Get Response.ActualForce[1]
  _response.ActualForce[1] := ResponseData.GetReal();
  // Get Response.ActualForce[2]
  _response.ActualForce[2] := ResponseData.GetReal();
  // Get Response.ActualForce[3]
  _response.ActualForce[3] := ResponseData.GetReal();
  // Get Response.ActualForce[4]
  _response.ActualForce[4] := ResponseData.GetReal();
  // Get Response.ActualForce[5]
  _response.ActualForce[5] := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE;
  ParameterAccepted  := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

