/// Calculate tool (TCP) with four-point method
FUNCTION_BLOCK MC_CalculateToolFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateToolFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
  ParCmd          : CalculateToolParCmd;      
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateToolOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateToolParCmd;
  /// command data to send
 _command         : CalculateToolSendData;
  /// response data received
 _response        : CalculateToolRecvData;      
  /// Incremented with each position of the input parameter "PositionsArray" sent from the PLC to the RC.
  /// • Default: 0
 _dataIndex       : USINT;
  /// Set TRUE by the client, when according to the user selected "Mode" the final position of the input parameter "PositionsArray" is sent to the RC.
  /// • Default: FALSE
 _dataComplete    : BOOL;
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
// Table 6-650: Sent CMD payload (PLC to RC) of "CalculateTool"
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
// Byte 04 : USINT      - DataIndex
// Byte 05 : BOOL       - DataComplete
// Byte 06 : USINT      - ToolNo
// Byte 07 : USINT      - FrameNo
// Byte 08 : SINT       - Mode
// Byte 09 : USINT      - ExternalTCP
// Byte 10 : REAL       - Position.X  HW HB
// Byte 11 :            - Position.X  HW LB
// Byte 12 :            - Position.X  LW HB
// Byte 13 :            - Position.X  LW LB
// Byte 14 : REAL       - Position.Y  HW HB
// Byte 15 :            - Position.Y  HW LB
// Byte 16 :            - Position.Y  LW HB
// Byte 17 :            - Position.Y  LW LB
// Byte 18 : REAL       - Position.Z  HW HB
// Byte 19 :            - Position.Z  HW LB
// Byte 20 :            - Position.Z  LW HB
// Byte 21 :            - Position.Z  LW LB
// Byte 22 : REAL       - Position.Rx HW HB
// Byte 23 :            - Position.Rx HW LB
// Byte 24 :            - Position.Rx LW HB
// Byte 25 :            - Position.Rx LW LB
// Byte 26 : REAL       - Position.Ry HW HB
// Byte 27 :            - Position.Ry HW LB
// Byte 28 :            - Position.Ry LW HB
// Byte 29 :            - Position.Ry LW LB
// Byte 30 : REAL       - Position.Rz HW HB
// Byte 31 :            - Position.Rz HW LB
// Byte 32 :            - Position.Rz LW HB
// Byte 33 :            - Position.Rz LW LB
// Byte 34 : Config     - ArmConfig   LW HB
// Byte 35 :            - ArmConfig   LW LB
// Byte 36 : TurnNumber - J1 + J2     LW HB
// Byte 37 :            - J3 + J4     LW LB
// Byte 38 :            - J5 + J6     LW LB
// Byte 39 :            - E1          LW LB
// Byte 40 : REAL       - Position.E1 HW HB
// Byte 41 :            - Position.E1 HW LB
// Byte 42 :            - Position.E1 LW HB
// Byte 43 :            - Position.E1 LW LB
// Byte 44 : REAL       - Position.E2 HW HB
// Byte 45 :            - Position.E2 HW LB
// Byte 46 :            - Position.E2 LW HB
// Byte 47 :            - Position.E2 LW LB
// Byte 48 : REAL       - Position.E3 HW HB
// Byte 49 :            - Position.E3 HW LB
// Byte 50 :            - Position.E3 LW HB
// Byte 51 :            - Position.E3 LW LB
// Byte 52 : REAL       - Position.E4 HW HB
// Byte 53 :            - Position.E4 HW LB
// Byte 54 :            - Position.E4 LW HB
// Byte 55 :            - Position.E4 LW LB
// Byte 56 : REAL       - Position.E5 HW HB
// Byte 57 :            - Position.E5 HW LB
// Byte 58 :            - Position.E5 LW HB
// Byte 59 :            - Position.E5 LW LB
// Byte 60 : REAL       - Position.E6 HW HB
// Byte 61 :            - Position.E6 HW LB
// Byte 62 :            - Position.E6 LW HB
// Byte 63 :            - Position.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.CalculateTool;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.DataIndex      := _dataIndex;
  _command.DataComplete.0 := _dataComplete;
  _command.ToolNo         := _parCmd.ToolNo;
  _command.FrameNo        := _parCmd.FrameNo;
  _command.Mode           := _parCmd.Mode;
  _command.ExternalTCP.0  := _parCmd.ExternalTCP;
    
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.TargetFrameNo
  CreateCommandPayload.AddUsint(_command.DataIndex);
  // add command.DataComplete
  CreateCommandPayload.AddByte(_command.DataComplete);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.ExternalTCP);
  // add command.Position.X
  CreateCommandPayload.AddReal(_command.Position.X);
  // add command.Position.Y
  CreateCommandPayload.AddReal(_command.Position.Y);
  // add command.Position.Z
  CreateCommandPayload.AddReal(_command.Position.Z);
  // add command.Position.Rx
  CreateCommandPayload.AddReal(_command.Position.Rx);
  // add command.Position.Ry
  CreateCommandPayload.AddReal(_command.Position.Ry);
  // add command.Position.Rz
  CreateCommandPayload.AddReal(_command.Position.Rz);
  // add command.Position.Config
  CreateCommandPayload.AddArmConfig (_command.Position.Config);
  // add command.Position.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Position.TurnNumber);
  // add command.Position.E1
  CreateCommandPayload.AddReal(_command.Position.E1);
  // add command.Position.E2
  CreateCommandPayload.AddReal(_command.Position.E2);
  // add command.Position.E3
  CreateCommandPayload.AddReal(_command.Position.E3);
  // add command.Position.E4
  CreateCommandPayload.AddReal(_command.Position.E4);
  // add command.Position.E5
  CreateCommandPayload.AddReal(_command.Position.E5);
  // add command.Position.E6
  CreateCommandPayload.AddReal(_command.Position.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CalculateToolFB';
  
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
       
    01: // inc data index 
       _dataIndex := _dataIndex + 1;
  
        CASE _parCmd.Mode OF
  
          ToolCalculationMode.TWO_POINT_Z_METHOD :
            _dataComplete := _dataIndex >= 2;
          
          ToolCalculationMode.THREE_POINT_METHOD :
            _dataComplete := _dataIndex >= 3;
  
          ToolCalculationMode.FOUR_POINT_METHOD :
            _dataComplete := _dataIndex >= 4;        
  
          ToolCalculationMode.FIVE_POINT_METHOD :        
            _dataComplete := _dataIndex >= 5;
  
          ToolCalculationMode.SIX_POINT_METHOD :        
            _dataComplete := _dataIndex >= 6;
  
          ToolCalculationMode.ABC_WORLD_METHOD :
            _dataComplete := _dataIndex >= 1;
          
          ToolCalculationMode.ABC_TWO_POINT_METHOD :
            _dataComplete := _dataIndex >= 2;
  
        END_CASE
  
         // create command data
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
             OutCmd.TCPMaxError    := _response.TCPMaxError;
             OutCmd.TCPMeanError   := _response.TCPMeanError;
             OutCmd.ToolData       := _response.ToolData;
             
             IF ( _dataComplete ) OR (_response.State = CmdMessageState.ABORTED )
             THEN
               // set timeout
               SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
               // inc step counter
              _stepCmd := _stepCmd + 1; 
             ELSE
               // set timeout
               SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
               // dec step counter
              _stepCmd := _stepCmd - 1; 
             END_IF
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
// Table 6-651: Received CMD payload (RC to PLC) of "CalculateTool"
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
// Byte 04 : IEC_DATE   - ToolData.Date LW HB
// Byte 05 :            - ToolData.Date LW LB
// Byte 06 : REAL       - TCPMaxError   HW HB
// Byte 07 :            - TCPMaxError   HW LB
// Byte 08 :            - TCPMaxError   LW HB
// Byte 09 :            - TCPMaxError   LW LB
// Byte 10 : REAL       - TCPMeanError  HW HB
// Byte 11 :            - TCPMeanError  HW LB
// Byte 12 :            - TCPMeanError  LW HB
// Byte 13 :            - TCPMeanError  LW LB
// Byte 14 : IEC_TIME   - ToolData.Time HW HB
// Byte 15 :            - ToolData.Time HW LB
// Byte 16 :            - ToolData.Time LW HB
// Byte 17 :            - ToolData.Time LW LB


// Byte 18 : REAL       - ToolData.X  HW HB
// Byte 19 :            - ToolData.X  HW LB
// Byte 20 :            - ToolData.X  LW HB
// Byte 21 :            - ToolData.X  LW LB
// Byte 22 : REAL       - ToolData.Y  HW HB
// Byte 23 :            - ToolData.Y  HW LB
// Byte 24 :            - ToolData.Y  LW HB
// Byte 25 :            - ToolData.Y  LW LB
// Byte 26 : REAL       - ToolData.Z  HW HB
// Byte 27 :            - ToolData.Z  HW LB
// Byte 28 :            - ToolData.Z  LW HB
// Byte 29 :            - ToolData.Z  LW LB
// Byte 30 : REAL       - ToolData.Rx HW HB
// Byte 31 :            - ToolData.Rx HW LB
// Byte 32 :            - ToolData.Rx LW HB
// Byte 33 :            - ToolData.Rx LW LB
// Byte 34 : REAL       - ToolData.Ry HW HB
// Byte 35 :            - ToolData.Ry HW LB
// Byte 36 :            - ToolData.Ry LW HB
// Byte 37 :            - ToolData.Ry LW LB
// Byte 38 : REAL       - ToolData.Rz HW HB
// Byte 39 :            - ToolData.Rz HW LB
// Byte 40 :            - ToolData.Rz LW HB
// Byte 41 :            - ToolData.Rz LW LB
// Byte 42 : USINT      - ToolData.ID
// Byte 43 : USINT      - ToolData.LoadNo
// Byte 44 : BOOL       - ToolData.ExternalTCP
// --------------------------
VAR_INPUT
  /// Response data
  ResponseData : RecvData;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  // Get Response.IEC_Date
  _response.ToolData.Timestamp.IEC_Date := ResponseData.GetIecDate();
  // Get Response.TCPMaxError
  _response.TCPMaxError := ResponseData.GetReal();
  // Get Response.TCPMeanError
  _response.TCPMeanError := ResponseData.GetReal();
  // Get Response.ToolData.Time
  _response.ToolData.Timestamp.IEC_Time := ResponseData.GetIecTime();
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

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

