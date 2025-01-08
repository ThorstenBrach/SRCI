/// Calculate Forward Kinematic
FUNCTION_BLOCK MC_CalculateForwardKinematicFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateForwardKinematicFB                                       
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
  ParCmd          : CalculateForwardKinematicParCmd;    
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : CalculateForwardKinematicOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : CalculateForwardKinematicParCmd;
  /// command data to send
 _command         : CalculateForwardKinematicSendData;
  /// response data received
 _response        : CalculateForwardKinematicRecvData;      
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
// Table 6-632: Sent CMD payload (PLC to RC) of "CalculateForwardKinematic"
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
// Byte 04 : USINT - ToolNo
// Byte 05 : USINT - FrameNo
// Byte 06 : REAL  - Position.J1  HW HB
// Byte 07 :       - Position.J1  HW LB
// Byte 08 :       - Position.J1  LW HB
// Byte 09 :       - Position.J1  LW LB
// Byte 10 : REAL  - Position.J2  HW HB
// Byte 11 :       - Position.J2  HW LB
// Byte 12 :       - Position.J2  LW HB
// Byte 13 :       - Position.J2  LW LB
// Byte 14 : REAL  - Position.J3  HW HB
// Byte 15 :       - Position.J3  HW LB
// Byte 16 :       - Position.J3  LW HB
// Byte 17 :       - Position.J3  LW LB
// Byte 18 : REAL  - Position.J4  HW HB
// Byte 19 :       - Position.J4  HW LB
// Byte 20 :       - Position.J4  LW HB
// Byte 21 :       - Position.J4  LW LB
// Byte 22 : REAL  - Position.J5  HW HB
// Byte 23 :       - Position.J5  HW LB
// Byte 24 :       - Position.J5  LW HB
// Byte 25 :       - Position.J5  LW LB
// Byte 26 : REAL  - Position.J6  HW HB
// Byte 27 :       - Position.J6  HW LB
// Byte 28 :       - Position.J6  LW HB
// Byte 29 :       - Position.J6  LW LB
// Byte 30 : REAL  - Position.E1  HW HB
// Byte 31 :       - Position.E1  HW LB
// Byte 32 :       - Position.E1  LW HB
// Byte 33 :       - Position.E1  LW LB
// Byte 34 : REAL  - Position.E2  HW HB
// Byte 35 :       - Position.E2  HW LB
// Byte 36 :       - Position.E2  LW HB
// Byte 37 :       - Position.E2  LW LB
// Byte 38 : REAL  - Position.E3  HW HB
// Byte 39 :       - Position.E3  HW LB
// Byte 40 :       - Position.E3  LW HB
// Byte 41 :       - Position.E3  LW LB
// Byte 42 : REAL  - Position.E4  HW HB
// Byte 43 :       - Position.E4  HW LB
// Byte 44 :       - Position.E4  LW HB
// Byte 45 :       - Position.E4  LW LB
// Byte 46 : REAL  - Position.E5  HW HB
// Byte 47 :       - Position.E5  HW LB
// Byte 48 :       - Position.E5  LW HB
// Byte 49 :       - Position.E5  LW LB
// Byte 50 : REAL  - Position.E6  HW HB
// Byte 51 :       - Position.E6  HW LB
// Byte 52 :       - Position.E6  LW HB
// Byte 53 :       - Position.E6  LW LB

// --------------------------

  // set command parameter 
  _command.CmdTyp                     :=  CmdType.CalculateForwardKinematic;
  _command.ExecMode                   :=  ExecMode;
  _command.ParSeq                     := _command.ParSeq;
  _command.Priority                   :=  Priority;
  _command.ToolNo                     := _parCmd.ToolNo;
  _command.FrameNo                    := _parCmd.FrameNo;
  _command.CartesianPosition          := _parCmd.CartesianPosition;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
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

  MyType := 'MC_CalculateForwardKinematicFB';
  
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
             CmdMessageState.DONE     : Error           := TRUE;
             CmdMessageState.ERROR    : Done            := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.TargetToolNoReturn      := _response.TargetToolNoReturn;
             OutCmd.TargetFrameNoReturn     := _response.TargetFrameNoReturn;
             OutCmd.CartesianPosition       := _response.CartesianPosition;
  
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
// Table 6-633: Received CMD payload (RC to PLC) of "CalculateForwardKinematic"
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
// Byte 04 : USINT      - ToolNoReturn
// Byte 05 : USINT      - FrameNoReturn
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
  ResponseData : RobotLibraryRecvDataFB;
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
  // Get CartesianPosition.X
  _response.CartesianPosition.X := ResponseData.GetReal();
  // Get CartesianPosition.Y
  _response.CartesianPosition.Y := ResponseData.GetReal();
  // Get CartesianPosition.Z
  _response.CartesianPosition.Z := ResponseData.GetReal();
  // Get CartesianPosition.Rx
  _response.CartesianPosition.Rx := ResponseData.GetReal();
  // Get CartesianPosition.Ry
  _response.CartesianPosition.Ry := ResponseData.GetReal();
  // Get CartesianPosition.Rz
  _response.CartesianPosition.Rz := ResponseData.GetReal();
  // Get CartesianPosition.Config
  _response.CartesianPosition.Config := ResponseData.GetArmConfig();
  // Get CartesianPosition.TurnNumber
  _response.CartesianPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get CartesianPosition.E1
  _response.CartesianPosition.E1 := ResponseData.GetReal();
  // Get CartesianPosition.E2
  _response.CartesianPosition.E2 := ResponseData.GetReal();
  // Get CartesianPosition.E3
  _response.CartesianPosition.E3 := ResponseData.GetReal();
  // Get CartesianPosition.E4
  _response.CartesianPosition.E4 := ResponseData.GetReal();
  // Get CartesianPosition.E5
  _response.CartesianPosition.E5 := ResponseData.GetReal();
  // Get CartesianPosition.E6
  _response.CartesianPosition.E6 := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

