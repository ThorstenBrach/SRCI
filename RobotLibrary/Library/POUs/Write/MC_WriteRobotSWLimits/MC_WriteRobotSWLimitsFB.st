/// Change robot limits of robot axes (degree)
FUNCTION_BLOCK MC_WriteRobotSWLimitsFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteRobotSWLimitsFB                                       
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
  ParCmd          : WriteRobotSWLimitsParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : WriteRobotSWLimitsOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : WriteRobotSWLimitsParCmd;
  /// command data to send
 _command         : WriteRobotSWLimitsSendData;
  /// response data received
 _response        : WriteRobotSWLimitsRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.WriteRobotSWLimits;
  
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
  
  
  // Check ParCmd.LimitValues.J1LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J1LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J1LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J1LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J1UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J1UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J1UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J1UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J2LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J2LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J2LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J2LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J2UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J2UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J2UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J2UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J3LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J3LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J3LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J3LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J3UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J3UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J3UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J3UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J4LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J4LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J4LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J4LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J4UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J4UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J4UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J4UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J5LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J5LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J5LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J5LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J5UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J5UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J5UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J5UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J6LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J6LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J6LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J6LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.J6UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.J6UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.J6UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.J6UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E1LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E1LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E1LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E1LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E1UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E1UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E1UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E1UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E2LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E2LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E2LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E2LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E2UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E2UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E2UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E2UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E3LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E3LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E3LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E3LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E3UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E3UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E3UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E3UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E4LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E4LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E4LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E4LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E4UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E4UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E4UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E4UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E5LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E5LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E5LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E5LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E5UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E5UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E5UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E5UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E6LowerLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E6LowerLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E6LowerLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E6LowerLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LimitValues.E6UpperLimit ? 
  IF ( SysDepIsValidReal(ParCmd.LimitValues.E6UpperLimit) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.LimitValues.E6UpperLimit = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.LimitValues.E6UpperLimit));
  
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ResetToFactoryDefaults ? 
  IF (( ParCmd.ResetToFactoryDefaults <> FALSE ) AND
      ( ParCmd.ResetToFactoryDefaults <> TRUE  ))
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
                            MessageText := 'Invalid Parameter ParCmd.ResetToFactoryDefaults = {1}',
                            Para1       := BOOL_TO_STRING(ParCmd.ResetToFactoryDefaults));
  
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// Parameter count
 _parameterCnt : DINT;
