/// Define work area
FUNCTION_BLOCK MC_WriteWorkAreaFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteWorkAreaFB                                       
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
  /// Processing Mode
  ProcessingMode     : ProcessingMode;
  /// command parameter 
  ParCmd             : WriteWorkAreaParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered    : BOOL;
  /// command outputs
  OutCmd             : WriteWorkAreaOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd             : WriteWorkAreaParCmd;
  /// command data to send
 _command            : WriteWorkAreaSendData;
  /// response data received
 _response           : WriteWorkAreaRecvData;      
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
  CheckParameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCmd), pData2 := ADR(_parCmd), DataLen := SIZEOF(ParCmd)) <> RobotLibraryConstants.OK );
  
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

METHOD INTERNAL CreateCommandPayload : RobotLibrarySendDataFB
// Table 6-205: Sent CMD payload (PLC to RC) of "WriteWorkArea"
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
// Byte 04 : UINT WorkAreaNo
// Byte 05 : 
// Byte 06 : DATE Data.Date
// Byte 07 : 
// Byte 08 : TIME_OF_DAY Data.Time
// Byte 09 : 
// Byte 10 : 
// Byte 11 : USINT - Data.AreaType
// Byte 12 : BOOL  - Data.AreaMode
// Byte 13 : USINT - Data.ReactionMode
// Byte 14 : BOOL  - Data.ActiveModification
// Byte 15 : USINT - Data.DefinitionMode
// Byte 16 : USINT - Data.FrameNo
// Byte 17 : 
// Byte 18 : REAL  - Data.ZeroPointX
// Byte 19 : 
// Byte 20 : 
// Byte 21 : 
// Byte 22 : REAL  - Data.ZeroPointY
// Byte 23 : 
// Byte 24 : 
// Byte 25 : 
// Byte 26 : REAL  - Data.ZeroPointZ
// Byte 27 : 
// Byte 28 : 
// Byte 29 : 
// Byte 30 : REAL  - Data.X1
// Byte 31 : 
// Byte 32 : 
// Byte 33 : 
// Byte 34 : REAL  - Data.X2
// Byte 35 : 
// Byte 36 : 
// Byte 37 : 
// Byte 38 : REAL  - Data.Y1
// Byte 39 : 
// Byte 40 : 
// Byte 41 : 
// Byte 42 : REAL  - Data.Y2
// Byte 43 : 
// Byte 44 : 
// Byte 45 : 
// Byte 46 : REAL  - Data.Z1
// Byte 47 : 
// Byte 48 : 
// Byte 49 : 
// Byte 50 : REAL  - Data.Z2
// Byte 51 : 
// Byte 52 : 
// Byte 53 : 
// Byte 54 : REAL  - Data.Radius
// Byte 55 : 
// Byte 56 : 
// Byte 57 : 
// Byte 58 : REAL  - Data.JointLowerLimit.J1
// Byte 59 : 
// Byte 60 : 
// Byte 61 : 
// Byte 62 : REAL  - Data.JointLowerLimit.J2
// Byte 63 : 
// Byte 64 : 
// Byte 65 : 
// Byte 66 : REAL  - Data.JointLowerLimit.J3
// Byte 67 : 
// Byte 68 : 
// Byte 69 : 
// Byte 70 : REAL  - Data.JointLowerLimit.J4
// Byte 71 : 
// Byte 72 : 
// Byte 73 : 
// Byte 74 : REAL  - Data.JointLowerLimit.J5
// Byte 75 : 
// Byte 76 : 
// Byte 77 : 
// Byte 78 : REAL  - Data.JointLowerLimit.J6
// Byte 79 : 
// Byte 80 : 
// Byte 81 : 
// Byte 82 : REAL  - Data.JointLowerLimit.E1
// Byte 83 : 
// Byte 84 : 
// Byte 85 : 
// Byte 86 : REAL  - Data.JointUpperLimit.J1
// Byte 87 : 
// Byte 88 : 
// Byte 89 : 
// Byte 90 : REAL  - Data.JointUpperLimit.J2
// Byte 91 : 
// Byte 92 : 
// Byte 93 : 
// Byte 94 : REAL  - Data.JointUpperLimit.J3
// Byte 95 : 
// Byte 96 : 
// Byte 97 : 
// Byte 98 : REAL  - Data.JointUpperLimit.J4
// Byte 99 : 
// Byte 100 : 
// Byte 101 : 
// Byte 102 : REAL - Data.JointUpperLimit.J5
// Byte 103 : 
// Byte 104 : 
// Byte 105 : 
// Byte 106 : REAL - Data.JointUpperLimit.J6
// Byte 107 : 
// Byte 108 : 
// Byte 109 : 
// Byte 110 : REAL - Data.JointUpperLimit.E1
// Byte 111 : 
// Byte 112 : 
// Byte 113 : 
// Byte 114 : REAL - Data.JointLowerLimit.E2
// Byte 115 : 
// Byte 116 : 
// Byte 117 : 
// Byte 118 : REAL - Data.JointLowerLimit.E3
// Byte 119 : 
// Byte 120 : 
// Byte 121 : 
// Byte 122 : REAL - Data.JointLowerLimit.E4
// Byte 123 : 
// Byte 124 : 
// Byte 125 : 
// Byte 126 : REAL - Data.JointLowerLimit.E5
// Byte 127 : 
// Byte 128 : 
// Byte 129 : 
// Byte 130 : REAL - Data.JointLowerLimit.E6
// Byte 131 : 
// Byte 132 : 
// Byte 133 : 
// Byte 134 : REAL - Data.JointUpperLimit.E2
// Byte 135 : 
// Byte 136 : 
// Byte 137 : 
// Byte 138 : REAL - Data.JointUpperLimit.E3
// Byte 139 : 
// Byte 140 : 
// Byte 141 : 
// Byte 142 : REAL - Data.JointUpperLimit.E4
// Byte 143 : 
// Byte 144 : 
// Byte 145 : 
// Byte 146 : REAL - Data.JointUpperLimit.E5
// Byte 147 : 
// Byte 148 : 
// Byte 149 : 
// Byte 150 : REAL - Data.JointUpperLimit.E6
// Byte 151 : 
// Byte 152 : 
// Byte 153 : 
// Byte 154 : BOOL - DataChanged
// --------------------------

  // set command parameter 
  _command.CmdTyp   :=  CmdType.WriteWorkArea;
  _command.ExecMode :=  ExecMode;
  _command.ParSeq   := _command.ParSeq;
  _command.Priority :=  Priority;
                    
  _command.WorkAreaData := _parCmd.WorkAreaData;
  _command.WorkAreaNo   := _parCmd.WorkAreaNo;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.WorkAreaNo
  CreateCommandPayload.AddUint(_command.WorkAreaNo);
  // add command.ToolData.Timestamp.IEC_DATE
  CreateCommandPayload.AddUint(_command.WorkAreaData.Timestamp.IEC_DATE);
  // add command.ToolData.Timestamp.IEC_TIME
  CreateCommandPayload.AddTime(_command.WorkAreaData.Timestamp.IEC_TIME);
  // add command.WorkAreaData.AreaType
  CreateCommandPayload.AddUsint(_command.WorkAreaData.AreaType);
  // add command.WorkAreaData.AreaMode
  CreateCommandPayload.AddBool(_command.WorkAreaData.AreaMode);
  // add command.WorkAreaData.ReactionMode
  CreateCommandPayload.AddUsint(_command.WorkAreaData.ReactionMode);
  // add command.WorkAreaData.ActiveModification
  CreateCommandPayload.AddBool(_command.WorkAreaData.ActiveModification);
  // add command.WorkAreaData.DefinitionMode
  CreateCommandPayload.AddUsint(_command.WorkAreaData.DefinitionMode);
  // add command.WorkAreaData.FrameNo
  CreateCommandPayload.AddUsint(_command.WorkAreaData.FrameNo);
  // add command.WorkAreaData.ZeroPointX
  CreateCommandPayload.AddReal(_command.WorkAreaData.ZeroPointX);
  // add command.WorkAreaData.ZeroPointY
  CreateCommandPayload.AddReal(_command.WorkAreaData.ZeroPointY);
  // add command.WorkAreaData.ZeroPointZ
  CreateCommandPayload.AddReal(_command.WorkAreaData.ZeroPointZ);
  
  
  // add command.WorkAreaData.X.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.X.LowerLimit);
  // add command.WorkAreaData.X.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.X.UpperLimit);
  // add command.WorkAreaData.Y.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.Y.LowerLimit);
  // add command.WorkAreaData.Y.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.Y.UpperLimit);
  // add command.WorkAreaData.Z.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.Z.LowerLimit);
  // add command.WorkAreaData.Z.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.Z.UpperLimit);
  // add command.WorkAreaData.Radius
  CreateCommandPayload.AddReal(_command.WorkAreaData.Radius);
  // add command.WorkAreaData.J1Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J1Limit.LowerLimit);
  // add command.WorkAreaData.J2Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J2Limit.LowerLimit);
  // add command.WorkAreaData.J3Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J3Limit.LowerLimit);
  // add command.WorkAreaData.J4Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J4Limit.LowerLimit);
  // add command.WorkAreaData.J5Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J5Limit.LowerLimit);
  // add command.WorkAreaData.J6Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J6Limit.LowerLimit);
  // add command.WorkAreaData.E1Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E1Limit.LowerLimit);
  // add command.WorkAreaData.J1Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J1Limit.UpperLimit);
  // add command.WorkAreaData.J2Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J2Limit.UpperLimit);
  // add command.WorkAreaData.J3Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J3Limit.UpperLimit);
  // add command.WorkAreaData.J4Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J4Limit.UpperLimit);
  // add command.WorkAreaData.J5Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J5Limit.UpperLimit);
  // add command.WorkAreaData.J6Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.J6Limit.UpperLimit);
  // add command.WorkAreaData.E1Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E1Limit.UpperLimit);
  // add command.WorkAreaData.E2Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E2Limit.LowerLimit);
  // add command.WorkAreaData.E3Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E3Limit.LowerLimit);
  // add command.WorkAreaData.E4Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E4Limit.LowerLimit);
  // add command.WorkAreaData.E5Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E5Limit.LowerLimit);
  // add command.WorkAreaData.E6Limit.LowerLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E6Limit.LowerLimit);
  // add command.WorkAreaData.E2Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E2Limit.UpperLimit);
  // add command.WorkAreaData.E3Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E3Limit.UpperLimit);
  // add command.WorkAreaData.E4Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E4Limit.UpperLimit);
  // add command.WorkAreaData.E5Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E5Limit.UpperLimit);
  // add command.WorkAreaData.E6Limit.UpperLimit
  CreateCommandPayload.AddReal(_command.WorkAreaData.E6Limit.UpperLimit);
  // add command.DataChanged
  CreateCommandPayload.AddBool(_command.DataChanged);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_WriteWorkAreaFB';
  
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
           SysDepMemSet(pDest := ADR(OutCmd), Value := 0, DataLen := SIZEOF(OutCmd));         
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
  
  
  // Reset FB
  IF ( NOT Execute )
  THEN
    Reset();  
  END_IF

END_METHOD

METHOD INTERNAL ParseResponsePayload : DINT
// Table 6-206: Received CMD payload (RC to PLC) of "WriteWorkArea"
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
VAR_INPUT
  /// Response data
  ResponseData : RobotLibraryRecvDataFB;
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

