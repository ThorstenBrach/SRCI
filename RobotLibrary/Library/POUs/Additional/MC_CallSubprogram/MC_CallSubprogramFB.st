/// Call subprogram stored in RC from PLC
FUNCTION_BLOCK MC_CallSubprogramFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CallSubprogramFB                                       
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
  ParCmd             : CallSubprogramParCmd;
  /// Processing mode
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;
END_VAR

VAR_OUTPUT
  /// TRUE while the output ReturnData returns valid data according to the user defined subprogram
  Valid              : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The requested subprogram on the RC is in progress. Movement of the axes trough this subprogram is possible.  
  InProgress         : BOOL;
  /// The command was aborted by another command
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted  : BOOL;
  /// command outputs
  OutCmd             : CallSubprogramOutCmd;       
END_VAR



VAR
  /// internal copy of command parameter 
 _parCmd             : CallSubprogramParCmd;
  /// command data to send
 _command            : CallSubprogramSendData;
  /// response data received
 _response           : CallSubprogramRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RCSupportedFunctions.CallSubprogram;
  
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
    CommandData := CreateCommandPayload(AxesGroup := AxesGroup); // ( Access via reference to rCommandFB in ACR )
    // notify active command register 
    AxesGroup.Acyclic.ActiveCommandRegister.NotifyParameterChanged := _uniqueID;  
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-687: Sent CMD payload (PLC to RC) of "CallSubprogram"
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
// Byte 10 : UINT  JobID;
// Byte 11 :       JobID;
// Byte 12 : BYTE  Data[0];
// Byte 13 : BYTE  Data[1];
// Byte 14 : BYTE  Data[2];
// Byte 15 : BYTE  Data[3];
// Byte 16 : BYTE  Data[4];
// Byte 17 : BYTE  Data[5];
// Byte 18 : BYTE  Data[6];
// Byte 19 : BYTE  Data[7];
// Byte 20 : BYTE  Data[8];
// Byte 21 : BYTE  Data[9];
// Byte 22 : BYTE  Data[10];
// Byte 23 : BYTE  Data[11];
// Byte 24 : BYTE  Data[12];
// Byte 25 : BYTE  Data[13];
// Byte 26 : BYTE  Data[14];
// Byte 27 : BYTE  Data[15];
// Byte 28 : BYTE  Data[16];
// Byte 29 : BYTE  Data[17];
// Byte 30 : BYTE  Data[18];
// Byte 31 : BYTE  Data[19];
// Byte 32 : BYTE  Data[20];
// Byte 33 : BYTE  Data[21];
// Byte 34 : BYTE  Data[22];
// Byte 35 : BYTE  Data[23];
// Byte 36 : BYTE  Data[24];
// Byte 37 : BYTE  Data[25];
// Byte 38 : BYTE  Data[26];
// Byte 39 : BYTE  Data[27];
// Byte 40 : BYTE  Data[28];
// Byte 41 : BYTE  Data[29];
// Byte 42 : BYTE  Data[30];
// Byte 43 : BYTE  Data[31];
// Byte 44 : BYTE  Data[32];
// Byte 45 : BYTE  Data[33];
// Byte 46 : BYTE  Data[34];
// Byte 47 : BYTE  Data[35];
// Byte 48 : BYTE  Data[36];
// Byte 49 : BYTE  Data[37];
// Byte 50 : BYTE  Data[38];
// Byte 51 : BYTE  Data[39];
// Byte 52 : BYTE  Data[40];
// Byte 53 : BYTE  Data[41];
// Byte 54 : BYTE  Data[42];
// Byte 55 : BYTE  Data[43];
// Byte 56 : BYTE  Data[44];
// Byte 57 : BYTE  Data[45];
// Byte 58 : BYTE  Data[46];
// Byte 59 : BYTE  Data[47];
// Byte 60 : BYTE  Data[48];
// Byte 61 : BYTE  Data[49];
// Byte 62 : BYTE  Data[50];
// Byte 63 : BYTE  Data[51];
// Byte 64 : BYTE  Data[52];
// Byte 65 : BYTE  Data[53];
// Byte 66 : BYTE  Data[54];
// Byte 67 : BYTE  Data[55];
// Byte 68 : BYTE  Data[56];
// Byte 69 : BYTE  Data[57];
// Byte 70 : BYTE  Data[58];
// Byte 71 : BYTE  Data[59];
// Byte 72 : BYTE  Data[60];
// Byte 73 : BYTE  Data[61];
// Byte 74 : BYTE  Data[62];
// Byte 75 : BYTE  Data[63];
// Byte 76 : BYTE  Data[64];
// Byte 77 : BYTE  Data[65];
// Byte 78 : BYTE  Data[66];
// Byte 79 : BYTE  Data[67];
// Byte 80 : BYTE  Data[68];
// Byte 81 : BYTE  Data[69];
// Byte 82 : BYTE  Data[70];
// Byte 83 : BYTE  Data[71];
// Byte 84 : BYTE  Data[72];
// Byte 85 : BYTE  Data[73];
// Byte 86 : BYTE  Data[74];
// Byte 87 : BYTE  Data[75];
// Byte 88 : BYTE  Data[76];
// Byte 89 : BYTE  Data[77];
// Byte 90 : BYTE  Data[78];
// Byte 91 : BYTE  Data[79];
// Byte 92 : BYTE  Data[80];
// Byte 93 : BYTE  Data[81];
// Byte 94 : BYTE  Data[82];
// Byte 95 : BYTE  Data[83];
// Byte 96 : BYTE  Data[84];
// Byte 97 : BYTE  Data[85];
// Byte 98 : BYTE  Data[86];
// Byte 99 : BYTE  Data[87];
// Byte 100: BYTE  Data[88];
// Byte 101: BYTE  Data[89];
// Byte 102: BYTE  Data[90];
// Byte 103: BYTE  Data[91];
// Byte 104: BYTE  Data[92];
// Byte 105: BYTE  Data[93];
// Byte 106: BYTE  Data[94];
// Byte 107: BYTE  Data[95];
// Byte 108: BYTE  Data[96];
// Byte 109: BYTE  Data[97];
// Byte 110: BYTE  Data[98];
// Byte 111: BYTE  Data[99];
// Byte 112: BYTE  Data[100];
// Byte 113: BYTE  Data[101];
// Byte 114: BYTE  Data[102];
// Byte 115: BYTE  Data[103];
// Byte 116: BYTE  Data[104];
// Byte 117: BYTE  Data[105];
// Byte 118: BYTE  Data[106];
// Byte 119: BYTE  Data[107];
// Byte 120: BYTE  Data[108];
// Byte 121: BYTE  Data[109];
// Byte 122: BYTE  Data[110];
// Byte 123: BYTE  Data[111];
// Byte 124: BYTE  Data[112];
// Byte 125: BYTE  Data[113];
// Byte 126: BYTE  Data[114];
// Byte 127: BYTE  Data[115];
// Byte 128: BYTE  Data[116];
// Byte 129: BYTE  Data[117];
// Byte 130: BYTE  Data[118];
// Byte 131: BYTE  Data[119];
// Byte 132: BYTE  Data[120];
// Byte 133: BYTE  Data[121];
// Byte 134: BYTE  Data[122];
// Byte 135: BYTE  Data[123];
// Byte 136: BYTE  Data[124];
// Byte 137: BYTE  Data[125];
// Byte 138: BYTE  Data[126];
// Byte 139: BYTE  Data[127];
// Byte 140: BYTE  Data[128];
// Byte 141: BYTE  Data[129];
// Byte 142: BYTE  Data[130];
// Byte 143: BYTE  Data[131];
// Byte 144: BYTE  Data[132];
// Byte 145: BYTE  Data[133];
// Byte 146: BYTE  Data[134];
// Byte 147: BYTE  Data[135];
// Byte 148: BYTE  Data[136];
// Byte 149: BYTE  Data[137];
// Byte 150: BYTE  Data[138];
// Byte 151: BYTE  Data[139];
// Byte 152: BYTE  Data[140];
// Byte 153: BYTE  Data[141];
// Byte 154: BYTE  Data[142];
// Byte 155: BYTE  Data[143];
// Byte 156: BYTE  Data[144];
// Byte 157: BYTE  Data[145];
// Byte 158: BYTE  Data[146];
// Byte 159: BYTE  Data[147];
// Byte 160: BYTE  Data[148];
// Byte 161: BYTE  Data[149];
// Byte 162: BYTE  Data[150];
// Byte 163: BYTE  Data[151];
// Byte 164: BYTE  Data[152];
// Byte 165: BYTE  Data[153];
// Byte 166: BYTE  Data[154];
// Byte 167: BYTE  Data[155];
// Byte 168: BYTE  Data[156];
// Byte 169: BYTE  Data[157];
// Byte 170: BYTE  Data[158];
// Byte 171: BYTE  Data[159];
// Byte 172: BYTE  Data[160];
// Byte 173: BYTE  Data[161];
// Byte 174: BYTE  Data[162];
// Byte 175: BYTE  Data[163];
// Byte 176: BYTE  Data[164];
// Byte 177: BYTE  Data[165];
// Byte 178: BYTE  Data[166];
// Byte 179: BYTE  Data[167];
// Byte 180: BYTE  Data[168];
// Byte 181: BYTE  Data[169];
// Byte 182: BYTE  Data[170];
// Byte 183: BYTE  Data[171];
// Byte 184: BYTE  Data[172];
// Byte 185: BYTE  Data[173];
// Byte 186: BYTE  Data[174];
// Byte 187: BYTE  Data[175];
// Byte 188: BYTE  Data[176];
// Byte 189: BYTE  Data[177];
// Byte 190: BYTE  Data[178];
// Byte 191: BYTE  Data[179];
// Byte 192: BYTE  Data[180];
// Byte 193: BYTE  Data[181];
// Byte 194: BYTE  Data[182];
// Byte 195: BYTE  Data[183];
// Byte 196: BYTE  Data[184];
// Byte 197: BYTE  Data[185];
// Byte 198: BYTE  Data[186];
// Byte 199: BYTE  Data[187];
// Byte 200: BYTE  Data[188];
// Byte 201: BYTE  Data[189];
VAR
  /// internal index for loops
  _idx : DINT;
END_VAR

  // set command parameter 
  _command.CmdTyp       :=  CmdType.CallSubprogram;
  _command.ExecMode     :=  ExecMode;
  _command.ParSeq       := _command.ParSeq;
  _command.Priority     :=  Priority;
  _command.EmitterID[0] :=  0;
  _command.EmitterID[1] :=  0;
  _command.EmitterID[2] :=  0;
  _command.EmitterID[3] :=  0;
  _command.Reserve      :=  0;
  _command.ListenerID   := _parCmd.ListenerID;
  _command.Reserve      := 0;
  _command.JobID        := _parCmd.JobID;
  _command.Data         := _parCmd.Data;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
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
  // add command.JobID
  CreateCommandPayload.AddUint(_command.JobID);
  
  FOR _idx := 0 TO RobotLibraryParameter.SUB_PROGRAM_DATA_MAX
  DO
    // add command.Data[_idx]
    CreateCommandPayload.AddByte(_command.Data[_idx]);
  END_FOR
  
  // Create logging
  CreateCommandPayloadLog(AxesGroup := AxesGroup);

END_METHOD

METHOD INTERNAL CreateCommandPayloadLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'CreateCommandPayload with the following parameter(s) :');
    
  // Create log entry for EmitterID[x]
  FOR _idx := 0 TO 3
  DO
    CreateLogMessagePara2 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Command.EmitterID[{2}] = {1}',
                            Para1       :=  SINT_TO_STRING(_command.EmitterID[_idx]),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  // Create log entry for ListenerID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.ListenerID = {1}',
                          Para1       :=  SINT_TO_STRING(_command.ListenerID));
  
  // Create log entry for Reserve
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve));
  
  // Create log entry for JobID
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.JobID = {1}',
                          Para1       :=  UINT_TO_STRING(_command.JobID));
  
  FOR _idx := 0 TO RobotLibraryParameter.SUB_PROGRAM_DATA_MAX
  DO
    // Create log entry for Data
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := StrReplace('Command.Data[{0}] = {1}', '{0}', DINT_TO_STRING(_idx)), 
                            Para1       :=  UINT_TO_STRING(_command.Data[_idx]));
  END_FOR

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_CallSubprogramFB';
  
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
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;           
             CmdMessageState.DONE        : Done               := TRUE;           
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
                  
           InProgress := _response.InProgress;
           
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.InstanceID        := 0; {warning 'ToDo'}
             OutCmd.OriginID          := _response.OriginID;
             OutCmd.InvocationCounter := _response.InvocationCounter;
             OutCmd.ReturnData        := _response.ReturnData;
   
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
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

