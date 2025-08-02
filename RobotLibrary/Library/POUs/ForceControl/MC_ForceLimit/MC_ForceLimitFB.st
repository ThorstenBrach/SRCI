/// Commands specified reaction from RA when defined force/torque detected
FUNCTION_BLOCK MC_ForceLimitFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceLimitFB                                       
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
  /// Command parameter 
  ParCmd            : ForceLimitParCmd;   
END_VAR

VAR_OUTPUT
  /// TRUE, while the following outputs return valid values
  Valid             : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// Command output 
  OutCmd            : ForceLimitOutCmd;      
END_VAR


VAR
  /// internal copy of command parameter 
 _parCmd            : ForceLimitParCmd;
  /// command data to send
 _command           : ForceLimitSendData;
  /// response data received
 _response          : ForceLimitRecvData;      
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

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ForceLimit;
  
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;  
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
  
  
  FOR _idx := 0 TO 5 
  DO
    // Check ParCmd.SensorValue[_idx] valid ? 
    IF ( SysDepIsValidReal(ParCmd.SensorValue[_idx]) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SensorValue[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SensorValue[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  END_FOR
  
  
  // Check ParCmd.ToolNo valid ? 
  IF (( ParCmd.ToolNo <   0                                                ) OR  
      ( ParCmd.ToolNo > 254                                                ) OR
      ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex ) OR
      ( ParCmd.ToolNo > RobotLibraryParameter.TOOL_MAX -1                  ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check ToolNo available on RC ? 
    IF ( ParCmd.ToolNo > AxesGroup.State.ConfigurationData.HighestToolIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_TOOLNO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.ToolNo = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.ToolNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.FrameNo valid ? 
  IF (( ParCmd.FrameNo <   0                                                 ) OR  
      ( ParCmd.FrameNo > 254                                                 ) OR
      ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex ) OR
      ( ParCmd.FrameNo > RobotLibraryParameter.FRAME_MAX -1                  ))         
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    
    // Check FrameNo available on RC ? 
    IF ( ParCmd.FrameNo > AxesGroup.State.ConfigurationData.HighestFrameIndex )
    THEN
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_UNAVAILABLE;
    ELSE
      ErrorID := RobotLibraryErrorIdEnum.ERR_FRAMENO_RANGE;
  	END_IF  
    
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.FrameNo = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.FrameNo));
    RETURN;                          
  END_IF
  
  
  FOR _idx := 0 TO 5 
  DO
    // Check ParCmd.ForceLimit[_idx] valid ? 
    IF ( SysDepIsValidReal(ParCmd.ForceLimit[_idx]) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.ForceLimit[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.ForceLimit[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  END_FOR
  
  
  // Check ParCmd.ConnectionMode valid ? 
  IF (( ParCmd.ConnectionMode <> ConnectionMode.RC_CONNECTED  ) AND  
      ( ParCmd.ConnectionMode <> ConnectionMode.PLC_CONNECTED ))
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
                            MessageText := 'Invalid Parameter ParCmd.ConnectionMode = {1}',
                            Para1       :=  CONNECTION_MODE_TO_STRING(ParCmd.ConnectionMode));
    RETURN;                          
  END_IF
  
  
  FOR _idx := 0 TO 5 
  DO
    // Check ParCmd.SensorFrame[_idx] valid ? 
    IF ( SysDepIsValidReal(ParCmd.SensorFrame[_idx]) = FALSE ) 
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
                              MessageText := 'Invalid Parameter ParCmd.SensorFrame[{2}] = {1}',
                              Para1       := VALID_REAL_TO_STRING(ParCmd.SensorFrame[_idx]),
                              Para2       := DINT_TO_STRING(_idx));
      EXIT;                            
      RETURN;                          
    END_IF
  END_FOR
  
  
  // Check ParCmd.CalibrationData valid ? 
  IF (( ParCmd.CalibrationData <   0 ) OR  
      ( ParCmd.CalibrationData > 255 ))
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
                            MessageText := 'Invalid Parameter ParCmd.CalibrationData = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.CalibrationData));
    RETURN;                          
  END_IF
  
  // Check ParCmd.FixedSensor
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.EmitterID valid ? 
  IF (( ParCmd.EmitterID < -127 ) OR  
      ( ParCmd.EmitterID >  127 ))
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
                            MessageText := 'Invalid Parameter ParCmd.EmitterID = {1}',
                            Para1       :=  SINT_TO_STRING(ParCmd.EmitterID));
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
// Table 6-727: Sent CMD payload (PLC to RC) of "ForceLimit"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT       - Type HB     
// Byte 01 :            - Type LB    
// Byte 02 : USINT      - Reserve | ExecutionMode
// Byte 03 : USINT      - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 004 : SINT       - EmitterID[0] 
// Byte 005 : SINT       - EmitterID[1] 
// Byte 006 : SINT       - EmitterID[2] 
// Byte 007 : SINT       - EmitterID[3]
// Byte 008 : SINT       - ListenerID
// Byte 009 : BYTE       - Reserve
// Byte 010 : USINT      - ToolNo
// Byte 011 : USINT      - FrameNo
// Byte 012 : USINT      - ConnectionMode
// Byte 013 : BOOL       - FixedSensor
// Byte 014 : REAL       - SensorFrame[0] HW HB
// Byte 015 :            - SensorFrame[0] HW LB
// Byte 016 :            - SensorFrame[0] LW HB
// Byte 017 :            - SensorFrame[0] LW LB
// Byte 018 : REAL       - SensorFrame[1] HW HB
// Byte 019 :            - SensorFrame[1] HW LB
// Byte 020 :            - SensorFrame[1] LW HB
// Byte 021 :            - SensorFrame[1] LW LB
// Byte 022 : REAL       - SensorFrame[2] HW HB
// Byte 023 :            - SensorFrame[2] HW LB
// Byte 024 :            - SensorFrame[2] LW HB
// Byte 025 :            - SensorFrame[2] LW LB
// Byte 026 : REAL       - SensorFrame[3] HW HB
// Byte 027 :            - SensorFrame[3] HW LB
// Byte 028 :            - SensorFrame[3] LW HB
// Byte 029 :            - SensorFrame[3] LW LB
// Byte 030 : REAL       - SensorFrame[4] HW HB
// Byte 031 :            - SensorFrame[4] HW LB
// Byte 032 :            - SensorFrame[4] LW HB
// Byte 033 :            - SensorFrame[4] LW LB
// Byte 034 : REAL       - SensorFrame[5] HW HB
// Byte 035 :            - SensorFrame[5] HW LB
// Byte 036 :            - SensorFrame[5] LW HB
// Byte 037 :            - SensorFrame[5] LW LB
// Byte 038 : USINT      - CalibrationData
// Byte 039 : USINT      - ReferenceType
// Byte 040 : REAL       - SensorValue[0] HW HB
// Byte 041 :            - SensorValue[0] HW LB
// Byte 042 :            - SensorValue[0] LW HB
// Byte 043 :            - SensorValue[0] LW LB
// Byte 044 : REAL       - SensorValue[1] HW HB
// Byte 045 :            - SensorValue[1] HW LB
// Byte 046 :            - SensorValue[1] LW HB
// Byte 047 :            - SensorValue[1] LW LB
// Byte 048 : REAL       - SensorValue[2] HW HB
// Byte 049 :            - SensorValue[2] HW LB
// Byte 050 :            - SensorValue[2] LW HB
// Byte 051 :            - SensorValue[2] LW LB
// Byte 052 : REAL       - SensorValue[3] HW HB
// Byte 053 :            - SensorValue[3] HW LB
// Byte 054 :            - SensorValue[3] LW HB
// Byte 055 :            - SensorValue[3] LW LB
// Byte 056 : REAL       - SensorValue[4] HW HB
// Byte 057 :            - SensorValue[4] HW LB
// Byte 058 :            - SensorValue[4] LW HB
// Byte 059 :            - SensorValue[4] LW LB
// Byte 060 : REAL       - SensorValue[5] HW HB
// Byte 061 :            - SensorValue[5] HW LB
// Byte 062 :            - SensorValue[5] LW HB
// Byte 063 :            - SensorValue[5] LW LB
// Byte 064 : REAL       - Limit[0] HW HB
// Byte 065 :            - Limit[0] HW LB
// Byte 066 :            - Limit[0] LW HB
// Byte 067 :            - Limit[0] LW LB
// Byte 068 : REAL       - Limit[1] HW HB
// Byte 069 :            - Limit[1] HW LB
// Byte 070 :            - Limit[1] LW HB
// Byte 071 :            - Limit[1] LW LB
// Byte 072 : REAL       - Limit[2] HW HB
// Byte 073 :            - Limit[2] HW LB
// Byte 074 :            - Limit[2] LW HB
// Byte 075 :            - Limit[2] LW LB
// Byte 076 : REAL       - Limit[3] HW HB
// Byte 077 :            - Limit[3] HW LB
// Byte 078 :            - Limit[3] LW HB
// Byte 079 :            - Limit[3] LW LB
// Byte 080 : REAL       - Limit[4] HW HB
// Byte 081 :            - Limit[4] HW LB
// Byte 082 :            - Limit[4] LW HB
// Byte 083 :            - Limit[4] LW LB
// Byte 084 : REAL       - Limit[5] HW HB
// Byte 085 :            - Limit[5] HW LB
// Byte 086 :            - Limit[5] LW HB
// Byte 087 :            - Limit[5] LW LB


// --------------------------

  // set command parameter 
  _command.CmdTyp          :=  CmdType.ForceLimit;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.EmitterID[0]    := _parCmd.EmitterID;
  _command.ListenerID      :=  0; {warning 'ToDo'} 
  _command.Reserve         :=  0; 
  _command.ToolNo          := _parCmd.ToolNo;
  _command.FrameNo         := _parCmd.FrameNo;
  _command.ConnectionMode  := SINT_TO_USINT(_parCmd.ConnectionMode);
  _command.FixedSensor.0   := _parCmd.FixedSensor;
  _command.SensorFrame     := _parCmd.SensorFrame;
  _command.CalibrationData := _parCmd.CalibrationData;
  _command.ReferenceType   := _parCmd.ReferenceType;
  _command.SensorValue     := _parCmd.SensorValue;
  _command.ForceLimit      := _parCmd.ForceLimit;  
  
  
  
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
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ToolNo
    CreateCommandPayload.AddUsint(_command.ToolNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.FrameNo
    CreateCommandPayload.AddUsint(_command.FrameNo);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ConnectionMode
    CreateCommandPayload.AddUsint(_command.ConnectionMode);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.FixedSensor
    CreateCommandPayload.AddByte(_command.FixedSensor);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  FOR _idx := 0 TO 5
  DO  
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SensorFrame[x]
      CreateCommandPayload.AddReal(_command.SensorFrame[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.CalibrationData
    CreateCommandPayload.AddUsint(_command.CalibrationData);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.ReferenceType
    CreateCommandPayload.AddUsint(_command.ReferenceType);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  FOR _idx := 0 TO 5
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.SensorValue[x]
      CreateCommandPayload.AddReal(_command.SensorValue[_idx]);
      // inc parameter counter
     _parameterCnt := _parameterCnt + 1;  
    END_IF
  END_FOR
  
  
  
  FOR _idx := 0 TO 5
  DO
    // Check parameter must be added ? 
    IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
    THEN
      // add command.ForceLimit[x]
      CreateCommandPayload.AddReal(_command.ForceLimit[_idx]);
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
                            MessageText := 'Command.EmitterID[{1}] = {2}',
                            Para1       :=  DINT_TO_STRING(_idx),
                            Para2       :=  SINT_TO_STRING(_command.EmitterID[_idx]));
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
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ToolNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ToolNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ToolNo));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for FrameNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FrameNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.FrameNo));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ConnectionMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConnectionMode = {1}',
                          Para1       :=  CONNECTION_MODE_TO_STRING(USINT_TO_SINT(_command.ConnectionMode)));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for FixedSensor
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.FixedSensor = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.FixedSensor));
  
  
  FOR _idx := 0 TO 5
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for ForceLimit[0]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SensorFrame[{1}] = {2}',
                            Para1       :=  DINT_TO_STRING(_idx),
                            Para2       :=  REAL_TO_STRING(_command.SensorFrame[_idx]));
  END_FOR     
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for CalibrationData
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CalibrationData = {1}',
                          Para1       :=  USINT_TO_STRING(_command.CalibrationData));
                          
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ReferenceType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ReferenceType = {1}',
                          Para1       :=  REFERENCE_TYPE_TO_STRING(_command.ReferenceType));                        
                                                  
  
  
  FOR _idx := 0 TO 5
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for ForceLimit[0]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.SensorValue[{1}] = {2}',
                            Para1       :=  DINT_TO_STRING(_idx),
                            Para2       :=  REAL_TO_STRING(_command.SensorValue[_idx]));
  END_FOR     
  
  
  FOR _idx := 0 TO 5
  DO
    // Return if no parameter is remaining...
    IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
    // dec remaining parameter(s)                        
    ParameterCnt := ParameterCnt - 1;
    // Create log entry for ForceLimit[0]
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.State.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.ForceLimit[{1}] = {2}',
                            Para1       :=  DINT_TO_STRING(_idx),
                            Para2       :=  REAL_TO_STRING(_command.ForceLimit[_idx]));
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ForceLimitFB';
  
  ExecMode := ExecutionMode.CONTINUOUS;
  Priority := PriorityLevel.NORMAL;