END_VAR
// Table 6-185: Sent CMD payload (PLC to RC) of "WriteRobotSWLimits"
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
// Byte 04 : DATE Date
// Byte 05 : 
// Byte 06 : TIME_OF_DAY Time
// Byte 07 : 
// Byte 08 : 
// Byte 09 : REAL J1LowerLimit
// Byte 10 : 
// Byte 11 : 
// Byte 12 : REAL J2LowerLimit
// Byte 13 : 
// Byte 14 : 
// Byte 15 : REAL J3LowerLimit
// Byte 16 : 
// Byte 17 : 
// Byte 18 : REAL J4LowerLimit
// Byte 19 : 
// Byte 20 : 
// Byte 21 : REAL J5LowerLimit
// Byte 22 : 
// Byte 23 : 
// Byte 24 : REAL J6LowerLimit
// Byte 25 : 
// Byte 26 : 
// Byte 27 : REAL E1LowerLimit
// Byte 28 : 
// Byte 29 : 
// Byte 30 : REAL J1UpperLimit
// Byte 31 : 
// Byte 32 : 
// Byte 33 : REAL J2UpperLimit
// Byte 34 : 
// Byte 35 : 
// Byte 36 : REAL J3UpperLimit
// Byte 37 : 
// Byte 38 : 
// Byte 39 : REAL J4UpperLimit
// Byte 40 : 
// Byte 41 : 
// Byte 42 : REAL J5UpperLimit
// Byte 43 : 
// Byte 44 : 
// Byte 45 : REAL J6UpperLimit
// Byte 46 : 
// Byte 47 : 
// Byte 48 : REAL E1UpperLimit
// Byte 49 : 
// Byte 50 : 
// Byte 51 : REAL E2LowerLimit
// Byte 52 : 
// Byte 53 : 
// Byte 54 : REAL E3LowerLimit
// Byte 55 : 
// Byte 56 : 
// Byte 57 : REAL E4LowerLimit
// Byte 58 : 
// Byte 59 : 
// Byte 60 : REAL E5LowerLimit
// Byte 61 : 
// Byte 62 : 
// Byte 63 : REAL E6LowerLimit
// Byte 64 : 
// Byte 65 : 
// Byte 66 : REAL E2UpperLimit
// Byte 67 : 
// Byte 68 : 
// Byte 69 : REAL E3UpperLimit
// Byte 70 : 
// Byte 71 : 
// Byte 72 : REAL E4UpperLimit
// Byte 73 : 
// Byte 74 : 
// Byte 75 : REAL E5UpperLimit
// Byte 76 : 
// Byte 77 : 
// Byte 78 : REAL E6UpperLimit
// Byte 79 : 
// Byte 80 : 
// Byte 81 : 
// Byte 82 : BOOL ResetToFactoryDefault
// --------------------------

  // set command parameter 
  _command.CmdTyp                 :=  CmdType.WriteRobotSWLimits;
  _command.ExecMode               :=  ExecMode;
  _command.ParSeq                 := _command.ParSeq;
  _command.Priority               :=  Priority;
                                  
  _command.LimitValues            :=  _parCmd.LimitValues;
  _command.ResetToFactoryDefaults :=  _parCmd.ResetToFactoryDefaults;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.Timestamp.IEC_DATE
    CreateCommandPayload.AddUint(_command.LimitValues.Timestamp.IEC_DATE);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.Timestamp.IEC_TIME
    CreateCommandPayload.AddTime(_command.LimitValues.Timestamp.IEC_TIME);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J1LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J1LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J2LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J2LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J3LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J3LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J41LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J4LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J5LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J5LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J6LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J6LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E1LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E1LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J1UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J1UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J2UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J2UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J3UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J3UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J4UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J4UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J5UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J5UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.J6UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.J6UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E1UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E1UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E2LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E2LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E3LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E3LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E4LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E4LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E5LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E5LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E6LowerLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E6LowerLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E2UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E2UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E3UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E3UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E4UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E4UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E5UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E5UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.LimitValues.E6UpperLimit
    CreateCommandPayload.AddReal(_command.LimitValues.E6UpperLimit);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
    
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

  // Create log entry for Parameter start
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload with the {1} parameter(s) :',
                          Para1       := DINT_TO_STRING(ParameterCnt));
    
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_command.LimitValues.Timestamp.IEC_DATE));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_command.LimitValues.Timestamp.IEC_TIME));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J1LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J1LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J1LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J2LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J2LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J2LowerLimit));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J3LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J3LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J3LowerLimit));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J4LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J4LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J4LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J5LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J5LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J5LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J6LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J6LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J6LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E1LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E1LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E1LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J1UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J1UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J1UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J2UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J2UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J2UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J3UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J3UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J3UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J4UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J4UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J4UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J5UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J5UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J5UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.J6UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.J6UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.J6UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E1UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E1UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E1UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E2LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E2LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E2LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E3LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E3LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E3LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E4LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E4LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E4LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E5LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E5LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E5LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E6LowerLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E6LowerLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E6LowerLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E2UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E2UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E2UpperLimit));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E3UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E3UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E3UpperLimit));                        
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E4UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E4UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E4UpperLimit));                                                
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E5UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E5UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E5UpperLimit));                                                                        
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for LimitValues.E6UpperLimit
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LimitValues.E6UpperLimit = {1}',
                          Para1       :=  REAL_TO_STRING(_command.LimitValues.E6UpperLimit));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteRobotSWLimitsFB';
  
  ExecMode := ExecutionMode.PARALLEL;
  Priority := PriorityLevel.NORMAL;

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
             CmdMessageState.BUFFERED : CommandBuffered := TRUE;
             CmdMessageState.DONE     : Done            := TRUE;
             CmdMessageState.ERROR    : Error           := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
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
// Table 6-186: Received CMD payload (RC to PLC) of "WriteRobotSWLimits"
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
// Byte 04 : BOOL       - RestartRequested

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
  CommandBuffered    := FALSE;

END_METHOD

