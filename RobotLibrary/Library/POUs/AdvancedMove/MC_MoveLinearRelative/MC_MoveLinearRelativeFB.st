/// Move the TCP relative to the actual cartesian position (linear interpolation)
FUNCTION_BLOCK MC_MoveLinearRelativeFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveLinearRelativeFB                                       
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
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands
  AbortingMode       : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter
  ParCmd             : MoveLinearRelativeParCmd;         
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command takes control of the motion of the according axis group
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// command outputs
  OutCmd             : MoveLinearRelativeOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveLinearRelativeParCmd;
  /// command data to send
 _command            : MoveLinearRelativeSendData;
  /// response data received
 _response           : MoveLinearRelativeRecvData;      
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
// Table 6-288: Sent CMD payload (PLC to RC) of "MoveLinearRelative"
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
// Byte 04 : SINT  - EmitterID[0];
// Byte 05 : SINT  - EmitterID[1];
// Byte 06 : SINT  - EmitterID[2];
// Byte 07 : SINT  - EmitterID[3];
// Byte 08 : SINT  - ListenerID;
// Byte 09 : BYTE  - Reserved;
// Byte 10 : UINT  - VelocityRate HB;
// Byte 11 :       - VelocityRate LB;
// Byte 12 : UINT  - AccelerationRate HB;
// Byte 13 :       - AccelerationRate LB;
// Byte 14 : UINT  - DecelerationRate HB;
// Byte 15 :       - DecelerationRate LB;
// Byte 16 : UINT  - JerkRate HB;
// Byte 17 :       - JerkRate LB;
// Byte 18 : USINT - ToolNo;
// Byte 19 : USINT - FrameNo;
// Byte 20 : USINT - BlendingMode;
// Byte 21 : USINT - OriMode;
// Byte 22 : REAL  - BlendingParameter[0] HW HB;
// Byte 23 :       - BlendingParameter[0] HW LB;
// Byte 24 :       - BlendingParameter[0] LW HB;
// Byte 25 :       - BlendingParameter[0] LW LB;
// Byte 26 : REAL  - BlendingParameter[1] HW HB;
// Byte 27 :       - BlendingParameter[1] HW LB;
// Byte 28 :       - BlendingParameter[1] LW HB;
// Byte 29 :       - BlendingParameter[1] LW LB;
// Byte 30 : REAL  - Distance.X HW HB;
// Byte 31 :       - Distance.X HW LB;
// Byte 32 :       - Distance.X LW HB;
// Byte 33 :       - Distance.X LW LB;
// Byte 34 : REAL  - Distance.Y HW HB;
// Byte 35 :       - Distance.Y HW LB;
// Byte 36 :       - Distance.Y LW HB;
// Byte 37 :       - Distance.Y LW LB;
// Byte 38 : REAL  - Distance.Z HW HB;
// Byte 39 :       - Distance.Z HW LB;
// Byte 40 :       - Distance.Z LW HB;
// Byte 41 :       - Distance.Z LW LB;
// Byte 42 : REAL  - Distance.RX HW HB;
// Byte 43 :       - Distance.RX HW LB;
// Byte 44 :       - Distance.RX LW HB;
// Byte 45 :       - Distance.RX LW LB;
// Byte 46 : REAL  - Distance.RY HW HB;
// Byte 47 :       - Distance.RY HW LB;
// Byte 48 :       - Distance.RY LW HB;
// Byte 49 :       - Distance.RY LW LB;
// Byte 50 : REAL  - Distance.RZ HW HB;
// Byte 51 :       - Distance.RZ HW LB;
// Byte 52 :       - Distance.RZ LW HB;
// Byte 53 :       - Distance.RZ LW LB;
// Byte 54 : BYTE  - - - - - - W E S;
// Byte 55 : BYTE  - Reserved;
// Byte 56 : BYTE  - Distance.TurnNumber[0];
// Byte 57 : BYTE  - Distance.TurnNumber[1];
// Byte 58 : BYTE  - Distance.TurnNumber[2];
// Byte 59 : BYTE  - Distance.TurnNumber[3];
// Byte 60 : REAL  - Distance.E1 HW HB;
// Byte 61 :       - Distance.E1 HW LB;
// Byte 62 :       - Distance.E1 LW HB;
// Byte 63 :       - Distance.E1 LW LB;
// Byte 64 : BOOL  - Manipulation;
// Byte 65 : BYTE  - ConfigMode[0];
// Byte 66 : BYTE  - ConfigMode[1];
// Byte 67 : USINT - ReferenceType;
// Byte 68 : USINT - TurnMode;
// Byte 69 : UINT  - Time HB;
// Byte 70 :       - Time LB;
// Byte 71 : REAL  - Distance.E2 HW HB;
// Byte 72 :       - Distance.E2 HW LB;
// Byte 73 :       - Distance.E2 LW HB;
// Byte 74 :       - Distance.E2 LW LB;
// Byte 75 : REAL  - Distance.E3 HW HB;
// Byte 76 :       - Distance.E3 HW LB;
// Byte 77 :       - Distance.E3 LW HB;
// Byte 78 :       - Distance.E3 LW LB;
// Byte 79 : REAL  - Distance.E4 HW HB;
// Byte 80 :       - Distance.E4 HW LB;
// Byte 81 :       - Distance.E4 LW HB;
// Byte 82 :       - Distance.E4 LW LB;
// Byte 83 : REAL  - Distance.E5 HW HB;
// Byte 84 :       - Distance.E5 HW LB;
// Byte 85 :       - Distance.E5 LW HB;
// Byte 86 :       - Distance.E5 LW LB;
// Byte 87 : REAL  - Distance.E6 HW HB;
// Byte 88 :       - Distance.E6 HW LB;
// Byte 89 :       - Distance.E6 LW HB;
// Byte 90 :       - Distance.E6 LW LB;
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.MoveLinearRelative;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.EmitterID         := _parCmd.EmitterID;
  _command.Reserve           := 0;
  _command.ListenerID        := 0; {warning 'ToDo'}
  _command.Reserve           := 0;
  _command.VelocityRate      := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate  := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate  := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate          := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo            := _parCmd.ToolNo;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.BlendingMode      := _parCmd.BlendingMode;
  _command.OriMode           := _parCmd.OriMode;
  _command.BlendingParameter := _parCmd.BlendingParameter;
  _command.Distance          := _parCmd.Distance;
  _command.Manipulation      := _parCmd.Manipulation;
  _command.ConfigMode        := _parCmd.ConfigMode;
  _command.ReferenceType     := _parCmd.ReferenceType;
  _command.TurnMode          := _parCmd.TurnMode;
  _command.MoveTime          := TIME_TO_UINT(_parCmd.MoveTime);
  
  
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
  // add command.VelocityRate
  CreateCommandPayload.AddUint(_command.VelocityRate);
  // add command.AccelerationRate
  CreateCommandPayload.AddUint(_command.AccelerationRate);
  // add command.DecelerationRate
  CreateCommandPayload.AddUint(_command.DecelerationRate);
  // add command.JerkRate
  CreateCommandPayload.AddUint(_command.JerkRate);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.mFrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.BlendingMode
  CreateCommandPayload.AddUsint(_command.BlendingMode);
  // add command.OriMode
  CreateCommandPayload.AddUsint(_command.OriMode);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.Distance.X
  CreateCommandPayload.AddReal(_command.Distance.X);
  // add command.Distance.Y
  CreateCommandPayload.AddReal(_command.Distance.Y);
  // add command.Distance.Z
  CreateCommandPayload.AddReal(_command.Distance.Z);
  // add command.Distance.Rx
  CreateCommandPayload.AddReal(_command.Distance.Rx);
  // add command.Distance.Ry
  CreateCommandPayload.AddReal(_command.Distance.Ry);
  // add command.Distance.Rz
  CreateCommandPayload.AddReal(_command.Distance.Rz);
  // add command.Distance.Config
  CreateCommandPayload.AddArmConfig(_command.Distance.Config);
  // add command.Distance.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Distance.TurnNumber);
  // add command.Distance.E1
  CreateCommandPayload.AddReal(_command.Distance.E1);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.ConfigMode
  CreateCommandPayload.AddArmConfig(_command.ConfigMode);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.TurnMode
  CreateCommandPayload.AddUsint(_command.TurnMode);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.Distance.E2
  CreateCommandPayload.AddReal(_command.Distance.E2);
  // add command.Distance.E3
  CreateCommandPayload.AddReal(_command.Distance.E3);
  // add command.Distance.E4
  CreateCommandPayload.AddReal(_command.Distance.E4);
  // add command.Distance.E5
  CreateCommandPayload.AddReal(_command.Distance.E5);
  // add command.Distance.E6
  CreateCommandPayload.AddReal(_command.Distance.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveLinearRelativeFB';

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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : Active             := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.DONE        : Done               := TRUE;           
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Update results
             OutCmd.Progress          := _response.Progress;
             OutCmd.FollowID          := _response.OriginID;
             OutCmd.RemainingDistance := _response.RemainingDistance;
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
// Table 6-289: Received CMD payload (RC to PLC) of "MoveLinearRelative"
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
// Byte 04 : USINT      - InvocationCounter
// Byte 05 : SINT       - Reserved
// Byte 06 : INT        - OriginID HW HB
// Byte 07 :            - OriginID HW LB
// Byte 08 : UINT       - Progress HW HB
// Byte 09 :            - Progress HW LB
// Byte 10 : REAL       - RemainingDistance HW HB
// Byte 11 :            - RemainingDistance HW LB
// Byte 12 :            - RemainingDistance LW HB
// Byte 13 :            - RemainingDistance LW LB
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
  
  // Get Response.InvocationCounter
  _response.InvocationCounter := ResponseData.GetUsint();
  // Get Response.Reserve
  _response.Reserve := ResponseData.GetSint();
  // Get Response.OriginID
  _response.OriginID := ResponseData.GetInt();
  // Get Response.Progress
  _response.Progress := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Active             := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD
