{attribute 'qualified_only'}
TYPE RobotLibraryInfoIdEnum :
(
  NO_INFO := 0,
  
  ////7.5 Table "E" – Command InfoIDs
  /// If an info event related to the execution of a function block occurs, the function block returns an
  /// InfoID to specify the event. The info events are stored in the PLC message buffer and are displayed
  /// on the function block outputs.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Command name> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing InfoIDs reported by commands and the
  /// corresponding description.

  /// Server Collision detected
  /// Motion commands
  INFO_TYPE_E_SERVER_16x6C01 := 16#6C01,

  /// Server Error occurred during motion. Check the message buffer for more information
  /// Motion commands
  INFO_TYPE_E_SERVER_16x6C02 := 16#6C02,

  /// Server Target position not reachable
  /// Motion commands
  INFO_TYPE_E_SERVER_16x6C03 := 16#6C03,

  /// Server Software limits reached
  /// Motion commands
  INFO_TYPE_E_SERVER_16x6C04 := 16#6C04,

  /// Server Abortion of this command was requested by a GroupStop
  /// All sequence related commands
  INFO_TYPE_E_SERVER_16x6C05 := 16#6C05,

  /// Server Abortion of this command was requested by another motion command
  /// All sequence related commands
  INFO_TYPE_E_SERVER_16x6C06 := 16#6C06,

  /// Server Reading the currently used software limits. Updated software limits are active after restart.
  /// Command "ReadRobotSWLimits"
  INFO_TYPE_E_SERVER_16x6C07 := 16#6C07,

  /// Server No SubProgram was stopped because none was active
  /// Command "StopSubprogram"
  INFO_TYPE_E_SERVER_16x6C09 := 16#6C09,

  /// Server A program for the supplied JobID is not running or does not exist.
  /// Command "StopSubprogram"
  INFO_TYPE_E_SERVER_16x6C11 := 16#6C11,

  /// Server A program for the supplied InstanceID is not running or does not exist.
  /// Command "StopSubprogram"
  INFO_TYPE_E_SERVER_16x6C12 := 16#6C12,

  /// Server The robot is waiting at the blending zone.
  /// Motion commands
  INFO_TYPE_E_SERVER_16x6C13 := 16#6C13,

  /// Server Jog motion was interrupted by GroupStop
  /// Command "GroupJog"
  INFO_TYPE_E_SERVER_16x6C14 := 16#6C14,

  /// Server Jog motion was interrupted by RA sequence state INTERRUPTED
  /// Command "GroupJog"
  INFO_TYPE_E_SERVER_16x6C15 := 16#6C15,

  /// Server Manual start is ignored when the sequence is empty
  /// Command "EnableRobot"
  INFO_TYPE_E_SERVER_16x6C19 := 16#6C19,

  /// Server Invalid parameter value - A value was given for index 0. Index 0 is not writeable. Remove the value or change the index.
  /// Commands: "WriteIntegers", "WriteReals", "WriteAnalogOutputs", "ReadDigitalInputs", "ReadDigitalOutputs", "ReadIntegers", "ReadReals"
  INFO_TYPE_E_SERVER_16x6D51 := 16#6D51,

  /// Server Invalid parameter value OutputBitmask - No bitmask was given for a non zero index. Set the index to zero, or set a valid bitmask.
  /// Command "WriteDigitalOutputs"
  INFO_TYPE_E_SERVER_16x6D52 := 16#6D52,

  /// Server Invalid parameter value OutputBitmask - A bitmask was given for a zero index. Set the bitmask to zero, or set a non zero index.
  /// Command "WriteDigitalOutputs"
  INFO_TYPE_E_SERVER_16x6D53 := 16#6D53,

  /// Server Command interrupted due to RA sequence state INTERRUPTED
  /// All sequence related commands
  INFO_TYPE_E_SERVER_16x6F01 := 16#6F01,

  /// Server Command interrupted due to RA power state NOT_ENABLED
  /// All sequence related commands
  INFO_TYPE_E_SERVER_16x6F02 := 16#6F02,

  /// Server Command interrupted due to RA sequence state INTERRUPTED while single step mode is active
  /// All sequence related commands
  INFO_TYPE_E_SERVER_16x6F03 := 16#6F03,

  /// Server Internal code used to reset warnings
  /// All commands
  INFO_TYPE_E_SERVER_16xFF := 16#FF,


  /// 7.6 Table "F" – RI InfoIDs
  /// RI info events can occur on the PLC as well as on the RC. In the event of an RI info on the PLC,
  /// the corresponding InfoID is written to the PLC message buffer independent of the function call
  /// "ReadMessages". In the event of an RI info on the RC, the InfoID is transmitted via the function
  /// block "ReadMessages" and is also stored in PLC message buffer.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing InfoIDs reported via RI info events and the
  /// corresponding description.  

  /// Client Lifesign smaller than lower limit. It has been increased to 10ms.
  INFO_TYPE_F_CLIENT_16x6001 := 16#6001,

  /// Client ReceiveExtendedCartesianPosition cannot be used without ReceiveCartesianPos. RecCarPos is automatically activated.
  INFO_TYPE_F_CLIENT_16x6002 := 16#6002,

  /// Client ReceiveExtendedJointPosition cannot be used without ReceiveJointPosition. RecJointPos is automatically activated.
  INFO_TYPE_F_CLIENT_16x6003 := 16#6003,

  /// Client Synchronization of tool data is disabled, and the data is different on the RC. Tool = "NUMBER" (Please Enter a valid SyncMode)
  INFO_TYPE_F_CLIENT_16x60141 := 16#6014,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (TOOL)
  INFO_TYPE_F_CLIENT_16x6015 := 16#6015,

  /// Client Synchronization of frame data is disabled, and the data is different on the RC. Frame = "NUMBER" (Please Enter a valid SyncMode)
  INFO_TYPE_F_CLIENT_16x60201 := 16#6020,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (FRAME)
  INFO_TYPE_F_CLIENT_16x6021 := 16#6021,

  /// Client Synchronization of load data is disabled, and the data is different on the RC. Load = "NUMBER" (Please Enter a valid SyncMode)
  INFO_TYPE_F_CLIENT_16x60261 := 16#6026,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (LOAD)
  INFO_TYPE_F_CLIENT_16x6027 := 16#6027,

  /// Client Synchronization of work area data is disabled, and the data is different on the RC. WorkArea = "NUMBER" (Please Enter a valid SyncMode)
  INFO_TYPE_F_CLIENT_16x60321 := 16#6032,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (WORKAREA)
  INFO_TYPE_F_CLIENT_16x6033 := 16#6033,

  /// Client Synchronization of Software Limits data is disabled, and the data is different on the RC.
  INFO_TYPE_F_CLIENT_16x6036 := 16#6036,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (SW LIMITS)
  INFO_TYPE_F_CLIENT_16x6037 := 16#6037,

  /// Client Synchronization of default dynamics data is disabled, and the data is different on the RC.
  INFO_TYPE_F_CLIENT_16x6040 := 16#6040,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (DEFAULT DYNAMICS)
  INFO_TYPE_F_CLIENT_16x6041 := 16#6041,

  /// Client Synchronization of reference dynamics data is disabled, and the data is different on the RC.
  INFO_TYPE_F_CLIENT_16x6044 := 16#6044,

  /// Client Change the Syncmode to Negative only works on Startup with PLC (REFERENCE DYNAMICS)
  INFO_TYPE_F_CLIENT_16x6045 := 16#6045,

  /// Server RA disabled due to operation mode change
  INFO_TYPE_F_SERVER_16x6A01 := 16#6A01,

  /// Server Operation mode changed
  INFO_TYPE_F_SERVER_16x6A02 := 16#6A02,

  /// Server The server state has been reset on client request. Client restart may be a cause.
  INFO_TYPE_F_SERVER_16x6A03 := 16#6A03,

  /// Server The actual override has been decreased to not exceed a movement's monitoring velocity.
  INFO_TYPE_F_SERVER_16x6A07 := 16#6A07,

  /// Server Excessive logging may degrade system performance.
  INFO_TYPE_F_SERVER_16x6A13 := 16#6A13,

  /// Server The first motion is executed with reduced velocity.
  INFO_TYPE_F_SERVER_16x6C08 := 16#6C08
)WORD;
END_TYPE


