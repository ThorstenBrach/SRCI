/// Calculate cartesian position from existing cartesian position
FUNCTION_BLOCK MC_CalculateCartesianPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateCartesianPositionFB                                       
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
  /// Command parameter 
  ParCmd          : CalculateCartesianPositionParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateCartesianPositionOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateCartesianPositionParCmd;
  /// command data to send
 _command         : CalculateCartesianPositionSendData;
  /// response data received
 _response        : CalculateCartesianPositionRecvData;      
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
// Table 6-645: Received CMD payload (RC to PLC) of "CalculateCartesianPosition"
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
// Byte 04 : USINT      - FrameNo
// Byte 05 : USINT      - TargetFrameNo
// Byte 06 : REAL       - Position.X  HW HB
// Byte 07 :            - Position.X  HW LB
// Byte 08 :            - Position.X  LW HB
// Byte 09 :            - Position.X  LW LB
// Byte 10 : REAL       - Position.Y  HW HB
// Byte 11 :            - Position.Y  HW LB
// Byte 12 :            - Position.Y  LW HB
// Byte 13 :            - Position.Y  LW LB
// Byte 14 : REAL       - Position.Z  HW HB
// Byte 15 :            - Position.Z  HW LB
// Byte 16 :            - Position.Z  LW HB
// Byte 17 :            - Position.Z  LW LB
// Byte 18 : REAL       - Position.Rx HW HB
// Byte 19 :            - Position.Rx HW LB
// Byte 20 :            - Position.Rx LW HB
// Byte 21 :            - Position.Rx LW LB
// Byte 22 : REAL       - Position.Ry HW HB
// Byte 23 :            - Position.Ry HW LB
// Byte 24 :            - Position.Ry LW HB
// Byte 25 :            - Position.Ry LW LB
// Byte 26 : REAL       - Position.Rz HW HB
// Byte 27 :            - Position.Rz HW LB
// Byte 28 :            - Position.Rz LW HB
// Byte 29 :            - Position.Rz LW LB
// Byte 30 : Config     - ArmConfig   LW HB
// Byte 31 :            - ArmConfig   LW LB
// Byte 32 : TurnNumber - J1 + J2     LW HB
// Byte 33 :            - J3 + J4     LW LB
// Byte 34 :            - J5 + J6     LW LB
// Byte 35 :            - E1          LW LB
// Byte 36 : REAL       - Position.E1 HW HB
// Byte 37 :            - Position.E1 HW LB
// Byte 38 :            - Position.E1 LW HB
// Byte 39 :            - Position.E1 LW LB
// Byte 40 : REAL       - Position.E2 HW HB
// Byte 41 :            - Position.E2 HW LB
// Byte 42 :            - Position.E2 LW HB
// Byte 43 :            - Position.E2 LW LB
// Byte 44 : REAL       - Position.E3 HW HB
// Byte 45 :            - Position.E3 HW LB
// Byte 46 :            - Position.E3 LW HB
// Byte 47 :            - Position.E3 LW LB
// Byte 48 : REAL       - Position.E4 HW HB
// Byte 49 :            - Position.E4 HW LB
// Byte 50 :            - Position.E4 LW HB
// Byte 51 :            - Position.E4 LW LB
// Byte 52 : REAL       - Position.E5 HW HB
// Byte 53 :            - Position.E5 HW LB
// Byte 54 :            - Position.E5 LW HB
// Byte 55 :            - Position.E5 LW LB
// Byte 56 : REAL       - Position.E6 HW HB
// Byte 57 :            - Position.E6 HW LB
// Byte 58 :            - Position.E6 LW HB
// Byte 59 :            - Position.E6 LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.CalculateCartesianPosition;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.TargetFrameNo     := _parCmd.TargetFrameNo;
  _command.CartesianPosition := _parCmd.CartesianPosition;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.TargetFrameNo
  CreateCommandPayload.AddUsint(_command.TargetFrameNo);
  // add command.CartesianPosition.X
  CreateCommandPayload.AddReal(_command.CartesianPosition.X);
  // add command.CartesianPosition.Y
  CreateCommandPayload.AddReal(_command.CartesianPosition.Y);
  // add command.CartesianPosition.Z
  CreateCommandPayload.AddReal(_command.CartesianPosition.Z);
  // add command.CartesianPosition.Rx
  CreateCommandPayload.AddReal(_command.CartesianPosition.Rx);
  // add command.CartesianPosition.Ry
  CreateCommandPayload.AddReal(_command.CartesianPosition.Ry);
  // add command.CartesianPosition.Rz
  CreateCommandPayload.AddReal(_command.CartesianPosition.Rz);
  // add command.CartesianPosition.Config
  CreateCommandPayload.AddArmConfig(_command.CartesianPosition.Config);
  // add command.CartesianPosition.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.CartesianPosition.TurnNumber);
  // add command.CartesianPosition.E1
  CreateCommandPayload.AddReal(_command.CartesianPosition.E1);
  // add command.CartesianPosition.E2
  CreateCommandPayload.AddReal(_command.CartesianPosition.E2);
  // add command.CartesianPosition.E3
  CreateCommandPayload.AddReal(_command.CartesianPosition.E3);
  // add command.CartesianPosition.E4
  CreateCommandPayload.AddReal(_command.CartesianPosition.E4);
  // add command.CartesianPosition.E5
  CreateCommandPayload.AddReal(_command.CartesianPosition.E5);
  // add command.CartesianPosition.E6
  CreateCommandPayload.AddReal(_command.CartesianPosition.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CalculateCartesianPositionFB';
  
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
             OutCmd.TargetToolNoReturn      := _response.TargetToolNoReturn;
             OutCmd.TargetFrameNoReturn     := _response.TargetFrameNoReturn;
             OutCmd.CartesianPositionReturn := _response.CartesianPositionReturn;
  
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
// Table 6-645: Received CMD payload (RC to PLC) of "CalculateCartesianPosition"
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
// Byte 04 : USINT      - TargetToolNoReturn
// Byte 05 : USINT      - TargetFrameNoReturn
// Byte 06 : REAL       - Position.X  HW HB
// Byte 07 :            - Position.X  HW LB
// Byte 08 :            - Position.X  LW HB
// Byte 09 :            - Position.X  LW LB
// Byte 10 : REAL       - Position.Y  HW HB
// Byte 11 :            - Position.Y  HW LB
// Byte 12 :            - Position.Y  LW HB
// Byte 13 :            - Position.Y  LW LB
// Byte 14 : REAL       - Position.Z  HW HB
// Byte 15 :            - Position.Z  HW LB
// Byte 16 :            - Position.Z  LW HB
// Byte 17 :            - Position.Z  LW LB
// Byte 18 : REAL       - Position.Rx HW HB
// Byte 19 :            - Position.Rx HW LB
// Byte 20 :            - Position.Rx LW HB
// Byte 21 :            - Position.Rx LW LB
// Byte 22 : REAL       - Position.Ry HW HB
// Byte 23 :            - Position.Ry HW LB
// Byte 24 :            - Position.Ry LW HB
// Byte 25 :            - Position.Ry LW LB
// Byte 26 : REAL       - Position.Rz HW HB
// Byte 27 :            - Position.Rz HW LB
// Byte 28 :            - Position.Rz LW HB
// Byte 29 :            - Position.Rz LW LB
// Byte 30 : Config     - ArmConfig   LW HB
// Byte 31 :            - ArmConfig   LW LB
// Byte 32 : TurnNumber - J1 + J2     LW HB
// Byte 33 :            - J3 + J4     LW LB
// Byte 34 :            - J5 + J6     LW LB
// Byte 35 :            - E1          LW LB
// Byte 36 : REAL       - Position.E1 HW HB
// Byte 37 :            - Position.E1 HW LB
// Byte 38 :            - Position.E1 LW HB
// Byte 39 :            - Position.E1 LW LB
// Byte 40 : REAL       - Position.E2 HW HB
// Byte 41 :            - Position.E2 HW LB
// Byte 42 :            - Position.E2 LW HB
// Byte 43 :            - Position.E2 LW LB
// Byte 44 : REAL       - Position.E3 HW HB
// Byte 45 :            - Position.E3 HW LB
// Byte 46 :            - Position.E3 LW HB
// Byte 47 :            - Position.E3 LW LB
// Byte 48 : REAL       - Position.E4 HW HB
// Byte 49 :            - Position.E4 HW LB
// Byte 50 :            - Position.E4 LW HB
// Byte 51 :            - Position.E4 LW LB
// Byte 52 : REAL       - Position.E5 HW HB
// Byte 53 :            - Position.E5 HW LB
// Byte 54 :            - Position.E5 LW HB
// Byte 55 :            - Position.E5 LW LB
// Byte 56 : REAL       - Position.E6 HW HB
// Byte 57 :            - Position.E6 HW LB
// Byte 58 :            - Position.E6 LW HB
// Byte 59 :            - Position.E6 LW LB
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
  
  // Get TargetToolNoReturn
  _response.TargetToolNoReturn   := ResponseData.GetUsint();
  // Get TargetFrameNoReturn
  _response.TargetFrameNoReturn  := ResponseData.GetUsint();
  // Get CartesianPositionReturn.X
  _response.CartesianPositionReturn.X := ResponseData.GetReal();
  // Get CartesianPositionReturn.Y
  _response.CartesianPositionReturn.Y := ResponseData.GetReal();
  // Get CartesianPositionReturn.Z
  _response.CartesianPositionReturn.Z := ResponseData.GetReal();
  // Get CartesianPositionReturn.Rx
  _response.CartesianPositionReturn.Rx := ResponseData.GetReal();
  // Get CartesianPositionReturn.Ry
  _response.CartesianPositionReturn.Ry := ResponseData.GetReal();
  // Get CartesianPositionReturn.Rz
  _response.CartesianPositionReturn.Rz := ResponseData.GetReal();
  // Get CartesianPositionReturn.Config
  _response.CartesianPositionReturn.Config := ResponseData.GetArmConfig();
  // Get CartesianPositionReturn.TurnNumber
  _response.CartesianPositionReturn.TurnNumber := ResponseData.GetTurnNumbers();
  // Get CartesianPositionReturn.E1
  _response.CartesianPositionReturn.E1 := ResponseData.GetReal();
  // Get CartesianPositionReturn.E2
  _response.CartesianPositionReturn.E2 := ResponseData.GetReal();
  // Get CartesianPositionReturn.E3
  _response.CartesianPositionReturn.E3 := ResponseData.GetReal();
  // Get CartesianPositionReturn.E4
  _response.CartesianPositionReturn.E4 := ResponseData.GetReal();
  // Get CartesianPositionReturn.E5
  _response.CartesianPositionReturn.E5 := ResponseData.GetReal();
  // Get CartesianPositionReturn.E6
  _response.CartesianPositionReturn.E6 := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD
