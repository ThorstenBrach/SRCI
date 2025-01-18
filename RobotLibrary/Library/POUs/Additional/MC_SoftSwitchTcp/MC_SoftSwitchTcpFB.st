/// Push robot: Robot calculates opposite vector and moves slowly in that direction
FUNCTION_BLOCK MC_SoftSwitchTcpFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SoftSwitchTcpFB                                       
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
  /// Command parameter 
  ParCmd             : SoftSwitchTcpParCmd;  
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command "SoftSwitchTCP" takes control of the according axis group.
  Active             : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// command results
  OutCmd             : SoftSwitchTcpOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : SoftSwitchTcpParCmd;
  /// command data to send
 _command            : SoftSwitchTcpSendData;
  /// response data received
 _response           : SoftSwitchTcpRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.SoftSwitchTCP;
  
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
// Table 6-748: Sent CMD payload (PLC to RC) of "SoftSwitchTCP"
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
// Byte 04 : USINT  - LimitMode
// Byte 05 : BYTE   - CompliantAxes
// Byte 06 : BOOL   - ReferenceType
// Byte 07 : USINT  - ReferenceNo
// Byte 08 : INT    - ResistanceForceTCP HW HB
// Byte 09 :        - ResistanceForceTCP HW LB
// Byte 10 : UINT   - ResistanceForceAxis[0] HW HB
// Byte 11 :        - ResistanceForceAxis[0] HW LB
// Byte 12 : UINT   - ResistanceForceAxis[1] HW HB
// Byte 13 :        - ResistanceForceAxis[1] HW LB
// Byte 14 : UINT   - ResistanceForceAxis[2] HW HB
// Byte 15 :        - ResistanceForceAxis[2] HW LB
// Byte 16 : UINT   - ResistanceForceAxis[3] HW HB
// Byte 17 :        - ResistanceForceAxis[3] HW LB
// Byte 18 : UINT   - ResistanceForceAxis[4] HW HB
// Byte 19 :        - ResistanceForceAxis[4] HW LB
// Byte 20 : UINT   - ResistanceForceAxis[5] HW HB
// Byte 21 :        - ResistanceForceAxis[5] HW LB
// Byte 22 : REAL   - VectorData[0] HW HB
// Byte 23 :        - VectorData[0] HW LB
// Byte 24 :        - VectorData[0] LW HB
// Byte 25 :        - VectorData[0] LW LB
// Byte 26 : REAL   - VectorData[1] HW HB
// Byte 27 :        - VectorData[1] HW LB
// Byte 28 :        - VectorData[1] LW HB
// Byte 29 :        - VectorData[1] LW LB
// Byte 30 : REAL   - VectorData[2] HW HB
// Byte 31 :        - VectorData[2] HW LB
// Byte 32 :        - VectorData[2] LW HB
// Byte 33 :        - VectorData[2] LW LB
// Byte 34 : REAL   - VectorData[3] HW HB
// Byte 35 :        - VectorData[3] HW LB
// Byte 36 :        - VectorData[3] LW HB
// Byte 37 :        - VectorData[3] LW LB
// Byte 38 : REAL   - VectorData[4] HW HB
// Byte 39 :        - VectorData[4] HW LB
// Byte 40 :        - VectorData[4] LW HB
// Byte 41 :        - VectorData[4] LW LB
// Byte 42 : REAL   - VectorData[5] HW HB
// Byte 43 :        - VectorData[5] HW LB
// Byte 44 :        - VectorData[5] LW HB
// Byte 45 :        - VectorData[5] LW LB
// Byte 46 : USINT  - ResistanceForceMode

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.ShiftPosition;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  
  _command.LimitMode                 := _parCmd.LimitMode;
  _command.CompliantAxes             := _parCmd.CompliantAxes;       
  _command.ReferenceType             := _parCmd.ReferenceType;
  _command.ReferenceNo               := _parCmd.ReferenceNo;
  _command.ResistanceForceTCP        := REAL_TO_INT (_parCmd.ResistanceForceTCP     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceMode       := _parCmd.ResistanceForceMode;
  _command.ResistanceForceAxis[0]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[0] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceAxis[1]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[1] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceAxis[2]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[2] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceAxis[3]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[3] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceAxis[4]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[4] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.ResistanceForceAxis[5]    := REAL_TO_UINT(_parCmd.ResistanceForceAxis[5] * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.VectorData                := _parCmd.VectorData;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.LimitMode
  CreateCommandPayload.AddUsint(_command.LimitMode);
  // add command.CompliantAxes
  CreateCommandPayload.AddByte(_command.CompliantAxes);
  // add command.ReferenceType
  CreateCommandPayload.AddBool(_command.ReferenceType.0);
  // add command.ReferenceNo
  CreateCommandPayload.AddUsint(_command.ReferenceNo);
  // add command.ResistanceForceTCP
  CreateCommandPayload.AddInt(_command.ResistanceForceTCP);
  // add command.ResistanceForceAxis[0]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[0]);
  // add command.ResistanceForceAxis[1]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[1]);
  // add command.ResistanceForceAxis[2]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[2]);
  // add command.ResistanceForceAxis[3]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[3]);
  // add command.ResistanceForceAxis[4]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[4]);
  // add command.ResistanceForceAxis[5]
  CreateCommandPayload.AddUint(_command.ResistanceForceAxis[5]);
  // add command.VectorData[0]
  CreateCommandPayload.AddReal(_command.VectorData[0]);
  // add command.VectorData[1]
  CreateCommandPayload.AddReal(_command.VectorData[1]);
  // add command.VectorData[2]
  CreateCommandPayload.AddReal(_command.VectorData[2]);
  // add command.VectorData[3]
  CreateCommandPayload.AddReal(_command.VectorData[3]);
  // add command.VectorData[4]
  CreateCommandPayload.AddReal(_command.VectorData[4]);
  // add command.VectorData[5]
  CreateCommandPayload.AddReal(_command.VectorData[5]);
  // add command.ResistanceForceMode
  CreateCommandPayload.AddUsint(_command.ResistanceForceMode);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_SoftSwitchTcpFB';

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
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.SoftMovement := _response.SoftMovement;
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
// Table 6-749: Received CMD payload (RC to PLC) of "SoftSwitchTCP"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04  : BOOL - SoftMovement
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
  
  // Get Response.SoftMovement
  _response.SoftMovement := ResponseData.GetBool();

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

