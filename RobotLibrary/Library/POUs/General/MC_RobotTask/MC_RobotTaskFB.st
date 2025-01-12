/// Handles multiple mechanisms required for operation of the interface.
FUNCTION_BLOCK MC_RobotTaskFB EXTENDS RobotLibraryLogFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotTaskFB                                       
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
  /// Stäubli simulator 
  STAUBLI_SIMULATOR : BOOL; {warning 'ToDo: Remove'}
  /// Set TRUE (default) to initialize the interface
  Enable            : BOOL;
  /// User defined robot name
  RobotName         : STRING(20);
  /// Current System Time
  SystemTime        : SystemTime;
  /// Online Change detected
  OnlineChange      : BOOL;
  /// Axes Group ID -> is used to uniquely identify each RA on a per RC basis.
  ///
  /// For convenience, an RC with only one RA must assign ID 1 to this RA. 
  /// An RC with multiple RAs must assign numeric values 1-15 to those RAs.
  AxesGroupID       : BYTE;
  /// Flag for clear error
  ErrorClear        : BOOL;
  /// Configuration parameter
  ParCfg            : RobotTaskParCfg;
END_VAR

VAR_IN_OUT
  /// Inputs of PLC for communication from RC
  RobotInData       : ARRAY[0..RobotLibraryParameter.ROBOT_IN_DATA_MAX ] OF BYTE;
  /// Outputs of PLC for communication to RC
  RobotOutData      : ARRAY[0..RobotLibraryParameter.ROBOT_OUT_DATA_MAX] OF BYTE;
  ///  User data stored on the PLC according to Table 6-10
  UserData          : UserData;
  /// ToolData stored on PLC. For more information refer to 5.5.6.3
  ToolData          : ARRAY[1..RobotLibraryParameter.TOOL_MAX      ] OF ToolData;
  /// LoadData stored on PLC.For more information refer to 5.5.6.4
  FrameData         : ARRAY[1..RobotLibraryParameter.FRAME_MAX     ] OF FrameData;
  /// LoadData stored on PLC.For more information refer to 5.5.6.4
  LoadData          : ARRAY[1..RobotLibraryParameter.LOAD_MAX      ] OF LoadData;
  /// Work areas stored on PLC. For more information refer to 5.5.8
  WorkAreas         : ARRAY[1..RobotLibraryParameter.WORK_AREAS_MAX] OF RobotWorkArea;
  /// Software limits stored on PLC
  SoftwareLimits    : SWLimits;
  /// Default dynamics stored on PLC. For more information refer to 5.5.7
  DefaultDynamics   : DefaultDynamics;
  /// Reference dynamics stored on PLC. For more information refer to 5.5.7
  ReferenceDynamics : ReferenceDynamics;
  /// System log on PLC
  SystemLog         : ARRAY[0..RobotLibraryParameter.SYSTEM_LOG_MAX ] OF STRING(255);
  /// Message buffer on the PLC - For more information refer to 5.5.11
  MessageLog        : ARRAY[0..RobotLibraryParameter.MESSAGE_LOG_MAX] OF AlarmMessage;
  /// Robot assignment of function
  AxesGroup         : AxesGroup;
END_VAR

VAR_OUTPUT
  /// FB is being processed
  Busy              : BOOL;
  /// Interface is initialized (RI state: "Initialized").
  /// For more information on RI states refer to chapter 5.5.3.1.
  Initialized       : BOOL;
  /// Server and client were successfully synchronized (RI state: "Synchronized").
  /// For more information on the synchronization mechanism refer to chapter 5.6.7.
  Synchronized      : BOOL;
  /// An error occurred
  Error             : BOOL;
  /// ErrorID reported by RC for error identification according to Table 7-1
  ErrorID           : WORD;
  ErrorIdEnum       : RobotLibraryErrorIdEnum;  
  ErrorAddTxt       : STRING(RobotLibraryConstants.MAX_ADD_TEXT_LENGTH);
  /// WarningID for warning identification reported during execution of command according to Table 7-3
  WarningID         : WORD;
  WarningIdEnum     : RobotLibraryWarningIdEnum;  
  /// InfoID for info identification reported during execution of command according to Table 7-5
  InfoID            : WORD;    
  InfoIdEnum        : RobotLibraryInfoIdEnum;    
  /// Invalid frames counter
  InvalidFrames     : UDINT;
END_VAR

VAR
  /// internal copy of configuration parameter
 _parCfg                : RobotTaskParCfg;

  /// FB for exchange configuration
  ExchangeConfiguration : MC_ExchangeConfigurationFB;
  /// FB for read robot data
  ReadRobotData         : MC_ReadRobotDataFB;
  /// FB for read messaged
  ReadMessages          : MC_ReadMessagesFB;  
  /// Send Buffer
  SendData              : RobotLibrarySendDataFB;
  /// Recv Buffer
  RecvData              : RobotLibraryRecvDataFB;
  /// Telegram 
  Telegram              : Telegram; 
  
  /// internal step counter for clear error
 _stepErrorClear        : DINT;
  /// internal timer 
 _timerErrorClear       : TON;
  /// internal timeout 
 _timeoutErrorClear     : TIME := T#1S; 
  /// Rising edge for clear error
 _errorClear_R          : R_TRIG;
  /// internal step counter for command
 _stepCmd               : DINT;
  /// internal timer 
 _timerCmd              : TON;
  /// internal timeout 
 _timeoutCmd            : TIME := T#5S; 
  /// Rising edge for enable
 _enable_R              : R_TRIG;
  /// Falling edge for enable
 _enable_F              : F_TRIG;

  /// Flag that indicated the the connection is alive (data exchange)
 _aliveBit              : BOOL;
  /// last lifesign counter value
 _aliveValue            : BYTE;
  /// timer for detecting alive state
 _aliveCheck            : TON;
  /// rising edge for connection is alive
 _alive_R               : R_TRIG;
  /// falling edge for connection is alive
 _alive_F               : F_TRIG;
   /// last telegram state
 _lastTelegramState     : TelegramState   := TelegramState.UNDEFINED;
   /// last telegram control
 _lastTelegramControl   : ControlHalfByte := ControlHalfByte.NONE;
END_VAR


VAR CONSTANT
  /// Size of the fragment header
  FRAGMENT_HEADER_SIZE : UDINT := SIZEOF(TelegramPlcToRobFragmentHeader);
  /// Size of the comand header
  COMMAND_HEADER_SIZE  : UDINT := SIZEOF(TelegramPlcToRobCommandHeader);
  /// Size of the footer
  FOOTER_SIZE          : UDINT := 1;
  /// Minimal payload size for telegram
  MIN_PAYLOAD_SIZE     : UDINT := 1;
  /// Active command
  ACTIVE_CMD           : UDINT := 1;
  /// Buffered command
  BUFFER_CMD           : UDINT := 2;
  /// Empty command entry
  EMPTY_CMD_ENTRY      : AxesGroupAcyclicAcrEntryCmdBuffer;
  /// bitmask to mask the LifeSign out of the halfbyte
  LIFESIGN_BIT_MASK    : BYTE := 2#000_1111;   
  /// Primary sequence
  PRIMARY_SEQUENCE     : DINT := 0;
  /// Secondary sequence
  SECONDARY_SEQUENCE   : DINT := 1;  
  /// Empty Execution-Order-List entry
  EMPTY_EOL_ENTRY      : DINT := 0;
END_VAR

  HandleAxesGroupAcyclic       ( AxesGroup    := AxesGroup);
  HandleAxesGroupCyclic        ( AxesGroup    := AxesGroup);
  HandleAxesGroupCyclicOptional( AxesGroup    := AxesGroup);
  HandleAxesGroupInternalData  ( AxesGroup    := AxesGroup);
  HandleAxesGroupMessageLog    ( AxesGroup    := AxesGroup);
  HandleAxesGroupParameter     ( AxesGroup    := AxesGroup);
  HandleAxesGroupState         ( AxesGroup    := AxesGroup);
  
  HandleLifeSign               ( AxesGroup    := AxesGroup);
  HandleInvalidFrames          ( AxesGroup    := AxesGroup);
  HandleTelegramStateCtrl();
  HandleAliveBit               (RobotInData[1]);
  HandleSeqAck                 ( AxesGroup    := AxesGroup);
  
  OnCall                       ( AxesGroup    := AxesGroup);
  OnExecRun                    ( AxesGroup    := AxesGroup);
  OnErrorClear                 ( AxesGroup    := AxesGroup);
  
  
  
  AxesGroupToTelegram  ( AxesGroup    := AxesGroup );
  
  CreateSendPayload    ( AxesGroup    := AxesGroup,
                         RobotOutData := RobotOutData );
  
  ParseRecvPayload     ( AxesGroup    := AxesGroup,
                         RobotInData  := RobotInData); 
  
  AxesGroupFromTelegram( AxesGroup    := AxesGroup);
  
  
  // call internal functionblocks
  ExchangeConfiguration 
  (  
    Name      := RobotName, 
    ExecMode  := ExecutionMode.PARALLEL,
    Priority  := PriorityLevel.NORMAL, 
    AxesGroup := AxesGroup, 
  );
  
  ReadRobotData
  (
    Name      := RobotName, 
    ExecMode  := ExecutionMode.PARALLEL,
    Priority  := PriorityLevel.NORMAL, 
    AxesGroup := AxesGroup, 
  );
  
  ReadMessages
  (
    Name      := RobotName, 
    ExecMode  := ExecutionMode.PARALLEL,
    Priority  := PriorityLevel.NORMAL, 
    AxesGroup := AxesGroup, 
  );

END_FUNCTION_BLOCK

METHOD PRIVATE AxesGroupFromTelegram
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR

  AxesGroupFromTelegramCyclic         (AxesGroup := AxesGroup);
  AxesGroupFromTelegramCyclicOptional (AxesGroup := AxesGroup);

END_METHOD

METHOD PRIVATE AxesGroupFromTelegramCyclic
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // ---------------------------------
  // Mapp Telegramm to AxesGroup Data  
  // ---------------------------------
  AxesGroup.Cyclic.RobToPlc.SRCIVersion    := Telegram.RobToPlc.Header.SRCIVersion ;
  AxesGroup.Cyclic.RobToPlc.LifeSign       := Telegram.RobToPlc.Header.LifeSign ;
  AxesGroup.Cyclic.RobToPlc.TelegramState  := Telegram.RobToPlc.Header.TelegramState ;
  AxesGroup.Cyclic.RobToPlc.StatusRobotArm := DwordToRaStatusWord(Telegram.RobToPlc.Header.StatusRobotArm);
  AxesGroup.Cyclic.RobToPlc.Override       := Telegram.RobToPlc.Header.Override ;

END_METHOD

METHOD PRIVATE AxesGroupFromTelegramCyclicOptional
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup: AxesGroup;
END_VAR

  // Sub ProgramData {{{
  AxesGroup.CyclicOptional.RobToPlc.SubProgramData.Data := Telegram.RobToPlc.CyclicOptional.SubProgramData.Data;
  // }}}
  
  
  // Cartesian position {{{
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Active                   :=                                     AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Active;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.X                        :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.X;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Y                        :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.Y;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Z                        :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.Z;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Rx                       :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.Rx;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Ry                       :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.Ry;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Rz                       :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.Rz;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Config.Shoulder          :=              WordToArmConfigShoulder(Telegram.RobToPlc.CyclicOptional.CartesianPosition.Config);
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Config.Elbow             :=              WordToArmConfigElbow   (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Config);
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Config.Wrist             :=              WordToArmConfigWrist   (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Config);
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J1Turns       := BYTE_TO_SINT(GetHalfeByteLo         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J2_J1));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J2Turns       := BYTE_TO_SINT(GetHalfeByteHi         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J2_J1));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J3Turns       := BYTE_TO_SINT(GetHalfeByteLo         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J4_J3));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J4Turns       := BYTE_TO_SINT(GetHalfeByteHi         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J4_J3));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J5Turns       := BYTE_TO_SINT(GetHalfeByteLo         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J6_J5));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.J6Turns       := BYTE_TO_SINT(GetHalfeByteHi         (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J6_J5));
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.TurnNumber.E1Turns       := BYTE_TO_SINT                        (Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_E1);
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.E1                       :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.E1;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.ToolNo  :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.CurrentlyUsedToolNo;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.CoordinateSystem.FrameNo :=                                      Telegram.RobToPlc.CyclicOptional.CartesianPosition.CurrentlyUsedFrameNo;
  // }}}
  
  // Joint position {{{
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.Active := AxesGroup.CyclicOptional.RobToPlc.JointPosition.Active;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J1     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J1;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J2     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J2;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J3     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J3;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J4     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J4;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J5     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J5;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.J6     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.J6;
  AxesGroup.CyclicOptional.RobToPlc.JointPosition.E1     :=  Telegram.RobToPlc.CyclicOptional.JointPosition.E1;
  // }}}
  
  // Force {{{
  AxesGroup.CyclicOptional.RobToPlc.Force.Active          := AxesGroup.CyclicOptional.RobToPlc.Force.Active;
  AxesGroup.CyclicOptional.RobToPlc.Force.X               :=  Telegram.RobToPlc.CyclicOptional.Force.X;
  AxesGroup.CyclicOptional.RobToPlc.Force.Y               :=  Telegram.RobToPlc.CyclicOptional.Force.Y;
  AxesGroup.CyclicOptional.RobToPlc.Force.Z               :=  Telegram.RobToPlc.CyclicOptional.Force.Z;
  AxesGroup.CyclicOptional.RobToPlc.Force.Rx              :=  Telegram.RobToPlc.CyclicOptional.Force.Rx;
  AxesGroup.CyclicOptional.RobToPlc.Force.Ry              :=  Telegram.RobToPlc.CyclicOptional.Force.Ry;
  AxesGroup.CyclicOptional.RobToPlc.Force.Rz              :=  Telegram.RobToPlc.CyclicOptional.Force.Rz;
  // }}}
  
  // Current {{{
  AxesGroup.CyclicOptional.RobToPlc.Current.Active        := AxesGroup.CyclicOptional.RobToPlc.Current.Active;
  AxesGroup.CyclicOptional.RobToPlc.Current.J1            :=  Telegram.RobToPlc.CyclicOptional.Current.J1;
  AxesGroup.CyclicOptional.RobToPlc.Current.J2            :=  Telegram.RobToPlc.CyclicOptional.Current.J2;
  AxesGroup.CyclicOptional.RobToPlc.Current.J3            :=  Telegram.RobToPlc.CyclicOptional.Current.J3;
  AxesGroup.CyclicOptional.RobToPlc.Current.J4            :=  Telegram.RobToPlc.CyclicOptional.Current.J4;
  AxesGroup.CyclicOptional.RobToPlc.Current.J5            :=  Telegram.RobToPlc.CyclicOptional.Current.J5;
  AxesGroup.CyclicOptional.RobToPlc.Current.J6            :=  Telegram.RobToPlc.CyclicOptional.Current.J6;
  // }}}
  
  
  // Two Sequences {{{
  // }}}
  
  // Cartesian Position Extended
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E2     :=  Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E2;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E3     :=  Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E3;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E4     :=  Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E4;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E5     :=  Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E5;
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.E6     :=  Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E6;
  
  // Joint Position Extended
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.Active     := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.Active;
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E2         :=  Telegram.RobToPlc.CyclicOptional.JointPositionExt.E2;
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E3         :=  Telegram.RobToPlc.CyclicOptional.JointPositionExt.E3;
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E4         :=  Telegram.RobToPlc.CyclicOptional.JointPositionExt.E4;
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E5         :=  Telegram.RobToPlc.CyclicOptional.JointPositionExt.E5;
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.E6         :=  Telegram.RobToPlc.CyclicOptional.JointPositionExt.E6;
  
  // Force Extended
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.Active             := AxesGroup.CyclicOptional.RobToPlc.ForceExt.Active;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E1                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E1;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E2                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E2;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E3                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E3;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E4                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E4;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E5                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E5;
  AxesGroup.CyclicOptional.RobToPlc.ForceExt.E6                 :=  Telegram.RobToPlc.CyclicOptional.ForceExt.E6;
  
  // Current Extended
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.Active           := AxesGroup.CyclicOptional.RobToPlc.CurrentExt.Active;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E1               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E1;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E2               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E2;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E3               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E3;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E4               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E4;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E5               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E5;
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt.E6               :=  Telegram.RobToPlc.CyclicOptional.CurrentExt.E6;

END_METHOD

METHOD PRIVATE AxesGroupToTelegram : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

VAR 
  /// internal index
 _idx                       : DINT;
  /// internal sequence index
 _seqIdx                    : DINT;
  /// internal fragment index
 _fragIdx                   : DINT;
  /// internal register index
 _regIdx                    : DINT;
  /// internal execution order list index
 _listIdx                   : DINT := 1;
  /// internal payload pointer
 _payLoadPtr                : DWORD;
  /// internal fragment action
 _fragmentAction            : FragmentAction;
  /// internal fragment action as string
 _fragmentActionString      : STRING;
  /// maximount amount of bytes per sequence
  SEQUENCE_MAX_PAYLOAD_SIZE : UDINT;
END_VAR

  IF ( AxesGroup.InternalData.NewSEQ[0]) {warning 'Handle 2nd sequence'}
  THEN
    // delete old telegram data 
    SysDepMemSet(pDest := ADR(Telegram.PlcToRob), Value := 0 , DataLen := SIZEOF(Telegram.PlcToRob));
  END_IF
    
  AxesGroupToTelegramHeader        (AxesGroup := AxesGroup);
  AxesGroupToTelegramCyclic        (AxesGroup := AxesGroup);
  AxesGroupToTelegramCyclicOptional(AxesGroup := AxesGroup);
  AxesGroupToTelegramSequence      (AxesGroup := AxesGroup);
  AxesGroupToTelegramFooter        (AxesGroup := AxesGroup);
  AxesGroupToTelegramLogging       (AxesGroup := AxesGroup);

END_METHOD

METHOD PRIVATE AxesGroupToTelegramCyclic : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  Telegram.PlcToRob.Cyclic.Tool  := 0; {warning 'ToDo'} 
  Telegram.PlcToRob.Cyclic.Frame := 0; {warning 'ToDo'}

END_METHOD

METHOD PRIVATE AxesGroupToTelegramCyclicOptional : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // AxesGroup.CyclicOptional.PlcToRob.SubProgramData {{{
  IF (AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Active)
  THEN
    Telegram.PlcToRob.CyclicOptional.SubProgramData.Data := AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Data; 
  END_IF
  // }}}
  
  // AxesGroup.CyclicOptional.PlcToRob.CartesianPosition  {{{  
  IF (AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Active)
  THEN
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.X           :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.X;  
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Y           :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Y;  
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Z           :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Z;
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Rx          :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Rx;  
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Ry          :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Ry;  
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Rz          :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Rz;
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J2_J1 := CombineHalfBytes(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J2Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J1Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J4_J3 := CombineHalfBytes(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J4Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J3Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J6_J5 := CombineHalfBytes(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J6Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J5Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_E1    :=                  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.E1Turns;
  END_IF  
  // }}}
    
  // AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt {{{ 
  IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.Active) 
  THEN
    Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E2 := AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.E2;  
    Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E3 := AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.E3;  
    Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E4 := AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.E4;  
    Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E5 := AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.E5;  
    Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E6 := AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.E6;  
  END_IF
  // }}}
  
  // AxesGroup.CyclicOptional.PlcToRob.JointPosition {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPosition.Active) 
  THEN
    Telegram.PlcToRob.CyclicOptional.JointPosition.J1 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J1;
    Telegram.PlcToRob.CyclicOptional.JointPosition.J2 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J2;
    Telegram.PlcToRob.CyclicOptional.JointPosition.J3 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J3;
    Telegram.PlcToRob.CyclicOptional.JointPosition.J4 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J4;
    Telegram.PlcToRob.CyclicOptional.JointPosition.J5 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J5;
    Telegram.PlcToRob.CyclicOptional.JointPosition.J6 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.J6;
    Telegram.PlcToRob.CyclicOptional.JointPosition.E1 := AxesGroup.CyclicOptional.PlcToRob.JointPosition.E1;
  END_IF
  // }}}
  
  // AxesGroup.CyclicOptional.PlcToRob.JointPositionExt {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.Active) 
  THEN
    Telegram.PlcToRob.CyclicOptional.JointPositionExt.E2 := AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.E2;
    Telegram.PlcToRob.CyclicOptional.JointPositionExt.E3 := AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.E3;  
    Telegram.PlcToRob.CyclicOptional.JointPositionExt.E4 := AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.E4;
    Telegram.PlcToRob.CyclicOptional.JointPositionExt.E5 := AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.E5;
    Telegram.PlcToRob.CyclicOptional.JointPositionExt.E6 := AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.E6;        
  END_IF  
  // }}}
       
  // AxesGroup.CyclicOptional.PlcToRob.Force {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.Force.Active) 
  THEN
    Telegram.PlcToRob.CyclicOptional.Force.X  := AxesGroup.CyclicOptional.PlcToRob.Force.X;
    Telegram.PlcToRob.CyclicOptional.Force.Y  := AxesGroup.CyclicOptional.PlcToRob.Force.Y;
    Telegram.PlcToRob.CyclicOptional.Force.Z  := AxesGroup.CyclicOptional.PlcToRob.Force.Z;
    Telegram.PlcToRob.CyclicOptional.Force.Rx := AxesGroup.CyclicOptional.PlcToRob.Force.Rx;
    Telegram.PlcToRob.CyclicOptional.Force.Ry := AxesGroup.CyclicOptional.PlcToRob.Force.Ry;
    Telegram.PlcToRob.CyclicOptional.Force.Rz := AxesGroup.CyclicOptional.PlcToRob.Force.Rz;
  END_IF  
  // }}}
                      
  // AxesGroup.CyclicOptional.PlcToRob.ForceExt {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.ForceExt.Active) 
  THEN
    Telegram.PlcToRob.CyclicOptional.ForceExt.E1 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E1;
    Telegram.PlcToRob.CyclicOptional.ForceExt.E2 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E2;
    Telegram.PlcToRob.CyclicOptional.ForceExt.E3 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E3;
    Telegram.PlcToRob.CyclicOptional.ForceExt.E4 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E4;
    Telegram.PlcToRob.CyclicOptional.ForceExt.E5 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E5;
    Telegram.PlcToRob.CyclicOptional.ForceExt.E6 := AxesGroup.CyclicOptional.PlcToRob.ForceExt.E6;
  END_IF                    
  // }}}

END_METHOD

METHOD PRIVATE AxesGroupToTelegramFooter : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  Telegram.PlcToRob.Footer.LifeSign := GetHalfeByteLo(Telegram.PlcToRob.Header.FastStop_LifeSign);

END_METHOD

METHOD PRIVATE AxesGroupToTelegramHeader : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  Telegram.PlcToRob.Header.SRCIVersion               := VersionToByte(AxesGroup.Cyclic.PlcToRob.SRCIVersion);
  Telegram.PlcToRob.Header.FastStop_LifeSign         := CombineHalfBytes( HalfByteHi := AxesGroup.Cyclic.PlcToRob.FastStop, HalfByteLo := AxesGroup.Cyclic.PlcToRob.LifeSign );
  Telegram.PlcToRob.Header.TelegramLengthPlcToRob    := ParCfg.Com.TelegramLengthPlcToRob;
  Telegram.PlcToRob.Header.TelegramLengthRobToPlc    := ParCfg.Com.TelegramLengthRobToPlc;
  Telegram.PlcToRob.Header.AxesGroupID_Control       := CombineHalfBytes(HalfByteHi := AxesGroup.Cyclic.PlcToRob.AxesGroupID, HalfByteLo := AxesGroup.Cyclic.PlcToRob.Control);
  Telegram.PlcToRob.Header.Reserved                  := 0;
  Telegram.PlcToRob.Header.TelegramNumberPlcToRob    := PlcOptionalCyclicToUint(AxesGroup.Parameter.Plc.OptionalCyclic);
  Telegram.PlcToRob.Header.TelegramNumberRobToPlc    := RobOptionalCyclicToUint(AxesGroup.Parameter.Rob.OptionalCyclic);
  Telegram.PlcToRob.Header.ClientDate                := AxesGroup.Cyclic.PlcToRob.ClientDate;
  Telegram.PlcToRob.Header.ClientTime                := AxesGroup.Cyclic.PlcToRob.ClientTime;

END_METHOD

METHOD PRIVATE AxesGroupToTelegramLogging : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

VAR 
  /// internal sequence index
 _seqIdx                    : DINT;
  /// internal fragment index
 _fragIdx                   : DINT;
END_VAR

  FOR _seqIdx := 0 TO AxesGroup.InternalData.SequenceCountSend
  DO
    // check new data ? 
    IF ( AxesGroup.InternalData.NewSEQ[_seqIdx] )
    THEN
      IF ( Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength > 0 ) 
      THEN
        // Create log entry
        CreateLogMessagePara3 ( Timestamp   := SystemTime,
                                MessageType := MessageType.CMD,
                                Severity    := Severity.DEBUG,
                                MessageCode := 0,
                                MessageText := 'SendData: SEQ = {1}, added Sequence [{2}] with PayloadLength = {3}',
                                Para1       :=  UINT_TO_STRING(Telegram.PlcToRob.Sequence[_seqIdx].Header.SEQ_ACK),
                                Para2       :=  DINT_TO_STRING(_seqIdx),
                                Para3       :=  UINT_TO_STRING(Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength));
      END_IF
      
      FOR _fragIdx := 0 TO AxesGroup.InternalData.FragmentCountSend[_seqIdx]
      DO
        IF ( Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > 0 )
        THEN
          // Create log entry
          CreateLogMessagePara5 ( Timestamp   := SystemTime,
                                  MessageType := MessageType.CMD,
                                  Severity    := Severity.DEBUG,
                                  MessageCode := 0,
                                  MessageText := 'SendData: added Fragment [{1}] with PayloadLength = {2}, CmdID <{3}>, Cmd <{4}> Fragment-Action Bits:{5}' ,
                                  Para1       := DINT_TO_STRING(_fragIdx),
                                  Para2       := UINT_TO_STRING            (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength),
                                  Para3       := UINT_TO_STRING            (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID),
                                  Para4       := CmdTypeToString           (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.CmdType),
                                  Para5       := ByteToFragmentActionString(Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction)); 
        END_IF
      END_FOR
    END_IF
  END_FOR

END_METHOD

METHOD PRIVATE AxesGroupToTelegramSequence : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

VAR 
  /// internal index
 _idx                       : DINT;
  /// internal sequence index
 _seqIdx                    : DINT;
  /// internal fragment index
 _fragIdx                   : DINT;
  /// internal register index
 _regIdx                    : DINT;
  /// internal execution order list index
 _listIdx                   : DINT := 1;
  /// internal payload pointer
 _payLoadPtr                : DWORD;
  /// internal fragment action
 _fragmentAction            : FragmentAction;
  /// internal fragment action as string
 _fragmentActionString      : STRING;
  /// maximount amount of bytes per sequence
  SEQUENCE_MAX_PAYLOAD_SIZE : UDINT;
END_VAR

  // set current SEQ / ACk index
  Telegram.PlcToRob.Sequence[0].Header.SEQ_ACK := AxesGroup.InternalData.CurrentSEQ[0];
  Telegram.PlcToRob.Sequence[1].Header.SEQ_ACK := AxesGroup.InternalData.CurrentSEQ[1];
  
  
  // only update telegram content if a new sequence SEQ is set
  IF ( AxesGroup.InternalData.NewSEQ[0] ) {warning 'Handle 2nd sequence'}
  THEN
    // only reset counters in case of new telegram to send  
    AxesGroup.InternalData.SequenceCountSend := 0;
    AxesGroup.InternalData.FragmentCountSend[_seqIdx] := 0;
  
    IF ( RobotLibraryParameter.TWO_SEQUENCES )
    THEN
      SEQUENCE_MAX_PAYLOAD_SIZE := RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX - FOOTER_SIZE - Telegram.PlcToRob.Header.TelegramLengthPlcToRob  / 2;
    ELSE
      SEQUENCE_MAX_PAYLOAD_SIZE := RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX - FOOTER_SIZE - Telegram.PlcToRob.Header.TelegramLengthPlcToRob  / 1;
    END_IF  
    
    // calc current telegram payload length
    Telegram.PlcToRob.Header.TelegramLengthPlcToRob := CalcTelegramLengthPlcToRob(AxesGroup := AxesGroup);
    
    // Bedingung anpassen und TWO_SEQUENCES berücksichtigen
    WHILE (( RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX - Telegram.PlcToRob.Header.TelegramLengthPlcToRob ) >= FRAGMENT_HEADER_SIZE + MIN_PAYLOAD_SIZE ) 
    DO
      // Check command in Execution-Order-List available ?
      IF ( AxesGroup.Acyclic.ActiveCommandRegister.ExecutionOrderList[_listIdx] > EMPTY_EOL_ENTRY)
      THEN
        // set current SEQ / ACk index
        Telegram.PlcToRob.Sequence[_seqIdx].Header.SEQ_ACK := AxesGroup.InternalData.CurrentSEQ[_seqIdx];
        
        // get active command register index
       _regIdx := AxesGroup.Acyclic.ActiveCommandRegister.ExecutionOrderList[_listIdx];
    
        // check State of the current ACR entry ?
        IF (( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State >= BufferStateCmd.CREATED  ) AND
            ( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State <= BufferStateCmd.SENDING  ))
        THEN
          // add size of fragement header      
          Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength :=
            Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength + SIZEOF(Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header); 
            
            
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID          := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].UniqueID;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.Reserve        := 
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction := 0; // will be set below
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer := DWORD_TO_UINT(AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr); {warning 'ToDo: change data type'}
          
          // The 1st message resets the ARC entry on the server side  
         _fragmentAction.Reset := (( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State      = BufferStateCmd.CREATED ) AND
                                   ( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr = 0                      ));
                                   
          // Update messages must clear the ARC entry on the server side  
         _fragmentAction.Clear := (( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State      = BufferStateCmd.UPDATE_AVAILABLE  ) AND
                                   ( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr = 0                                )); 
    
          
          // fill telegramm header - just for later debugging ( the header is part of the command payload itselfy ) {{{
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.CmdType       := CombineBytesToUint ( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[0],
                                                                                                                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[1]);
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ExecMode.0    :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[2].0;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ExecMode.1    :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[2].1;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ExecMode.2    :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[2].2;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ExecMode.3    :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[2].3;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.Prio.0        :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].0;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.Prio.1        :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].1;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.Prio.2        :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].2;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.Prio.3        :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].3;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ParSequence.0 :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].4;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ParSequence.1 :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].5;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ParSequence.2 :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].6;
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ParSequence.3 :=                      AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[3].7;
          // }}}
          // loop through the payload
          FOR _payLoadPtr := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr TO AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayloadLen -1  
          DO
            // copy payload
            Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[_payLoadPtr] 
              := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].Payload[_payLoadPtr];
        
            // inc current sequence payload length
            Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength
              := Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength + 1;  
        
            // inc current fragment payload length
            Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength 
              := Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength + 1;
        
            // inc payload pointer in active command register
            AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr 
              := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr + 1;
          
            // set command state
            IF ( AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr >= AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadLen) 
            THEN
              AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State := BufferStateCmd.PROCESSED;
            ELSE
              AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].State := BufferStateCmd.SENDING;  
            END_IF 
    
            // calc current telegram payload length
            Telegram.PlcToRob.Header.TelegramLengthPlcToRob := CalcTelegramLengthPlcToRob(AxesGroup := AxesGroup);
      
            // check limit reached ?
            IF ( Telegram.PlcToRob.Header.TelegramLengthPlcToRob >= RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX) 
            THEN  
              EXIT; // -> abort for loop 
            END_IF  
          END_FOR
    
          // check payload complete ?
         _fragmentAction.Complete := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr 
                                     >= AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayloadLen;
    
          // just for brakepoint
          IF (_fragmentAction.Complete)
          THEN
           _fragmentAction.Complete := _fragmentAction.Complete; 
          END_IF
    
          // set fragment action
          Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction := FragmentActionToByte(_fragmentAction);
        END_IF
      END_IF
      
      // inc execution order list index 
     _listIdx := _listIdx + 1;
      // inc fragment index 
     _fragIdx := _fragIdx + 1;
  
      IF (_fragIdx > 1)
      THEN
      _fragIdx := _fragIdx;
      END_IF    
    
      // check abort conditions
      IF (( Telegram.PlcToRob.Header.TelegramLengthPlcToRob                       >= RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ) OR  // Payload limit reached 
          ( _fragIdx                                                              >= RobotLibraryParameter.FRAGMENT_MAX         ) OR  // Max fragment limit reached
          (  AxesGroup.Acyclic.ActiveCommandRegister.ExecutionOrderList[_listIdx]  = EMPTY_EOL_ENTRY                            ))    // No entry in ExecutionOrderList left
      THEN
        EXIT;// -> Abort while loop
      END_IF         
    END_WHILE  
    
    AxesGroup.InternalData.SequenceCountSend          := _seqIdx;
    AxesGroup.InternalData.FragmentCountSend[_seqIdx] := _fragIdx;
    
    {warning 'ToDo: take a loacal var for length and do not overwrite header telegram length'}
    Telegram.PlcToRob.Header.TelegramLengthPlcToRob := ParCfg.Com.TelegramLengthPlcToRob;
    Telegram.PlcToRob.Header.TelegramLengthRobToPlc := ParCfg.Com.TelegramLengthRobToPlc;
  END_IF

END_METHOD

METHOD PRIVATE CalcTelegramLengthPlcToRob : UINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR
  /// length of the optional cyclic data block
 _cyclicOptionalDataLength : UINT;
END_VAR

  // CyclicOptional {{{
  
  // AxesGroup.CyclicOptional.PlcToRob.SubProgramData
  IF (AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Active)
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.SubProgramData);    
  END_IF
  
  // AxesGroup.CyclicOptional.PlcToRob.CartesianPosition  
  IF (AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Active)
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.CartesianPosition);    
  END_IF  
    
  // AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt 
  IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.Active) 
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt);    
  END_IF
  
  // AxesGroup.CyclicOptional.PlcToRob.JointPosition
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPosition.Active) 
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.JointPosition);    
  END_IF
  
  // AxesGroup.CyclicOptional.PlcToRob.JointPositionExt
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.Active) 
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.JointPositionExt);    
  END_IF  
       
  // AxesGroup.CyclicOptional.PlcToRob.Force
  IF ( AxesGroup.CyclicOptional.PlcToRob.Force.Active) 
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.Force);    
  END_IF  
                      
  // AxesGroup.CyclicOptional.PlcToRob.ForceExt
  IF ( AxesGroup.CyclicOptional.PlcToRob.ForceExt.Active) 
  THEN
    // inc cyclic optional data length
   _cyclicOptionalDataLength 
     := _cyclicOptionalDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.ForceExt);    
  END_IF                    
  // }}}
  
  
  IF ( RobotLibraryParameter.TWO_SEQUENCES )
  THEN
    CalcTelegramLengthPlcToRob :=    SIZEOF(Telegram.PlcToRob.Header)
                                   +       _cyclicOptionalDataLength
                                   + SIZEOF(Telegram.PlcToRob.Sequence[  PRIMARY_SEQUENCE].Header)
                                   +       (Telegram.PlcToRob.Sequence[  PRIMARY_SEQUENCE].Header.PayloadLength)
                                   + SIZEOF(Telegram.PlcToRob.Sequence[SECONDARY_SEQUENCE].Header)
                                   +       (Telegram.PlcToRob.Sequence[SECONDARY_SEQUENCE].Header.PayloadLength)
                                   + SIZEOF(Telegram.PlcToRob.Footer);  
  ELSE
    CalcTelegramLengthPlcToRob :=    SIZEOF(Telegram.PlcToRob.Header)
                                   +       _cyclicOptionalDataLength
                                   + SIZEOF(Telegram.PlcToRob.Sequence[PRIMARY_SEQUENCE].Header)
                                   +       (Telegram.PlcToRob.Sequence[PRIMARY_SEQUENCE].Header.PayloadLength)
                                   + SIZEOF(Telegram.PlcToRob.Footer);
  END_IF

END_METHOD

METHOD PRIVATE CreateSendPayload : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup                 : AxesGroup;
  /// Outputs of PLC for communication to RC
  RobotOutData              : ARRAY[0..RobotLibraryParameter.ROBOT_OUT_DATA_MAX] OF BYTE;
END_VAR

VAR 
  /// internal index
 _idx                       : DINT;
  /// temporary byte
 _tmpByte                   : BYTE;
  /// internal sequence index
 _seqIdx                    : DINT;
  /// internal fragment index
 _fragIdx                   : DINT;
END_VAR

  // ------------------------------------
  // Fill SendData
  // ------------------------------------
  // reset all variables and payload
  SendData.Reset();
  
  CreateSendPayloadHeader        ( AxesGroup := AxesGroup );
  CreateSendPayloadCyclic        ( AxesGroup := AxesGroup );
  CreateSendPayloadCyclicOptional( AxesGroup := AxesGroup );
  CreateSendPayloadSequence      ( AxesGroup := AxesGroup );
  CreateSendPayloadFooter        ( AxesGroup := AxesGroup );
  CreateSendPayloadLogging       ( AxesGroup := AxesGroup );
  
  // Copy payload to outputs  
  SysDepMemCpy( pDest := ADR(RobotOutData), pSrc := ADR(SendData.Payload), DataLen := RobotLibraryParameter.ROBOT_OUT_DATA_MAX+1);
  
  
  // reset NewSEQ flag
  AxesGroup.InternalData.NewSEQ[0] := FALSE; {warning 'Test'}

END_METHOD

METHOD PRIVATE CreateSendPayloadCyclic : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  SendData.AddByte(Telegram.PlcToRob.Cyclic.Tool);  
  SendData.AddByte(Telegram.PlcToRob.Cyclic.Frame);

END_METHOD

METHOD PRIVATE CreateSendPayloadCyclicOptional : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

VAR 
  /// temporary byte
 _tmpByte   : BYTE;
END_VAR

  // Telegram.PlcToRob.CyclicOptional.SubProgramData {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Active )
  THEN
    SendData.AddDataBlock( ADR(Telegram.PlcToRob.CyclicOptional.SubProgramData.Data), SIZEOF(Telegram.PlcToRob.CyclicOptional.SubProgramData.Data));  
  END_IF
  // }}}
      
  // Telegram.PlcToRob.CyclicOptional.CartesianPos {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.X );
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.Y );
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.Z );
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.Rx);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.Ry);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPosition.Rz);
  
   _tmpByte   := 0;
   _tmpByte.0 := Telegram.PlcToRob.CyclicOptional.CartesianPosition.Config.0;
   _tmpByte.1 := Telegram.PlcToRob.CyclicOptional.CartesianPosition.Config.1;
   _tmpByte.2 := Telegram.PlcToRob.CyclicOptional.CartesianPosition.Config.2;
   
    SendData.AddByte(_tmpByte);
            
    SendData.AddByte (Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J2_J1             );
    SendData.AddByte (Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J4_J3             );
    SendData.AddByte (Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J6_J5             );
    SendData.AddByte (Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_E1                );
    SendData.AddReal (Telegram.PlcToRob.CyclicOptional.CartesianPosition.E1                      );
  END_IF
  // }}}
  
  // Telegram.PlcToRob.CyclicOptional.JointPosition {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPosition.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J1);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J2);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J3);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J4);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J5);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.J6);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPosition.E1);
  END_IF
  // }}}
  
  // Telegram.PlcToRob.CyclicOptional.Force {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.Force.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.X);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.Y);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.Z);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.Rx);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.Ry);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.Force.Rz);
  END_IF  
  // }}}
  
  // Telegram.PlcToRob.CyclicOptional.TwoSequences {{{
  // }}}
  
  // AxesGroup.OptionalCyclic.PlcToRob.CartesianPosExt {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E2);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E3);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E4);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E5);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt.E6);
  END_IF    
  // }}}
  
  // AxesGroup.OptionalCyclic.PlcToRob.JointPositionExt {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPositionExt.E2);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPositionExt.E3);  
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPositionExt.E4);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPositionExt.E5);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.JointPositionExt.E6);        
  END_IF  
  // }}}
                      
  // Telegram.PlcToRob.CyclicOptional..CartesianForceExt {{{
  IF ( AxesGroup.CyclicOptional.PlcToRob.ForceExt.Active) 
  THEN
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E1);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E2);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E3);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E4);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E5);
    SendData.AddReal(Telegram.PlcToRob.CyclicOptional.ForceExt.E6);
  END_IF                    
  // }}}

END_METHOD

METHOD PRIVATE CreateSendPayloadFooter : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR
  /// index of lifesign in footer
  _lifeSignIdxFooter : DINT;
END_VAR

  {warning 'ToDo: changed but no yet tested'}
  
  IF (( _parCfg.Com.TelegramLengthPlcToRob    >= 1                                          ) AND 
      ( _parCfg.Com.TelegramLengthPlcToRob -1 <= RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ))
  THEN
    // set index of life sign byte
   _lifeSignIdxFooter := _parCfg.Com.TelegramLengthPlcToRob -1;
   
    SendData.Payload[_lifeSignIdxFooter] := AxesGroup.Cyclic.PlcToRob.LifeSign;
  END_IF

END_METHOD

METHOD PRIVATE CreateSendPayloadHeader : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  SendData.AddByte(Telegram.PlcToRob.Header.SRCIVersion           );
  SendData.AddByte(Telegram.PlcToRob.Header.FastStop_LifeSign     ); 
  SendData.AddUint(Telegram.PlcToRob.Header.TelegramLengthPlcToRob);
  SendData.AddUint(Telegram.PlcToRob.Header.TelegramLengthRobToPlc);
  SendData.AddByte(Telegram.PlcToRob.Header.AxesGroupID_Control   );
  SendData.AddByte(Telegram.PlcToRob.Header.Reserved              );
  SendData.AddUint(Telegram.PlcToRob.Header.TelegramNumberPlcToRob);
  SendData.AddUint(Telegram.PlcToRob.Header.TelegramNumberRobToPlc);
  SendData.AddUint(Telegram.PlcToRob.Header.ClientDate            ); 
  SendData.AddTime(Telegram.PlcToRob.Header.ClientTime            );

END_METHOD

METHOD PRIVATE CreateSendPayloadLogging : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup                 : AxesGroup;
END_VAR

  IF  ((( Telegram.PlcToRob.Sequence[0].Header.PayloadLength > 0 ) AND (AxesGroup.InternalData.NewSEQ[0] )) OR
       (( Telegram.PlcToRob.Sequence[1].Header.PayloadLength > 0 ) AND (AxesGroup.InternalData.NewSEQ[1] )))
  THEN
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.DEBUG,
                            MessageCode := 0,
                            MessageText := 'SendData: Bytes send in total: {1}',
                            Para1       :=  UDINT_TO_STRING(SendData.PayloadLen));
  END_IF

END_METHOD

METHOD PRIVATE CreateSendPayloadSequence : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup                 : AxesGroup;
END_VAR

VAR 
  /// internal sequence index
 _seqIdx                    : DINT;
  /// internal fragment index
 _fragIdx                   : DINT;
END_VAR

  //WHILE(SendData.PayloadPtr + FOOTER_SIZE < Telegram.PlcToRob.Header.TelegramLengthPlcToRob )
  //DO         
    FOR _seqIdx := 0 TO AxesGroup.InternalData.SequenceCountSend
    DO
      // Telegram.PlcToRob.Sequence[x].Header {{{
      SendData.AddUint(Telegram.PlcToRob.Sequence[_seqIdx].Header.SEQ_ACK);
      SendData.AddUint(Telegram.PlcToRob.Sequence[_seqIdx].Header.PayloadLength);
      // }}}
    
      // check limit reachted ?
      IF ( SendData.PayloadPtr + FOOTER_SIZE = Telegram.PlcToRob.Header.TelegramLengthPlcToRob)
      THEN
        EXIT;
      END_IF
      
      // PlcToRob.Sequence[x].Fragment[x] {{{
      FOR _fragIdx := 0 TO AxesGroup.InternalData.FragmentCountSend[_seqIdx]  
      DO
   
        IF (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > 0)
        THEN  
          // PlcToRob.Sequence[x].Fragment[x].Header {{{        
          SendData.AddUint                     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID);
          SendData.AddByte                     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.Reserve);
          SendData.AddByte                     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction);
          SendData.AddUint                     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer);
          SendData.AddUint                     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength);
          // }}}
          
          // PlcToRob.Sequence[x].Fragment[x].Command {{{
          
          // Hint: the command header is part of the fragment payload  
          IF (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > 0)
          THEN
            SendData.AddDataBlock( pValue :=  ADR(Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload           ) + Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer,
                                     Size :=     (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength      ) - Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer);
          END_IF
        END_IF
        // }}}
      END_FOR
      // }}}
    END_FOR  
  
  //END_WHILE

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // if TRUE, the retain variables are initialized (warm start / cold start)
  bInCopyCode : BOOL;  // if TRUE, the instance afterwards gets moved into the copy code (online change)
END_VAR

  MyType := 'MC_RobotTaskFB';
  
  // if no AxesGroupID is set, then take the current instance counter value ( -> unique value for each instance )
  IF (AxesGroupID = 0)
  THEN
    AxesGroupID := RobotLibraryDefines.AxesGroupInstances;
  END_IF
  
  // inc global instance counter
  RobotLibraryDefines.AxesGroupInstances 
    := RobotLibraryDefines.AxesGroupInstances + 1;
    
  
  
  // Create log entry
  CreateLogMessage ( Timestamp   := SystemTime,
                     MessageType := MessageType.CMD,
                     Severity    := Severity.DEBUG,
                     MessageCode := 0,
                     MessageText := 'PLC started / restarted');

END_METHOD

METHOD PRIVATE HandleAliveBit
VAR_INPUT
  LifeSign : BYTE;
END_VAR

VAR_INST
  /// flag that indicates that the 1st cyclce is running
  First : BOOL := TRUE;
END_VAR

  IF (First AND LifeSign > 0)
  THEN
    // init alive value
   _aliveValue := LifeSign;
    // reset first flag
    First := FALSE;
  END_IF
  
  
  _aliveCheck ( IN  := (_aliveValue = LifeSign) , PT := ParCfg.Com.LifeSignTimeOut + ParCfg.Plc.CycleTime);
  _alive_R    ( CLK := _aliveBit);
  _alive_F    ( CLK := _aliveBit);
  
  IF ( _aliveValue <> LifeSign)
  THEN
   _aliveValue := LifeSign;
   _aliveBit   := TRUE;
  END_IF
  
  IF (_aliveCheck.Q)
  THEN
   _aliveBit := FALSE;
  END_IF
  
  IF (_alive_R.Q)
  THEN
    // Create log entry
    CreateLogMessage ( Timestamp   := SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.INFO,
                       MessageCode := 0,
                       MessageText := 'Data Exchange is running (Alive-Bit)');
  END_IF
  
  IF (_alive_F.Q)
  THEN
    // Create log entry
    CreateLogMessage ( Timestamp   := SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.INFO,
                       MessageCode := 0,
                       MessageText := 'Data Exchange has stopped (Alive-Bit)');
  END_IF

END_METHOD

METHOD PRIVATE HandleAxesGroupAcyclic
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // Call active command register FB
  AxesGroup.Acyclic.ActiveCommandRegister(SystemTime := SystemTime, ExternalLogger := AxesGroup.MessageLog.ExternalLogger, LogLevel := AxesGroup.MessageLog.LogLevel);

END_METHOD

METHOD PRIVATE HandleAxesGroupCyclic
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // set instance AxesGroupID
  AxesGroup.Cyclic.PlcToRob.AxesGroupID := AxesGroupID;
  // Set Version
  AxesGroup.Cyclic.PlcToRob.SRCIVersion := RobotLibraryConstants.SRCIVersion;
  // Set Date + Time
  AxesGroup.Cyclic.PlcToRob.ClientDate  := DATE_TO_IEC_DATE(SystemTime.SystemDate);
  AxesGroup.Cyclic.PlcToRob.ClientTime  := TIME_TO_IEC_TIME(SystemTime.SystemTime);

END_METHOD

METHOD PRIVATE HandleAxesGroupCyclicOptional
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // PlcToRob {{{
  AxesGroup.CyclicOptional.PlcToRob.SubProgramData      .Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseCallSubprogram; 
  AxesGroup.CyclicOptional.PlcToRob.CartesianPosition   .Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseCartesianPosition; 
  AxesGroup.CyclicOptional.PlcToRob.JointPosition       .Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseJointPosition; 
  AxesGroup.CyclicOptional.PlcToRob.Force               .Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseForce; 
  AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseCartesianPositionExt; 
  AxesGroup.CyclicOptional.PlcToRob.JointPositionExt    .Active := AxesGroup.Parameter.Plc.OptionalCyclic.UseJointPositionExt; 
  // }}}
  
  // RobToPlc {{{
  AxesGroup.CyclicOptional.RobToPlc.SubProgramData      .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseCallSubprogram; 
  AxesGroup.CyclicOptional.RobToPlc.CartesianPosition   .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPosition;    
  AxesGroup.CyclicOptional.RobToPlc.JointPosition       .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPosition;    
  AxesGroup.CyclicOptional.RobToPlc.Force               .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseForce;
  AxesGroup.CyclicOptional.RobToPlc.Current             .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseCurrent;    
  AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPositionExt;    
  AxesGroup.CyclicOptional.RobToPlc.JointPositionExt    .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPositionExt;    
  AxesGroup.CyclicOptional.RobToPlc.ForceExt            .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseForceExt;    
  AxesGroup.CyclicOptional.RobToPlc.CurrentExt          .Active := AxesGroup.Parameter.Rob.OptionalCyclic.UseCurrentExt;    
  // }}}

END_METHOD

METHOD PRIVATE HandleAxesGroupInternalData
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // Update internal data
  AxesGroup.InternalData.SystemTime   := SystemTime;
  AxesGroup.InternalData.OnlineChange := OnlineChange;
  
  // Create rising and falling edges for Online Change
  AxesGroup.InternalData.OnlineChange_R(CLK := OnlineChange);
  AxesGroup.InternalData.OnlineChange_F(CLK := OnlineChange);
  
  // Create rising and falling edges for GroupReset
  AxesGroup.InternalData.GroupReset_R(CLK := AxesGroup.InternalData.GroupReset);
  AxesGroup.InternalData.GroupReset_F(CLK := AxesGroup.InternalData.GroupReset);

END_METHOD

METHOD PRIVATE HandleAxesGroupMessageLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup  : AxesGroup;
END_VAR

  // Set External logger 
  AxesGroup.MessageLog.ExternalLogger := ExternalLogger;
  AxesGroup.MessageLog.LogLevel       := LogLevel;
  
  
  IF (AxesGroup.InternalData.GroupReset_R.Q)
  THEN
    AxesGroup.MessageLog.DeleteMessages();
    AxesGroup.MessageLog.DeleteSystemLogs();
  END_IF

END_METHOD

METHOD PRIVATE HandleAxesGroupParameter
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  AxesGroup.Parameter.Plc.Parameter                           := ParCfg.Plc.Parameter;      
  AxesGroup.Parameter.Plc.OptionalCyclic                      := ParCfg.Plc.OptionalCyclic; {warning 'ToDo: '}
  
  AxesGroup.Parameter.Rob.OptionalCyclic                      := ParCfg.Rob.OptionalCyclic; {warning 'ToDo'}
  AxesGroup.Parameter.Rob.Parameter.LengthACR                 := ExchangeConfiguration.OutCmd.LengthACR;
  AxesGroup.Parameter.Rob.Parameter.HighestToolIndex          := ExchangeConfiguration.OutCmd.HighestToolIndex;
  AxesGroup.Parameter.Rob.Parameter.HighestFrameIndex         := ExchangeConfiguration.OutCmd.HighestFrameIndex;
  AxesGroup.Parameter.Rob.Parameter.HighestLoadIndex          := ExchangeConfiguration.OutCmd.HighestLoadIndex;
  AxesGroup.Parameter.Rob.Parameter.HighestWorkAreaIndex      := ExchangeConfiguration.OutCmd.HighestWorkAreaIndex;
  AxesGroup.Parameter.Rob.Parameter.DataInSync                := ExchangeConfiguration.OutCmd.DataInSync;
  AxesGroup.Parameter.Rob.Parameter.ChangeIndexTool           := ExchangeConfiguration.OutCmd.ChangeIndexTool;
  AxesGroup.Parameter.Rob.Parameter.ChangeIndexFrame          := ExchangeConfiguration.OutCmd.ChangeIndexFrame;
  AxesGroup.Parameter.Rob.Parameter.ChangeIndexLoad           := ExchangeConfiguration.OutCmd.ChangeIndexLoad;
  AxesGroup.Parameter.Rob.Parameter.ChangeIndexWorkArea       := ExchangeConfiguration.OutCmd.ChangeIndexWorkArea;
  AxesGroup.Parameter.Rob.Parameter.RAWorkingHours            := ExchangeConfiguration.OutCmd.RAWorkingHours;
  AxesGroup.Parameter.Rob.Parameter.BrakeTestRequired         := ExchangeConfiguration.OutCmd.BrakeTestRequired;
  AxesGroup.Parameter.Rob.Parameter.StepModeExactStopActive   := ExchangeConfiguration.OutCmd.StepModeExactStopActive;
  AxesGroup.Parameter.Rob.Parameter.StepModeBlendingActive    := ExchangeConfiguration.OutCmd.StepModeBlendingActive;
  AxesGroup.Parameter.Rob.Parameter.PathAccuracyMode          := ExchangeConfiguration.OutCmd.PathAccuracyMode;
  AxesGroup.Parameter.Rob.Parameter.AvoidSingularity          := ExchangeConfiguration.OutCmd.AvoidSingularity;
  AxesGroup.Parameter.Rob.Parameter.CollisionDetectionEnabled := ExchangeConfiguration.OutCmd.CollisionDetectionEnabled;
  AxesGroup.Parameter.Rob.Parameter.AcceleratingSupported     := ExchangeConfiguration.OutCmd.AcceleratingSupported;
  AxesGroup.Parameter.Rob.Parameter.DecceleratingSupported    := ExchangeConfiguration.OutCmd.DecceleratingSupported;
  AxesGroup.Parameter.Rob.Parameter.ConstantVelocitySupported := ExchangeConfiguration.OutCmd.ConstantVelocitySupported;
  AxesGroup.Parameter.Rob.Parameter.RCWorkingHours            := ExchangeConfiguration.OutCmd.RCWorkingHours;

END_METHOD

METHOD PRIVATE HandleAxesGroupState
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  AxesGroup.State.AliveOk     := _aliveBit;
  AxesGroup.State.Initialized := Initialized AND AxesGroup.State.AliveOk;
  
  
  
  AxesGroup.State.Synchronized := (( AxesGroup.State.AliveOk                                         ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.DefaultDynamicsInSync   ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.ToolsInSync             ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.FramesInSync            ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.LoadsInSync             ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.WorkAreasInSync         ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.SoftwareLimitsInSync    ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.DefaultDynamicsInSync   ) AND
                                   ( ExchangeConfiguration.OutCmd.DataInSync.ReferenceDynamicsInSync ));
    
  
  AxesGroup.State.ConfigExchanged                := ExchangeConfiguration.ParameterAccepted;
  
  AxesGroup.State.RobotData.RCManufacturer       := ReadRobotData.OutCmd.RCManufacturer;
  AxesGroup.State.RobotData.RCOrderID            := ReadRobotData.OutCmd.RCOrderID;
  AxesGroup.State.RobotData.RCSerialNumber       := ReadRobotData.OutCmd.RCSerialNumber;
  AxesGroup.State.RobotData.RASerialNumber       := ReadRobotData.OutCmd.RASerialNumber;
  AxesGroup.State.RobotData.RCFirmwareVersion    := ReadRobotData.OutCmd.RCFirmwareVersion;
  AxesGroup.State.RobotData.RCInterpreterVersion := ReadRobotData.OutCmd.RCInterpreterVersion;
  AxesGroup.State.RobotData.AxisJointUsed        := ReadRobotData.OutCmd.AxisJointUsed;
  AxesGroup.State.RobotData.AxisExternalUsed     := ReadRobotData.OutCmd.AxisExternalUsed;
  AxesGroup.State.RobotData.AxisJointUnit        := ReadRobotData.OutCmd.AxisJointUnit;
  AxesGroup.State.RobotData.AxisExternalUnit     := ReadRobotData.OutCmd.AxisExternalUnit;
  AxesGroup.State.RobotData.RCSupportedFunctions := ReadRobotData.OutCmd.RCSupportedFunctions;
  AxesGroup.State.RobotData.RobotID              := ReadRobotData.OutCmd.RobotID;  
  AxesGroup.State.RobotData.InterpreterCycleTime := ReadRobotData.OutCmd.InterpreterCycleTime;

