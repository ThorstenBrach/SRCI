/// Automatic detection of load data
FUNCTION_BLOCK MC_LoadMeasurementAutomaticFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementAutomaticFB                                       
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
  /// Parameter which determines the behavior towards the previously sent and still active or buffered commands.
  AbortingMode    : AbortingMode;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag    : SequenceFlag;  
  /// Command parameter 
  ParCmd          : LoadMeasurementAutomaticParCmd;      
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
  OutCmd             : LoadMeasurementAutomaticOutCmd;        
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd          : LoadMeasurementAutomaticParCmd;
  /// command data to send
 _command         : LoadMeasurementAutomaticSendData;
  /// response data received
 _response        : LoadMeasurementAutomaticRecvData;      
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

METHOD INTERNAL CreateCommandPayload : SendData
// Table 6-778: Sent CMD payload (PLC to RC) of "LoadMeasurementAutomatic"
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
// Byte 009 : BYTE       - Reserved
// Byte 010 : REAL       - AreaJ3[0] HW HB
// Byte 011 :            - AreaJ3[0] HW LB
// Byte 012 :            - AreaJ3[0] LW HB
// Byte 013 :            - AreaJ3[0] LW LB
// Byte 014 : REAL       - AreaJ3[1] HW HB
// Byte 015 :            - AreaJ3[1] HW LB
// Byte 016 :            - AreaJ3[1] LW HB
// Byte 017 :            - AreaJ3[1] LW LB
// Byte 018 : REAL       - AreaJ4[0] HW HB
// Byte 019 :            - AreaJ4[0] HW LB
// Byte 020 :            - AreaJ4[0] LW HB
// Byte 021 :            - AreaJ4[0] LW LB
// Byte 022 : REAL       - AreaJ4[1] HW HB
// Byte 023 :            - AreaJ4[1] HW LB
// Byte 024 :            - AreaJ4[1] LW HB
// Byte 025 :            - AreaJ4[1] LW LB
// Byte 026 : REAL       - AreaJ5[0] HW HB
// Byte 027 :            - AreaJ5[0] HW LB
// Byte 028 :            - AreaJ5[0] LW HB
// Byte 029 :            - AreaJ5[0] LW LB
// Byte 030 : REAL       - AreaJ5[1] HW HB
// Byte 031 :            - AreaJ5[1] HW LB
// Byte 032 :            - AreaJ5[1] LW HB
// Byte 033 :            - AreaJ5[1] LW LB
// Byte 034 : REAL       - AreaJ6[0] HW HB
// Byte 035 :            - AreaJ6[0] HW LB
// Byte 036 :            - AreaJ6[0] LW HB
// Byte 037 :            - AreaJ6[0] LW LB
// Byte 038 : REAL       - AreaJ6[1] HW HB
// Byte 039 :            - AreaJ6[1] HW LB
// Byte 040 :            - AreaJ6[1] LW HB
// Byte 041 :            - AreaJ6[1] LW LB
// Byte 042 : REAL       - ConfigurationAngle HW HB
// Byte 043 :            - ConfigurationAngle HW LB
// Byte 044 :            - ConfigurationAngle LW HB
// Byte 045 :            - ConfigurationAngle LW LB
// Byte 046 : REAL       - Position_1.J1 HW HB
// Byte 047 :            - Position_1.J1 HW LB
// Byte 048 :            - Position_1.J1 LW HB
// Byte 049 :            - Position_1.J1 LW LB
// Byte 050 : REAL       - Position_1.J2 HW HB
// Byte 051 :            - Position_1.J2 HW LB
// Byte 052 :            - Position_1.J2 LW HB
// Byte 053 :            - Position_1.J2 LW LB
// Byte 054 : REAL       - Position_1.J3 HW HB
// Byte 055 :            - Position_1.J3 HW LB
// Byte 056 :            - Position_1.J3 LW HB
// Byte 057 :            - Position_1.J3 LW LB
// Byte 058 : REAL       - Position_1.J4 HW HB
// Byte 059 :            - Position_1.J4 HW LB
// Byte 060 :            - Position_1.J4 LW HB
// Byte 061 :            - Position_1.J4 LW LB
// Byte 062 : REAL       - Position_1.J5 HW HB
// Byte 063 :            - Position_1.J5 HW LB
// Byte 064 :            - Position_1.J5 LW HB
// Byte 065 :            - Position_1.J5 LW LB
// Byte 066 : REAL       - Position_1.J6 HW HB
// Byte 067 :            - Position_1.J6 HW LB
// Byte 068 :            - Position_1.J6 LW HB
// Byte 069 :            - Position_1.J6 LW LB
// Byte 070 : REAL       - Position_1.E1 HW HB
// Byte 071 :            - Position_1.E1 HW LB
// Byte 072 :            - Position_1.E1 LW HB
// Byte 073 :            - Position_1.E1 LW LB
// Byte 074 : REAL       - Position_2.J1 HW HB
// Byte 075 :            - Position_2.J1 HW LB
// Byte 076 :            - Position_2.J1 LW HB
// Byte 077 :            - Position_2.J1 LW LB
// Byte 078 : REAL       - Position_2.J2 HW HB
// Byte 079 :            - Position_2.J2 HW LB
// Byte 080 :            - Position_2.J2 LW HB
// Byte 081 :            - Position_2.J2 LW LB
// Byte 082 : REAL       - Position_2.J3 HW HB
// Byte 083 :            - Position_2.J3 HW LB
// Byte 084 :            - Position_2.J3 LW HB
// Byte 085 :            - Position_2.J3 LW LB
// Byte 086 : REAL       - Position_2.J4 HW HB
// Byte 087 :            - Position_2.J4 HW LB
// Byte 088 :            - Position_2.J4 LW HB
// Byte 089 :            - Position_2.J4 LW LB
// Byte 090 : REAL       - Position_2.J5 HW HB
// Byte 091 :            - Position_2.J5 HW LB
// Byte 092 :            - Position_2.J5 LW HB
// Byte 093 :            - Position_2.J5 LW LB
// Byte 094 : REAL       - Position_2.J6 HW HB
// Byte 095 :            - Position_2.J6 HW LB
// Byte 096 :            - Position_2.J6 LW HB
// Byte 097 :            - Position_2.J6 LW LB
// Byte 098 : REAL       - Position_2.E1 HW HB
// Byte 099 :            - Position_2.E1 HW LB
// Byte 100 :            - Position_2.E1 LW HB
// Byte 101 :            - Position_2.E1 LW LB
// Byte 102 : REAL       - Position_1.E1 HW HB
// Byte 103 :            - Position_1.E2 HW LB
// Byte 104 :            - Position_1.E2 LW HB
// Byte 105 :            - Position_1.E2 LW LB
// Byte 106 : REAL       - Position_1.E3 HW HB
// Byte 107 :            - Position_1.E3 HW LB
// Byte 108 :            - Position_1.E3 LW HB
// Byte 109 :            - Position_1.E3 LW LB
// Byte 110 : REAL       - Position_1.E4 HW HB
// Byte 111 :            - Position_1.E4 HW LB
// Byte 112 :            - Position_1.E4 LW HB
// Byte 113 :            - Position_1.E4 LW LB
// Byte 114 : REAL       - Position_1.E5 HW HB
// Byte 115 :            - Position_1.E5 HW LB
// Byte 116 :            - Position_1.E5 LW HB
// Byte 117 :            - Position_1.E5 LW LB
// Byte 118 : REAL       - Position_1.E6 HW HB
// Byte 119 :            - Position_1.E6 HW LB
// Byte 120 :            - Position_1.E6 LW HB
// Byte 121 :            - Position_1.E6 LW LB
// Byte 122 : REAL       - Position_2.E2 HW HB
// Byte 123 :            - Position_2.E2 HW LB
// Byte 124 :            - Position_2.E2 LW HB
// Byte 125 :            - Position_2.E2 LW LB
// Byte 125 : REAL       - Position_2.E3 HW HB
// Byte 127 :            - Position_2.E3 HW LB
// Byte 128 :            - Position_2.E3 LW HB
// Byte 129 :            - Position_2.E3 LW LB
// Byte 130 : REAL       - Position_2.E4 HW HB
// Byte 131 :            - Position_2.E4 HW LB
// Byte 132 :            - Position_2.E4 LW HB
// Byte 133 :            - Position_2.E4 LW LB
// Byte 134 : REAL       - Position_2.E5 HW HB
// Byte 135 :            - Position_2.E5 HW LB
// Byte 136 :            - Position_2.E5 LW HB
// Byte 137 :            - Position_2.E5 LW LB
// Byte 138 : REAL       - Position_2.E6 HW HB
// Byte 139 :            - Position_2.E6 HW LB
// Byte 140 :            - Position_2.E6 LW HB
// Byte 141 :            - Position_2.E6 LW LB

  // set command parameter 
  _command.CmdTyp             :=  CmdType.LoadMeasurementAutomatic;
  _command.ExecMode           :=  ExecMode;
  _command.ParSeq             := _command.ParSeq;
  _command.Priority           :=  Priority;
  
  _command.Mass               := parCmd.Mass;
  _command.Mode               := parCmd.Mode;
  _command.Reserved           := 0;
  _command.Area_J3            := parCmd.Area_J3;
  _command.Area_J4            := parCmd.Area_J4;
  _command.Area_J5            := parCmd.Area_J5;
  _command.Area_J6            := parCmd.Area_J6;
  _command.ConfigurationAngle := parCmd.ConfigurationAngle;
  _command.Position_1         := parCmd.Position_1;
  _command.Position_2         := parCmd.Position_2;
  
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.Mass
  CreateCommandPayload.AddReal(_command.Mass);
  // add command.Mode
  CreateCommandPayload.AddUsint(_command.Mode);
  // add command.Reserved
  CreateCommandPayload.AddByte(_command.Reserved);
  // add command.Area_J3[0]
  CreateCommandPayload.AddReal(_command.Area_J3[0]);
  // add command.Area_J3[1]
  CreateCommandPayload.AddReal(_command.Area_J3[1]);
  // add command.Area_J4[0]
  CreateCommandPayload.AddReal(_command.Area_J4[0]);
  // add command.Area_J4[1]
  CreateCommandPayload.AddReal(_command.Area_J4[1]);
  // add command.Area_J5[0]
  CreateCommandPayload.AddReal(_command.Area_J5[0]);
  // add command.Area_J5[1]
  CreateCommandPayload.AddReal(_command.Area_J5[1]);
  // add command.Area_J6[0]
  CreateCommandPayload.AddReal(_command.Area_J6[0]);
  // add command.Area_J6[1]
  CreateCommandPayload.AddReal(_command.Area_J6[1]);
  // add command.ConfigurationAngle
  CreateCommandPayload.AddReal(_command.ConfigurationAngle);
  // add command.Position_1.J1
  CreateCommandPayload.AddReal(_command.Position_1.J1);
  // add command.Position_1.J2
  CreateCommandPayload.AddReal(_command.Position_1.J2);
  // add command.Position_1.J3
  CreateCommandPayload.AddReal(_command.Position_1.J3);
  // add command.Position_1.J4
  CreateCommandPayload.AddReal(_command.Position_1.J4);
  // add command.Position_1.J5
  CreateCommandPayload.AddReal(_command.Position_1.J5);
  // add command.Position_1.J6
  CreateCommandPayload.AddReal(_command.Position_1.J6);
  // add command.Position_1.E1
  CreateCommandPayload.AddReal(_command.Position_1.E1);
  // add command.Position_1.E2
  CreateCommandPayload.AddReal(_command.Position_1.E2);
  // add command.Position_1.E3
  CreateCommandPayload.AddReal(_command.Position_1.E3);
  // add command.Position_1.E4
  CreateCommandPayload.AddReal(_command.Position_1.E4);
  // add command.Position_1.E5
  CreateCommandPayload.AddReal(_command.Position_1.E5);
  // add command.Position_1.E6
  CreateCommandPayload.AddReal(_command.Position_1.E6);
  // add command.Position_2.J1
  CreateCommandPayload.AddReal(_command.Position_2.J1);
  // add command.Position_2.J2
  CreateCommandPayload.AddReal(_command.Position_2.J2);
  // add command.Position_2.J3
  CreateCommandPayload.AddReal(_command.Position_2.J3);
  // add command.Position_2.J4
  CreateCommandPayload.AddReal(_command.Position_2.J4);
  // add command.Position_2.J5
  CreateCommandPayload.AddReal(_command.Position_2.J5);
  // add command.Position_2.J6
  CreateCommandPayload.AddReal(_command.Position_2.J6);
  // add command.Position_2.E1
  CreateCommandPayload.AddReal(_command.Position_2.E1);
  // add command.Position_2.E2
  CreateCommandPayload.AddReal(_command.Position_2.E2);
  // add command.Position_2.E3
  CreateCommandPayload.AddReal(_command.Position_2.E3);
  // add command.Position_2.E4
  CreateCommandPayload.AddReal(_command.Position_2.E4);
  // add command.Position_2.E5
  CreateCommandPayload.AddReal(_command.Position_2.E5);
  // add command.Position_2.E6
  CreateCommandPayload.AddReal(_command.Position_2.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_LoadMeasurementAutomaticFB';

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
// Table 6-778: Sent CMD payload (PLC to RC) of "LoadMeasurementAutomatic"
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
