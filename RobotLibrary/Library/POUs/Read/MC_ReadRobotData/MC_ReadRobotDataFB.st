/// Read robot-specific data from the RC
FUNCTION_BLOCK MC_ReadRobotDataFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRobotDataFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-11
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
  /// internal copy of command parameter 
  ParCmd          : ReadRobotDataParCmd;  
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadRobotDataOutCmd;       
END_VAR


VAR
  /// internal copy of command parameter 
 _parCmd             : ReadRobotDataParCmd;
  /// command data to send
 _command            : ReadRobotDataSendData;
  /// response data received
 _response           : ReadRobotDataRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := TRUE;  // Function is mandatory 
  RETURN;
  
  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.ReadRobotData;
  
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-17: Sent CMD payload (PLC to RC) of "ReadRobotData"
// --------------------------
// Header
// --------------------------
// Byte 00 : UINT  - Type HB     
// Byte 01 :       - Type LB    
// Byte 02 : USINT - Reserve | ExecutionMode
// Byte 03 : USINT - ParSeq  | Priority
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.ReadRobotData;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Create command payload without additional parameter(s)');

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadRobotDataFB';
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
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // reset Busy Flag
             Busy := FALSE;
             // Update results
             OutCmd.RCManufacturer       :=                              _response.RCManufacturer;
             OutCmd.RCOrderID            :=                              _response.RCOrderID;
             OutCmd.RCSerialNumber       :=                              _response.RCSerialNumber;
             OutCmd.RASerialNumber       :=                              _response.RASerialNumber;
             OutCmd.RCFirmwareVersion    :=                              _response.RCFirmwareVersion;
             OutCmd.RCInterpreterVersion :=                              _response.RCInterpreterVersion;
             OutCmd.AxisJointUsed        :=  ByteToAxisJointUsed        (_response.AxisJointUsed);           
             OutCmd.AxisExternalUsed     :=  ByteToAxisExternalUsed     (_response.AxisExternalUsed);
             OutCmd.AxisJointUnit        :=  ByteToAxisJointUnit        (_response.AxisJointUnit);
             OutCmd.AxisExternalUnit     :=  ByteToAxisExternalUnit     (_response.AxisExternalUnit);
             OutCmd.RCSupportedFunctions :=  BytesToRCSupportedFunctions(_response.RCSupportedFunctions);
             OutCmd.RobotID              :=                              _response.RobotID;  
             OutCmd.InterpreterCycleTime :=                              _response.InterpreterCycleTime;
             
             // must be always true, because this command is part of the interface initialization
             OutCmd.RCSupportedFunctions.ExchangeConfiguration := TRUE;
             OutCmd.RCSupportedFunctions.ReadRobotData         := TRUE;
             OutCmd.RCSupportedFunctions.ReadMessages          := TRUE;
                        
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
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
// Table 6-18: Received CMD payload (RC to PLC) of "ReadRobotData"
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
// Byte 04 : CHAR  RCManufacturer[0];
// Byte 05 : CHAR  RCManufacturer[1];
// Byte 06 : CHAR  RCManufacturer[2];
// Byte 07 : CHAR  RCManufacturer[3];
// Byte 08 : CHAR  RCManufacturer[4];
// Byte 09 : CHAR  RCManufacturer[5];
// Byte 10 : CHAR  RCManufacturer[6];
// Byte 11 : CHAR  RCManufacturer[7];
// Byte 12 : CHAR  RCManufacturer[8];
// Byte 13 : CHAR  RCManufacturer[9];
// Byte 14 : CHAR  RCManufacturer[10];
// Byte 15 : CHAR  RCManufacturer[11];
// Byte 16 : CHAR  RCManufacturer[12];
// Byte 17 : CHAR  RCManufacturer[13];
// Byte 18 : CHAR  RCManufacturer[14];
// Byte 19 : CHAR  RCManufacturer[15];
// Byte 20 : CHAR  RCManufacturer[16];
// Byte 21 : CHAR  RCManufacturer[17];
// Byte 22 : CHAR  RCManufacturer[18];
// Byte 23 : CHAR  RCManufacturer[19];
// Byte 24 : CHAR  RCOrderID[0];
// Byte 25 : CHAR  RCOrderID[1];
// Byte 26 : CHAR  RCOrderID[2];
// Byte 27 : CHAR  RCOrderID[3];
// Byte 28 : CHAR  RCOrderID[4];
// Byte 29 : CHAR  RCOrderID[5];
// Byte 30 : CHAR  RCOrderID[6];
// Byte 31 : CHAR  RCOrderID[7];
// Byte 32 : CHAR  RCOrderID[8];
// Byte 33 : CHAR  RCOrderID[9];
// Byte 34 : CHAR  RCOrderID[10];
// Byte 35 : CHAR  RCOrderID[11];
// Byte 36 : CHAR  RCOrderID[12];
// Byte 37 : CHAR  RCOrderID[13];
// Byte 38 : CHAR  RCOrderID[14];
// Byte 39 : CHAR  RCOrderID[15];
// Byte 40 : CHAR  RCOrderID[16];
// Byte 41 : CHAR  RCOrderID[17];
// Byte 42 : CHAR  RCOrderID[18];
// Byte 43 : CHAR  RCOrderID[19];
// Byte 44 : CHAR  RCSerialNumber[0];
// Byte 45 : CHAR  RCSerialNumber[1];
// Byte 46 : CHAR  RCSerialNumber[2];
// Byte 47 : CHAR  RCSerialNumber[3];
// Byte 48 : CHAR  RCSerialNumber[4];
// Byte 49 : CHAR  RCSerialNumber[5];
// Byte 50 : CHAR  RCSerialNumber[6];
// Byte 51 : CHAR  RCSerialNumber[7];
// Byte 52 : CHAR  RCSerialNumber[8];
// Byte 53 : CHAR  RCSerialNumber[9];
// Byte 54 : CHAR  RCSerialNumber[10];
// Byte 55 : CHAR  RCSerialNumber[11];
// Byte 56 : CHAR  RCSerialNumber[12];
// Byte 57 : CHAR  RCSerialNumber[13];
// Byte 58 : CHAR  RCSerialNumber[14];
// Byte 59 : CHAR  RCSerialNumber[15];
// Byte 60 : CHAR  RASerialNumber[0];
// Byte 61 : CHAR  RASerialNumber[1];
// Byte 62 : CHAR  RASerialNumber[2];
// Byte 63 : CHAR  RASerialNumber[3];
// Byte 64 : CHAR  RASerialNumber[4];
// Byte 65 : CHAR  RASerialNumber[5];
// Byte 66 : CHAR  RASerialNumber[6];
// Byte 67 : CHAR  RASerialNumber[7];
// Byte 68 : CHAR  RASerialNumber[8];
// Byte 69 : CHAR  RASerialNumber[9];
// Byte 70 : CHAR  RASerialNumber[10];
// Byte 71 : CHAR  RASerialNumber[11];
// Byte 72 : CHAR  RASerialNumber[12];
// Byte 73 : CHAR  RASerialNumber[13];
// Byte 74 : CHAR  RASerialNumber[14];
// Byte 75 : CHAR  RASerialNumber[15];
// Byte 76 : CHAR  RCFirmwareVersion[0];
// Byte 77 : CHAR  RCFirmwareVersion[1];
// Byte 78 : CHAR  RCFirmwareVersion[2];
// Byte 79 : CHAR  RCFirmwareVersion[3];
// Byte 80 : CHAR  RCFirmwareVersion[4];
// Byte 81 : CHAR  RCFirmwareVersion[5];
// Byte 82 : CHAR  RCFirmwareVersion[6];
// Byte 83 : CHAR  RCFirmwareVersion[7];
// Byte 84 : CHAR  RCFirmwareVersion[8];
// Byte 85 : CHAR  RCFirmwareVersion[9];
// Byte 86 : CHAR  RCFirmwareVersion[10];
// Byte 87 : CHAR  RCFirmwareVersion[11];
// Byte 88 : CHAR  RCInterpreterVersion[0];
// Byte 89 : CHAR  RCInterpreterVersion[1];
// Byte 90 : CHAR  RCInterpreterVersion[2];
// Byte 91 : BYTE  Reserved;
// Byte 92 : BYTE  AxisJointUsed;
// Byte 93 : BYTE  AxisExternalUsed;
// Byte 94 : BYTE  AxisJointUnit;
// Byte 95 : BYTE  AxisExternalUnit;
// Byte 96 : BYTE  RCSupportedFunctions[0];
// Byte 97 : BYTE  RCSupportedFunctions[1];
// Byte 98 : BYTE  RCSupportedFunctions[2];
// Byte 99 : BYTE  RCSupportedFunctions[3];
// Byte 100: BYTE  RCSupportedFunctions[4];
// Byte 101: BYTE  RCSupportedFunctions[5];
// Byte 102: BYTE  RCSupportedFunctions[6];
// Byte 103: BYTE  RCSupportedFunctions[7];
// Byte 104: BYTE  RCSupportedFunctions[8];
// Byte 105: BYTE  RCSupportedFunctions[9];
// Byte 106: BYTE  RCSupportedFunctions[10];
// Byte 107: BYTE  RCSupportedFunctions[11];
// Byte 108: BYTE  RCSupportedFunctions[12];
// Byte 109: BYTE  RCSupportedFunctions[13];
// Byte 110: BYTE  RCSupportedFunctions[14];
// Byte 111: BYTE  RCSupportedFunctions[15];
// Byte 112: BYTE  RCSupportedFunctions[16];
// Byte 113: BYTE  RCSupportedFunctions[17];
// Byte 114: BYTE  RCSupportedFunctions[18];
// Byte 115: BYTE  Reserved;
// Byte 116: CHAR  RobotID[0];
// Byte 117: CHAR  RobotID[1];
// Byte 118: CHAR  RobotID[2];
// Byte 119: CHAR  RobotID[3];
// Byte 120: CHAR  RobotID[4];
// Byte 121: CHAR  RobotID[5];
// Byte 122: CHAR  RobotID[6];
// Byte 123: CHAR  RobotID[7];
// Byte 124: CHAR  RobotID[8];
// Byte 125: CHAR  RobotID[9];
// Byte 126: CHAR  RobotID[10];
// Byte 127: CHAR  RobotID[11];
// Byte 128: CHAR  RobotID[12];
// Byte 129: CHAR  RobotID[13];
// Byte 130: CHAR  RobotID[14];
// Byte 131: CHAR  RobotID[15];
// Byte 132: UINT  InterpreterCycleTime HW HB;
// Byte 133:       InterpreterCycleTime HW LB;
// --------------------------

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  // Get _response.RCManufacturer
  ResponseData.GetDataBlock(pData := ADR(_response.RCManufacturer)      , SIZEOF(_response.RCManufacturer   )   , IsString := TRUE );
  // Get _response.RCOrderID
  ResponseData.GetDataBlock(pData := ADR(_response.RCOrderID)           , SIZEOF(_response.RCOrderID        )   , IsString := TRUE );
  // Get _response.RCSerialNumber
  ResponseData.GetDataBlock(pData := ADR(_response.RCSerialNumber)      , SIZEOF(_response.RCSerialNumber   )   , IsString := TRUE );
  // Get _response.RASerialNumber
  ResponseData.GetDataBlock(pData := ADR(_response.RASerialNumber)      , SIZEOF(_response.RASerialNumber   )   , IsString := TRUE );
  // Get _response.RCFirmwareVersion
  ResponseData.GetDataBlock(pData := ADR(_response.RCFirmwareVersion)   , SIZEOF(_response.RCFirmwareVersion)   , IsString := TRUE );
  // Get _response.RCInterpreterVersion
  ResponseData.GetDataBlock(pData := ADR(_response.RCInterpreterVersion), SIZEOF(_response.RCInterpreterVersion), IsString := TRUE );
  
  // Get _response.Reserve
  _response.Reserve := ResponseData.GetByte(); 
  // Get _response.AxisJointUsed
  _response.AxisJointUsed := ResponseData.GetByte(); 
  // Get _response.AxisExternalUsed
  _response.AxisExternalUsed := ResponseData.GetByte(); 
  // Get _response.AxisJointUnit
  _response.AxisJointUnit := ResponseData.GetByte(); 
  // Get _response.AxisExternalUnit
  _response.AxisExternalUnit := ResponseData.GetByte();
  // Get _response.RCSupportedFunctions
  ResponseData.GetDataBlock(pData := ADR(_response.RCSupportedFunctions), SIZEOF(_response.RCSupportedFunctions), IsString := FALSE );
  // Get _response.Reserve2
  _response.Reserve2 := ResponseData.GetByte(); 
  // Get _response.RobotID
  ResponseData.GetDataBlock(pData := ADR(_response.RobotID)             , SIZEOF(_response.RobotID)             , IsString := TRUE );
  // Get _response.InterpreterCycleTime
  _response.InterpreterCycleTime := ResponseData.GetUsint(); 
  
  // Create logging
  ParseResponsePayloadLog(ResponseData := ResponseData, Timestamp := Timestamp);

