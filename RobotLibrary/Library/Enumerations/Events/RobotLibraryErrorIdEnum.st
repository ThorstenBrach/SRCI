{attribute 'qualified_only'}
TYPE RobotLibraryErrorIdEnum :
(
  NO_ERROR := 0,

  {warning 'ToDo: This is an internal error ID, which is not defined in SRCI specification'}
  /// START
  
  /// Program fault : Invalid step
  ERR_INVALID_STEP             := 1,
  /// Program fault : Invalid library parameter
  ERR_INVALID_LIBRARY_PARA     := 2,
  /// Program fault : Invalid axes groups ID
  ERR_INVALID_AXES_GROUP_ID    := 3,

  /// Function is not supported
  ERR_FUNCTION_NOT_SUPPORTED   := 5,
  /// Program fault : Timeout during command execution 
  ERR_TIMEOUT_CMD              := 6,
  /// Parameter fault : Invalid command parameter SyncReaction
  ERR_INVALID_PAR_CMD_SYNC_REACTION  := 7,
  /// Invalid command parameter - see log file for details (LogLevel Error)
  ERR_INVALID_PAR_CMD := 8,             
  /// Synchronisation state prohibits command execution
  ERR_SYNC_STATE_PROHIBITS_COMMAND := 9,
  /// Synchronisation mode is invalid
  ERR_SYNC_MODE_INVALID := 10,     
  /// Client Invalid parameter value - LoadNo not
  /// available on RC
  /// Commands using the parameter "LoadNo"
  ERR_LOADNO_UNAVAILABLE  := 11,   
  /// Client Invalid parameter value - WorkAreaNo outside of
  /// the allowed range -1..254
  /// Commands using the parameter "WorkAreaNo"
  ERR_WORKAREANO_RANGE  := 12,
  /// Client Invalid parameter value - LoadNo not
  /// available on RC
  /// Commands using the parameter "LoadNo"
  ERR_WORKAREANO_UNAVAILABLE  := 13,   
  /// Client Specified TriggerMode not allowed
  /// Commands using the parameter "TriggerMode"
  ERR_TRIGGERMODE_NOT_ALLOWED := 14, 
  /// Client Specified Frame calculation mode not valid
  /// Commands using the parameter "FrameCalculationMode"
  ERR_FRAMECALCULATIONMODE_INVALID := 15,
  
  /// END
  {warning 'ToDo: This is an internal error ID, which is not defined in SRCI specification'}
  
  
  
  
  /// Telegram control does not match the telegram state
  ERR_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE_0xA1 := 16#A1,  
  /// Initialization lost for unknown reason. See message log after reinitializing
  ERR_INIT_LOST_UNKNOWN_0xA2  := 16#A2,
  /// Telegram length does not match the length provided in the communication interface.
  ERR_TELEGRAM_LENGTH_MISMATCH_0xA3 := 16#A3,
  /// Incompatible major SRCI version
  ERR_SRCI_MAJOR_VERSION_INCOMPATIBLE_0xA4 := 16#A4,
  /// Lifesign timeout
  ERR_LIFESIGN_TIMEOUT_0xA5 := 16#A5,
  /// The selected optional cyclic data does not fit in the given telegram size
  ERR_CYCLIC_DATA_TOO_LARGE_0xA6 := 16#A6,
  /// The robot interface was reset after being initialized
  ERR_INTERFACE_WAS_RESET_AFTER_INIT_0xA7 := 16#A7,
  /// Telegram sequence timeout
  ERR_TELEGRAM_SEQ_TIMEOUT_0xA8 := 16#A8,
  /// The telegram number changed after initialization
  ERR_TELEGRAM_NO_CHANGED_AFTER_INIT_0xA9 := 16#A9,
  /// Invalid AxesGroupID
  ERR_AXESGROUP_ID_INVALID_0xAA := 16#AA,
  /// Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERR_TELEGRAM_NUMBER_INVALID_0xAB := 16#AB,
  /// Telegram Number is not supported
  ERR_TELEGRAM_NUMBER_NOT_SUPPORTED_0xAC := 16#AC,
  /// Server Connection to the communication partner was lost
  ERR_SERVER_CONNECTION_LOST_0xAD := 16#AD,
  
  
  /// Table 5-96: Telegram and Initialization State 
  /// Initialization may fail due to several reasons, described in the following table. T he failure is
  /// signaled using the telegram state byte.
 

  /// 7.1 Table "A" – Command ErrorIDs 
  /// If an error related to the execution of a function block occurs, the function block returns an ErrorID
  /// to specify the error. The errors are stored in the PLC message buffer and are displayed on the
  /// function block outputs.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Command name> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing ErrorIDs reported by commands and the
  /// corresponding description.

  /// ------------------------------------------------------
  /// CLIENT ErrorIDs
  /// ------------------------------------------------------

  /// Client Specified Velocity not valid
  /// Commands using the parameter "Velocity"
  ERR_VELOCITY_INVALID  := 16#8401,
  
  /// Client Specified Acceleration not valid
  /// Commands using the parameter "Acceleration"
  ERR_ACCELERATION_INVALID  := 16#8402,
  
  /// Client Specified Deceleration not valid
  /// Commands using the parameter "Deceleration"
  ERR_DECELERATION_INVALID  := 16#8403,
  
  /// Client Specified Jerk not valid
  /// Commands using the parameter "Jerk"
  ERR_JERK_INVALID  := 16#8404,
  
  /// Client Invalid parameter value - ConfigMode Elbow
  /// Commands using the parameter "ConfigMode"
  ERR_CONFIGMODE_ELBOW_INVALID  := 16#8405,
  
  /// Client Invalid parameter value - ConfigMode Shoulder
  /// Commands using the parameter "ConfigMode"
  ERR_CONFIGMODE_SHOULDER_INVALID  := 16#8406,
  
  /// Client Invalid parameter value - ConfigMode Wrist
  /// Commands using the parameter "ConfigMode"
  ERR_CONFIGMODE_WRIST_INVALID  := 16#8407,
  
  /// Client Invalid parameter value - TrajectoryMode
  /// Commands using the parameter "TrajectoryMode"
  ERR_TRAJECTORYMODE_INVALID  := 16#8409,
  
  /// Client Invalid parameter value - Override
  /// Commands using the parameter "Override"
  ERR_OVERRIDE_INVALID  := 16#8410,
  
  /// Client Invalid parameter value - AbortingMode.
  /// Only 0: Buffer / 1: Abort are valid.
  /// Commands using the parameter "AbortingMode"
  ERR_ABORTINGMODE_INVALID  := 16#8411,
  
  /// Client Invalid parameter value - ToolNo outside of
  /// the allowed range -1..254
  /// Commands using the parameter "ToolNo"
  ERR_TOOLNO_RANGE  := 16#8412,
  
  /// Client Invalid parameter value - ToolNo not
  /// available on RC
  /// Commands using the parameter "ToolNo"
  ERR_TOOLNO_UNAVAILABLE  := 16#8413,
  
  /// Client Invalid parameter value - FrameNo outside
  /// of the allowed range -1..254
  /// Commands using the parameter "FrameNo"
  ERR_FRAMENO_RANGE  := 16#8414,
  
  /// Client Invalid parameter value - FrameNo not
  /// available on RC
  /// Commands using the parameter "FrameNo"
  ERR_FRAMENO_UNAVAILABLE  := 16#8415,
  
  /// Client The array specified for AcyclicData exceeds
  /// the supported maximum length of 190 bytes
  /// Command "CallSubprogram"
  ERR_ACYCLICDATA_TOO_LARGE  := 16#8416,
  
  /// Client The array length specified for ReturnAcyclicData
  /// is not sufficient for the returned data. The data has been truncated
  /// Command "CallSubprogram"
  ERR_RETURNACYCLICDATA_TRUNCATED  := 16#8417,
  
  /// Client Invalid parameter value - LoadNo outside of
  /// the allowed range -1..254
  /// All commands
  ERR_LOADNO_RANGE  := 16#8418,
  
  /// Client Specified ProcessingMode not defined
  /// Commands using the parameter "ProcessingMode"
  ERR_PROCESSINGMODE_NOT_DEFINED  := 16#8602,
  
  /// Client Specified ProcessingMode not allowed
  /// Commands using the parameter "ProcessingMode"
  ERR_PROCESSINGMODE_NOT_ALLOWED  := 16#8603,
  
  /// Client Specified Emitter ID not allowed
  /// Commands using the parameter "EmitterID"
  ERR_EMITTERID_NOT_ALLOWED := 16#8604,
  
  /// Client Specified Listener ID not allowed
  /// Commands using the parameter "ListenerID"
  ERR_LISTENERID_NOT_ALLOWED   := 16#8605,
  
  /// Client ProcessingMode or SequenceFlag changed during execution
  /// Commands using the parameter "ProcessingMode" or "SequenceFlag"
  ERR_PROCSEQFLAG_CHANGED  := 16#8609,
  
  /// Client Commands are not Enabled (First Robot must be initialized)
  /// All commands
  ERR_COMMANDS_NOT_ENABLED  := 16#8612,
  
  /// Client Error received from robot without error ID
  /// All commands
  ERR_ROBOT_ERROR_NO_ID  := 16#8613,
  
  /// Client AxesGroup changed during execution
  /// All commands
  ERR_AXESGROUP_CHANGED  := 16#8614,
  
  /// Client Specified SEQ Flag not allowed
  /// Commands using the parameter "SequenceFlag"
  ERR_SEQFLAG_NOT_ALLOWED  := 16#8616,
  
  /// Client AxesGroup cleared during execution
  /// All commands
  ERR_AXESGROUP_CLEARED  := 16#8617,
  
  /// Client No free ACR entry available
  /// All commands
  ERR_NO_FREE_ACR_ENTRY  := 16#8618,
  
  /// Client Sequence flag must be 0 in the selected ProcessingMode
  /// Commands using the parameter "ProcessingMode" or "SequenceFlag"
  ERR_SEQFLAG_INVALID_IN_PROC_MODE  := 16#8625,
  
  /// Client Specified Listener ID must be > 0 for selected trigger based ProcessingMode
  /// Commands using the parameter "ListenerID"
  ERR_LISTENERID_MUST_BE_GREATER_THAN_ZERO  := 16#8626,
  
  /// Client Specified Emitter ID must be 0
  /// Commands using the parameter "EmitterID"
  ERR_EMITTERID_MUST_BE_ZERO  := 16#8627,
  
  /// Client Specified Listener ID must be a positive value (>= 0)
  /// Commands using the parameter "ListenerID"
  ERR_LISTENERID_MUST_BE_POSITIVE  := 16#8635,


  /// ------------------------------------------------------
  /// SERVER ErrorIDs
  /// ------------------------------------------------------
  
  /// Server Continue not possible - robot is not enabled
  /// Command "GroupContinue"
  ERROR_CONTINUE_NOT_POSSIBLE_BY_NOT_ENABLED := 16#8C01,
  
  /// Server Continue not possible - robot is not inPrimaryPosition
  /// Command "GroupContinue"
  ERROR_CONTINUE_NOT_POSSIBLE_BY_NOT_IN_PRIMARY_POS := 16#8C02,
  
  /// Server Robot disabled
  /// Command "EnableRobot"
  ERR_ROBOT_DISABLED  := 16#8C03,
  /// Server Robot disabled due to an error
  /// Command "EnableRobot"
  ERR_ROBOT_DISABLED_BY_ERROR  := 16#8C04,

  /// Server Not all mandatory commands have been called yet
  /// Command "EnableRobot"
  ERR_MANDATORY_CMDS_MISSING  := 16#8C05,

  /// Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies enabling in this state
  /// Command "EnableRobot"
  ERR_RI_NOT_SYNCHRONIZED  := 16#8C06,

  /// Server Limit exceeded. Move closer to return position
  /// Command "ReturnToPrimary"
  ERR_LIMIT_EXCEEDED_RETURN_POS  := 16#8C07,

  /// Server Invalid parameter value - Must switch to T1Ext when changing between AutoExt and T2Ext
  /// Command "SetOperationMode"
  ERR_SET_OPMODE_T1EXT_REQUIRED  := 16#8C08,

  /// Server Cannot write to a dynamic frame (frame used by e.g. conveyor tracking)
  /// Command "WriteFrameData"
  ERR_WRITE_DYNAMIC_FRAME  := 16#8C09,

  /// Server Continue not possible in manual operation mode
  /// Command "GroupContinue"
  ERR_CONTINUE_NOT_POSSIBLE_BY_MANUAL_MODE  := 16#8C10,

  /// Server It is not allowed to reference a frame which already references another frame
  /// Command "WriteFrame"
  ERR_FRAME_REFERENCING_INVALID  := 16#8C12,

  /// Server The referenced Frame is invalid, dynamic (frame used by e.g. conveyor tracking) or does not exist
  /// Command "WriteFrame"
  ERR_FRAME_INVALID  := 16#8C13,

  /// Server Currently used tool ID differs from the tool ID of the target position
  /// Command "ReturnToPrimary"
  ERR_TOOLID_DIFFERS_TARGET  := 16#8C14,

  /// Server Writing a Frame during an active movement is not supported by this RC
  /// Command "WriteFrame"
  ERR_WRITE_FRAME_DURING_MOVE  := 16#8C15,

  /// Server Writing a Tool during an active movement is not supported by this RC
  /// Command "WriteToolData"
  ERR_WRITE_TOOL_DURING_MOVE  := 16#8C16,

  /// Server Writing a Load during an active movement is not supported by this RC
  /// Command "WriteLoadData"
  ERR_WRITE_LOAD_DURING_MOVE  := 16#8C17,

  /// Server ManualStep is not allowed in Automatic External
  /// Command "EnableRobot"
  ERR_MANUAL_STEP_NOT_ALLOWED  := 16#8C20,

  /// Server ManualStep is only allowed when StepMode is active
  /// Command "EnableRobot"
  ERR_MANUAL_STEP_ONLY_IN_STEP_MODE_ALLOWED  := 16#8C21,

  /// Server The current ToolData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_TOOLDATA_DIFFERS  := 16#8C22,

  /// Server The current LoadData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_LOADDATA_DIFFERS := 16#8C23,

  /// Server The current FrameData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_FRAMEDATA_DIFFERS := 16#8C24,

  /// Server The current reference FrameData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_REF_FRAMEDATA_CHANGED  := 16#8C25,

  /// Server The ToolNo differs from the one in the return position. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_TOOLNO_DIFFERS_TARGET  := 16#8C26,

  /// Server The FrameNo differs from the one in the return position. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERR_FRAMENO_DIFFERS_TARGET  := 16#8C27,

  /// Server Continue is not possible while the Robot is interrupting or stopping.
  /// Command "GroupContinue"
  ERR_CONTINUE_WHILE_STOPPING  := 16#8C28,

  /// Server Software limits could not be set because values were specified for non-existing axes
  /// Command "WriteSWLimits"
  ERR_SOFTWARE_LIMITS_FOR_NON_EXISTING_AXIS  := 16#8C29,

  /// Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies continue in this state
  /// Command "GroupContinue"
  ERR_RI_NOT_SYNCHRONIZED_CONTINUE_DENIED  := 16#8C30,

  /// Server Enable switch must be active to enable the robot
  /// Command "EnableRobot"
  ERR_ENABLE_SWITCH_REQUIRED  := 16#8C31,

  /// Server Manual step sent while robot not enabled
  /// Command "EnableRobot"
  ERR_MANUAL_STEP_WHILE_DISABLED  := 16#8C32,

  /// Server Jog not possible during active movement
  /// Command "GroupJog"
  ERR_JOG_NOT_ALLOWED_DURING_MOVE  := 16#8C33,

  /// Server Target position was commanded for an external axis which does not exist
  /// All move commands
  ERR_TARGET_POS_FOR_NON_EXISTING_AXIS  := 16#8C34,

  /// Server Jog of axis is not possible. Axis does not exist
  /// Command "GroupJog"
  ERR_JOG_AXIS_NOT_EXIST  := 16#8C35,

  /// Server Incremental jog is only possible in one axis of rotation
  /// Command "GroupJog"
  ERR_INC_JOG_ONE_AXIS_ONLY  := 16#8C36,

  /// Server A program for the supplied JobID does not exist.
  /// Commands: "CallSubprogram", "StopSubprogram"
  ERR_JOBID_NOT_EXIST  := 16#8C37,

  /// Server A program including motion commands is only allowed to be executed in a sequence buffer
  /// Command "CallSubprogram"
  ERR_ONLY_ALLOWED_IN_SEQ_BUFFER  := 16#8C38,

  /// Server A program with the same number is already running. Multiple instances are not supported
  /// Command "CallSubprogram"
  ERR_JOB_ALREADY_RUNNING  := 16#8C39,

  /// Server Changing the JobID in PM 3 during runtime of this CMD is not supported.
  /// Command "CallSubprogram"
  ERR_JOBID_CHANGE_PM3_NOT_ALLOWED  := 16#8C42,

  /// Server Continue is not possible while the robot is stopping due to GroupInterrupt, GroupStop, SetSequence, or GroupJog
  /// Command "GroupContinue"
  ERR_CONTINUE_DURING_STOPPING  := 16#8C43,

  /// Server GroupJog motion was stopped due to the release of the enable switch.
  /// Command "GroupJog"
  ERR_JOG_STOPPED_BY_ENABLE_RELEASED  := 16#8C52,

  /// Server Setting the limits is not possible because the current robot position is currently outside of those limits.
  /// Command "WriteSWLimits"
  ERR_SWLIMITS_NOT_ALLOWED_ROBOT_IS_OUTSIDE  := 16#8C53,

  /// Server Setting the limits is not possible while a motion is active.
  /// Command "WriteSWLimits"
  ERR_SWLIMITS_NOT_ALLOWED_DURING_MOVE  := 16#8C54,

  /// Server Change of operation mode by the PLC not possible. The RC must be in an "External" operation mode
  /// Command "SetOperationMode"
  ERR_OPMODE_CHANGE_NOT_POSSIBLE_BY_PLC  := 16#8C56,

  /// Server Auxpoint must not be identical to start or end position of the motion
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_AUXPOINT_IDENTICAL_WITH_OTHER_POS  := 16#8C57,

  /// Server Auxpoint invalid
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_AUXPOINT_INVALID  := 16#8C58,

  /// Server Supplied positions must not be identical or at a larger distance apart
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_CALC_NOT_POSSIBLE_BY_POS := 16#8C59,

  /// Server Calculation not possible with the given parameters
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_CALC_NOT_POSSIBLE_BY_PARA  := 16#8C60,

  /// Server Positions must not be on one line
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_CALC_NOT_POSSIBLE_BY_POS_ON_LINE := 16#8C61,

  /// Server No solution found for the given CartesianPosition
  /// Command "CalculateInverseKinematic"
  ERR_INV_KINEMATIC_NO_SOLUTION := 16#8C62,

  /// Server Solution is outside of the hardware limits
  /// Commands: "CalculateInverseKinematic", "CalculateForwardKinematic"
  ERR_INV_KINEMATIC_SOLUTION_OUTSIDE_SWLIMITS := 16#8C63,

  /// Server The selected parameter is write protected and can thus not be changed
  /// Command "WriteSystemVariable"
  ERR_PARAM_WRITE_PROTECTED  := 16#8C64,

  /// Server Number of received positions exceeds the maximum expected number (index out of range)
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_POS_INDEX_OUT_OF_RANGE  := 16#8C65,

  /// Server Number of received positions does not correspond to the required number for the selected mode
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_POS_INDEX_MISMATCH  := 16#8C66,

  /// Server Invalid parameter value - AccelerationRate
  /// Commands using the parameter "AccelerationRate"
  ERR_INVALID_PARAM_ACCELERATION_RATE := 16#8D01,

  /// Server Invalid parameter value - BlendingMode
  /// Commands using the parameter "BlendingMode"
  ERR_INVALID_PARAM_BLENDING_MODE := 16#8D03,

  /// Server Invalid parameter value - BlendingParameter
  /// Commands using the parameter "BlendingParameter"
  ERR_INVALID_PARAM_BLENDING_PARA  := 16#8D04,

  /// Server Invalid parameter value - ConfigMode Elbow
  /// Commands using the parameter "ConfigMode"
  ERR_INVALID_PARAM_CONFIGMODE_ELBOW := 16#8D05,

  /// Server Invalid parameter value - DecelerationRate
  /// Commands using the parameter "DecelerationRate"
  ERR_INVALID_PARAM_DECELERATION_RATE := 16#8D06,

  /// Server Invalid parameter value - No value greater than zero
  /// Commands: "WriteDefaultDynamics", "WriteReferenceDynamics"
  ERR_INVALID_PARAM_VALUE_ZERO := 16#8D07,

  /// Server Invalid parameter value - FrameNo
  /// Commands using the parameter "FrameNo"
  ERR_INVALID_PARAM_FRAMENO := 16#8D08,

  /// Server Invalid parameter value - IncrementalRotation
  /// Command "GroupJog"
  ERR_INVALID_PARAM_INC_ROTATION  := 16#8D09,

  /// Server Invalid parameter value - IncrementalTranslation
  /// Command "GroupJog"
  ERR_INVALID_PARAM_INC_TRANSLATION := 16#8D10,

  /// Server Invalid parameter value - JerkRate
  /// Commands using the parameter "JerkRate"
  ERR_INVALID_PARAM_JERK_RATE := 16#8D11,

  /// Server Invalid parameter value - Control Positive and negative jog direction was active at the same time
  /// Command "GroupJog"
  ERR_INVALID_PARAM_JOG_POS_AND_JOG_NEG := 16#8D12,

  /// Server Invalid parameter value - JointPosition
  /// Commands using the parameter "JointPosition"
  ERR_INVALID_PARAM_JOINT_POS := 16#8D13,

  /// Server Invalid parameter value - LifesignTimeout
  /// Command "ExchangeConfiguration"
  ERR_INVALID_PARAM_LIFE_SIGN_TIMEOUT := 16#8D14,

  /// Server Invalid parameter value - SoftwareLimits all values must not be zero
  /// Command "WriteRobotSWLimits"
  ERR_INVALID_PARAM_SWLIMITS := 16#8D15,

  /// Server Invalid parameter value - LimitValues
  /// Command "WriteRobotSWLimits"
  ERR_INVALID_PARAM_LIMITVALUES := 16#8D16,

  /// Server Invalid parameter value - LoadNo
  /// Commands using the parameter "LoadNo"
  ERR_INVALID_PARAM_LOADNO := 16#8D17,

  /// Server Invalid parameter value - LogLevel
  /// Command "ExchangeConfiguration"
  ERR_INVALID_PARAM_LOG_LEVEL := 16#8D18,

  /// Server Invalid parameter value - Mode
  /// Commands using the parameter "Mode"
  ERR_INVALID_PARAM_MODE := 16#8D21,

  /// Server Invalid parameter value - OriMode
  /// Commands using the parameter "OriMode"
  ERR_INVALID_PARAM_ORI_MODE := 16#8D22,

  /// Server Invalid parameter value - Override
  /// Commands using the parameter "Override"
  ERR_INVALID_PARAM_OVERRIDE := 16#8D23,

  /// Server Invalid parameter value - Position
  /// Commands using the parameter "Position"
  ERR_INVALID_PARAM_POSITION := 16#8D24,

  /// Server Invalid parameter value - ReferenceDynamics all values less than zero
  /// Command "WriteReferenceDynamics"
  ERR_INVALID_PARAM_REF_DYNAMICS_LESS_THAN_ZERO := 16#8D25,

  /// Server Invalid parameter value - Acceleration
  /// Commands using the parameter "Acceleration"
  ERR_INVALID_PARAM_ACCELERATION := 16#8D26,

  /// Server Invalid parameter value - Deceleration
  /// Commands using the parameter "Deceleration"
  ERR_INVALID_PARAM_DECELERATION := 16#8D27,

  /// Server Invalid parameter value - Jerk
  /// Commands using the parameter "Jerk"
  ERR_INVALID_PARAM_JERK := 16#8D28,

  /// Server Invalid parameter value - Velocity
  /// Commands using the parameter "Velocity"
  ERR_INVALID_PARAM_VELOCITY := 16#8D29,

  /// Server Invalid parameter value - ReturnMode
  /// Command "ReturnToPrimary"
  ERR_INVALID_PARAM_RETURN_MODE := 16#8D30,

  /// Server Invalid parameter value - TargetSequence
  /// Command "SetSequence"
  ERR_INVALID_PARAM_TARGET_SEQUENCE := 16#8D31,

  /// Server Invalid parameter value - OperationMode
  /// Command "SetOperationMode"
  ERR_INVALID_PARAM_OPERATION_MODE := 16#8D32,

  /// Server Invalid parameter value - SyncReaction
  /// Command "LRob_ExchangeConfiguration"
  ERR_INVALID_PARAM_SYNC_REACTION := 16#8D33,

  /// Server Invalid parameter value - Time
  /// Commands using the parameter "Time"
  ERR_INVALID_PARAM_TIME := 16#8D34,

  /// Server Invalid parameter value - ToolNo
  /// Commands using the parameter "ToolNo"
  ERR_INVALID_PARAM_TOOLNO := 16#8D35,

  /// Server Invalid parameter value - TrajectoryMode
  /// Command "ReturnToPrimary"
  ERR_INVALID_PARAM_TRAJECTORY_MODE := 16#8D36,

  /// Server Invalid parameter value - TurnMode
  /// Commands using the parameter "TurnMode"
  ERR_INVALID_PARAM_TURN_MODE := 16#8D37,

  /// Server Invalid parameter value - VelocityRate
  /// Commands using the parameter "VelocityRate"
  ERR_INVALID_PARAM_VELOCITY_MODE := 16#8D38,

  /// Server Invalid parameter value - WaitForNrOfCmd
  /// Command "LRob_ExchangeConfiguration"
  ERR_INVALID_PARAM_WAIT_FOR_NR_OF_CMD := 16#8D39,

  /// Server Invalid parameter value - ConfigMode Shoulder
  /// Commands using the parameter "ConfigMode"
  ERR_INVALID_PARAM_CONFIG_MODE_SHOULDER := 16#8D40,

  /// Server Invalid parameter value - ConfigMode Wrist
  /// Commands using the parameter "ConfigMode"
  ERR_INVALID_PARAM_CONFIG_MODE_WRIST := 16#8D41,

  /// Server Invalid parameter value - StepMode
  /// Commands using the parameter "StepMode"
  ERR_INVALID_PARAM_STEP_MODE := 16#8D42,

  /// Server The supplied StopMode is not valid. Use 0, 1, or 2
  /// Command "StopSubprogram"
  ERR_STEP_MODE_NOT_VALID := 16#8D43,

  /// Server When StopMode 2: (Stop all subprograms) is selected, the TargetID must be -1.
  /// Command "StopSubprogram"
  ERR_STOP_MODE_2_TARGETID_NEG1 := 16#8D44,

  /// Server When StopMode 0: (Stop via JobID) is selected, the TargetID must NOT be -1.
  /// Command "StopSubprogram"
  ERR_STOP_MODE_0_TARGETID_NOT_NEG1 := 16#8D45,

  /// Server When StopMode 1: (Stop via InstanceID) is selected, the TargetID must NOT be -1.
  /// Command "StopSubprogram"
  ERR_STOP_MODE_1_TARGETID_NOT_NEG1  := 16#8D46,

  /// Server Invalid parameter value - Index out of range
  /// All Commands
  ERR_INVALID_PARAM_INDEX_OUT_OF_RANGE := 16#8D47,

  /// Server Invalid parameter value - Same index was used multiple times
  /// Commands: "WriteDigitalOutputs", "WriteIntegers", "WriteReals", "WriteAnalogOutputs", "ReadDigitalInputs", "ReadDigitalOutputs", "ReadIntegers", "ReadReals"
  ERR_INVALID_PARAM_SAME_INDEX_MULTIPLE_TIMES := 16#8D48,

  /// Server Invalid parameter value - Specified mass greater than the maximum RA payload.
  /// Command "WriteLoad"
  ERR_INVALID_PARAM_MASS_EXCEEDS_PAYLOAD  := 16#8D49,

  /// Server Invalid parameter value - At least one index must not be 0 and result in a read/write operation.
  /// Commands: "WriteDigitalOutputs", "WriteIntegers", "WriteReals", "WriteAnalogOutputs", "ReadDigitalInputs", "ReadDigitalOutputs", "ReadIntegers", "ReadReals"
  ERR_INVALID_PARAM_AT_LEAST_ONE_INDEX_REQUIRED  := 16#8D50,

  /// Server Invalid parameter value - MessageLevel must be between 0-28
  /// Command "ReadMessages"
  ERR_INVALID_PARAM_MESSAGE_LEVEL := 16#8D51,

  /// Server Invalid parameter value - CircPlane does not match CircMode
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_INVALID_PARAM_CIRCPLANE_MISMATCH_CIRCMODE := 16#8D61,

  /// Server Invalid parameter value - CircMode outside of the allowed range 0..3
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_INVALID_PARAM_CIRCMODE_OUT_OF_RANGE := 16#8D62,

  /// Server Invalid parameter value - Tolerance must only be used for CircMode 1
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_INVALID_PARAM_TOLERANCE_ONLY_CIRCMODE_1 := 16#8D63,

  /// Server Invalid parameter value - Angle must only be used for CircMode 2
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_INVALID_PARAM_ANGLE_ONLY_CIRCMODE_2 := 16#8D64,

  /// Server Invalid parameter value - PathChoice outside of the allowed range 0..1
  /// Commands
  ERR_INVALID_PARAM_PATH_CHOICE_OUT_OF_RANGE := 16#8D65,

  /// Server Invalid parameter value - Mode outside of the allowed range 0..4
  /// Command "ShiftPosition"
  ERR_INVALID_PARAM_SHIFT_MODE_OUT_OF_RANGE := 16#8D66,

  /// Server Invalid parameter value - RotationAngle only allowed in mode 3
  /// Command "ShiftPosition"
  ERR_INVALID_PARAM_ROTATION_ANGLE_ONLY_MODE_3 := 16#8D67,

  /// Server Invalid parameter value - TransformationParameter_2 value does not match the selected mode
  /// Command "ShiftPosition"
  ERR_INVALID_PARAM_TRANSFORMATION_PARAM_2_INVALID := 16#8D68,

  /// Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_INVALID_PARAM_TOOLNO_OUT_OF_RANGE := 16#8D69,

  /// Server Invalid parameter value - FrameNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERR_INVALID_PARAM_FRAMENO_OUT_OF_RANGE := 16#8D70,

  /// Server Invalid parameter value - TargetToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERR_INVALID_PARAM_TARGET_TOOLNO_OUT_OF_RANGE := 16#8D71,

  /// Server Invalid parameter value - TargetFrameNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERR_INVALID_PARAM_TARGET_FRAMENO_OUT_OF_RANGE := 16#8D72,

  /// Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERR_INVALID_PARAM_ERR_TOOLNO_INVALID := 16#8D73,

  /// Server Invalid parameter value - ParameterID does not exist on the RC
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERR_INVALID_PARAM_PARAMETER_ID_INVALID := 16#8D74,

  /// Server Invalid parameter value - SubParameterID does not exist on the RC for the supplied ParameterID
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERR_INVALID_PARAM_SUB_PARAMETER_ID_INVALID := 16#8D75,

  /// Server Invalid parameter value - SubParameterID must be 0 for a parameter without subparameters
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERR_INVALID_PARAM_SUB_PARAMETER_MUST_BE_ZERO := 16#8D76,

  /// Server Invalid parameter value - SubParameterID must not be 0 for a parameter with subparameters
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERR_INVALID_PARAM_SUB_PARAMETER_MUST_NOT_BE_ZERO := 16#8D77,

  /// Server Invalid parameter value - DataType outside of the allowed range 1..13
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_TYPE_OUT_OF_RANGE := 16#8D78,

  /// Server Invalid parameter value - DataType does not match the data type of the parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_TYPE_MISMATCH := 16#8D79,

  /// Server Invalid parameter value - Data_0 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_0_INVALID := 16#8D80,

  /// Server Invalid parameter value - Data_1 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_1_INVALID := 16#8D81,

  /// Server Invalid parameter value - Data_2 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_2_INVALID := 16#8D82,

  /// Server Invalid parameter value - Data_3 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_3_INVALID := 16#8D83,

  /// Server Invalid parameter value - Data_4 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_4_INVALID := 16#8D84,

  /// Server Invalid parameter value - Data_5 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_5_INVALID := 16#8D85,

  /// Server Invalid parameter value - Data_6 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_6_INVALID := 16#8D86,

  /// Server Invalid parameter value - Data_7 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERR_INVALID_PARAM_DATA_7_INVALID := 16#8D87,

  /// Server Invalid parameter value - ReferenceFrame outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateFrame"
  ERR_INVALID_PARAM_REFERENCE_FRAME_OUT_OF_RANGE := 16#8D88,

  /// Server Optional parameter value not supported - DecelerationRate
  /// Commands using the parameter "DecelerationRate"
  ERR_OPTIONAL_PARAM_DECELERATION_RATE_NOT_SUPPORTED := 16#8E03,

  /// Server Optional parameter value not supported - JerkRate
  /// Commands using the parameter "JerkRate"
  ERR_OPTIONAL_PARAM_JERK_RATE_NOT_SUPPORTED := 16#8E04,

  /// Server Optional parameter value not supported - BlendingMode
  /// Commands using the parameter "BlendingMode"
  ERR_OPTIONAL_PARAM_BLENDING_MODE_NOT_SUPPORTED := 16#8E05,

  /// Server Optional parameter value not supported - Time
  /// Commands using the parameter "Time"
  ERR_OPTIONAL_PARAM_TIME_NOT_SUPPORTED := 16#8E06,

  /// Server Optional parameter value not supported - Position
  /// Commands using the parameter "Position"
  ERR_OPTIONAL_PARAM_POSITION_NOT_SUPPORTED := 16#8E07,

  /// Server Optional parameter value not supported - OriMode
  /// Commands using the parameter "OriMode"
  ERR_OPTIONAL_PARAM_ORI_MODE_NOT_SUPPORTED := 16#8E08,

  /// Server Optional parameter value not supported - ConfigMode
  /// Commands using the parameter "ConfigMode"
  ERR_OPTIONAL_PARAM_CONFIG_MODE_NOT_SUPPORTED := 16#8E09,

  /// Server Optional parameter value not supported - TurnMode
  /// Commands using the parameter "TurnMode"
  ERR_OPTIONAL_PARAM_TURN_MODE_NOT_SUPPORTED := 16#8E10,

  /// Server Optional parameter value not supported - TrajectoryMode
  /// Command "ReturnToPrimary"
  ERR_OPTIONAL_PARAM_TRAJECTORY_MODE_NOT_SUPPORTED := 16#8E11,

  /// Server Optional parameter value not supported - OperationMode
  /// Command "SetOperationMode"
  ERR_OPTIONAL_PARAM_OPERATION_MODE_NOT_SUPPORTED := 16#8E12,

  /// Server Optional parameter value not supported - IncrementalRotation
  /// Command "GroupJog"
  ERR_OPTIONAL_PARAM_INC_ROTATION_NOT_SUPPORTED := 16#8E13,

  /// Server Optional parameter value not supported - IncrementalTranslation
  /// Command "GroupJog"
  ERR_OPTIONAL_PARAM_INC_TRANSLATION_NOT_SUPPORTED := 16#8E14,

  /// Server Optional parameter value not supported - StepMode Exact Stop
  /// Command "EnableRobot"
  ERR_OPTIONAL_PARAM_STEP_MODE_EXACT_STOP_NOT_SUPPORTED := 16#8E16,

  /// Server Optional parameter value not supported - StepMode Blending
  /// Command "EnableRobot"
  ERR_OPTIONAL_PARAM_STEP_MODE_BLENDING_NOT_SUPPORTED := 16#8E17,

  /// Server Optional parameter value not supported - ModifiedConvention
  /// Command "ReadDHParameter"
  ERR_OPTIONAL_PARAM_MODIFIED_CONVENTION_NOT_SUPPORTED := 16#8E20,

  /// Server Optional parameter value not supported - WaitAtBlendingPoint
  /// Command "ExchangeConfig"
  ERR_OPTIONAL_PARAM_WAIT_AT_BLENDING_POINT_NOT_SUPPORTED := 16#8E21,

  /// Server Optional parameter not supported - Angle
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_OPTIONAL_PARAM_ANGLE_NOT_SUPPORTED := 16#8E23,

  /// Server Optional parameter not supported - PathChoice
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_OPTIONAL_PARAM_PATH_CHOICE_NOT_SUPPORTED := 16#8E24,

  /// Server Optional parameter not supported - Tolerance
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERR_OPTIONAL_PARAM_TOLERANCE_NOT_SUPPORTED := 16#8E25,

  /// Server Optional parameter not supported - TransformationParameter_2
  /// Command "ShiftPosition"
  ERR_OPTIONAL_PARAM_TRANSFORMATION_PARAM2_NOT_SUPPORTED := 16#8E26,

  /// Server Optional parameter not supported - RotationAngle
  /// Command "ShiftPosition"
  ERR_OPTIONAL_PARAM_ROTATION_ANGLE_NOT_SUPPORTED := 16#8E27,

  /// Server Optional parameter value not supported - Mode
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_OPTIONAL_PARAM_VALUE_NOT_SUPPORTED := 16#8E28,

  /// Server Optional parameter not supported - ExternalTCP
  /// Commands: "CalculateTool", "CalculateFrame"
  ERR_OPTIONAL_PARAM_EXTERNAL_TCP_NOT_SUPPORTED := 16#8E29,

  /// Server Optional parameter not supported - RelativePosition
  /// Commands using the parameter "RelativePosition"
  ERR_OPTIONAL_PARAM_RELATIVE_POS_NOT_SUPPORTED := 16#8E30,

  /// Server Specified Emitter ID must not be 0
  /// Commands using the parameter "EmitterID"
  ERR_EMITTER_ID_MUST_NOT_BE_ZERO := 16#8F04,

  /// Server Invalid parameter value - Execution mode
  /// All Commands
  ERR_INVALID_PARAM_EXECUTION_MODE := 16#8F10,

  /// Server Command not implemented
  /// All Commands
  ERR_CMD_NOT_IMPLEMENTED := 16#8F11,

  /// Server Only one instance of this command is allowed
  /// Commands: "EnableRobot", "GroupJog", "ReturnToPrimary", "ExchangeConfig"
  ERR_CMD_ONLY_ONE_INSTANCE_ALLOWED := 16#8F12,

  /// Server Command requires an active interrupt or idle state to be executed
  /// Commands: "GroupJog", "ReturnToPrimary"
  ERR_CMD_REQUIRES_INTERRUPT_OR_IDLE_STATE := 16#8F13,

  /// Server Command cannot be executed during active interrupt
  /// Command "ReturnToPrimary"
  ERR_CMD_NOT_ALLOWED_DURING_ACTIVE_INTERRUPT := 16#8F14,

  /// Server Secondary sequence is blocked by command (e.g. GroupJog, ReturnToPrimary). No other commands may be buffered in secondary sequence
  /// All commands processed in secondary sequence
  ERR_SECONDARY_SEQUENCE_BLOCKED_BY_CMD := 16#8F15,

  /// Server The secondary sequence is not active. Commands may only be buffered in this sequence if it is active
  /// Commands using the parameter "SequenceFlag"
  ERR_SECONDARY_SEQUENCE_NOT_ACTIVE := 16#8F16,

  /// Server Secondary sequence is not empty. The command requires the secondary sequence to be empty
  /// Commands: "GroupJog", "ReturnToPrimary"
  ERR_SECONDARY_SEQUENCE_NOT_EMPTY := 16#8F17,

  /// Server Transaction not possible in the state machine
  /// All commands
  ERR_TRANSACTION_NOT_POSSIBLE_IN_STATE_MACHINE := 16#8F18,

  /// Server Cannot execute command because current operation mode is local.
  /// Commands that are not available in local modes
  ERR_CMD_NOT_POSSIBLE_BY_OP_MODE_LOCAL := 16#8F19,

  /// Server Command type out of range
  /// All commands
  ERR_CMD_TYPE_OUT_OF_RANGE := 16#8F20,

  /// Server Execution of this CMD is not possible while CallSubprogram is in progress in the sequence
  /// Commands: "SetSequence", "GroupJog"
  ERR_CMD_NOT_POSSIBLE_DURING_CALL_SUB_PROGRAM := 16#8F21,

  /// Server Operation not possible. See MessageLog for further information
  /// All commands
  ERR_OPERATION_NOT_POSSIBLE_SEE_LOG := 16#8F36,

  /// Server An RC internal error occurred during execution of this command. Check the message log for additional information
  /// All commands
  ERR_INTERNAL_ERROR_DURING_CMD := 16#8FFF,
  
  /// 7.2 Table "B" – RI ErrorIDs
  /// RI errors can occur on the PLC as well as on the RC. In the event of an RI error on the PLC, the
  /// corresponding ErrorID is written to the PLC message buffer independent of the function call
  /// "ReadMessages". In the event of an RI error on the RC, the ErrorID is transmitted via the function
  /// block "ReadMessages" and is also stored in PLC message buffer.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing "ErrorIDs" reported via RI errors and the
  /// corresponding description.

  /// ------------------------------------------------------
  /// Client ErrorIDs
  /// ------------------------------------------------------

  /// Client Wrong Telegram State (Two Sequences not in both directions active)
  ERR_WRONG_TELEGRAM_STATE  := 16#8001,

  /// Client Acyclic area client to server too small
  ERR_ACYCLIC_AREA_TO_SMALL_PLC_TO_ROB  := 16#8002,

  /// Client Acyclic area server to client too small
  ERR_ACYCLIC_AREA_TO_SMALL_ROB_TO_PLC := 16#8003,

  /// Client Lifesign timeout
  ERR_LIFESIGN_TIMEOUT_0x8005 := 16#8004,

  /// Client Telegram sequence timeout
  ERR_TELEGRAM_SEQ_TIMEOUT_0x8005 := 16#8005,

  /// Client Assigned AxesGroup not valid
  ERR_AXESGROUP_INVALID := 16#8007,

  /// Client Assigned periphery not valid
  ERR_PERIPHERY_INVALID := 16#8008,

  /// Client Invalid state of the robot (more than 1 CMD active)
  ERR_INVALID_ROBOT_STATE := 16#8009,

  /// Client Telegram Number changed after initialization. Reinitialize by disabling and enabling the RobotTask.
  ERR_TELEGRAM_NUMBER_CHANGED_AFTER_INIT  := 16#8013,
    
  /// Client Telegram control does not match the telegram state
  ERR_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE_0x80A1 := 16#80A1,

  /// Client Initialization lost for unknown reason. See message log after reinitializing
  ERR_INIT_LOST_UNKNOWN_0x80A2  := 16#80A2,

  /// Client Telegram length does not match the length provided in the communication interface, or the communication interface is too small.
  ERR_TELEGRAM_LENGTH_MISMATCH_0x80A3  := 16#80A3,

  /// Client Incompatible major SRCI version
  ERR_SRCI_MAJOR_VERSION_INCOMPATIBLE_0x80A4  := 16#80A4,

  /// Client Lifesign timeout
  ERR_LIFESIGN_TIMEOUT_0x80A5 := 16#80A5,

  /// Client The selected optional cyclic data does not fit in the given telegram size
  ERR_CYCLIC_DATA_TOO_LARGE_0x80A6  := 16#80A6,

  /// Client The robot interface was reset after being initialized
  ERR_INTERFACE_WAS_RESET_AFTER_INIT_0x80A7  := 16#80A7,

  /// Client Telegram sequence timeout
  ERR_TELEGRAM_SEQ_TIMEOUT_0x80A8_0x80A8  := 16#80A8,

  /// Client The telegram number changed after initialization
  ERR_TELEGRAM_NO_CHANGED_AFTER_INIT_0x80A9 := 16#80A9,

  /// Client Error: Invalid AxesGroupID
  ERR_AXESGROUP_ID_INVALID_0x80AA  := 16#80AA,

  /// Client Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERR_TELEGRAM_NUMBER_INVALID_0x80AB  := 16#80AB,

  /// Client Telegram Number is not supported
  ERR_TELEGRAM_NUMBER_NOT_SUPPORTED_0x80AC := 16#80AC,

  /// Server The ACR is full. RA is disabled
  ERR_ACR_REGISER_IS_FULL  := 16#8A01,

  /// Server The execution of a mandatory command has been stopped. Exchange config must run for the system to run
  ERR_MANDATORY_CMD_STOPPED  := 16#8A02,

  /// Server Inconsistent data received. Make sure the complete telegram data is sent to RC in one frame.
  ERR_INCONSISTENT_DATA_RECEIVED  := 16#8A03,

  /// Client Connection to the communication partner was lost
  ERR_CONNECTION_LOST  := 16#8AAD,

  /// Client Fatal Error occurred. Reinitialization of Robot_Task is required
  ERR_FATAL_ERROR_REINIT_REQUIRED  := 16#9001,

  /// ------------------------------------------------------
  /// SERVER ErrorIDs
  /// ------------------------------------------------------
  
  /// Server Internal error
  ERR_INTERNAL_ERROR  := 16#9A01,

  /// Server Internal error in deserialize
  ERR_DESERIALIZE_ERROR  := 16#9A02,

  /// Server CMD ID out of range 1.ACR_Length
  ERR_CMD_ID_OUT_OF_RANGE  := 16#9A03,

  /// Server Invalid fragment length
  ERR_FRAGMENT_LENGTH_INVALID := 16#9A04,

  /// Server Command priority or type changed during runtime
  ERR_CMD_PRIORITY_CHANGED := 16#9A05,

  /// Server Tried to reset a non-empty ACR entry
  ERR_TRIED_TO_RESET_NONEMPTY_ACR_REGISTER := 16#9A06,

  /// Server Error: Invalid Sequence payload length (e.g., sequence payload length is specified 999 even if telegram length is only 100.)
  ERR_SEQUENCE_PAYLOAD_INVALID_LENGTH := 16#9A07,

  /// Server Invalid ActionByte
  ERR_ACTION_BYTE_INVALID := 16#9A08,

  /// Server Invalid Command payload length
  ERR_CMD_PAYLOAD_LENGTH_INVALID := 16#9A09,

  /// Server Error: Invalid Command payload pointer (e.g., Out of bounds)
  ERR_CMD_PAYLOAD_POINTER_INVALID := 16#9A10,

  /// Server Illegal Execution Mode change
  ERR_EXEC_MODE_CHANGE_ILLEGAL := 16#9A14

)WORD;
END_TYPE


