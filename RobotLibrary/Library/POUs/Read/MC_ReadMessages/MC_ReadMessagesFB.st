/// Read error codes of pending errors and move them into user data block "RobotData"
FUNCTION_BLOCK MC_ReadMessagesFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadMessagesFB                                       
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
  ParCmd          : ReadMessagesParCmd;
END_VAR
VAR_OUTPUT
  /// TRUE, while the following outputs return valid values:
  /// • Values
  Valid           : BOOL; 
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command outputs
  OutCmd          : ReadMessagesOutCmd;  
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReadMessagesParCmd;
  /// command data to send
 _command            : ReadMessagesSendData;
  /// response data received
 _response           : ReadMessagesRecvData;      
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

  CheckFunctionSupported := TRUE; // Function is mandatory 
  RETURN;
  
  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ReadMessages;
  
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
  
  // Check ParCmd.MsgID valid ? 
  IF (( ParCmd.MsgID <   0 ) OR  
      ( ParCmd.MsgID > 255 ))
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
                            MessageText := 'Invalid Parameter ParCmd.MsgID = {1}',
                            Para1       :=  INT_TO_STRING(ParCmd.MsgID));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.MessageLevel valid ? 
  IF (( ParCmd.MessageLevel <> MessageLevel.DEBUG   ) AND 
      ( ParCmd.MessageLevel <> MessageLevel.INFO    ) AND
      ( ParCmd.MessageLevel <> MessageLevel.WARNING ) AND
      ( ParCmd.MessageLevel <> MessageLevel.ERROR   ))
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
                            MessageText := 'Invalid Parameter ParCmd.MessageLevel = {1}',
                            Para1       :=  MESSAGE_LEVEL_TO_STRING(ParCmd.MessageLevel));
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
// Table 6-107: Sent CMD payload (PLC to RC) of "ReadMessages"
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
// Byte 04 : USINT  MsgID;
// Byte 05 : BOOL   Enable;
// Byte 06 : USINT  MessageLevel;
// --------------------------

  // set command parameter 
  _command.CmdTyp       :=  CmdType.ReadMessages;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.MsgID        := _parCmd.MsgID;
  _command.Enable       :=  Enable;
  _command.MessageLevel := _parCmd.MessageLevel;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.MsgID
    CreateCommandPayload.AddUsint(_command.MsgID);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.Enable
    CreateCommandPayload.AddBool(_command.Enable);
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;  
  END_IF
  
  
  // Check parameter must be added ? 
  IF ( CheckAddParameter(CreateCommandPayload.PayloadPtr))
  THEN
    // add command.MessageLevel
    CreateCommandPayload.AddUsint(_command.MessageLevel);
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
  // Create log entry for MsgID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MsgID = {1}',
                          Para1       :=  USINT_TO_STRING(_command.MsgID));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Enable
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Enable = {1}',
                          Para1       :=  BOOL_TO_STRING(_command.Enable));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for MessageLevel
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MessageLevel = {1}',
                          Para1       :=  USINT_TO_STRING(_command.MessageLevel));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadMessagesFB';
  
  ExecMode := ExecutionMode.PARALLEL;
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
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  // call base implementation
  SUPER^.OnExecRun(AxesGroup := AxesGroup);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q ) AND ( NOT Error) 
         THEN
           // reset the rising edge
          _enable_R();       
          
           // Check function is supported and parameter are valid ?
           IF (( CheckFunctionSupported( AxesGroup := AxesGroup )) AND
               ( CheckParameterValid   ( AxesGroup := AxesGroup )))
           THEN      
             // Reset all internal flags
             Reset();
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
             CmdMessageState.ERROR    : Error           := TRUE;
             CmdMessageState.ACTIVE   : 
  
             // Add message to message buffer       
             AxesGroup.MessageLog.AddMessageLogByParameter
               (   Timestamp   := IEC_TIMESTAMP_TO_SYSTEMTIME(_response.Timestamp),
                   MessageType :=                             _response.MsgType,
                   MessageCode :=                             _response.ErrorCode,
                   MessageText :=                             _response.Text,
                   Severity    :=                             _response.Severity
               );
           END_CASE
   
           // Update results
           Enabled                       := _response.Enabled;
           OutCmd.MsgId                  := _response.MsgId;
           OutCmd.NumberOfActiveErrors   := _response.NumberOfActiveErrors;
           OutCmd.NumberOfActiveWarnings := _response.NumberOfActiveWarnings;
           OutCmd.Timestamp              := _response.Timestamp;
           OutCmd.MsgType                := _response.MsgType;
           OutCmd.Severity               := _response.Severity;
           OutCmd.ErrorCode              := _response.ErrorCode;
           OutCmd.Text                   := _response.Text;
  
           // Enabled, Aborted or Error ? -> Reset Busy flag  
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
// Table 6-108: Received CMD payload (RC to PLC) of "ReadMessages"
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
// Byte 04 : USINT       MsgID;
// Byte 05 : BOOL        Enabled;

