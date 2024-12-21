/// Read integer values on RC
FUNCTION_BLOCK MC_ReadIntegersFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadIntegersFB                                       
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
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter
  ParCmd             : ReadIntegersParCmd;       
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • Values
  Valid              : BOOL; 
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command outputs
  OutCmd             : ReadIntegersOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadIntegersParCmd;
  /// command data to send
 _command            : ReadIntegersSendData;
  /// response data received
 _response           : ReadIntegersRecvData;      
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

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-496: Sent CMD payload (PLC to RC) of "ReadIntegers"
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
// Byte 04 : SINT   - EmitterID[0];
// Byte 05 : SINT   - EmitterID[1];
// Byte 06 : SINT   - EmitterID[2];
// Byte 07 : SINT   - EmitterID[3];
// Byte 08 : SINT   - ListenerID;
// Byte 09 : BYTE   - Reserved;
// Byte 10 : USINT  - Index[0];
// Byte 11 : USINT  - Index[1];
// Byte 12 : USINT  - Index[2];
// Byte 13 : USINT  - Index[3];
// Byte 14 : USINT  - Index[4];
// Byte 15 : USINT  - Index[5];
// Byte 16 : USINT  - Index[6];
// --------------------------

  // set command parameter 
  _command.CmdTyp       :=  CmdType.ReadIntegers;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.EmitterID[0] := 0;
  _command.EmitterID[1] := 0;
  _command.EmitterID[2] := 0;
  _command.EmitterID[3] := 0;
  _command.Reserve      := 0;
  _command.ListenerID   := _parCmd.ListenerID;
  _command.Index        := _parCmd.Index;
  
  
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
  // add command.Index[0]
  CreateCommandPayload.AddUsint(_command.Index[0]);
  // add command.Index[1]
  CreateCommandPayload.AddUsint(_command.Index[1]);
  // add command.Index[2]
  CreateCommandPayload.AddUsint(_command.Index[2]);
  // add command.Index[3]
  CreateCommandPayload.AddUsint(_command.Index[3]);
  // add command.Index[4]
  CreateCommandPayload.AddUsint(_command.Index[4]);
  // add command.Index[5]
  CreateCommandPayload.AddUsint(_command.Index[5]);
  // add command.Index[5]
  CreateCommandPayload.AddUsint(_command.Index[6]);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadIntegersFB';
  
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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
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
             OutCmd.Values            := _response.Values;
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
// Table 6-497: Received CMD payload (RC to PLC) of "ReadIntegers"
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
// Byte 04 : USINT  - InvocationCounter;
// Byte 05 : BYTE   - Reserved;
// Byte 06 : INT    - OriginID LW HB;
// Byte 07 :        - OriginID LW LB;
// Byte 08 : INT    - Values[0] LW HB;
// Byte 09 :        - Values[0] LW LB;
// Byte 10 : INT    - Values[1] LW HB;
// Byte 11 :        - Values[1] LW LB;
// Byte 12 : INT    - Values[2] LW HB;
// Byte 13 :        - Values[2] LW LB;
// Byte 14 : INT    - Values[3] LW HB;
// Byte 15 :        - Values[3] LW LB;
// Byte 16 : INT    - Values[4] LW HB;
// Byte 17 :        - Values[4] LW LB;
// Byte 18 : INT    - Values[5] LW HB;
// Byte 19 :        - Values[5] LW LB;
// Byte 20 : INT    - Values[6] LW HB;
// Byte 21 :        - Values[6] LW LB;
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetByte();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
  // Get Response.Values[0]
  _response.Values[0] := ResponseData.GetInt();
  // Get Response.Values[1]
  _response.Values[1] := ResponseData.GetInt();
  // Get Response.Values[2]
  _response.Values[2] := ResponseData.GetInt();
  // Get Response.Values[3]
  _response.Values[3] := ResponseData.GetInt();
  // Get Response.Values[4]
  _response.Values[4] := ResponseData.GetInt();
  // Get Response.Values[5]
  _response.Values[5] := ResponseData.GetInt();
  // Get Response.Values[6]
  _response.Values[6] := ResponseData.GetInt();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE; 
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