// Table 6-688: Received CMD payload (RC to PLC) of "CallSubprogram"
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
// Byte 04 : USINT InvocationCounter;
// Byte 05 : SINT  Reserved;
// Byte 06 : INT   OriginID;
// Byte 07 :       OriginID;
// Byte 08 : UINT  Progress;
// Byte 09 :       Progress;
// Byte 10 : BOOL  InProgress;
// Byte 11 : BYTE  ReturnData[0];
// Byte 12 : BYTE  ReturnData[1];
// Byte 13 : BYTE  ReturnData[2];
// Byte 14 : BYTE  ReturnData[3];
// Byte 15 : BYTE  ReturnData[4];
// Byte 16 : BYTE  ReturnData[5];
// Byte 17 : BYTE  ReturnData[6];
// Byte 18 : BYTE  ReturnData[7];
// Byte 19 : BYTE  ReturnData[8];
// Byte 20 : BYTE  ReturnData[9];
// Byte 21 : BYTE  ReturnData[10];
// Byte 22 : BYTE  ReturnData[11];
// Byte 23 : BYTE  ReturnData[12];
// Byte 24 : BYTE  ReturnData[13];
// Byte 25 : BYTE  ReturnData[14];
// Byte 26 : BYTE  ReturnData[15];
// Byte 27 : BYTE  ReturnData[16];
// Byte 28 : BYTE  ReturnData[17];
// Byte 29 : BYTE  ReturnData[18];
// Byte 30 : BYTE  ReturnData[19];
// Byte 31 : BYTE  ReturnData[20];
// Byte 32 : BYTE  ReturnData[21];
// Byte 33 : BYTE  ReturnData[22];
// Byte 34 : BYTE  ReturnData[23];
// Byte 35 : BYTE  ReturnData[24];
// Byte 36 : BYTE  ReturnData[25];
// Byte 37 : BYTE  ReturnData[26];
// Byte 38 : BYTE  ReturnData[27];
// Byte 39 : BYTE  ReturnData[28];
// Byte 40 : BYTE  ReturnData[29];
// Byte 41 : BYTE  ReturnData[30];
// Byte 42 : BYTE  ReturnData[31];
// Byte 43 : BYTE  ReturnData[32];
// Byte 44 : BYTE  ReturnData[33];
// Byte 45 : BYTE  ReturnData[34];
// Byte 46 : BYTE  ReturnData[35];
// Byte 47 : BYTE  ReturnData[36];
// Byte 48 : BYTE  ReturnData[37];
// Byte 49 : BYTE  ReturnData[38];
// Byte 50 : BYTE  ReturnData[39];
// Byte 51 : BYTE  ReturnData[40];
// Byte 52 : BYTE  ReturnData[41];
// Byte 53 : BYTE  ReturnData[42];
// Byte 54 : BYTE  ReturnData[43];
// Byte 55 : BYTE  ReturnData[44];
// Byte 56 : BYTE  ReturnData[45];
// Byte 57 : BYTE  ReturnData[46];
// Byte 58 : BYTE  ReturnData[47];
// Byte 59 : BYTE  ReturnData[48];
// Byte 60 : BYTE  ReturnData[49];
// Byte 61 : BYTE  ReturnData[50];
// Byte 62 : BYTE  ReturnData[51];
// Byte 63 : BYTE  ReturnData[52];
// Byte 64 : BYTE  ReturnData[53];
// Byte 65 : BYTE  ReturnData[54];
// Byte 66 : BYTE  ReturnData[55];
// Byte 67 : BYTE  ReturnData[56];
// Byte 68 : BYTE  ReturnData[57];
// Byte 69 : BYTE  ReturnData[58];
// Byte 70 : BYTE  ReturnData[59];
// Byte 71 : BYTE  ReturnData[60];
// Byte 72 : BYTE  ReturnData[61];
// Byte 73 : BYTE  ReturnData[62];
// Byte 74 : BYTE  ReturnData[63];
// Byte 75 : BYTE  ReturnData[64];
// Byte 76 : BYTE  ReturnData[65];
// Byte 77 : BYTE  ReturnData[66];
// Byte 78 : BYTE  ReturnData[67];
// Byte 79 : BYTE  ReturnData[68];
// Byte 80 : BYTE  ReturnData[69];
// Byte 81 : BYTE  ReturnData[70];
// Byte 82 : BYTE  ReturnData[71];
// Byte 83 : BYTE  ReturnData[72];
// Byte 84 : BYTE  ReturnData[73];
// Byte 85 : BYTE  ReturnData[74];
// Byte 86 : BYTE  ReturnData[75];
// Byte 87 : BYTE  ReturnData[76];
// Byte 88 : BYTE  ReturnData[77];
// Byte 89 : BYTE  ReturnData[78];
// Byte 90 : BYTE  ReturnData[79];
// Byte 91 : BYTE  ReturnData[80];
// Byte 92 : BYTE  ReturnData[81];
// Byte 93 : BYTE  ReturnData[82];
// Byte 94 : BYTE  ReturnData[83];
// Byte 95 : BYTE  ReturnData[84];
// Byte 96 : BYTE  ReturnData[85];
// Byte 97 : BYTE  ReturnData[86];
// Byte 98 : BYTE  ReturnData[87];
// Byte 99 : BYTE  ReturnData[88];
// Byte 100: BYTE  ReturnData[89];
// Byte 101: BYTE  ReturnData[90];
// Byte 102: BYTE  ReturnData[91];
// Byte 103: BYTE  ReturnData[92];
// Byte 104: BYTE  ReturnData[93];
// Byte 105: BYTE  ReturnData[94];
// Byte 106: BYTE  ReturnData[95];
// Byte 107: BYTE  ReturnData[96];
// Byte 108: BYTE  ReturnData[97];
// Byte 109: BYTE  ReturnData[98];
// Byte 110: BYTE  ReturnData[99];
// Byte 111: BYTE  ReturnData[100];
// Byte 112: BYTE  ReturnData[101];
// Byte 113: BYTE  ReturnData[102];
// Byte 114: BYTE  ReturnData[103];
// Byte 115: BYTE  ReturnData[104];
// Byte 116: BYTE  ReturnData[105];
// Byte 117: BYTE  ReturnData[106];
// Byte 118: BYTE  ReturnData[107];
// Byte 119: BYTE  ReturnData[108];
// Byte 120: BYTE  ReturnData[109];
// Byte 121: BYTE  ReturnData[110];
// Byte 122: BYTE  ReturnData[111];
// Byte 123: BYTE  ReturnData[112];
// Byte 124: BYTE  ReturnData[113];
// Byte 125: BYTE  ReturnData[114];
// Byte 126: BYTE  ReturnData[115];
// Byte 127: BYTE  ReturnData[116];
// Byte 128: BYTE  ReturnData[117];
// Byte 129: BYTE  ReturnData[118];
// Byte 130: BYTE  ReturnData[119];
// Byte 131: BYTE  ReturnData[120];
// Byte 132: BYTE  ReturnData[121];
// Byte 133: BYTE  ReturnData[122];
// Byte 134: BYTE  ReturnData[123];
// Byte 135: BYTE  ReturnData[124];
// Byte 136: BYTE  ReturnData[125];
// Byte 137: BYTE  ReturnData[126];
// Byte 138: BYTE  ReturnData[127];
// Byte 139: BYTE  ReturnData[128];
// Byte 140: BYTE  ReturnData[129];
// Byte 141: BYTE  ReturnData[130];
// Byte 142: BYTE  ReturnData[131];
// Byte 143: BYTE  ReturnData[132];
// Byte 144: BYTE  ReturnData[133];
// Byte 145: BYTE  ReturnData[134];
// Byte 146: BYTE  ReturnData[135];
// Byte 147: BYTE  ReturnData[136];
// Byte 148: BYTE  ReturnData[137];
// Byte 149: BYTE  ReturnData[138];
// Byte 150: BYTE  ReturnData[139];
// Byte 151: BYTE  ReturnData[140];
// Byte 152: BYTE  ReturnData[141];
// Byte 153: BYTE  ReturnData[142];
// Byte 154: BYTE  ReturnData[143];
// Byte 155: BYTE  ReturnData[144];
// Byte 156: BYTE  ReturnData[145];
// Byte 157: BYTE  ReturnData[146];
// Byte 158: BYTE  ReturnData[147];
// Byte 159: BYTE  ReturnData[148];
// Byte 160: BYTE  ReturnData[149];
// Byte 161: BYTE  ReturnData[150];
// Byte 162: BYTE  ReturnData[151];
// Byte 163: BYTE  ReturnData[152];
// Byte 164: BYTE  ReturnData[153];
// Byte 165: BYTE  ReturnData[154];
// Byte 166: BYTE  ReturnData[155];
// Byte 167: BYTE  ReturnData[156];
// Byte 168: BYTE  ReturnData[157];
// Byte 169: BYTE  ReturnData[158];
// Byte 170: BYTE  ReturnData[159];
// Byte 171: BYTE  ReturnData[160];
// Byte 172: BYTE  ReturnData[161];
// Byte 173: BYTE  ReturnData[162];
// Byte 174: BYTE  ReturnData[163];
// Byte 175: BYTE  ReturnData[164];
// Byte 176: BYTE  ReturnData[165];
// Byte 177: BYTE  ReturnData[166];
// Byte 178: BYTE  ReturnData[167];
// Byte 179: BYTE  ReturnData[168];
// Byte 180: BYTE  ReturnData[169];
// Byte 181: BYTE  ReturnData[170];
// Byte 182: BYTE  ReturnData[171];
// Byte 183: BYTE  ReturnData[172];
// Byte 184: BYTE  ReturnData[173];
// Byte 185: BYTE  ReturnData[174];
// Byte 186: BYTE  ReturnData[175];
// Byte 187: BYTE  ReturnData[176];
// Byte 188: BYTE  ReturnData[177];
// Byte 189: BYTE  ReturnData[178];
// Byte 190: BYTE  ReturnData[179];
// Byte 191: BYTE  ReturnData[180];
// Byte 192: BYTE  ReturnData[181];
// Byte 193: BYTE  ReturnData[182];
// Byte 194: BYTE  ReturnData[183];
// Byte 195: BYTE  ReturnData[184];
// Byte 196: BYTE  ReturnData[185];
// Byte 197: BYTE  ReturnData[186];
// Byte 198: BYTE  ReturnData[187];
// Byte 199: BYTE  ReturnData[188];
// Byte 200: BYTE  ReturnData[189];

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
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
  // Get Response.InProgress
  _response.InProgress := ResponseData.GetBool();
  
  FOR _idx := 0 TO RobotLibraryParameter.SUB_PROGRAM_DATA_MAX
  DO  
    // Get Response.InProgress
   _response.ReturnData[_idx] := ResponseData.GetByte();  
  END_FOR

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  
  Valid              := FALSE;
  InProgress         := FALSE;
  CommandAborted     := FALSE;
  ParameterAccepted  := FALSE;
  
  CommandBuffered    := FALSE;
  CommandAborted     := FALSE;
  CommandInterrupted := FALSE;

END_METHOD

