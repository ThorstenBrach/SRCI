/// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
FUNCTION_BLOCK MC_SearchHardStopJFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SearchHardStopJFB                                       
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
  ParCmd             : SearchHardStopJParCmd;
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
  OutCmd             : SearchHardStopJOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : SearchHardStopJParCmd;
  /// command data to send
 _command            : SearchHardStopJSendData;
  /// response data received
 _response           : SearchHardStopJRecvData;      
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
// Table 6-412: Sent CMD payload (PLC to RC) of "SearchHardStopJ"
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
// Byte 04 : UINT  VelocityRate;
// Byte 05 :       VelocityRate;
// Byte 06 : UINT  AccelerationRate;
// Byte 07 :       AccelerationRate;
// Byte 08 : UINT  DecelerationRate;
// Byte 09 :       DecelerationRate;
// Byte 10 : UINT  JerkRate;
// Byte 11 :       JerkRate;
// Byte 12 : REAL  JointPosition.J1;
// Byte 13 :       JointPosition.J1;
// Byte 14 :       JointPosition.J1;
// Byte 15 :       JointPosition.J1;
// Byte 16 : REAL  JointPosition.J2;
// Byte 17 :       JointPosition.J2;
// Byte 18 :       JointPosition.J2;
// Byte 19 :       JointPosition.J2;
// Byte 20 : REAL  JointPosition.J3;
// Byte 21 :       JointPosition.J3;
// Byte 22 :       JointPosition.J3;
// Byte 23 :       JointPosition.J3;
// Byte 24 : REAL  JointPosition.J4;
// Byte 25 :       JointPosition.J4;
// Byte 26 :       JointPosition.J4;
// Byte 27 :       JointPosition.J4;
// Byte 28 : REAL  JointPosition.J5;
// Byte 29 :       JointPosition.J5;
// Byte 30 :       JointPosition.J5;
// Byte 31 :       JointPosition.J5;
// Byte 32 : REAL  JointPosition.J6;
// Byte 33 :       JointPosition.J6;
// Byte 34 :       JointPosition.J6;
// Byte 35 :       JointPosition.J6;
// Byte 36 : REAL  JointPosition.E1;
// Byte 37 :       JointPosition.E1;
// Byte 38 :       JointPosition.E1;
// Byte 39 :       JointPosition.E1;
// Byte 40 : USINT OriMode;
// Byte 41 : USINT DetectionMode;
// Byte 42 : BOOL  Manipulation;
// Byte 43 : BYTE  Reserved;
// Byte 44 : REAL  DetectionVector[0];
// Byte 45 :       DetectionVector[0];
// Byte 46 :       DetectionVector[0];
// Byte 47 :       DetectionVector[0];
// Byte 48 : REAL  DetectionVector[1];
// Byte 49 :       DetectionVector[1];
// Byte 50 :       DetectionVector[1];
// Byte 51 :       DetectionVector[1];
// Byte 52 : REAL  DetectionVector[2];
// Byte 53 :       DetectionVector[2];
// Byte 54 :       DetectionVector[2];
// Byte 55 :       DetectionVector[2];
// Byte 56 : REAL  DetectionVector[3];
// Byte 57 :       DetectionVector[3];
// Byte 58 :       DetectionVector[3];
// Byte 59 :       DetectionVector[3];
// Byte 60 : REAL  DetectionVector[4];
// Byte 61 :       DetectionVector[4];
// Byte 62 :       DetectionVector[4];
// Byte 63 :       DetectionVector[4];
// Byte 64 : REAL  DetectionVector[5];
// Byte 65 :       DetectionVector[5];
// Byte 66 :       DetectionVector[5];
// Byte 67 :       DetectionVector[5];
// Byte 68 : REAL  JointPosition.E2;
// Byte 69 :       JointPosition.E2;
// Byte 70 :       JointPosition.E2;
// Byte 71 :       JointPosition.E2;
// Byte 72 : REAL  JointPosition.E3;
// Byte 73 :       JointPosition.E3;
// Byte 74 :       JointPosition.E3;
// Byte 75 :       JointPosition.E3;
// Byte 76 : REAL  JointPosition.E4;
// Byte 77 :       JointPosition.E4;
// Byte 78 :       JointPosition.E4;
// Byte 79 :       JointPosition.E4;
// Byte 80 : REAL  JointPosition.E5;
// Byte 81 :       JointPosition.E5;
// Byte 82 :       JointPosition.E5;
// Byte 83 :       JointPosition.E5;
// Byte 84 : REAL  JointPosition.E6;
// Byte 85 :       JointPosition.E6;
// Byte 86 :       JointPosition.E6;
// Byte 87 :       JointPosition.E6;
// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.SearchHardstopJ;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.VelocityRate      := REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate  := REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate  := REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate          := REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JointPosition     := _parCmd.JointPosition;
  _command.OriMode           := 0;
  _command.DetectionMode     := _parCmd.DetectionMode;
  _command.Manipulation      := _parCmd.Manipulation;
  _command.Reserve           :=  0;
  _command.DetectionVector   := _parCmd.DetectionVector;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.VelocityRate
  CreateCommandPayload.AddUint(_command.VelocityRate);
  // add command.AccelerationRate
  CreateCommandPayload.AddUint(_command.AccelerationRate);
  // add command.DecelerationRate
  CreateCommandPayload.AddUint(_command.DecelerationRate);
  // add command.JerkRate
  CreateCommandPayload.AddUint(_command.JerkRate);
  // add command.JointPosition.J1
  CreateCommandPayload.AddReal(_command.JointPosition.J1);
  // add command.JointPosition.J2
  CreateCommandPayload.AddReal(_command.JointPosition.J2);
  // add command.JointPosition.J3
  CreateCommandPayload.AddReal(_command.JointPosition.J3);
  // add command.JointPosition.J4
  CreateCommandPayload.AddReal(_command.JointPosition.J4);
  // add command.JointPosition.J5
  CreateCommandPayload.AddReal(_command.JointPosition.J5);
  // add command.JointPosition.J6
  CreateCommandPayload.AddReal(_command.JointPosition.J6);
  // add command.JointPosition.E1
  CreateCommandPayload.AddReal(_command.JointPosition.E1);
  // add command.OriMode
  CreateCommandPayload.AddUsint(_command.OriMode);
  // add command.DetectionMode
  CreateCommandPayload.AddUsint(_command.DetectionMode);
  // add command.Manipulation
  CreateCommandPayload.AddBool(_command.Manipulation);
  // add command.Reserve
  CreateCommandPayload.AddByte(_command.Reserve);
  // add command.DetectionVector[0]
  CreateCommandPayload.AddReal(_command.DetectionVector[0]);
  // add command.DetectionVector[1]
  CreateCommandPayload.AddReal(_command.DetectionVector[1]);
  // add command.DetectionVector[2]
  CreateCommandPayload.AddReal(_command.DetectionVector[2]);
  // add command.DetectionVector[3]
  CreateCommandPayload.AddReal(_command.DetectionVector[3]);
  // add command.DetectionVector[4]
  CreateCommandPayload.AddReal(_command.DetectionVector[4]);
  // add command.DetectionVector[5]
  CreateCommandPayload.AddReal(_command.DetectionVector[5]);
  // add command.JointPosition.E2
  CreateCommandPayload.AddReal(_command.JointPosition.E2);
  // add command.JointPosition.E3
  CreateCommandPayload.AddReal(_command.JointPosition.E3);
  // add command.JointPosition.E4
  CreateCommandPayload.AddReal(_command.JointPosition.E4);
  // add command.JointPosition.E5
  CreateCommandPayload.AddReal(_command.JointPosition.E5);
  // add command.JointPosition.E6
  CreateCommandPayload.AddReal(_command.JointPosition.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SearchHardStopJFB';

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
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.InClamping        := _response.InClamping;
             OutCmd.Progress          := _response.Progress;
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
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-413: Received CMD payload (RC to PLC) of "SearchHardStopJ"
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
  ResponseData : RobotLibraryRecvDataFB;
END_VAR

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.Progress
  _response.Progress := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance := ResponseData.GetReal();
  // Get Response.InClamping
  _response.InClamping := ResponseData.GetBool();

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

