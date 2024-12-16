{attribute 'qualified_only'}
TYPE RobotLibraryErrorIdEnum :
(
	NO_ERROR := 0,
  
  /// Table 5-96: Telegram and Initialization State 
  /// Initialization may fail due to several reasons, described in the following table. T he failure is
  /// signaled using the telegram state byte.

  /// Telegram control does not match the telegram state
  ERROR_161 := 161,
  /// Initialization lost for unknown reason. See message log after reinitializing
  ERROR_162 := 162,
  /// Telegram length does not match the length provided in the communication interface.
  ERROR_163 := 163,
  /// Incompatible major SRCI version
  ERROR_164 := 164,
  /// Lifesign timeout
  ERROR_165 := 165,
  /// The selected optional cyclic data does not fit in the given telegram size
  ERROR_166 := 166,
  /// The robot interface was reset after being initialized
  ERROR_167 := 167,
  /// Telegram sequence timeout
  ERROR_168 := 168,
  /// The telegram number changed after initialization
  ERROR_169 := 169,
  /// Invalid AxesGroupID
  ERROR_170 := 170,
  /// Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERROR_171 := 171,
  /// Telegram Number is not supported
  ERROR_172 := 172,




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


  /// Client Specified Velocity not valid
  /// Commands using the parameter "Velocity"
  ERROR_TYPE_A_CLIENT_16x8401 := 16#8401,
  
  /// Client Specified Acceleration not valid
  /// Commands using the parameter "Acceleration"
  ERROR_TYPE_A_CLIENT_16x8402 := 16#8402,
  
  /// Client Specified Deceleration not valid
  /// Commands using the parameter "Deceleration"
  ERROR_TYPE_A_CLIENT_16x8403 := 16#8403,
  
  /// Client Specified Jerk not valid
  /// Commands using the parameter "Jerk"
  ERROR_TYPE_A_CLIENT_16x8404 := 16#8404,
  
  /// Client Invalid parameter value - ConfigMode Elbow
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_CLIENT_16x8405 := 16#8405,
  
  /// Client Invalid parameter value - ConfigMode Shoulder
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_CLIENT_16x8406 := 16#8406,
  
  /// Client Invalid parameter value - ConfigMode Wrist
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_CLIENT_16x8407 := 16#8407,
  
  /// Client Invalid parameter value - TrajectoryMode
  /// Commands using the parameter "TrajectoryMode"
  ERROR_TYPE_A_CLIENT_16x8409 := 16#8409,
  
  /// Client Invalid parameter value - Override
  /// Commands using the parameter "Override"
  ERROR_TYPE_A_CLIENT_16x8410 := 16#8410,
  
  /// Client Invalid parameter value - AbortingMode.
  /// Only 0: Buffer / 1: Abort are valid.
  /// Commands using the parameter "AbortingMode"
  ERROR_TYPE_A_CLIENT_16x8411 := 16#8411,
  
  /// Client Invalid parameter value - ToolNo outside of
  /// the allowed range -1..254
  /// Commands using the parameter "ToolNo"
  ERROR_TYPE_A_CLIENT_16x8412 := 16#8412,
  
  /// Client Invalid parameter value - ToolNo not
  /// available on RC
  /// Commands using the parameter "ToolNo"
  ERROR_TYPE_A_CLIENT_16x8413 := 16#8413,
  
  /// Client Invalid parameter value - FrameNo outside
  /// of the allowed range -1..254
  /// Commands using the parameter "FrameNo"
  ERROR_TYPE_A_CLIENT_16x8414 := 16#8414,
  
  /// Client Invalid parameter value - FrameNo not
  /// available on RC
  /// Commands using the parameter "FrameNo"
  ERROR_TYPE_A_CLIENT_16x8415 := 16#8415,
  
  /// Client The array specified for AcyclicData exceeds
  /// the supported maximum length of 190 bytes
  /// Command "CallSubprogram"
  ERROR_TYPE_A_CLIENT_16x8416 := 16#8416,
  
  /// Client The array length specified for ReturnAcyclicData
  /// is not sufficient for the returned data. The data has been truncated
  /// Command "CallSubprogram"
  ERROR_TYPE_A_CLIENT_16x8417 := 16#8417,
  
  /// Client Invalid parameter value - LoadNo outside of
  /// the allowed range -1..254
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8418 := 16#8418,
  
  /// Client Specified ProcessingMode not defined
  /// Commands using the parameter "ProcessingMode"
  ERROR_TYPE_A_CLIENT_16x8602 := 16#8602,
  
  /// Client Specified ProcessingMode not allowed
  /// Commands using the parameter "ProcessingMode"
  ERROR_TYPE_A_CLIENT_16x8603 := 16#8603,
  
  /// Client Specified Emitter ID not allowed
  /// Commands using the parameter "EmitterID"
  ERROR_TYPE_A_CLIENT_16x8604 := 16#8604,
  
  /// Client Specified Listener ID not allowed
  /// Commands using the parameter "ListenerID"
  ERROR_TYPE_A_CLIENT_16x8605 := 16#8605,
  
  /// Client ProcessingMode or SequenceFlag changed during execution
  /// Commands using the parameter "ProcessingMode" or "SequenceFlag"
  ERROR_TYPE_A_CLIENT_16x8609 := 16#8609,
  
  /// Client Commands are not Enabled (First Robot must be initialized)
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8612 := 16#8612,
  
  /// Client Error received from robot without error ID
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8613 := 16#8613,
  
  /// Client AxesGroup changed during execution
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8614 := 16#8614,
  
  /// Client Specified SEQ Flag not allowed
  /// Commands using the parameter "SequenceFlag"
  ERROR_TYPE_A_CLIENT_16x8616 := 16#8616,
  
  /// Client AxesGroup cleared during execution
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8617 := 16#8617,
  
  /// Client No free ACR entry available
  /// All commands
  ERROR_TYPE_A_CLIENT_16x8618 := 16#8618,
  
  /// Client Sequence flag must be 0 in the selected ProcessingMode
  /// Commands using the parameter "ProcessingMode" or "SequenceFlag"
  ERROR_TYPE_A_CLIENT_16x8625 := 16#8625,
  
  /// Client Specified Listener ID must be > 0 for selected trigger based ProcessingMode
  /// Commands using the parameter "ListenerID"
  ERROR_TYPE_A_CLIENT_16x8626 := 16#8626,
  
  /// Client Specified Emitter ID must be 0
  /// Commands using the parameter "EmitterID"
  ERROR_TYPE_A_CLIENT_16x8627 := 16#8627,
  
  /// Client Specified Listener ID must be a positive value (>= 0)
  /// Commands using the parameter "ListenerID"
  ERROR_TYPE_A_CLIENT_16x8635 := 16#8635,
  
  /// Server Continue not possible - robot is not enabled
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C01 := 16#8C01,
  
  /// Server Continue not possible - robot is not inPrimaryPosition
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C02 := 16#8C02,
  
  /// Server Robot disabled
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C03 := 16#8C03,
  /// Server Robot disabled due to an error
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C04 := 16#8C04,

  /// Server Not all mandatory commands have been called yet
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C05 := 16#8C05,

  /// Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies enabling in this state
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C06 := 16#8C06,

  /// Server Limit exceeded. Move closer to return position
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C07 := 16#8C07,

  /// Server Invalid parameter value - Must switch to T1Ext when changing between AutoExt and T2Ext
  /// Command "SetOperationMode"
  ERROR_TYPE_A_SERVER_16x8C08 := 16#8C08,

  /// Server Cannot write to a dynamic frame (frame used by e.g. conveyor tracking)
  /// Command "WriteFrameData"
  ERROR_TYPE_A_SERVER_16x8C09 := 16#8C09,

  /// Server Continue not possible in manual operation mode
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C10 := 16#8C10,

  /// Server It is not allowed to reference a frame which already references another frame
  /// Command "WriteFrame"
  ERROR_TYPE_A_SERVER_16x8C12 := 16#8C12,

  /// Server The referenced Frame is invalid, dynamic (frame used by e.g. conveyor tracking) or does not exist
  /// Command "WriteFrame"
  ERROR_TYPE_A_SERVER_16x8C13 := 16#8C13,

  /// Server Currently used tool ID differs from the tool ID of the target position
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C14 := 16#8C14,

  /// Server Writing a Frame during an active movement is not supported by this RC
  /// Command "WriteFrame"
  ERROR_TYPE_A_SERVER_16x8C15 := 16#8C15,

  /// Server Writing a Tool during an active movement is not supported by this RC
  /// Command "WriteToolData"
  ERROR_TYPE_A_SERVER_16x8C16 := 16#8C16,

  /// Server Writing a Load during an active movement is not supported by this RC
  /// Command "WriteLoadData"
  ERROR_TYPE_A_SERVER_16x8C17 := 16#8C17,

  /// Server ManualStep is not allowed in Automatic External
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C20 := 16#8C20,

  /// Server ManualStep is only allowed when StepMode is active
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C21 := 16#8C21,

  /// Server The current ToolData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C22 := 16#8C22,

  /// Server The current LoadData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C23 := 16#8C23,

  /// Server The current FrameData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C24 := 16#8C24,

  /// Server The current reference FrameData has changed and differs from the one when the primary position was left. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C25 := 16#8C25,

  /// Server The ToolNo differs from the one in the return position. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C26 := 16#8C26,

  /// Server The FrameNo differs from the one in the return position. Returning is not possible.
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8C27 := 16#8C27,

  /// Server Continue is not possible while the Robot is interrupting or stopping.
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C28 := 16#8C28,

  /// Server Software limits could not be set because values were specified for non-existing axes
  /// Command "WriteSWLimits"
  ERROR_TYPE_A_SERVER_16x8C29 := 16#8C29,

  /// Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies continue in this state
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C30 := 16#8C30,

  /// Server Enable switch must be active to enable the robot
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C31 := 16#8C31,

  /// Server Manual step sent while robot not enabled
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8C32 := 16#8C32,

  /// Server Jog not possible during active movement
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8C33 := 16#8C33,

  /// Server Target position was commanded for an external axis which does not exist
  /// All move commands
  ERROR_TYPE_A_SERVER_16x8C34 := 16#8C34,

  /// Server Jog of axis is not possible. Axis does not exist
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8C35 := 16#8C35,

  /// Server Incremental jog is only possible in one axis of rotation
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8C36 := 16#8C36,

  /// Server A program for the supplied JobID does not exist.
  /// Commands: "CallSubprogram", "StopSubprogram"
  ERROR_TYPE_A_SERVER_16x8C37 := 16#8C37,

  /// Server A program including motion commands is only allowed to be executed in a sequence buffer
  /// Command "CallSubprogram"
  ERROR_TYPE_A_SERVER_16x8C38 := 16#8C38,

  /// Server A program with the same number is already running. Multiple instances are not supported
  /// Command "CallSubprogram"
  ERROR_TYPE_A_SERVER_16x8C39 := 16#8C39,

  /// Server Changing the JobID in PM 3 during runtime of this CMD is not supported.
  /// Command "CallSubprogram"
  ERROR_TYPE_A_SERVER_16x8C42 := 16#8C42,

  /// Server Continue is not possible while the robot is stopping due to GroupInterrupt, GroupStop, SetSequence, or GroupJog
  /// Command "GroupContinue"
  ERROR_TYPE_A_SERVER_16x8C43 := 16#8C43,

  /// Server GroupJog motion was stopped due to the release of the enable switch.
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8C52 := 16#8C52,

  /// Server Setting the limits is not possible because the current robot position is currently outside of those limits.
  /// Command "WriteSWLimits"
  ERROR_TYPE_A_SERVER_16x8C53 := 16#8C53,

  /// Server Setting the limits is not possible while a motion is active.
  /// Command "WriteSWLimits"
  ERROR_TYPE_A_SERVER_16x8C54 := 16#8C54,

  /// Server Change of operation mode by the PLC not possible. The RC must be in an "External" operation mode
  /// Command "SetOperationMode"
  ERROR_TYPE_A_SERVER_16x8C56 := 16#8C56,

  /// Server Auxpoint must not be identical to start or end position of the motion
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8C57 := 16#8C57,

  /// Server Auxpoint invalid
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8C58 := 16#8C58,

  /// Server Supplied positions must not be identical or at a larger distance apart
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8C59 := 16#8C59,

  /// Server Calculation not possible with the given parameters
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8C60 := 16#8C60,

  /// Server Positions must not be on one line
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8C61 := 16#8C61,

  /// Server No solution found for the given CartesianPosition
  /// Command "CalculateInverseKinematic"
  ERROR_TYPE_A_SERVER_16x8C62 := 16#8C62,

  /// Server Solution is outside of the hardware limits
  /// Commands: "CalculateInverseKinematic", "CalculateForwardKinematic"
  ERROR_TYPE_A_SERVER_16x8C63 := 16#8C63,

  /// Server The selected parameter is write protected and can thus not be changed
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8C64 := 16#8C64,

  /// Server Number of received positions exceeds the maximum expected number (index out of range)
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8C65 := 16#8C65,

  /// Server Number of received positions does not correspond to the required number for the selected mode
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8C66 := 16#8C66,

  /// Server Invalid parameter value - AccelerationRate
  /// Commands using the parameter "AccelerationRate"
  ERROR_TYPE_A_SERVER_16x8D01 := 16#8D01,

  /// Server Invalid parameter value - BlendingMode
  /// Commands using the parameter "BlendingMode"
  ERROR_TYPE_A_SERVER_16x8D03 := 16#8D03,

  /// Server Invalid parameter value - BlendingParameter
  /// Commands using the parameter "BlendingParameter"
  ERROR_TYPE_A_SERVER_16x8D04 := 16#8D04,

  /// Server Invalid parameter value - ConfigMode Elbow
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_SERVER_16x8D05 := 16#8D05,

  /// Server Invalid parameter value - DecelerationRate
  /// Commands using the parameter "DecelerationRate"
  ERROR_TYPE_A_SERVER_16x8D06 := 16#8D06,

  /// Server Invalid parameter value - No value greater than zero
  /// Commands: "WriteDefaultDynamics", "WriteReferenceDynamics"
  ERROR_TYPE_A_SERVER_16x8D07 := 16#8D07,

  /// Server Invalid parameter value - FrameNo
  /// Commands using the parameter "FrameNo"
  ERROR_TYPE_A_SERVER_16x8D08 := 16#8D08,

  /// Server Invalid parameter value - IncrementalRotation
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8D09 := 16#8D09,

  /// Server Invalid parameter value - IncrementalTranslation
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8D10 := 16#8D10,

  /// Server Invalid parameter value - JerkRate
  /// Commands using the parameter "JerkRate"
  ERROR_TYPE_A_SERVER_16x8D11 := 16#8D11,

  /// Server Invalid parameter value - Control Positive and negative jog direction was active at the same time
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8D12 := 16#8D12,

  /// Server Invalid parameter value - JointPosition
  /// Commands using the parameter "JointPosition"
  ERROR_TYPE_A_SERVER_16x8D13 := 16#8D13,

  /// Server Invalid parameter value - LifesignTimeout
  /// Command "ExchangeConfiguration"
  ERROR_TYPE_A_SERVER_16x8D14 := 16#8D14,

  /// Server Invalid parameter value - SoftwareLimits all values must not be zero
  /// Command "WriteRobotSWLimits"
  ERROR_TYPE_A_SERVER_16x8D15 := 16#8D15,

  /// Server Invalid parameter value - LimitValues
  /// Command "WriteRobotSWLimits"
  ERROR_TYPE_A_SERVER_16x8D16 := 16#8D16,

  /// Server Invalid parameter value - LoadNo
  /// Commands using the parameter "LoadNo"
  ERROR_TYPE_A_SERVER_16x8D17 := 16#8D17,

  /// Server Invalid parameter value - LogLevel
  /// Command "ExchangeConfiguration"
  ERROR_TYPE_A_SERVER_16x8D18 := 16#8D18,

  /// Server Invalid parameter value - Mode
  /// Commands using the parameter "Mode"
  ERROR_TYPE_A_SERVER_16x8D21 := 16#8D21,

  /// Server Invalid parameter value - OriMode
  /// Commands using the parameter "OriMode"
  ERROR_TYPE_A_SERVER_16x8D22 := 16#8D22,

  /// Server Invalid parameter value - Override
  /// Commands using the parameter "Override"
  ERROR_TYPE_A_SERVER_16x8D23 := 16#8D23,

  /// Server Invalid parameter value - Position
  /// Commands using the parameter "Position"
  ERROR_TYPE_A_SERVER_16x8D24 := 16#8D24,

  /// Server Invalid parameter value - ReferenceDynamics all values less than zero
  /// Command "WriteReferenceDynamics"
  ERROR_TYPE_A_SERVER_16x8D25 := 16#8D25,

  /// Server Invalid parameter value - Acceleration
  /// Commands using the parameter "Acceleration"
  ERROR_TYPE_A_SERVER_16x8D26 := 16#8D26,

  /// Server Invalid parameter value - Deceleration
  /// Commands using the parameter "Deceleration"
  ERROR_TYPE_A_SERVER_16x8D27 := 16#8D27,

  /// Server Invalid parameter value - Jerk
  /// Commands using the parameter "Jerk"
  ERROR_TYPE_A_SERVER_16x8D28 := 16#8D28,

  /// Server Invalid parameter value - Velocity
  /// Commands using the parameter "Velocity"
  ERROR_TYPE_A_SERVER_16x8D29 := 16#8D29,

  /// Server Invalid parameter value - ReturnMode
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8D30 := 16#8D30,

  /// Server Invalid parameter value - TargetSequence
  /// Command "SetSequence"
  ERROR_TYPE_A_SERVER_16x8D31 := 16#8D31,

  /// Server Invalid parameter value - OperationMode
  /// Command "SetOperationMode"
  ERROR_TYPE_A_SERVER_16x8D32 := 16#8D32,

  /// Server Invalid parameter value - SyncReaction
  /// Command "LRob_ExchangeConfiguration"
  ERROR_TYPE_A_SERVER_16x8D33 := 16#8D33,

  /// Server Invalid parameter value - Time
  /// Commands using the parameter "Time"
  ERROR_TYPE_A_SERVER_16x8D34 := 16#8D34,

  /// Server Invalid parameter value - ToolNo
  /// Commands using the parameter "ToolNo"
  ERROR_TYPE_A_SERVER_16x8D35 := 16#8D35,

  /// Server Invalid parameter value - TrajectoryMode
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8D36 := 16#8D36,

  /// Server Invalid parameter value - TurnMode
  /// Commands using the parameter "TurnMode"
  ERROR_TYPE_A_SERVER_16x8D37 := 16#8D37,

  /// Server Invalid parameter value - VelocityRate
  /// Commands using the parameter "VelocityRate"
  ERROR_TYPE_A_SERVER_16x8D38 := 16#8D38,

  /// Server Invalid parameter value - WaitForNrOfCmd
  /// Command "LRob_ExchangeConfiguration"
  ERROR_TYPE_A_SERVER_16x8D39 := 16#8D39,

  /// Server Invalid parameter value - ConfigMode Shoulder
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_SERVER_16x8D40 := 16#8D40,

  /// Server Invalid parameter value - ConfigMode Wrist
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_SERVER_16x8D41 := 16#8D41,

  /// Server Invalid parameter value - StepMode
  /// Commands using the parameter "StepMode"
  ERROR_TYPE_A_SERVER_16x8D42 := 16#8D42,

  /// Server The supplied StopMode is not valid. Use 0, 1, or 2
  /// Command "StopSubprogram"
  ERROR_TYPE_A_SERVER_16x8D43 := 16#8D43,

  /// Server When StopMode 2: (Stop all subprograms) is selected, the TargetID must be -1.
  /// Command "StopSubprogram"
  ERROR_TYPE_A_SERVER_16x8D44 := 16#8D44,

  /// Server When StopMode 0: (Stop via JobID) is selected, the TargetID must NOT be -1.
  /// Command "StopSubprogram"
  ERROR_TYPE_A_SERVER_16x8D45 := 16#8D45,

  /// Server When StopMode 1: (Stop via InstanceID) is selected, the TargetID must NOT be -1.
  /// Command "StopSubprogram"
  ERROR_TYPE_A_SERVER_16x8D46 := 16#8D46,

  /// Server Invalid parameter value - Index out of range
  /// All Commands
  ERROR_TYPE_A_SERVER_16x8D47 := 16#8D47,

  /// Server Invalid parameter value - Same index was used multiple times
  /// Commands: "WriteDigitalOutputs", "WriteIntegers", "WriteReals", "WriteAnalogOutputs", "ReadDigitalInputs", "ReadDigitalOutputs", "ReadIntegers", "ReadReals"
  ERROR_TYPE_A_SERVER_16x8D48 := 16#8D48,

  /// Server Invalid parameter value - Specified mass greater than the maximum RA payload.
  /// Command "WriteLoad"
  ERROR_TYPE_A_SERVER_16x8D49 := 16#8D49,

  /// Server Invalid parameter value - At least one index must not be 0 and result in a read/write operation.
  /// Commands: "WriteDigitalOutputs", "WriteIntegers", "WriteReals", "WriteAnalogOutputs", "ReadDigitalInputs", "ReadDigitalOutputs", "ReadIntegers", "ReadReals"
  ERROR_TYPE_A_SERVER_16x8D50 := 16#8D50,

  /// Server Invalid parameter value - MessageLevel must be between 0-28
  /// Command "ReadMessages"
  ERROR_TYPE_A_SERVER_16x8D51 := 16#8D51,

  /// Server Invalid parameter value - CircPlane does not match CircMode
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8D61 := 16#8D61,

  /// Server Invalid parameter value - CircMode outside of the allowed range 0..3
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8D62 := 16#8D62,

  /// Server Invalid parameter value - Tolerance must only be used for CircMode 1
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8D63 := 16#8D63,

  /// Server Invalid parameter value - Angle must only be used for CircMode 2
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8D64 := 16#8D64,

  /// Server Invalid parameter value - PathChoice outside of the allowed range 0..1
  /// Commands
  ERROR_TYPE_A_SERVER_16x8D65 := 16#8D65,

  /// Server Invalid parameter value - Mode outside of the allowed range 0..4
  /// Command "ShiftPosition"
  ERROR_TYPE_A_SERVER_16x8D66 := 16#8D66,

  /// Server Invalid parameter value - RotationAngle only allowed in mode 3
  /// Command "ShiftPosition"
  ERROR_TYPE_A_SERVER_16x8D67 := 16#8D67,

  /// Server Invalid parameter value - TransformationParameter_2 value does not match the selected mode
  /// Command "ShiftPosition"
  ERROR_TYPE_A_SERVER_16x8D68 := 16#8D68,

  /// Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8D69 := 16#8D69,

  /// Server Invalid parameter value - FrameNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERROR_TYPE_A_SERVER_16x8D70 := 16#8D70,

  /// Server Invalid parameter value - TargetToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERROR_TYPE_A_SERVER_16x8D71 := 16#8D71,

  /// Server Invalid parameter value - TargetFrameNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERROR_TYPE_A_SERVER_16x8D72 := 16#8D72,

  /// Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateCartesianPosition"
  ERROR_TYPE_A_SERVER_16x8D73 := 16#8D73,

  /// Server Invalid parameter value - ParameterID does not exist on the RC
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D74 := 16#8D74,

  /// Server Invalid parameter value - SubParameterID does not exist on the RC for the supplied ParameterID
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D75 := 16#8D75,

  /// Server Invalid parameter value - SubParameterID must be 0 for a parameter without subparameters
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D76 := 16#8D76,

  /// Server Invalid parameter value - SubParameterID must not be 0 for a parameter with subparameters
  /// Commands: "ReadSystemVariable", "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D77 := 16#8D77,

  /// Server Invalid parameter value - DataType outside of the allowed range 1..13
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D78 := 16#8D78,

  /// Server Invalid parameter value - DataType does not match the data type of the parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D79 := 16#8D79,

  /// Server Invalid parameter value - Data_0 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D80 := 16#8D80,

  /// Server Invalid parameter value - Data_1 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D81 := 16#8D81,

  /// Server Invalid parameter value - Data_2 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D82 := 16#8D82,

  /// Server Invalid parameter value - Data_3 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D83 := 16#8D83,

  /// Server Invalid parameter value - Data_4 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D84 := 16#8D84,

  /// Server Invalid parameter value - Data_5 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D85 := 16#8D85,

  /// Server Invalid parameter value - Data_6 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D86 := 16#8D86,

  /// Server Invalid parameter value - Data_7 contains invalid data for the target parameter
  /// Command "WriteSystemVariable"
  ERROR_TYPE_A_SERVER_16x8D87 := 16#8D87,

  /// Server Invalid parameter value - ReferenceFrame outside of the allowed range 0..254 or does not exist on the RC
  /// Command "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8D88 := 16#8D88,

  /// Server Optional parameter value not supported - DecelerationRate
  /// Commands using the parameter "DecelerationRate"
  ERROR_TYPE_A_SERVER_16x8E03 := 16#8E03,

  /// Server Optional parameter value not supported - JerkRate
  /// Commands using the parameter "JerkRate"
  ERROR_TYPE_A_SERVER_16x8E04 := 16#8E04,

  /// Server Optional parameter value not supported - BlendingMode
  /// Commands using the parameter "BlendingMode"
  ERROR_TYPE_A_SERVER_16x8E05 := 16#8E05,

  /// Server Optional parameter value not supported - Time
  /// Commands using the parameter "Time"
  ERROR_TYPE_A_SERVER_16x8E06 := 16#8E06,

  /// Server Optional parameter value not supported - Position
  /// Commands using the parameter "Position"
  ERROR_TYPE_A_SERVER_16x8E07 := 16#8E07,

  /// Server Optional parameter value not supported - OriMode
  /// Commands using the parameter "OriMode"
  ERROR_TYPE_A_SERVER_16x8E08 := 16#8E08,

  /// Server Optional parameter value not supported - ConfigMode
  /// Commands using the parameter "ConfigMode"
  ERROR_TYPE_A_SERVER_16x8E09 := 16#8E09,

  /// Server Optional parameter value not supported - TurnMode
  /// Commands using the parameter "TurnMode"
  ERROR_TYPE_A_SERVER_16x8E10 := 16#8E10,

  /// Server Optional parameter value not supported - TrajectoryMode
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8E11 := 16#8E11,

  /// Server Optional parameter value not supported - OperationMode
  /// Command "SetOperationMode"
  ERROR_TYPE_A_SERVER_16x8E12 := 16#8E12,

  /// Server Optional parameter value not supported - IncrementalRotation
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8E13 := 16#8E13,

  /// Server Optional parameter value not supported - IncrementalTranslation
  /// Command "GroupJog"
  ERROR_TYPE_A_SERVER_16x8E14 := 16#8E14,

  /// Server Optional parameter value not supported - StepMode Exact Stop
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8E16 := 16#8E16,

  /// Server Optional parameter value not supported - StepMode Blending
  /// Command "EnableRobot"
  ERROR_TYPE_A_SERVER_16x8E17 := 16#8E17,

  /// Server Optional parameter value not supported - ModifiedConvention
  /// Command "ReadDHParameter"
  ERROR_TYPE_A_SERVER_16x8E20 := 16#8E20,

  /// Server Optional parameter value not supported - WaitAtBlendingPoint
  /// Command "ExchangeConfig"
  ERROR_TYPE_A_SERVER_16x8E21 := 16#8E21,

  /// Server Optional parameter not supported - Angle
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8E23 := 16#8E23,

  /// Server Optional parameter not supported - PathChoice
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8E24 := 16#8E24,

  /// Server Optional parameter not supported - Tolerance
  /// Commands: "MoveCircularAbsolute", "MoveCircularRelative", "MoveCircularCam"
  ERROR_TYPE_A_SERVER_16x8E25 := 16#8E25,

  /// Server Optional parameter not supported - TransformationParameter_2
  /// Command "ShiftPosition"
  ERROR_TYPE_A_SERVER_16x8E26 := 16#8E26,

  /// Server Optional parameter not supported - RotationAngle
  /// Command "ShiftPosition"
  ERROR_TYPE_A_SERVER_16x8E27 := 16#8E27,

  /// Server Optional parameter value not supported - Mode
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8E28 := 16#8E28,

  /// Server Optional parameter not supported - ExternalTCP
  /// Commands: "CalculateTool", "CalculateFrame"
  ERROR_TYPE_A_SERVER_16x8E29 := 16#8E29,

  /// Server Optional parameter not supported - RelativePosition
  /// Commands using the parameter "RelativePosition"
  ERROR_TYPE_A_SERVER_16x8E30 := 16#8E30,

  /// Server Specified Emitter ID must not be 0
  /// Commands using the parameter "EmitterID"
  ERROR_TYPE_A_SERVER_16x8F04 := 16#8F04,

  /// Server Invalid parameter value - Execution mode
  /// All Commands
  ERROR_TYPE_A_SERVER_16x8F10 := 16#8F10,

  /// Server Command not implemented
  /// All Commands
  ERROR_TYPE_A_SERVER_16x8F11 := 16#8F11,

  /// Server Only one instance of this command is allowed
  /// Commands: "EnableRobot", "GroupJog", "ReturnToPrimary", "ExchangeConfig"
  ERROR_TYPE_A_SERVER_16x8F12 := 16#8F12,

  /// Server Command requires an active interrupt or idle state to be executed
  /// Commands: "GroupJog", "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8F13 := 16#8F13,

  /// Server Command cannot be executed during active interrupt
  /// Command "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8F14 := 16#8F14,

  /// Server Secondary sequence is blocked by command (e.g. GroupJog, ReturnToPrimary). No other commands may be buffered in secondary sequence
  /// All commands processed in secondary sequence
  ERROR_TYPE_A_SERVER_16x8F15 := 16#8F15,

  /// Server The secondary sequence is not active. Commands may only be buffered in this sequence if it is active
  /// Commands using the parameter "SequenceFlag"
  ERROR_TYPE_A_SERVER_16x8F16 := 16#8F16,

  /// Server Secondary sequence is not empty. The command requires the secondary sequence to be empty
  /// Commands: "GroupJog", "ReturnToPrimary"
  ERROR_TYPE_A_SERVER_16x8F17 := 16#8F17,

  /// Server Transaction not possible in the state machine
  /// All commands
  ERROR_TYPE_A_SERVER_16x8F18 := 16#8F18,

  /// Server Cannot execute command because current operation mode is local.
  /// Commands that are not available in local modes
  ERROR_TYPE_A_SERVER_16x8F19 := 16#8F19,

  /// Server Command type out of range
  /// All commands
  ERROR_TYPE_A_SERVER_16x8F20 := 16#8F20,

  /// Server Execution of this CMD is not possible while CallSubprogram is in progress in the sequence
  /// Commands: "SetSequence", "GroupJog"
  ERROR_TYPE_A_SERVER_16x8F21 := 16#8F21,

  /// Server Operation not possible. See MessageLog for further information
  /// All commands
  ERROR_TYPE_A_SERVER_16x8F36 := 16#8F36,

  /// Server An RC internal error occurred during execution of this command. Check the message log for additional information
  /// All commands
  ERROR_TYPE_A_SERVER_16x8FFF := 16#8FFF,
  

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


  /// Client Wrong Telegram State (Two Sequences not in both directions active)
  ERROR_TYPE_B_CLIENT_16x8001 := 16#8001,

  /// Client Acyclic area client to server too small
  ERROR_TYPE_B_CLIENT_16x8002 := 16#8002,

  /// Client Acyclic area server to client too small
  ERROR_TYPE_B_CLIENT_16x8003 := 16#8003,

  /// Client Lifesign timeout
  ERROR_TYPE_B_CLIENT_16x8004 := 16#8004,

  /// Client Telegram sequence timeout
  ERROR_TYPE_B_CLIENT_16x8005 := 16#8005,

  /// Client Assigned AxesGroup not valid
  ERROR_TYPE_B_CLIENT_16x8007 := 16#8007,

  /// Client Assigned periphery not valid
  ERROR_TYPE_B_CLIENT_16x8008 := 16#8008,

  /// Client Invalid state of the robot (more than 1 CMD active)
  ERROR_TYPE_B_CLIENT_16x8009 := 16#8009,

  /// Client Telegram Number changed after initialization. Reinitialize by disabling and enabling the RobotTask.
  ERROR_TYPE_B_CLIENT_16x8013 := 16#8013,

  /// Client Telegram control does not match the telegram state
  ERROR_TYPE_B_CLIENT_16x80A1 := 16#80A1,

  /// Client Initialization lost for unknown reason. See message log after reinitializing
  ERROR_TYPE_B_CLIENT_16x80A2 := 16#80A2,

  /// Client Telegram length does not match the length provided in the communication interface, or the communication interface is too small.
  ERROR_TYPE_B_CLIENT_16x80A3 := 16#80A3,

  /// Client Incompatible major SRCI version
  ERROR_TYPE_B_CLIENT_16x80A4 := 16#80A4,

  /// Client Lifesign timeout
  ERROR_TYPE_B_CLIENT_16x80A5 := 16#80A5,

  /// Client The selected optional cyclic data does not fit in the given telegram size
  ERROR_TYPE_B_CLIENT_16x80A6 := 16#80A6,

  /// Client The robot interface was reset after being initialized
  ERROR_TYPE_B_CLIENT_16x80A7 := 16#80A7,

  /// Client Telegram sequence timeout
  ERROR_TYPE_B_CLIENT_16x80A8 := 16#80A8,

  /// Client The telegram number changed after initialization
  ERROR_TYPE_B_CLIENT_16x80A9 := 16#80A9,

  /// Client Error: Invalid AxesGroupID
  ERROR_TYPE_B_CLIENT_16x80AA := 16#80AA,

  /// Client Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERROR_TYPE_B_CLIENT_16x80AB := 16#80AB,

  /// Client Telegram Number is not supported
  ERROR_TYPE_B_CLIENT_16x80AC := 16#80AC,

  /// Server The ACR is full. RA is disabled
  ERROR_TYPE_B_SERVER_16x8A01 := 16#8A01,

  /// Server The execution of a mandatory command has been stopped. Exchange config must run for the system to run
  ERROR_TYPE_B_SERVER_16x8A02 := 16#8A02,

  /// Server Inconsistent data received. Make sure the complete telegram data is sent to RC in one frame.
  ERROR_TYPE_B_SERVER_16x8A03 := 16#8A03,

  /// Client Connection to the communication partner was lost
  ERROR_TYPE_B_CLIENT_16x8AAD := 16#8AAD,

  /// Client Fatal Error occurred. Reinitialization of Robot_Task is required
  ERROR_TYPE_B_CLIENT_16x9001 := 16#9001,

  /// Server Internal error
  ERROR_TYPE_B_SERVER_16x9A01 := 16#9A01,

  /// Server Internal error in deserialize
  ERROR_TYPE_B_SERVER_16x9A02 := 16#9A02,

  /// Server CMD ID out of range 1.ACR_Length
  ERROR_TYPE_B_SERVER_16x9A03 := 16#9A03,

  /// Server Invalid fragment length
  ERROR_TYPE_B_SERVER_16x9A04 := 16#9A04,

  /// Server Command priority or type changed during runtime
  ERROR_TYPE_B_SERVER_16x9A05 := 16#9A05,

  /// Server Tried to reset a non-empty ACR entry
  ERROR_TYPE_B_SERVER_16x9A06 := 16#9A06,

  /// Server Error: Invalid Sequence payload length (e.g., sequence payload length is specified 999 even if telegram length is only 100.)
  ERROR_TYPE_B_SERVER_16x9A07 := 16#9A07,

  /// Server Invalid ActionByte
  ERROR_TYPE_B_SERVER_16x9A08 := 16#9A08,

  /// Server Invalid Command payload length
  ERROR_TYPE_B_SERVER_16x9A09 := 16#9A09,

  /// Server Error: Invalid Command payload pointer (e.g., Out of bounds)
  ERROR_TYPE_B_SERVER_16x9A10 := 16#9A10,

  /// Server Illegal Execution Mode change
  ERROR_TYPE_B_SERVER_16x9A14 := 16#9A14,

  /// Server Telegram control does not match the telegram state
  ERROR_TYPE_B_SERVER_16xA1 := 16#A1,

  /// Server Initialization lost for unknown reason. See message log after reinitializing
  ERROR_TYPE_B_SERVER_16xA2 := 16#A2,

  /// Server Telegram length does not match the length provided in the communication interface.
  ERROR_TYPE_B_SERVER_16xA3 := 16#A3,

  /// Server Incompatible major SRCI version
  ERROR_TYPE_B_SERVER_16xA4 := 16#A4,

  /// Server Lifesign timeout
  ERROR_TYPE_B_SERVER_16xA5 := 16#A5,

  /// Server The selected optional cyclic data does not fit in the given telegram size
  ERROR_TYPE_B_SERVER_16xA6 := 16#A6,

  /// Server The robot interface was reset after being initialized
  ERROR_TYPE_B_SERVER_16xA7 := 16#A7,

  /// Server Telegram sequence timeout
  ERROR_TYPE_B_SERVER_16xA8 := 16#A8,

  /// Server The telegram number changed after initialization
  ERROR_TYPE_B_SERVER_16xA9 := 16#A9,

  /// Server Invalid AxesGroupID
  ERROR_TYPE_B_SERVER_16xAA := 16#AA,

  /// Server Telegram number is invalid. E.g., TwoSequences is only activated in one direction
  ERROR_TYPE_B_SERVER_16xAB := 16#AB,

  /// Server Telegram Number is not supported
  ERROR_TYPE_B_SERVER_16xAC := 16#AC,

  /// Server Connection to the communication partner was lost
  ERROR_TYPE_B_SERVER_16xAD := 16#AD  

)WORD;
END_TYPE


