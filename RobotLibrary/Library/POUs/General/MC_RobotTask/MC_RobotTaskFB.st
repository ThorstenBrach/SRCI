/// Handles multiple mechanisms required for operation of the interface.
/// For maximal performance, this FB must be called after the function FB's, 
/// so that the data can be written to the fieldbus in the same cycle as the start of FB occours 
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
  SystemLog         : ARRAY[0..RobotLibraryParameter.SYSTEM_LOG_MAX ] OF STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN);
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
 _parCfg                      : RobotTaskParCfg;
  /// FB for exchange configuration
 _exchangeConfiguration       : MC_ExchangeConfigurationFB;
  /// FB for read robot data
 _readRobotData               : MC_ReadRobotDataFB;
  /// FB for read messaged
 _readMessages                : MC_ReadMessagesFB;  
  /// FB for read tool data
 _readToolData                : MC_ReadToolDataFB;  
  /// FB for read frame data
 _readFrameData               : MC_ReadFrameDataFB;  
  /// FB for read load data
 _readLoadData                : MC_ReadLoadDataFB;  
  /// FB for read work area
 _readWorkArea                : MC_ReadWorkAreaFB;  
  /// FB for read robot software limits
 _readRobotSWLimits           : MC_ReadRobotSWLimitsFB;  
  /// FB for read robot default dynamics
 _readRobotDefaultDynamics    : MC_ReadRobotDefaultDynamicsFB;  
  /// FB for read robot reference dynamics
 _readRobotReferenceDynamics  : MC_ReadRobotReferenceDynamicsFB;  

  
  /// FB for write tool data
 _writeToolData               : MC_WriteToolDataFB;  
  /// FB for write frame data
 _writeFrameData              : MC_WriteFrameDataFB;  
  /// FB for write load data
 _writeLoadData               : MC_WriteLoadDataFB;  
  /// FB for write work area
 _writeWorkArea               : MC_WriteWorkAreaFB;  
  /// FB for write robot software limits
 _writeRobotSWLimits          : MC_WriteRobotSWLimitsFB;  
  /// FB for write robot default dynamics
 _writeRobotDefaultDynamics   : MC_WriteRobotDefaultDynamicsFB;  
  /// FB for write robot reference dynamics
 _writeRobotReferenceDynamics : MC_WriteRobotReferenceDynamicsFB;  
  
  
  
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
  EMPTY_CMD_ENTRY      : AxesGroupAcyclicAcrEntryCmdBuffer := (State := BufferStateCmd.EMPTY);
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
  HandleAxesGroupMessageLog    ( AxesGroup    := AxesGroup);
  HandleAxesGroupParameter     ( AxesGroup    := AxesGroup);
  HandleAxesGroupState         ( AxesGroup    := AxesGroup);
  HandleLifeSign               ( AxesGroup    := AxesGroup);
  HandleLogMessagesAck         ( AxesGroup    := AxesGroup);
  HandleInvalidFrames          ( AxesGroup    := AxesGroup, RobotInData := RobotInData);
  HandleTelegramStateCtrl      (                          );
  HandleAliveBit               ( RobotInData[1]           );
  HandleSeqAck                 ( AxesGroup    := AxesGroup);
  HandleUserData               ( AxesGroup    := AxesGroup, UserData := UserData );
  OnCall                       ( AxesGroup    := AxesGroup);
  OnExecRun                    ( AxesGroup    := AxesGroup);
  
  
  AxesGroupToTelegram  ( AxesGroup    := AxesGroup );
  
  CreateSendPayload    ( AxesGroup    := AxesGroup,
                         RobotOutData := RobotOutData );
  
  ParseRecvPayload     ( AxesGroup    := AxesGroup,
                         RobotInData  := RobotInData); 
  
  AxesGroupFromTelegram( AxesGroup    := AxesGroup);
  
  
  // call internal functionblocks
  _exchangeConfiguration      ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readRobotData              ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readMessages               ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readToolData               ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readFrameData              ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readLoadData               ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readWorkArea               ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _readRobotSWLimits          ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _readRobotDefaultDynamics   ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _readRobotReferenceDynamics ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );
  _writeToolData              ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeFrameData             ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeLoadData              ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeWorkArea              ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeRobotSWLimits         ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeRobotDefaultDynamics  ( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  _writeRobotReferenceDynamics( Name := RobotName, ExecMode := ExecutionMode.PARALLEL, Priority := PriorityLevel.NORMAL, AxesGroup := AxesGroup );  
  
  
  // Update SystemLog and MessageLog
  SystemLog  := AxesGroup.MessageLog.SystemLogs;
  MessageLog := AxesGroup.MessageLog.Messages;

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

  IF ( AxesGroup.State.NewSEQ[0]) {warning 'Handle 2nd sequence'}
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

  IF (AxesGroup.Cyclic.PlcToRob.ToolNo = -1 )
  THEN
    Telegram.PlcToRob.Cyclic.ToolNo  := 16#FF;
  ELSE
    Telegram.PlcToRob.Cyclic.ToolNo  := INT_TO_BYTE(AxesGroup.Cyclic.PlcToRob.ToolNo); 
  END_IF
  
  IF (AxesGroup.Cyclic.PlcToRob.FrameNo = -1 )
  THEN
    Telegram.PlcToRob.Cyclic.FrameNo  := 16#FF;
  ELSE
    Telegram.PlcToRob.Cyclic.FrameNo  := INT_TO_BYTE(AxesGroup.Cyclic.PlcToRob.FrameNo); 
  END_IF

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
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J2_J1 := CombineHalfSints(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J2Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J1Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J4_J3 := CombineHalfSints(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J4Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J3Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_J6_J5 := CombineHalfSints(AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J6Turns, 
                                                                                       AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.J5Turns);
    Telegram.PlcToRob.CyclicOptional.CartesianPosition.Turns_E1    := SINT_TO_BYTE    (AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.TurnNumber.E1Turns);
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

  FOR _seqIdx := 0 TO AxesGroup.State.SequenceCountSend
  DO
    // check new data ? 
    IF ( AxesGroup.State.NewSEQ[_seqIdx] )
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
      
      FOR _fragIdx := 0 TO AxesGroup.State.FragmentCountSend[_seqIdx]
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
                                  Para4       := CMD_TYPE_TO_STRING        (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.CmdType),
                                  Para5       := FRAGMENT_ACTION_TO_STRING (Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction)); 
  
          // Create log entry
          CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                  MessageType := MessageType.CMD,
                                  Severity    := Severity.DEBUG,
                                  MessageCode := 0,
                                  MessageText := 'ExecMode = [{1}]' ,
                                  Para1       := EXECUTION_MODE_TO_STRING(Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ExecMode));
  
  
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
   /// Amount of sequences
 _seqCount                  : DINT;

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
  
  /// current length of telegram 
 _telegramLengthCurrent    : UINT;
END_VAR

  // Check 2nd sequence active ? 
  IF ( RobotLibraryParameter.TWO_SEQUENCES )
  THEN
    // inc sequence counter
   _seqCount := _seqCount + 1;
    
    SEQUENCE_MAX_PAYLOAD_SIZE := CalculateSequencePayloadMax(AxesGroup := AxesGroup, 
                                                             Direction := ComDirection.PLC_TO_ROB, 
                                                             Sequence  := SequenceFlag.SECONDARY_SEQUENCE ) - FOOTER_SIZE;
  ELSE
    SEQUENCE_MAX_PAYLOAD_SIZE := CalculateSequencePayloadMax(AxesGroup := AxesGroup, 
                                                             Direction := ComDirection.PLC_TO_ROB, 
                                                             Sequence  := SequenceFlag.PRIMARY_SEQUENCE   ) - FOOTER_SIZE;
  END_IF   
  
  
  FOR _seqIdx := 0 TO _seqCount
  DO
    // set current SEQ / ACk index
    Telegram.PlcToRob.Sequence[_seqIdx].Header.SEQ_ACK := AxesGroup.State.CurrentSEQ[_seqIdx];
  
    // only update telegram content if a new sequence SEQ is set
    IF ( AxesGroup.State.NewSEQ[_seqIdx] ) 
    THEN
      // only reset counters in case of new telegram to send  
      AxesGroup.State.SequenceCountSend := 0;
      AxesGroup.State.FragmentCountSend[_seqIdx] := 0;
      
      // calc current telegram payload length
     _telegramLengthCurrent := CalculateTelegramLengthPlcToRob(AxesGroup := AxesGroup);
      
      // Bedingung anpassen und TWO_SEQUENCES berücksichtigen
      WHILE (( _parCfg.Com.TelegramLengthPlcToRob - _telegramLengthCurrent ) >= FRAGMENT_HEADER_SIZE + MIN_PAYLOAD_SIZE ) 
      DO
        // Check command in Execution-Order-List available ?
        IF ( AxesGroup.Acyclic.ActiveCommandRegister.ExecutionOrderList[_listIdx] > EMPTY_EOL_ENTRY)
        THEN
          // set current SEQ / ACk index
          Telegram.PlcToRob.Sequence[_seqIdx].Header.SEQ_ACK := AxesGroup.State.CurrentSEQ[_seqIdx];
          
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
            Telegram.PlcToRob.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer := AxesGroup.Acyclic.ActiveCommandRegister.Register[_regIdx].Command[ACTIVE_CMD].PayLoadPtr; 
            
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
             _telegramLengthCurrent := CalculateTelegramLengthPlcToRob(AxesGroup := AxesGroup);
        
              // check limit reached ?
              IF ( _telegramLengthCurrent >= _parCfg.Com.TelegramLengthPlcToRob) 
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
    
        // check abort conditions
        IF (( _telegramLengthCurrent                                                >= _parCfg.Com.TelegramLengthPlcToRob  ) OR  // Payload limit reached 
            ( _fragIdx                                                              >=  RobotLibraryParameter.FRAGMENT_MAX ) OR  // Max fragment limit reached
            (  AxesGroup.Acyclic.ActiveCommandRegister.ExecutionOrderList[_listIdx]  =  EMPTY_EOL_ENTRY                    ))    // No entry in ExecutionOrderList left
        THEN
          EXIT;// -> Abort while loop
        END_IF         
      END_WHILE  
      
      AxesGroup.State.SequenceCountSend          := _seqIdx;
      AxesGroup.State.FragmentCountSend[_seqIdx] := _fragIdx;
      
    END_IF  
  END_FOR

END_METHOD

METHOD CalculateCyclicDataLength : UINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR_INPUT
  /// Communication direction
  Direction : ComDirection;
END_VAR

VAR CONSTANT
  /// Size of the header
  ROB_TO_PLC_HEADER_SIZE : UINT := 10;
END_VAR

  // ------------------------------------
  // PLC -> ROB
  // ------------------------------------
  IF (Direction = ComDirection.PLC_TO_ROB)
  THEN  
    // Add Header size 
    CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.Header);  
    // Add Cyclic size 
    CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.Cyclic);
    
    // Check SubProgramData active ? 
    IF ( AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Active )
    THEN
      // Add SubProgramData size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.SubProgramData);
    END_IF
      
    // Check CartesianPosition active ? 
    IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPosition.Active )
    THEN
      // Add CartesianPosition size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.CartesianPosition);
    END_IF
    
    // Check JointPosition active ? 
    IF ( AxesGroup.CyclicOptional.PlcToRob.JointPosition.Active )
    THEN
      // Add JointPosition size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.JointPosition);
    END_IF  
    
    // Check Force active ? 
    IF ( AxesGroup.CyclicOptional.PlcToRob.Force.Active )
    THEN
      // Add Force size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.Force);
    END_IF  
      
    // Check CartesianPositionExt acive ? 
    IF ( AxesGroup.CyclicOptional.PlcToRob.CartesianPositionExt.Active )
    THEN
      // Add CartesianPositionExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.CartesianPositionExt);
    END_IF   
      
    // Check JointPositionExt active ?
    IF ( AxesGroup.CyclicOptional.PlcToRob.JointPositionExt.Active )
    THEN
      // Add JointPositionExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.JointPositionExt);
    END_IF  
          
    // Check ForceExt active ?
    IF ( AxesGroup.CyclicOptional.PlcToRob.ForceExt.Active )
    THEN
      // Add ForceExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.PlcToRob.CyclicOptional.ForceExt);
    END_IF
  END_IF
  
  // ------------------------------------
  // ROB -> PLC
  // ------------------------------------
  IF (Direction = ComDirection.ROB_TO_PLC)
  THEN
    // Add Header size 
    CalculateCyclicDataLength := CalculateCyclicDataLength + ROB_TO_PLC_HEADER_SIZE; 
    {warning 'ToDo: Used a constant because SizeOf(Telegram.RobToPlc.Header) return a wrong value,  because of VersionStruct instead of Byte'}
    
    // Check SubProgramData active ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.SubProgramData.Active )
    THEN
      // Add SubProgramData size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.SubProgramData);
    END_IF
      
    // Check CartesianPosition active ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.CartesianPosition.Active )
    THEN
      // Add CartesianPosition size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.CartesianPosition);
    END_IF
    
    // Check JointPosition active ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.JointPosition.Active )
    THEN
      // Add JointPosition size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.JointPosition);
    END_IF  
    
    // Check Force active ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.Force.Active )
    THEN
      // Add Force size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.Force);
    END_IF  
      
    // Check Current acive ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.Current.Active )
    THEN
      // Add Current size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.Current);
    END_IF    
      
    // Check CartesianPositionExt acive ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt.Active )
    THEN
      // Add CartesianPositionExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.CartesianPositionExt);
    END_IF  
      
    // Check JointPositionExt active ?
    IF ( AxesGroup.CyclicOptional.RobToPlc.JointPositionExt.Active )
    THEN
      // Add JointPositionExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.JointPositionExt);
    END_IF  
          
    // Check ForceExt active ?
    IF ( AxesGroup.CyclicOptional.RobToPlc.ForceExt.Active )
    THEN
      // Add ForceExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.ForceExt);
    END_IF
      
    // Check CurrentExt active ? 
    IF ( AxesGroup.CyclicOptional.RobToPlc.CurrentExt.Active )
    THEN
      // Add CurrentExt size 
      CalculateCyclicDataLength := CalculateCyclicDataLength + SIZEOF(Telegram.RobToPlc.CyclicOptional.CurrentExt);
    END_IF
  END_IF

END_METHOD

METHOD CalculateSequencePayloadMax : UINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR_INPUT
  /// Communication direction
  Direction : ComDirection;
  /// Sequeunce
  Sequence : SequenceFlag;  
END_VAR

VAR
  /// Length of the cyclic header
 _cyclicDataLength      : UINT;
END_VAR

  // calculate cyclic header length
  _cyclicDataLength := CalculateCyclicDataLength(AxesGroup := AxesGroup, Direction := Direction);
  
  
  CASE (Sequence) 
  OF
    SequenceFlag.PRIMARY_SEQUENCE   : 
  
      IF (Direction = ComDirection.PLC_TO_ROB)
      THEN  
        // calculate sequence payload length
        CalculateSequencePayloadMax := ( _parCfg.Com.TelegramLengthPlcToRob - _cyclicDataLength );
      END_IF
  
      IF (Direction = ComDirection.ROB_TO_PLC)
      THEN  
        // calculate sequence payload length
        CalculateSequencePayloadMax := ( _parCfg.Com.TelegramLengthRobToPlc - _cyclicDataLength );
      END_IF
      
  
    SequenceFlag.SECONDARY_SEQUENCE :
    
      IF (Direction = ComDirection.PLC_TO_ROB)
      THEN  
        // calculate sequence payload length
        CalculateSequencePayloadMax := (( _parCfg.Com.TelegramLengthPlcToRob - _cyclicDataLength ) / 2);
      END_IF
  
      IF (Direction = ComDirection.ROB_TO_PLC)
      THEN  
        // calculate sequence payload length
        CalculateSequencePayloadMax := (( _parCfg.Com.TelegramLengthRobToPlc - _cyclicDataLength ) / 2);
      END_IF
  
      
  END_CASE

END_METHOD

METHOD CalculateSequencePayloadStartAdr : UINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR_INPUT
  /// Communication direction
  Direction : ComDirection;
  /// Sequeunce
  Sequence : SequenceFlag;  
END_VAR

VAR
  /// Length of the cyclic header
 _cyclicDataLength      : UINT;
  /// Length of the sequnce payload
 _sequencePayloadLength : UINT;
