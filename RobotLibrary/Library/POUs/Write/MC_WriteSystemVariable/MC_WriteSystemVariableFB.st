/// Write specific parameter of the robot
FUNCTION_BLOCK MC_WriteSystemVariableFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteSystemVariableFB                                       
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
  /// Processing Mode
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
  /// command parameter 
  ParCmd             : WriteSystemVariableParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// TRUE, when parameters were overwritten but not activated on RC until a restart of the RC
  RestartRequested   : BOOL;
  /// command outputs
  OutCmd             : WriteSystemVariableOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteSystemVariableParCmd;
  /// command data to send
 _command            : WriteSystemVariableSendData;
  /// response data received
 _response           : WriteSystemVariableRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD INTERNAL CheckAddParameter : BOOL
VAR_INPUT
  /// Payload pointer
  PayloadPtr : UDINT;
END_VAR
VAR
  /// Payload as byte array
  Payload    : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Null Byte array 
  Null       : ARRAY [1..SIZEOF(_command)] OF BYTE;
  /// Data length to compare
  DataLen    : UDINT;
END_VAR

  // Payload pointer must be decreased by one byte, because ADR(Payload) is already one byte !
  PayloadPtr := LIMIT (0, PayloadPtr - 1, SIZEOF(Payload) -1);
  // Convert command struct to payload array
  SysDepMemCpy( pDest := ADR(Payload), pSrc := ADR(_command), DataLen := SIZEOF(_command));
  // Calculate the data length to compare - at least one byte must be compared !
  DataLen := LIMIT(1, SIZEOF(Payload) - PayloadPtr, SIZEOF(Payload)); 
  // Compare Payload-Array with Null-Byte-Array
  CheckAddParameter := SysDepMemCmp( pData1 := ADR(Payload) + PayloadPtr , pData2 := ADR(Null), DataLen := DataLen) <>  RobotLibraryConstants.OK ;

END_METHOD

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.WriteSystemVariable;
  
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
 _idx : DINT;
