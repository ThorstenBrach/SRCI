/// Activate superimposed motion of TCP to defined motion
FUNCTION_BLOCK MC_MoveSuperImposedFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedFB                                       
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
  ParCmd            : MoveSuperImposedParCmd;
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// The command takes control of the motion of the according axis group
  Active            : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command outputs
  OutCmd            : MoveSuperImposedOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : MoveSuperImposedParCmd;
  /// command data to send
 _command            : MoveSuperImposedSendData;
  /// response data received
 _response           : MoveSuperImposedRecvData;      
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
// Table 6-464: Sent CMD payload (PLC to RC) of "MoveSuperImposed"
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
// Byte 04 : SINT  EmitterID[0];
// Byte 05 : SINT  EmitterID[1];
// Byte 06 : SINT  EmitterID[2];
// Byte 07 : SINT  EmitterID[3];
// Byte 08 : SINT  ListenerID;
// Byte 09 : BYTE  Reserved;
// Byte 10 : UINT  VelocityRate;
// Byte 11 :       VelocityRate;
// Byte 12 : UINT  AccelerationRate;
// Byte 13 :       AccelerationRate;
// Byte 14 : UINT  DecelerationRate;
// Byte 15 :       DecelerationRate;
// Byte 16 : UINT  JerkRate;
// Byte 17 :       JerkRate;
// Byte 18 : USINT ToolNo;
// Byte 19 : USINT FrameNo;
// Byte 20 : REAL  Offset.X;
// Byte 21 :       Offset.X;
// Byte 22 :       Offset.X;
// Byte 23 :       Offset.X;
// Byte 24 : REAL  Offset.Y;
// Byte 25 :       Offset.Y;
// Byte 26 :       Offset.Y;
// Byte 27 :       Offset.Y;
// Byte 28 : REAL  Offset.Z;
// Byte 29 :       Offset.Z;
// Byte 30 :       Offset.Z;
// Byte 31 :       Offset.Z;
// Byte 32 : REAL  Offset.RX;
// Byte 33 :       Offset.RX;
// Byte 34 :       Offset.RX;
// Byte 35 :       Offset.RX;
// Byte 36 : REAL  Offset.RY;
// Byte 37 :       Offset.RY;
// Byte 38 :       Offset.RY;
// Byte 39 :       Offset.RY;
// Byte 40 : REAL  Offset.RZ;
// Byte 41 :       Offset.RZ;
// Byte 42 :       Offset.RZ;
// Byte 43 :       Offset.RZ;
// Byte 44 : BYTE  - - - - - W E S;
// Byte 45 : BYTE  Reserved;
// Byte 46 : BYTE  Offset.TurnNumber[0];
// Byte 47 : BYTE  Offset.TurnNumber[1];
// Byte 48 : BYTE  Offset.TurnNumber[2];
// Byte 49 : BYTE  Offset.TurnNumber[3];
// Byte 50 : REAL  Offset.E1;
// Byte 51 :       Offset.E1;
// Byte 52 :       Offset.E1;
// Byte 53 :       Offset.E1;
// Byte 54 : USINT ReferenceType;
// Byte 55 : BYTE  Reserved;
// Byte 56 : REAL  Offset.E2;
// Byte 57 :       Offset.E2;
// Byte 58 :       Offset.E2;
// Byte 59 :       Offset.E2;
// Byte 60 : REAL  Offset.E3;
// Byte 61 :       Offset.E3;
// Byte 62 :       Offset.E3;
// Byte 63 :       Offset.E3;
// Byte 64 : REAL  Offset.E4;
// Byte 65 :       Offset.E4;
// Byte 66 :       Offset.E4;
// Byte 67 :       Offset.E4;
// Byte 68 : REAL  Offset.E5;
// Byte 69 :       Offset.E5;
// Byte 70 :       Offset.E5;
// Byte 71 :       Offset.E5;
// Byte 72 : REAL  Offset.E6;
// Byte 73 :       Offset.E6;
// Byte 74 :       Offset.E6;
// Byte 75 :       Offset.E6;
// --------------------------

  // set command parameter 
  _command.CmdTyp               :=  CmdType.MoveSuperImposed;
  _command.ExecMode             :=  ExecMode;
  _command.ParSeq               := _command.ParSeq;
  _command.Priority             :=  Priority;
  _command.EmitterID            := _parCmd.EmitterID;
  _command.ListenerID           := _parCmd.ListenerID;
  _command.Reserve              := 0;
  _command.VelocityDiffRate     := REAL_TO_UINT(_parCmd.VelocityDiffRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationDiffRate := REAL_TO_UINT(_parCmd.AccelerationDiffRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationDiffRate := REAL_TO_UINT(_parCmd.DecelerationDiffRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkDiffRate         := REAL_TO_UINT(_parCmd.JerkDiffRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ToolNo               := _parCmd.ToolNo;
  _command.FrameNo              := _parCmd.FrameNo;
  _command.Offset               := _parCmd.Offset;
  _command.ReferenceType        := _parCmd.ReferenceType;
  _command.Reserve2             := 0;
  
  
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
  // add command.VelocityDiffRate
  CreateCommandPayload.AddUint(_command.VelocityDiffRate);
  // add command.AccelerationDiffRate
  CreateCommandPayload.AddUint(_command.AccelerationDiffRate);
  // add command.DecelerationDiffRate
  CreateCommandPayload.AddUint(_command.DecelerationDiffRate);
  // add command.JerkDiffRate
  CreateCommandPayload.AddUint(_command.JerkDiffRate);
  // add command.ToolNo
  CreateCommandPayload.AddUsint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.Offset.X
  CreateCommandPayload.AddReal(_command.Offset.X);
  // add command.Offset.Y
  CreateCommandPayload.AddReal(_command.Offset.Y);
  // add command.Offset.Z
  CreateCommandPayload.AddReal(_command.Offset.Z);
  // add command.Offset.Rx
  CreateCommandPayload.AddReal(_command.Offset.Rx);
  // add command.Offset.Ry
  CreateCommandPayload.AddReal(_command.Offset.Ry);
  // add command.Offset.Rz
  CreateCommandPayload.AddReal(_command.Offset.Rz);
  // add command.Offset.Config
  CreateCommandPayload.AddArmConfig(_command.Offset.Config);
  // add command.Offset.TurnNumber
  CreateCommandPayload.AddTurnNumber(_command.Offset.TurnNumber);
  // add command.Offset.E1
  CreateCommandPayload.AddReal(_command.Offset.E1);
  // add command.ReferenceType
  CreateCommandPayload.AddUsint(_command.ReferenceType);
  // add command.Reserve2
  CreateCommandPayload.AddByte(_command.Reserve2);
  // add command.Offset.E2
  CreateCommandPayload.AddReal(_command.Offset.E2);
  // add command.Offset.E3
  CreateCommandPayload.AddReal(_command.Offset.E3);
  // add command.Offset.E4
  CreateCommandPayload.AddReal(_command.Offset.E4);
  // add command.Offset.E5
  CreateCommandPayload.AddReal(_command.Offset.E5);
  // add command.Offset.E6
  CreateCommandPayload.AddReal(_command.Offset.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MoveSuperImposedFB';
  
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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED : CommandBuffered   := TRUE;
             CmdMessageState.ACTIVE   : Active            := TRUE;
             CmdMessageState.DONE     : Done              := TRUE;
                                        ParameterAccepted := TRUE;
             CmdMessageState.ERROR    : Error             := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.OriginID          := _response.OriginID;
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
// Table 6-465: Received CMD payload (RC to PLC) of "MoveSuperImposed"
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
  ParameterAccepted  := FALSE;

END_METHOD
