/// Read the actual position – TCP: X…RZ + config/Turn, … Joint: (J1…E6)
FUNCTION_BLOCK MC_ReadActualPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionFB                                       
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
  /// Processing mode - For more information see chapter 5.6.4.5.
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;  
  /// command parameter 
  ParCmd             : ReadActualPositionParCmd;
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values
  /// • ActualCartesianPosition
  /// • ToolNoReturn
  /// • FrameNoReturn
  /// • ActualJointPosition
  Valid              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;  
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command outputs
  OutCmd             : ReadActualPositionOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadActualPositionParCmd;
  /// command data to send
 _command            : ReadActualPositionSendData;
  /// response data received
 _response           : ReadActualPositionRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.ReadActualPosition;
  
  IF ( NOT CheckFunctionSupported )
  THEN
    // call base implementation for set error and create log entry
    SUPER^.CheckFunctionSupported(AxesGroup := AxesGroup);
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

  // Check ParCmd Size is > 0, because MemCmp does not work correctly with size = 0
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-38: Sent CMD payload (PLC to RC) of "ReadActualPosition"
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
// Byte 10 : USINT ToolNo
// Byte 11 : USINT FrameNo
// --------------------------

  // set command parameter 
  _command.CmdTyp       :=  CmdType.ReadActualPosition;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.EmitterID[0] := 0;
  _command.EmitterID[1] := 0;
  _command.EmitterID[2] := 0;
  _command.EmitterID[3] := 0;
  _command.Reserve      := 0;
  _command.ListenerID   := _parCmd.ListenerID;
  _command.ToolNo       := INT_TO_USINT(_parCmd.ToolNo);
  _command.FrameNo      := INT_TO_USINT(_parCmd.FrameNo);
  
  
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
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.Index[1]
  CreateCommandPayload.AddUsint(_command.FrameNo);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadActualPositionFB';
  
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
           // Check function is supported and parameter are valid ?
           IF (( CheckFunctionSupported( AxesGroup := AxesGroup )) AND
               ( CheckParameterValid   ( AxesGroup := AxesGroup )))      
           THEN
             // set busy flag
             Busy := TRUE;
             // Reset command outputs
             SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
             // apply command parameter
            _parCmd := ParCmd;
             // init parameter sequence
            _command.ParSeq := 1;
             // create command data
             CommandData := CreateCommandPayload();
             // Add command to active command register
            _uniqueID := AxesGroup.Acyclic.ActiveCommandRegister.AddCmd( pCommandFB := ADR(THIS^ ));     
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1;
           END_IF 
         END_IF
       
  
    01:  // Wait for responce received
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
             OutCmd.OriginID                := _response.OriginID;
             OutCmd.InvocationCounter       := _response.InvocationCounter;
             OutCmd.ToolNoReturn            := _response.ToolNoReturn;
             OutCmd.FrameNoReturn           := _response.FrameNoReturn;
             OutCmd.ActualCartesianPosition := _response.ActualCartesianPosition;
             OutCmd.ActualJointPosition     := _response.ActualJointPosition;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
  
    02: IF ( NOT Execute)
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
// Table 6-39: Received CMD payload (RC to PLC) of "ReadActualPosition"
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
// Byte 04 : USINT   - InvocationCounter;
// Byte 05 : SINT    - Reserved;
// Byte 06 : INT     - OriginID HW HB;
// Byte 07 :         - OriginID HW LB;
// Byte 08 : USINT   - ToolNoReturn;
// Byte 09 : USINT   - FrameNoReturn;
// Byte 10 : REAL    - ActualCartesianPosition.X HW HB;
// Byte 11 :         - ActualCartesianPosition.X HW LB;
// Byte 12 :         - ActualCartesianPosition.X LW HB;
// Byte 13 :         - ActualCartesianPosition.X LW LB;
// Byte 14 : REAL    - ActualCartesianPosition.Y HW HB;
// Byte 15 :         - ActualCartesianPosition.Y HW LB;
// Byte 16 :         - ActualCartesianPosition.Y LW HB;
// Byte 17 :         - ActualCartesianPosition.Y LW LB;
// Byte 18 : REAL    - ActualCartesianPosition.Z HW HB;
// Byte 19 :         - ActualCartesianPosition.Z HW LB;
// Byte 20 :         - ActualCartesianPosition.Z LW HB;
// Byte 21 :         - ActualCartesianPosition.Z LW LB;
// Byte 22 : REAL    - ActualCartesianPosition.RX HW HB;
// Byte 23 :         - ActualCartesianPosition.RX HW LB;
// Byte 24 :         - ActualCartesianPosition.RX LW HB;
// Byte 25 :         - ActualCartesianPosition.RX LW LB;
// Byte 26 : REAL    - ActualCartesianPosition.RY HW HB;
// Byte 27 :         - ActualCartesianPosition.RY HW LB;
// Byte 28 :         - ActualCartesianPosition.RY LW HB;
// Byte 29 :         - ActualCartesianPosition.RY LW LB;
// Byte 30 : REAL    - ActualCartesianPosition.RZ HW HB;
// Byte 31 :         - ActualCartesianPosition.RZ HW LB;
// Byte 32 :         - ActualCartesianPosition.RZ LW HB;
// Byte 33 :         - ActualCartesianPosition.RZ LW LB;
// Byte 34 : BYTE    - W E S;
// Byte 35 : BYTE    - Reserved;
// Byte 36 : BYTE    - ActualCartesianPosition.TurnNumber[0];
// Byte 37 : BYTE    - ActualCartesianPosition.TurnNumber[1];
// Byte 38 : BYTE    - ActualCartesianPosition.TurnNumber[2];
// Byte 39 : BYTE    - ActualCartesianPosition.TurnNumber[3];
// Byte 40 : REAL    - ActualJointPosition.J1 HW HB;
// Byte 41 :         - ActualJointPosition.J1 HW LB;
// Byte 42 :         - ActualJointPosition.J1 LW HB;
// Byte 43 :         - ActualJointPosition.J1 LW LB;
// Byte 44 : REAL    - ActualJointPosition.J2 HW HB;
// Byte 45 :         - ActualJointPosition.J2 HW LB;
// Byte 46 :         - ActualJointPosition.J2 LW HB;
// Byte 47 :         - ActualJointPosition.J2 LW LB;
// Byte 48 : REAL    - ActualJointPosition.J3 HW HB;
// Byte 49 :         - ActualJointPosition.J3 HW LB;
// Byte 50 :         - ActualJointPosition.J3 LW HB;
// Byte 51 :         - ActualJointPosition.J3 LW LB;
// Byte 52 : REAL    - ActualJointPosition.J4 HW HB;
// Byte 53 :         - ActualJointPosition.J4 HW LB;
// Byte 54 :         - ActualJointPosition.J4 LW HB;
// Byte 55 :         - ActualJointPosition.J4 LW LB;
// Byte 56 : REAL    - ActualJointPosition.J5 HW HB;
// Byte 57 :         - ActualJointPosition.J5 HW LB;
// Byte 58 :         - ActualJointPosition.J5 LW HB;
// Byte 59 :         - ActualJointPosition.J5 LW LB;
// Byte 60 : REAL    - ActualJointPosition.J6 HW HB;
// Byte 61 :         - ActualJointPosition.J6 HW LB;
// Byte 62 :         - ActualJointPosition.J6 LW HB;
// Byte 63 :         - ActualJointPosition.J6 LW LB;
// Byte 64 : REAL    - ActualCartesianPosition.E1 HW HB;
// Byte 65 :         - ActualCartesianPosition.E1 HW LB;
// Byte 66 :         - ActualCartesianPosition.E1 LW HB;
// Byte 67 :         - ActualCartesianPosition.E1 LW LB;
// Byte 68 : REAL    - ActualCartesianPosition.E2 HW HB;
// Byte 69 :         - ActualCartesianPosition.E2 HW LB;
// Byte 70 :         - ActualCartesianPosition.E2 LW HB;
// Byte 71 :         - ActualCartesianPosition.E2 LW LB;
// Byte 72 : REAL    - ActualCartesianPosition.E3 HW HB;
// Byte 73 :         - ActualCartesianPosition.E3 HW LB;
// Byte 74 :         - ActualCartesianPosition.E3 LW HB;
// Byte 75 :         - ActualCartesianPosition.E3 LW LB;
// Byte 76 : REAL    - ActualCartesianPosition.E4 HW HB;
// Byte 77 :         - ActualCartesianPosition.E4 HW LB;
// Byte 78 :         - ActualCartesianPosition.E4 LW HB;
// Byte 79 :         - ActualCartesianPosition.E4 LW LB;
// Byte 80 : REAL    - ActualCartesianPosition.E5 HW HB;
// Byte 81 :         - ActualCartesianPosition.E5 HW LB;
// Byte 82 :         - ActualCartesianPosition.E5 LW HB;
// Byte 83 :         - ActualCartesianPosition.E5 LW LB;
// Byte 84 : REAL    - ActualCartesianPosition.E6 HW HB;
// Byte 85 :         - ActualCartesianPosition.E6 HW LB;
// Byte 86 :         - ActualCartesianPosition.E6 LW HB;
// Byte 87 :         - ActualCartesianPosition.E6 LW LB;
// Byte 88 : REAL    - ActualJointPosition.E1 HW HB;
// Byte 89 :         - ActualJointPosition.E1 HW LB;
// Byte 90 :         - ActualJointPosition.E1 LW HB;
// Byte 91 :         - ActualJointPosition.E1 LW LB;
// Byte 92 : REAL    - ActualJointPosition.E2 HW HB;
// Byte 93 :         - ActualJointPosition.E2 HW LB;
// Byte 94 :         - ActualJointPosition.E2 LW HB;
// Byte 95 :         - ActualJointPosition.E2 LW LB;
// Byte 96 : REAL    - ActualJointPosition.E3 HW HB;
// Byte 97 :         - ActualJointPosition.E3 HW LB;
// Byte 98 :         - ActualJointPosition.E3 LW HB;
// Byte 99 :         - ActualJointPosition.E3 LW LB;
// Byte 100: REAL    - ActualJointPosition.E4 HW HB;
// Byte 101:         - ActualJointPosition.E4 HW LB;
// Byte 102:         - ActualJointPosition.E4 LW HB;
// Byte 103:         - ActualJointPosition.E4 LW LB;
// Byte 104: REAL    - ActualJointPosition.E5 HW HB;
// Byte 105:         - ActualJointPosition.E5 HW LB;
// Byte 106:         - ActualJointPosition.E5 LW HB;
// Byte 107:         - ActualJointPosition.E5 LW LB;
// Byte 108: REAL    - ActualJointPosition.E6 HW HB;
// Byte 109:         - ActualJointPosition.E6 HW LB;
// Byte 110:         - ActualJointPosition.E6 LW HB;
// Byte 111:         - ActualJointPosition.E6 LW LB;
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
  
  // Get Response.ToolNoReturn
  _response.ToolNoReturn := ResponseData.GetUsint();
  // Get Response.FrameNoReturn
  _response.FrameNoReturn := ResponseData.GetUsint();
  // Get Response.ActualCartesianPosition.X
  _response.ActualCartesianPosition.X := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Y
  _response.ActualCartesianPosition.Y := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Z
  _response.ActualCartesianPosition.Z := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Rx
  _response.ActualCartesianPosition.Rx := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Ry
  _response.ActualCartesianPosition.Ry := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Rz
  _response.ActualCartesianPosition.Rz := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.Config
  _response.ActualCartesianPosition.Config := ResponseData.GetArmConfig();
  // Get Response.ActualCartesianPosition.TurnNumber
  _response.ActualCartesianPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get Response.ActualCartesianPosition.E1
  _response.ActualCartesianPosition.E1 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J1
  _response.ActualJointPosition.J1 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J2
  _response.ActualJointPosition.J2 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J3
  _response.ActualJointPosition.J3 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J4
  _response.ActualJointPosition.J4 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J5
  _response.ActualJointPosition.J5 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.J6
  _response.ActualJointPosition.J6 := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.E2
  _response.ActualCartesianPosition.E2 := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.E3
  _response.ActualCartesianPosition.E3 := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.E4
  _response.ActualCartesianPosition.E4 := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.E5
  _response.ActualCartesianPosition.E5 := ResponseData.GetReal();
  // Get Response.ActualCartesianPosition.E6
  _response.ActualCartesianPosition.E6 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E1
  _response.ActualJointPosition.E1 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E2
  _response.ActualJointPosition.E2 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E3
  _response.ActualJointPosition.E3 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E4
  _response.ActualJointPosition.E4 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E5
  _response.ActualJointPosition.E5 := ResponseData.GetReal();
  // Get Response.ActualJointPosition.E6
  _response.ActualJointPosition.E6 := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE;
  ParameterAccepted  := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