END_VAR

  // calculate cyclic header length
  _cyclicDataLength := CalculateCyclicDataLength(AxesGroup := AxesGroup, Direction := Direction);
  
  CASE (Sequence) 
  OF
  
    SequenceFlag.PRIMARY_SEQUENCE   : 
    
      // return start address
      CalculateSequencePayloadStartAdr := _cyclicDataLength;
  
    SequenceFlag.SECONDARY_SEQUENCE :
    
      // calculate sequence payload max
     _sequencePayloadLength 
       := CalculateSequencePayloadMax( AxesGroup := AxesGroup, 
                                       Direction := Direction, 
                                       Sequence  := Sequence );
                                       
      // return start address
      CalculateSequencePayloadStartAdr := _cyclicDataLength + _sequencePayloadLength;
      
  END_CASE

END_METHOD

METHOD PRIVATE CalculateTelegramLengthPlcToRob : UINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR
VAR
  /// length of the cyclic data block
 _cyclicDataLength : UINT;
END_VAR

  _cyclicDataLength := CalculateCyclicDataLength(AxesGroup := AxesGroup, Direction := ComDirection.PLC_TO_ROB); 
  
  
  IF ( RobotLibraryParameter.TWO_SEQUENCES )
  THEN
    CalculateTelegramLengthPlcToRob := _cyclicDataLength
                                      + SIZEOF(Telegram.PlcToRob.Sequence[  PRIMARY_SEQUENCE].Header)
                                      +       (Telegram.PlcToRob.Sequence[  PRIMARY_SEQUENCE].Header.PayloadLength)
                                      + SIZEOF(Telegram.PlcToRob.Sequence[SECONDARY_SEQUENCE].Header)
                                      +       (Telegram.PlcToRob.Sequence[SECONDARY_SEQUENCE].Header.PayloadLength)
                                      + SIZEOF(Telegram.PlcToRob.Footer);  
  ELSE
    CalculateTelegramLengthPlcToRob := _cyclicDataLength
                                      + SIZEOF(Telegram.PlcToRob.Sequence[PRIMARY_SEQUENCE].Header)
                                      +       (Telegram.PlcToRob.Sequence[PRIMARY_SEQUENCE].Header.PayloadLength)
                                      + SIZEOF(Telegram.PlcToRob.Footer);
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterChanged : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup    : AxesGroup; 
END_VAR

VAR
  /// internal index for loops
 _idx : DINT;
END_VAR

  // Check initialization is already done ?
  IF ( NOT Initialized )
  THEN
    CheckParameterChanged := FALSE;
    RETURN;
  END_IF
  
  // compare memory 
  CheckParameterChanged := ( SysDepMemCmp(pData1 := ADR(ParCfg), pData2 := ADR(_parCfg), DataLen := SIZEOF(ParCfg)) <> RobotLibraryConstants.OK );
  
  FOR _idx := SyncTime.DURING_START_UP TO SyncTime.AFTER_START_UP
  DO
    // Check Tool SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.Tool[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.Tool[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_TOOL_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.Tool[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.Tool[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.Tool[_idx]));   
    END_IF
    
    
    // Check Frame SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.Frame[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.Frame[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_FRAME_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.Frame[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.Frame[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.Frame[_idx]));   
    END_IF
    
    
    // Check Load SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.Load[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.Load[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_LOAD_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.Load[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.Load[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.Load[_idx]));   
    END_IF
    
    
    // Check WorkAreas SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.WorkAreas[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.WorkAreas[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_WORK_AREA_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.WorkAreas[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.WorkAreas[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.WorkAreas[_idx]));   
    END_IF
  
    // Check SWLimits SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.SWLimits[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.SWLimits[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_SWLIMITS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.SWLimits[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.SWLimits[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.SWLimits[_idx]));   
    END_IF
    
   
    // Check DefaultDynamics SyncMode changed ? 
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.DefaultDynamics[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.DefaultDynamics[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_DEFAULT_DYNAMIVS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.DefaultDynamics[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.DefaultDynamics[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.DefaultDynamics[_idx]));   
    END_IF
    
    
    // Check ReferenceDynamics SyncMode changed ?
    IF ( _parCfg.Plc.Parameter.SynchronizationModes.ReferenceDynamics[_idx] <> ParCfg.Plc.Parameter.SynchronizationModes.ReferenceDynamics[_idx] )
    THEN
      // Set info
      InfoID := RobotLibraryInfoIdEnum.INFO_CHANGE_REFERENCE_DYNAMIVS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED;
       
      // Create log entry
      CreateLogMessagePara3( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.INFO,
                             MessageCode := 0,
                             MessageText := 'SyncMode.ReferenceDynamics[{1}] changed from {2} to {3}, but this is only allowed at PLC start',
                             Para1       := SYNC_TIME_TO_STRING(_idx),
                             Para2       := SYNC_MODE_TO_STRING( ParCfg.Plc.Parameter.SynchronizationModes.ReferenceDynamics[_idx]),
                             Para3       := SYNC_MODE_TO_STRING(_parCfg.Plc.Parameter.SynchronizationModes.ReferenceDynamics[_idx]));   
    END_IF
  
  END_FOR
  
  
  // Check Plc.OptionalCyclic changed ? 
  IF ( PlcOptionalCyclicToUint(_parCfg.Plc.OptionalCyclic) <> PlcOptionalCyclicToUint(ParCfg.Plc.OptionalCyclic ))
  THEN
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_CHANGED_AFTER_INIT;
     
    // Create log entry
    CreateLogMessagePara2( Timestamp   := SystemTime,
                           MessageType := MessageType.CMD,
                           Severity    := Severity.ERROR,
                           MessageCode := 0,
                           MessageText := 'ParCfg.Plc.OptionalCyclic changed after initialization from {1} to {2} -> Reinitialize by disabling and enabling the RobotTask',
                           Para1       := WORD_TO_STRING_BIN(PlcOptionalCyclicToUint(_parCfg.Plc.OptionalCyclic)),
                           Para2       := WORD_TO_STRING_BIN(PlcOptionalCyclicToUint( ParCfg.Plc.OptionalCyclic)));   
  END_IF
  
  
  // Check Rob.OptionalCyclic changed ? 
  IF ( RobOptionalCyclicToUint(_parCfg.Rob.OptionalCyclic) <> RobOptionalCyclicToUint(ParCfg.Rob.OptionalCyclic ))
  THEN
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_CHANGED_AFTER_INIT;
     
    // Create log entry
    CreateLogMessagePara2( Timestamp   := SystemTime,
                           MessageType := MessageType.CMD,
                           Severity    := Severity.ERROR,
                           MessageCode := 0,
                           MessageText := 'ParCfg.Rob.OptionalCyclic changed after initialization from {1} to {2} -> Reinitialize by disabling and enabling the RobotTask',
                           Para1       := WORD_TO_STRING_BIN(RobOptionalCyclicToUint(_parCfg.Rob.OptionalCyclic)),
                           Para2       := WORD_TO_STRING_BIN(RobOptionalCyclicToUint( ParCfg.Rob.OptionalCyclic)));   
  END_IF

END_METHOD

METHOD PROTECTED CheckParameterValid : BOOL
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // init return value
  CheckParameterValid := TRUE;
  
  // Regrion ParCfg.Com {{{
  
  // Check LifeSignTimeout
  IF ( ParCfg.Com.LifeSignTimeOut < T#10MS )
  THEN
    // set to valid min value
    ParCfg.Com.LifeSignTimeOut := T#10MS;
   
    // Set info
    InfoID := RobotLibraryInfoIdEnum.INFO_LIFESIGN_TIMEOUT_TO_SMALL_AND_SET_TO_10MS;
     
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.INFO,
                            MessageCode := 0,
                            MessageText := 'LifeSignTimeout to small and set from {1}ms to 10ms',
                            Para1       := TIME_TO_STRING(ParCfg.Com.LifeSignTimeOut));                          
  END_IF
  
  
  // Check ParCfg.Com.TelegramLengthPlcToRob
  IF (( ParCfg.Com.TelegramLengthPlcToRob < 64                                           ) OR
      ( ParCfg.Com.TelegramLengthPlcToRob > RobotLibraryParameter.ROBOT_OUT_DATA_MAX + 1 ))
  THEN
    // parameter(s) not valid
    CheckParameterValid := FALSE;
  
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_TELEGRAM_LENGTH_MISMATCH_0x80A3;
     
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.INFO,
                            MessageCode := 0,
                            MessageText := 'ParCfg.Com.TelegramLengthPlcToRob {1} invalid',
                            Para1       := UINT_TO_STRING(ParCfg.Com.TelegramLengthPlcToRob));
    // no further validation                          
    RETURN;                          
  END_IF
  
  // Check ParCfg.Com.TelegramLengthRobToPlc
  IF (( ParCfg.Com.TelegramLengthRobToPlc < 64                                          ) OR
      ( ParCfg.Com.TelegramLengthRobToPlc > RobotLibraryParameter.ROBOT_IN_DATA_MAX + 1 ))
  THEN
    // parameter(s) not valid
    CheckParameterValid := FALSE;
  
    // Set error
    ErrorID := RobotLibraryErrorIdEnum.ERR_TELEGRAM_LENGTH_MISMATCH_0x80A3;
     
    // Create log entry
    CreateLogMessagePara1 ( Timestamp   := SystemTime,
                            MessageType := MessageType.CMD,
                            Severity    := Severity.INFO,
                            MessageCode := 0,
                            MessageText := 'ParCfg.Com.TelegramLengthRobToPlc {1} invalid',
                            Para1       := UINT_TO_STRING(ParCfg.Com.TelegramLengthRobToPlc));
    // no further validation                          
    RETURN;                          
  END_IF
  // EndRegion }}}
  
  // Region ParCfg.Rob.OptionalCyclic {{{
  
  // Check configuration if optional cyclic CartesianPosition valid ?
  IF ( ParCfg.Rob.OptionalCyclic.UseCartesianPosition AND ParCfg.Rob.OptionalCyclic.UseCartesianPositionExt )
  THEN
    // set to valid configuration
    ParCfg.Rob.OptionalCyclic.UseCartesianPosition    := TRUE;
    ParCfg.Rob.OptionalCyclic.UseCartesianPositionExt := FALSE;
   
    // Set info
    InfoID := RobotLibraryInfoIdEnum.INFO_RECV_EXT_CART_POS_NOT_USABLE_WITH_RECV_CART_POS;
     
    // Create log entry
    CreateLogMessage( Timestamp   := SystemTime,
                      MessageType := MessageType.CMD,
                      Severity    := Severity.INFO,
                      MessageCode := 0,
                      MessageText := 'UseCartesianPosition and UseCartesianPositionExt cannot be configured together -> UseCartesianPosition is automatically activated');
  END_IF
  
  
  // Check configuration if optional cyclic JointPosition valid ?
  IF ( ParCfg.Rob.OptionalCyclic.UseJointPosition AND ParCfg.Rob.OptionalCyclic.UseJointPositionExt ) AND FALSE  {warning 'ToDo: Yaskawa need this combination for debugging via JointPosExt '}
  THEN
    // set to valid configuration
    ParCfg.Rob.OptionalCyclic.UseJointPosition    := TRUE;
    ParCfg.Rob.OptionalCyclic.UseJointPositionExt := FALSE;
   
    // Set info
    InfoID := RobotLibraryInfoIdEnum.INFO_RECV_EXT_JOINT_POS_NOT_USABLE_WITH_RECV_JOINT_POS;
     
    // Create log entry
    CreateLogMessage( Timestamp   := SystemTime,
                      MessageType := MessageType.CMD,
                      Severity    := Severity.INFO,
                      MessageCode := 0,
                      MessageText := 'UseJointPosition and UseJointPositionExt cannot be configured together -> UseJointPosition is automatically activated');
  END_IF
  // EndRegion }}}

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
  AxesGroup.State.NewSEQ[0] := FALSE; {warning 'Test'}

END_METHOD

METHOD PRIVATE CreateSendPayloadCyclic : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  SendData.AddByte(Telegram.PlcToRob.Cyclic.ToolNo);  
  SendData.AddByte(Telegram.PlcToRob.Cyclic.FrameNo);

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

  IF (( _parCfg.Com.TelegramLengthPlcToRob    >= 1                                           ) AND 
      ( _parCfg.Com.TelegramLengthPlcToRob    <= RobotLibraryParameter.ROBOT_OUT_DATA_MAX +1 ))
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

  IF  ((( Telegram.PlcToRob.Sequence[0].Header.PayloadLength > 0 ) AND (AxesGroup.State.NewSEQ[0] )) OR
       (( Telegram.PlcToRob.Sequence[1].Header.PayloadLength > 0 ) AND (AxesGroup.State.NewSEQ[1] )))
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
    FOR _seqIdx := 0 TO AxesGroup.State.SequenceCountSend
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
      FOR _fragIdx := 0 TO AxesGroup.State.FragmentCountSend[_seqIdx]  
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
  AxesGroup.Acyclic.ActiveCommandRegister(SystemTime     := SystemTime,
                                          RegisterSize   := MIN( RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX, AxesGroup.Parameter.Rob.Parameter.LengthACR),
                                          ExternalLogger := AxesGroup.MessageLog.ExternalLogger, 
                                          LogLevel       := AxesGroup.MessageLog.LogLevel);

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
  
  AxesGroup.Cyclic.PlcToRob.TelegramLengthPlcToRob := _parCfg.Com.TelegramLengthPlcToRob;
  AxesGroup.Cyclic.PlcToRob.TelegramLengthRobToPlc := _parCfg.Com.TelegramLengthRobToPlc;
  
  AxesGroup.Cyclic.PlcToRob.TelegramNumberPlcToRob := PlcOptionalCyclicToUint(AxesGroup.Parameter.Plc.OptionalCyclic);
  AxesGroup.Cyclic.PlcToRob.TelegramNumberRobToPlc := RobOptionalCyclicToUint(AxesGroup.Parameter.Rob.OptionalCyclic);
  
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

METHOD PRIVATE HandleAxesGroupMessageLog
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup  : AxesGroup;
END_VAR

  // Set External logger 
  AxesGroup.MessageLog.ExternalLogger := ExternalLogger;
  AxesGroup.MessageLog.LogLevel       := LogLevel;
  
  
  IF (AxesGroup.State.GroupReset_R.Q)
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
  
  IF (_exchangeConfiguration.Enabled)
  THEN  
    AxesGroup.Parameter.Rob.Parameter.LengthACR                 := _exchangeConfiguration.OutCmd.LengthACR;
    AxesGroup.Parameter.Rob.Parameter.HighestToolIndex          := _exchangeConfiguration.OutCmd.HighestToolIndex;
    AxesGroup.Parameter.Rob.Parameter.HighestFrameIndex         := _exchangeConfiguration.OutCmd.HighestFrameIndex;
    AxesGroup.Parameter.Rob.Parameter.HighestLoadIndex          := _exchangeConfiguration.OutCmd.HighestLoadIndex;
    AxesGroup.Parameter.Rob.Parameter.HighestWorkAreaIndex      := _exchangeConfiguration.OutCmd.HighestWorkAreaIndex;
    AxesGroup.Parameter.Rob.Parameter.DataInSync                := _exchangeConfiguration.OutCmd.DataInSync;
    AxesGroup.Parameter.Rob.Parameter.ChangeIndexTool           := _exchangeConfiguration.OutCmd.ChangeIndexTool;
    AxesGroup.Parameter.Rob.Parameter.ChangeIndexFrame          := _exchangeConfiguration.OutCmd.ChangeIndexFrame;
    AxesGroup.Parameter.Rob.Parameter.ChangeIndexLoad           := _exchangeConfiguration.OutCmd.ChangeIndexLoad;
    AxesGroup.Parameter.Rob.Parameter.ChangeIndexWorkArea       := _exchangeConfiguration.OutCmd.ChangeIndexWorkArea;
    AxesGroup.Parameter.Rob.Parameter.RAWorkingHours            := _exchangeConfiguration.OutCmd.RAWorkingHours;
    AxesGroup.Parameter.Rob.Parameter.BrakeTestRequired         := _exchangeConfiguration.OutCmd.BrakeTestRequired;
    AxesGroup.Parameter.Rob.Parameter.StepModeExactStopActive   := _exchangeConfiguration.OutCmd.StepModeExactStopActive;
    AxesGroup.Parameter.Rob.Parameter.StepModeBlendingActive    := _exchangeConfiguration.OutCmd.StepModeBlendingActive;
    AxesGroup.Parameter.Rob.Parameter.PathAccuracyMode          := _exchangeConfiguration.OutCmd.PathAccuracyMode;
    AxesGroup.Parameter.Rob.Parameter.AvoidSingularity          := _exchangeConfiguration.OutCmd.AvoidSingularity;
    AxesGroup.Parameter.Rob.Parameter.CollisionDetectionEnabled := _exchangeConfiguration.OutCmd.CollisionDetectionEnabled;
    AxesGroup.Parameter.Rob.Parameter.AcceleratingSupported     := _exchangeConfiguration.OutCmd.AcceleratingSupported;
    AxesGroup.Parameter.Rob.Parameter.DecceleratingSupported    := _exchangeConfiguration.OutCmd.DecceleratingSupported;
    AxesGroup.Parameter.Rob.Parameter.ConstantVelocitySupported := _exchangeConfiguration.OutCmd.ConstantVelocitySupported;
    AxesGroup.Parameter.Rob.Parameter.RCWorkingHours            := _exchangeConfiguration.OutCmd.RCWorkingHours;
  END_IF

END_METHOD

METHOD PRIVATE HandleAxesGroupState
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  AxesGroup.State.AliveOk     := _aliveBit;
  AxesGroup.State.Initialized := Initialized AND AxesGroup.State.AliveOk;
  AxesGroup.State.CMDsEnabled := AxesGroup.State.Initialized;
  
  
  AxesGroup.State.Synchronized := ((  AxesGroup.State.AliveOk                                         ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.DefaultDynamicsInSync   ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.ToolsInSync             ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.FramesInSync            ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.LoadsInSync             ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.WorkAreasInSync         ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.SoftwareLimitsInSync    ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.DefaultDynamicsInSync   ) AND
                                   ( _exchangeConfiguration.OutCmd.DataInSync.ReferenceDynamicsInSync ));
    
  
  AxesGroup.State.ConfigExchanged := _exchangeConfiguration.Enabled;
  
  
  
  // Update internal data
  AxesGroup.State.SystemTime   := SystemTime;
  AxesGroup.State.OnlineChange := OnlineChange;
  AxesGroup.State.Initialized  := Initialized;
  
  // Create rising and falling edges for Online Change
  AxesGroup.State.OnlineChange_R(CLK := OnlineChange);
  AxesGroup.State.OnlineChange_F(CLK := OnlineChange);
  
  // Create rising and falling edges for GroupReset
  AxesGroup.State.GroupReset_R(CLK := AxesGroup.State.GroupReset);
  AxesGroup.State.GroupReset_F(CLK := AxesGroup.State.GroupReset);
  
  // Copy function block results 
  AxesGroup.State.RobotData         := _readRobotData.OutCmd;
  AxesGroup.State.ConfigurationData := _exchangeConfiguration.OutCmd;

END_METHOD

METHOD PRIVATE HandleInvalidFrames
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup   : AxesGroup;
    /// Inputs of PLC for communication from RC
  RobotInData : ARRAY[0..RobotLibraryParameter.ROBOT_IN_DATA_MAX ] OF BYTE;
END_VAR 
VAR
  /// index of lifesign in header
 _lifeSignIdxHeader : DINT;
  /// Value of lifesign in header
 _lifeSignHeader    : BYTE;
  /// index of lifesign in footer
 _lifeSignIdxFooter : DINT;
  /// Value of lifesign in footer
 _lifeSignFooter    : BYTE;
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
  
  // set index of last byte
  _lifeSignIdxHeader := 1;
  _lifeSignIdxFooter := _parCfg.Com.TelegramLengthRobToPlc -1;
  
  IF ( AxesGroup.Cyclic.RobToPlc.TelegramState = TelegramState.INITIALIZED ) 
  THEN
    // Get lifesign values
   _lifeSignHeader := GetHalfeByteHi( RobotInData[_lifeSignIdxHeader]);
   _lifeSignFooter := GetHalfeByteHi( RobotInData[_lifeSignIdxFooter]);
  END_IF
  
  // Timer for invalid frame(s) message
  _invalidFrameCounterCheck_D( IN := TRUE , PT := RobotLibraryParameter.INVALID_FRAMES_CHECK_TIMEOUT);
  
  // Check Frame is valid : 
  // ----------------------
  IF ( _lifeSignHeader <> _lifeSignFooter )   
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
  IF ( AxesGroup.State.GroupReset_R.Q)
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
  /// flag for 1st cycle
 _first : BOOL := TRUE;
END_VAR

  IF ( _first )
  THEN
    // init LifeSign 
    AxesGroup.Cyclic.PlcToRob.LifeSign := 0;
    // reset first flag
   _first := FALSE;
    // prevent inc LifeSign in the 1st cycle (Code below)
    RETURN;
  END_IF
  
  
  AxesGroup.Cyclic.PlcToRob.LifeSign := AxesGroup.Cyclic.PlcToRob.LifeSign + 1;
    
  IF ( AxesGroup.Cyclic.PlcToRob.LifeSign > 15 )
  THEN
    AxesGroup.Cyclic.PlcToRob.LifeSign := 1; // 0 is only in the very 1st cycle to indicate the system start in logging
  END_IF
  
  
  
  IF ( Enable ) AND ( _alive_F.Q ) 
  THEN
    // Reset initialized flag
    Initialized := FALSE;
    // Set error 
    ErrorID := RobotLibraryErrorIdEnum.ERR_CONNECTION_LOST;  
    // Create log entry
    CreateLogMessage ( Timestamp   := SystemTime,
                       MessageType := MessageType.CMD,
                       Severity    := Severity.FATAL_ERROR,
                       MessageCode := 0,
                       MessageText := 'LifeSign timeout -> Reinitialization required !');
  END_IF
  
  // Reset connection lost error
  IF ( NOT Enable ) AND ( _aliveBit ) AND ( ErrorID = RobotLibraryErrorIdEnum.ERR_CONNECTION_LOST )
  THEN
    ErrorID := 0;
  END_IF

END_METHOD

METHOD HandleLogMessagesAck
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup : AxesGroup;
END_VAR

  IF (( _readMessages.Enabled           ) AND 
      ( _readMessages.OutCmd.MsgId > 0  ))  
  THEN
    // Check if message has been entered into the message log ?   
    IF ( AxesGroup.MessageLog.CheckMessageCodePresent(_readMessages.OutCmd.ErrorCode ))
    THEN
      // Set Message ID as Acknowlege ID  
     _readMessages.ParCmd.MsgID := _readMessages.OutCmd.MsgId;  
  	END_IF    
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

  FOR _idx := 0 TO  AxesGroup.State.SequenceCountSend 
  DO
    AxesGroup.State.CurrentAck[_idx] := Telegram.RobToPlc.Sequence[_idx].Header.SEQ_ACK;
    
    IF (NOT Enable)
    THEN
      AxesGroup.State.CurrentSEQ[0] := 0;
      AxesGroup.State.CurrentSEQ[1] := 0;
    END_IF  
    
    // Check Seq/Ack : 
    // ----------------------
    IF ( AxesGroup.State.CurrentAck[_idx] = AxesGroup.State.CurrentSEQ[_idx] ) 
    THEN
      AxesGroup.State.CurrentSEQ[_idx] := MAX(AxesGroup.State.CurrentSEQ[0],AxesGroup.State.CurrentSEQ[1]) +1;
  
      IF (AxesGroup.State.CurrentSEQ[_idx] >= 255) {warning 'ToDo: Test for Yaskawa'}
      THEN
        AxesGroup.State.CurrentSEQ[_idx] := 0;
  		END_IF
      
      AxesGroup.State.NewSEQ[_idx] := TRUE;
    END_IF  
  END_FOR

END_METHOD

METHOD PRIVATE HandleSync
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncFrameData
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncLoadData
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncRobotDefaultDynamics
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncRobotReferenceDynamics
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncRobotSWLimits
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncToolData
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


END_METHOD

METHOD PRIVATE HandleSyncWorkArea
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
END_VAR


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
                            Para1       := TELEGRAM_CONTROL_TO_STRING(_lastTelegramControl),
                            Para2       := TELEGRAM_CONTROL_TO_STRING(GetHalfeByteLo(Telegram.PlcToRob.Header.AxesGroupID_Control)));
  
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
                            Para1       := TELEGRAM_STATE_TO_STRING(_lastTelegramState),
                            Para2       := TELEGRAM_STATE_TO_STRING(Telegram.RobToPlc.Header.TelegramState));
  
    _lastTelegramState := Telegram.RobToPlc.Header.TelegramState;
  END_IF

END_METHOD

METHOD HandleUserData
VAR_IN_OUT
   /// Robot assignment of function
  AxesGroup    : AxesGroup;
  ///  User data stored on the PLC according to Table 6-10
  UserData     : UserData;
END_VAR

  // Common
  UserData.LogLevel                          := LogLevel;
  UserData.PLCLibraryVersion                 := RobotLibraryConstants.PLCLibraryVersion;
                                             
  // Communication                           
  UserData.LifeSignTimeOut                   := _parCfg.Com.LifeSignTimeOut;
                                             
  // Plc Parameter                           
  UserData.SynchronizationModes              := _parCfg.Plc.Parameter.SynchronizationModes;
                                             
  // Robot Parameter                         
  UserData.EnableSyncTool                    := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncTool;
  UserData.EnableSyncFrame                   := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncFrame;
  UserData.EnableSyncLoad                    := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncLoad;
  UserData.EnableSyncWorkArea                := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncWorkArea;
  UserData.EnableSyncSWLimits                := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncSWLimits;
  UserData.EnableSyncDefaultDynamics         := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncDefaultDynamics;
  UserData.EnableSyncReferenceDynamics       := _parCfg.Rob.Parameter.DataEnableSync.EnableSyncReferenceDynamics;
  UserData.DelayTime                         := _parCfg.Rob.Parameter.DelayTime;
  UserData.WaitForNrOfCmd                    := _parCfg.Rob.Parameter.WaitForNrOfCmd;
  UserData.WaitAtBlendingZone                := _parCfg.Rob.Parameter.WaitAtBlendingZone;
  UserData.AllowSecSeqWhileSubprogram        := _parCfg.Rob.Parameter.AllowSecSeqWhileSubprogram;
  UserData.AllowDynamicBlending              := _parCfg.Rob.Parameter.AllowDynamicBlending;
  UserData.SyncReaction                      := _parCfg.Rob.Parameter.SyncReaction;
  UserData.SyncDelay                         := _parCfg.Rob.Parameter.SyncDelay;
  UserData.MessageLevel                      := _parcfg.Rob.Parameter.MessageLevel;
  
  // ReadRobotData
  UserData.RCManufacturer                    := AxesGroup.State.RobotData.RCManufacturer; 
  UserData.RCOrderID                         := AxesGroup.State.RobotData.RCOrderID; 
  UserData.RCSerialNumber                    := AxesGroup.State.RobotData.RCSerialNumber;
  UserData.RASerialNumber                    := AxesGroup.State.RobotData.RASerialNumber;
  UserData.RCFirmwareVersion                 := AxesGroup.State.RobotData.RCFirmwareVersion;
  
  UserData.RCInterpreterVersion.MajorVersion := STRING_TO_USINT(MID(AxesGroup.State.RobotData.RCInterpreterVersion, LEN := 1, POS := 1));
  UserData.RCInterpreterVersion.MinorVersion := STRING_TO_USINT(MID(AxesGroup.State.RobotData.RCInterpreterVersion, LEN := 1, POS := 2));
  UserData.RCInterpreterVersion.PatchVersion := STRING_TO_USINT(MID(AxesGroup.State.RobotData.RCInterpreterVersion, LEN := 1, POS := 3));
  
  UserData.AxisJointUsed                     := AxesGroup.State.RobotData.AxisJointUsed;
  UserData.AxisExternalUsed                  := AxesGroup.State.RobotData.AxisExternalUsed;
  UserData.AxisJointUnit                     := AxesGroup.State.RobotData.AxisJointUnit;
  UserData.AxisExternalUnit                  := AxesGroup.State.RobotData.AxisExternalUnit;
  UserData.RCSupportedFunctions              := AxesGroup.State.RobotData.RCSupportedFunctions;
                                             
  UserData.BrakeTestRequired                 := AxesGroup.State.ConfigurationData.BrakeTestRequired;
  UserData.PathAccuracyMode                  := AxesGroup.State.ConfigurationData.PathAccuracyMode;
  UserData.AvoidSingularity                  := AxesGroup.State.ConfigurationData.AvoidSingularity;
  UserData.ConstantVelocitySupported         := AxesGroup.State.ConfigurationData.ConstantVelocitySupported;
  UserData.StepModeExactStopActive           := AxesGroup.State.ConfigurationData.StepModeExactStopActive;
  UserData.StepModeBlendingActive            := AxesGroup.State.ConfigurationData.StepModeBlendingActive;
  UserData.AcceleratingSupported             := AxesGroup.State.ConfigurationData.AcceleratingSupported;
  UserData.DeceleratingSupported             := AxesGroup.State.ConfigurationData.DecceleratingSupported;
                                             
  UserData.Initialized                       := Initialized;
  UserData.Synchronized                      := Synchronized;
                                             
  // Cyclic data                             
  UserData.RCSRCIVersion                     := AxesGroup.Cyclic.RobToPlc.SRCIVersion;
  UserData.IsMoving                          := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.IsMoving;
  UserData.PrimarySequencePaused             := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.PrimarySequencePaused;
  UserData.InPrimaryPos                      := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.InPrimaryPos;
  UserData.SecondarySequenceActive           := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.SecondarySequenceActive;
  UserData.ErrorPending                      := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.ErrorPending;
  UserData.RestartInProgress                 := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.RestartInProgress;
  UserData.Enabled                           := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.Enabled;
  UserData.Idle                              := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.RaSequenceState = RaSequenceState.IDLE;
  UserData.Executing                         := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.RaSequenceState = RaSequenceState.EXECUTING;
  UserData.Interrupted                       := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.RaSequenceState = RaSequenceState.INTERRUPTED;
  UserData.IsBlending                        := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.IsBlending;  
  UserData.OperationMode                     := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.OperationMode;
  UserData.CollisionDetectionEnabled         := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.CollisionDetectedEnabled;
  UserData.CollisionDetected                 := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.CollisionDetected;
  UserData.RestartRequested                  := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.RestartRequested;
  UserData.ActualOverride                    := AxesGroup.Cyclic.RobToPlc.Override;
  UserData.Accelerating                      := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.Accelerating;
  UserData.Decelerating                      := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.Decelerating;
  UserData.ConstantVelocity                  := AxesGroup.Cyclic.RobToPlc.StatusRobotArm.ConstantVelocity;
  
  // Cyclic optional data
  UserData.CartesianPosition                 := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition;
  UserData.ExtCartesianPosition              := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt;  
  UserData.JointPosition                     := AxesGroup.CyclicOptional.RobToPlc.JointPosition;
  UserData.ExtJointPosition                  := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt;
  
  
  {warning 'ToDo: Check where to get the missing informations'}
  
  UserData.ActivateTwoSequences           := FALSE;
  UserData.ReadingCartesianPosition       := FALSE;
  UserData.ReadingExtCartesianPosition    := FALSE;
  UserData.ReadingJointPosition           := FALSE;
  UserData.ReadingExtJointPosition        := FALSE;
  UserData.ToolDataSynchronizing          := FALSE;
  UserData.FrameDataSynchronizing         := FALSE;
  UserData.LoadDataSynchronizing          := FALSE;
  UserData.WorkAreaDataSynchronizing      := FALSE;
  UserData.SWLimitsSynchronizing          := FALSE;
  UserData.DefaultDynamicsSynchronizing   := FALSE;
  UserData.ReferenceDynamicsSynchronizing := FALSE;

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
  IF (( RobotLibraryParameter.ROBOT_IN_DATA_MAX     < 64 ) OR
      ( RobotLibraryParameter.ROBOT_OUT_DATA_MAX    < 64 ))
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
  
  
  // Reset flag for initialization
  IF ( Initialized ) AND ( AxesGroup.Cyclic.RobToPlc.TelegramState <> TelegramState.INITIALIZED)
  THEN
    // Reset initialized flag
    Initialized := FALSE;
    // Set error 
    ErrorID := RobotLibraryErrorIdEnum.ERR_INIT_LOST_UNKNOWN_0x80A2;
  END_IF
  
  
  // Check configuration parameter changed ? 
  CheckParameterChanged(AxesGroup := AxesGroup);