// Byte 06 : USINT       NumberOfActiveErrors;
// Byte 07 : USINT       NumberOfActiveWarnings;
// Byte 08 : DATE        Date HW HB;
// Byte 09 :             Date HW LB;
// Byte 10 : TIME_OF_DAY Time HW HB;
// Byte 11 :             Time HW LB;
// Byte 12 :             Time LW HB;
// Byte 13 :             Time LW LB;
// Byte 14 : USINT       MsgType;
// Byte 15 : SINT        Severity;
// Byte 16 : DWORD       ErrorCode HW HB;
// Byte 17 :             ErrorCode HW LB;
// Byte 18 :             ErrorCode LW HB;
// Byte 19 :             ErrorCode LW LB;
// Byte 20 : CHAR        Text[0];
// Byte 21 : CHAR        Text[1];
// Byte 22 : CHAR        Text[2];
// Byte 23 : CHAR        Text[3];
// Byte 24 : CHAR        Text[4];
// Byte 25 : CHAR        Text[5];
// Byte 26 : CHAR        Text[6];
// Byte 27 : CHAR        Text[7];
// Byte 28 : CHAR        Text[8];
// Byte 29 : CHAR        Text[9];
// Byte 30 : CHAR        Text[10];
// Byte 31 : CHAR        Text[11];
// Byte 32 : CHAR        Text[12];
// Byte 33 : CHAR        Text[13];
// Byte 34 : CHAR        Text[14];
// Byte 35 : CHAR        Text[15];
// Byte 36 : CHAR        Text[16];
// Byte 37 : CHAR        Text[17];
// Byte 38 : CHAR        Text[18];
// Byte 39 : CHAR        Text[19];
// Byte 40 : CHAR        Text[20];
// Byte 41 : CHAR        Text[21];
// Byte 42 : CHAR        Text[22];
// Byte 43 : CHAR        Text[23];
// Byte 44 : CHAR        Text[24];
// Byte 45 : CHAR        Text[25];
// Byte 46 : CHAR        Text[26];
// Byte 47 : CHAR        Text[27];
// Byte 48 : CHAR        Text[28];
// Byte 49 : CHAR        Text[29];
// Byte 50 : CHAR        Text[30];
// Byte 51 : CHAR        Text[31];
// Byte 52 : CHAR        Text[32];
// Byte 53 : CHAR        Text[33];
// Byte 54 : CHAR        Text[34];
// Byte 55 : CHAR        Text[35];
// Byte 56 : CHAR        Text[36];
// Byte 57 : CHAR        Text[37];
// Byte 58 : CHAR        Text[38];
// Byte 59 : CHAR        Text[39];
// Byte 60 : CHAR        Text[40];
// Byte 61 : CHAR        Text[41];
// Byte 62 : CHAR        Text[42];
// Byte 63 : CHAR        Text[43];
// Byte 64 : CHAR        Text[44];
// Byte 65 : CHAR        Text[45];
// Byte 66 : CHAR        Text[46];
// Byte 67 : CHAR        Text[47];
// Byte 68 : CHAR        Text[48];
// Byte 69 : CHAR        Text[49];
// Byte 70 : CHAR        Text[50];
// Byte 71 : CHAR        Text[51];
// Byte 72 : CHAR        Text[52];
// Byte 73 : CHAR        Text[53];
// Byte 74 : CHAR        Text[54];
// Byte 75 : CHAR        Text[55];
// Byte 76 : CHAR        Text[56];
// Byte 77 : CHAR        Text[57];
// Byte 78 : CHAR        Text[58];
// Byte 79 : CHAR        Text[59];
// Byte 80 : CHAR        Text[60];
// Byte 81 : CHAR        Text[61];
// Byte 82 : CHAR        Text[62];
// Byte 83 : CHAR        Text[63];
// Byte 84 : CHAR        Text[64];
// Byte 85 : CHAR        Text[65];
// Byte 86 : CHAR        Text[66];
// Byte 87 : CHAR        Text[67];
// Byte 88 : CHAR        Text[68];
// Byte 89 : CHAR        Text[69];
// Byte 90 : CHAR        Text[70];
// Byte 91 : CHAR        Text[71];
// Byte 92 : CHAR        Text[72];
// Byte 93 : CHAR        Text[73];
// Byte 94 : CHAR        Text[74];
// Byte 95 : CHAR        Text[75];
// Byte 96 : CHAR        Text[76];
// Byte 97 : CHAR        Text[77];
// Byte 98 : CHAR        Text[78];
// Byte 99 : CHAR        Text[79];
// Byte 100: CHAR        Text[80];
// Byte 101: CHAR        Text[81];
// Byte 102: CHAR        Text[82];
// Byte 103: CHAR        Text[83];
// Byte 104: CHAR        Text[84];
// Byte 105: CHAR        Text[85];
// Byte 106: CHAR        Text[86];
// Byte 107: CHAR        Text[87];
// Byte 108: CHAR        Text[88];
// Byte 109: CHAR        Text[89];
// Byte 110: CHAR        Text[90];
// Byte 111: CHAR        Text[91];
// Byte 112: CHAR        Text[92];
// Byte 113: CHAR        Text[93];
// Byte 114: CHAR        Text[94];
// Byte 115: CHAR        Text[95];
// Byte 116: CHAR        Text[96];
// Byte 117: CHAR        Text[97];
// Byte 118: CHAR        Text[98];
// Byte 119: CHAR        Text[99];
// Byte 120: CHAR        Text[100];
// Byte 121: CHAR        Text[101];
// Byte 122: CHAR        Text[102];
// Byte 123: CHAR        Text[103];
// Byte 124: CHAR        Text[104];
// Byte 125: CHAR        Text[105];
// Byte 126: CHAR        Text[106];
// Byte 127: CHAR        Text[107];
// Byte 128: CHAR        Text[108];
// Byte 129: CHAR        Text[109];
// Byte 130: CHAR        Text[110];
// Byte 131: CHAR        Text[111];
// Byte 132: CHAR        Text[112];
// Byte 133: CHAR        Text[113];
// Byte 134: CHAR        Text[114];
// Byte 135: CHAR        Text[115];
// Byte 136: CHAR        Text[116];
// Byte 137: CHAR        Text[117];
// Byte 138: CHAR        Text[118];
// Byte 139: CHAR        Text[119];
// Byte 140: CHAR        Text[120];
// Byte 141: CHAR        Text[121];
// Byte 142: CHAR        Text[122];
// Byte 143: CHAR        Text[123];
// Byte 144: CHAR        Text[124];
// Byte 145: CHAR        Text[125];
// Byte 146: CHAR        Text[126];
// Byte 147: CHAR        Text[127];
// Byte 148: CHAR        Text[128];
// Byte 149: CHAR        Text[129];
// Byte 150: CHAR        Text[130];
// Byte 151: CHAR        Text[131];
// Byte 152: CHAR        Text[132];
// Byte 153: CHAR        Text[133];
// Byte 154: CHAR        Text[134];
// Byte 155: CHAR        Text[135];
// Byte 156: CHAR        Text[136];
// Byte 157: CHAR        Text[137];
// Byte 158: CHAR        Text[138];
// Byte 159: CHAR        Text[139];
// Byte 160: CHAR        Text[140];
// Byte 161: CHAR        Text[141];
// Byte 162: CHAR        Text[142];
// Byte 163: CHAR        Text[143];
// Byte 164: CHAR        Text[144];
// Byte 165: CHAR        Text[145];
// Byte 166: CHAR        Text[146];
// Byte 167: CHAR        Text[147];
// Byte 168: CHAR        Text[148];
// Byte 169: CHAR        Text[149];
// --------------------------

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
    // Get Response.MsgID
   _response.MsgID := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Enabled
   _response.Enabled := ResponseData.GetBool();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.NumberOfActiveErrors
   _response.NumberOfActiveErrors := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.NumberOfActiveWarnings
   _response.NumberOfActiveWarnings := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Timestamp.IEC_DATE
   _response.Timestamp.IEC_DATE := ResponseData.GetIecDate();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Timestamp.IEC_TIME
   _response.Timestamp.IEC_TIME := ResponseData.GetIecTime();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.MsgType
   _response.MsgType := ResponseData.GetUsint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
  
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.Severity
   _response.Severity := ResponseData.GetSint();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
   
   
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get Response.ErrorCode
   _response.ErrorCode := ResponseData.GetDword();
    // inc parameter counter
   _parameterCnt := _parameterCnt + 1;
  END_IF
  
   
  // Check payload remaining ? 
  IF ( ResponseData.IsPayloadRemaining)
  THEN  
    // Get _response.RCManufacturer
    ResponseData.GetDataBlock(pData := ADR(_response.Text) , SIZEOF(_response.Text) , IsString := TRUE );
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
  // Create log entry for Enabled
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Enabled = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.Enabled));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for MsgID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.MsgID = {1}',
                          Para1       :=  USINT_TO_STRING(_response.MsgID));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for NumberOfActiveErrors
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.NumberOfActiveErrors = {1}',
                          Para1       :=  USINT_TO_STRING(_response.NumberOfActiveErrors));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for NumberOfActiveWarnings
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.NumberOfActiveWarnings = {1}',
                          Para1       :=  USINT_TO_STRING(_response.NumberOfActiveWarnings));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Timestamp.IEC_DATE
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Timestamp.IEC_DATE = {1}',
                          Para1       :=  IEC_DATE_TO_STRING(_response.Timestamp.IEC_DATE));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Timestamp.IEC_TIME
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Timestamp.IEC_TIME = {1}',
                          Para1       :=  IEC_TIME_TO_STRING(_response.Timestamp.IEC_TIME));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for MsgType
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.MsgType = {1}',
                          Para1       :=  USINT_TO_STRING(_response.MsgType));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Severity
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Severity = {1}',
                          Para1       :=  SEVERITY_TO_STRING(_response.Severity,AlignString := FALSE));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for ErrorCode
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ErrorCode = {1}',
                          Para1       :=  DWORD_TO_STRING(_response.ErrorCode));
  
  
  // Return if no parameter is remaining...
  IF ( ParameterCnt = 0 ) THEN RETURN; END_IF
  // dec remaining parameter(s)                        
  ParameterCnt := ParameterCnt - 1;
  // Create log entry for Text
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Text = {1}',
                          Para1       :=  _response.Text);

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  Valid              := FALSE; 
  CommandBuffered    := FALSE;

END_METHOD

