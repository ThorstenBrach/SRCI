/// Wait to process next command in sequence until trigger signal is received
FUNCTION_BLOCK MC_WaitForTriggerFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WaitForTriggerFB                                       
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
  /// command parameter 
  ParCmd             : WaitForTriggerParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Command is currently processed by the active sequence, takes control of the motion of the according axis group and is waiting for Trigger.
  Active             : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// command results
  OutCmd             : WaitForTriggerOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WaitForTriggerParCmd;
  /// command data to send
 _command            : WaitForTriggerSendData;
  /// response data received
 _response           : WaitForTriggerRecvData;      
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
// Table 6-610: Sent CMD payload (PLC to RC) of "WaitForTrigger"
// --------------------------
// Header
// --------------------------
// --------------------------
// Datablock
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 04 : SINT       - EmitterID[0]
// Byte 05 : SINT       - EmitterID[1]
// Byte 06 : SINT       - EmitterID[2]
// Byte 07 : SINT       - EmitterID[3]
// Byte 08 : SINT       - ListenerID
// Byte 09 : BYTE       - Reserved
// Byte 10 : UINT       - VelocityRate HW HB
// Byte 11 :            - VelocityRate HW LB
// Byte 12 : UINT       - AccelerationRate HW HB
// Byte 13 :            - AccelerationRate HW LB
// Byte 14 : UINT       - DecelerationRate HW HB
// Byte 15 :            - DecelerationRate HW LB
// Byte 16 : UINT       - JerkRate HW HB
// Byte 17 :            - JerkRate HW LB
// Byte 18 : USINT      - ToolNo
// Byte 19 : USINT      - BlendingMode
// Byte 20 : REAL       - BlendingParameter[0] HW HB
// Byte 21 :            - BlendingParameter[0] HW LB
// Byte 22 :            - BlendingParameter[0] LW HB
// Byte 23 :            - BlendingParameter[0] LW LB
// Byte 24 : REAL       - BlendingParameter[1] HW HB
// Byte 25 :            - BlendingParameter[1] HW LB
// Byte 26 :            - BlendingParameter[1] LW HB
// Byte 27 :            - BlendingParameter[1] LW LB
// Byte 28 : REAL       - JointPosition.J1 HW HB
// Byte 29 :            - JointPosition.J1 HW LB
// Byte 30 :            - JointPosition.J1 LW HB
// Byte 31 :            - JointPosition.J1 LW LB
// Byte 32 : REAL       - JointPosition.J2 HW HB
// Byte 33 :            - JointPosition.J2 HW LB
// Byte 34 :            - JointPosition.J2 LW HB
// Byte 35 :            - JointPosition.J2 LW LB
// Byte 36 : REAL       - JointPosition.J3 HW HB
// Byte 37 :            - JointPosition.J3 HW LB
// Byte 38 :            - JointPosition.J3 LW HB
// Byte 39 :            - JointPosition.J3 LW LB
// Byte 40 : REAL       - JointPosition.J4 HW HB
// Byte 41 :            - JointPosition.J4 HW LB
// Byte 42 :            - JointPosition.J4 LW HB
// Byte 43 :            - JointPosition.J4 LW LB
// Byte 44 : REAL       - JointPosition.J5 HW HB
// Byte 45 :            - JointPosition.J5 HW LB
// Byte 46 :            - JointPosition.J5 LW HB
// Byte 47 :            - JointPosition.J5 LW LB
// Byte 48 : REAL       - JointPosition.J6 HW HB
// Byte 49 :            - JointPosition.J6 HW LB
// Byte 50 :            - JointPosition.J6 LW HB
// Byte 51 :            - JointPosition.J6 LW LB
// Byte 52 : REAL       - JointPosition.E1 HW HB
// Byte 53 :            - JointPosition.E1 HW LB
// Byte 54 :            - JointPosition.E1 LW HB
// Byte 55 :            - JointPosition.E1 LW LB
// Byte 56 : BOOL       - Manipulation
// Byte 57 : BYTE       - Reserve
// Byte 58 : UINT       - Time HW HB
// Byte 59 :            - Time HW LB
// Byte 60 : REAL       - JointPosition.E2 HW HB
// Byte 61 :            - JointPosition.E2 HW LB
// Byte 62 :            - JointPosition.E2 LW HB
// Byte 63 :            - JointPosition.E2 LW LB
// Byte 64 : REAL       - JointPosition.E3 HW HB
// Byte 65 :            - JointPosition.E3 HW LB
// Byte 66 :            - JointPosition.E3 LW HB
// Byte 67 :            - JointPosition.E3 LW LB
// Byte 68 : REAL       - JointPosition.E4 HW HB
// Byte 69 :            - JointPosition.E4 HW LB
// Byte 70 :            - JointPosition.E4 LW HB
// Byte 71 :            - JointPosition.E4 LW LB
// Byte 72 : REAL       - JointPosition.E5 HW HB
// Byte 73 :            - JointPosition.E5 HW LB
// Byte 74 :            - JointPosition.E5 LW HB
// Byte 75 :            - JointPosition.E5 LW LB
// Byte 76 : REAL       - JointPosition.E6 HW HB
// Byte 77 :            - JointPosition.E6 HW LB
// Byte 78 :            - JointPosition.E6 LW HB
// Byte 79 :            - JointPosition.E6 LW LB

  // set command parameter 
  _command.CmdTyp          :=  CmdType.WaitForTrigger;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;                         
  _command.EmitterID[0]    := _parCmd.EmitterID;
  _command.EmitterID[1]    := 0;
  _command.EmitterID[2]    := 0;
  _command.EmitterID[3]    := 0;
  _command.ListenerID      := _parCmd.ListenerID;
  _command.Reserve         := 0;
  _command.ConditionalWait := _parCmd.ConditionalWait;
  
  
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
  // add command.ConditionalWait
  CreateCommandPayload.AddBool(_command.ConditionalWait);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WaitForTriggerFB';

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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : Active             := TRUE;
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
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.InvocationCounter := _response.InvocationCounter;
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
// Table 6-611: Received CMD payload (RC to PLC) of "WaitForTrigger"
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
// Byte 04 : USINT   - InvocationCounter
// Byte 05 : SINT    - Reserve
// Byte 06 : INT     - OriginID LW HB
// Byte 07 :         - OriginID LW LB
// Byte 08 : UINT    - Progress LW HB
// Byte 09 :         - Progress LW LB
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Active             := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD
