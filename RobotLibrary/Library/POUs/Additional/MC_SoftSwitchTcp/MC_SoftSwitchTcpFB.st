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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.SoftSwitchTCP;
  
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
  IF (SIZEOF(ParCmd) = 0) OR (_stepCmd = 0)
  THEN 
    RETURN;
  END_IF
  
  // compare memory 
  _parameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCmd), pData2 := ADR(_parCmd), DataLen := SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
  // check parameter valid ?
  _parameterValid   := CheckParameterValid( AxesGroup := AxesGroup );
  
  IF ((  _parameterChanged        )  AND 
      (  _parameterValid          )) OR
      (  _parameterUpdateInternal )  
  THEN  
    // reset internal flag for send parameter update
   _parameterUpdateInternal := FALSE;
    // update internal copy of parameters 
   _parCmd := ParCmd;
    // inc parameter sequence
   _command.ParSeq := _command.ParSeq + 1;
    // update command data  
    CommandData := CreateCommandPayload(AxesGroup := AxesGroup); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx       : DINT;  
END_VAR

  CheckParameterValid := TRUE;
  
  // Check AbortingMode valid ? 
  IF (( AbortingMode <> AbortingModeEnum.BUFFER ) AND
      ( AbortingMode <> AbortingModeEnum.ABORT  ))  
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_ABORTINGMODE_INVALID;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter AbortingMode = {1}',
                            Para1       := ABORTING_MODE_TO_STRING(AbortingMode));
    RETURN;                          
  END_IF
  
  // Check SequenceFlag valid ? 
  IF (( SequenceFlag <> SequenceFlagEnum.PRIMARY_SEQUENCE   ) AND
      ( SequenceFlag <> SequenceFlagEnum.SECONDARY_SEQUENCE ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_SEQFLAG_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter SequenceFlag = {1}',
                            Para1       := SEQUENCE_FLAG_TO_STRING(SequenceFlag));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ReferenceType valid ? 
  IF (( ParCmd.ReferenceType <> ReferenceType.TOOL  ) AND  
      ( ParCmd.ReferenceType <> ReferenceType.FRAME ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ReferenceType = {1}',
                            Para1       :=  REFERENCE_TYPE_TO_STRING(ParCmd.ReferenceType));
    RETURN;                          
  END_IF
  
  // Check ParCmd.ReferenceNo valid ? 
  IF (( ParCmd.ReferenceNo < 0   ) OR  
      ( ParCmd.ReferenceNo > 254 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ReferenceNo = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.ReferenceNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.CompliantAxes valid ?
  IF (( ParCmd.CompliantAxes < 0  ) OR  
      ( ParCmd.CompliantAxes > 63 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.CompliantAxes = {1}',
                            Para1       :=  BYTE_TO_STRING_BIN(ParCmd.CompliantAxes));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitMode valid ? 
  IF (( ParCmd.LimitMode <> LimitMode.NO_LIMIT_DEFINED ) AND  
      ( ParCmd.LimitMode <> LimitMode.LIMIT_DEFINED    ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.LimitMode = {1}',
                            Para1       :=  LIMIT_MODE_TO_STRING(ParCmd.LimitMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ResistanceForceMode valid ? 
  IF (( ParCmd.ResistanceForceMode <> ResistanceForceMode.RESISTANCE_FORCE_TCP  ) AND  
      ( ParCmd.ResistanceForceMode <> ResistanceForceMode.RESISTANCE_FORCE_AXIS ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ResistanceForceMode = {1}',
                            Para1       :=  RESISTANT_FORCE_MODE_TO_STRING(ParCmd.ResistanceForceMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ResistanceForceTCP valid ? 
  IF (( SysDepIsValidReal(ParCmd.ResistanceForceTCP) = FALSE ) OR
      (                   ParCmd.ResistanceForceTCP  <     0 ) OR
      (                   ParCmd.ResistanceForceTCP  >   200 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ResistanceForceTCP = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ResistanceForceTCP));
    RETURN;                          
  END_IF
  
  
  FOR _idx := 0 TO 5
  DO
    // Check ParCmd.ResistanceForceAxis[x] valid ? 
    IF (( SysDepIsValidReal(ParCmd.ResistanceForceAxis[_idx]) = FALSE ) OR
        (                   ParCmd.ResistanceForceAxis[_idx]  <     0 ) OR
        (                   ParCmd.ResistanceForceAxis[_idx]  >   200 ))
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.ResistanceForceAxis[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.ResistanceForceAxis[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  END_FOR
  
  
  FOR _idx := 0 TO 5
  DO
    // Check ParCmd.VectorData[x] valid ? 
    IF ( SysDepIsValidReal(ParCmd.VectorData[_idx]) = FALSE )
    THEN
      // Parameter not valid
      CheckParameterValid := FALSE;
      // Set error
      ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
      
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.ERROR,
                              MessageCode := ErrorID,
                              MessageText := 'Invalid Parameter ParCmd.VectorData[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.VectorData[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  END_FOR

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
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
  _command.ResistanceForceTCP        := REAL_TO_PERCENT_INT (_parCmd.ResistanceForceTCP     , IsOptional := TRUE );
  _command.ResistanceForceMode       :=_parCmd.ResistanceForceMode;
  _command.ResistanceForceAxis[0]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[0] , IsOptional := TRUE );
  _command.ResistanceForceAxis[1]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[1] , IsOptional := TRUE );
  _command.ResistanceForceAxis[2]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[2] , IsOptional := TRUE );
  _command.ResistanceForceAxis[3]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[3] , IsOptional := TRUE );
  _command.ResistanceForceAxis[4]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[4] , IsOptional := TRUE );
  _command.ResistanceForceAxis[5]    := REAL_TO_PERCENT_UINT(_parCmd.ResistanceForceAxis[5] , IsOptional := TRUE );
  _command.VectorData                :=_parCmd.VectorData;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
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
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the following parameter(s) :');
    
  // Create log entry for LimitMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitMode = {1}',
                          Para1       :=  LIMIT_MODE_TO_STRING(_command.LimitMode));
  
  // Create log entry for CompliantAxes
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CompliantAxes = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.CompliantAxes));
  
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_command.ReferenceType));
  
  // Create log entry for ReferenceNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ReferenceNo));
  
  // Create log entry for ResistanceForceTCP
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceTCP = {1}',
                          Para1       :=  INT_TO_STRING(_command.ResistanceForceTCP));
  
  // Create log entry for ResistanceForceAxis[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[0] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[0]));
  
  // Create log entry for ResistanceForceAxis[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[1] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[1]));
  
  // Create log entry for ResistanceForceAxis[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[2] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[2]));
  
  // Create log entry for ResistanceForceAxis[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[3] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[3]));
  
  // Create log entry for ResistanceForceAxis[4]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[4] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[4]));
  
  // Create log entry for ResistanceForceAxis[5]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceAxis[5] = {1}',
                          Para1       :=  UINT_TO_STRING(_command.ResistanceForceAxis[5]));
  
  // Create log entry for VectorData[0]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[0] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[0]));
                          
  // Create log entry for VectorData[1]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[1] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[1]));
  
  // Create log entry for VectorData[2]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[2] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[2]));
  
  // Create log entry for VectorData[3]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[3] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[3]));
  
  // Create log entry for VectorData[4]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[4] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[4]));
  
  // Create log entry for VectorData[5]
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.VectorData[5] = {1}',
                          Para1       :=  REAL_TO_STRING(_command.VectorData[5]));
                          
  // Create log entry for ResistanceForceMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ResistanceForceMode = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ResistanceForceMode));

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

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _execute_R.Q ) AND ( NOT Error)  
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
             CommandData := CreateCommandPayload(AxesGroup := AxesGroup);
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
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
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

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get Response.SoftMovement
  _response.SoftMovement := ResponseData.GetBool();
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
                          
  // Create log entry for SoftMovement
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.SoftMovement = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.SoftMovement));

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

