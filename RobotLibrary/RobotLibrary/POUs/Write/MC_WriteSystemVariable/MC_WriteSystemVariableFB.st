/// Write specific parameter of the robot
FUNCTION_BLOCK MC_WriteSystemVariableFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteSystemVariableFB                                       
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
  ParCmd             : WriteSystemVariableParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// TRUE, when parameters were overwritten but not activated on RC until a restart of the RC
  RestartRequested   : BOOL;
  /// command outputs
  OutCmd             : WriteSystemVariableOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteSystemVariableParCmd;
  /// command data to send
 _command            : WriteSystemVariableSendData;
  /// response data received
 _response           : WriteSystemVariableRecvData;      
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
// Table 6-626: Sent CMD payload (PLC to RC) of "WriteSystemVariable"
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
// Byte 04 : SINT EmitterID[0]
// Byte 05 : SINT EmitterID[1]
// Byte 06 : SINT EmitterID[2]
// Byte 07 : SINT EmitterID[3]
// Byte 08 : SINT ListenerID
// Byte 09 : BYTE Reserved
// Byte 10 : UINT ParameterID[0]
// Byte 11 : 
// Byte 12 : UINT ParameterID[1]
// Byte 13 : 
// Byte 14 : UINT ParameterID[2]
// Byte 15 : 
// Byte 16 : UINT ParameterID[3]
// Byte 17 : 
// Byte 18 : UINT ParameterID[4]
// Byte 19 : 
// Byte 20 : UINT ParameterID[5]
// Byte 21 : 
// Byte 22 : UINT ParameterID[6]
// Byte 23 : 
// Byte 24 : UINT ParameterID[7]
// Byte 25 : 
// Byte 26 : USINT SubParameterID[0]
// Byte 27 : USINT SubParameterID[1]
// Byte 28 : USINT SubParameterID[2]
// Byte 29 : USINT SubParameterID[3]
// Byte 30 : USINT SubParameterID[4]
// Byte 31 : USINT SubParameterID[5]
// Byte 32 : USINT SubParameterID[6]
// Byte 33 : USINT SubParameterID[7]
// Byte 34 : USINT DataType[0]
// Byte 35 : USINT DataType[1]
// Byte 36 : USINT DataType[2]
// Byte 37 : USINT DataType[3]
// Byte 38 : USINT DataType[4]
// Byte 39 : USINT DataType[5]
// Byte 40 : USINT DataType[6]
// Byte 41 : USINT DataType[7]
// Byte 42 : BYTE Data_0[0]
// Byte 43 : BYTE Data_0[1]
// Byte 44 : BYTE Data_0[2]
// Byte 45 : BYTE Data_0[3]
// Byte 46 : BYTE Data_1[0]
// Byte 47 : BYTE Data_1[1]
// Byte 48 : BYTE Data_1[2]
// Byte 49 : BYTE Data_1[3]
// Byte 50 : BYTE Data_2[0]
// Byte 51 : BYTE Data_2[1]
// Byte 52 : BYTE Data_2[2]
// Byte 53 : BYTE Data_2[3]
// Byte 54 : BYTE Data_3[0]
// Byte 55 : BYTE Data_3[1]
// Byte 56 : BYTE Data_3[2]
// Byte 57 : BYTE Data_3[3]
// Byte 58 : BYTE Data_4[0]
// Byte 59 : BYTE Data_4[1]
// Byte 60 : BYTE Data_4[2]
// Byte 61 : BYTE Data_4[3]
// Byte 62 : BYTE Data_5[0]
// Byte 63 : BYTE Data_5[1]
// Byte 64 : BYTE Data_5[2]
// Byte 65 : BYTE Data_5[3]
// Byte 66 : BYTE Data_6[0]
// Byte 67 : BYTE Data_6[1]
// Byte 68 : BYTE Data_6[2]
// Byte 69 : BYTE Data_6[3]
// Byte 70 : BYTE Data_7[0]
// Byte 71 : BYTE Data_7[1]
// Byte 72 : BYTE Data_7[2]
// Byte 73 : BYTE Data_7[3]
// Byte 74 : BOOL RCParameter
// --------------------------

VAR
  /// internal index for loops
  _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp         :=  CmdType.WriteSystemVariable;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
                          
  _command.EmitterID[0]   :=  0;
  _command.EmitterID[1]   :=  0;
  _command.EmitterID[2]   :=  0;
  _command.EmitterID[3]   :=  0;
  _command.ListenerID     :=  _parCmd.ListenerID;
  _command.Reserve        :=  0;
  _command.ParameterID    :=  _parCmd.ParameterID;
  _command.SubParameterID :=  _parCmd.SubParameterID;
  _command.DataType       :=  _parCmd.DataType;
  _command.Data_0         :=  _parCmd.Data_0;
  _command.Data_1         :=  _parCmd.Data_1;
  _command.Data_2         :=  _parCmd.Data_2;
  _command.Data_3         :=  _parCmd.Data_3;
  _command.Data_4         :=  _parCmd.Data_4;
  _command.Data_5         :=  _parCmd.Data_5;
  _command.Data_6         :=  _parCmd.Data_6;
  _command.Data_7         :=  _parCmd.Data_7;
  
  
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
  
  FOR _idx := 0 TO 7 
  DO
    // add command.ParameterID[_idx]
    CreateCommandPayload.AddUint(_command.ParameterID[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.SubParameterID[_idx]
    CreateCommandPayload.AddUsint(_command.SubParameterID[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.DataType[_idx]
    CreateCommandPayload.AddUsint(_command.DataType[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_0[_idx]
    CreateCommandPayload.AddUsint(_command.Data_0[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_1[_idx]
    CreateCommandPayload.AddUsint(_command.Data_1[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_2[_idx]
    CreateCommandPayload.AddUsint(_command.Data_2[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_3[_idx]
    CreateCommandPayload.AddUsint(_command.Data_3[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_4[_idx]
    CreateCommandPayload.AddUsint(_command.Data_4[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_5[_idx]
    CreateCommandPayload.AddUsint(_command.Data_5[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_6[_idx]
    CreateCommandPayload.AddUsint(_command.Data_6[_idx]);
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // add command.Data_7[_idx]
    CreateCommandPayload.AddUsint(_command.Data_7[_idx]);
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteSystemVariableFB';
  
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
                  
           RestartRequested := _response.RestartRequested    ;            
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.RestartRequested  := _response.RestartRequested;
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
// Table 6-627: Received CMD payload (RC to PLC) of "WriteSystemVariable"
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
// Byte 04 : USINT      - InvocationCounter
// Byte 05 : SINT       - Reserved
// Byte 06 : INT        - OriginID HW HB
// Byte 07 :            - OriginID HW LB
// Byte 08 : BOOL       - RestartRequested
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
  // Get Response.RestartRequested
  _response.RestartRequested := ResponseData.GetBool();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  RestartRequested   := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD
