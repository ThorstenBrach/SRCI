/// Create and move spline on RC simultaneously
FUNCTION_BLOCK MC_DynamicSplineFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DynamicSplineFB                                       
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
  /// Start of the command at the rising edge
  Execute            : BOOL;
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands
  AbortingMode       : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter 
  ParCmd             : DynamicSplineParCmd;
END_VAR
VAR_OUTPUT
  /// FB is being processed
  Busy               : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// Function is enabled and new input values will be transmitted.
  Enabled            : BOOL;
  /// The command takes control of the motion of the according axis group
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command results
  OutCmd             : DynamicSplineOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : DynamicSplineParCmd;
  /// command data to send
 _command            : DynamicSplineSendData;
  /// response data received
 _response           : DynamicSplineRecvData;      
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-772: Sent CMD payload (PLC to RC) of "DynamicSpline"
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
// Byte 00 : UINT  Type;
// Byte 01 :       Type;
// Byte 02 : USINT Reserved ExecutionMode;
// Byte 03 : USINT ParSeq Priority;
// Byte 04 : UINT  Mode;
// Byte 05 : USINT BlendingMode;
// Byte 06 : REAL  BlendingParameter[0];
// Byte 07 :       BlendingParameter[0];
// Byte 08 :       BlendingParameter[0];
// Byte 09 :       BlendingParameter[0];
// Byte 10 : REAL  BlendingParameter[1];
// Byte 11 :       BlendingParameter[1];
// Byte 12 :       BlendingParameter[1];
// Byte 13 :       BlendingParameter[1];
// Byte 14 : UINT  Time;
// Byte 15 :       Time;
// Byte 16 : INT   StartPosition;
// Byte 17 :       StartPosition;
// Byte 18 : UINT  SplineData.VelocityRate;
// Byte 19 :       SplineData.VelocityRate;
// Byte 20 : UINT  SplineData.AccelerationRate;
// Byte 21 :       SplineData.AccelerationRate;
// Byte 22 : UINT  SplineData.DecelerationRate;
// Byte 23 :       SplineData.DecelerationRate;
// Byte 24 : UINT  SplineData.JerkRate;
// Byte 25 :       SplineData.JerkRate;
// Byte 26 : USINT SplineData.ToolNo;
// Byte 27 : USINT SplineData.FrameNo;
// Byte 28 : REAL  SplineData.X;
// Byte 29 :       SplineData.X;
// Byte 30 :       SplineData.X;
// Byte 31 :       SplineData.X;
// Byte 32 : REAL  SplineData.Y;
// Byte 33 :       SplineData.Y;
// Byte 34 :       SplineData.Y;
// Byte 35 :       SplineData.Y;
// Byte 36 : REAL  SplineData.Z;
// Byte 37 :       SplineData.Z;
// Byte 38 :       SplineData.Z;
// Byte 39 :       SplineData.Z;
// Byte 40 : REAL  SplineData.RX;
// Byte 41 :       SplineData.RX;
// Byte 42 :       SplineData.RX;
// Byte 43 :       SplineData.RX;
// Byte 44 : REAL  SplineData.RY;
// Byte 45 :       SplineData.RY;
// Byte 46 :       SplineData.RY;
// Byte 47 :       SplineData.RY;
// Byte 48 : REAL  SplineData.RZ;
// Byte 49 :       SplineData.RZ;
// Byte 50 :       SplineData.RZ;
// Byte 51 :       SplineData.RZ;
// Byte 52 : BYTE  - - - - - W E S;
// Byte 53 : BYTE  Reserved;
// Byte 54 : BYTE  SplineData.TurnNumber[0];
// Byte 55 : BYTE  SplineData.TurnNumber[1];
// Byte 56 : BYTE  SplineData.TurnNumber[2];
// Byte 57 : BYTE  SplineData.TurnNumber[3];
// Byte 58 : REAL  SplineData.E1;
// Byte 59 :       SplineData.E1;
// Byte 60 :       SplineData.E1;
// Byte 61 :       SplineData.E1;
// Byte 62 : UINT  SplineData.Time;
// Byte 63 :       SplineData.Time;
// Byte 64 : REAL  SplineData.E2;
// Byte 65 :       SplineData.E2;
// Byte 66 :       SplineData.E2;
// Byte 67 :       SplineData.E2;
// Byte 68 : REAL  SplineData.E3;
// Byte 69 :       SplineData.E3;
// Byte 70 :       SplineData.E3;
// Byte 71 :       SplineData.E3;
// Byte 72 : REAL  SplineData.E4;
// Byte 73 :       SplineData.E4;
// Byte 74 :       SplineData.E4;
// Byte 75 :       SplineData.E4;
// Byte 76 : REAL  SplineData.E5;
// Byte 77 :       SplineData.E5;
// Byte 78 :       SplineData.E5;
// Byte 79 :       SplineData.E5;
// Byte 80 : REAL  SplineData.E6;
// Byte 81 :       SplineData.E6;
// Byte 82 :       SplineData.E6;
// Byte 83 :       SplineData.E6;
VAR
  /// internal index for loops
  _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp            :=  CmdType.DynamicSpline;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.Mode              := _parCmd.Mode;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.MoveTime          := TIME_TO_UINT(_parCmd.MoveTime);
  _command.StartPosition     := _parCmd.StartPosition;
  
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    _command.SplineData[_idx].VelocityRate     := REAL_TO_UINT(_parCmd.SplineData[_idx].VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
    _command.SplineData[_idx].AccelerationRate := REAL_TO_UINT(_parCmd.SplineData[_idx].AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
    _command.SplineData[_idx].DecelerationRate := REAL_TO_UINT(_parCmd.SplineData[_idx].DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
    _command.SplineData[_idx].JerkRate         := REAL_TO_UINT(_parCmd.SplineData[_idx].JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
    _command.SplineData[_idx].ToolNo           :=              _parCmd.SplineData[_idx].ToolNo;
    _command.SplineData[_idx].FrameNo          :=              _parCmd.SplineData[_idx].FrameNo;
    _command.SplineData[_idx].MoveTime         := TIME_TO_UINT(_parCmd.SplineData[_idx].MoveTime);
  END_FOR
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  
  // add command.Mode
  CreateCommandPayload.AddUint(_command.Mode);
  // add command.BlendingMode
  CreateCommandPayload.AddUsint(_command.BlendingMode);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.StartPosition
  CreateCommandPayload.AddInt(_command.StartPosition);
  
  
  FOR _idx := 1 TO RobotLibraryParameter.SPLINE_DATA_MAX
  DO
    // add command.VelocityRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].VelocityRate);
    // add command.AccelerationRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].AccelerationRate);
    // add command.DecelerationRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].DecelerationRate);
    // add command.JerkRate
    CreateCommandPayload.AddUint(_command.SplineData[_idx].JerkRate);
    // add command.ToolNo
    CreateCommandPayload.AddUsint(_command.SplineData[_idx].ToolNo);
    // add command.FrameNo
    CreateCommandPayload.AddUsint(_command.SplineData[_idx].FrameNo);
    // add command.SplineData[_idx].Position.X
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.X);
    // add command.SplineData[_idx].Position.Y
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Y);
    // add command.SplineData[_idx].Position.Z
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Z);
    // add command.SplineData[_idx].Position.Rx
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rx);
    // add command.SplineData[_idx].Position.Ry
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Ry);
    // add command.SplineData[_idx].Position.Rz
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.Rz);
    // add command.SplineData[_idx].Position.Config
    CreateCommandPayload.AddArmConfig(_command.SplineData[_idx].Position.Config);
    // add command.SplineData[_idx].Position.TurnNumber
    CreateCommandPayload.AddTurnNumber(_command.SplineData[_idx].Position.TurnNumber);
    // add command.SplineData[_idx].Position.E1
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E1);
    // add command.SplineData[_idx].MoveTime
    CreateCommandPayload.AddUint(_command.SplineData[_idx].MoveTime);  
    // add command.SplineData[_idx].Position.E2
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E2);
    // add command.SplineData[_idx].Position.E3
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E3);
    // add command.SplineData[_idx].Position.E4
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E4);
    // add command.SplineData[_idx].Position.E5
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E5);
    // add command.SplineData[_idx].Position.E6
    CreateCommandPayload.AddReal(_command.SplineData[_idx].Position.E6);
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_DynamicSplineFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( Execute )  
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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.SegmentProgress     := _response.SegmentProgress;
             OutCmd.RemainingDistance   := _response.RemainingDistance;
             OutCmd.Buffered            := _response.Buffered;
             OutCmd.Calculated          := _response.Calculated;
             OutCmd.ActiveIndex         := _response.ActiveIndex;
             OutCmd.TrajectoryCompleted := _response.TrajectoryCompleted;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
  
    03: IF ( NOT Execute)
        THEN
          // reset step counter
         _stepCmd := 0;
          // reset busy flag
          Busy := FALSE;    
          // reset buffered flag
          CommandBuffered := FALSE;  
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
   _uniqueId           := 0;
   _stepCmd            := 0;
    Busy               := FALSE;
    CommandBuffered    := FALSE;  
    CommandAborted     := FALSE;
    CommandInterrupted := FALSE;
    Error              := FALSE;
    ErrorID            := 0;
    WarningID          := 0;
    InfoID             := 0;  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-773: Received CMD payload (RC to PLC) of "DynamicSpline"
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
// Byte 04 : UINT    - Progress LW HB
// Byte 05 :         - Progress LW LB
// Byte 06 : REAL    - RemainingDistance HW HB
// Byte 07 :         - RemainingDistance HW LB
// Byte 08 :         - RemainingDistance LW HB
// Byte 09 :         - RemainingDistance LW LB
// Byte 10 : BOOL    - InClamping
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
  
  // Get Response.Progress
  _response.SegmentProgress := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance := ResponseData.GetReal();
  // Get Response.Buffered
  _response.Buffered := ResponseData.GetInt();
  // Get Response.Calculated
  _response.Calculated := ResponseData.GetInt();
  // Get Response.ActiveIndex
  _response.ActiveIndex := ResponseData.GetSint();
  // Get Response.TrajectoryCompleted
  _response.TrajectoryCompleted := ResponseData.GetBool();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  Active             := FALSE;
  Enabled            := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD
