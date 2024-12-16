/// Reads and writes specific configuration parameters on RC that are required for the RI to work
FUNCTION_BLOCK MC_ExchangeConfigurationFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExchangeConfigurationFB                                       
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
  ParCmd            : ExchangeConfigurationParCmd;
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered   : BOOL;
  /// Receiving of input parameter values has been acknowledged by RC
  ParameterAccepted : BOOL;
  /// command results
  OutCmd            : ExchangeConfigurationOutCmd;
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd            : ExchangeConfigurationParCmd;
  /// command data to send
 _command           : ExchangeConfigurationSendData;
  /// response data received
 _response          : ExchangeConfigurationRecvData;
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
    // Reset parameter accepted flag
    ParameterAccepted := FALSE;
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-86: Sent CMD payload (PLC to RC) of "ExchangeConfiguration"
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
// Byte 4   : USINT      - LogLevel
// Byte 5.0 : BOOL       - WaitAtBlendingZone
// Byte 5.1 : BOOL       - Enable
// Byte 5.2 : BOOL       - AllowSecSeqWhileSubprogram
// Byte 5.3 : BOOL       - AllowDynamicBlending
// Byte 6   : UINT       - DelayTime HB
// Byte 7   :            - DelayTime LB
// Byte 8   : UINT       - WaitForNrOfCmd HB
// Byte 9   :            - WaitForNrOfCmd LB
// Byte 10  : UINT       - LifeSignTimeOut HB
// Byte 11  :            - LifeSignTimeOut LB
// Byte 12  : UINT       - SyncDelay HB
// Byte 13  :            - SyncDelay LB
// Byte 14  : USINT      - SyncReaction
// Byte 15  : DataInSync - DataInSync 
// Byte 16  : BYTE       - Reserved
// Byte 17  : BYTE       - DataEnableSync
// Byte 18  : BYTE       - Reserved

  // set command parameter 
  _command.CmdTyp          :=  CmdType.ExchangeConfiguration;
  _command.ExecMode        :=  ExecMode;
  _command.ParSeq          := _command.ParSeq;
  _command.Priority        :=  Priority;
  _command.LogLevel        := _parCmd.LogLevel;
  _command.CtrlByte.0      := _parCmd.WaitAtBlendingZone;
  _command.CtrlByte.1      :=  Enable;
  _command.CtrlByte.2      := _parCmd.AllowSecSeqWhileSubprogram;
  _command.CtrlByte.3      := _parCmd.AllowDynamicBlending;
  _command.DelayTime       := _parCmd.DelayTime;
  _command.WaitForNrOfCmd  := _parCmd.WaitForNrOfCmd;
  _command.LifeSignTimeOut := _parCmd.LifeSignTimeOut;
  _command.SyncDelay       := _parCmd.SyncDelay;
  _command.SyncReaction    := _parCmd.SyncReaction;
  _command.DataInSync      := _parCmd.DataInSync;
  _command.Reserve1        := 0;
  _command.DataEnableSync  := _parCmd.DataEnableSync;  
  _command.Reserve2        := 0;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.LogLevel
  CreateCommandPayload.AddUsint(_command.LogLevel);
  // add command.CtrlByte
  CreateCommandPayload.AddByte(_command.CtrlByte);
  // add command.DelayTime
  CreateCommandPayload.AddUint(_command.DelayTime);
  // add command.WaitForNrOfCmd
  CreateCommandPayload.AddUint(_command.WaitForNrOfCmd);
  // add command.LifeSignTimeOut
  CreateCommandPayload.AddUint(_command.LifeSignTimeOut);
  // add command.SyncDelay
  CreateCommandPayload.AddUint(_command.SyncDelay);
  // add command.SyncReaction
  CreateCommandPayload.AddUsint(_command.SyncReaction);
  // add command.DataInSync
  CreateCommandPayload.AddDataInSync(_command.DataInSync);
  // add command.Reserve1
  CreateCommandPayload.AddByte(_command.Reserve1);
  // add command.DataEnableSync
  CreateCommandPayload.AddDataEnableSync(_command.DataEnableSync);
  // add command.Reserve2
  CreateCommandPayload.AddByte(_command.Reserve2);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType   := 'MC_ExchangeConfigurationFB';
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
  
           CASE  _response.State 
           OF
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;  
             CmdMessageState.ERROR       : Error              := TRUE;
  				 END_CASE
                  
           // Active, Interrupted, Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.ACTIVE )
           THEN
             // Reset Busy Flag
             Busy := FALSE;
             // Reset Enabled flag
             Enabled := TRUE;
             
             OutCmd.LengthACR                 := _response.LengthACR;
             OutCmd.HighestToolIndex          := _response.HighestToolIndex;
             OutCmd.HighestFrameIndex         := _response.HighestFrameIndex;
             OutCmd.HighestLoadIndex          := _response.HighestLoadIndex;
             OutCmd.HighestWorkAreaIndex      := _response.HighestWorkAreaIndex;
             OutCmd.DataInSync                := _response.DataInSync;
             OutCmd.ChangeIndexTool           := _response.ChangeIndexTool;
             OutCmd.ChangeIndexFrame          := _response.ChangeIndexFrame;
             OutCmd.ChangeIndexLoad           := _response.ChangeIndexLoad;
             OutCmd.ChangeIndexWorkArea       := _response.ChangeIndexWorkArea;
             OutCmd.RAWorkingHours            := _response.RAWorkingHours;
             OutCmd.BrakeTestRequired         := _response.StatusByte.0;
             OutCmd.StepModeExactStopActive   := _response.StatusByte.1;
             OutCmd.StepModeBlendingActive    := _response.StatusByte.2;
             OutCmd.PathAccuracyMode          := _response.StatusByte.3;
             OutCmd.AvoidSingularity          := _response.StatusByte.4;
             OutCmd.CollisionDetectionEnabled := _response.StatusByte.5;
             OutCmd.AcceleratingSupported     := _response.StatusByte.6;
             OutCmd.DecceleratingSupported    := _response.StatusByte.7;
             OutCmd.ConstantVelocitySupported := _response.ConstantVelocitySupported;
             OutCmd.RCWorkingHours            := _response.RCWorkingHours;      
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
  				 END_IF
         END_IF
  
         // Check enable flag 
         IF (_enable_F.Q)
         THEN
           // trigger parameter update to disable GroupJog
           MemSet( destAddr := ADR(_parCmd), fillbyte := 0, n := SIZEOF(_parCmd));
           // reset the falling edge
          _enable_F();       
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
// Table 6-87: Received CMD payload (RC to PLC) of "ExchangeConfiguration"
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
// Byte 04 : BOOL       - Enabled
// Byte 05 : BYTE       - Reserve
// Byte 05 : UINT       - LengthACR LW HB
// Byte 06 :            - LengthACR LW LB
// Byte 08 : USINT      - HighestToolIndex
// Byte 09 : USINT      - HighestFrameIndex
// Byte 10 : USINT      - HighestLoadIndex
// Byte 11 : USINT      - HighestWorkAreaIndex
// Byte 12 : DataInSync - DataInSync
// Byte 13 : BYTE       - Reserve
// Byte 14 : USINT      - ChangeIndexTool
// Byte 15 : USINT      - ChangeIndexFrame
// Byte 16 : USINT      - ChangeIndexLoad
// Byte 17 : USINT      - ChangeIndexWorkArea
// Byte 18 : UDINT      - RA WorkingHours HW HB
// Byte 19 :            - RA WorkingHours HW LB
// Byte 20 :            - RA WorkingHours LW HB
// Byte 21 :            - RA WorkingHours LW LB
// Byte 22 : BYTE       - StatusByte
// Byte 23 : BOOL       - ConstantVelocitySupported
// Byte 24 : UDINT      - RC WorkingHours HW HB
// Byte 25 :            - RC WorkingHours HW LB
// Byte 26 :            - RC WorkingHours LW HB
// Byte 27 :            - RC WorkingHours LW LB


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
  // Get Response.Reserve1
  _response.Reserve1 := ResponseData.GetByte();
  // Get Response.LengthACR
  _response.LengthACR := ResponseData.GetUint();
  // Get Response.HighestToolIndex
  _response.HighestToolIndex := ResponseData.GetUsint();
  // Get Response.HighestFrameIndex
  _response.HighestFrameIndex := ResponseData.GetUsint();
  // Get Response.HighestLoadIndex
  _response.HighestLoadIndex := ResponseData.GetUsint();
  // Get Response.HighestWorkAreaIndex
  _response.HighestWorkAreaIndex := ResponseData.GetUsint();
  // Get Response.DataInSync
  _response.DataInSync := ResponseData.GetDataInSync();
  // Get Response.Reserve2
  _response.Reserve2 := ResponseData.GetByte();
  // Get Response.ChangeIndexTool
  _response.ChangeIndexTool := ResponseData.GetUsint();
  // Get Response.ChangeIndexFrame
  _response.ChangeIndexFrame := ResponseData.GetUsint();
  // Get Response.ChangeIndexLoad
  _response.ChangeIndexLoad := ResponseData.GetUsint();
  // Get Response.ChangeIndexWorkArea
  _response.ChangeIndexWorkArea := ResponseData.GetUsint();
  // Get Response.RAWorkingHours
  _response.RAWorkingHours := ResponseData.GetUdint();
  // Get Response.StatusByte
  _response.StatusByte := ResponseData.GetByte();
  // Get Response.ConstantVelocitySupported
  _response.ConstantVelocitySupported := ResponseData.GetBool();
  // Get Response.RCWorkingHours
  _response.RCWorkingHours := ResponseData.GetUdint();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

