/// Read error codes of pending errors and move them into user data block "RobotData"
FUNCTION_BLOCK MC_ReadMessagesFB EXTENDS RobotLibraryBaseExecuteFB
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
  CheckParameterChanged := ( MemCmp(ADR(ParCmd), ADR(_parCmd), SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
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

METHOD INTERNAL CreateCommandPayload : SendData
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
  _command.Enable       := _parCmd.Enable;
  _command.MessageLevel := _parCmd.MessageLevel;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.MsgID
  CreateCommandPayload.AddUsint(_command.MsgID);
  // add command.Enable
  CreateCommandPayload.AddBool(_command.Enable);
  // add command.MessageLevel
  CreateCommandPayload.AddUsint(_command.MessageLevel);

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
           MemSet(ADR(OutCmd),0,SIZEOF(OutCmd));         
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
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED : CommandBuffered := TRUE;
             CmdMessageState.DONE     : Done            := TRUE;
             CmdMessageState.ERROR    : Error           := TRUE;
             CmdMessageState.ACTIVE   :
  
             // Update results
             OutCmd.Enabled                := _response.Enabled;
             OutCmd.MsgId                  := _response.MsgId;
             OutCmd.NumberOfActiveErrors   := _response.NumberOfActiveErrors;
             OutCmd.NumberOfActiveWarnings := _response.NumberOfActiveWarnings;
             OutCmd.Timestamp              := _response.Timestamp;
             OutCmd.MsgType                := _response.MsgType;
             OutCmd.Severity               := _response.Severity;
             OutCmd.ErrorCode              := _response.ErrorCode;
             OutCmd.Text                   := _response.Text;
  
             ParCmd.Enable := OutCmd.Enabled; 
             ParCmd.MsgId  := OutCmd.MsgId;
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
// Byte 04 : BOOL        Enabled;
// Byte 05 : USINT       MsgID;
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
  
  // Get Response.Enabled
  _response.Enabled := ResponseData.GetBool();
  // Get Response.MsgID
  _response.MsgID := ResponseData.GetUsint();
  // Get Response.NumberOfActiveErrors
  _response.NumberOfActiveErrors := ResponseData.GetUsint();
  // Get Response.NumberOfActiveWarnings
  _response.NumberOfActiveWarnings := ResponseData.GetUsint();
  // Get Response.Timestamp.IEC_DATE
  _response.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.Timestamp.IEC_TIME
  _response.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.MsgType
  _response.MsgType := ResponseData.GetUsint();
  // Get Response.Severity
  _response.Severity := ResponseData.GetSint();
  // Get Response.ErrorCode
  _response.ErrorCode := ResponseData.GetDword();
  // Get _response.RCManufacturer
  ResponseData.GetDataBlock(pData := ADR(_response.Text) , SIZEOF(_response.Text) , IsString := TRUE );

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  Valid              := FALSE; 
  CommandBuffered    := FALSE;

END_METHOD
