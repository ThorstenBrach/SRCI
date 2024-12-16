/// Set active sequence
FUNCTION_BLOCK MC_SetSequenceFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetSequenceFB                                       
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
  ParCmd          : SetSequenceParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command results
  OutCmd          : SetSequenceOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : SetSequenceParCmd;
  /// command data to send
 _command         : SetSequenceSendData;
  /// response data received
 _response        : SetSequenceRecvData;      
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
  CheckParameterChanged := ( MemCmp(ADR(ParCmd), ADR(_parCmd), SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
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
// Table 6-92: Sent CMD payload (PLC to RC) of "SetSequence"
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
 // Byte 12 : USINT ToolNo;
 // Byte 13 : USINT FrameNo;
 // Byte 14 : REAL  Position.X;
 // Byte 15 :       Position.X;
 // Byte 16 :       Position.X;
 // Byte 17 :       Position.X;
 // Byte 18 : REAL  Position.Y;
 // Byte 19 :       Position.Y;
 // Byte 20 :       Position.Y;
 // Byte 21 :       Position.Y;
 // Byte 22 : REAL  Position.Z;
 // Byte 23 :       Position.Z;
 // Byte 24 :       Position.Z;
 // Byte 25 :       Position.Z;
 // Byte 26 : REAL  Position.RX;
 // Byte 27 :       Position.RX;
 // Byte 28 :       Position.RX;
 // Byte 29 :       Position.RX;
 // Byte 30 : REAL  Position.RY;
 // Byte 31 :       Position.RY;
 // Byte 32 :       Position.RY;
 // Byte 33 :       Position.RY;
 // Byte 34 : REAL  Position.RZ;
 // Byte 35 :       Position.RZ;
 // Byte 36 :       Position.RZ;
 // Byte 37 :       Position.RZ;
 // Byte 38 : BYTE  - - - - - W E S;
 // Byte 39 : BYTE  Reserved;
 // Byte 40 : BYTE  Position.TurnNumber[0];
 // Byte 41 : BYTE  Position.TurnNumber[1];
 // Byte 42 : BYTE  Position.TurnNumber[2];
 // Byte 43 : BYTE  Position.TurnNumber[3];
 // Byte 44 : REAL  Position.E1;
 // Byte 45 :       Position.E1;
 // Byte 46 :       Position.E1;
 // Byte 47 :       Position.E1;
 // Byte 48 : USINT OriMode;
 // Byte 49 : USINT DetectionMode;
 // Byte 50 : BOOL  Manipulation;
 // Byte 51 : BYTE  Reserved;
 // Byte 52 : REAL  DetectionVector[0];
 // Byte 53 :       DetectionVector[0];
 // Byte 54 :       DetectionVector[0];
 // Byte 55 :       DetectionVector[0];
 // Byte 56 : REAL  DetectionVector[1];
 // Byte 57 :       DetectionVector[1];
 // Byte 58 :       DetectionVector[1];
 // Byte 59 :       DetectionVector[1];
 // Byte 60 : REAL  DetectionVector[2];
 // Byte 61 :       DetectionVector[2];
 // Byte 62 :       DetectionVector[2];
 // Byte 63 :       DetectionVector[2];
 // Byte 64 : REAL  DetectionVector[3];
 // Byte 65 :       DetectionVector[3];
 // Byte 66 :       DetectionVector[3];
 // Byte 67 :       DetectionVector[3];
 // Byte 68 : REAL  DetectionVector[4];
 // Byte 69 :       DetectionVector[4];
 // Byte 70 :       DetectionVector[4];
 // Byte 71 :       DetectionVector[4];
 // Byte 72 : REAL  DetectionVector[5];
 // Byte 73 :       DetectionVector[5];
 // Byte 74 :       DetectionVector[5];
 // Byte 75 :       DetectionVector[5];
 // Byte 76 : BYTE  ConfigMode[0];
 // Byte 77 : BYTE  ConfigMode[1];
 // Byte 78 : USINT TurnMode;
 // Byte 79 : REAL  Position.E2;
 // Byte 80 :       Position.E2;
 // Byte 81 :       Position.E2;
 // Byte 82 :       Position.E2;
 // Byte 83 : REAL  Position.E3;
 // Byte 84 :       Position.E3;
 // Byte 85 :       Position.E3;
 // Byte 86 :       Position.E3;
 // Byte 87 : REAL  Position.E4;
 // Byte 88 :       Position.E4;
 // Byte 89 :       Position.E4;
 // Byte 90 :       Position.E4;
 // Byte 91 : REAL  Position.E5;
 // Byte 92 :       Position.E5;
 // Byte 93 :       Position.E5;
 // Byte 94 :       Position.E5;
 // Byte 95 : REAL  Position.E6;
 // Byte 96 :       Position.E6;
 // Byte 97 :       Position.E6;
 // Byte 98 :       Position.E6;

  // set command parameter 
  _command.CmdTyp         :=  CmdType.SetSequence;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.TargetSequence := _parCmd.TargetSequence;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.TargetSequence
  CreateCommandPayload.AddUsint(_command.TargetSequence);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SetSequenceFB';
  
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
           MemSet(ADR(OutCmd),0,SIZEOF(OutCmd));         
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
             Busy:= FALSE;
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
// Table 6-93: Received CMD payload (RC to PLC) of "SetSequence"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT   - ParSeq | State     
// Byte 01 : SINT    - AlarmMessageSeverity    
// Byte 02 : UINT    - AlarmMessageCode HB
// Byte 03 :         - AlarmMessageCode LB
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

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

