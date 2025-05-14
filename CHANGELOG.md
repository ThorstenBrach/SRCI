# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

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