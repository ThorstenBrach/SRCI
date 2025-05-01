/// Configure conveyor parameters
FUNCTION_BLOCK MC_ConfigureConveyorFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ConfigureConveyorFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
  ParCmd          : ConfigureConveyorParCmd;      
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// Command output 
  OutCmd          : ConfigureConveyorOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : ConfigureConveyorParCmd;
  /// command data to send
 _command         : ConfigureConveyorSendData;
  /// response data received
 _response        : ConfigureConveyorRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ConfigureConveyor;
  
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

  CheckParameterValid := TRUE;
  
  
  // Check ParCmd.ConveyorNo valid ? 
  IF (( ParCmd.ConveyorNo <   0 ) OR  
      ( ParCmd.ConveyorNo > 255 ))
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorNo = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.ConveyorNo));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.X valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.X) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.X = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.X));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.Y valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.Y) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.Y = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.Y));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.Z valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.Z) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.Z = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.Z));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.Rx valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.Rx) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.Rx = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.Rx));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.Ry valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.Ry) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.Ry = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.Ry));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.Rz valid ? 
  IF ( SysDepIsValidReal(ParCmd.ConveyorOrigin.Rz) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.Rz = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.ConveyorOrigin.Rz));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorOrigin.ReferenceFrame  valid ? 
  IF (( ParCmd.ConveyorOrigin.ReferenceFrame <   0 ) OR  
      ( ParCmd.ConveyorOrigin.ReferenceFrame > 254 ))
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorOrigin.ReferenceFrame = {1}',
                            Para1       := USINT_TO_STRING(ParCmd.ConveyorOrigin.ReferenceFrame ));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.ConveyorType valid ? 
  IF (( ParCmd.ConveyorType <> ConveyorType.LINEAR_CONVEYOR_TRACKING ) AND  
      ( ParCmd.ConveyorType <> ConveyorType.LINEAR_CONVEYOR_TRACKING ))
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
                            MessageText := 'Invalid Parameter ParCmd.ConveyorType = {1}',
                            Para1       :=  CONVEYOR_TYPE_TO_STRING(ParCmd.ConveyorType));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Radius valid ? 
  IF ( SysDepIsValidReal(ParCmd.Radius) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.Radius = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.Radius));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.StartDistance valid ? 
  IF ( SysDepIsValidReal(ParCmd.StartDistance) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.StartDistance = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.StartDistance));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.EndDistance valid ? 
  IF ( SysDepIsValidReal(ParCmd.EndDistance) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.EndDistance = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.EndDistance));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.SyncInLength valid ? 
  IF ( SysDepIsValidReal(ParCmd.SyncInLength) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.SyncInLength = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.SyncInLength));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.SyncOutLength valid ? 
  IF ( SysDepIsValidReal(ParCmd.SyncOutLength) = FALSE ) 
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
                            MessageText := 'Invalid Parameter ParCmd.SyncOutLength = {1}',
                            Para1       := VALID_REAL_TO_STRING(ParCmd.SyncOutLength));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-458: Sent CMD payload (PLC to RC) of "ConfigureConveyor"
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
// Byte 04 : IEC_DATE   - Date              LW HB
// Byte 05 :            - Date              LW LB
// Byte 06 : IEC_TIME   - Time              HW HB
// Byte 07 :            - Time              HW LB
// Byte 08 :            - Time              LW HB
// Byte 09 :            - Time              LW LB
// Byte 10 : USINT      - ReferenceFrame
// Byte 11 : BYTE       - Reserve
// Byte 12 : REAL       - ConveyorOrigin.X  HW HB
// Byte 13 :            - ConveyorOrigin.X  HW LB
// Byte 14 :            - ConveyorOrigin.X  LW HB
// Byte 15 :            - ConveyorOrigin.X  LW LB
// Byte 16 : REAL       - ConveyorOrigin.Y  HW HB
// Byte 17 :            - ConveyorOrigin.Y  HW LB
// Byte 18 :            - ConveyorOrigin.Y  LW HB
// Byte 19 :            - ConveyorOrigin.Y  LW LB
// Byte 20 : REAL       - ConveyorOrigin.Z  HW HB
// Byte 21 :            - ConveyorOrigin.Z  HW LB
// Byte 22 :            - ConveyorOrigin.Z  LW HB
// Byte 23 :            - ConveyorOrigin.Z  LW LB
// Byte 24 : REAL       - ConveyorOrigin.Rx HW HB
// Byte 25 :            - ConveyorOrigin.Rx HW LB
// Byte 26 :            - ConveyorOrigin.Rx LW HB
// Byte 27 :            - ConveyorOrigin.Rx LW LB
// Byte 28 : REAL       - ConveyorOrigin.Ry HW HB
// Byte 29 :            - ConveyorOrigin.Ry HW LB
// Byte 30 :            - ConveyorOrigin.Ry LW HB
// Byte 31 :            - ConveyorOrigin.Ry LW LB
// Byte 32 : REAL       - ConveyorOrigin.Rz HW HB
// Byte 33 :            - ConveyorOrigin.Rz HW LB
// Byte 34 :            - ConveyorOrigin.Rz LW HB
// Byte 35 :            - ConveyorOrigin.Rz LW LB
// Byte 36 : BOOL       - ConveyorOrigin Available
// Byte 37 : USINT      - ConveyorNo
// Byte 38 : USINT      - ConveyorType
// Byte 39 : REAL       - Radius            HW HB
// Byte 40 :            - Radius            HW LB
// Byte 41 :            - Radius            LW HB
// Byte 42 :            - Radius            LW LB
// Byte 43 : REAL       - StartDistance     HW HB
// Byte 44 :            - StartDistance     HW LB
// Byte 45 :            - StartDistance     LW HB
// Byte 46 :            - StartDistance     LW LB
// Byte 47 : REAL       - EndDistance       HW HB
// Byte 48 :            - EndDistance       HW LB
// Byte 49 :            - EndDistance       LW HB
// Byte 50 :            - EndDistance       LW LB
// Byte 51 : REAL       - SyncInLength      HW HB
// Byte 52 :            - SyncInLength      HW LB
// Byte 53 :            - SyncInLength      LW HB
// Byte 54 :            - SyncInLength      LW LB
// Byte 55 : REAL       - SyncOutLength     HW HB
// Byte 56 :            - SyncOutLength     HW LB
// Byte 57 :            - SyncOutLength     LW HB
// Byte 58 :            - SyncOutLength     LW LB
// --------------------------

  // set command parameter 
  _command.CmdTyp         :=  CmdType.ConfigureConveyor;
  _command.ExecMode       :=  ExecMode;
  _command.ParSeq         := _command.ParSeq;
  _command.Priority       :=  Priority;
  _command.ConveyorNo     := _parCmd.ConveyorNo;
  _command.ConveyorOrigin := _parCmd.ConveyorOrigin;
  _command.ConveyorType   := _parCmd.ConveyorType;
  _command.Radius         := _parCmd.Radius;
  _command.StartDistance  := _parCmd.StartDistance;
  _command.EndDistance    := _parCmd.EndDistance;
  _command.SyncInLength   := _parCmd.SyncInLength;
  _command.SyncOutLength  := _parCmd.SyncOutLength;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // add command.ConveyorOrigin.Timestamp.IEC_DATE
  CreateCommandPayload.AddIecDate(_command.ConveyorOrigin.Timestamp.IEC_DATE);
  // add command.ConveyorOrigin.Timestamp.IEC_TIME
  CreateCommandPayload.AddIecTime(_command.ConveyorOrigin.Timestamp.IEC_TIME);
  // add command.ConveyorOrigin.ReferenceFrame
  CreateCommandPayload.AddUsint(_command.ConveyorOrigin.ReferenceFrame);
  // add command.ConveyorOrigin.Reserve
  CreateCommandPayload.AddByte(0);
  // add command.ConveyorOrigin.ReferenceFrame.X
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.X);
  // add command.ConveyorOrigin.ReferenceFrame.Y
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Y);
  // add command.ConveyorOrigin.ReferenceFrame.Z
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Z);
  // add command.ConveyorOrigin.ReferenceFrame.Rx
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Rx);
  // add command.ConveyorOrigin.ReferenceFrame.Ry
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Ry);
  // add command.ConveyorOrigin.ReferenceFrame.Rz
  CreateCommandPayload.AddReal(_command.ConveyorOrigin.Rz);
  // add command.ConveyorOriginAvailable
  CreateCommandPayload.AddBool(_command.ConveyorOriginAvailable);
  // add command.ConveyorNo
  CreateCommandPayload.AddUsint(_command.ConveyorNo);
  // add command.ConveyorType
  CreateCommandPayload.AddUsint(_command.ConveyorType);
  // add command.Radius
  CreateCommandPayload.AddReal(_command.Radius);
  // add command.StartDistance
  CreateCommandPayload.AddReal(_command.StartDistance);
  // add command.EndDistance
  CreateCommandPayload.AddReal(_command.EndDistance);
  // add command.SyncInLength
  CreateCommandPayload.AddReal(_command.SyncInLength);
  // add command.SyncOutLength
  CreateCommandPayload.AddReal(_command.SyncOutLength);
  
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
  
  // Create log entry for ConveyorOrigin.Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_command.ConveyorOrigin.Timestamp.IEC_DATE));
                         
  // Create log entry for ConveyorOrigin.Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_command.ConveyorOrigin.Timestamp.IEC_TIME));
  
  // Create log entry for ConveyorOrigin.ReferenceFrame
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.ReferenceFrame = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ConveyorOrigin.ReferenceFrame));
                          
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(0));        
  
  // Create log entry for ConveyorOrigin.X
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.X = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.X));
                          
  // Create log entry for ConveyorOrigin.Y
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Y = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.Y));
                          
  // Create log entry for ConveyorOrigin.Z
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Z = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.Z));
  
  // Create log entry for ConveyorOrigin.Rx
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Rx = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.Rx));
                          
  // Create log entry for ConveyorOrigin.Ry
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Ry = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.Ry));
                          
  // Create log entry for ConveyorOrigin.Rz
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOrigin.Rz = {1}',
                          Para1       :=  REAL_TO_STRING(_command.ConveyorOrigin.Rz));                        
                          
  // Create log entry for ConveyorOriginAvailable
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorOriginAvailable = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.ConveyorOriginAvailable));
                          
  // Create log entry for ConveyorNo
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorNo = {1}',
                          Para1       :=  USINT_TO_STRING(_command.ConveyorNo));
                          
  // Create log entry for ConveyorType
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ConveyorType = {1}',
                          Para1       :=  CONVEYOR_TYPE_TO_STRING(_command.ConveyorType));                        
                          
  // Create log entry for Radius
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Radius = {1}',
                          Para1       :=  REAL_TO_STRING(_command.Radius));       
                          
  // Create log entry for StartDistance
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.StartDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_command.StartDistance));       
      
  // Create log entry for EndDistance
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.EndDistance = {1}',
                          Para1       :=  REAL_TO_STRING(_command.EndDistance));           
  
  // Create log entry for SyncInLength
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SyncInLength = {1}',
                          Para1       :=  REAL_TO_STRING(_command.SyncInLength));           
  
  // Create log entry for SyncOutLength
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SyncOutLength = {1}',
                          Para1       :=  REAL_TO_STRING(_command.SyncOutLength));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ConfigureConveyorFB';

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
// Table 6-459: Received CMD payload (RC to PLC) of "ConfigureConveyor"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT      - ParSeq | State     
// Byte 01 : SINT       - AlarmMessageSeverity    
// Byte 02 : UINT       - AlarmMessageCode HB
// Byte 03 :            - AlarmMessageCode LB
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq                := _rspHeader.ParSeq;
  _response.State                 := _rspHeader.State;
  _response.AlarmMessageSeverity  := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode      := _rspHeader.AlarmMessageCode;
  
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
                          
  // Create log entry for no parameter 
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'This command has no parameter to parse...');

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

