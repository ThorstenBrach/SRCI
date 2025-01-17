/// Move all joints relative to actual joint position (Relative Joint PTP)
FUNCTION_BLOCK MC_MoveAxesRelativeFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveAxesRelativeFB                                       
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
  ParCmd             : MoveAxesRelativeParCmd;     
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
  /// command results
  OutCmd             : MoveAxesRelativeOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : MoveAxesRelativeParCmd;
  /// command data to send
 _command            : MoveAxesRelativeSendData;
  /// response data received
 _response           : MoveAxesRelativeRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.MoveAxesRelative;
  
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
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-304: Sent CMD payload (PLC to RC) of "MoveAxesRelative"
// --------------------------
// Header
// --------------------------
// --------------------------
// Datablock
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 04 : SINT       - EmitterID[0]
// Byte 05 : SINT       - EmitterID[1]
// Byte 06 : SINT       - EmitterID[2]
// Byte 07 : SINT       - EmitterID[3]
// Byte 08 : SINT       - ListenerID
// Byte 09 : BYTE       - Reserved
// Byte 10 : UINT       - VelocityRate HW HB
// Byte 11 :            - VelocityRate HW LB
// Byte 12 : UINT       - AccelerationRate HW HB
// Byte 13 :            - AccelerationRate HW LB
// Byte 14 : UINT       - DecelerationRate HW HB
// Byte 15 :            - DecelerationRate HW LB
// Byte 16 : UINT       - JerkRate HW HB
// Byte 17 :            - JerkRate HW LB
// Byte 18 : USINT      - ToolNo
// Byte 19 : USINT      - BlendingMode
// Byte 20 : REAL       - BlendingParameter[0] HW HB
// Byte 21 :            - BlendingParameter[0] HW LB
// Byte 22 :            - BlendingParameter[0] LW HB
// Byte 23 :            - BlendingParameter[0] LW LB
// Byte 24 : REAL       - BlendingParameter[1] HW HB
// Byte 25 :            - BlendingParameter[1] HW LB
// Byte 26 :            - BlendingParameter[1] LW HB
// Byte 27 :            - BlendingParameter[1] LW LB
// Byte 28 : REAL       - JointDistance.J1 HW HB
// Byte 29 :            - JointDistance.J1 HW LB
// Byte 30 :            - JointDistance.J1 LW HB
// Byte 31 :            - JointDistance.J1 LW LB
// Byte 32 : REAL       - JointDistance.J2 HW HB
// Byte 33 :            - JointDistance.J2 HW LB
// Byte 34 :            - JointDistance.J2 LW HB
// Byte 35 :            - JointDistance.J2 LW LB
// Byte 36 : REAL       - JointDistance.J3 HW HB
// Byte 37 :            - JointDistance.J3 HW LB
// Byte 38 :            - JointDistance.J3 LW HB
// Byte 39 :            - JointDistance.J3 LW LB
// Byte 40 : REAL       - JointDistance.J4 HW HB
// Byte 41 :            - JointDistance.J4 HW LB
// Byte 42 :            - JointDistance.J4 LW HB
// Byte 43 :            - JointDistance.J4 LW LB
// Byte 44 : REAL       - JointDistance.J5 HW HB
// Byte 45 :            - JointDistance.J5 HW LB
// Byte 46 :            - JointDistance.J5 LW HB
// Byte 47 :            - JointDistance.J5 LW LB
// Byte 48 : REAL       - JointDistance.J6 HW HB
// Byte 49 :            - JointDistance.J6 HW LB
// Byte 50 :            - JointDistance.J6 LW HB
// Byte 51 :            - JointDistance.J6 LW LB
// Byte 52 : REAL       - JointDistance.E1 HW HB
// Byte 53 :            - JointDistance.E1 HW LB
// Byte 54 :            - JointDistance.E1 LW HB
// Byte 55 :            - JointDistance.E1 LW LB
// Byte 56 : BOOL       - Manipulation
// Byte 57 : BYTE       - Reserve
// Byte 58 : UINT       - Time HW HB
// Byte 59 :            - Time HW LB
// Byte 60 : REAL       - JointDistance.E2 HW HB
// Byte 61 :            - JointDistance.E2 HW LB
// Byte 62 :            - JointDistance.E2 LW HB
// Byte 63 :            - JointDistance.E2 LW LB
// Byte 64 : REAL       - JointDistance.E3 HW HB
// Byte 65 :            - JointDistance.E3 HW LB
// Byte 66 :            - JointDistance.E3 LW HB
// Byte 67 :            - JointDistance.E3 LW LB
// Byte 68 : REAL       - JointDistance.E4 HW HB
// Byte 69 :            - JointDistance.E4 HW LB
// Byte 70 :            - JointDistance.E4 LW HB
// Byte 71 :            - JointDistance.E4 LW LB
// Byte 72 : REAL       - JointDistance.E5 HW HB
// Byte 73 :            - JointDistance.E5 HW LB
// Byte 74 :            - JointDistance.E5 LW HB
// Byte 75 :            - JointDistance.E5 LW LB
// Byte 76 : REAL       - JointDistance.E6 HW HB
// Byte 77 :            - JointDistance.E6 HW LB
// Byte 78 :            - JointDistance.E6 LW HB
// Byte 79 :            - JointDistance.E6 LW LB

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.MoveAxesRelative;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  _command.EmitterID[0]              := _parCmd.EmitterID[0];
  _command.EmitterID[1]              := _parCmd.EmitterID[1];
  _command.EmitterID[2]              := _parCmd.EmitterID[2];
  _command.EmitterID[3]              := _parCmd.EmitterID[3];
  _command.ListenerID                := 0; {warning 'ToDo'}
  _command.Reserve                   := 0;
  _command.VelocityRate              := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate          := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate          := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate                  := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo                    := _parCmd.ToolNo;
  _command.BlendingMode              := _parCmd.BlendingMode;
  _command.BlendingParameter         := _parCmd.BlendingParameter;
  _command.JointDistance             := _parCmd.JointDistance;
  _command.Manipulation              := _parCmd.Manipulation;
  _command.MoveTime                  := TIME_TO_UINT(_parCmd.MoveTime);
  
  
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
  // add command.BlendingMode
  CreateCommandPayload.AddUsint(_command.BlendingMode);
  // add command.BlendingParameter[0]
  CreateCommandPayload.AddReal(_command.BlendingParameter[0]);
  // add command.BlendingParameter[1]
  CreateCommandPayload.AddReal(_command.BlendingParameter[1]);
  // add command.JointPosition.J1
  CreateCommandPayload.AddReal(_command.JointDistance.J1);
  // add command.JointPosition.J2
  CreateCommandPayload.AddReal(_command.JointDistance.J2);
  // add command.JointPosition.J3
  CreateCommandPayload.AddReal(_command.JointDistance.J3);
  // add command.JointPosition.J4
  CreateCommandPayload.AddReal(_command.JointDistance.J4);
  // add command.JointPosition.J5
  CreateCommandPayload.AddReal(_command.JointDistance.J5);
  // add command.JointPosition.J6
  CreateCommandPayload.AddReal(_command.JointDistance.J6);
  // add command.JointPosition.E1
  CreateCommandPayload.AddReal(_command.JointDistance.E1);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve2);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);
  // add command.JointPosition.E2
  CreateCommandPayload.AddReal(_command.JointDistance.E2);
  // add command.JointPosition.E3
  CreateCommandPayload.AddReal(_command.JointDistance.E3);
  // add command.JointPosition.E4
  CreateCommandPayload.AddReal(_command.JointDistance.E4);
  // add command.JointPosition.E5
  CreateCommandPayload.AddReal(_command.JointDistance.E5);
  // add command.JointPosition.E6
  CreateCommandPayload.AddReal(_command.JointDistance.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveAxesRelativeFB';

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
             // Reset Busy Flag
             Busy := FALSE;
             // Update results
             OutCmd.FollowID          := _response.OriginID;
             OutCmd.Progress          := _response.Progress;
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
// Table 6-305: Received CMD payload (RC to PLC) of "MoveAxesRelative"
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
// Byte 04 : USINT   - InvocationCounter
// Byte 05 : SINT    - Reserve
// Byte 06 : INT     - OriginID LW HB
// Byte 07 :         - OriginID LW LB
// Byte 08 : UINT    - Progress LW HB
// Byte 09 :         - Progress LW LB
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
  // Get Response.Progress
  _response.Progress := ResponseData.GetUint();

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

