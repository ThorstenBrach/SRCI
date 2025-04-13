{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UserData                                       
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
TYPE UserData :
STRUCT
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for tool data 
  EnableSyncTool                 : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for frame data
  EnableSyncFrame                : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for load data
  EnableSyncLoad                 : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for work area data
  EnableSyncWorkArea             : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for software limits
  EnableSyncSWLimits             : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for default dynamics
  EnableSyncDefaultDynamics      : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for reference dynamics
  EnableSyncReferenceDynamics    : BOOL;
  /// Set TRUE to define two sequences in one Telegram.
  ActivateTwoSequences           : BOOL;
  /// Synchronisation modes  
  SynchronizationModes           : SynchronizationModes;  
  /// Defines waiting time [ms] of RC between receiving a first move command when motion queue is empty and starting the first movement. See also chapter 5.6.8.
  DelayTime                      : UINT; 
  /// Define number of points required to calculate the blending. See also chapter 5.6.8
  WaitForNrOfCmd                 : UINT;
  ///Defines blending behavior for single move commands
  /// • 0 (default): Move to end position :
  ///     Robot moves exactly the target position independently of the selected "BlendingMode"
  /// 
  /// • 1: Wait at blending parameter : 
  ///      Robot stops its movement when the specified blending parameter is reached
  WaitAtBlendingZone             : BOOL;
  /// Allow a sequence switch from primary to secondary while a subprogram called via CallSubprogram (6.5.18) in the sequence is in progress
  AllowSecSeqWhileSubprogram     : BOOL;
  /// Allows blending when CallSubprogram is called in sequence and removed afterwards.
  /// For more information see chapter 6.5.21.
  /// • 0 (default): Dynamic blending is prevented
  /// • 1: Dynamic blending is allowed
  AllowDynamicBlending           : BOOL;
  /// Maximum allowed time [ms] between incrementation of LifeSign before communication error.
  /// • <10 ms: Invalid
  /// • 50 ms: default
  /// See also chapter 5.6.6.2.
  LifeSignTimeOut                : TIME;
  /// Specifies system reaction in case inconsistency of synchronization data is detected according to Table 6-81. For more information refer to chapter 5.6.7.2
  SyncReaction                   : USINT;
  /// Defines a delay time [ms] between detecting an inconsistency of configuration data between server and client an executing the defined SyncReaction.
  /// Always positive.
  /// • Default: 0 ms
  SyncDelay                      : UINT;
  /// Defines up to which level of severity messages will be logged in the RC's server log
  LogLevel                       : LogLevel;
  /// Defines up to which level of severity messages will be transmitted to the PLC’s message buffer
  MessageLevel                   : MessageLevel;
  /// Version of client implementation in format (X.X.X)
  PLCLibraryVersion              : VersionStruct;
  /// RC manufacturer name 
  RCManufacturer                 : STRING(20); 
  /// RC part number 
  RCOrderID                      : STRING(20); 
  /// RC serial number 
  RCSerialNumber                 : STRING(16); 
  /// RA serial number 
  RASerialNumber                 : STRING(16); 
  /// Robot firmware version in manufacturer-specific format 
  RCFirmwareVersion              : STRING(12); 
  /// Version of server implementation in format (X.X.X) 
  RCInterpreterVersion           : VersionStruct;
  /// Version of SRCI specification on which server implementation is based in format (X.X.X)  
  RCSRCIVersion                  : VersionStruct;
  /// TRUE  = Axis used in Robot, FALSE = Axis NOT used. See Table 6-13 for bit assignment.
  AxisJointUsed                  : AxisJointUsed;
  /// TRUE = Axis used by Robot, FALSE = Axis NOT used. See Table 6-13 for bit assignment.
  AxisExternalUsed               : AxisExternalUsed;
  /// TRUE = mm, FALSE = °. See Table 6-13 for bit assignment.
  AxisJointUnit                  : AxisJointUnit;
  /// TRUE = mm, FALSE = °. See Table 6-13 for bit assignment.
  AxisExternalUnit               : AxisExternalUnit;
  /// Interface is initialized and ready to process commands.
  Initialized                    : BOOL;
  /// All synchronization-related configuration data between client and server is synchronized.
  Synchronized                   : BOOL;
  /// ToolData synchronization is activated.
  ToolDataSynchronizing          : BOOL;
  /// FrameData synchronization is activated.
  FrameDataSynchronizing         : BOOL;
  /// LoadData synchronization is activated.
  LoadDataSynchronizing          : BOOL;
  /// WorkAreaData synchronization is activated.
  WorkAreaDataSynchronizing      : BOOL;
  /// SWLimits synchronization is activated.
  SWLimitsSynchronizing          : BOOL;
  /// DefaultDynamics synchronization is activated.
  DefaultDynamicsSynchronizing   : BOOL;
  /// ReferenceDynamics synchronization is activated.
  ReferenceDynamicsSynchronizing : BOOL;
  /// TRUE, when robot’s axes values change due to physical movement of axes. Can only be TRUE in sequence state "Executing". Default: FALSE 
  IsMoving                       : BOOL;
  /// TRUE, when move commands buffered by the primary sequence are currently not processed. Default: FALSE 
  PrimarySequencePaused          : BOOL;
  /// TRUE, when robot is moving in the primary sequence. FALSE, when robot leaves its position by other means than move commands in the primary sequence. Default: FALSE
  InPrimaryPos                   : BOOL;
  /// TRUE, when secondary sequence is active. Default: FALSE
  SecondarySequenceActive        : BOOL;
  /// Shows that an error acknowledgement by the client is necessary. Default: FALSE
  ErrorPending                   : BOOL;
  /// TRUE, when RC is restarting. Default: FALSE
  RestartInProgress              : BOOL;
  /// Signals that a brake test is required in the defined monitoring time (see chapter 6.5.27).
  BrakeTestRequired              : BOOL;
  /// RA power state. Default: FALSE
  Enabled                        : BOOL;
  /// TRUE, while RA sequence states returns Idle. Default: FALSE
  Idle                           : BOOL;
  /// TRUE, while RA sequence states returns Executing. Default: FALSE
  Executing                      : BOOL;
  /// TRUE, while RA sequence states returns Interrupted. Default: FALSE
  Interrupted                    : BOOL;
  /// TRUE, when robot is currently blending between to move commands. Can only be TRUE in sequence state "Executing". Default: FALSE
  IsBlending                     : BOOL;  
  /// Operation Mode (see chapter 5.5.1)
  OperationMode                  : OperationMode;
  /// PathAccuracyMode is active (see chapter 6.5.22) 
  PathAccuracyMode               : BOOL;
  /// AvoidSingularity is active (see chapter 6.5.23) 
  AvoidSingularity               : BOOL;
  /// TRUE, while CollisionDetection is enabled (see chapter 6.5.35) Default: FALSE 
  CollisionDetectionEnabled      : BOOL;
  /// TRUE, when a collision was detected while CollisionDetection is enabled (see chapter 6.5.35) Default: FALSE 
  CollisionDetected              : BOOL;
  /// TRUE, when the RC requests a restart of the RC induced through the functions "WriteRobotSWLimits" (chapter 6.2.16) or "WriteSystemVariable" (chapter 6.5.8) Default: FALSE 
  RestartRequested               : BOOL;
  /// Actual override
  ActualOverride                 : REAL;
  /// StepMode is active and set to ExactStop (see chapter 6.1.3) 
  StepModeExactStopActive        : BOOL;
  /// StepMode is active and set to Blending (see chapter 6.1.3) 
  StepModeBlendingActive         : BOOL;
  /// Cyclic dynamics status bit Accelerating is supported by RC (see chapter 5.5.3.2) 
  AcceleratingSupported          : BOOL;
  /// TRUE, when the robot is currently accelerating Default: FALSE 
  Accelerating                   : BOOL;
  /// Cyclic dynamics status bit Decelerating is supported by RC (see chapter 5.5.3.2) 
  DeceleratingSupported          : BOOL;
  /// TRUE, when the robot is currently decelerating Default: FALSE 
  Decelerating                   : BOOL;
  /// Cyclic dynamics status bit ConstantVelocity is supported by RC (see chapter 5.5.3.2) 
  ConstantVelocitySupported      : BOOL;
  /// TRUE, while the robot velocity is constant Default: FALSE 
  ConstantVelocity               : BOOL;
  /// TRUE, while the CartesianPosition is returned cyclically 
  ReadingCartesianPosition       : BOOL;
  /// TRUE, while the ExtCartesianPosition is returned cyclically 
  ReadingExtCartesianPosition    : BOOL;
  /// TRUE, while the JointPosition is returned cyclically 
  ReadingJointPosition           : BOOL;
  /// TRUE, while the ExtJointPosition is returned cyclically 
  ReadingExtJointPosition        : BOOL;
  /// Cyclically returned, absolute coordinates of current position in selected coordinate systems (see input parameters ToolNo and FrameNo of function ReadActualPositionCyclic 6.1.6)
  CartesianPosition              : RobotCartesianPositionShort;
  /// Cyclically returned, absolute cartesian position of the external axes of the robot in selected coordinate systems (see input parameters ToolNo and FrameNo of function ReadActualPositionCyclic 6.1.6)
  ExtCartesianPosition           : RobotCartesianPositionExt;  
  /// Cyclically returned, absolute position of the robot in Joint position
  JointPosition                  : RobotJointPositionShort;
  /// Cyclically returned, absolute joint position of the external axes of the robot
  ExtJointPosition               : RobotJointPositionExt;
  /// TRUE: Function is supported by RC
  /// FALSE: Function is not supported by RC
  /// See Table 6-14 for bit assignment.
  RCSupportedFunctions           : RCSupportedFunctions;
END_STRUCT
END_TYPE


