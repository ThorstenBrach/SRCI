/// Read content of selected user frame number
FUNCTION_BLOCK MC_ReadFrameDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadFrameDataFB                                       
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
  ParCmd          : ReadFrameDataParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadFrameDataOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ReadFrameDataParCmd;
  /// command data to send
 _command         : ReadFrameDataSendData;
  /// response data received
 _response        : ReadFrameDataRecvData;      
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
// Table 6-159: Sent CMD payload (PLC to RC) of "ReadFrameData"
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
// Byte 04 : USINT - FrameNo
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadFrameData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  _command.FrameNo  := _parCmd.FrameNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.FrameNo
  CreateCommandPayload.AddInt(_command.FrameNo);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadFrameDataFB';
  
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
             OutCmd.FrameData     := _response.FrameData;
             OutCmd.FrameNoReturn := _response.FrameNoReturn;
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
// Table 6-479: Received CMD payload (RC to PLC) of "ReadDigitalInputs"
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
// Byte 04 : DATE    - FrameData.Date HW HB;
// Byte 05 :         - FrameData.Date HW LB;
// Byte 06 : TOD     - FrameData.Time HW HB;
// Byte 07 :         - FrameData.Time HW LB;
// Byte 08 :         - FrameData.Time LW HB;
// Byte 09 :         - FrameData.Time LW LB;
// Byte 10 : USINT   - FrameData.ReferenceFrame;
// Byte 11 : BYTE    - Reserved;
// Byte 12 : REAL    - FrameData.X HW HB;
// Byte 13 :         - FrameData.X HW LB;
// Byte 14 :         - FrameData.X LW HB;
// Byte 15 :         - FrameData.X LW LB;
// Byte 16 : REAL    - FrameData.Y HW HB;
// Byte 17 :         - FrameData.Y HW LB;
// Byte 18 :         - FrameData.Y LW HB;
// Byte 19 :         - FrameData.Y LW LB;
// Byte 20 : REAL    - FrameData.Z HW HB;
// Byte 21 :         - FrameData.Z HW LB;
// Byte 22 :         - FrameData.Z LW HB;
// Byte 23 :         - FrameData.Z LW LB;
// Byte 24 : REAL    - FrameData.RX HW HB;
// Byte 25 :         - FrameData.RX HW LB;
// Byte 26 :         - FrameData.RX LW HB;
// Byte 27 :         - FrameData.RX LW LB;
// Byte 28 : REAL    - FrameData.RY HW HB;
// Byte 29 :         - FrameData.RY HW LB;
// Byte 30 :         - FrameData.RY LW HB;
// Byte 31 :         - FrameData.RY LW LB;
// Byte 32 : REAL    - FrameData.RZ HW HB;
// Byte 33 :         - FrameData.RZ HW LB;
// Byte 34 :         - FrameData.RZ LW HB;
// Byte 35 :         - FrameData.RZ LW LB;
// Byte 36 : USINT   - FrameNo;
// Byte 37 : BOOL    - DataChanged;
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
  
  // Get Response.FrameData.Timestamp.IEC_DATE
  _response.FrameData.Timestamp.IEC_DATE := ResponseData.GetUsint();
  // Get Response.FrameData.Timestamp.IEC_TIME
  _response.FrameData.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.FrameData.ReferenceFrame
  _response.FrameData.ReferenceFrame := ResponseData.GetUsint();
  // Get Response.FrameData.Reserve
  _response.Reserve := ResponseData.GetByte();
  // Get Response.FrameData.X
  _response.FrameData.X := ResponseData.GetReal();
  // Get Response.FrameData.Y
  _response.FrameData.Y := ResponseData.GetReal();
  // Get Response.FrameData.Z
  _response.FrameData.Z := ResponseData.GetReal();
  // Get Response.FrameData.Rx
  _response.FrameData.Rx := ResponseData.GetReal();
  // Get Response.FrameData.Ry
  _response.FrameData.Ry := ResponseData.GetReal();
  // Get Response.FrameData.Rz
  _response.FrameData.Rz := ResponseData.GetReal();
  // Get Response.FrameNoReturn
  _response.FrameNoReturn := ResponseData.GetUsint();
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