END_METHOD

METHOD PRIVATE HandleInvalidFrames
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR 
VAR
  /// index of lifesign in header
  _lifeSignIdxHeader : DINT;
  /// index of lifesign in footer
  _lifeSignIdxFooter : DINT;
END_VAR
VAR_INST
  /// Timeout for invalid frames counter check
 _invalidFrameCounterCheck_D : TON;
  /// last count of invalid frames
 _lastInvalidFrames          : UDINT;
END_VAR

  IF (( _parCfg.Com.TelegramLengthRobToPlc     < 1                                       ) AND 
      ( _parCfg.Com.TelegramLengthRobToPlc - 1 > RobotLibraryParameter.ROBOT_IN_DATA_MAX ))
  THEN
    // no valid telegram length settings 
    RETURN;
  END_IF
  
  
  //RETURN; {warning 'ToDo: Remove this line to enable function again'}
  
  
  // set index of last byte
  _lifeSignIdxHeader := 1;
  _lifeSignIdxFooter := _parCfg.Com.TelegramLengthRobToPlc -1;
  
  // Timer for invalid frame(s) message
  _invalidFrameCounterCheck_D( IN := TRUE , PT := RobotLibraryParameter.INVALID_FRAMES_CHECK_TIMEOUT);
  
  // Check Frame is valid : 
  // ----------------------
  IF ( GetHalfeByteHi( RobotInData[_lifeSignIdxHeader]) <> GetHalfeByteHi(RobotInData[_lifeSignIdxFooter]))
  THEN
    InvalidFrames := InvalidFrames + 1;
  END_IF
  
  // Check timeout for invalid frame message
  IF ( _invalidFrameCounterCheck_D.Q )
  THEN
    // reset timer
   _invalidFrameCounterCheck_D( IN := FALSE);
    
    // compare invalid frame(s) counter
    IF ( InvalidFrames <> _lastInvalidFrames)
    THEN
      // store last invalid frame(s) counter value
     _lastInvalidFrames := InvalidFrames;
      // Create log entry
      CreateLogMessagePara1 ( Timestamp   := SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.INFO,
                              MessageCode := 0,
                              MessageText := 'Detected invalid frames {1} in total',
                              Para1       :=  UDINT_TO_STRING(InvalidFrames));
    END_IF
  END_IF
  
  
  // Reset invalid frames counter with rising edge of group reset
  IF ( AxesGroup.InternalData.GroupReset_R.Q)
  THEN
        InvalidFrames := 0;
   _lastInvalidFrames := 0;
   
    // Create log entry
    CreateLogMessage ( Timestamp   := SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.INFO,
                       MessageCode := 0,
                       MessageText := 'Reset invalid frames counter by executing GroupReset');
  END_IF

END_METHOD

METHOD PRIVATE HandleLifeSign
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR 

VAR_INST
  /// internal toggle bit
 _toggle                     : BOOL;
  /// Toggle for life sign
 _lifeSignToggle_R           : TON;
  /// Toggle for life sign
 _lifeSignToggle_F           : TON;
  /// last robot life sign
 _lastRobotlifeSign          : BYTE;
END_VAR

  // call timers for toggle
  (*
  _lifeSignToggle_R(IN :=     _toggle, PT := ParCfg.Com.LifeSignTimeOut - ParCfg.Plc.CycleTime);
  _lifeSignToggle_F(IN := NOT _toggle, PT := ParCfg.Com.LifeSignTimeOut - ParCfg.Plc.CycleTime);
  _lifeSignToggle_R(IN :=     _toggle, PT := ParCfg.Plc.CycleTime * ParCfg.Plc.RefreshCyclesOutput);
  _lifeSignToggle_F(IN := NOT _toggle, PT := ParCfg.Plc.CycleTime * ParCfg.Plc.RefreshCyclesOutput);
  *)
  
  _lifeSignToggle_R(IN :=     _toggle, PT := T#40MS); {warning 'ToDo'}
  _lifeSignToggle_F(IN := NOT _toggle, PT := T#40MS); {warning 'ToDo'}
  
  
  
  // increment LifeSign counter
  IF ( _lifeSignToggle_R.Q) OR ( _lifeSignToggle_F.Q) OR ( NOT STAUBLI_SIMULATOR)
  THEN
   _toggle := NOT _toggle;
   
    AxesGroup.Cyclic.PlcToRob.LifeSign := AxesGroup.Cyclic.PlcToRob.LifeSign + 1;
  
    IF ( AxesGroup.Cyclic.PlcToRob.LifeSign > 15 )
    THEN
      AxesGroup.Cyclic.PlcToRob.LifeSign := 0;
    END_IF
  END_IF
  
  
  // check Robot life sign 
  IF ( RobotInData[1] <> _lastRobotlifeSign)
  THEN
   _lastRobotlifeSign := RobotInData[1];
  END_IF

END_METHOD

METHOD PRIVATE HandleSeqAck
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR 
VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  FOR _idx := 0 TO  AxesGroup.InternalData.SequenceCountSend 
  DO
    AxesGroup.InternalData.CurrentAck[_idx] := Telegram.RobToPlc.Sequence[_idx].Header.SEQ_ACK;
  
    // Check Seq/Ack : 
    // ----------------------
    IF ( AxesGroup.InternalData.CurrentAck[_idx] = AxesGroup.InternalData.CurrentSEQ[_idx] )
    THEN
      AxesGroup.InternalData.CurrentSEQ[_idx] := MAX(AxesGroup.InternalData.CurrentSEQ[0],AxesGroup.InternalData.CurrentSEQ[1]) +1;
      
      AxesGroup.InternalData.NewSEQ[_idx] := TRUE;
    END_IF  
  END_FOR

END_METHOD

METHOD PRIVATE HandleTelegramStateCtrl
VAR_INPUT
END_VAR

  IF ( _errorClear_R.Q )
  THEN
    // Create log entry
    CreateLogMessage ( Timestamp   := SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.INFO,
                       MessageCode := 0,
                       MessageText := 'RobotTask: rising edge of ErrorClear flag');
  END_IF
  
  // Telegram Control
  // ----------------
  IF ( _lastTelegramControl <> GetHalfeByteLo(Telegram.PlcToRob.Header.AxesGroupID_Control))
  THEN
    // Create log entry
    CreateLogMessagePara2 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.INFO,
                            MessageCode := 0,
                            MessageText := 'SRCI Interface control changed from {1} to {2}',
                            Para1       := TelegramControlToString(_lastTelegramControl),
                            Para2       := TelegramControlToString(GetHalfeByteLo(Telegram.PlcToRob.Header.AxesGroupID_Control)));
  
    _lastTelegramControl := GetHalfeByteLo(Telegram.PlcToRob.Header.AxesGroupID_Control);
  END_IF
  
  
  // Telegram State
  // ----------------
  IF ( _lastTelegramState <> Telegram.RobToPlc.Header.TelegramState)
  THEN
    // Create log entry
    CreateLogMessagePara2 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.INFO,
                            MessageCode := 0,
                            MessageText := 'SRCI Interface state changed from {1} to {2}',
                            Para1       := TelegramStateToString(_lastTelegramState),
                            Para2       := TelegramStateToString(Telegram.RobToPlc.Header.TelegramState));
  
    _lastTelegramState := Telegram.RobToPlc.Header.TelegramState;
  END_IF

END_METHOD

METHOD PRIVATE OnCall
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  // map numeric value to enum, so that the corresponding message text is directly shown by the tooltip
  ErrorIdEnum   := ErrorId;
  WarningIdEnum := WarningId;
  InfoIdEnum    := InfoId;
  
  Error := ErrorID <> RobotLibraryConstants.OK ;
  
  // Check Payload and In/Out data size
  IF (( RobotLibraryParameter.ROBOT_IN_DATA_MAX     <> RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ) OR
      ( RobotLibraryParameter.ROBOT_OUT_DATA_MAX    <> RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ) OR
      ( RobotLibraryParameter.PARAMETER_PAYLOAD_MAX >= RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ))
  THEN
    ErrorID := RobotLibraryEvents.ERR_INVALID_LIBRARY_PARA;
    RETURN;
  END_IF
  
  // Check AxesGroupID valid
  IF (( AxesGroupID < RobotLibraryConstants.AXES_GROUP_ID_MIN ) OR
      ( AxesGroupID > RobotLibraryConstants.AXES_GROUP_ID_MAX ))
  THEN
    ErrorID := RobotLibraryEvents.ERR_INVALID_AXES_GROUP_ID;
    RETURN;
  END_IF
  
  // Check AxesGroupID instances
  IF ( RobotLibraryDefines.AxesGroupInstances > RobotLibraryConstants.AXES_GROUP_ID_MAX)
  THEN
    ErrorID := RobotLibraryEvents.ERR_INVALID_AXES_GROUP_COUNT;
    RETURN;
  END_IF
  
  
  // Set flag for initialization
  Initialized := ( AxesGroup.Cyclic.RobToPlc.TelegramState = TelegramState.INITIALIZED);
  
  
  SystemLog  := AxesGroup.MessageLog.SystemLogs;
  MessageLog := AxesGroup.MessageLog.Messages;

END_METHOD

METHOD OnErrorClear : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup;
END_VAR

  // building rising edge
  _errorClear_R(CLK := ErrorClear);
  
  OnErrorClear := RobotLibraryConstants.RUNNING;
  
  
  CASE _stepErrorClear OF
    
    00:  IF ( _errorClear_R.Q ) 
         THEN
           // reset the rising edge
          _errorClear_R();       
           // set busy flag
           Busy := TRUE;
                   
           IF (( AxesGroup.Cyclic.RobToPlc.TelegramState >= TelegramState.ERROR_161  ) AND
               ( AxesGroup.Cyclic.RobToPlc.TelegramState <= TelegramState.ERROR_172  )) 
           THEN
             // clear error
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.ACK_ERROR;        
             // set timeout
             SetTimeout(PT := _timeoutErrorClear, rTimer := _timerErrorClear);
             // inc step counter
            _stepErrorClear := _stepErrorClear + 1;
           ELSE 
             // reset busy flag
             Busy := FALSE;
             // reset step counter
            _stepErrorClear := 0;
             // Finished OK 
             OnErrorClear := RobotLibraryConstants.OK;
           END_IF
         END_IF
       
    01:  IF ( AxesGroup.Cyclic.RobToPlc.TelegramState = TelegramState.READY_TO_RESUME ) 
         THEN
           // Request resume
           AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.RESUME;
           // set timeout
           SetTimeout(PT := _timeoutErrorClear, rTimer := _timerErrorClear);
           // inc step counter
          _stepErrorClear := _stepErrorClear + 1; 
         ELSE
           // timeout exceeded ? 
           IF (( CheckTimeout(_timerErrorClear)           = RobotLibraryConstants.OK ) AND
               ( AxesGroup.Cyclic.RobToPlc.TelegramState >= TelegramState.ERROR_161  ) AND
               ( AxesGroup.Cyclic.RobToPlc.TelegramState <= TelegramState.ERROR_172  )) 
           THEN
            // TelegrammState in error          
            ErrorID := AxesGroup.Cyclic.RobToPlc.TelegramState;
            ErrorAddTxt := CONCAT('_stepErrorClear = ' , DINT_TO_STRING(_stepErrorClear));
           END_IF
         END_IF
  
  
    02: IF (AxesGroup.Cyclic.RobToPlc.TelegramState = TelegramState.INITIALIZED)
        THEN
          // Request resume
          AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.NONE;
          // reset busy flag
          Busy := FALSE;
          // reset step counter
         _stepErrorClear := 0;
          // Finished OK 
          OnErrorClear := RobotLibraryConstants.OK;
        ELSE
          // timeout exceeded ? 
          IF (CheckTimeout(_timerErrorClear) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepErrorClear = ' , DINT_TO_STRING(_stepErrorClear));
          END_IF
        END_IF    
  
  ELSE
    // invalid step
    ErrorID     := RobotLibraryEvents.ERR_INVALID_STEP;
    ErrorAddTxt := CONCAT('_stepErrorClear = ' , DINT_TO_STRING(_stepErrorClear));
  END_CASE
  
  
  // Reset FB
  IF ( OnErrorClear <> RobotLibraryConstants.RUNNING)
  THEN
   _stepErrorClear := 0;
    Busy           := FALSE;
    Error          := FALSE;
    ErrorID        := 0;
    ErrorAddTxt    := '';
    WarningID      := 0;
    InfoID         := 0;  
  END_IF

END_METHOD

METHOD OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup;
END_VAR

  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  OnExecRun := RobotLibraryConstants.RUNNING;
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q )
         THEN
           IF ( _enable_R.Q )
           THEN
             // Create log entry
             CreateLogMessage ( Timestamp   := SystemTime,
                                MessageType := MessageType.CMD,
                                Severity    := Severity.INFO,
                                MessageCode := 0,
                                MessageText := 'Robot Task Enabled');
           END_IF
         
           // reset the rising edge
          _enable_R();       
           // reset the falling edge
          _enable_F();
           // set busy flag
           Busy := TRUE;
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // inc step counter
          _stepCmd := _stepCmd + 1; 
         END_IF
         
         // take configuration parameter if not yet enabled
        _parCfg := ParCfg;
  
       
    01:  CASE AxesGroup.Cyclic.RobToPlc.TelegramState  OF
  
           TelegramState.UNDEFINED : ;
           
           TelegramState.ERROR_161..TelegramState.ERROR_172:
  
             // clear error
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.ACK_ERROR;        
  
           TelegramState.READY_TO_RESUME : ; 
             // clear error
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.RESUME;        
           
           TelegramState.READY_FOR_INITIALIZATION: 
  
             // Request initialization
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.INITIALIZE;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
  
           TelegramState.INITIALIZED: 
  
           // inc step counter
          _stepCmd := _stepCmd + 1; 
  
         ELSE
           // TelegrammState in error          
           ErrorID := AxesGroup.Cyclic.RobToPlc.TelegramState;
           ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
         END_CASE
  
  
    02: IF (AxesGroup.Cyclic.RobToPlc.TelegramState = TelegramState.INITIALIZED)
        THEN
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1; 
        ELSE
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF    
  
  
    03: IF (( NOT ExchangeConfiguration.Busy  ) AND 
            ( NOT ExchangeConfiguration.Error ))
        THEN
          ExchangeConfiguration.ParCmd.LogLevel                   := LogLevel; 
          ExchangeConfiguration.ParCmd.WaitAtBlendingZone         := _parCfg.Rob.Parameter.WaitAtBlendingZone;
          ExchangeConfiguration.ParCmd.AllowSecSeqWhileSubprogram := _parCfg.Rob.Parameter.AllowSecSeqWhileSubprogram;
          ExchangeConfiguration.ParCmd.AllowDynamicBlending       := _parCfg.Rob.Parameter.AllowDynamicBlending;
          ExchangeConfiguration.ParCmd.DelayTime                  := _parCfg.Rob.Parameter.DelayTime;
          ExchangeConfiguration.ParCmd.WaitForNrOfCmd             := _parCfg.Rob.Parameter.WaitForNrOfCmd;
          ExchangeConfiguration.ParCmd.LifeSignTimeOut            := TIME_TO_UINT(_parCfg.Com.LifeSignTimeOut);
          ExchangeConfiguration.ParCmd.SyncDelay                  := _parCfg.Rob.Parameter.SyncDelay;
          ExchangeConfiguration.ParCmd.SyncReaction               := _parCfg.Rob.Parameter.SyncReaction;
          {warning 'ToDo: ExchangeConfiguration.ParCmd.DataInSync'}
        //ExchangeConfiguration.ParCmd.DataInSync                 := _parCfg.Rob.Parameter.DataInSync;
          ExchangeConfiguration.ParCmd.DataEnableSync             := _parCfg.Rob.Parameter.DataEnableSync;
         
          // start function block
          ExchangeConfiguration.Enable                            := TRUE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ExchangeConfiguration.Error)
          THEN
            ErrorID     := ExchangeConfiguration.ErrorID;
            ErrorAddTxt := ExchangeConfiguration.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    04: IF ( ExchangeConfiguration.Busy )
        THEN
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ExchangeConfiguration.Error)
          THEN
            ErrorID     := ExchangeConfiguration.ErrorID;
            ErrorAddTxt := ExchangeConfiguration.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    
    05: IF (( NOT ExchangeConfiguration.Busy              ) AND
            (     ExchangeConfiguration.ParameterAccepted ))
        THEN
          // stop execution       
          ExchangeConfiguration.Enable := FALSE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
         ELSE
           // check error ? 
           IF (ExchangeConfiguration.Error)
           THEN
             ErrorID     := ExchangeConfiguration.ErrorID;
             ErrorAddTxt := ExchangeConfiguration.ErrorAddTxt;;
           END_IF  
         
           // timeout exceeded ? 
           IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
           THEN
             ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
             ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
           END_IF
         END_IF
  
         
    06: IF (( NOT ReadRobotData.Busy  ) AND 
            ( NOT ReadRobotData.Error )) 
        THEN
          // start function block
          ReadRobotData.Execute := TRUE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ReadRobotData.Error)
          THEN
            ErrorID     := ReadRobotData.ErrorID;
            ErrorAddTxt := ReadRobotData.ErrorAddTxt;;
          END_IF  
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    07: IF ( ReadRobotData.Busy ) 
        THEN
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ReadRobotData.Error)
          THEN
            ErrorID     := ReadRobotData.ErrorID;
            ErrorAddTxt := ReadRobotData.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    
    08: IF (( NOT ReadRobotData.Busy  ) AND
            (     ReadRobotData.Done  ))
        THEN       
          // start function block
          ReadRobotData.Execute := FALSE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;
         ELSE
           // check error ? 
           IF (ReadRobotData.Error)
           THEN
             ErrorID     := ReadRobotData.ErrorID;
             ErrorAddTxt := ReadRobotData.ErrorAddTxt;;
           END_IF  
         
           // timeout exceeded ? 
           IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
           THEN
             ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
             ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
           END_IF
         END_IF
  
  
    09: IF (( NOT ReadMessages.Busy  ) AND 
            ( NOT ReadMessages.Error )) 
        THEN
          // start function block
          ReadMessages.Enable := TRUE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ReadMessages.Error)
          THEN
            ErrorID     := ReadMessages.ErrorID;
            ErrorAddTxt := ReadMessages.ErrorAddTxt;;
          END_IF  
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    10: IF ( ReadMessages.Busy )
        THEN
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (ReadMessages.Error)
          THEN
            ErrorID     := ReadMessages.ErrorID;
            ErrorAddTxt := ReadMessages.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    
    11: IF ((     ReadMessages.Enabled ) AND
            ( NOT ReadMessages.Error   ))
        THEN       
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;
        ELSE
           // check error ? 
           IF (ReadRobotData.Error)
           THEN
             ErrorID     := ReadMessages.ErrorID;
             ErrorAddTxt := ReadMessages.ErrorAddTxt;;
           END_IF  
         
           // timeout exceeded ? 
           IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
           THEN
             ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
             ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
           END_IF
         END_IF
  
    12:  // Reset busy flag
         Busy := FALSE;
         
         // Wait for task disable
         IF ( NOT Enable)
         THEN
           // reset start of function blocks
           ReadMessages.Enable := FALSE;
           ReadRobotData.Execute := FALSE;
           ExchangeConfiguration.Enable := FALSE;
           // Reset step counter
          _stepCmd := 0;         
           // finished okay
           OnExecRun := RobotLibraryConstants.OK;
         END_IF  
  
         
  ELSE
    // invalid step
    ErrorID     := RobotLibraryEvents.ERR_INVALID_STEP;
    ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
  END_CASE
  
  
  // Reset FB
  IF ( OnExecRun <> RobotLibraryConstants.RUNNING)
  THEN
   _stepCmd     := 0;
    Busy        := FALSE;
    Error       := FALSE;
    ErrorID     := 0;
    ErrorAddTxt := '';
    WarningID   := 0;
    InfoID      := 0;  
  END_IF

END_METHOD

METHOD PRIVATE ParseRecvPayload
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
  /// Inputs of PLC for communication from RC
  RobotInData  : ARRAY[0..RobotLibraryParameter.ROBOT_IN_DATA_MAX ] OF BYTE;
END_VAR

VAR
  /// internal index
 _idx             : DINT;
  /// temporary DWORD
 _tmpDword        : DWORD;
  /// length of data block
 _dataBlockLength : UINT;
  /// internal payload length
 _payLoadLen      : DWORD;  
  /// internal payload pointer
 _payLoadPtr      : DWORD;  
  /// sequence counter
 _seqCount        : DINT;
END_VAR

  // Reset payload
  RecvData.Reset();
  // Copy inputs to payload  
  SysDepMemCpy( pDest := ADR(RecvData.Payload) , pSrc  := ADR(RobotInData), DataLen := RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX +1);
  
  // check new data to receive ? 
  IF ( Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK <> AxesGroup.InternalData.LastACK[0]) {warning 'ToDo: handle 2nd sequence'} 
  THEN
    // delete old telegram data 
    SysDepMemSet(pDest := ADR(Telegram.RobToPlc), Value := 0 , DataLen := SIZEOF(Telegram.RobToPlc));
  END_IF
  
  
  ParseRecvPayloadHeader        ( AxesGroup := AxesGroup);
  ParseRecvPayloadCyclic        ( AxesGroup := AxesGroup);
  ParseRecvPayloadCyclicOptional( AxesGroup := AxesGroup);
  ParseRecvPayloadSequence      ( AxesGroup := AxesGroup);
  ParseRecvPayloadFooter        ( AxesGroup := AxesGroup);
  ParseRecvPayloadLogging       ( AxesGroup := AxesGroup);
  
  
  AxesGroup.InternalData.LastACK[0] := Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK; 
  AxesGroup.InternalData.LastACK[1] := Telegram.RobToPlc.Sequence[1].Header.SEQ_ACK;

END_METHOD

