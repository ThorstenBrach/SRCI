/// Configure conveyor parameters
FUNCTION_BLOCK MC_ConfigureConveyorFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ConfigureConveyorFB                                       
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
  ParCmd          : ConfigureConveyorParCmd;      
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : ConfigureConveyorOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ConfigureConveyorParCmd;
  /// command data to send
 _command         : ConfigureConveyorSendData;
  /// response data received
 _response        : ConfigureConveyorRecvData;      
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-458: Sent CMD payload (PLC to RC) of "ConfigureConveyor"
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
// Byte 04 : IEC_DATE   - Date              LW HB
// Byte 05 :            - Date              LW LB
// Byte 06 : IEC_TIME   - Time              HW HB
// Byte 07 :            - Time              HW LB
// Byte 08 :            - Time              LW HB
// Byte 09 :            - Time              LW LB
// Byte 10 : USINT      - ReferenceFrame
// Byte 11 : BYTE       - Reserve
// Byte 12 : REAL       - ConveyorOrigin.X  HW HB
// Byte 13 :            - ConveyorOrigin.X  HW LB
// Byte 14 :            - ConveyorOrigin.X  LW HB
// Byte 15 :            - ConveyorOrigin.X  LW LB
// Byte 16 : REAL       - ConveyorOrigin.Y  HW HB
// Byte 17 :            - ConveyorOrigin.Y  HW LB
// Byte 18 :            - ConveyorOrigin.Y  LW HB
// Byte 19 :            - ConveyorOrigin.Y  LW LB
// Byte 20 : REAL       - ConveyorOrigin.Z  HW HB
// Byte 21 :            - ConveyorOrigin.Z  HW LB
// Byte 22 :            - ConveyorOrigin.Z  LW HB
// Byte 23 :            - ConveyorOrigin.Z  LW LB
// Byte 24 : REAL       - ConveyorOrigin.Rx HW HB
// Byte 25 :            - ConveyorOrigin.Rx HW LB
// Byte 26 :            - ConveyorOrigin.Rx LW HB
// Byte 27 :            - ConveyorOrigin.Rx LW LB
// Byte 28 : REAL       - ConveyorOrigin.Ry HW HB
// Byte 29 :            - ConveyorOrigin.Ry HW LB
// Byte 30 :            - ConveyorOrigin.Ry LW HB
// Byte 31 :            - ConveyorOrigin.Ry LW LB
// Byte 32 : REAL       - ConveyorOrigin.Rz HW HB
// Byte 33 :            - ConveyorOrigin.Rz HW LB
// Byte 34 :            - ConveyorOrigin.Rz LW HB
// Byte 35 :            - ConveyorOrigin.Rz LW LB
// Byte 36 : BOOL       - ConveyorOrigin Available
// Byte 37 : USINT      - ConveyorNo
// Byte 38 : USINT      - ConveyorType
// Byte 39 : REAL       - Radius            HW HB
// Byte 40 :            - Radius            HW LB
// Byte 41 :            - Radius            LW HB
// Byte 42 :            - Radius            LW LB
// Byte 43 : REAL       - StartDistance     HW HB
// Byte 44 :            - StartDistance     HW LB
// Byte 45 :            - StartDistance     LW HB
// Byte 46 :            - StartDistance     LW LB
// Byte 47 : REAL       - EndDistance       HW HB
// Byte 48 :            - EndDistance       HW LB
// Byte 49 :            - EndDistance       LW HB
// Byte 50 :            - EndDistance       LW LB
// Byte 51 : REAL       - SyncInLength      HW HB
// Byte 52 :            - SyncInLength      HW LB
// Byte 53 :            - SyncInLength      LW HB
// Byte 54 :            - SyncInLength      LW LB
// Byte 55 : REAL       - SyncOutLength     HW HB
// Byte 56 :            - SyncOutLength     HW LB
// Byte 57 :            - SyncOutLength     LW HB
// Byte 58 :            - SyncOutLength     LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ConfigureConveyor;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.ConveyorNo     := _parCmd.ConveyorNo;
  _command.ConveyorOrigin := _parCmd.ConveyorOrigin;
  _command.ConveyorType   := _parCmd.ConveyorType;
  _command.Radius         := _parCmd.Radius;
  _command.StartDistance  := _parCmd.StartDistance;
  _command.EndDistance    := _parCmd.EndDistance;
  _command.SyncInLength   := _parCmd.SyncInLength;
  _command.SyncOutLength  := _parCmd.SyncOutLength;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  
  // add command.ConveyorOrigin.Timestamp.IEC_DATE
  CreateCommandPayload.AddIecDate(_command.ConveyorOrigin.Timestamp.IEC_DATE);
  // add command.ConveyorOrigin.Timestamp.IEC_TIME
  CreateCommandPayload.AddIecTime(_command.ConveyorOrigin.Timestamp.IEC_TIME);
  // add command.ConveyorOrigin.ReferenceFrame
  CreateCommandPayload.AddUsint(_command.ConveyorOrigin.ReferenceFrame);
  // add command.ConveyorOrigin.Reserve
  CreateCommandPayload.AddByte(0);
  // add command.ConveyorOrigin.ReferenceFrame.X
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.X);
  // add command.ConveyorOrigin.ReferenceFrame.Y
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Y);
  // add command.ConveyorOrigin.ReferenceFrame.Z
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Z);
  // add command.ConveyorOrigin.ReferenceFrame.Rx
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Rx);
  // add command.ConveyorOrigin.ReferenceFrame.Ry
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Ry);
  // add command.ConveyorOrigin.ReferenceFrame.Rz
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Rz);
  // add command.ConveyorOriginAvailable
  CreateCommandPayload.AddBool(_command.ConveyorOriginAvailable);
  // add command.ConveyorNo
  CreateCommandPayload.AddUsint(_command.ConveyorNo);
  // add command.ConveyorType
  CreateCommandPayload.AddUsint(_command.ConveyorType);
  // add command.Radius
  CreateCommandPayload.AddReal(_command.Radius);
  // add command.StartDistance
  CreateCommandPayload.AddReal(_command.StartDistance);
  // add command.EndDistance
  CreateCommandPayload.AddReal(_command.EndDistance);
  // add command.SyncInLength
  CreateCommandPayload.AddReal(_command.SyncInLength);
  // add command.SyncOutLength
  CreateCommandPayload.AddReal(_command.SyncOutLength);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ConfigureConveyorFB';

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
             //OutCmd.Dummy := _response.Dummy;
             
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
// Table 6-459: Received CMD payload (RC to PLC) of "ConfigureConveyor"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT      - ParSeq | State     
// Byte 01 : SINT       - AlarmMessageSeverity    
// Byte 02 : UINT       - AlarmMessageCode HB
// Byte 03 :            - AlarmMessageCode LB
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

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

