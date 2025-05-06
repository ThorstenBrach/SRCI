# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.0.0.42] - 2025-05-01

### Added
- Functions to compare data objects:
  - `IsFrameDataEqual`
  - `IsToolDataEqual`
  - `IsLoadDataEqual`
  - `IsSwLimitsEqual`
  - `IsWorkAreaEqual`
  - `IsDefaultDynamicsEqual`
  - `IsReferenceDynamicsEqual`
- Methods to handle synchronization:
  - `HandleSyncFrameData`
  - `HandleSyncToolData`
  - `HandleSyncLoadData`
  - `HandleSyncWorkArea`
  - `HandleSyncSwLimits`
  - `HandleSyncDefaultDynamics`
  - `HandleSyncReferenceDynamics`
- Some missing `Error`, `Warning`, and `Info` events from the specification (still incomplete).

### Changed
- Array definitions updated to use range `0..MAX-1` for:
  - `FrameData`
  - `ToolData`
  - `LoadData`
  - `WorkAreas`


## [0.0.0.41] - 2025-04-13

### Added
- `SyncTime` Enum.
- `TO_STRING` conversion for `SyncTime`.
- Preparations for synchronization mechanism in `RobotTask` (not yet implemented).
- Distinction between `SyncMode` values: `SYNC_DURING_STARTUP` and `SYNC_AFTER_STARTUP`.

### Changed
- Renamed:
  - `RobotTask.ExchangeConfiguration` to `RobotTask._exchangeConfiguration`.
  - `RobotTask.ReadRobotData` to `RobotTask._readRobotData`.
  - `RobotTask.ReadMessaged` to `RobotTask._readmessaged`.
- Consolidated `AxesGroup.InternalData` and `AxesGroup.State` into `AxesGroup.State`.
- Standardized method usage: replaced `OnCall` with `OnExecRun` for command execution (`OnCall` remains in `BaseFB`).
- Assigned more meaningful names to `SyncReaction` items.

### Fixed
- Issue with acknowledgement of `LogMessages` via `ReadMessagesFB`.


## [0.0.0.40] - 2025-04-03

### Added

- `TO_STRING` conversion functions for `AlarmMessage` and `AlarmCode`.
- Library parameter `MESSAGE_TEXT_LEN` for consistent string definitions.
- Monitoring of ARC usage with log messages when free registers run out.
- `RobotLibraryRecvDataBaseFB` and `RobotLibrarySendDataBaseFB` (without payload definitions).
- `RobotLibraryResponseDataFB` and `RobotLibraryCommandDataFB` (with specific payloads).
- `Initialized` flag of `RobotTaskFB` in `AxesGroup.InternalData`.
- Initialization check in all `CommandFBs` with error raised if `RobotTask` is uninitialized.
- Check in all `CommandFBs` that no command error is pending before execution.

### Changed

- `RobotLibraryRecvDataFB` and `RobotLibrarySendDataFB` now extend their respective base FBs and define specific payloads.
- Replaced:
  - All `ResponseData` definitions of type `RobotLibraryRecvDataFB` with `RobotLibraryResponseDataFB`.
  - All `CommandData` definitions of type `RobotLibrarySendDataFB` with `RobotLibraryCommandDataFB`.
- Moved:
  - Time conversion functions to a dedicated folder.
  - `BaseFBs` to a dedicated folder.
  - `AxesGroupMessageLogFB` to a new folder.
- `AxesGroupMessageLogFB` now implements the `IMessageLogger` interface.
- Optimized:
  - Execution behavior of all `EnableFBs` to prevent hangs when disabling.
  - Internal debugging: messages are now pushed to the `SystemLog` array.
  - Message logging: command-related events now logged, not just messages from `ReadMessagesFB`.
- Replaced some general `ParCmd` error messages with specific messages (per SRCI specification; some still pending).

### Removed

- FSM state machine from `BaseFBs`.
- `ErrorClear` mechanism from `RobotTaskFB` (now: set `Enable` to `FALSE` to acknowledge errors or trigger reset).


## [0.0.0.39] - 2025-03-23

### Added

- Constant for PLC library version.
- Method `HandleUserData` in `RobotTaskFB` to update `UserData`.
- Enumeration `AxisUnit`.
- Structures and conversion functions for:
  - `JointAxisUsed` and `JointAxisUnit`
  - `ExternalAxisUsed` and `ExternalAxisUnit`
- ConfigurationData in `AxesGroup.InternalData` to access `ExchangeConfiguration.OutCmd`.
- `MessageLevel` to `RobotTaskParCfgRobParameter` and related handling in `RobotTaskFB`.

### Changed

- `ReadRobotDataOutCmd` and `UserData` structures adapted to changes in axis unit/usage definitions.
- `ParameterValid` methods of `BrakeTestFB` and `OpenBrakeFB` updated accordingly.
- Payload definition of ARC entries now uses `PARAMETER_PAYLOAD_MAX` and `RESPONSE_PAYLOAD_MAX` (set to 255) to reduce memory usage.
- Fragment definitions in telegram sequence structures now based on `FRAGMENT_MAX`.

### Removed

- Library parameter `TELEGRAM_PAYLOAD_MAX` (replaced by `ROBOT_IN_DATA_MAX` and `ROBOT_OUT_DATA_MAX`).
- Library parameter `LIFE_SIGN_TIMEOUT` (now part of `RobotTask.ParCfg`).
- Unused structures `MessageHeaderCommand` and `MessageHeaderResponse`.

### Fixed

- `ParseRecvPayloadSequence` method optimized to handle multiple fragments and prepare support for 2nd sequence (not yet tested).
- `AxesGroupToTelegramSequence` adjusted to prepare support for 2nd sequence (not yet tested).


## [0.0.0.38] - 2025-03-13

### Added
- Telegram error 173 (not in specification V1.3; discovered during Yaskawa testing).
- `Reset` method to `RobotTask` to reset internal variables on falling edge of the `Enable` flag.

### Changed
- `CheckFunctionSupport` method of mandatory commands now always returns `TRUE`.
- Assignment of `SystemLog` and `MessageLog` moved from `OnCall` to FB body for access to `VAR_IN_OUT`.

### Fixed
- `MC_ReturnToPrimaryFB` and related structures corrected (incorrect in spec V1.3; discovered during Yaskawa testing).
- Bug in `ManageRegister` of `ActiveCommandRegisterFB` that prevented subsequent registers from being checked if a previous register had no valid `CommandFB`.

### Removed
- `STAUBLI_SIMULATOR` flag.

### Changed
- Most `TO_STRING` methods corrected and improved.
- `AddRsp` method of `ActiveCommandRegisterFB` now uses meaningful constants instead of hardcoded indexes.
- Callback behavior updated: callback moved from `ManageRegister` to `AddRsp` to ensure associated `CommandFB` receives response in the same PLC cycle.
- LifeSign handling optimized: `LifeSign = 0` only used in the first cycle to indicate communication start.
- Logging messages optimized.


## [0.0.0.37] - 2025-03-05

### Added
- System-dependent functions: `IsValidReal` and `IsValidLReal`.
- Read `RobotData` results to `AxesGroup.InternalData`.
- Missing enumerations and corresponding `TO_STRING` conversion functions.
- `CheckParameterValid` method added to all command FBs with command-specific parameter validation.

### Changed
- `CheckParameterChanged` method modified to execute parameter validation only when the command FB is running.

### Fixed
- Corrections in command-specific structures.


## [0.0.0.36] - 2025-02-17

### Added
- Padding bytes in `CreateCommandPayload` method of `MC_GroupJogFB` - not specified in SRCI spezification V1.3, but required for correct command execution - (discovered during Stäubli testing)

### Fixed
- Issue with `FastStop` mechanism: counter is no longer decremented after `GroupStop` / `GroupInterrupt`; it can now only be reset using `GroupReset`.


## [0.0.0.35] - 2025-02-08

### Added
- Additional logging for all parameters in the response payload.
- Method to convert %-INT values to `REAL`, handling optional values (`16#FFFF` → `-1.0`).
- Method to convert `REAL` values to %-INT, handling optional values (`-1.0` → `16#FFFF`).
- Additional `TO_STRING` methods for logging enum-based parameters with name and value.
- Mechanism for internal triggering of parameter updates to the ARC Register (without changing `ParCmd`).
- Call to FB-specific `CheckParameterValid` method within `CheckParameterChanged`, used as condition for parameter update.

### Changed
- Renamed enumeration items in:
  - `RobotLibraryErrorIdEnum`
  - `RobotLibraryWarningIdEnum`
  - `RobotLibraryInfoIdEnum` — now using more meaningful names.
- Unified `LogLevel` and `Severity` by using `LogLevel` as alias.

### Changed
- Optimized log texts.


## [0.0.0.34] - 2025-02-03

### Added
- Additional logging for all command payload parameters.
- `TO_STRING` methods for logging enum-based parameters with clear text and value.
- Preparation for extended logging of all parameters in response payload (not yet implemented).

### Changed
- `UniqueID` now corresponds to the ARC index.
- ARC register size is now based on the smaller value of PLC-ARC size and Robot-ARC size.
- Simplified command payload creation for `ConfigMode` using `ArmConfigParameterToBytes`.

### Fixed
- Implicit conversion warnings.


## [0.0.0.33] - 2025-01-19

### Added
- `RcSupportedFunctions` to `AxesGroupInternalData` to enable function support checks.
- `CheckFunctionSupported` method to all Command FBs: blocks execution if function is unsupported by the RC.
- `CheckParameterValid` method to all Command FBs (currently only prepared, not fully implemented).
- Pre-initialization of `RcSupportFunctions` bits (`ExchangeConfiguration`, `ReadRobotData`, `ReadMessages`) to `TRUE` for RobotTask initialization sequence.

### Changed
- Execution performance of Command FBs improved: telegram is now written to fieldbus within the same PLC cycle as FB activation (requires Command FBs before `RobotTaskFB`).
- `ReadActualPositionCyclic` command fundamentally revised.
- Optional parameters `JerkRate` and `DecelerationRate` handled in:
  - `BasicMove` commands
  - `ReadDefaultDynamics` / `WriteDefaultDynamics`
- Optional parameters `JerkReference` and `DecelerationReference` handled in:
  - `ReadReferenceDynamics` / `WriteReferenceDynamics`
- Datatype of `RaSequenceState` in `RaStatusWord` changed to enum instead of single bits.
- Reorganized conversion functions into separate folders.
- All `TO_STRING` functions converted to uppercase.

### Fixed
- Spelling mistakes.


## [0.0.0.32] - 2025-01-12

### Changed
- Internal timestamp format updated to support millisecond resolution for improved debugging.
- Logging messages enhanced with more detailed information.

### Fixed
- Bug in `ActiveCommandRegister` / `ExecutionOrderList` affecting `CmdID` in `FragmentHeader`, which could cause sporadic decoding errors on the robot side.

### Added
- Preparation of `FragmentCounters` for the second telegram sequence.


## [0.0.0.31] - 2025-01-08

### Added
- Legal notice to `README.md`.
- New functions to convert Siemens formats to TwinCAT/3S formats:
  - `IEC_DATE_TO_DATE`
  - `IEC_TIME_TO_TIME`
  - `IEC_TIMESTAMP_TO_DT`
- `ReadMessagesFB` is now integrated into `RobotTaskFB` and starts during interface initialization.
- `RobotTaskFB` now clears a potentially pending interface error when starting.
- Missing `PRIVATE` keywords added to several private methods.

### Changed
- Software status updated in `README.md`.
- Renamed function blocks:
  - `SendData` → `RobotLibrarySendDataFB`
  - `RecvData` → `RobotLibraryRecvDataFB`
- Initial values updated in the parameter list for:
  - `TOOL_MAX`, `FRAME_MAX`, `LAOD_MAX`, `WORK_AREAS_MAX`, `MESSAGE_LOG_MAX`
- `XNULL (DWORD)` replaced by `NULL_POINTER (POINTER TO BYTE)` (due to CODESYS compiler issue).
- `AxesGroupMessageLog` changed from a struct to a function block with methods for adding, deleting, and sorting messages.
- `ExecutionAbort` code moved from instances into the associated base FBs.
- Array sizes of `SystemLog` and `MessageLog` adjusted.
- Base function block of `MC_ReadMessagesFB` changed from `ExecuteBaseFB` to `EnableBaseFB` to match specification.


## [0.0.0.30] - 2025-01-02

### Added
- Missing assignment of `AxesGroup.CyclicOptional.RobToPlc.SubProgramData`.

### Changed
- Behavior of applying `RobotTask.ParCfg`.
- `RobotTask.OnCall` now cyclically updates:
  - `AxesGroup.Cyclic.PlcToRob.ClientDate`
  - `AxesGroup.Cyclic.PlcToRob.ClientTime`
- Separate telegram footer structures now used for `RobToPlc` and `PlcToRob` (due to structural differences).
- Parsing of `Telegram.RobToPlc.Footer.LifeSign` simplified in `RobotTask.ParseRecvPayloadFooter`.


## [0.0.0.29] - 2024-12-24

### Added
- Library category.

### Changed
- `LifeSign` address in telegram is now variable (was previously hardcoded to byte `[255]`).

### Fixed
- Incorrect assignment of `ArmConfig` in `CartesianPosition`.


## [0.0.0.28] - 2024-12-21

### Added
- Intermediate abstraction layer to generalize system-specific functions.
- Common interfaces for system-specific operations.
- Implementations of these interfaces for CODESYS and TwinCAT targets.

### Changed
- Improved modularity and portability by decoupling system-specific implementations.


## [0.0.0.27] - 2024-12-16

### Added
- Plain text versions of source-code files (`*.ST`) to improve GitHub diff tracking and code reviews.

### Changed
- Source code is now also available in plain text format alongside the existing Library and PLCopen XML files.


## [V0.0.0.26] - 2024-12-08

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.25] - 2024-12-01

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.24] - 2024-11-29

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.23] - 2024-11-24

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.22] - 2024-11-20

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.21] - 2024-11-10

### Changed
- No detailed change information provided – early development phase.
- Changed License information


## [V0.0.0.21] - 2024-11-10

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.21] - 2024-11-10

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.20] - 2024-09-08

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.19] - 2024-09-02

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.18] - 2024-08-11

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.17] - 2024-08-10

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.16] - 2024-08-08

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.15] - 2024-08-03

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.15] - 2024-08-03

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.14] - 2024-08-01

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.13] - 2024-07-29

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.12] - 2024-07-03

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.11] - 2024-06-30

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.10] - 2024-06-23

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.9] - 2024-06-22

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.8] - 2024-06-20

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.7] - 2024-06-17

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.6] - 2024-06-16

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.5] - 2024-06-11

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.4] - 2024-06-09

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.3] - 2024-06-05

### Changed
- No detailed change information provided – early development phase.


## [V0.0.0.2] - 2024-06-04

### Changed
- No detailed change information provided – early development phase.