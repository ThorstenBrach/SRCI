/// Read content of selected tool number
FUNCTION_BLOCK MC_ReadToolDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadToolDataFB                                       
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
  ParCmd          : ReadToolDataParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadToolDataOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadToolDataParCmd;
  /// command data to send
 _command         : ReadToolDataSendData;
  /// response data received
 _response        : ReadToolDataRecvData;      
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-165: Sent CMD payload (PLC to RC) of "ReadToolData"
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
// Byte 04 : USINT - ToolNo;
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadToolData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  _command.ToolNo   := _parCmd.ToolNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.ToolNo
  CreateCommandPayload.AddInt(_command.ToolNo);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadToolDataFB';
  
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
             OutCmd.ToolData     := _response.ToolData;
             OutCmd.ToolNoReturn := _response.ToolNoReturn;
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
// Table 6-166: Received CMD payload (RC to PLC) of "ReadToolData"
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
// Byte 04 : IEC_DATE   ToolData.Date HW HB;
// Byte 05 :            ToolData.Date HW LB;
// Byte 06 : IEC_TIME - ToolData.Time HW HB;
// Byte 07 :            ToolData.Time HW LB;
// Byte 08 :            ToolData.Time LW HB;
// Byte 09 :            ToolData.Time LW LB;
// Byte 10 : REAL       ToolData.X HW HB;
// Byte 11 :            ToolData.X HW LB;
// Byte 12 :            ToolData.X LW HB;
// Byte 13 :            ToolData.X LW LB;
// Byte 14 : REAL       ToolData.Y HW HB;
// Byte 15 :            ToolData.Y HW LB;
// Byte 16 :            ToolData.Y LW HB;
// Byte 17 :            ToolData.Y LW LB;
// Byte 18 : REAL       ToolData.Z HW HB;
// Byte 19 :            ToolData.Z HW LB;
// Byte 20 :            ToolData.Z LW HB;
// Byte 21 :            ToolData.Z LW LB;
// Byte 22 : REAL       ToolData.RX HW HB;
// Byte 23 :            ToolData.RX HW LB;
// Byte 24 :            ToolData.RX LW HB;
// Byte 25 :            ToolData.RX LW LB;
// Byte 26 : REAL       ToolData.RY HW HB;
// Byte 27 :            ToolData.RY HW LB;
// Byte 28 :            ToolData.RY LW HB;
// Byte 29 :            ToolData.RY LW LB;
// Byte 30 : REAL       ToolData.RZ HW HB;
// Byte 31 :            ToolData.RZ HW LB;
// Byte 32 :            ToolData.RZ LW HB;
// Byte 33 :            ToolData.RZ LW LB;
// Byte 34 : USINT      ToolData.ID;
// Byte 35 : USINT      ToolData.LoadNo;
// Byte 36 : BOOL       ToolData.ExternalTCP;
// Byte 37 : BYTE       Reserved;
// Byte 38 : USINT      ToolNo;
// Byte 39 : BOOL       DataChanged;
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
  
  // Get Response.ToolData.Timestamp.IEC_DATE
  _response.ToolData.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.ToolData.Timestamp.IEC_TIME
  _response.ToolData.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.ToolData.X
  _response.ToolData.X := ResponseData.GetReal();
  // Get Response.ToolData.Y
  _response.ToolData.Y := ResponseData.GetReal();
  // Get Response.ToolData.Z
  _response.ToolData.Z := ResponseData.GetReal();
  // Get Response.ToolData.Rx
  _response.ToolData.Rx := ResponseData.GetReal();
  // Get Response.ToolData.Ry
  _response.ToolData.Ry := ResponseData.GetReal();
  // Get Response.ToolData.Rz
  _response.ToolData.Rz := ResponseData.GetReal();
  // Get Response.ToolData.ID
  _response.ToolData.ID := ResponseData.GetUsint();
  // Get Response.ToolData.LoadNo
  _response.ToolData.LoadNo := ResponseData.GetUsint();
  // Get Response.ToolData.ExternalTCP
  _response.ToolData.ExternalTCP := ResponseData.GetBool();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetByte();
  // Get Response.ToolData.ToolNoReturn
  _response.ToolNoReturn := ResponseData.GetUsint();
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

