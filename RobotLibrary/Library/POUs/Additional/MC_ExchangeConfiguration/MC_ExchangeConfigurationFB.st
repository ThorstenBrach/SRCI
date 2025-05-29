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

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := TRUE; // Function is mandatory 
  RETURN;
  
  CheckFunctionSupported := AxesGroup.State.RobotData.RCSupportedFunctions.ExchangeConfiguration;
  
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

  CheckParameterValid := TRUE;
  
  // Check ParCmd.LogLevel valid ? 
  IF (( ParCmd.LogLevel <> Severity.DEACTIVATE  ) AND  
      ( ParCmd.LogLevel <> Severity.DEBUG       ) AND
      ( ParCmd.LogLevel <> Severity.INFO        ) AND
      ( ParCmd.LogLevel <> Severity.WARNING     ) AND
      ( ParCmd.LogLevel <> Severity.ERROR       ) AND
      ( ParCmd.LogLevel <> Severity.FATAL_ERROR ))    
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
                            MessageText := 'Invalid Parameter ParCmd.LogLevel = {1}',
                            Para1       :=  LOG_LEVEL_TO_STRING(ParCmd.LogLevel));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.WaitAtBlendingZone
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.AllowSecSeqWhileSubprogram
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DelayTime valid ? 
  IF ( ParCmd.DelayTime < 0  )   
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
                            MessageText := 'Invalid Parameter ParCmd.DelayTime = {1} ms',
                            Para1       :=  UINT_TO_STRING(ParCmd.DelayTime));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.WaitForNrOfCmd valid ? 
  IF ( ParCmd.WaitForNrOfCmd < 0  )   
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
                            MessageText := 'Invalid Parameter ParCmd.WaitForNrOfCmd = {1}',
                            Para1       :=  UINT_TO_STRING(ParCmd.WaitForNrOfCmd));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.LifeSignTimeOut valid ? 
  IF ( ParCmd.LifeSignTimeOut < 10 )   
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
                            MessageText := 'Invalid Parameter ParCmd.LifeSignTimeOut = {1} ms',
                            Para1       :=  UINT_TO_STRING(ParCmd.LifeSignTimeOut));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.SyncDelay valid ? 
  IF ( ParCmd.SyncDelay < 0  )   
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
                            MessageText := 'Invalid Parameter ParCmd.SyncDelay = {1}',
                            Para1       :=  UINT_TO_STRING(ParCmd.SyncDelay));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.SyncReaction valid ? 
  IF (( ParCmd.SyncReaction <> SyncReaction.NO_REACTION                      ) AND  
      ( ParCmd.SyncReaction <> SyncReaction.NO_AUTOMATIC_DISABLE             ) AND
      ( ParCmd.SyncReaction <> SyncReaction.INTERRUPT_WHEN_SEQUENCE_IS_EMPTY ) AND
      ( ParCmd.SyncReaction <> SyncReaction.IMMEDIATE_INTERRUPT              ))
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
                            MessageText := 'Invalid Parameter ParCmd.SyncReaction = {1}',
                            Para1       :=  SYNC_REACTION_TO_STRING(ParCmd.SyncReaction));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.DataInSync.ToolsInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.FramesInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.LoadsInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.WorkAreasInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.SoftwareLimitsInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.DefaultDynamicsInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataInSync.ReferenceDynamicsInSync
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncTool
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncFrame
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncLoad
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncWorkArea
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncSWLimits
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncDefaultDynamics
  // -> no plausibility check for boolean
  
  
  // Check ParCmd.DataEnableSync.EnableSyncReferenceDynamics
  // -> no plausibility check for boolean
  
  // Check ParCmd.DataEnableSync.AllowDynamicBlending
  // -> no plausibility check for boolean

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibraryCommandDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
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
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.LogLevel
  CreateCommandPayload.AddUsint(SINT_TO_USINT(_command.LogLevel));
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
    
  // Create log entry for LogLevel
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LogLevel = {1}',
                          Para1       :=  LOG_LEVEL_TO_STRING(_command.LogLevel));
  
  // Create log entry for CtrlByte
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.CtrlByte = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.CtrlByte));
  
  // Create log entry for DelayTime
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DelayTime = {1}',
                          Para1       :=  UINT_TO_STRING(_command.DelayTime));
  
  // Create log entry for WaitForNrOfCmd
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.WaitForNrOfCmd = {1}',
                          Para1       :=  UINT_TO_STRING(_command.WaitForNrOfCmd));
  
  // Create log entry for LifeSignTimeOut
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.LifeSignTimeOut = {1}',
                          Para1       :=  UINT_TO_STRING(_command.LifeSignTimeOut));
  
  // Create log entry for SyncDelay
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SyncDelay = {1}',
                          Para1       :=  UINT_TO_STRING(_command.SyncDelay));
  
  // Create log entry for SyncReaction
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.SyncReaction = {1}',
                          Para1       :=  SYNC_REACTION_TO_STRING(_command.SyncReaction));
  
  // Create log entry for DataInSync
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DataInSync = {1}',
                          Para1       :=  DATA_IN_SYNC_TO_STRING(_command.DataInSync));
  
  // Create log entry for Reserve1
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve1 = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve1));
  
  // Create log entry for DataEnableSync
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.DataEnableSync = {1}',
                          Para1       :=  DATA_ENABLE_SYNC_TO_STRING(_command.DataEnableSync));
  
  // Create log entry for Reserve2
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.State.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Reserve2 = {1}',
                          Para1       :=  BYTE_TO_STRING(_command.Reserve2));

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
  Priority := PriorityLevel.NORMAL;

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
             CmdMessageState.BUFFERED    : CommandBuffered    := TRUE;
             CmdMessageState.ACTIVE      : ParameterAccepted  := TRUE;  
             CmdMessageState.ERROR       : Error              := TRUE;
           END_CASE
  
           // Update Enabled flag
           Enabled :=  _response.Enabled;
           
           // Update command outputs
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
  
           // Enabled ? -> Reset Busy flag  
           IF (Enabled)
           THEN  
             Busy := FALSE;
  				 END_IF
                  
           // Interrupted, Done, Aborted or Error ?
           IF (_response.State > CmdMessageState.ACTIVE )
           THEN
             // Reset Enabled Flag
             Enabled := FALSE;
             // Reset Busy Flag
             Busy := FALSE;             
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 2; 
           END_IF
         END_IF
  
         // do not abort directly, so that the ParSeq update can be send
         IF ( _enable_F.Q ) 
         THEN
           // Reset Enabled Flag
           Enabled := FALSE;
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
  
    02: IF ((    _responseReceived                                   )  OR 
            (     CheckTimeout(_timerCmd) = RobotLibraryConstants.OK )) OR 
           (( NOT AxesGroup.State.Initialized                        )  AND
            ( NOT AxesGroup.State.Synchronized                       ))
        THEN
          Reset();   
  	    END_IF
        
        // Wait for Enable = FALSE
    03: IF ( NOT Enable )
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

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
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
  
  // Create log entry for Enabled
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Enabled = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.Enabled));
  
  // Create log entry for Reserve1
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve1 = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve1));
  
  // Create log entry for LengthACR
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.LengthACR = {1}',
                          Para1       :=  UINT_TO_STRING(_response.LengthACR));
  
  // Create log entry for HighestToolIndex
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.HighestToolIndex = {1}',
                          Para1       :=  USINT_TO_STRING(_response.HighestToolIndex));
  
  // Create log entry for HighestFrameIndex
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.HighestFrameIndex = {1}',
                          Para1       :=  USINT_TO_STRING(_response.HighestFrameIndex));
  
  // Create log entry for HighestLoadIndex
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.HighestLoadIndex = {1}',
                          Para1       :=  USINT_TO_STRING(_response.HighestLoadIndex));
  
  // Create log entry for HighestWorkAreaIndex
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.HighestWorkAreaIndex = {1}',
                          Para1       :=  USINT_TO_STRING(_response.HighestWorkAreaIndex));
  
  // Create log entry for DataInSync.ToolsInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.ToolsInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.ToolsInSync));
  
  // Create log entry for DataInSync.FramesInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.FramesInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.FramesInSync));
  
  // Create log entry for DataInSync.LoadsInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.LoadsInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.LoadsInSync));
  
  // Create log entry for DataInSync.WorkAreasInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.WorkAreasInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.WorkAreasInSync));
  
  // Create log entry for DataInSync.SoftwareLimitsInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.SoftwareLimitsInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.SoftwareLimitsInSync));
                
  // Create log entry for DataInSync.DefaultDynamicsInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.DefaultDynamicsInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.DefaultDynamicsInSync));
                 
  // Create log entry for DataInSync.ReferenceDynamicsInSync
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.DataInSync.ReferenceDynamicsInSync = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.DataInSync.ReferenceDynamicsInSync));
  
  // Create log entry for Reserve2
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.Reserve2 = {1}',
                          Para1       :=  BYTE_TO_STRING(_response.Reserve2));
  
  // Create log entry for ChangeIndexTool
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ChangeIndexTool = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ChangeIndexTool));
  
  // Create log entry for ChangeIndexFrame
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ChangeIndexFrame = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ChangeIndexFrame));
  
  // Create log entry for ChangeIndexLoad
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ChangeIndexLoad = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ChangeIndexLoad));
  
  // Create log entry for ChangeIndexWorkArea
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ChangeIndexWorkArea = {1}',
                          Para1       :=  USINT_TO_STRING(_response.ChangeIndexWorkArea));
  
  // Create log entry for RAWorkingHours
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RAWorkingHours = {1}',
                          Para1       :=  UDINT_TO_STRING(_response.RAWorkingHours));
  
  // Create log entry for StatusByte
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.StatusByte = {1}',
                          Para1       :=  BYTE_TO_STRING_BIN(_response.StatusByte));
  
  // Create log entry for ConstantVelocitySupported
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.ConstantVelocitySupported = {1}',
                          Para1       :=  BOOL_TO_STRING(_response.ConstantVelocitySupported));
  
  // Create log entry for RCWorkingHours
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.RCWorkingHours = {1}',
                          Para1       :=  UDINT_TO_STRING(_response.RCWorkingHours));

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Busy               := FALSE;
  CommandBuffered    := FALSE;
  ParameterAccepted  := FALSE;

END_METHOD

