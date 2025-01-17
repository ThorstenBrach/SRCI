/// Synchronize robot with conveyor
FUNCTION_BLOCK MC_SyncToConveyorFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncToConveyorFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
  ParCmd            : SyncToConveyorParCmd;      
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// The command takes control of the motion of the according axis group
  Active            : BOOL;
  /// The command was aborted by another command.
  CommandAborted    : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// Command output 
  OutCmd            : SyncToConveyorOutCmd;      
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : SyncToConveyorParCmd;
  /// command data to send
 _command           : SyncToConveyorSendData;
  /// response data received
 _response          : SyncToConveyorRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.SyncToConveyor;
  
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-452: Sent CMD payload (PLC to RC) of "SyncToConveyor"
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
// Byte 10 : USINT      - ConveyorNo
// Byte 11 : USINT      - FrameNo
// Byte 12 : USINT      - SyncInMode
// Byte 13 : REAL       - SyncInParameter HW HB
// Byte 14 :            - SyncInParameter HW LB
// Byte 15 :            - SyncInParameter LW HB
// Byte 16 :            - SyncInParameter LW LB
// Byte 17 : REAL       - MaxVelocity     HW HB
// Byte 18 :            - MaxVelocity     HW LB
// Byte 19 :            - MaxVelocity     LW HB
// Byte 20 :            - MaxVelocity     LW LB
// Byte 21 : REAL       - MaxAcceleration HW HB
// Byte 22 :            - MaxAcceleration HW LB
// Byte 23 :            - MaxAcceleration LW HB
// Byte 24 :            - MaxAcceleration LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp          :=  CmdType.SyncToConveyor;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.EmitterID[0]    := 0; {warning 'ToDo'}
  _command.EmitterID[1]    := 0; {warning 'ToDo'}
  _command.EmitterID[2]    := 0; {warning 'ToDo'}
  _command.EmitterID[3]    := 0; {warning 'ToDo'}
  _command.ListenerID      := _parCmd.ListenerID;
  _command.Reserve         := 0;
  _command.ConveyorNo      := _parCmd.ConveyorNo;
  _command.FrameNo         := _parCmd.FrameNo;
  _command.SyncInMode      := _parCmd.SyncInMode;
  _command.SyncInParameter := _parCmd.SyncInParameter;
  _command.MaxVelocity     := _parCmd.MaxVelocity;
  _command.MaxAcceleration := _parCmd.MaxAcceleration;
  
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
  // add command.ConveyorNo
  CreateCommandPayload.AddUsint(_command.ConveyorNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.SyncInMode
  CreateCommandPayload.AddUsint(_command.SyncInMode);
  // add command.SyncInParameter
  CreateCommandPayload.AddReal(_command.SyncInParameter);
  // add command.MaxVelocity
  CreateCommandPayload.AddReal(_command.MaxVelocity);
  // add command.MaxAcceleration
  CreateCommandPayload.AddReal(_command.MaxAcceleration);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SyncToConveyorFB';

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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
                                           Active             := TRUE; {warning 'ToDo'}           
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Update results
           OutCmd.InvocationCounter := _response.InvocationCounter;
           OutCmd.OriginID          := _response.OriginID;
           OutCmd.InSync            := _response.InSync;           
           Enabled                  := TRUE; {warning 'ToDo'}
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // reset busy flag
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
  
  
    02:  IF (NOT Enable)
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
// Table 6-453: Received CMD payload (RC to PLC) of "SyncToConveyor"
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
// Byte 04 : USINT       - InvocationCounter
// Byte 05 : SINT        - Reserved
// Byte 06 : INT         - OriginID
// Byte 07 : BOOL        - InSync
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
  // Get Response.InSync
  _response.InSync   := ResponseData.GetBool();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  Busy               := FALSE;
  Active             := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