END_METHOD

METHOD Protected OnExecCancel : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal return value 
 _retVal    : DINT;
END_VAR

  OnExecCancel := RobotLibraryConstants.RUNNING;
  
  CASE _stepCancel OF
    
    0: // set busy flag
       Busy := TRUE;
      
       // Create log entry
       CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                               MessageType := MessageType.CMD,
                               Severity    := Severity.DEBUG,
                               MessageCode := 0,
                               MessageText := 'Execution of {1} cancled ',
                               Para1       := MyType);                 
      
       // try to remove cmd
      _retVal := AxesGroup.Acyclic.ActiveCommandRegister.RemoveCmd(_uniqueID);
    
       // check result of removement       
       IF ( _retVal = RobotLibraryConstants.OK )
       THEN
         // Reset step counter
        _stepCancel := 0;
         // finished okay
         OnExecCancel := RobotLibraryConstants.OK;
       
         // Create log entry
         CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                                 MessageType := MessageType.CMD,
                                 Severity    := Severity.DEBUG,
                                 MessageCode := 0,
                                 MessageText := '{1} successfully removed from ARC',
                                 Para1       := MyType);                 
       ELSE
         // set timeout
         SetTimeout(PT := _timeoutCancel, rTimer := _timerCancel);
         // inc step counter
        _stepCancel := _stepCancel + 1; 
       
         // Create log entry
         CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                                 MessageType := MessageType.CMD,
                                 Severity    := Severity.DEBUG,
                                 MessageCode := 0,
                                 MessageText := '{1} was not removed from ARC because execution was already in progress',
                                 Para1       := MyType);                 
       END_IF       
    
       
   1:  // call clear error 
       OnExecCancel := OnExecErrorClear(AxesGroup := AxesGroup);  
   
       IF ( OnExecCancel = RobotLibraryConstants.OK)
       THEN
         // Reset busy flag
         Busy := FALSE;
         // Reset step counter
        _stepCancel := 0;
         // finished okay
         OnExecCancel := RobotLibraryConstants.OK;
       END_IF  
    
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE  
  
  
                          
  // reset step counter
  IF (OnExecCancel <> RobotLibraryConstants.RUNNING)
  THEN
    // Reset FB variables
    Reset();
    // Reset step counter
   _stepCancel := 0;
  END_IF