END_METHOD

METHOD OnExecRun : DINT
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup         : AxesGroup;
END_VAR

  // building rising and falling edges
  _enable_R( CLK := Enable);
  _enable_F( CLK := Enable);
  
  IF ( _enable_F.Q)
  THEN
    Reset(AxesGroup := AxesGroup);
  END_IF
  
  
  OnExecRun := RobotLibraryConstants.RUNNING;
  
  CASE _stepCmd OF
    
    00:  IF ( _enable_R.Q )
         THEN
           // Create log entry
           CreateLogMessage ( Timestamp   := SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.INFO,
                              MessageCode := 0,
                              MessageText := 'Robot Task Enabled');
         
           // reset the rising edge
          _enable_R();
           // set busy flag
           Busy := TRUE;
           // set timeout
           SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
           // Reset FastStop       
           AxesGroup.Cyclic.PlcToRob.FastStop := 0;
           // Reset Active command register
           AxesGroup.Acyclic.ActiveCommandRegister.Reset();
         
           // check parameter valid
           IF ( CheckParameterValid(AxesGroup := AxesGroup) )
           THEN
             // take configuration parameter if not yet enabled
            _parCfg := ParCfg;
             // inc step counter
            _stepCmd := _stepCmd + 1; 
           END_IF
         END_IF
       
    01:  CASE AxesGroup.Cyclic.RobToPlc.TelegramState  OF
  
           TelegramState.UNDEFINED : ;
           
           TelegramState.ERROR_161..TelegramState.ERROR_172:
  
             // clear error
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.ACK_ERROR;        
  
           TelegramState.ERROR_173:
  
             // Reset interface including the ARC register on server side
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.RESET;        
             
           TelegramState.READY_TO_RESUME :  
           
             // Resume
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.RESUME;        
           
           TelegramState.READY_FOR_INITIALIZATION: 
  
             // Request initialization
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.INITIALIZE;
             
           TelegramState.INITIALIZED: 
  
             // Reset Telegram Control 
             AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.NONE;
             // set timeout
             SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
             // inc step counter
            _stepCmd := _stepCmd + 1; 
  
         ELSE
           // TelegrammState in error          
           ErrorID := AxesGroup.Cyclic.RobToPlc.TelegramState;
           ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
         END_CASE
  
         // timeout exceeded ? 
         IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
         THEN
           ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
           ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
         END_IF
  
         
    02: IF (( NOT _exchangeConfiguration.Busy  ) AND 
            ( NOT _exchangeConfiguration.Error ))
        THEN
          // set command parameter
         _exchangeConfiguration.ParCmd.LogLevel                           :=  LogLevel; 
         _exchangeConfiguration.ParCmd.WaitAtBlendingZone                 := _parCfg.Rob.Parameter.WaitAtBlendingZone;
         _exchangeConfiguration.ParCmd.AllowSecSeqWhileSubprogram         := _parCfg.Rob.Parameter.AllowSecSeqWhileSubprogram;
         _exchangeConfiguration.ParCmd.AllowDynamicBlending               := _parCfg.Rob.Parameter.AllowDynamicBlending;
         _exchangeConfiguration.ParCmd.DelayTime                          := _parCfg.Rob.Parameter.DelayTime;
         _exchangeConfiguration.ParCmd.WaitForNrOfCmd                     := _parCfg.Rob.Parameter.WaitForNrOfCmd;
         _exchangeConfiguration.ParCmd.LifeSignTimeOut                    :=  TIME_TO_UINT(_parCfg.Com.LifeSignTimeOut);
         _exchangeConfiguration.ParCmd.SyncDelay                          := _parCfg.Rob.Parameter.SyncDelay;
         _exchangeConfiguration.ParCmd.SyncReaction                       := _parCfg.Rob.Parameter.SyncReaction;
         _exchangeConfiguration.ParCmd.DataEnableSync                     := _parCfg.Rob.Parameter.DataEnableSync;
         _exchangeConfiguration.ParCmd.DataInSync.ToolsInSync             :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.FramesInSync            :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.LoadsInSync             :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.WorkAreasInSync         :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.SoftwareLimitsInSync    :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.DefaultDynamicsInSync   :=  FALSE;
         _exchangeConfiguration.ParCmd.DataInSync.ReferenceDynamicsInSync :=  FALSE;         
         
          // start function block
         _exchangeConfiguration.Enable := TRUE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (_exchangeConfiguration.Error)
          THEN
            ErrorID     := _exchangeConfiguration.ErrorID;
            ErrorAddTxt := _exchangeConfiguration.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    
    03: IF (( NOT _exchangeConfiguration.Busy              ) AND
            (     _exchangeConfiguration.ParameterAccepted ))
        THEN     
          // --------------------------------------------------------------------- 
          // !!! ExchangeConfiguration must stay active for the Sync mechanism !!!
          // --------------------------------------------------------------------- 
          // ExchangeConfiguration.Enable := FALSE;  
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (_exchangeConfiguration.Error)
          THEN
            ErrorID     := _exchangeConfiguration.ErrorID;
            ErrorAddTxt := _exchangeConfiguration.ErrorAddTxt;;
          END_IF  
         
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
  
         
    04: IF (( NOT _readRobotData.Busy  ) AND 
            ( NOT _readRobotData.Error )) 
        THEN
          // start function block
         _readRobotData.Execute := TRUE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (_readRobotData.Error)
          THEN
            ErrorID     := _readRobotData.ErrorID;
            ErrorAddTxt := _readRobotData.ErrorAddTxt;;
          END_IF  
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
      
    
    05: IF (( NOT _readRobotData.Busy  ) AND
            (     _readRobotData.Done  ))
        THEN       
          // start function block
         _readRobotData.Execute := FALSE;
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;
         ELSE
           // check error ? 
           IF (_readRobotData.Error)
           THEN
             ErrorID     := _readRobotData.ErrorID;
             ErrorAddTxt := _readRobotData.ErrorAddTxt;;
           END_IF  
         
           // timeout exceeded ? 
           IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
           THEN
             ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
             ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
           END_IF
         END_IF
  
  
    06: IF (( NOT _readMessages.Busy  ) AND 
            ( NOT _readMessages.Error )) 
        THEN
          // start function block
         _readMessages.Enable := TRUE;
         _readMessages.ParCmd.MsgID := 0;
         _readMessages.ParCmd.MessageLevel := _parCfg.Rob.Parameter.MessageLevel;
          
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;       
        ELSE
          // check error ? 
          IF (_readMessages.Error)
          THEN
            ErrorID     := _readMessages.ErrorID;
            ErrorAddTxt := _readMessages.ErrorAddTxt;;
          END_IF  
          // timeout exceeded ? 
          IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
          THEN
            ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
            ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
          END_IF
        END_IF
    
    07: IF ((     _readMessages.Enabled ) AND
            ( NOT _readMessages.Busy    ) AND
            ( NOT _readMessages.Error   ))
        THEN       
          // --------------------------------------------------------------- 
          // !!! ReadMessages must stay active for the Message mechanism !!!
          // --------------------------------------------------------------- 
          // ReadMessages.Enable := FALSE;  
          // Reset busy flag
          Busy := FALSE;
          // set initialized flag
          Initialized := TRUE;       
          // set timeout
          SetTimeout(PT := _timeoutCmd, rTimer := _timerCmd);
          // inc step counter
         _stepCmd := _stepCmd + 1;
        ELSE
           // check error ? 
           IF (_readMessages.Error)
           THEN
             ErrorID     := _readMessages.ErrorID;
             ErrorAddTxt := _readMessages.ErrorAddTxt;;
           END_IF  
         
           // timeout exceeded ? 
           IF (CheckTimeout(_timerCmd) = RobotLibraryConstants.OK)
           THEN
             ErrorID     := RobotLibraryEvents.ERR_TIMEOUT_CMD;
             ErrorAddTxt := CONCAT('_stepCmd = ' , DINT_TO_STRING(_stepCmd));
           END_IF
         END_IF
  
    08:  // Wait for task disable
         IF ( NOT Enable)
         THEN
           // Reset active command register
           AxesGroup.Acyclic.ActiveCommandRegister.Reset();
           // reset internal variables
           Reset(AxesGroup := AxesGroup);
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
  SysDepMemCpy( pDest := ADR(RecvData.Payload) , pSrc  := ADR(RobotInData), DataLen := RobotLibraryParameter.ROBOT_IN_DATA_MAX +1);
  
  // check new data to receive ? 
  IF ( Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK <> AxesGroup.State.LastACK[0]) {warning 'ToDo: handle 2nd sequence'} 
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
  
  
  AxesGroup.State.LastACK[0] := Telegram.RobToPlc.Sequence[0].Header.SEQ_ACK; 
  AxesGroup.State.LastACK[1] := Telegram.RobToPlc.Sequence[1].Header.SEQ_ACK;

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

  IF (( _parCfg.Com.TelegramLengthRobToPlc >= 1                                           ) AND 
      ( _parCfg.Com.TelegramLengthRobToPlc <= RobotLibraryParameter.ROBOT_IN_DATA_MAX + 1 ))
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
  FOR _seqIdx := 0 TO AxesGroup.State.SequenceCountRecv
  DO
    // check new data to receive ? 
    IF ( Telegram.RobToPlc.Sequence[_seqIdx].Header.SEQ_ACK <> AxesGroup.State.LastACK[_seqIdx]) 
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
    
        FOR _fragIdx := 0 TO AxesGroup.State.FragmentCountRecv[_seqIdx] 
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
                                    Para2       :=  UINT_TO_STRING              (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength),
                                    Para3       :=  DINT_TO_STRING              (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID),
                                    Para4       :=  CMD_MESSAGE_STATE_TO_STRING (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.State),
                                    Para5       :=    FRAGMENT_ACTION_TO_STRING (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction));
          END_IF
        END_FOR    
      END_IF
    END_IF
  END_FOR

END_METHOD

METHOD PRIVATE ParseRecvPayloadSequence
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup        : AxesGroup;
END_VAR

VAR
  /// internal index
 _idx              : DINT;
  /// index for sequence
 _seqIdx           : DINT;
  /// index for fragment
 _fragIdx          : DINT; 
  /// Amount of sequences
 _seqCount         : DINT;
  /// current payload pointer of the current sequence
 _seqPayloadPtr    : UINT; 
END_VAR

  // Check 2nd sequence active ? 
  IF ( RobotLibraryParameter.TWO_SEQUENCES )
  THEN
   _seqCount := _seqCount + 1;
  END_IF
  
  FOR _seqIdx := 0 TO _seqCount
  DO
    // Check 2nd sequence ? -> goto 2nd sequence payload address  
    IF ( _seqIdx = SECONDARY_SEQUENCE )
    THEN
      RecvData.PayloadPtr := CalculateSequencePayloadStartAdr(AxesGroup := AxesGroup, 
                                                              Direction := ComDirection.ROB_TO_PLC,
                                                              Sequence  := SequenceFlag.SECONDARY_SEQUENCE);
  	END_IF
  
    // parste sequence header
    Telegram.RobToPlc.Sequence[_seqIdx].Header.SEQ_ACK       := RecvData.GetUint();
    Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength := RecvData.GetUint();
    
    // check new data available ? 
    IF ( Telegram.RobToPlc.Sequence[_seqIdx].Header.SEQ_ACK <> AxesGroup.State.LastACK[_seqIdx]) 
    THEN
      // Check sequence payload available ? 
      IF (Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength > 0)
      THEN
        // Check sequence payload length is valid ? 
        IF ( Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength > _parCfg.Com.TelegramLengthRobToPlc )
        THEN 
          // Create log entry for payload not valid 
          CreateLogMessagePara2 ( Timestamp   := SystemTime,
                                  MessageType := MessageType.CMD,
                                  Severity    := Severity.DEBUG,
                                  MessageCode := 0,
                                  MessageText := 'Invalid sequence payload length, Sequence = {1}, PayloadLength = {2} ',
                                  Para1       :=  DINT_TO_STRING(_seqIdx),
                                  Para2       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength));
                                  RETURN;
        ELSE
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
        END_IF
      
        // processing sequence payload                                  
        WHILE ( _seqPayloadPtr < Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength )
        DO                        
          // parse header
          Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID          := RecvData.GetUint();
          Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.Reserve        := RecvData.GetByte();
          Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction := RecvData.GetByte();
          Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer := RecvData.GetUint();
          Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength  := RecvData.GetUint();
         
          // add header size to payload pointer 
         _seqPayloadPtr := _seqPayloadPtr + SIZEOF(Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header);
          
          // Check fragment payload available ? 
          IF (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > 0)
          THEN
            // Check fragment payload length is valid ? 
            IF ( Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength > _parCfg.Com.TelegramLengthRobToPlc )
            THEN 
              // Create log entry for payload not valid 
              CreateLogMessagePara2 ( Timestamp   := SystemTime,
                                      MessageType := MessageType.CMD,
                                      Severity    := Severity.DEBUG,
                                      MessageCode := 0,
                                      MessageText := 'Invalid fragment payload length, Sequence = {1}, PayloadLength = {2} ',
                                      Para1       :=  DINT_TO_STRING(_seqIdx),
                                      Para2       :=  UINT_TO_STRING(Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength));
                                      RETURN;
            END_IF
          
            // Fill Response payload
            FOR _idx := Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadPointer TO Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength -1
            DO
              Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[_idx] := RecvData.GetByte();
              // inc payload pointer
             _seqPayloadPtr := _seqPayloadPtr + SIZEOF(BYTE);
            END_FOR
            
            // Add Response to ACR
            AxesGroup.Acyclic.ActiveCommandRegister.AddRsp(Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx]);
          
            // Only for debugging - header is part of the payload itself
            Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.State                 :=      GetHalfeByteLo( Value :=  Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[0]);
            Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.ParSeq                :=      GetHalfeByteHi( Value :=  Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[0]);
            Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.AlarmMessageSeverity  :=        BYTE_TO_SINT(           Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[1]);
            Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.AlarmMessageCode      :=  CombineBytesToUint( HiByte := Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[2],
                                                                                                                                LoByte := Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Payload[3]);
            // Create log entry
            CreateLogMessagePara5 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.DEBUG,
                                    MessageCode := 0,
                                    MessageText := 'RecvData: received Fragment [{1}] with PayloadLength = {2}, CmdID <{3}> , CmdState: {4}, Fragment-Action Bits: {5}',
                                    Para1       :=  DINT_TO_STRING(_seqIdx),
                                    Para2       :=  UINT_TO_STRING              (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.PayloadLength),
                                    Para3       :=  DINT_TO_STRING              (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.CmdID),
                                    Para4       :=  CMD_MESSAGE_STATE_TO_STRING (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Command.Header.State),
                                    Para5       :=    FRAGMENT_ACTION_TO_STRING (Telegram.RobToPlc.Sequence[_seqIdx].Fragment[_fragIdx].Header.FragmentAction));
          END_IF
          
          // Check still payload left ? -> goto next fragment  
          IF ( _seqPayloadPtr < Telegram.RobToPlc.Sequence[_seqIdx].Header.PayloadLength )
          THEN
           _fragIdx := _fragIdx + 1;        
          END_IF
          
          // Check fragment index limit reached ? 
          IF ( _fragIdx > RobotLibraryParameter.FRAGMENT_MAX ) 
          THEN 
            // Create log entry
            CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.DEBUG,
                                    MessageCode := 0,
                                    MessageText := 'Fragment index out of range, _fragIdx = {1} ',
                                    Para1       :=  DINT_TO_STRING(_fragIdx));
                                    RETURN;
          END_IF        
        END_WHILE    
      END_IF
    END_IF    
  END_FOR

