/// Return to path left during active interrupt
FUNCTION_BLOCK MC_ReturnToPrimaryFB EXTENDS RobotLibraryBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReturnToPrimaryFB                                       
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
  /// Activate ReturnToPrimary
  Enable             : BOOL;
  /// command parameter
  ParCmd             : ReturnToPrimaryParCmd;      
END_VAR

VAR_OUTPUT
  /// The command has been completed successfully
  Done               : BOOL;
  /// FB is being processed
  Busy               : BOOL;
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// The command takes control of the motion of the according axis group
  Active             : BOOL;
  /// The command was aborted by another command.
  CommandAborted     : BOOL;
  /// TRUE, while command is interrupted during execution and can be continued
  CommandInterrupted : BOOL;
  /// command results
  OutCmd             : ReturnToPrimaryOutCmd;      
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : ReturnToPrimaryParCmd;
  /// command data to send
 _command            : ReturnToPrimarySendData;
  /// response data received
 _response           : ReturnToPrimaryRecvData;      
  /// Rising edge for enable
 _enable_R           : R_TRIG;
  /// Falling edge for enable
 _enable_F           : F_TRIG;
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
// Table 6-310: Sent CMD payload (PLC to RC) of "ReturnToPrimary"
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
// Byte 04  : UINT  - ToolNo LW HB
// Byte 05  :       - ToolNo LW LB
// Byte 06  : UINT  - FrameNo LW HB
// Byte 07  :       - FrameNo LW LB
// Byte 08  : UINT  - VelocityRate LW HB
// Byte 09  :       - VelocityRate LW LB
// Byte 10  : UINT  - AccelerationRate LW HB
// Byte 11  :       - AccelerationRate LW LB
// Byte 12  : UINT  - DecelerationRate LW HB
// Byte 13  :       - DecelerationRate LW LB
// Byte 14  : UINT  - JerkRate LW HB
// Byte 15  :       - JerkRate LW LB
// Byte 16  : REAL  - Limit HW HB
// Byte 17  :       - Limit HW LB
// Byte 18  :       - Limit LW HB
// Byte 19  :       - Limit LW LB
// Byte 20  : BOOL  - ReturnMode
// Byte 21  : BOOL  - TrajectoryMode
// Byte 22  : UINT  - Time LW HB
// Byte 23  : UINT  - Time LW LB


// --------------------------

  // set command parameter 
  _command.CmdTyp            :=  CmdType.ReturnToPrimary;
  _command.ExecMode          :=  ExecMode;
  _command.ParSeq            := _command.ParSeq;
  _command.Priority          :=  Priority;
  _command.ToolNo            := _parCmd.ToolNo;
  _command.FrameNo           := _parCmd.FrameNo;
  _command.VelocityRate      :=  REAL_TO_UINT(_parCmd.VelocityRate     * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.AccelerationRate  :=  REAL_TO_UINT(_parCmd.AccelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DecelerationRate  :=  REAL_TO_UINT(_parCmd.DecelerationRate * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.JerkRate          :=  REAL_TO_UINT(_parCmd.JerkRate         * RobotLibraryConstants.REAL_CONVERSION_FACTOR);
  _command.DistanceLimit     := _parCmd.DistanceLimit;
  _command.ReturnMode        :=(_parCmd.ReturnMode = ReturnMode.END_POSITION);
  _command.TrajectoryMode    := _parCmd.TrajectoryMode = TrajectoryMode.PTP_MOVEMENT;
  _command.MoveTime          :=  TIME_TO_UINT(_parCmd.MoveTime);
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.ToolNo
  CreateCommandPayload.AddUint(_command.ToolNo);
  // add command.FrameNo
  CreateCommandPayload.AddUint(_command.FrameNo);
  // add command.VelocityRate
  CreateCommandPayload.AddUint(_command.VelocityRate);
  // add command.AccelerationRate
  CreateCommandPayload.AddUint(_command.AccelerationRate);
  // add command.DecelerationRate
  CreateCommandPayload.AddUint(_command.DecelerationRate);
  // add command.JerkRate
  CreateCommandPayload.AddUint(_command.JerkRate);
  // add command.DistanceLimit
  CreateCommandPayload.AddReal(_command.DistanceLimit);
  // add command.ReturnMode
  CreateCommandPayload.AddBool(_command.ReturnMode);
  // add command.TrajectoryMode
  CreateCommandPayload.AddBool(_command.TrajectoryMode);
  // add command.MoveTime
  CreateCommandPayload.AddUint(_command.MoveTime);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReturnToPrimaryFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q )  
         THEN
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();       
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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : Active             := TRUE;
             CmdMessageState.INTERRUPTED : CommandInterrupted := TRUE;
             CmdMessageState.DONE        : Done               := TRUE;
             CmdMessageState.ABORTED     : CommandAborted     := TRUE;
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.Progress          := _response.Progress;
             OutCmd.RemainingDistance := _response.RemainingDistance;
             OutCmd.PrimaryPosToolNo  := UINT_TO_USINT(_response.PrimaryPosToolNo);  {warning 'ToDo'}
             OutCmd.PrimaryPosFrameNo := UINT_TO_USINT(_response.PrimaryPosFrameNo); {warning 'ToDo'}
             
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
  				 END_IF
         END_IF
  
    03: IF (NOT Enable)
        THEN
          Reset();
        END_IF  
  ELSE
    // invalid step
    ErrorID := RobotLibraryEvents.ERR_INVALID_STEP;
  END_CASE
  
  
  
  // Reset FB
  IF (( _enable_R.Q ) OR
      ( _enable_F.Q ))
  THEN
    Reset();
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-311: Received CMD payload (RC to PLC) of "ReturnToPrimary"
// --------------------------
// Header
// --------------------------
// Byte 00 : USINT - ParSeq | State     
// Byte 01 : SINT  - AlarmMessageSeverity    
// Byte 02 : UINT  - AlarmMessageCode HB
// Byte 03 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 04 : UINT  - Progress LW HB
// Byte 05 :       - Progress LW LB
// Byte 06 : REAL  - RemainingDistance HW HB
// Byte 07 :       - RemainingDistance HW LB
// Byte 08 :       - RemainingDistance LW HB
// Byte 09 :       - RemainingDistance LW LB
// Byte 10 : UINT  - PrimaryPosToolNo LW HB
// Byte 11 :       - PrimaryPosToolNo LW LB
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
  
  // Get Response.Progress
  _response.Progress             := ResponseData.GetUint();
  // Get Response.RemainingDistance
  _response.RemainingDistance    := ResponseData.GetReal();
  // Get Response.PrimaryPosToolNo
  _response.PrimaryPosToolNo     := ResponseData.GetUint();
  // Get Response.PrimaryPosFrameNo
  _response.PrimaryPosFrameNo    := ResponseData.GetUint();

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