END_METHOD

METHOD PROTECTED OnExecErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  OnExecErrorClear := RobotLibraryConstants.RUNNING;
  
  CASE _stepClearError OF
    
    0:  // set busy flag
        Busy := TRUE;
        // trigger parameter update to disable FB
       _parameterUpdateInternal := TRUE;
        // call Check Parameter changed method to trigger the parameter update to disable the function
        CheckParameterChanged(AxesGroup := AxesGroup);
        // set timeout
        SetTimeout(PT := _timeoutClearError, rTimer := _timerClearError);
        // inc step counter
       _stepClearError := _stepClearError + 1; 
        
    1: IF ( _responseReceived )
       THEN
         // reset response received flag
        _responseReceived := FALSE;
         // reset step counter
        _stepClearError := 0;
         // finished
         OnExecErrorClear := RobotLibraryConstants.OK;
       ELSE
         // timeout exceeded ? 
         IF (CheckTimeout(_timerClearError) = RobotLibraryConstants.OK)
         THEN
           OnExecErrorClear := RobotLibraryConstants.HAS_ERROR;
         END_IF
  	   END_IF
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE
  
  
  // reset step counter
  IF (OnExecErrorClear <> RobotLibraryConstants.RUNNING)
  THEN
    // Reset 
    Reset();     
    // reset step counter
   _stepClearError := 0;
  END_IF