END_METHOD

METHOD INTERNAL ParseResponsePayloadLog
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
  /// Timestamp
  Timestamp    : SystemTime;  
END_VAR
VAR 
  /// internal index for loops
 _idx : DINT;
  /// temporary string
 _tmpStr : STRING;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
  
  // Create log entry for RCManufacturer
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCManufacturer = {1}',
                          Para1       := _response.RCManufacturer);
  
  // Create log entry for RCOrderID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCOrderID = {1}',
                          Para1       := _response.RCOrderID);
  
  // Create log entry for RCSerialNumber
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCSerialNumber = {1}',
                          Para1       := _response.RCSerialNumber);
  
  // Create log entry for RASerialNumber
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RASerialNumber = {1}',
                          Para1       := _response.RASerialNumber);
  
  // Create log entry for RCFirmwareVersion
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCFirmwareVersion = {1}',
                          Para1       := _response.RCFirmwareVersion);
                          
  // Create log entry for RCInterpreterVersion
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCInterpreterVersion = {1}',
                          Para1       := _response.RCInterpreterVersion);
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve));
  
  // Create log entry for AxisJointUsed
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.AxisJointUsed = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.AxisJointUsed));
  
  // Create log entry for AxisExternalUsed
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.AxisExternalUsed = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.AxisExternalUsed));
  
  // Create log entry for AxisJointUnit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.AxisJointUnit = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.AxisJointUnit));
  
  // Create log entry for AxisExternalUnit
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.AxisExternalUnit = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.AxisExternalUnit));
  
  FOR _idx := 0 TO 18
  do
   _tmpStr := '16#';
   _tmpStr := CONCAT( _tmpStr, BYTE_TO_STRING_BIN(_response.RCSupportedFunctions[_idx]));
  
    // Create log entry for RCSupportedFunctions
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.RCSupportedFunctions[{2}] = {1}',
                            Para1       := _tmpStr,
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for Reserve2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve2 = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve2));
  
  // Create log entry for RobotID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RobotID = {1}',
                          Para1       :=  _response.RobotID);
  
  // Create log entry for InterpreterCycleTime
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.InterpreterCycleTime = {1}',
                          Para1       :=  UINT_TO_STRING(_response.InterpreterCycleTime));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