END_VAR

  CheckParameterValid := TRUE;
  
  // Check ProcessingModea valid ? 
  IF (( ProcessingMode <> ProcessingModeEnum.BUFFERED           ) AND
      ( ProcessingMode <> ProcessingModeEnum.ABORTING           ) AND
      ( ProcessingMode <> ProcessingModeEnum.PARALLEL           ) AND
      ( ProcessingMode <> ProcessingModeEnum.CONTINUOUS         ) AND
      ( ProcessingMode <> ProcessingModeEnum.DEACTIVATE         ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_ONCE       ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_CONTINUOUS ) AND
      ( ProcessingMode <> ProcessingModeEnum.TRIGGER_MULTIPLE   ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_PROCESSINGMODE_NOT_ALLOWED;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ProcessingMode = {1}',
                            Para1       := PROCESSING_MODE_TO_STRING(ProcessingMode));
    RETURN;
  END_IF
  
  
  // Check SequenceFlag valid ? 
  IF (( SequenceFlag <> SequenceFlagEnum.NO_SEQUENCE        ) AND
      ( SequenceFlag <> SequenceFlagEnum.PRIMARY_SEQUENCE   ) AND
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
  
  
  // Check ParCmd.RCParameter valid ? 
  IF (( ParCmd.RCParameter <> FALSE ) AND
      ( ParCmd.RCParameter <> TRUE  ))       
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
                            MessageText := 'Invalid Parameter ParCmd.RCParameter = {1}',
                            Para1       := BOOL_TO_STRING(ParCmd.RCParameter));
    RETURN;
  END_IF
  
  
  FOR _idx := 0 TO 7
  DO
    // Check ParCmd.RCParameter[_idx] valid ? 
    IF (( ParCmd.ParameterID[_idx] < 0            ) AND
        ( ParCmd.ParameterID[_idx] > 16#FFFF_FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.ParameterID[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.ParameterID[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  END_FOR
  
  
  FOR _idx := 0 TO 7
  DO
    // Check ParCmd.SubParameterID[_idx] valid ? 
    IF (( ParCmd.SubParameterID[_idx] < 0            ) AND
        ( ParCmd.SubParameterID[_idx] > 16#FFFF_FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.SubParameterID[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.SubParameterID[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  END_FOR
  
  
  FOR _idx := 0 TO 7
  DO
    // Check ParCmd.DataType[_idx] valid ? 
    IF (( ParCmd.DataType[_idx] <> DataType.TYPE_BOOL       ) AND
        ( ParCmd.DataType[_idx] <> DataType.TYPE_BYTE       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_WORD       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_DWORD      ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_SINT       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_USINT      ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_INT        ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_UINT       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_DINT       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_UDINT      ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_REAL       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_CHAR       ) AND       
        ( ParCmd.DataType[_idx] <> DataType.TYPE_CHAR_ARRAY ))       
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
                              MessageText := 'Invalid Parameter ParCmd.DataType[{2}] = {1}',
                              Para1       := DATA_TYPE_TO_STRING(ParCmd.DataType[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  END_FOR
  
  
  FOR _idx := 0 TO 3
  DO
    // Check ParCmd.Data_0[_idx] valid ? 
    IF (( ParCmd.Data_0[_idx] < 0       ) AND
        ( ParCmd.Data_0[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_0[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_0[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  
    
    // Check ParCmd.Data_1[_idx] valid ? 
    IF (( ParCmd.Data_1[_idx] < 0       ) AND
        ( ParCmd.Data_1[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_1[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_1[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  
  
    // Check ParCmd.Data_2[_idx] valid ? 
    IF (( ParCmd.Data_2[_idx] < 0       ) AND
        ( ParCmd.Data_2[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_2[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_2[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  
    
    // Check ParCmd.Data_3[_idx] valid ? 
    IF (( ParCmd.Data_3[_idx] < 0       ) AND
        ( ParCmd.Data_3[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_3[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_3[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
    
    
    // Check ParCmd.Data_4[_idx] valid ? 
    IF (( ParCmd.Data_4[_idx] < 0       ) AND
        ( ParCmd.Data_4[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_4[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_4[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
    
    
    // Check ParCmd.Data_5[_idx] valid ? 
    IF (( ParCmd.Data_5[_idx] < 0       ) AND
        ( ParCmd.Data_5[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_5[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_5[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
    
    
    // Check ParCmd.Data_6[_idx] valid ? 
    IF (( ParCmd.Data_6[_idx] < 0       ) AND
        ( ParCmd.Data_6[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_6[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_6[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
    
    
    // Check ParCmd.Data_7[_idx] valid ? 
    IF (( ParCmd.Data_7[_idx] < 0       ) AND
        ( ParCmd.Data_7[_idx] > 16#FFFF ))       
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
                              MessageText := 'Invalid Parameter ParCmd.Data_7[{2}] = {1}',
                              Para1       := UINT_TO_STRING(ParCmd.Data_7[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                        
      RETURN;
    END_IF
  END_FOR
  
  
  // Check ParCmd.ListenerID valid ? 
  IF (( ParCmd.ListenerID < 0   ) OR
      ( ParCmd.ListenerID > 127 ))      
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
                            MessageText := 'Invalid Parameter ParCmd.ListenerID = {1}',
                            Para1       := SINT_TO_STRING(ParCmd.ListenerID));
    RETURN;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx          : DINT;
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-626: Sent CMD payload (PLC to RC) of "WriteSystemVariable"
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
// Byte 04 : SINT EmitterID[0]
// Byte 05 : SINT EmitterID[1]
// Byte 06 : SINT EmitterID[2]
// Byte 07 : SINT EmitterID[3]
// Byte 08 : SINT ListenerID
// Byte 09 : BYTE Reserved
// Byte 10 : UINT ParameterID[0]
// Byte 11 : 
// Byte 12 : UINT ParameterID[1]
// Byte 13 : 
// Byte 14 : UINT ParameterID[2]
// Byte 15 : 
// Byte 16 : UINT ParameterID[3]
// Byte 17 : 
// Byte 18 : UINT ParameterID[4]
// Byte 19 : 
// Byte 20 : UINT ParameterID[5]
// Byte 21 : 
// Byte 22 : UINT ParameterID[6]
// Byte 23 : 
// Byte 24 : UINT ParameterID[7]
// Byte 25 : 
// Byte 26 : USINT SubParameterID[0]
// Byte 27 : USINT SubParameterID[1]
// Byte 28 : USINT SubParameterID[2]
// Byte 29 : USINT SubParameterID[3]
// Byte 30 : USINT SubParameterID[4]
// Byte 31 : USINT SubParameterID[5]
// Byte 32 : USINT SubParameterID[6]
// Byte 33 : USINT SubParameterID[7]
// Byte 34 : USINT DataType[0]
// Byte 35 : USINT DataType[1]
// Byte 36 : USINT DataType[2]
// Byte 37 : USINT DataType[3]
// Byte 38 : USINT DataType[4]
// Byte 39 : USINT DataType[5]
// Byte 40 : USINT DataType[6]
// Byte 41 : USINT DataType[7]
// Byte 42 : BYTE Data_0[0]
// Byte 43 : BYTE Data_0[1]
// Byte 44 : BYTE Data_0[2]
// Byte 45 : BYTE Data_0[3]
// Byte 46 : BYTE Data_1[0]
// Byte 47 : BYTE Data_1[1]
// Byte 48 : BYTE Data_1[2]
// Byte 49 : BYTE Data_1[3]
// Byte 50 : BYTE Data_2[0]
// Byte 51 : BYTE Data_2[1]
// Byte 52 : BYTE Data_2[2]
// Byte 53 : BYTE Data_2[3]
// Byte 54 : BYTE Data_3[0]
// Byte 55 : BYTE Data_3[1]
// Byte 56 : BYTE Data_3[2]
// Byte 57 : BYTE Data_3[3]
// Byte 58 : BYTE Data_4[0]
// Byte 59 : BYTE Data_4[1]
// Byte 60 : BYTE Data_4[2]
// Byte 61 : BYTE Data_4[3]
// Byte 62 : BYTE Data_5[0]
// Byte 63 : BYTE Data_5[1]
// Byte 64 : BYTE Data_5[2]
// Byte 65 : BYTE Data_5[3]
// Byte 66 : BYTE Data_6[0]
// Byte 67 : BYTE Data_6[1]
// Byte 68 : BYTE Data_6[2]
// Byte 69 : BYTE Data_6[3]
// Byte 70 : BYTE Data_7[0]
// Byte 71 : BYTE Data_7[1]
// Byte 72 : BYTE Data_7[2]
// Byte 73 : BYTE Data_7[3]
// Byte 74 : BOOL RCParameter
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.WriteSystemVariable;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
                          
  _command.EmitterID[0]   :=  0;
  _command.EmitterID[1]   :=  0;
  _command.EmitterID[2]   :=  0;
  _command.EmitterID[3]   :=  0;
  _command.ListenerID     :=  _parCmd.ListenerID;
  _command.Reserve        :=  0;
  _command.ParameterID    :=  _parCmd.ParameterID;
  _command.SubParameterID :=  _parCmd.SubParameterID;
  
  FOR _idx := 0 TO 7 
  DO
   _command.DataType[_idx] := _parCmd.DataType[_idx];
  END_FOR
  
  _command.Data_0         :=  _parCmd.Data_0;
  _command.Data_1         :=  _parCmd.Data_1;
  _command.Data_2         :=  _parCmd.Data_2;
  _command.Data_3         :=  _parCmd.Data_3;
  _command.Data_4         :=  _parCmd.Data_4;
  _command.Data_5         :=  _parCmd.Data_5;
  _command.Data_6         :=  _parCmd.Data_6;
  _command.Data_7         :=  _parCmd.Data_7;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.EmitterID[x]
      CreateCommandPayload.AddSint(_command.EmitterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ListenerID
    CreateCommandPayload.AddSint(_command.ListenerID);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Reserve
    CreateCommandPayload.AddByte(_command.Reserve);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  
  FOR _idx := 0 TO 7 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.ParameterID[_idx]
      CreateCommandPayload.AddUint(_command.ParameterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SubParameterID[_idx]
      CreateCommandPayload.AddUsint(_command.SubParameterID[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 7 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.DataType[_idx]
      CreateCommandPayload.AddUsint(_command.DataType[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_0[_idx]
      CreateCommandPayload.AddUsint(_command.Data_0[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_1[_idx]
      CreateCommandPayload.AddUsint(_command.Data_1[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_2[_idx]
      CreateCommandPayload.AddUsint(_command.Data_2[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_3[_idx]
      CreateCommandPayload.AddUsint(_command.Data_3[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_4[_idx]
      CreateCommandPayload.AddUsint(_command.Data_4[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_5[_idx]
      CreateCommandPayload.AddUsint(_command.Data_5[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_6[_idx]
      CreateCommandPayload.AddUsint(_command.Data_6[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  FOR _idx := 0 TO 3 
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.Data_7[_idx]
      CreateCommandPayload.AddUsint(_command.Data_7[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR_INPUT
  /// Parameter count
  ParameterCnt : DINT;
END_VAR
VAR 
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.EmitterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
                         
                         
  // Create log entry for ParameterID[_idx]
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.ParameterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.ParameterID[{2}] = {1}',
                            Para1       :=  UINT_TO_STRING(_command.ParameterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for SubParameterID[_idx]
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.SubParameterID
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SubParameterID[{2}] = {1}',
                            Para1       :=  USINT_TO_STRING(_command.SubParameterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
                         
  // Create log entry for DataType[_idx]
  FOR _idx := 0 TO 7
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.DataType
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.DataType[{2}] = {1}',
                            Para1       :=  DATA_TYPE_TO_STRING(_command.DataType[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_0[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_0
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_0[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_0[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_1[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_1
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_1[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_1[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_2[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_2
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_2[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_2[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_3[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_3
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_3[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_3[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_4[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_4
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_4[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_4[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_5[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_5
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_5[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_5[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_6[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_6
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_6[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_6[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Data_7[_idx]
  FOR _idx := 0 TO 3
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for Command.Data_7
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.Data_7[{2}] = {1}',
                            Para1       :=  BYTE_TO_STRING(_command.Data_7[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteSystemVariableFB';
  
  ExecMode       := ExecutionMode.PARALLEL;
  Priority       := PriorityLevel.NORMAL;
  ProcessingMode := ProcessingModeEnum.PARALLEL;
  SequenceFlag   := SequenceFlagEnum.NO_SEQUENCE;

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
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           RestartRequested := _response.RestartRequested    ;            
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.RestartRequested  := _response.RestartRequested;
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
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
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
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-627: Received CMD payload (RC to PLC) of "WriteSystemVariable"
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
// Byte 08 : BOOL       - RestartRequested

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.InvocationCounter
   _response.InvocationCounter := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Reserve
   _response.Reserve := ResponseData.GetSint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.OriginID
   _response.OriginID := ResponseData.GetInt();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.RestartRequested
   _response.RestartRequested := ResponseData.GetBool();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
   
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp, ParameterCnt := _parameterCnt);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryResponseDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
  /// Parameter count
  ParameterCnt : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := '{1} parameter(s) to parse from the response data:',
                          Para1       := DINT_TO_STRING(ParameterCnt));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for InvocationCounter
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InvocationCounter = {1}',
                          Para1       :=  USINT_TO_STRING(_response.InvocationCounter));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  SINT_TO_STRING(_response.Reserve));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for OriginID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.OriginID = {1}',
                          Para1       :=  INT_TO_STRING(_response.OriginID));                       
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for RestartRequested
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RestartRequested = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.RestartRequested));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  RestartRequested   := FALSE;
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

