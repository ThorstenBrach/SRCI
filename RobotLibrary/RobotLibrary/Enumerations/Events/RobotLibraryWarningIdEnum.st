{attribute 'qualified_only'}
TYPE RobotLibraryWarningIdEnum :
(
	NO_WARNING := 0,
 
  /// 7.3 Table "C" – Command WarningIDs
  /// If a warning related to the execution of a function block occurs, the function block returns a
  /// WarningID to specify the warning. The warnings are stored in the PLC message buffer and are
  /// displayed on the function block outputs.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Command name> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing WarningIDs reported by commands and
  /// the corresponding description.

  /// Client HighPriority Input is ignored when a sequential ProcessingMode is selected
  /// Commands: "WriteDigitalOutputs", "WriteIntegers", "WriteReals", "WriteAnalogOutputs"
  WARNING_TYPE_C_CLIENT_16x7301 := 16#7301,

  /// Client Optional Cyclic data was disabled by the user but is still enabled until reinitialization of RobotTask
  /// Command: "ReadActualPositionCyclic"
  WARNING_TYPE_C_CLIENT_16x7303 := 16#7303,

  /// Client Number of free entries in the ACR is running out
  /// All commands
  WARNING_TYPE_C_CLIENT_16x7605 := 16#7605,

  /// Server The Frame is currently used in the sequence
  /// Command: "WriteFrameData"
  WARNING_TYPE_C_SERVER_16x7C03 := 16#7C03,

  /// Server The Tool is currently used in the sequence
  /// Command: "WriteToolData"
  WARNING_TYPE_C_SERVER_16x7C04 := 16#7C04,

  /// Server The Load is currently used in the sequence
  /// Command: "WriteLoadData"
  WARNING_TYPE_C_SERVER_16x7C06 := 16#7C06,

  /// Server The monitoring does not apply to motion CMDs which are already buffered.
  /// Command: "SetTriggerMotion"
  WARNING_TYPE_C_SERVER_16x7C14 := 16#7C14,

  /// 7.4 Table "D" – RI WarningIDs
  /// RI warnings can occur on the PLC as well as on the RC. In the event of an RI warning on the PLC,
  /// the corresponding WarningID is written to the PLC message buffer independent of the function call
  /// "ReadMessages". In the event of an RI warning on the RC, the WarningID is transmitted via the
  /// function block "ReadMessages" and is also stored in PLC message buffer.
  /// In the PLC message buffer, they are dynamically arranged by the client to be displayed as follows:
  /// <Origin> <MessageType> <Description>
  /// More information about the general message handling mechanism can be found in 5.5.11
  /// Diagnostics.
  /// The following table gives an overview over the existing WarningIDs reported via RI warnings and
  /// the corresponding description.

  /// Client Acyclic range client to server very small
  WARNING_TYPE_D_CLIENT_16x7001 := 16#7001,

  /// Client Acyclic range server to client very small
  WARNING_TYPE_D_CLIENT_16x7002 := 16#7002,

  /// Client Telegram number was changed during operation
  WARNING_TYPE_D_CLIENT_16x7003 := 16#7003,

  /// Client Save Tool locally failed. Index not available in user data.
  WARNING_TYPE_D_CLIENT_16x7005 := 16#7005,

  /// Client Save Frame locally failed. Index not available in user data.
  WARNING_TYPE_D_CLIENT_16x7006 := 16#7006,

  /// Client Save Load locally failed. Index not available in user data.
  WARNING_TYPE_D_CLIENT_16x7007 := 16#7007,

  /// Client Save WorkArea locally failed. Index not available in user data.
  WARNING_TYPE_D_CLIENT_16x7008 := 16#7008,

  /// Client Array of tool data supplied to RobotTask does not start at 0.
  WARNING_TYPE_D_CLIENT_16x7009 := 16#7009,

  /// Client Array of tool data supplied to RobotTask must be longer than the number of tools on the RC.
  WARNING_TYPE_D_CLIENT_16x7010 := 16#7010,

  /// Client Tool data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7011 := 16#7011,

  /// Client Error Sync with Tool "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70121 := 16#7012,

  /// Client Error Sync Data changed in both Sides with Tool "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70131 := 16#7013,

  /// Client Array of frame data supplied to RobotTask does not start at 0.
  WARNING_TYPE_D_CLIENT_16x7015 := 16#7015,

  /// Client Array of frame data supplied to RobotTask must be longer than the number of frames on the RC.
  WARNING_TYPE_D_CLIENT_16x7016 := 16#7016,

  /// Client Frame data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7017 := 16#7017,

  /// Client Error Sync with Frame "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70181 := 16#7018,

  /// Client Error Sync Data changed in both Sides with Frame "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70191 := 16#7019,

  /// Client Array of load data supplied to RobotTask does not start at 0.
  WARNING_TYPE_D_CLIENT_16x7021 := 16#7021,

  /// Client Array of load data supplied to RobotTask must be longer than the number of tools on the RC.
  WARNING_TYPE_D_CLIENT_16x7022 := 16#7022,

  /// Client Load data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7023 := 16#7023,

  /// Client Error Sync with Load "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70241 := 16#7024,

  /// Client Error Sync Data changed in both Sides with Load "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70251 := 16#7025,

  /// Client Array of workarea data supplied to RobotTask does not start at 0.
  WARNING_TYPE_D_CLIENT_16x7027 := 16#7027,

  /// Client Array of workarea data supplied to RobotTask must be longer than the number of tools on the RC.
  WARNING_TYPE_D_CLIENT_16x7028 := 16#7028,

  /// Client Workarea data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7029 := 16#7029,

  /// Client Error Sync with WorkArea "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7030 := 16#7030,

  /// Client Error Sync Data changed in both Sides with WorkArea "NUMBER" (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x70311 := 16#7031,

  /// Client Software limits data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x70331 := 16#7033,

  /// Client Error Sync with Software Limits (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7034 := 16#7034,

  /// Client Error Sync Data changed in both Sides with Software Limits (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7035 := 16#7035,

  /// Client Default dynamics data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7037 := 16#7037,

  /// Client Error Sync with Default Dynamics (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7038 := 16#7038,

  /// Client Error Sync Data changed in both Sides with Default Dynamics (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7039 := 16#7039,

  /// Client Reference dynamics data sync mode is invalid.
  WARNING_TYPE_D_CLIENT_16x7041 := 16#7041,

  /// Client Error Sync with Reference Dynamics (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7042 := 16#7042,

  /// Client Error Sync Data changed in both Sides with Reference Dynamics (Please Enter a valid SyncMode)
  WARNING_TYPE_D_CLIENT_16x7043 := 16#7043,

  /// Client Synchronization of tool is not possible due to error in the read or write tool cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7044 := 16#7044,

  /// Client Synchronization of frame is not possible due to error in the read or write frame cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7045 := 16#7045,

  /// Client Synchronization of load is not possible due to error in the read or write load cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7046 := 16#7046,

  /// Client Synchronization of swLimits is not possible due to error in the read or write swLimits cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7047 := 16#7047,

  /// Client Synchronization of referenceDynamics is not possible due to error in the read or write referenceDynamics cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7048 := 16#7048,

  /// Client Synchronization of defaultDynamics is not possible due to error in the read or write defaultDynamics cmd. See dedicated message log entry for more information.
  WARNING_TYPE_D_CLIENT_16x7049 := 16#7049,

  /// Client Using the legacy SRCI version encoding. It will not be compatible with the newest RC interpreter versions.
  WARNING_TYPE_D_CLIENT_16x7050 := 16#7050,

  /// Server The ACR is almost full. Filling it completely disables the robot. Make sure to limit the number of commands in the system.
  WARNING_TYPE_D_SERVER_16x7A01 := 16#7A01
)WORD;
END_TYPE