END_METHOD

METHOD Reset
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup;  
END_VAR

  // reset flags
  Busy              := FALSE;
  Initialized       := FALSE;
  Synchronized      := FALSE;
  Error             := FALSE;
  ErrorID           := 0;
  WarningID         := 0;
  InfoID            := 0;  
  
  // Reset internal functon blocks
  _exchangeConfiguration      .Enable  := FALSE;
  _readRobotData              .Execute := FALSE;
  _readMessages               .Enable  := FALSE;  
  _readToolData               .Execute := FALSE;  
  _readFrameData              .Execute := FALSE;  
  _readLoadData               .Execute := FALSE;  
  _readWorkArea               .Execute := FALSE;  
  _readRobotSWLimits          .Execute := FALSE;  
  _readRobotDefaultDynamics   .Execute := FALSE;  
  _readRobotReferenceDynamics .Execute := FALSE;  
  _writeToolData              .Execute := FALSE;   
  _writeFrameData             .Execute := FALSE;   
  _writeLoadData              .Execute := FALSE;   
  _writeWorkArea              .Execute := FALSE;   
  _writeRobotSWLimits         .Execute := FALSE;   
  _writeRobotDefaultDynamics  .Execute := FALSE;   
  _writeRobotReferenceDynamics.Execute := FALSE;   
  
  // Set Client error to force server error
  AxesGroup.Cyclic.PlcToRob.Control := ControlHalfByte.CLIENT_ERROR;
  
  // Reset active command register
  AxesGroup.Acyclic.ActiveCommandRegister.Reset();
        
  // reset step counter
  _stepCmd := 0;

END_METHOD

