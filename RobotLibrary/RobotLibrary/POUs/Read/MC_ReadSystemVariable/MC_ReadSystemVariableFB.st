/// Read specific parameter of the robot
FUNCTION_BLOCK MC_ReadSystemVariableFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadSystemVariableFB                                       
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
  ParCmd             : ReadSystemVariableParCmd;
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • DataType
  /// • Data_0
  /// • Data_1
  /// • Data_2
  /// • Data_3
  /// • Data_4
  /// • Data_5
  /// • Data_6
  /// • Data_7
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
  OutCmd             : ReadSystemVariableOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadSystemVariableParCmd;
  /// command data to send
 _command            : ReadSystemVariableSendData;
  /// response data received
 _response           : ReadSystemVariableRecvData;      
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-618: Sent CMD payload (PLC to RC) of "ReadSystemVariable"
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
// Byte 04 : SINT  EmitterID[0];
// Byte 05 : SINT  EmitterID[1];
// Byte 06 : SINT  EmitterID[2];
// Byte 07 : SINT  EmitterID[3];
// Byte 08 : SINT  ListenerID;
// Byte 09 : BYTE  Reserved;
// Byte 10 : UINT  ParameterID[0] HW HB;
// Byte 11 :       ParameterID[0] HW LB;
// Byte 12 : UINT  ParameterID[1] HW HB;
// Byte 13 :       ParameterID[1] HW LB;
// Byte 14 : UINT  ParameterID[2] HW HB;
// Byte 15 :       ParameterID[2] HW LB;
// Byte 16 : UINT  ParameterID[3] HW HB;
// Byte 17 :       ParameterID[3] HW LB;
// Byte 18 : UINT  ParameterID[4] HW HB;
// Byte 19 :       ParameterID[4] HW LB;
// Byte 20 : UINT  ParameterID[5] HW HB;
// Byte 21 :       ParameterID[5] HW LB;
// Byte 22 : UINT  ParameterID[6] HW HB;
// Byte 23 :       ParameterID[6] HW LB;
// Byte 24 : UINT  ParameterID[7] HW HB;
// Byte 25 :       ParameterID[7] HW LB;
// Byte 26 : USINT SubParameterID[0];
// Byte 27 : USINT SubParameterID[1];
// Byte 28 : USINT SubParameterID[2];
// Byte 29 : USINT SubParameterID[3];
// Byte 30 : USINT SubParameterID[4];
// Byte 31 : USINT SubParameterID[5];
// Byte 32 : USINT SubParameterID[6];
// Byte 33 : USINT SubParameterID[7];
// Byte 34 : BOOL  RCParameter;

// --------------------------
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ReadSystemVariable;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.EmitterID[0]   := 0;
  _command.EmitterID[1]   := 0;
  _command.EmitterID[2]   := 0;
  _command.EmitterID[3]   := 0;
  _command.Reserve        := 0;
  _command.ListenerID     := _parCmd.ListenerID;
  _command.ParameterID    := _parCmd.ParameterID;
  _command.SubParameterID := _parCmd.SubParameterID;
  _command.RCParameter    := _parCmd.RCParameter;
  
  
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
  
  // add command.RCParameter
  CreateCommandPayload.AddBool(_command.RCParameter);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadSystemVariableFB';
  
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
             OutCmd.DataType          := _response.DataType;
             OutCmd.Data_0            := _response.Data_0;
             OutCmd.Data_1            := _response.Data_1;
             OutCmd.Data_2            := _response.Data_2;
             OutCmd.Data_3            := _response.Data_3;
             OutCmd.Data_4            := _response.Data_4;
             OutCmd.Data_5            := _response.Data_5;
             OutCmd.Data_6            := _response.Data_6;
             OutCmd.Data_7            := _response.Data_7;
             
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
// Table 6-619: Received CMD payload (RC to PLC) of "ReadSystemVariable"
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
// Byte 04 : USINT InvocationCounter;
// Byte 05 : SINT  Reserved;
// Byte 06 : INT   OriginID HW HB;
// Byte 07 :       OriginID HW LB;
// Byte 08 : USINT DataType[0];
// Byte 09 : USINT DataType[1];
// Byte 10 : USINT DataType[2];
// Byte 11 : USINT DataType[3];
// Byte 12 : USINT DataType[4];
// Byte 13 : USINT DataType[5];
// Byte 14 : USINT DataType[6];
// Byte 15 : USINT DataType[7];
// Byte 16 : BYTE  Data_0[0];
// Byte 17 : BYTE  Data_0[1];
// Byte 18 : BYTE  Data_0[2];
// Byte 19 : BYTE  Data_0[3];
// Byte 20 : BYTE  Data_1[0];
// Byte 21 : BYTE  Data_1[1];
// Byte 22 : BYTE  Data_1[2];
// Byte 23 : BYTE  Data_1[3];
// Byte 24 : BYTE  Data_2[0];
// Byte 25 : BYTE  Data_2[1];
// Byte 26 : BYTE  Data_2[2];
// Byte 27 : BYTE  Data_2[3];
// Byte 28 : BYTE  Data_3[0];
// Byte 29 : BYTE  Data_3[1];
// Byte 30 : BYTE  Data_3[2];
// Byte 31 : BYTE  Data_3[3];
// Byte 32 : BYTE  Data_4[0];
// Byte 33 : BYTE  Data_4[1];
// Byte 34 : BYTE  Data_4[2];
// Byte 35 : BYTE  Data_4[3];
// Byte 36 : BYTE  Data_5[0];
// Byte 37 : BYTE  Data_5[1];
// Byte 38 : BYTE  Data_5[2];
// Byte 39 : BYTE  Data_5[3];
// Byte 40 : BYTE  Data_6[0];
// Byte 41 : BYTE  Data_6[1];
// Byte 42 : BYTE  Data_6[2];
// Byte 43 : BYTE  Data_6[3];
// Byte 44 : BYTE  Data_7[0];
// Byte 45 : BYTE  Data_7[1];
// Byte 46 : BYTE  Data_7[2];
// Byte 47 : BYTE  Data_7[3];
// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RecvData;
END_VAR
VAR
  /// internal index for loops
 _idx : DINT;
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
  
  FOR _idx := 0 TO 7
  DO
    // Get Response.DataType[_idx] 
   _response.DataType[_idx] := ResponseData.GetUsint();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_0[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_1[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_2[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_3[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_4[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_5[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_6[_idx] := ResponseData.GetByte();
  END_FOR
  
  FOR _idx := 0 TO 3
  DO
    // Get Response.DataType[_idx] 
   _response.Data_7[_idx] := ResponseData.GetByte();
  END_FOR

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