END_METHOD

METHOD PROTECTED OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q ) AND ( NOT Error) 
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
  
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
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;
                                           Valid              := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
           
           // Update results
           OutCmd.ForceStatus.ForceControlEnabled         := _response.ForceStatus.0;
           OutCmd.ForceStatus.ForceLimitEnabled           := _response.ForceStatus.1;
           OutCmd.ForceStatus.ApplyingForce               := _response.ForceStatus.2;
           OutCmd.ForceStatus.MaxDeviationReached         := _response.ForceStatus.3;
           OutCmd.ForceStatus.SpecifiedForceTorqueReached := _response.ForceStatus.4;
           OutCmd.ForceStatus.SpecifiedForceLimitReached  := _response.ForceStatus.5;
           OutCmd.ForceStatus.Bit06                       := _response.ForceStatus.6;
           OutCmd.ForceStatus.Bit07                       := _response.ForceStatus.7;  
           OutCmd.FollowID                                := _response.OriginID; {warning 'ToDo'}
           
           // Update enable flag
           Enabled := OutCmd.ForceStatus.ForceLimitEnabled;
           
           
           // Enabled or Error ? -> Reset Busy flag  
           IF (( Enabled ) OR 
               ( Error   ))
           THEN  
             Busy := FALSE;
  				 END_IF
  
         END_IF
  
         // do not abort directly, so that the ParSeq update can be send
         IF ( _enable_F.Q ) 
         THEN
           // Set Busy flag
           Busy := TRUE;
           // trigger parameter update to disable FB
          _parameterUpdateInternal := TRUE;
           // reset the falling edge
          _enable_F();
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
  
        // Wait for response received or timeout or not Initialized
    02: IF ((    _responseReceived                                   )  OR 
            (     CheckTimeout(_timerCmd) = RobotLibraryConstants.OK )) OR 
           (( NOT AxesGroup.State.Initialized                        )  AND
            ( NOT AxesGroup.State.Synchronized                       ))
        THEN
          Reset();   
  	    END_IF
        
  ELSE
    // invalid step
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_STEP;
  END_CASE
  
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
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
// Table 6-728: Received CMD payload (RC to PLC) of "ForceLimit"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT      - ParSeq | State     
// Byte 01 : SINT       - AlarmMessageSeverity    
// Byte 02 : UINT       - AlarmMessageCode HB
// Byte 03 :            - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : USINT      - InvocationCounter 
// Byte 05 : USINT      - Reserved 
// Byte 06 : INT        - OriginID LW HB
// Byte 07 :            - OriginID LW LB 
// Byte 08 : BYTE       - ForceStatus 
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN 
    // Get Response.ForceStatus
   _response.ForceStatus := ResponseData.GetByte();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
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
    // Get Response.Reserved
   _response.Reserved := ResponseData.GetSint();
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
    // Get Response.ForceStatus
   _response.ForceStatus := ResponseData.GetByte();
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
                          Para1       :=  SINT_TO_STRING(_response.Reserved));
  
  
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
  // Create log entry for ForceStatus
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ForceStatus = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.ForceStatus));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Valid              := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