METHOD PRIVATE ParseRecvPayloadCyclic
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup: AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE ParseRecvPayloadCyclicOptional
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR

VAR 
  /// internal index for loops
 _idx : DINT;
END_VAR

  // AxesGroup.OptionalCyclic.RobToPlc.SubProgramData {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.SubProgramData.Active )
  THEN
    FOR _idx := 0 TO 25 {warning 'Add contant for DataMax'}
    DO
      Telegram.RobToPlc.CyclicOptional.SubProgramData.Data[_idx] := RecvData.GetByte(); 
    END_FOR
  END_IF
  // }}}
    
  // AxesGroup.OptionalCyclic.RobToPlc.CartesianPos {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.X                    := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Y                    := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Z                    := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Rx                   := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Ry                   := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Rz                   := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Config               := RecvData.GetWord();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J2_J1          := RecvData.GetByte();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J4_J3          := RecvData.GetByte();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_J6_J5          := RecvData.GetByte();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Turns_E1             := RecvData.GetByte();  
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.E1                   := RecvData.GetReal();  
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.ToolNo               := RecvData.GetUsint();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.FrameNo              := RecvData.GetUsint();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.CurrentlyUsedToolNo  := RecvData.GetUsint();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.CurrentlyUsedFrameNo := RecvData.GetUsint();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Reserve_1            := RecvData.GetByte();
    Telegram.RobToPlc.CyclicOptional.CartesianPosition.Reserve_2            := RecvData.GetByte();  
  END_IF
  // }}}
  
  // AxesGroup.OptionalCyclic.RobToPlc.JointPosition {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.JointPosition.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.JointPosition.J1         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.J2         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.J3         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.J4         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.J5         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.J6         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.E1         := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPosition.E1_Reserve := RecvData.GetWord();
  END_IF  
  // }}}
  
  // AxesGroup.OptionalCyclic.RobToPlc.CartesianForce {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.Force.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.Force.X  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Force.Y  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Force.Z  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Force.Rx := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Force.Ry := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Force.Rz := RecvData.GetReal();
  END_IF  
  // }}}    
    
  // AxesGroup.OptionalCyclic.RobToPlc.Current {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.Current.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.Current.J1  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Current.J2  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Current.J3  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Current.J4  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Current.J5  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.Current.J6  := RecvData.GetReal();
  END_IF    
    
  // AxesGroup.OptionalCyclic.RobToPlc.CartesianPosExt {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E2 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E3 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E4 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E5 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CartesianPositionExt.E6 := RecvData.GetReal();
  END_IF  
  // }}}       
    
  // AxesGroup.OptionalCyclic.RobToPlc.JointPosition {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.JointPositionExt.E2 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPositionExt.E3 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPositionExt.E4 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPositionExt.E5 := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.JointPositionExt.E6 := RecvData.GetReal();  
  END_IF  
  // }}}    
        
  // AxesGroup.OptionalCyclic.RobToPlc.CartesianForceExt {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.ForceExt.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.ForceExt.E1  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.ForceExt.E2  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.ForceExt.E3  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.ForceExt.E4  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.ForceExt.E5  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.ForceExt.E6  := RecvData.GetReal();
  END_IF
  // }}}    
    
  // AxesGroup.OptionalCyclic.RobToPlc.CurrentExt {{{
  IF ( AxesGroup.CyclicOptional.RobToPlc.CurrentExt.Active )
  THEN
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E1  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E2  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E3  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E4  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E5  := RecvData.GetReal();
    Telegram.RobToPlc.CyclicOptional.CurrentExt.E6  := RecvData.GetReal();
  END_IF
  // }}}

END_METHOD

METHOD PRIVATE ParseRecvPayloadFooter
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

VAR
  /// index of lifesign in footer
  _lifeSignIdxFooter : DINT;
END_VAR

  IF (( _parCfg.Com.TelegramLengthRobToPlc    >= 1                                          ) AND 
      ( _parCfg.Com.TelegramLengthRobToPlc -1 <= RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX ))
  THEN
    // set index of last byte
   _lifeSignIdxFooter := _parCfg.Com.TelegramLengthRobToPlc -1;
   
  
    Telegram.RobToPlc.Footer.LifeSign := GetHalfeByteHi(RecvData.Payload[_lifeSignIdxFooter]); 
  END_IF

END_METHOD

METHOD PRIVATE ParseRecvPayloadHeader
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR

  // Version
  Telegram.RobToPlc.Header.SRCIVersion := ByteToVersion(RecvData.GetByte());
  // Connection alive signal
  Telegram.RobToPlc.Header.LifeSign    := RecvData.GetHalfeByte2(IncPayloadPtr := TRUE);
  // Reserved byte
  Telegram.RobToPlc.Header.Reserved       := RecvData.GetByte();
  // Initialization and Telegram control state
  Telegram.RobToPlc.Header.TelegramState  := RecvData.GetUsint();
  // Combination of various RA related states.
  Telegram.RobToPlc.Header.StatusRobotArm := RecvData.GetDword();
  // Actual override in percentage encoding 
  Telegram.RobToPlc.Header.Override       := RecvData.GetUint();

END_METHOD

METHOD PRIVATE ParseRecvPayloadLogging
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR

VAR
  /// internal sequence index for loops
  _seqIdx : DINT;
  /// internal fragment index for loops
  _fragIdx : DINT;
END_VAR

  RETURN;
  FOR _seqIdx := 0 TO AxesGroup.InternalData.SequenceCountRecv
  DO
    // check new data to receive ? 
    IF ( Telegram.RobToPlc.Sequence[_seqIdx].Header.SEQ_ACK <> AxesGroup.InternalData.LastACK[_seqIdx]) 
    THEN
      // Check sequence payload > 0 ?    
      IF (Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength > 0)
      THEN
        // Create log entry
        CreateLogMessagePara4 ( Timestamp   := SystemTime,
                                MessageType := MessageType.CMD,
                                Severity    := Severity.DEBUG,
                                MessageCode := 0,
                                MessageText := 'RecvData: ACK = {1}, received Sequence [{2}] with PayloadLength = {3}, Lifesign = {4}',
                                Para1       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[_seqIdx].Header.SEQ_ACK),
                                Para2       :=  DINT_TO_STRING(_seqIdx),
                                Para3       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength),
                                Para4       :=  BYTE_TO_STRING(Telegram.RobToPlc.Header.LifeSign));
    
        FOR _fragIdx := 0 TO AxesGroup.InternalData.FragmentCountRecv[_seqIdx] 
        DO
          // Check fragment payload > 0 ?    
          IF (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > 0)
          THEN
            // Create log entry
            CreateLogMessagePara5 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.DEBUG,
                                    MessageCode := 0,
                                    MessageText := 'RecvData: received Fragment [{1}] with PayloadLength = {2}, CmdID <{3}> , CmdState: {4}, Fragment-Action Bits: {5}',
                                    Para1       :=  DINT_TO_STRING(0), {warning 'Add seqIdx'}
                                    Para2       :=  UINT_TO_STRING            (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength),
                                    Para3       :=  DINT_TO_STRING            (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID),
                                    Para4       :=  CmdMessageStateToString   (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.State),
                                    Para5       :=  ByteToFragmentActionString(Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction));
          END_IF
        END_FOR    
      END_IF
    END_IF
  END_FOR

END_METHOD

METHOD PRIVATE ParseRecvPayloadSequence
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR

VAR
  /// internal index
 _idx             : DINT;
  /// temporary DWORD
 _tmpDword        : DWORD;
  /// length of data block
 _dataBlockLength : UINT;
  /// internal payload length
 _payLoadLen      : DWORD;  
  /// internal payload pointer
 _payLoadPtr      : DWORD;  
  /// sequence counter
 _seqCount        : DINT;
END_VAR


VAR_INST
  /// last received acknowledge
 _lastACK : ARRAY[0..1] OF UDINT;
END_VAR

  // Sequence Data
  Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK       := RecvData.GetUint();
  Telegram.RobToPlc.Sequence[0].Header.PayloadLength := RecvData.GetUint();
  
  // check new data ? 
  IF ( Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK <> AxesGroup.InternalData.LastACK[0]) {warning 'ToDo Handle 2nd sequence'} 
  THEN
  
    IF (Telegram.RobToPlc.Sequence[0].Header.PayloadLength > 0)
    THEN
      // Create log entry
      CreateLogMessagePara4 ( Timestamp   := SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.DEBUG,
                              MessageCode := 0,
                              MessageText := 'RecvData: ACK = {1}, received Sequence [{2}] with PayloadLength = {3}, Lifesign = {4}',
                              Para1       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK),
                              Para2       :=  DINT_TO_STRING(0), {warning 'Add seqIdx'}
                              Para3       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[0].Header.PayloadLength),
                              Para4       :=  BYTE_TO_STRING(Telegram.RobToPlc.Header.LifeSign));
      
      Telegram.RobToPlc.Sequence[0].Fragment[0].Header.CmdID               := RecvData.GetUint();
      Telegram.RobToPlc.Sequence[0].Fragment[0].Header.Reserve             := RecvData.GetByte();
      Telegram.RobToPlc.Sequence[0].Fragment[0].Header.FragmentAction      := RecvData.GetByte();
      Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadPointer      := RecvData.GetUint();
      Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadLength       := RecvData.GetUint();
      
      
      IF (Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadLength > 0)
      THEN
        // Fill Respone payload
        FOR _idx := Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadPointer TO Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadLength
        DO
          Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[_idx] := RecvData.GetByte();
        END_FOR
        
        // Add Response to ACR
        AxesGroup.Acyclic.ActiveCommandRegister.AddRsp(Telegram.RobToPlc.Sequence[0].Fragment[0]);
      
        // Only for debugging
        Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Header.State                 := GetHalfeByteLo(Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[0]);
        Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Header.ParSeq                := GetHalfeByteHi(Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[0]);
        Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Header.AlarmMessageSeverity  :=   BYTE_TO_SINT(Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[1]);
        Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Header.AlarmMessageCode      :=  CombineBytesToUint( HiByte := Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[2],
                                                                                                               LoByte := Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Payload[3]);
        // Create log entry
        CreateLogMessagePara5 ( Timestamp   := SystemTime,
                                MessageType := MessageType.CMD,
                                Severity    := Severity.DEBUG,
                                MessageCode := 0,
                                MessageText := 'RecvData: received Fragment [{1}] with PayloadLength = {2}, CmdID <{3}> , CmdState: {4}, Fragment-Action Bits: {5}',
                                Para1       :=  DINT_TO_STRING(0), {warning 'Add seqIdx'}
                                Para2       :=  UINT_TO_STRING            (Telegram.RobToPlc.Sequence[0].Fragment[0].Header.PayloadLength),
                                Para3       :=  DINT_TO_STRING            (Telegram.RobToPlc.Sequence[0].Fragment[0].Header.CmdID),
                                Para4       :=  CmdMessageStateToString   (Telegram.RobToPlc.Sequence[0].Fragment[0].Command.Header.State),
                                Para5       :=  ByteToFragmentActionString(Telegram.RobToPlc.Sequence[0].Fragment[0].Header.FragmentAction));
                                //Para6       :=  BYTE_TO_STRING(Telegram.RobToPlc.Header.LifeSign)
      END_IF    
    END_IF
  END_IF  
  
  IF ( RobotLibraryParameter.TWO_SEQUENCES ) {warning 'ToDo'}
  THEN
   _seqCount := _seqCount + 1;
  END_IF

END_METHOD

