/// Change configuration of selected tool number
FUNCTION_BLOCK MC_WriteToolDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteToolDataFB                                       
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
  ParCmd             : WriteToolDataParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : WriteToolDataOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteToolDataParCmd;
  /// command data to send
 _command            : WriteToolDataSendData;
  /// response data received
 _response           : WriteToolDataRecvData;      
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
// Table 6-126: Sent CMD payload (PLC to RC) of "WriteToolData"
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
// Byte 04 : DATE ToolData.Date
// Byte 05 : 
// Byte 06 : TIME_OF_DAY ToolData.Time
// Byte 07 : 
// Byte 08 : 
// Byte 09 : REAL ToolData.X
// Byte 10 : 
// Byte 11 : 
// Byte 12 : REAL ToolData.Y
// Byte 13 : 
// Byte 14 : 
// Byte 15 : REAL ToolData.Z
// Byte 16 : 
// Byte 17 : 
// Byte 18 : REAL ToolData.RX
// Byte 19 : 
// Byte 20 : 
// Byte 21 : REAL ToolData.RY
// Byte 22 : 
// Byte 23 : 
// Byte 24 : REAL ToolData.RZ
// Byte 25 : 
// Byte 26 : 
// Byte 27 : USINT ToolData.ID
// Byte 28 : USINT ToolData.LoadNo
// Byte 29 : BOOL ToolData.ExternalTCP
// Byte 30 : BYTE Reserved
// Byte 31 : USINT ToolNo
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.WriteToolData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;                  
  _command.ToolData :=  _parCmd.ToolData;
  _command.ToolNo   :=  _parCmd.ToolNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.ToolData.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.ToolData.Timestamp.IEC_DATE);
  // add command.ToolData.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.ToolData.Timestamp.IEC_TIME);
  // add command.ToolData.X
  CreateCommandPayload.AddReal(_command.ToolData.X);
  // add command.ToolData.Y
  CreateCommandPayload.AddReal(_command.ToolData.Y);
  // add command.ToolData.Z
  CreateCommandPayload.AddReal(_command.ToolData.Z);
  // add command.ToolData.Rx
  CreateCommandPayload.AddReal(_command.ToolData.Rx);
  // add command.ToolData.Ry
  CreateCommandPayload.AddReal(_command.ToolData.Ry);
  // add command.ToolData.Rz
  CreateCommandPayload.AddReal(_command.ToolData.Rz);
  // add command.ToolData.ID
  CreateCommandPayload.AddUsint(_command.ToolData.ID);
  // add command.ToolData.LoadNo
  CreateCommandPayload.AddUsint(_command.ToolData.LoadNo);
  // add command.ToolData.ExternalTCP
  CreateCommandPayload.AddBool(_command.ToolData.ExternalTCP);
  // add command.ToolData.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.ToolData.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteToolDataFB';
  
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
// Table 6-127: Received CMD payload (RC to PLC) of "WriteToolData"
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
