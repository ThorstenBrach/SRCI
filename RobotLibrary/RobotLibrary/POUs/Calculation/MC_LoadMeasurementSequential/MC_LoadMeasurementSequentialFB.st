/// Sequential detection of load data
FUNCTION_BLOCK MC_LoadMeasurementSequentialFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementSequentialFB                                       
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
  /// Processing mode
  ProcessingMode     : ProcessingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag       : SequenceFlag;  
  /// Command parameter 
  ParCmd             : LoadMeasurementSequentialParCmd;      
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;  
  /// The command takes control of the motion of the according axis group.
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued.
  CommandInterrupted : BOOL;
  /// Command output 
  OutCmd             : LoadMeasurementSequentialOutCmd;        
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : LoadMeasurementSequentialParCmd;
  /// command data to send
 _command            : LoadMeasurementSequentialSendData;
  /// response data received
 _response           : LoadMeasurementSequentialRecvData;      
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
// Table 6-784: Sent CMD payload (PLC to RC) of "LoadMeasurementSequential"
// --------------------------
// Header
// --------------------------
// Byte 000 : UINT  - Type HB     
// Byte 001 :       - Type LB    
// Byte 002 : USINT - Reserve | ExecutionMode
// Byte 003 : USINT - ParSeq  | Priority
// --------------------------
// Datablock
// --------------------------
// Byte 004 : REAL       - Mass HW HB
// Byte 005 :            - Mass HW LB
// Byte 006 :            - Mass LW HB
// Byte 007 :            - Mass LW LB
// Byte 008 : USINT      - Mode

  // set command parameter 
  _command.CmdTyp   :=  CmdType.LoadMeasurementSequential;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;                  
  _command.Mass     :=  parCmd.Mass;
  _command.Mode     :=  parCmd.Mode;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  
  // add command.Mass
  CreateCommandPayload.AddReal(_command.Mass);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.Mode);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_LoadMeasurementSequentialFB';
  
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
           // reset Active flag
           Active := FALSE;
           
           CASE  _response.State 
           OF
             CmdMessageState.ACTIVE      : Active             := TRUE;
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Rest Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.LoadData          := _response.LoadData;
             OutCmd.LoadDataAvailable := _response.LoadDataAvailable;
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
// Table 6-785: Received CMD payload (RC to PLC) of "LoadMeasurementSequential"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// Datablock
// --------------------------
// Byte 004 : IEC_DATE   - IEC Date LW HB
// Byte 005 :            - IEC Date LW LB
// Byte 006 : IEC_TIME   - IEC Time HW HB
// Byte 007 :            - IEC Time HW LB
// Byte 008 :            - IEC Time LW HB
// Byte 009 :            - IEC Time LW LB
// Byte 010 : REAL       - LoadData.X HW HB
// Byte 011 :            - LoadData.X HW LB
// Byte 012 :            - LoadData.X LW HB
// Byte 013 :            - LoadData.X LW LB
// Byte 014 : REAL       - LoadData.Y HW HB
// Byte 015 :            - LoadData.Y HW LB
// Byte 016 :            - LoadData.Y LW HB
// Byte 017 :            - LoadData.Y LW LB
// Byte 018 : REAL       - LoadData.Z HW HB
// Byte 019 :            - LoadData.Z HW LB
// Byte 020 :            - LoadData.Z LW HB
// Byte 021 :            - LoadData.Z LW LB
// Byte 022 : REAL       - LoadData.Rx HW HB
// Byte 023 :            - LoadData.Rx HW LB
// Byte 024 :            - LoadData.Rx LW HB
// Byte 025 :            - LoadData.Rx LW LB
// Byte 026 : REAL       - LoadData.Ry HW HB
// Byte 027 :            - LoadData.Ry HW LB
// Byte 028 :            - LoadData.Ry LW HB
// Byte 029 :            - LoadData.Ry LW LB
// Byte 030 : REAL       - LoadData.Rz HW HB
// Byte 031 :            - LoadData.Rz HW LB
// Byte 032 :            - LoadData.Rz LW HB
// Byte 033 :            - LoadData.Rz LW LB
// Byte 034 : REAL       - Mass HW HB
// Byte 035 :            - Mass HW LB
// Byte 036 :            - Mass LW HB
// Byte 037 :            - Mass LW LB
// Byte 038 : REAL       - LoadData.Ix HW HB
// Byte 039 :            - LoadData.Ix HW LB
// Byte 040 :            - LoadData.Ix LW HB
// Byte 041 :            - LoadData.Ix LW LB
// Byte 042 : REAL       - LoadData.Iy HW HB
// Byte 043 :            - LoadData.Iy HW LB
// Byte 044 :            - LoadData.Iy LW HB
// Byte 045 :            - LoadData.Iy LW LB
// Byte 046 : REAL       - LoadData.Iz HW HB
// Byte 047 :            - LoadData.Iz HW LB
// Byte 048 :            - LoadData.Iz LW HB
// Byte 049 :            - LoadData.Iz LW LB
// Byte 050 : BOOL       - LoadData.Available
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
  
  // Get Response.LoadData.Timestamp.TsData
  _response.LoadData.Timestamp.IEC_DATE := ResponseData.GetIecDate();
  // Get Response.LoadData.Timestamp.TsTime
  _response.LoadData.Timestamp.IEC_TIME := ResponseData.GetIecTime();
  // Get Response.LoadData.X
  _response.LoadData.X := ResponseData.GetReal();
  // Get Response.LoadData.Y
  _response.LoadData.Y := ResponseData.GetReal();
  // Get Response.LoadData.Z
  _response.LoadData.Z := ResponseData.GetReal();
  // Get Response.LoadData.Rx
  _response.LoadData.Rx := ResponseData.GetReal();
  // Get Response.LoadData.Ry
  _response.LoadData.Ry := ResponseData.GetReal();
  // Get Response.LoadData.Rz
  _response.LoadData.Rz := ResponseData.GetReal();
  // Get Response.LoadData.Mass
  _response.LoadData.Mass := ResponseData.GetReal();
  // Get Response.LoadData.Ix
  _response.LoadData.Ix := ResponseData.GetReal();
  // Get Response.LoadData.Iy
  _response.LoadData.Iy := ResponseData.GetReal();
  // Get Response.LoadData.Iz
  _response.LoadData.Iz := ResponseData.GetReal();
  // Get Response.LoadDataAvailable
  _response.LoadDataAvailable := ResponseData.GetBool();

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

