/// Login on RC from PLC
FUNCTION_BLOCK MC_UserLoginFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UserLoginFB                                       
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
  ParCmd          : UserLoginParCmd;      
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command results
  OutCmd          : UserLoginOutCmd;     
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : UserLoginParCmd;
  /// command data to send
 _command         : UserLoginSendData;
  /// response data received
 _response        : UserLoginRecvData;      
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
// Table 6-69: Sent CMD payload (PLC to RC) of "UserLogin"
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
// Byte 04 : SINT       - Mode
// Byte 05 : SINT       - LevelID
// Byte 06 : String(50) - Password[0]
// Byte 07 :            - Password[1]
// Byte 08 :            - Password[2]
// Byte 09 :            - Password[3]
// Byte 10 :            - Password[4]
// Byte 11 :            - Password[5]
// Byte 12 :            - Password[6]
// Byte 13 :            - Password[7]
// Byte 14 :            - Password[8]
// Byte 15 :            - Password[9]
// Byte 16 :            - Password[10]
// Byte 17 :            - Password[11]
// Byte 18 :            - Password[12]
// Byte 19 :            - Password[13]
// Byte 20 :            - Password[14]
// Byte 21 :            - Password[15]
// Byte 22 :            - Password[16]
// Byte 23 :            - Password[17]
// Byte 24 :            - Password[18]
// Byte 25 :            - Password[19]
// Byte 26 :            - Password[20]
// Byte 27 :            - Password[21]
// Byte 28 :            - Password[22]
// Byte 29 :            - Password[23]
// Byte 30 :            - Password[24]
// Byte 31 :            - Password[25]
// Byte 32 :            - Password[26]
// Byte 33 :            - Password[27]
// Byte 34 :            - Password[28]
// Byte 35 :            - Password[29]
// Byte 36 :            - Password[30]
// Byte 37 :            - Password[31]
// Byte 38 :            - Password[32]
// Byte 39 :            - Password[33]
// Byte 40 :            - Password[34]
// Byte 41 :            - Password[35]
// Byte 42 :            - Password[36]
// Byte 43 :            - Password[37]
// Byte 44 :            - Password[38]
// Byte 45 :            - Password[39]
// Byte 46 :            - Password[40]
// Byte 47 :            - Password[41]
// Byte 48 :            - Password[42]
// Byte 49 :            - Password[43]
// Byte 50 :            - Password[44]
// Byte 51 :            - Password[45]
// Byte 52 :            - Password[46]
// Byte 53 :            - Password[47]
// Byte 54 :            - Password[48]
// Byte 55 :            - Password[49]
// Byte 56 : String(50) - Username[0]
// Byte 57 :            - Username[1]
// Byte 58 :            - Username[2]
// Byte 59 :            - Username[3]
// Byte 60 :            - Username[4]
// Byte 61 :            - Username[5]
// Byte 62 :            - Username[6]
// Byte 63 :            - Username[7]
// Byte 64 :            - Username[8]
// Byte 65 :            - Username[9]
// Byte 66 :            - Username[10]
// Byte 67 :            - Username[11]
// Byte 68 :            - Username[12]
// Byte 69 :            - Username[13]
// Byte 70 :            - Username[14]
// Byte 71 :            - Username[15]
// Byte 72 :            - Username[16]
// Byte 73 :            - Username[17]
// Byte 74 :            - Username[18]
// Byte 75 :            - Username[19]
// Byte 76 :            - Username[20]
// Byte 77 :            - Username[21]
// Byte 78 :            - Username[22]
// Byte 79 :            - Username[23]
// Byte 80 :            - Username[24]
// Byte 81 :            - Username[25]
// Byte 82 :            - Username[26]
// Byte 83 :            - Username[27]
// Byte 84 :            - Username[28]
// Byte 85 :            - Username[29]
// Byte 86 :            - Username[30]
// Byte 87 :            - Username[31]
// Byte 88 :            - Username[32]
// Byte 89 :            - Username[33]
// Byte 90 :            - Username[34]
// Byte 91 :            - Username[35]
// Byte 92 :            - Username[36]
// Byte 93 :            - Username[37]
// Byte 94 :            - Username[38]
// Byte 95 :            - Username[39]
// Byte 96 :            - Username[40]
// Byte 97 :            - Username[41]
// Byte 98 :            - Username[42]
// Byte 99 :            - Username[43]
// Byte 100:            - Username[44]
// Byte 101:            - Username[45]
// Byte 102:            - Username[46]
// Byte 103:            - Username[47]
// Byte 104:            - Username[48]
// Byte 105:            - Username[49]

  // set command parameter 
  _command.CmdTyp     :=  CmdType.UserLogin;
  _command.ExecMode   :=  ExecMode;
  _command.ParSeq     := _command.ParSeq;
  _command.Priority   :=  Priority;
  
  _command.Mode       := _parCmd.Mode;
  _command.LevelID    := _parCmd.LevelID;
  _command.Username   := _parCmd.Username;
  _command.Password   := _parCmd.Password;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.LevelID
  CreateCommandPayload.AddSint(_command.LevelID);
  // add command.Password
  CreateCommandPayload.AddString(_command.Password);
  // add command.Username
  CreateCommandPayload.AddString(_command.Username);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_UserLoginFB';
  
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
  				 END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
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
// Table 6-70: Received CMD payload (RC to PLC) of "UserLogin"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
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

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD
