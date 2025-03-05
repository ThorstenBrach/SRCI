/// Capture trigger Position, measuring input
FUNCTION_BLOCK MC_MeasuringInputFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MeasuringInputFB                                       
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
  ParCmd          : MeasuringInputParCmd;        
END_VAR

VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;  
  /// Command output 
  OutCmd          : MeasuringInputOutCmd;            
END_VAR
VAR
  /// internal copy of command parameter 
 _parCmd          : MeasuringInputParCmd;
  /// command data to send
 _command         : MeasuringInputSendData;
  /// response data received
 _response        : MeasuringInputRecvData;      
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD PROTECTED CheckFunctionSupported : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  CheckFunctionSupported := AxesGroup.InternalData.RobotData.RCSupportedFunctions.MeasuringInput;
  
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
  
  // Check ParCmd.MeasuringMode valid ? 
  IF (( ParCmd.MeasuringMode <> MeasuringIoMode.MEASUREMENT_AT_NEXT_RISING_EDGE             ) AND  
      ( ParCmd.MeasuringMode <> MeasuringIoMode.MEASUREMENT_AT_NEXT_FALLING_EDGE            ) AND
      ( ParCmd.MeasuringMode <> MeasuringIoMode.MEASUREMENT_AT_NEXT_EDGE                    ) AND
      ( ParCmd.MeasuringMode <> MeasuringIoMode.MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_RISING  ) AND
      ( ParCmd.MeasuringMode <> MeasuringIoMode.MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_FALLING ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.MeasuringMode = {1}',
                            Para1       :=  MEASURING_IO_MODE_TO_STRING(ParCmd.MeasuringMode));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.Index valid ? 
  IF (( ParCmd.Index <   0 ) OR  
      ( ParCmd.Index > 255 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.Index = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.Index));
    RETURN;                          
  END_IF
  
  
  // Check ParCmd.BitNumber valid ? 
  IF (( ParCmd.BitNumber <   0 ) OR  
      ( ParCmd.BitNumber > 255 ))
  THEN
    // Parameter not valid
    CheckParameterValid := FALSE;
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD;
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.ERROR,
                            MessageCode := ErrorID,
                            MessageText := 'Invalid Parameter ParCmd.BitNumber = {1}',
                            Para1       :=  USINT_TO_STRING(ParCmd.BitNumber));
    RETURN;                          
  END_IF

END_METHOD

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR
// Table 6-565: Sent CMD payload (PLC to RC) of "MeasuringInput"
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
// Byte 004 : USINT       - MeasuringMode
// Byte 005 : USINT       - Index
// Byte 006 : USINT       - BitNumber

  // set command parameter 
  _command.CmdTyp        :=  CmdType.MeasuringInput;
  _command.ExecMode      :=  ExecMode;
  _command.ParSeq        := _command.ParSeq;
  _command.Priority      :=  Priority;
                         
  _command.MeasuringMode := parCmd.MeasuringMode;
  _command.Index         := parCmd.Index;
  _command.BitNumber     := parCmd.BitNumber;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload(AxesGroup := AxesGroup);
  
  // add command.MeasuringMode
  CreateCommandPayload.AddUsint(_command.MeasuringMode);
  // add command.Index
  CreateCommandPayload.AddUsint(_command.Index);
  // add command.BitNumber
  CreateCommandPayload.AddUsint(_command.BitNumber);
  
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
                          MessageText := 'Create command payload with the following parameter(s) :');
    
  // Create log entry for MeasuringMode
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.MeasuringMode = {1}',
                          Para1       :=  USINT_TO_STRING(_command.MeasuringMode));
                          
  // Create log entry for Index
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.Index = {1}',
                          Para1       :=  USINT_TO_STRING(_command.Index));
                          
  // Create log entry for BitNumber
  CreateLogMessagePara1 ( Timestamp   := AxesGroup.InternalData.SystemTime,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Command.BitNumber = {1}',
                          Para1       :=  USINT_TO_STRING(_command.BitNumber));

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_MeasuringInputFB';
  
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
             CmdMessageState.BUFFERED    : CommandBuffered := TRUE;
             CmdMessageState.DONE        : Done            := TRUE;
             CmdMessageState.ERROR       : Error           := TRUE;
           END_CASE
                  
           // Done, Aborted or Error ?
           IF (_response.State >= CmdMessageState.DONE )
           THEN
             // Reset Busy flag
             Busy := FALSE;
             // Update results
             OutCmd.MeasuringID := _response.MeasuringID;
             OutCmd.Measurings  := _response.Measurings;
             
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
// Table 6-566: Received CMD payload (RC to PLC) of "MeasuringInput"
// --------------------------
// Header
// --------------------------
// Byte 000 : USINT - ParSeq | State     
// Byte 001 : SINT  - AlarmMessageSeverity    
// Byte 002 : UINT  - AlarmMessageCode HB
// Byte 003 :       - AlarmMessageCode LB
// --------------------------
// Datablock
// --------------------------
// Byte 004 : BOOL      - Enabled
// Byte 005 : UINT      - MeasuringID LW LB 
// Byte 006 : USINT     - ToolNo_1
// Byte 007 : USINT     - FrameNo_1
// Byte 008 : USINT     - ToolNo_2
// Byte 009 : USINT     - FrameNo_2
// Byte 010 : REAL      - MeasuredCartesianPosition_1.X HW HB
// Byte 011 :           - MeasuredCartesianPosition_1.X HW LB
// Byte 012 :           - MeasuredCartesianPosition_1.X LW HB
// Byte 013 :           - MeasuredCartesianPosition_1.X LW LB
// Byte 014 : REAL      - MeasuredCartesianPosition_1.Y HW HB
// Byte 015 :           - MeasuredCartesianPosition_1.Y HW LB
// Byte 016 :           - MeasuredCartesianPosition_1.Y LW HB
// Byte 017 :           - MeasuredCartesianPosition_1.Y LW LB
// Byte 018 : REAL      - MeasuredCartesianPosition_1.Z HW HB
// Byte 019 :           - MeasuredCartesianPosition_1.Z HW LB
// Byte 020 :           - MeasuredCartesianPosition_1.Z LW HB
// Byte 021 :           - MeasuredCartesianPosition_1.Z LW LB
// Byte 022 : REAL      - MeasuredCartesianPosition_1.Rx HW HB
// Byte 023 :           - MeasuredCartesianPosition_1.Rx HW LB
// Byte 024 :           - MeasuredCartesianPosition_1.Rx LW HB
// Byte 025 :           - MeasuredCartesianPosition_1.Rx LW LB
// Byte 026 : REAL      - MeasuredCartesianPosition_1.Ry HW HB
// Byte 027 :           - MeasuredCartesianPosition_1.Ry HW LB
// Byte 028 :           - MeasuredCartesianPosition_1.Ry LW HB
// Byte 029 :           - MeasuredCartesianPosition_1.Ry LW LB
// Byte 030 : REAL      - MeasuredCartesianPosition_1.Rz HW HB
// Byte 031 :           - MeasuredCartesianPosition_1.Rz HW LB
// Byte 032 :           - MeasuredCartesianPosition_1.Rz LW HB
// Byte 033 :           - MeasuredCartesianPosition_1.Rz LW LB
// Byte 034 : Config    - MeasuredCartesianPosition_1.ArmConfig
// Byte 035 :           - MeasuredCartesianPosition_1.Reserve
// Byte 036 : TurnNumber- MeasuredCartesianPosition_1.TurnNumber.J1 + J2  HW HB
// Byte 037 :           - MeasuredCartesianPosition_1.TurnNumber.J3 + J4  HW LB
// Byte 038 :           - MeasuredCartesianPosition_1.TurnNumber.J5 + J6  LW LB
// Byte 039 :           - MeasuredCartesianPosition_1.TurnNumber.E1       LW LB
// Byte 040 : REAL      - MeasuredCartesianPosition_1.E1 HW HB
// Byte 041 :           - MeasuredCartesianPosition_1.E1 HW LB
// Byte 042 :           - MeasuredCartesianPosition_1.E1 LW HB
// Byte 043 :           - MeasuredCartesianPosition_1.E1 LW LB
// Byte 044 : REAL      - MeasuredJointPosition_1.J1 HW HB
// Byte 045 :           - MeasuredJointPosition_1.J1 HW LB
// Byte 046 :           - MeasuredJointPosition_1.J1 LW HB
// Byte 047 :           - MeasuredJointPosition_1.J1 LW LB
// Byte 048 : REAL      - MeasuredJointPosition_1.J2 HW HB
// Byte 049 :           - MeasuredJointPosition_1.J2 HW LB
// Byte 050 :           - MeasuredJointPosition_1.J2 LW HB
// Byte 051 :           - MeasuredJointPosition_1.J2 LW LB
// Byte 052 : REAL      - MeasuredJointPosition_1.J3 HW HB
// Byte 053 :           - MeasuredJointPosition_1.J3 HW LB
// Byte 054 :           - MeasuredJointPosition_1.J3 LW HB
// Byte 055 :           - MeasuredJointPosition_1.J3 LW LB
// Byte 056 : REAL      - MeasuredJointPosition_1.J4 HW HB
// Byte 057 :           - MeasuredJointPosition_1.J4 HW LB
// Byte 058 :           - MeasuredJointPosition_1.J4 LW HB
// Byte 059 :           - MeasuredJointPosition_1.J4 LW LB
// Byte 060 : REAL      - MeasuredJointPosition_1.J5 HW HB
// Byte 061 :           - MeasuredJointPosition_1.J5 HW LB
// Byte 062 :           - MeasuredJointPosition_1.J5 LW HB
// Byte 063 :           - MeasuredJointPosition_1.J5 LW LB
// Byte 064 : REAL      - MeasuredJointPosition_1.J6 HW HB
// Byte 065 :           - MeasuredJointPosition_1.J6 HW LB
// Byte 066 :           - MeasuredJointPosition_1.J6 LW HB
// Byte 067 :           - MeasuredJointPosition_1.J6 LW LB
// Byte 068 : REAL      - MeasuredJointPosition_1.E1 HW HB
// Byte 069 :           - MeasuredJointPosition_1.E1 HW LB
// Byte 070 :           - MeasuredJointPosition_1.E1 LW HB
// Byte 071 :           - MeasuredJointPosition_1.E1 LW LB
// Byte 072 : REAL      - MeasuredCartesianPosition_2.X HW HB
// Byte 073 :           - MeasuredCartesianPosition_2.X HW LB
// Byte 074 :           - MeasuredCartesianPosition_2.X LW HB
// Byte 075 :           - MeasuredCartesianPosition_2.X LW LB
// Byte 076 : REAL      - MeasuredCartesianPosition_2.Y HW HB
// Byte 077 :           - MeasuredCartesianPosition_2.Y HW LB
// Byte 078 :           - MeasuredCartesianPosition_2.Y LW HB
// Byte 079 :           - MeasuredCartesianPosition_2.Y LW LB
// Byte 080 : REAL      - MeasuredCartesianPosition_2.Z HW HB
// Byte 081 :           - MeasuredCartesianPosition_2.Z HW LB
// Byte 082 :           - MeasuredCartesianPosition_2.Z LW HB
// Byte 083 :           - MeasuredCartesianPosition_2.Z LW LB
// Byte 084 : REAL      - MeasuredCartesianPosition_2.Rx HW HB
// Byte 085 :           - MeasuredCartesianPosition_2.Rx HW LB
// Byte 086 :           - MeasuredCartesianPosition_2.Rx LW HB
// Byte 087 :           - MeasuredCartesianPosition_2.Rx LW LB
// Byte 088 : REAL      - MeasuredCartesianPosition_2.Ry HW HB
// Byte 089 :           - MeasuredCartesianPosition_2.Ry HW LB
// Byte 090 :           - MeasuredCartesianPosition_2.Ry LW HB
// Byte 091 :           - MeasuredCartesianPosition_2.Ry LW LB
// Byte 092 : REAL      - MeasuredCartesianPosition_2.Rz HW HB
// Byte 093 :           - MeasuredCartesianPosition_2.Rz HW LB
// Byte 094 :           - MeasuredCartesianPosition_2.Rz LW HB
// Byte 095 :           - MeasuredCartesianPosition_2.Rz LW LB
// Byte 096 : Config    - MeasuredCartesianPosition_2.ArmConfig
// Byte 097 :           - MeasuredCartesianPosition_2.Reserve
// Byte 098 : TurnNumber- MeasuredCartesianPosition_2.TurnNumber.J1 + J2  HW HB
// Byte 099 :           - MeasuredCartesianPosition_2.TurnNumber.J3 + J4  HW LB
// Byte 100 :           - MeasuredCartesianPosition_2.TurnNumber.J5 + J6  LW LB
// Byte 101 :           - MeasuredCartesianPosition_2.TurnNumber.E1       LW LB
// Byte 102 : REAL      - MeasuredCartesianPosition_2.E1 HW HB
// Byte 103 :           - MeasuredCartesianPosition_2.E1 HW LB
// Byte 104 :           - MeasuredCartesianPosition_2.E1 LW HB
// Byte 105 :           - MeasuredCartesianPosition_2.E1 LW LB
// Byte 106 : REAL      - MeasuredJointPosition_2.J1 HW HB
// Byte 107 :           - MeasuredJointPosition_2.J1 HW LB
// Byte 108 :           - MeasuredJointPosition_2.J1 LW HB
// Byte 109 :           - MeasuredJointPosition_2.J1 LW LB
// Byte 110 : REAL      - MeasuredJointPosition_2.J2 HW HB
// Byte 111 :           - MeasuredJointPosition_2.J2 HW LB
// Byte 112 :           - MeasuredJointPosition_2.J2 LW HB
// Byte 113 :           - MeasuredJointPosition_2.J2 LW LB
// Byte 114 : REAL      - MeasuredJointPosition_2.J3 HW HB
// Byte 115 :           - MeasuredJointPosition_2.J3 HW LB
// Byte 116 :           - MeasuredJointPosition_2.J3 LW HB
// Byte 117 :           - MeasuredJointPosition_2.J3 LW LB
// Byte 118 : REAL      - MeasuredJointPosition_2.J4 HW HB
// Byte 119 :           - MeasuredJointPosition_2.J4 HW LB
// Byte 120 :           - MeasuredJointPosition_2.J4 LW HB
// Byte 121 :           - MeasuredJointPosition_2.J4 LW LB
// Byte 122 : REAL      - MeasuredJointPosition_2.J5 HW HB
// Byte 123 :           - MeasuredJointPosition_2.J5 HW LB
// Byte 124 :           - MeasuredJointPosition_2.J5 LW HB
// Byte 125 :           - MeasuredJointPosition_2.J5 LW LB
// Byte 126 : REAL      - MeasuredJointPosition_2.J6 HW HB
// Byte 127 :           - MeasuredJointPosition_2.J6 HW LB
// Byte 128 :           - MeasuredJointPosition_2.J6 LW HB
// Byte 129 :           - MeasuredJointPosition_2.J6 LW LB
// Byte 130 : REAL      - MeasuredJointPosition_2.E1 HW HB
// Byte 131 :           - MeasuredJointPosition_2.E1 HW LB
// Byte 132 :           - MeasuredJointPosition_2.E1 LW HB
// Byte 133 :           - MeasuredJointPosition_2.E1 LW LB
// Byte 134 : REAL      - MeasuredCartesianPosition_1.E2 HW HB
// Byte 135 :           - MeasuredCartesianPosition_1.E2 HW LB
// Byte 136 :           - MeasuredCartesianPosition_1.E2 LW HB
// Byte 137 :           - MeasuredCartesianPosition_1.E2 LW LB
// Byte 138 : REAL      - MeasuredCartesianPosition_1.E3 HW HB
// Byte 139 :           - MeasuredCartesianPosition_1.E3 HW LB
// Byte 140 :           - MeasuredCartesianPosition_1.E3 LW HB
// Byte 141 :           - MeasuredCartesianPosition_1.E3 LW LB
// Byte 142 : REAL      - MeasuredCartesianPosition_1.E4 HW HB
// Byte 143 :           - MeasuredCartesianPosition_1.E4 HW LB
// Byte 144 :           - MeasuredCartesianPosition_1.E4 LW HB
// Byte 145 :           - MeasuredCartesianPosition_1.E4 LW LB
// Byte 146 : REAL      - MeasuredCartesianPosition_1.E5 HW HB
// Byte 147 :           - MeasuredCartesianPosition_1.E5 HW LB
// Byte 148 :           - MeasuredCartesianPosition_1.E5 LW HB
// Byte 149 :           - MeasuredCartesianPosition_1.E5 LW LB
// Byte 150 : REAL      - MeasuredCartesianPosition_1.E6 HW HB
// Byte 151 :           - MeasuredCartesianPosition_1.E6 HW LB
// Byte 152 :           - MeasuredCartesianPosition_1.E6 LW HB
// Byte 153 :           - MeasuredCartesianPosition_1.E6 LW LB
// Byte 154 : REAL      - MeasuredJointPosition_1.E2 HW HB
// Byte 155 :           - MeasuredJointPosition_1.E2 HW LB
// Byte 156 :           - MeasuredJointPosition_1.E2 LW HB
// Byte 157 :           - MeasuredJointPosition_1.E2 LW LB
// Byte 158 : REAL      - MeasuredJointPosition_1.E3 HW HB
// Byte 159 :           - MeasuredJointPosition_1.E3 HW LB
// Byte 160 :           - MeasuredJointPosition_1.E3 LW HB
// Byte 161 :           - MeasuredJointPosition_1.E3 LW LB
// Byte 162 : REAL      - MeasuredJointPosition_1.E4 HW HB
// Byte 163 :           - MeasuredJointPosition_1.E4 HW LB
// Byte 164 :           - MeasuredJointPosition_1.E4 LW HB
// Byte 165 :           - MeasuredJointPosition_1.E4 LW LB
// Byte 166 : REAL      - MeasuredJointPosition_1.E5 HW HB
// Byte 167 :           - MeasuredJointPosition_1.E5 HW LB
// Byte 168 :           - MeasuredJointPosition_1.E5 LW HB
// Byte 169 :           - MeasuredJointPosition_1.E5 LW LB
// Byte 170 : REAL      - MeasuredJointPosition_1.E6 HW HB
// Byte 171 :           - MeasuredJointPosition_1.E6 HW LB
// Byte 172 :           - MeasuredJointPosition_1.E6 LW HB
// Byte 173 :           - MeasuredJointPosition_1.E6 LW LB
// Byte 174 : REAL      - MeasuredCartesianPosition_2.E2 HW HB
// Byte 175 :           - MeasuredCartesianPosition_2.E2 HW LB
// Byte 176 :           - MeasuredCartesianPosition_2.E2 LW HB
// Byte 177 :           - MeasuredCartesianPosition_2.E2 LW LB
// Byte 178 : REAL      - MeasuredCartesianPosition_2.E3 HW HB
// Byte 179 :           - MeasuredCartesianPosition_2.E3 HW LB
// Byte 180 :           - MeasuredCartesianPosition_2.E3 LW HB
// Byte 181 :           - MeasuredCartesianPosition_2.E3 LW LB
// Byte 182 : REAL      - MeasuredCartesianPosition_2.E4 HW HB
// Byte 183 :           - MeasuredCartesianPosition_2.E4 HW LB
// Byte 184 :           - MeasuredCartesianPosition_2.E4 LW HB
// Byte 185 :           - MeasuredCartesianPosition_2.E4 LW LB
// Byte 186 : REAL      - MeasuredCartesianPosition_2.E5 HW HB
// Byte 187 :           - MeasuredCartesianPosition_2.E5 HW LB
// Byte 188 :           - MeasuredCartesianPosition_2.E5 LW HB
// Byte 189 :           - MeasuredCartesianPosition_2.E5 LW LB
// Byte 190 : REAL      - MeasuredCartesianPosition_2.E6 HW HB
// Byte 191 :           - MeasuredCartesianPosition_2.E6 HW LB
// Byte 192 :           - MeasuredCartesianPosition_2.E6 LW HB
// Byte 193 :           - MeasuredCartesianPosition_2.E6 LW LB
// Byte 194 : REAL      - MeasuredJointPosition_2.E2 HW HB
// Byte 195 :           - MeasuredJointPosition_2.E2 HW LB
// Byte 196 :           - MeasuredJointPosition_2.E2 LW HB
// Byte 197 :           - MeasuredJointPosition_2.E2 LW LB
// Byte 198 : REAL      - MeasuredJointPosition_2.E3 HW HB
// Byte 199 :           - MeasuredJointPosition_2.E3 HW LB
// Byte 200 :           - MeasuredJointPosition_2.E3 LW HB
// Byte 201 :           - MeasuredJointPosition_2.E3 LW LB
// Byte 202 : REAL      - MeasuredJointPosition_2.E4 HW HB
// Byte 203 :           - MeasuredJointPosition_2.E4 HW LB
// Byte 204 :           - MeasuredJointPosition_2.E4 LW HB
// Byte 205 :           - MeasuredJointPosition_2.E4 LW LB
// Byte 206 : REAL      - MeasuredJointPosition_2.E5 HW HB
// Byte 207 :           - MeasuredJointPosition_2.E5 HW LB
// Byte 208 :           - MeasuredJointPosition_2.E5 LW HB
// Byte 209 :           - MeasuredJointPosition_2.E5 LW LB
// Byte 210 : REAL      - MeasuredJointPosition_2.E6 HW HB
// Byte 211 :           - MeasuredJointPosition_2.E6 HW LB
// Byte 212 :           - MeasuredJointPosition_2.E6 LW HB
// Byte 213 :           - MeasuredJointPosition_2.E6 LW LB

  // call base implementation to parse the header from payload buffer
  ResponseData.PayloadPtr := SUPER^.ParseResponsePayload(ResponseData := ResponseData, Timestamp := Timestamp);
  
  // copy parsed header to response
  _response.ParSeq               := _rspHeader.ParSeq;
  _response.State                := _rspHeader.State;
  _response.AlarmMessageSeverity := _rspHeader.AlarmMessageSeverity;
  _response.AlarmMessageCode     := _rspHeader.AlarmMessageCode;
  
  
  // Get Response.MeasuringID
  _response.MeasuringID   := ResponseData.GetUint();
  // Get Response.Measurings[1].ToolNo
  _response.Measurings[1].ToolNo := ResponseData.GetUsint();
  // Get Response.Measurings[1].FrameNo
  _response.Measurings[1].FrameNo := ResponseData.GetUsint();
  // Get Response.Measurings[2].ToolNo
  _response.Measurings[2].ToolNo := ResponseData.GetUsint();
  // Get Response.Measurings[2].FrameNo
  _response.Measurings[2].FrameNo := ResponseData.GetUsint();
  // Get Response.Measurings[1].MeasuredCartesianPosition.X
  _response.Measurings[1].MeasuredCartesianPosition.X := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Y
  _response.Measurings[1].MeasuredCartesianPosition.Y := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Z
  _response.Measurings[1].MeasuredCartesianPosition.Z := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Rx
  _response.Measurings[1].MeasuredCartesianPosition.Rx := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Ry
  _response.Measurings[1].MeasuredCartesianPosition.Ry := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Rz
  _response.Measurings[1].MeasuredCartesianPosition.Rz := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.Config
  _response.Measurings[1].MeasuredCartesianPosition.Config := ResponseData.GetArmConfig();
  // Get Response.Measurings[1].MeasuredCartesianPosition.TurnNumber
  _response.Measurings[1].MeasuredCartesianPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E1
  _response.Measurings[1].MeasuredCartesianPosition.E1 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J1
  _response.Measurings[1].MeasuredJointPosition.J1 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J2
  _response.Measurings[1].MeasuredJointPosition.J2 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J3
  _response.Measurings[1].MeasuredJointPosition.J3 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J4
  _response.Measurings[1].MeasuredJointPosition.J4 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J5
  _response.Measurings[1].MeasuredJointPosition.J5 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.J6
  _response.Measurings[1].MeasuredJointPosition.J6 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E1
  _response.Measurings[1].MeasuredJointPosition.E1 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.X
  _response.Measurings[2].MeasuredCartesianPosition.X := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Y
  _response.Measurings[2].MeasuredCartesianPosition.Y := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Z
  _response.Measurings[2].MeasuredCartesianPosition.Z := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Rx
  _response.Measurings[2].MeasuredCartesianPosition.Rx := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Ry
  _response.Measurings[2].MeasuredCartesianPosition.Ry := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Rz
  _response.Measurings[2].MeasuredCartesianPosition.Rz := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.Config
  _response.Measurings[2].MeasuredCartesianPosition.Config := ResponseData.GetArmConfig();
  // Get Response.Measurings[2].MeasuredCartesianPosition.TurnNumber
  _response.Measurings[2].MeasuredCartesianPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E1
  _response.Measurings[2].MeasuredCartesianPosition.E1 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J1
  _response.Measurings[2].MeasuredJointPosition.J1 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J2
  _response.Measurings[2].MeasuredJointPosition.J2 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J3
  _response.Measurings[2].MeasuredJointPosition.J3 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J4
  _response.Measurings[2].MeasuredJointPosition.J4 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J5
  _response.Measurings[2].MeasuredJointPosition.J5 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.J6
  _response.Measurings[2].MeasuredJointPosition.J6 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E1
  _response.Measurings[2].MeasuredJointPosition.E1 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E2
  _response.Measurings[1].MeasuredCartesianPosition.E2 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E3
  _response.Measurings[1].MeasuredCartesianPosition.E3 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E4
  _response.Measurings[1].MeasuredCartesianPosition.E4 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E5
  _response.Measurings[1].MeasuredCartesianPosition.E5 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredCartesianPosition.E6
  _response.Measurings[1].MeasuredCartesianPosition.E6 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E2
  _response.Measurings[1].MeasuredJointPosition.E2 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E3
  _response.Measurings[1].MeasuredJointPosition.E3 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E4
  _response.Measurings[1].MeasuredJointPosition.E4 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E5
  _response.Measurings[1].MeasuredJointPosition.E5 := ResponseData.GetReal();
  // Get Response.Measurings[1].MeasuredJointPosition.E6
  _response.Measurings[1].MeasuredJointPosition.E6 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E2
  _response.Measurings[2].MeasuredCartesianPosition.E2 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E3
  _response.Measurings[2].MeasuredCartesianPosition.E3 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E4
  _response.Measurings[2].MeasuredCartesianPosition.E4 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E5
  _response.Measurings[2].MeasuredCartesianPosition.E5 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredCartesianPosition.E6
  _response.Measurings[2].MeasuredCartesianPosition.E6 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E2
  _response.Measurings[2].MeasuredJointPosition.E2 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E3
  _response.Measurings[2].MeasuredJointPosition.E3 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E4
  _response.Measurings[2].MeasuredJointPosition.E4 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E5
  _response.Measurings[2].MeasuredJointPosition.E5 := ResponseData.GetReal();
  // Get Response.Measurings[2].MeasuredJointPosition.E6
  _response.Measurings[2].MeasuredJointPosition.E6 := ResponseData.GetReal();
  
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
END_VAR

  // Create log entry for Parameter start
  CreateLogMessage      ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Parsed the following parameter(s) from response data:');
                          
  // Create log entry for MeasuringID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.MeasuringID = {1}',
                          Para1       :=  UINT_TO_STRING(_response.MeasuringID));
  
  // Create log entry for MeasuringID
  CreateLogMessagePara1 ( Timestamp   := Timestamp,
                          MessageType := MessageType.CMD,
                          Severity    := Severity.DEBUG,
                          MessageCode := 0,
                          MessageText := 'Response.MeasuringID = {1}',
                          Para1       :=  UINT_TO_STRING(_response.MeasuringID));
  
  // Create log entry for Measurings[x]
  FOR _idx := 1 TO 2
  DO
    // Create log entry for Measurings[x].ToolNo
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].ToolNo = {1}',
                            Para1       :=  USINT_TO_STRING(_response.Measurings[_idx].ToolNo),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].FrameNo
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].FrameNo = {1}',
                            Para1       :=  USINT_TO_STRING(_response.Measurings[_idx].FrameNo),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Create log entry for Measurings[x]
  FOR _idx := 1 TO 2
  DO
    // Create log entry for Measurings[x].MeasuredCartesianPosition.X
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.X = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.X),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Y
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Y = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Y),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Z
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Z = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Z),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Rx
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Rx = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Rx),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Ry
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Ry = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Ry),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Rz
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Rz = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Rz),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.Config
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.Config = {1}',
                            Para1       :=  ARM_CONFIG_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.Config),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J1Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J1Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J1Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J2Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J2Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J2Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J3Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J3Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J3Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J4Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J4Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J4Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J5Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J5Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J5Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.J6Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.J6Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.J6Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.TurnNumber.E1Turns
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.TurnNumber.E1Turns = {1}',
                            Para1       :=  SINT_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.TurnNumber.E1Turns),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E1
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E1 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E1),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.J1
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J1 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J1),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.J2
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J2 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J2),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredJointPosition.J3
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J3 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J3),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.J4
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J4 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J4),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredJointPosition.J5
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J5 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J5),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.J6
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.J6 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.J6),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredJointPosition.E1
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E1 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E1),
                            Para2       :=  DINT_TO_STRING(_idx));
  END_FOR
  
  
  // Create log entry for Measurings[x]
  FOR _idx := 1 TO 2
  DO
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E2
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E2 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E2),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E3
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E3 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E3),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E4
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E4 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E4),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E5
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E5 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E5),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredCartesianPosition.E6
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredCartesianPosition.E6 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredCartesianPosition.E6),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredJointPosition.E2
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E2 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E2),
                            Para2       :=  DINT_TO_STRING(_idx));
  
    // Create log entry for Measurings[x].MeasuredJointPosition.E3
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E3 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E3),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.E4
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E4 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E4),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.E5
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E5 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E5),
                            Para2       :=  DINT_TO_STRING(_idx));
                            
    // Create log entry for Measurings[x].MeasuredJointPosition.E6
    CreateLogMessagePara2 ( Timestamp   := Timestamp,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'Response.Measurings[{2}].MeasuredJointPosition.E6 = {1}',
                            Para1       :=  REAL_TO_STRING(_response.Measurings[_idx].MeasuredJointPosition.E6),
                            Para2       :=  DINT_TO_STRING(_idx));
                       
  END_FOR

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

