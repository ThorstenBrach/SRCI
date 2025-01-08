/// Transform a defined position in space
FUNCTION_BLOCK MC_ShiftPositionFB EXTENDS RobotLibraryBaseExecuteFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ShiftPositionFB                                       
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
  ParCmd          : ShiftPositionParCmd;
END_VAR
VAR_OUTPUT
  /// Command is transferred and confirmed by the RC
  CommandBuffered : BOOL;
  /// command results
  OutCmd          : ShiftPositionOutCmd;    
END_VAR
VAR
  /// internal copy of command parameter 
 _parCmd          : ShiftPositionParCmd;
  /// command data to send
 _command         : ShiftPositionSendData;
  /// response data received
 _response        : ShiftPositionRecvData;      
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
// Table 6-668: Sent CMD payload (PLC to RC) of "ShiftPosition"
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
// Byte 04  : IEC_DATE  - TransformationParameter_1.Date
// Byte 05  :           - Reserved
// Byte 06  : IEC_TIME  - TransformationParameter_1.Time HW HB
// Byte 07  :           - TransformationParameter_1.Time HW LB
// Byte 08  :           - TransformationParameter_1.Time LW HB
// Byte 09  :           - TransformationParameter_1.Time LW LB
// Byte 10  : USINT     - TransformationParameter_1.ReferenceFrame
// Byte 11  : BYTE      - Reserved
// Byte 12  : REAL      - TransformationParameter_1.X HW HB
// Byte 13  :           - TransformationParameter_1.X HW LB
// Byte 14  :           - TransformationParameter_1.X LW HB
// Byte 15  :           - TransformationParameter_1.X LW LB
// Byte 16  : REAL      - TransformationParameter_1.Y HW HB
// Byte 17  :           - TransformationParameter_1.Y HW LB
// Byte 18  :           - TransformationParameter_1.Y LW HB
// Byte 19  :           - TransformationParameter_1.Y LW LB
// Byte 20  : REAL      - TransformationParameter_1.Z HW HB
// Byte 21  :           - TransformationParameter_1.Z HW LB
// Byte 22  :           - TransformationParameter_1.Z LW HB
// Byte 23  :           - TransformationParameter_1.Z LW LB
// Byte 24  : REAL      - TransformationParameter_1.RX HW HB
// Byte 25  :           - TransformationParameter_1.RX HW LB
// Byte 26  :           - TransformationParameter_1.RX LW HB
// Byte 27  :           - TransformationParameter_1.RX LW LB
// Byte 28  : REAL      - TransformationParameter_1.RY HW HB
// Byte 29  :           - TransformationParameter_1.RY HW LB
// Byte 30  :           - TransformationParameter_1.RY LW HB
// Byte 31  :           - TransformationParameter_1.RY LW LB
// Byte 32  : REAL      - TransformationParameter_1.RZ HW HB
// Byte 33  :           - TransformationParameter_1.RZ HW LB
// Byte 34  :           - TransformationParameter_1.RZ LW HB
// Byte 35  :           - TransformationParameter_1.RZ LW LB
// Byte 36  : USINT     - TransformationParameter_2
// Byte 37  : REAL      - RotationAngle HW HB
// Byte 38  :           - RotationAngle HW LB
// Byte 39  :           - RotationAngle LW HB
// Byte 40  :           - RotationAngle LW LB
// Byte 41  : SINT      - Mode
// Byte 42  : USINT     - FrameNo
// Byte 43  : USINT     - TargetFrameNo
// Byte 44  : REAL      - Position.X HW HB
// Byte 45  :           - Position.X HW LB
// Byte 46  :           - Position.X LW HB
// Byte 47  :           - Position.X LW LB
// Byte 48  : REAL      - Position.Y HW HB
// Byte 49  :           - Position.Y HW LB
// Byte 50  :           - Position.Y LW HB
// Byte 51  :           - Position.Y LW LB
// Byte 52  : REAL      - Position.Z HW HB
// Byte 53  :           - Position.Z HW LB
// Byte 54  :           - Position.Z LW HB
// Byte 55  :           - Position.Z LW LB
// Byte 56  : REAL      - Position.RX HW HB
// Byte 57  :           - Position.RX HW LB
// Byte 58  :           - Position.RX LW HB
// Byte 59  :           - Position.RX LW LB
// Byte 60  : REAL      - Position.RY HW HB
// Byte 61  :           - Position.RY HW LB
// Byte 62  :           - Position.RY LW HB
// Byte 63  :           - Position.RY LW LB
// Byte 64  : REAL      - Position.RZ HW HB
// Byte 65  :           - Position.RZ HW LB
// Byte 66  :           - Position.RZ LW HB
// Byte 67  :           - Position.RZ LW LB
// Byte 68  : ArmConfig - Position.Config
// Byte 69  :           -          Reserve
// Byte 70 : TurnNumber - Position.TurnNumber.J1 + J2  HW HB
// Byte 71 :            - Position.TurnNumber.J3 + J4  HW LB
// Byte 72 :            - Position.TurnNumber.J5 + J6  LW LB
// Byte 73 :            - Position.TurnNumber.E1       LW LB
// Byte 74  : REAL      - Position.E1 HW HB
// Byte 75  :           - Position.E1 HW LB
// Byte 76  :           - Position.E1 LW HB
// Byte 77  :           - Position.E1 LW LB
// Byte 78  : REAL      - Position.E2 HW HB
// Byte 79  :           - Position.E2 HW LB
// Byte 80  :           - Position.E2 LW HB
// Byte 81  :           - Position.E2 LW LB
// Byte 82  : REAL      - Position.E3 HW HB
// Byte 83  :           - Position.E3 HW LB
// Byte 84  :           - Position.E3 LW HB
// Byte 85  :           - Position.E3 LW LB
// Byte 86  : REAL      - Position.E4 HW HB
// Byte 87  :           - Position.E4 HW LB
// Byte 88  :           - Position.E4 LW HB
// Byte 89  :           - Position.E4 LW LB
// Byte 90  : REAL      - Position.E5 HW HB
// Byte 91  :           - Position.E5 HW LB
// Byte 92  :           - Position.E5 LW HB
// Byte 93  :           - Position.E5 LW LB
// Byte 94  : REAL      - Position.E6 HW HB
// Byte 95  :           - Position.E6 HW LB
// Byte 96  :           - Position.E6 LW HB
// Byte 97  :           - Position.E6 LW LB

  // set command parameter 
  _command.CmdTyp                    :=  CmdType.ShiftPosition;
  _command.ExecMode                  :=  ExecMode;
  _command.ParSeq                    := _command.ParSeq;
  _command.Priority                  :=  Priority;
  _command.TransformationParameter_1 := _parCmd.TransformationParameter_1;
  _command.TransformationParameter_2 := _parCmd.TransformationParameter_2;
  _command.RotationAngle             := _parCmd.RotationAngle;
  _command.Mode                      := _parCmd.Mode;
  _command.FrameNo                   := _parCmd.FrameNo;
  _command.TargetFrameNo             := _parCmd.TargetFrameNo;
  _command.Position                  := _parCmd.Position;
  
  // copy command data to header
  _cmdHeader := _command;
  // call base implementation to copy header to payload buffer
  CreateCommandPayload := SUPER^.CreateCommandPayload();
  
  // add command.TransformationParameter_1.Timestamp.IEC_DATE
  CreateCommandPayload.AddIecDate(_command.TransformationParameter_1.Timestamp.IEC_DATE);
  // add command.TransformationParameter_1.Timestamp.IEC_TIME
  CreateCommandPayload.AddIecTime(_command.TransformationParameter_1.Timestamp.IEC_TIME);
  // add command.TransformationParameter_1.ReferenceFrame
  CreateCommandPayload.AddUsint(_command.TransformationParameter_1.ReferenceFrame);
  // add command.Reserve
  CreateCommandPayload.AddByte(0);
  // add command.TransformationParameter_1.X
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.X);
  // add command.TransformationParameter_1.Y
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Y);
  // add command.TransformationParameter_1.Z
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Z);
  // add command.TransformationParameter_1.Rx
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Rx);
  // add command.TransformationParameter_1.Ry
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Ry);
  // add command.TransformationParameter_1.Rz
  CreateCommandPayload.AddReal(_command.TransformationParameter_1.Rz);
  // add command.TransformationParameter_2
  CreateCommandPayload.AddUsint(_command.TransformationParameter_2);
  // add command.RotationAngle
  CreateCommandPayload.AddReal(_command.RotationAngle);
  // add command.Mode
  CreateCommandPayload.AddSint(_command.Mode);
  // add command.FrameNo
  CreateCommandPayload.AddUsint(_command.FrameNo);
  // add command.TargetFrameNo
  CreateCommandPayload.AddUsint(_command.TargetFrameNo);
  // add command.Position.X
  CreateCommandPayload.AddReal(_command.Position.X);
  // add command.Position.Y
  CreateCommandPayload.AddReal(_command.Position.Y);
  // add command.Position.Z
  CreateCommandPayload.AddReal(_command.Position.Z);
  // add command.Position.Rx
  CreateCommandPayload.AddReal(_command.Position.Rx);
  // add command.Position.Ry
  CreateCommandPayload.AddReal(_command.Position.Ry);
  // add command.Position.Rz
  CreateCommandPayload.AddReal(_command.Position.Rz);
  // add command.Position.Config
  CreateCommandPayload.AddArmConfig(_command.Position.Config);
  // add command.Position.Config
  CreateCommandPayload.AddTurnNumber(_command.Position.TurnNumber);
  // add command.Position.E1
  CreateCommandPayload.AddReal(_command.Position.E1);
  // add command.Position.E2
  CreateCommandPayload.AddReal(_command.Position.E2);
  // add command.Position.E3
  CreateCommandPayload.AddReal(_command.Position.E3);
  // add command.Position.E4
  CreateCommandPayload.AddReal(_command.Position.E4);
  // add command.Position.E5
  CreateCommandPayload.AddReal(_command.Position.E5);
  // add command.Position.E6
  CreateCommandPayload.AddReal(_command.Position.E6);

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
  bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
  bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ShiftPositionFB';
  
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
             // Update results
             OutCmd.TransformedPosition := _response.TransformedPosition;
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
// Table 6-669: Received CMD payload (RC to PLC) of "ShiftPosition"
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
// Byte 04  : REAL      - TransformedPosition.X HW HB
// Byte 05  :           - TransformedPosition.X HW LB
// Byte 06  :           - TransformedPosition.X LW HB
// Byte 07  :           - TransformedPosition.X LW LB
// Byte 08  : REAL      - TransformedPosition.Y HW HB
// Byte 09  :           - TransformedPosition.Y HW LB
// Byte 10  :           - TransformedPosition.Y LW HB
// Byte 11  :           - TransformedPosition.Y LW LB
// Byte 12  : REAL      - TransformedPosition.Z HW HB
// Byte 13  :           - TransformedPosition.Z HW LB
// Byte 14  :           - TransformedPosition.Z LW HB
// Byte 15  :           - TransformedPosition.Z LW LB
// Byte 16  : REAL      - TransformedPosition.RX HW HB
// Byte 17  :           - TransformedPosition.RX HW LB
// Byte 18  :           - TransformedPosition.RX LW HB
// Byte 19  :           - TransformedPosition.RX LW LB
// Byte 20  : REAL      - TransformedPosition.RY HW HB
// Byte 21  :           - TransformedPosition.RY HW LB
// Byte 22  :           - TransformedPosition.RY LW HB
// Byte 23  :           - TransformedPosition.RY LW LB
// Byte 24  : REAL      - TransformedPosition.RZ HW HB
// Byte 25  :           - TransformedPosition.RZ HW LB
// Byte 26  :           - TransformedPosition.RZ LW HB
// Byte 27  :           - TransformedPosition.RZ LW LB
// Byte 28  : ArmConfig - TransformedPosition.Config
// Byte 29  :           - Reserved
// Byte 30  : TurnNumber- TransformedPosition.TurnNumber.J1 + J2  HW HB
// Byte 31  :           - TransformedPosition.TurnNumber.J3 + J4  HW LB
// Byte 32  :           - TransformedPosition.TurnNumber.J5 + J6  LW LB
// Byte 33  :           - TransformedPosition.TurnNumber.E1       LW LB
// Byte 34  : REAL      - TransformedPosition.E1 HW HB
// Byte 35  :           - TransformedPosition.E1 HW LB
// Byte 36  :           - TransformedPosition.E1 LW HB
// Byte 37  :           - TransformedPosition.E1 LW LB
// Byte 38  : REAL      - TransformedPosition.E2 HW HB
// Byte 39  :           - TransformedPosition.E2 HW LB
// Byte 40  :           - TransformedPosition.E2 LW HB
// Byte 41  :           - TransformedPosition.E2 LW LB
// Byte 42  : REAL      - TransformedPosition.E3 HW HB
// Byte 43  :           - TransformedPosition.E3 HW LB
// Byte 44  :           - TransformedPosition.E3 LW HB
// Byte 45  :           - TransformedPosition.E3 LW LB
// Byte 46  : REAL      - TransformedPosition.E4 HW HB
// Byte 47  :           - TransformedPosition.E4 HW LB
// Byte 48  :           - TransformedPosition.E4 LW HB
// Byte 49  :           - TransformedPosition.E4 LW LB
// Byte 50  : REAL      - TransformedPosition.E5 HW HB
// Byte 51  :           - TransformedPosition.E5 HW LB
// Byte 52  :           - TransformedPosition.E5 LW HB
// Byte 53  :           - TransformedPosition.E5 LW LB
// Byte 54  : REAL      - TransformedPosition.E6 HW HB
// Byte 55  :           - TransformedPosition.E6 HW LB
// Byte 56  :           - TransformedPosition.E6 LW HB
// Byte 57  :           - TransformedPosition.E6 LW LB
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
  
  // Get Response.TransformedPosition.X
  _response.TransformedPosition.X := ResponseData.GetReal();
  // Get Response.TransformedPosition.Y
  _response.TransformedPosition.Y := ResponseData.GetReal();
  // Get Response.TransformedPosition.Z
  _response.TransformedPosition.Z := ResponseData.GetReal();
  // Get Response.TransformedPosition.Rx
  _response.TransformedPosition.Rx := ResponseData.GetReal();
  // Get Response.TransformedPosition.Ry
  _response.TransformedPosition.Ry := ResponseData.GetReal();
  // Get Response.TransformedPosition.Rz
  _response.TransformedPosition.Rz := ResponseData.GetReal();
  // Get Response.TransformedPosition.Config
  _response.TransformedPosition.Config := ResponseData.GetArmConfig();
  // Get Response.TransformedPosition.TurnNumber
  _response.TransformedPosition.TurnNumber := ResponseData.GetTurnNumbers();
  // Get Response.TransformedPosition.E1
  _response.TransformedPosition.E1 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E2
  _response.TransformedPosition.E2 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E3
  _response.TransformedPosition.E3 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E4
  _response.TransformedPosition.E4 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E5
  _response.TransformedPosition.E5 := ResponseData.GetReal();
  // Get Response.TransformedPosition.E6
  _response.TransformedPosition.E6 := ResponseData.GetReal();

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  Reset := SUPER^.Reset();
  
  Done               := FALSE;
  Busy               := FALSE;
  CommandBuffered    := FALSE;

END_METHOD

