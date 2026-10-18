# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [1.5.1.0]

Fixes of the findings F1 … F92 found while porting the library to Python (SRCI_PY) and testing both
against the SRCI SDK (SDK in the loop, TcUnit project SRCI_PLC_TEST). Every change is marked in the
code with `// ST-FIX Fnn`. Details and the diffs: SRCI_PY `docs/ST_FINDINGS.md` and
`docs/ST_Finding_Solve_Guide.md`.

### Added
 - New functions `TURN_TO_SIGN_MAGNITUDE` and `SIGN_MAGNITUDE_TO_TURN` (turn numbers as sign + magnitude, ST-FIX F3)
 - New error and info IDs of the specification (ST-FIX F75)

### Fixed
 - ST-FIX F1: `MC_RobotTaskFB.CreateSendPayloadCyclicOptional` – Cartesian position PLC→RC: `Config` is sent as **1 byte**, but `SIZEOF(...CartesianPosition)` = 34 counts 2 bytes → all following bytes are shifted by one compared to the calculated layout. Fix: 2 bytes (`config`, `0`) (spec: Table 5-97: Config = bytes 24–25)
 - ST-FIX F2: `MC_RobotTaskFB.CreateSendPayloadCyclic`, `CalculateCyclicDataLength` – `ToolNo`/`FrameNo` are **always** sent after the header. Fix: only with `RobToPlc.CartesianPosition.Active` (confirmed with the SDK in M5) (spec: Table 5-88 bit 1 / 5-90 and SDK (`AutoTransmitCartesianPos`): only when "Cartesian Position" RC→PLC is configured; otherwise the RC expects the sequence at byte 18)
 - ST-FIX F3: `RobotLibrarySendDataBaseFB.AddTurnNumber`, `RobotLibraryRecvDataBaseFB.GetTurnNumbers` – turn numbers encoded as two's complement nibble (`SINT_TO_BYTE`, -1 → `2#1111` = -7 for the RC); decoding ignores the sign bit (`-1` = `2#1001` → 9) (spec: 5.5.4.4, tables 5-24…5-26: sign + magnitude, bits 0..2 value, bit 3 sign (E1: bits 0..6, bit 7))
 - ST-FIX F5: `MC_RobotTaskFB.ParseRecvPayloadSequence` – `_fragIdx` and `_seqPayloadPtr` are not reset for the second sequence – with two sequences the second one is parsed with a wrong fragment index/length. Fix: reset per sequence
 - ST-FIX F6: `DwordToRaStatusWord` – inserts `CollisionDetectedEnabled` at bit 13 → `CollisionDetected`, `RestartRequested`, `Accelerating`, `Decelerating`, `ConstantVelocity` are read one bit too high. Fix: `CollisionDetectedEnabled` stays FALSE (spec: Table 5-105 and SDK: 13 CollisionDetected, 14 RestartRequested, 15 Accelerating, 16 Decelerating, 17 ConstantVelocity)
 - ST-FIX F9: `ByteToAxisJointUnit` – bit 1 and bit 2 both assigned to `J2`, `J1` never set. Fix: J1..J6 = bits 1..6 like `ByteToAxisJointUsed`
 - ST-FIX F10: `PERCENT_INT_TO_REAL` – compares an `INT` with `16#FFFF_FFFF`/`16#0000_FFFF`; depending on the implicit conversion `-1` (16#FFFF) is not recognised as "not supported". Fix: intended meaning implemented: all 16 bits set → -1.0 (spec: 5.6.2 percentage encoding)
 - ST-FIX F12: `MC_MeasuringInputFB.CheckParameterValid` – `SetError( ErrorID := ErrorID := ...)` – duplicated assignment in the argument list. Fix: single `ErrorID :=`
 - ST-FIX F13: `MC_RobotTaskFB.HandleSync` – `HandleSyncToolData` is called twice per cycle (the tool step chain runs at double speed, e.g. `Execute` set and evaluated in the same cycle): single call
 - ST-FIX F14: `MC_RobotTaskFB.HandleAxesGroupSystemData` – `FrameDataPtr`/`WorkAreasPtr` (and Min/Max) are set to **LoadData** (copy & paste) – frame and work area data are written into the load array. Fix: FrameData / WorkAreas
 - ST-FIX F15: `MC_RobotTaskFB.OnExecRun` step 1 – timeout check `(State >= ERROR_161) OR (State <= ERROR_173)` is always TRUE → `ErrorID := TelegramState` also for non-error states: `AND`
 - ST-FIX F16: `MC_Read*FB` (tool/frame/load/SW limits/dynamics) during the synchronisation – the start-up read calls `AxesGroup.SystemData.Update*` and so **overwrites the user data with the RC data** before the comparison – with `CLIENT_TO_SERVER` the PLC data is lost and the comparison always finds equal data. Fix: new input `UpdateSystemData` (default TRUE) of the 7 read blocks, FALSE for the internal instances of the RobotTask; update only on `DONE` (spec: 5.6.7.3: client data wins)
 - ST-FIX F17: `MC_RobotTaskFB.HandleAxesGroupState` – `Unified*Index := MIN(..., X_MAX, ...)` but the internal arrays are `[0..X_MAX-1]` → write/read behind `_toolData` etc.. Fix: `X_MAX - 1`)
 - ST-FIX F18: `MC_RobotTaskFB.HandleSync*Data` – copy loops run over the user array bounds (`ToolDataMin..ToolDataMax`) on the internal arrays `[0..TOOL_MAX-1]` → out of bounds if the user array is longer than `TOOL_MAX` (Python raises `IndexError`): loops limited to `X_MAX - 1`
 - ST-FIX F19: `ActiveCommandRegisterFB.AddRsp` – `FOR _idx := PayloadPointer TO PayloadLength - 1` – for fragments after the first one (`PayloadPointer > 0`) nothing is copied, long responses (e.g. `ReadRobotData`, 134 bytes) are truncated. Fix: `PayloadPointer + PayloadLength - 1`) (spec: 5.6.5 fragmentation)
 - ST-FIX F20: synchronisation `SERVER_TO_CLIENT` – after reading the RC data the client never writes it back, so `DataChanged` on the RC is not reset and the RC never reports `DataInSync` → RI state never "Synchronized". Fix: after the read (step 21) the RC data is written back (step 30) if the RC supports the write command (spec: 5.6.7.4.2: "RobotTask then executes internally WriteToolData to reset DataChanged"; SDK resets `DataChanged` only on write)
 - ST-FIX F21: synchronisation `CLIENT_TO_SERVER` – writes tool/frame/load **0** (flange, world, …); the RC rejects it (SDK `0x8D35` invalid tool number) → warning, sync fails. Fix: tool/frame sync starts at index 1 (loops, start index, `LIMIT(1, …)`), like `LoadData` (spec: 5.5.4: index 0 is fixed (flange))
 - ST-FIX F22: `MC_ReadMessagesFB.ParseResponsePayload` – reads the 255 byte message text at offset 20 of the 256 byte response buffer (`GetDataBlock` copies behind the buffer). Fix: in `GetDataBlock`: missing bytes are 0
 - ST-FIX F23: `RobotLibraryBaseEnableFB` / `MC_RobotTaskFB.Reset` – disabling the RobotTask starts the cancel of the enable FBs (`_cancel`, 5 s timeout); a new enable within this time lets the pending cancel reset `MC_ReadMessagesFB` after its first response → start-up hangs in step 3. Fix: a rising edge of `Enable` ends a pending cancel/error clear; a restart while the RC is still `INITIALIZED` resets the interface (`Control := RESET`, `_restartReset`)
 - ST-FIX F24: `MC_RobotTaskFB.HandleSync` – a data set enabled for synchronisation whose functions the RC does not support (e.g. work areas in the SDK) keeps `Synchronized` FALSE forever. Fix: `_inSync*Ok` also TRUE if the RC does not support read + write (after `Initialized`) (spec: 5.6.7.1: "…or not supported by the RC does not impact the RI state Synchronized")
 - ST-FIX F25: `Valid` output of `MC_ReadActualPositionFB` (and `MC_ReadActualTCPVelocity`, `MC_ReadActualForce`, `MC_ReadAnalogInput`, `MC_ReadDigitalInputs/Outputs`, `MC_ReadIntegers`, `MC_ReadReals`, `MC_ReadSystemVariable`, `MC_CallSubprogram`, `MC_ActivateConveyorTracking`, `MC_SetTriggerLimit`) – `Valid` is never set to TRUE. Fix: output `Valid` (F25_POUS) (spec: 6.1.5: `Valid` like `Done` (TRUE while updated in `Continuous`))
 - ST-FIX F26: `CheckParameterValid` of 31 FBs – `IF ProcessingMode < BUFFERED AND ProcessingMode > TRIGGER_MULTIPLE` is never TRUE. Fix: range check before the enum conversion
 - ST-FIX F27: `MC_ReadToolDataFB`, `MC_ReadFrameDataFB` `.ParseResponsePayload` – `DataChanged` parsed before the index (ToDo "swapped compared to V1.3") → `ToolNoReturn`/`FrameNoReturn` = DataChanged; the sync updates the wrong tool/frame (spec: tables 6-184/6-190 (and SDK): index, then DataChanged (as `MC_ReadLoadDataFB`))
 - ST-FIX F28: `CheckAddParameter` of 32 FBs (list `F28_POUS` in `tools/st2py/config.py`) – a parameter is omitted when the bytes of `_command` **behind the payload position** are zero; this assumes payload order = structure layout. Where it differs non-zero parameters are dropped, e.g. `WriteToolData`: `ToolNo` (payload end, structure start) not sent → SDK 0x8D35; `WriteRobotSWLimits`: upper limits not sent (structure J1Lower, J1Upper, …; payload all lower, then all upper); `MC_EnableRobotFB.HoldToRun`; `E2..E6` of positions. Fix: `CheckAddParameter := TRUE` (complete payload); `tests/unit/tools/test_st2py_f28.py` recomputes the list
 - ST-FIX F29: `MC_RobotTaskFB.OnExecRun` step 8 – `Initialized := NOT ERROR AND NOT Synchronized; Initialized := NOT Synchronized;` – the 2nd line (ToDo) overwrites the first → after an error (e.g. init lost 0x80A2) `Initialized` and `CMDsEnabled` are TRUE again, FBs stay Busy forever. Fix: 2nd line removed: FBs end with `ERR_COMMANDS_NOT_ENABLED`
 - ST-FIX F30: `MC_ReadRobotDataFB.ParseResponsePayload` – `InterpreterCycleTime` read with `GetUsint` → 0 (SDK 10 ms) (spec: table 6-18 / SDK: UINT)
 - ST-FIX F31: `MC_WriteRobotSWLimitsFB.CreateCommandPayload` – `ResetToFactoryDefaults` (byte 106) is never sent (spec: table 6-209)
 - ST-FIX F32: responses of `GroupStop`, `ExchangeConfiguration`, `ReadRobotSWLimits`, `ReadMessages` – fields at the end are not read: `AbortedSequence`, `NumberOfServerLogs`, `DataChanged`; the message text has 150 characters, ST reads 255 (F22). Fix: fields added (`FieldAdd`) and parsed (spec: tables 6-290, 6-87, 6-203, 6-108)
 - ST-FIX F33: payload of 24 extended/optional FBs – layout differs from the spec tables (the bilateral test also found `MC_LoadMeasurementAutomaticFB`: Position_1 complete before Position_2) (shifted by missing/additional bytes, wrong data types, off-by-one loops). List with details: `KNOWN` in `tests/unit/fb/test_payload_spec.py`. Fix: source patches, spline one point per command (spec: chapter 6 payload tables)
 - ST-FIX F34: `MC_UserLoginFB`, `MC_SwitchLanguageFB` – `AddString` writes only the actual length; the spec has fixed fields (`Password`/`Username` 50, `LanguageCode` 2) → `Username` at the wrong offset. Fix: source patches (spec: tables 6-69, 6-76)
 - ST-FIX F35: `CmdType` enum, `MC_MoveLinearAbsoluteJFB`, `MC_SoftSwitchTcpFB` – wrong command types: MoveLinearAbsoluteJ is sent as **MoveLinearAbsolute (2103)** – the RC reads the joint target as Cartesian position; SoftSwitchTcp as ShiftPosition (7205); MoveCircularAbsolute 2109 / MoveCircularRelative 2106. Fix: enum override in `tools/plcopen_gen/overrides.py`, source patches (spec: spec: MoveLinearAbsoluteJ 2109, SoftSwitchTcp 7300, MoveCircularAbsolute 2106, MoveCircularRelative 2107)
 - ST-FIX F36: `MC_SearchHardStopFB`, `MC_SearchHardStopJFB` `.CheckParameterValid` – `FOR _idx := 0 TO 6` over `DetectionVector[0..5]` – reads behind the array (Python: IndexError)
 - ST-FIX F37: `MC_EnableRobotFB`, `MC_MoveCircularRelativeFB` `.CreateCommandPayload` – two BOOLs that are bit 0/1 of **one** byte are sent as two bytes (`HoldToRun`/`ManualStep`, `PathChoice`/`Manipulation`) → `ManualStep`/`Manipulation` land in a reserved byte (not visible in the layout check, sizes happen to fit) (spec: tables 6-25, 6-357)
 - ST-FIX F38: `MC_ReturnToPrimaryFB.CreateCommandPayload` – `AllowDifferences` is never copied into the command → always FALSE (spec: table 6-332)
 - ST-FIX F40: `MC_UnitMeasurementFB`, `MC_SyncToConveyorFB` `.OnApplyOutCmd` – `OutCmd` is only updated in state ACTIVE – the values of a response that is DONE at once are lost
 - ST-FIX F41: defaults of `ParCmd` (`VelocityRate`, `AccelerationRate`, `DecelerationRate`, `JerkRate`, ...) – default `0.0` = "internal minimal" velocity/acceleration; the spec defines "<0 %: (default) use default" → a command with the default values moves with minimal dynamics or is rejected (SDK: DecelerationRate 0 → 0x8E03). Fix: rates default -1.0 (`FieldOverride`), -1.0 → 16#FFFF (spec: chapter 6, e.g. 6.3.2.3)
 - ST-FIX F42: `MC_OpenBrakeFB` – Execute block; the spec defines OpenBrake with **Enable** (brakes stay open while Enable). Fix: `MC_OpenBrakeFB` cloned from `MC_FreeDriveFB` as enable block (spec: 6.x OpenBrake)
 - ST-FIX F43: `MC_FreeDriveFB` – output `Enabled` is never set (only `OutCmd.Enabled`)
 - ST-FIX F44: defaults of several blocks – no valid default: ExchangeConfiguration.LifeSignTimeOut, SetSequence.TargetSequence, SetOperationMode.OperationMode, CollisionDetection.SequenceFlag, Read/WriteLoadData.LoadNo 0, SwitchLanguage/UserLogin (empty), ForceControl, ReadAnalogInput, MoveSpline, SetTriggerRegister. Fix: defaults (ForceControl `ErrorReaction`, MoveSpline `MoveTime`); mandatory parameters documented (spec: Siemens test "valid CMD with the default values")
 - ST-FIX F45: interface of 23 blocks – inputs/outputs of the spec missing or named differently (list `KNOWN_MISSING` in `tests/unit/fb/test_interface_spec.py`, e.g. ReadActualPosition: spec Enable/ReadCartesianPosition/..., WaitTime.Time, GroupStop/SetSequence output Active). Fix: outputs added (`VarAppend`) + name mapping in the interface test (spec: "Associated command/response values")
 - ST-FIX F46: `StopSubprogramOutCmd.OriginID`, `ReadRobotDataOutCmd.RCInterpreterVersion` – no comment. Fix: comments added (`FieldOverride` doc)
 - ST-FIX F47: `MC_ExchangeConfigurationFB`, `MC_ReadMessagesFB`, `MC_ReadRobotDataFB` – without running RobotTask they stay Busy without error (all other blocks: error). Fix: via the command timeout F53
 - ST-FIX F48: 77 blocks – an undefined `ExecMode` (e.g. 18) is neither checked by the block nor rejected by the RC. Fix: undefined `ExecMode` → error, not sent (spec: Siemens "AbortingMode is not defined")
 - ST-FIX F49: `StopSubprogram.SequenceFlag`, `MoveLinearRelative.ReferenceType`, `MovePickPlaceDirect/Linear.BlendingMode`, `WriteAnalogOutput.Unit`, `CollisionDetection.ProcessingMode/SequenceFlag` – undefined enum values are not checked. Fix: enum checks in `CheckParameterValid`
 - ST-FIX F50: base of all Execute blocks – a falling edge of `Execute` before the end cancels the command: Execute for one cycle → nothing is sent; reset during the motion → motion runs, but `Done` is never shown. Fix: `Execute` edge held until the command ends (`_executeIn`/`_executeHold`) (spec: 5.5.x "Output status": the falling edge "does not stop or even influence the execution", outputs set for at least one cycle)
 - ST-FIX F51: motion blocks: inputs `AbortingMode`, `SequenceFlag` – checked but not used: the telegram always has the ExecutionMode of the input `ExecMode` → `AbortingMode = ABORT` has no effect (the new command is buffered). Fix: `ExecutionMode` from `AbortingMode`/`ProcessingMode`/`SequenceFlag` (table 5-77) (spec: 5.6.4.5)
 - ST-FIX F52: `MC_RobotTaskFB` receive part (`RecvData`, fragment loop) – at most `FRAGMENT_MAX + 1` = 10 fragments of a received telegram are parsed, the others are dropped with a DEBUG message only - but the telegram is acknowledged, so the RC considers them delivered → the responses are lost and the function blocks stay `Busy` forever (e.g. 16 GroupInterrupt in one cycle: the SDK sends 12 DONE fragments in one telegram, 2 are lost). Fix: `FRAGMENT_MAX` = 31; overflow logged as ERROR (spec: 5.6.5.3: no limit of fragments per telegram (header 8 bytes, a 256 byte telegram holds up to 27 fragments))
 - ST-FIX F53: 112 function blocks, `OnExecRun` – `SetTimeout(PT := _timeoutCmd, ...)` is called, but the timer is never evaluated while waiting for the response → no error when a response never arrives (see F52). Fix: command timeout
 - ST-FIX F54: `MC_CreateSplineFB`, `MC_DynamicSplineFB` – loops `FOR _idx := 0 TO SPLINE_DATA_MAX` over `SplineData[1..SPLINE_DATA_MAX]` → access before the array: loop from 1
 - ST-FIX F55: `MC_CreateSplineFB`, `MC_DynamicSplineFB` `.CreateCommandPayload` – the positions of the spline points are never copied into the command → always 0 sent (spec: tables of CreateSpline / DynamicSpline)
 - ST-FIX F56: `MC_RobotTaskFB.HandleSeqAck` – the Seq number wraps from 254 to **0**; an Ack of 0 equals the Ack of telegrams without new data → the response of that sequence is ignored, the block hangs (after 255 sequences): wrap to 1 (`test_sequence_number_overflow`); the fix is part of the new `HandleSeqAck` of F63 (solve guide F63) (spec: 5.6.5.3: 0 only on the first exchange)
 - ST-FIX F57: `MC_RobotTaskFB.HandleSync*` step 10 – the local change detection compares with `IgnoreTimestamp := FALSE`, but the internal copy holds the timestamp of the RC from the start-up read → every data set counts as changed on the PLC; together with the RC "not in sync" → warning "both sides changed", no synchronisation: `IgnoreTimestamp := TRUE`
 - ST-FIX F58: `MC_RobotTaskFB.HandleSync*` step 10 – data changed on both sides only sets the warning `WARN_*_SYNC_BOTH_SIDES_CHANGED`, also with a fixed direction (`CLIENT_TO_SERVER` / `SERVER_TO_CLIENT`) → synchronisation stops: step 11 / 12 for the fixed directions, warning only for `AUTOMATIC` (spec: 5.6.7.4: the direction decides)
 - ST-FIX F59: `MC_RobotTaskFB.AxesGroupFromTelegramCyclicOptional`, `MC_ReadActualPositionCyclicFB.OnExecRun` – the RobotTask writes the **currently used** tool/frame (bytes 36..37 of table 5-89) into `CoordinateSystem`; `ReadActualPositionCyclic` compares it with the requested `ToolNo`/`FrameNo` → as soon as a motion uses another tool the outputs are never updated again (all zero), `Enabled` stays TRUE; the output `CoordinateSystem` is never set. Fix: new field `CurrentCoordinateSystem` in `AxesGroupCyclicOptionalDataCartesianPosition`, `CoordinateSystem` from bytes 34..35, both outputs set (found by the Core example) (spec: 6.1.6: `CoordinateSystem` = tool/frame of the returned position, `CurrentCoordinateSystem` = currently used)
 - ST-FIX F60: `MC_RobotTaskFB.AxesGroupFrom/ToTelegramCyclicOptional`, `CombineHalfSints` – turn numbers of the optional cyclic Cartesian position are decoded/encoded as two's complement nibble (like F3). Fix: source patches + `CombineHalfSints` (spec: 5.5.4.4 sign + magnitude)
 - ST-FIX F61: `RobotLibraryBaseFB` (body, `CallBack`, `ParseResponsePayload`) – `Error := ErrorID <> 0` is computed in `OnCall` *before* the parameter check / response evaluation → one cycle `ErrorID ≠ 0` with `Error = FALSE`; with a parameter error `Execute` is TRUE without any of Busy/Done/Error; ACR full (16#8618) leaves `Busy` and `Error` TRUE; GroupJog `Active` and `Error` TRUE; response state ERROR without error code ends the FB without Done and without Error (spec audit B-01…B-05). Fix: at the end of the body and of `CallBack`: `Error := ErrorID <> OK`, with Error `OnUpdateStateFlags(ERROR)` (resets Busy/Active/Done of every FB); state ERROR without code → 16#8613 (spec: 5.5.10, table 5-45 (Busy/Done/Error/CommandAborted exclusive), table 7-1 16#8613)
 - ST-FIX F62: `RobotLibraryBaseFB.ParseResponsePayload` – every response clears `InfoID`/`WarningID`/`ErrorID` (also warnings of the client, e.g. from the parameter check) (B-06). Fix: IDs are only overwritten by reported messages, cleared by `Reset` (spec: 5.5.10: IDs are held like Done until the falling edge of Execute/Enable)
 - ST-FIX F63: `MC_RobotTaskFB`: `HandleSeqAck`, `AxesGroupToTelegram(Sequence)`, `CheckParameterValid`, telegram coding (`CreateSendPayload(Sequence)`, `ParseRecvPayloadSequence`, `CalculateSequencePayloadMax/StartAdr`) – **two telegram sequences do not work**: the RobotTask never finishes the initialization (A-01); the 1st sequence fills the whole telegram (`SEQUENCE_MAX_PAYLOAD_SIZE` unused, A-02); `CalculateSequencePayloadMax(PRIMARY)` not halved, footer not subtracted (A-03); header/ACK of the 2nd sequence only sent/evaluated sometimes (`SequenceCountSend`, A-04); `_fragIdx` not reset per sequence (A-05); receive order not by Ack (A-06); start values (A-07); `NewSEQ[1]` never reset and the whole PLC→RC telegram cleared when sequence 1 gets a new Seq; no check `Com.TwoSequences` vs `UseTwoSequences` (A-08) (open: telegram coding of the second sequence in `CreateSendPayloadSequence` / `ParseRecvPayloadSequence`). Fix: own area per sequence, both headers always sent, lower Ack/Seq first, next Seq = other sequence + 1 (common counter, 254 → 1 like F56), start values 0/1, per-sequence clear, Ack only accepted if = sent Seq, 16#80AB on inconsistent configuration; test against the SDK (spec: 5.6.5.3 "Multiple Sequences", Fig. 5-205…5-208, table 7-2 16#80AB; SDK `04_Network.cpp` (area = telegram − cyclic − footer, 1st = area/2))
 - ST-FIX F64: `MC_MoveSplineFB`, `MC_MoveSuperImposedFB`: `OnUpdateStateFlags` – state DONE sets `Done := FALSE` (copy error) → the FB never signals Done, `Execute` TRUE without any status. Fix: `Done := TRUE` (found by the output invariants) (spec: 5.5.10)
 - ST-FIX F65: `MC_RobotTaskFB`: `OnCall`, `OnExecRun` step 1, `HandleLifeSign`, `HandleSeqAck` – loss of the initialization always 16#80A2 even if the RC reports the reason in the telegram state (C-01); lifesign timeout of the RC reported as 16#8AAD "connection lost" (C-02); no telegram sequence timeout (C-03). Fix: RI error of the RC (16#A1…16#AD) from the telegram state, 16#80A7 when the RC is ready for (re)initialization again, 16#80A2 otherwise; lifesign 16#80A5; no new Seq number for 4 × LifeSignTimeOut → 16#80A8, not initialized (spec: 6.1.1, 5.6.5.3/5.6.6.2 (4 × LifeSignTimeOut), tables 5-103 and 7-2)
 - ST-FIX F66: `MC_RobotTaskFB.HandleInvalidFrames`, body – frames with different lifesign in header and footer are counted but **processed**; the footer is read at the end of the *buffer* instead of the telegram (C-04). Fix: footer at `TelegramLengthRobToPlc − 1`, invalid frame not parsed (spec: 5.6.6.2 (header/footer lifesign))
 - ST-FIX F67: `MC_RobotTaskFB.AxesGroupToTelegramSequence` – remaining space for acyclic data not checked (C-05). Fix: < sequence header + 1 byte → 16#8002 / 16#8003 (spec: 6.1.1 ("less than 1 byte → error"), table 7-2 16#8002/8003)
 - ST-FIX F68: `MC_RobotTaskFB.CheckParameterChanged` – changed optional cyclic configuration during operation → **error** 16#8013 (C-06). Fix: warning 16#7003 (takes effect after re-initialization) (spec: 6.1.1: warning; table 7-3 16#7003)
 - ST-FIX F69: `CheckParameterValid` of the FBs with EmitterID / ListenerID / SequenceFlag – EmitterID −128 / ListenerID < 0 reported as 16#0008; ListenerID not checked against the ProcessingMode (> 0 in trigger modes, 0 otherwise); SequenceFlag not checked against the ProcessingMode (D-01…D-03). Fix: 8627 "EmitterID must be 0" – condition not specified, not used (spec: tables 5-62, 6-496 (and the other ProcessingMode tables), 7-1: 16#8604, 16#8635, 16#8626, 16#8605, 16#8625)
 - ST-FIX F70: `CheckParameterValid` of 10 Read FBs, `MC_GroupJogFB` – ProcessingMode / SequenceFlag not allowed → 16#0008; GroupJog Override → 16#8401 (D-04…D-06) (spec: table 7-1: 16#8603, 16#8616, 16#8410)
 - ST-FIX F71: `RobotLibraryBaseExecuteFB/EnableFB.OnExecStart` – input `Priority` never checked (D-08). Fix: 1…4 (spec: table 7-1: 16#8610/8611)
 - ST-FIX F72: `MC_CallSubprogramFB.CheckParameterValid` – acyclic data > 190 bytes not rejected (D-09). Fix: limit 190 bytes (16#8417: the library has no ReturnAcyclicData – not applicable) (spec: table 7-1: 16#8416)
 - ST-FIX F73: `MC_ReadActualPositionCyclicFB.OnExecRun` – ToolNo/FrameNo −1 ("currently used", 255 in the telegram) never equal to the returned coordinate system → `Enabled` never set, outputs never updated (D-10). Fix: −1 matches any returned tool/frame (spec: 6.1.6)
 - ST-FIX F74: `RobotLibraryBaseFB.OnCall`, `AxesGroupMessageLogFB.AddMessageLog`, `AlarmMessage` – messages of the command only with the severity of the last RC response → client-side errors (parameter check) never in the message buffer; `AcrID`/`CmdType` missing (E-01, E-03). Fix: error/warning/info of the FB with their own severity, `AlarmMessage.AcrID/CmdType` (filled when the command was created) (spec: 5.5.11, Fig. 5-137, 7.1)
 - ST-FIX F75: enums `RobotLibraryErrorIdEnum`, `RobotLibraryInfoIdEnum` – IDs of the spec missing (16#8D52…8D60, 8D89…8D98, 8E22, 16#6C70, 6D54); names with a wrong value (`ERR_LIFESIGN_TIMEOUT_0x8005` = 16#8004, `ERR_TELEGRAM_SEQ_TIMEOUT_0x80A8_0x80A8`) (E-05, C-08). Fix: elements added, alias names with the correct value (spec: tables 7-1, 7-2, 7-4)
 - ST-FIX F76: `MC_GroupResetFB.OnExecRun` – after DONE the FastStop half byte is set back to 0. The RC counts every change of the half byte as new stopping commands (e.g. 2 -> 0 = 14), its FastStop counter stays > 0 and no motion is executed any more until the next initialization (found with SRCI_PY_HMI: GroupStop, GroupReset, next move hangs; probably also the INTERRUPTED moves of the JAKA MiniCobo). Fix: half byte not reset (only at the initialization, RobotTask) (spec: 5.6.6.2.1)
 - ST-FIX F77: `MC_MonitorWorkAreaFB`, `MC_MoveSuperImposedDynamicFB`, `MC_ReturnToPrimaryFB` `.OnExecRun` – blocks on `RobotLibraryBaseFB` (not on the Execute/Enable base) do not check `CMDsEnabled` → without running RobotTask they send the command into the ACR and stay `Busy` (found by the TcUnit tests of the PLC library: axes group with data; in Python only an empty axes group was tested, where the parameter check failed by chance). Fix: ERR_COMMANDS_NOT_ENABLED like the Execute/Enable blocks (spec: 5.5.x output status)
 - ST-FIX F78: `RobotLibraryBaseEnableFB.OnCall` – the RC answered with an error, Enable FALSE starts the error clear (waits up to 5 s for a response); a new rising edge of Enable in this time is consumed while `Error` is still TRUE → nothing sent, no `Busy`, no `Error` (found by the TcUnit test PM-03: the instance is reused). Fix: the new enable clears the old error first (spec: 5.5.x output status)
 - ST-FIX F79: `MC_RobotTaskFB.OnExecRun` step 1 – the init timeout reports the *momentary* telegram state; the RobotTask answers an error state with ACK_ERROR / RESET / INITIALIZE, so the error (e.g. 16#A4 SRCI major version) is only visible part of the time → depending on the phase `ERR_TIMEOUT_CMD` instead of the reason (TcUnit test SDK-RT-007, ~4 ms per robot cycle on the PLC). Fix: last error state of the initialization reported (spec: 5.6.2)
 - ST-FIX F80: `MC_SetTriggerMotionFB.CheckParameterValid` – `TriggerMode_2` = 0 (undefined, the default: only `TriggerMode_1` is used) was rejected with 16#0008 (TcUnit test GEN-05). Fix: `TriggerMode_2` UNDEFINED allowed (spec: table 6-692)
 - ST-FIX F81: `AxesGroupSystemDataFB.UpdateToolData` – the copy into the `ToolData` array of the RobotTask was commented out (`{warning 'ToDo: Compiler Fehler'}`), so Write/ReadToolData did not update the PLC copy (frames, loads and work areas were stored). Fix: copy like `UpdateFrameData`, pointer declared as `POINTER TO Tool` (spec: 6.2.11)
 - ST-FIX F82: `MC_ReadActualPositionCyclicFB.OnExecRun` – for the extended joint position `OutCmd.ReadingCartesianPositionExt` was set instead of `ReadingJointPositionExt` (copy & paste). Fix: own flag (spec: 6.1.6)
 - ST-FIX F83: `CheckParameterValid` of the 22 blocks with `SequenceFlag` (check of F69) – the check "sequence mode ⇔ SequenceFlag" also applied to `ProcessingMode` DEACTIVATE, so an action started in a sequence could not be deactivated with its SequenceFlag (16#8625) and `MC_WaitForTriggerFB` not at all. Fix: DEACTIVATE excluded from the check (spec: 5.6.4.5)
 - ST-FIX F84: `MC_MoveLinearCamFB.CheckParameterValid` – `TriggerDelay` > 255 ms was rejected (16#0008), although it is a UINT [ms]; `MC_MoveCircularCamFB` allows 65535. Fix: limit 16#FFFF (spec: 6.4.8)
 - ST-FIX F85: `MC_ConfigureConveyorFB.CheckParameterValid` – `ConveyorType` was compared with `LINEAR_CONVEYOR_TRACKING` twice, so `CIRCULAR_CONVEYOR_TRACKING` was rejected. Fix: second comparison `CIRCULAR_CONVEYOR_TRACKING` (spec: 6.3.29)
 - ST-FIX F86: `MC_ForceControlFB.CheckParameterValid` – `ConnectionMode` was tested against `PLC_SENSOR_RC_ALGORITHM` twice, so `PLC_SENSOR_ALGORITHM` was rejected. Fix: second comparison `PLC_SENSOR_ALGORITHM` (spec: 6.5.24)
 - ST-FIX F87: `MC_UserLoginFB.CheckParameterValid` – an empty `Username` was rejected also in the modes without user name. Fix: check only with `Mode` `USERNAME_AND_PASSWORD` (spec: 6.1.10)
 - ST-FIX F88: `MC_StopSubprogramFB.CheckParameterValid` – `TargetID` (JobID / InstanceID, UINT in the telegram, -1 = all) was limited to 255 and reported `ERR_LISTENERID_MUST_BE_POSITIVE`. Fix: limit 65534, error `ERR_INVALID_PAR_CMD` (spec: 6.5.21)
 - ST-FIX F89: `MC_MoveSuperImposedFB.CheckParameterValid` – `ProcessingMode` TRIGGER_CONTINUOUS was rejected, although the spec allows it. Fix: allowed (spec: 6.3.30)
 - ST-FIX F90: `MC_MeasuringInputFB.OnApplyOutCmd` – `OutCmd.MeasuringID` was set only at DONE, so a running measurement could not be aborted by its ID with `MC_AbortMeasuringInputFB`. Fix: also set while ACTIVE (spec: 6.4.14)
 - ST-FIX F91: `MC_WriteAnalogOutputFB.CheckParameterValid` – `Index` 0 was accepted (spec 1..32, like `MC_ReadAnalogInputFB`). Fix: lower limit 1 (spec: 6.4.13)
 - ST-FIX F92: `MC_UnitMeasurementFB.CheckParameterValid` – an invalid `MeasuringMode` was reported as `ERR_PROCESSINGMODE_NOT_ALLOWED`. Fix: `ERR_INVALID_PAR_CMD` (spec: 6.5.37)

### Not changed (documented only)
 - F4 dead code in `ParseRecvPayload`, F7 `GetDword` of the status word (correct without byte swap), F8 footer size (conservative), F11 `TurnNumber` cannot represent "-0", F39 to be reviewed

## [1.5.0.0] - 2026-09-19

### Changed
 - Release of the implementation for the SRCI V1.5 specification (It's been lying around here way too long)
 - Changed the license from LGPL V3.0 to MIT in order to achieve broader acceptance

## [0.0.0.50] - 2025-10-01

### Added
 - Added `NotifyParameterChanged` log message in all `CheckParameterChanged` methods
 - Added new error ID `ERR_MAXIMUM_DISTANCE_EXCEEDED`
 - Added new error ID `ERR_INVALID_SAFEREFERENCE_POSITION`
 - Added new error ID `ERR_SAFETY_SENSOR_NOT_TRIGGERED`
 - Added new error ID `ERR_RESTART_WHILE_ROBOT_MOVING`
 - Added new error ID `ERR_UNSUPPORTED_COMBINED_JOG`
 - Added new error ID `ERR_GROUPRESET_PENDING_MESSAGES`
 - Added new error ID `ERR_EXPORTMODE_NOT_EXIST`
 - Added new error ID `ERR_EXPORTNAME_NOT_EXIST`
 - Added new error ID `ERR_EXPORTNAME_ALREADY_EXISTS`
 - Added new error ID `ERR_DATALOG_NO_MEMORY_LEFT`
 - Added new error ID `ERR_DATALOG_ERROR_OCCURRED`
 - Added new error ID `ERR_INTERNAL_UNDEFINED_STEP`
 - Added new error ID `ERR_PRIORITY_TOO_LOW`
 - Added new error ID `ERR_PRIORITY_TOO_HIGH`
 - Added new error ID `ERR_INTERNAL_ERROR_WITHOUT_ID`
 - Added new error ID `ERR_POSITION_NOT_REACHABLE`
 - Added new error ID `ERR_CONFIG_MODES_MUST_BE_IDENTICAL`
 - Added new error ID `ERR_OPTIONAL_PARAM_MAXIMUM_DISTANCE_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_CIRCMODE_VALUE_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_IX_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_IY_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_IZ_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_RX_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_RY_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_RZ_NOT_SUPPORTED`
 - Added new error ID `ERR_OPTIONAL_PARAM_INCREMENTAL_JOG_NOT_SUPPORTED`
 - Added new warning ID `WARN_INVALID_ROBOT_STATE_MULTIPLE_CMDS_ACTIVE`
 - Added new warning ID `WARN_PARAM_CHANGE_NOT_POSSIBLE_DEACTIVATE_FIRST_CTX`
 - Added new warning ID `WARN_PARAM_CHANGE_NOT_POSSIBLE_DEACTIVATE_FIRST`
 - Added new warning ID `WARN_HOLD_TO_RUN_REQUIRES_MOTION_IN_SEQUENCE`
 - Added new warning ID `WARN_TRIGGER_EVENT_WITHOUT_ASSOCIATED_ACTION`
 - Added new warning ID `WARN_TRIGGER_MODE2_NOT_SUPPORTED_FOR_ALL_MOVES`
 - Added new warning ID `WARN_SAFE_REFERENCING_VELOCITY_REDUCED`
 - Added new warning ID `WARN_SAFE_REFERENCING_ADDITIONAL_STEPS_REQUIRED`  
 - Added new Info ID `INFO_CONTINUOUS_UPDATE_NOT_POSSIBLE`
 - Added new Info ID `INFO_CMD_BOUND_TO_INSTANCE_CONTINUOUS_MODE`
 - Added new Info ID `INFO_CONTINUOUS_UPDATE_NOT_POSSIBLE`
 - Added new Info ID `INFO_CMD_BOUND_TO_INSTANCE_TRIGGER_MODE`
 - Added `StatusRobotArm` informations to `AxesGroup.State`

### Changed

 - Changed telegram of `MC_EnableRobotFB` - moved `ManualStep` to `Bit 01` of the same byte as `HoldToRun` and added a reserve byte at the end.
 - Changed `OnApplyOutCmd` method of `MC_ReadRobotDefaultDynamicsFB`,  to use `PERCENT_UINT_TO_REAL` function instead of `PERCENT_INT_TO_REAL(UINT_TO_INT(...)` function, which returned -0.01 instead of -1.
 - Changed `OnApplyOutCmd` method of `MC_ReadRobotReferenceDynamicsFB`, to use `PERCENT_UINT_TO_REAL` function instead of `PERCENT_INT_TO_REAL(UINT_TO_INT(...)` function, which returned -0.01 instead of -1.
 - Changed `OnApplyOutCmd` method of `MC_WriteRobotDefaultDynamicsFB`,  to use `PERCENT_UINT_TO_REAL` function instead of `PERCENT_INT_TO_REAL(UINT_TO_INT(...)` function, which returned -0.01 instead of -1.
 - `OutCmd.DynamicValues.Timestamp` of `MC_ReadRobotReferenceDynamicsFB` was not updated in `OnApplyOutCmd` method.
 - `OutCmd.ReferenceDynamicValues.Timestamp` of `MC_WriteRobotReferenceDynamicsFB` was not updated in `OnApplyOutCmd` method.
 - Changed conditions for acknowledge new `MsgID` in `HandleLogMessagesAck` method in `MC_RobotTaskFB`
 - Reset `Initialized` flag of `RobotTaskFB` in `OnExecRun` method in case of error
 - Changed `OutCmd.Progress` of all motion commands to `optional`, so that a value of `65535` is interpreted as `-1`
 - Reset `Busy` flag of `MC_EnableRobotFB` in `UpdateStateFlags` method if target state is reached
 - Changed condition of `step 1` in `HandleSyncFrameData`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncLoadData`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncRobotDefaultDynamics`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncRobotReferenceDynamics`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncRobotSWLimits`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncToolData`, to additionally check the `Done` state
 - Changed condition of `step 1` in `HandleSyncWorkArea`, to additionally check the `Done` state
 - Fixed a bug in `HandleSyncToolData` method of `MC_RobotTaskFB` , that the `SynchronizationModes` of `SWLimits` was used instead of `Tool`
 - Fixed a bug in `ParseRecvPayloadSequence` method of `MC_RobotTaskFB`, that the payload was not correctly added to a command when the payloadpointer was not zero
 - Fixed a bug in `GroupJog` FB, that the `Busy` was not reset when the command becomes `Active` - which triggered a `Cancel` if the `Enable` flag was set to `FALSE` again.
 - Fixed a bug in `GroupJog` FB, that the response parameter was not logged because the parameter count was not incremented during parsing the response message.
 - Fixed a spelling mistage in some log messages `cancled` instead of `cancelled`
 
## [0.0.0.49] - 2025-09-12

### Added

 - Added feature : Allowing data packet to be configured individually per robot instance by using ARRAY[*]. #14
 - Added feature : Allowing data sizes for Tool, Load, Frame and WorkAreas to be configured individually per robot instance by using ARRAY[*]. Related to #14
 - Added property `HasError` which returns `TRUE` if an error is set.
 - Added property `HasWarning` which returns `TRUE` if a warning is set.
 - Added property `HasInfo` which returns `TRUE` if an info is set.
 - Added new method `SetError` that allows setting an internal FB error.
   Includes parameter `Overwrite` to control whether an existing error should be replaced. All affected code locations have been updated accordingly.
 - Added new method `SetWarning` that allows setting an internal FB warning. 
   Includes parameter `Overwrite` to control whether an existing warning should be replaced. All affected code locations have been updated accordingly.
 - Added new method `SetInfo` that allows setting an internal FB info. 
   Includes parameter `Overwrite` to control whether an existing info should be replaced. All affected code locations have been updated accordingly.
 - Added new FB `SystemDataFB` to `AxesGroup` providing array sizes and pointers of system data to the corresponding Read/Write FBs. 
   This allows to automatically update system data storage for Tool, Load, Frame, WorkAreas, which is a requirement of the SRCI specification.
 - Added error handling for error 'ERR_PROCESSINGMODE_NOT_DEFINED' to all FBs that use the `ProcessingMode`parameter.

### Changed
 - Refactored all command FBs by moving the update of FB `StatusFlags` into a dedicated method `OnUpdateStateFlags` to keep to code `OnExecRun` of cleaner.
 - Refactored all command FBs by moving the update of FB `OutCmd` into a dedicated method `OnApplyOutCmd` to keep to code `OnExecRun` of cleaner.
 - Modified behavior of StatusFlag `Busy` in all `Enable` FBs. 
   Previously, `Busy` was reset on the rising edge of `Enabled` - Now it remains `TRUE` for the entire duration the FB is enabled.
 - Modified behavior of StatusFlag `ParameterAccepted`. 
   Previously, it was only set to `TRUE` once the command entered the Active state - Now switches to `TRUE` when a command is buffered.

### Removed
 - Removed library constant `ROBOT_IN_DATA_MAX` as it is no longer needed due to the use of `ARRAY[*]`. Related to #14
 - Removed library constant `ROBOT_OUT_DATA_MAX` as it is no longer needed due to the use of `ARRAY[*]`. Related to #14

## [0.0.0.48] - 2025-08-22

### Added

 - Added `PLCManufacturedID` to `UserData` and assign value from _parCfg.Plc.Parameter of `MC_RobotTaskFB`
 - Added `PLCOrderID` to `UserData` and assign value from _parCfg.Plc.Parameter of `MC_RobotTaskFB`
 - Added `PLCSerialNumber` to `UserData` and assign value from _parCfg.Plc.Parameter of `MC_RobotTaskFB`
 - Added `PLCFirmwareVersion` to `UserData` and assign value from _parCfg.Plc.Parameter of `MC_RobotTaskFB`
 - Added `PLCInterfaceVersion` to `UserData` and assign value from _parCfg.Plc.Parameter of `MC_RobotTaskFB`

### Changed
 - Corrected a spelling mistake: renamed `CurrenArcUsagePercent` to `CurrentAcrUsagePercent`
 - Corrected some spelling mistakes: changed `ARC` to `ACR` (A)ctive (C)ommand (R)egister 
 - Reset `CurrentArcUsageCount` in `Reset` method of `ActiveCommandRegisterFB`.
 - Reset `CurrentArcUsagePercent` in `Reset` method of `ActiveCommandRegisterFB`.
 - LifeSign counter in `HandleLifeSign` method of `MC_RobotTaskFB` is now reset to 0 in case that the Enable input of `MC_RobotTaskFB` is FALSE.
 - Pre-initialized `AxesGroupID` of `MC_RobotTaskFB` with value `0` again instead `1` ( 1 looks like a misstake in der SRCI specification ).
 - In case of `TelegramState` errors `TelegramCtrl.Reset` is used instead of `TelegramCtrl.ACK_ERROR` to acknowledge the error, because with `TelegramCtrl.ACK_ERROR` the ARC is not reset on the robot side. 
 - Fixed a bug that the `Initialized` Bit of the `MC_RobotTaskFB` was set to early, because of the command order change in the previous `V0.0.0.47` update
 - Fixed a bug that the `Busy` Bit of the `MC_RobotTaskFB` was reset to early, because of the command order change in the previous `V0.0.0.47` update
 - Harmonized Logging messages for ACR log messages starting with `ARC-ID [x] :` 
 - Changed the `Severity` of the ACR log messages from `Severity.DEBUG` to `Severity.INFO`
 - Check `Severity` at the begin of all `CreateLogMessage` FBs to protect unnecessary sub method calls.
 - Assigned `InternalLogger` interface to `ActiveCommandRegisterFB` which was previously missing, so that ACR log messages was not displayed in `SystemLog`.
 - Increased the string length of variable `Name` from `20` to `80` in `RobotLibraryBaseFB` ( it is inherited by all other FBs ) 
 - Skip HandleSync action if no synchronization is configured (neither at startup nor after). (Temporary solution, not final yet)
 - Example Beckhoff : Switched from `AdsAndFileLoggerFB` to `FileLoggerFB` and added method `HandleLogger` in `Robot (PRG)`. 
 - Example Beckhoff : Changed `LogLevel` in `RobotTask` from `LogLevel.DEBUG` to `LogLevel.INFO`
 - Example Codesys  : Created a codesys based FileLoggerFB and added method `HandleLogger` in `Robot (PRG)`. 
 - Example Codesys  : Changed `LogLevel` in `RobotTask` from `LogLevel.DEBUG` to `LogLevel.INFO`


## [0.0.0.47] - 2025-08-11

### Changed
 - Moved `InvalidFrames` counter from `MC_RobotTaskFB` to `AxesGroup.State`.
 - Removed `AxesGroupInstances` counter from `RobotLibraryDefines`.
 - Pre-initialized `AxesGroupID` of `MC_RobotTaskFB` with value `1`.
 - Reset `Synchronized` flag of `MC_RobotTaskFB` on LifeSign timeout or TelegramState error.
 - Return TelegramState errors as `ErrorID` in `MC_RobotTaskFB`.
 - Handle Byte-Order-Swap in `WordToArmConfigShoulder` , which was previously missing and led to an incorrectly applied shoulder configuration.
 - Handle Byte-Order-Swap in `WordToArmConfigElbow` , which was previously missing and led to an incorrectly applied elbow configuration.
 - Handle Byte-Order-Swap in `WordToArmConfigWrist` , which was previously missing and led to an incorrectly applied wrist configuration.
 - Fixed bug in `AddArmConfig` method of `RobotLibrarySendDataBaseFB` that could previously lead to an incorrectly applied arm configuration.
 - Renamed `TelegramState` enum items to more meaningful names.
 - Modified `TELEGRAM_STATE_TO_STRING` function according to the changes in the `TelegramState` enum items.
 - Reset `ErrorAddTxt` in the `Reset` method of `MC_RobotTaskFB`.
 - Changed execution order of commands in the `OnExecRun` method of `MC_RobotTaskFB`.
 - Corrected a spelling mistake: renamed `ARC_USAGE_WARNING_LIMIT` to `ACR_USAGE_WARNING_LIMIT`.
 - Fixed a wrong log message text in `CreateCommandPayloadLog` method of `MC_ShiftPositionFB`.
 - Fixed a wrong log message text in `CreateCommandPayloadLog` method of `MC_MoveDirectAbsoluteFB`.

## [0.0.0.46] - 2025-08-02

### Added
 - Added two missing reserve bytes in `GroupJogSendData`.
 - Introduced `ReadingCartesianPosition`, `ReadingCartesianPositionExt`, `ReadingJointPosition`, and `ReadingJointPositionExt` flags to the `AxesGroupState` structure.
 - Added missing comments to some variables for better code documentation.

### Changed
 - Moved the configuration of two sequences from global library parameters to the local `ParCfg.Com` of `RobotTaskFB`, enabling instance-specific configurations.
 - Fixed a bug in the split transmission of command payloads where too few bytes were added.
 - Fixed a bug in `ReadToolData` where ToolNo was transmitted as `SINT` instead of `USINT`, causing the tool values of the `Flange` to always be returned.
 - Fixed a bug in `ReadFrameData` where the date was parsed as `USINT` instead of `UINT`, resulting in incorrect values.
 - Fixed a bug in `ReadRobotData` where the robot interpreter version was displayed with special characters (e.g., $0). Changed the variable to `STRING(5)` and added a dot separator between version numbers.
 - Updated `RemainingDistance` and `Progress` values of all motion commands during the `ACTIVE` state, not just upon reaching the `DONE` state.
 - The `RemoveCmd` method of `ActiveCommandRegisterFB` now returns feedback indicating whether the command was successfully removed.
 - Fixed a bug in all FBs inheriting from `EnableBaseFB` where, in case of cancelation, no telegram with `Enable` = `FALSE` was sent if the `RemoveCmd` method failed because the command was already executing.
 - Fixed a bug in all FBs inheriting from `ExecuteBaseFB` where, after a reset, the `RemoveCmd` method was called with `UniqueID` = `0` due to the reset clearing the ID.
 - Overrode the `OnCall` method of `MC_ReadActualPositionCyclicFB` to update the `AxesGroup.State` flags for reading position data. The base implementation of `OnCall` is still invoked.
 - Updated the `ReadingCartesianPosition`, `ReadingCartesianPositionExt`, `ReadingJointPosition`, and `ReadingJointPositionExt` flags in the `HandleUserData` method of `RobotTaskFB`.
 - Hid several local variables from the online view using the `hide` pragma to improve clarity and reduce visual clutter in diagnostics.
 - Removed the `CreateUniqueID` method from `ActiveCommandRegisterFB`, as the `UniqueID` corresponds to the `ARC index`.
 - Improved logging in `ActiveCommandRegisterFB` by including the current `ARC index` and `CmdType` where previously missing.
### Removed
 - Removed several `ToDo` pragmas, as the associated items were clarified and already correctly implemented (primarily regarding `ListenerIDs` / `EmitterIDs`, which are always 0).
 - Removed unused structure `AxesGroupAcyclicAcrEntryCmd`
 - Removed unused structure `AxesGroupAcyclicAcrEntryCmdHeader`
 - Removed unused structure `AxesGroupAcyclicAcrEntryCmdTrigger`
 - Removed unused structure `AxesGroupAcyclicAcrEntryRsp`
 - Removed unused structure `AxesGroupAcyclicAcrEntryRspHeader`
 - Removed unused structure `AxesGroupAcyclicAcrEntryRspTrigger`
 - Removed unused structure `AxesGroupParameterCmdEntry`


## [0.0.0.45] - 2025-07-24

### Added
 - Constant `HAS_ERROR = -1` to allow checking function return values for `-1` in a more readable way.
 - New method `CheckAddParameter` to determine whether a parameter needs to be sent or can be omitted—along with all following parameters — if it and the remaining values are null.
 - Property `IsPayloadRemaining` to `RobotLibraryResponseDataFB`, which returns `TRUE` if there is remaining data in the payload. This is relevant for parsing incoming payloads that may have been shortened.

### Changed
 - Outgoing payload generation was optimized to include only as many parameters as actual values are present in the message. Trailing null values are omitted to save payload size, in accordance with the specification.
 - Outgoing payload logging now excludes trailing parameters with null values that were not transmitted.
 - Incoming payload handling now imports only parameters that have non-null values, assuming the sender already shortened the message accordingly.
 - Incoming payload logging now logs only parameters that actually received a value from the payload.
 - Logging during payload parsing now includes the number of parsed parameters in the initial log message.
 - Logging during payload sending now includes the number of transmitted parameters in the initial log message.
 - `OnExecCancel` is now called repeatedly until it returns either `OK` or `HAS_ERROR`, instead of being called only once. This change applies to both `RobotLibraryBaseExecuteFB` and `RobotLibraryBaseEnableFB`.
 - `OnExecErrorClear` is now called repeatedly until it returns either `OK` or `HAS_ERROR`, instead of being called only once. This change applies to both `RobotLibraryBaseExecuteFB` and `RobotLibraryBaseEnableFB`.
 - Overridden the `OnExecErrorClear` method in all `RobotLibraryBaseEnableFB` derivatives to ensure that an additional telegram with `Enable = FALSE` is always sent when acknowledging an error. This prevents functions—such as `GroupJog`—from getting stuck in certain cases.


## [0.0.0.44] - 2025-07-01

### Added
 - Example project for `Beckhoff`
 - Example project for `Codesys`
  
### Changed
 - Build.yml to add the example project to the release

## [0.0.0.43] - 2025-05-29

### Added
 - function-specific initial value for `ExecMode` variable in all function FBs within the FB_init method.
 - function-specific initial value for `Priority` variable in all function FBs within the FB_init method.
 - function-specific initial value for `ProcessingMode` variable in all function FBs within the FB_init method.
 - function-specific initial value for `AbortingMode` variable in all function FBs within the FB_init method.
 - function-specific initial value for `SequenceFlag` variable in all function FBs within the FB_init method.
 - missing Synchronized flag check and combined it with Initialized condition where applicable.

### Changed
 - moved declaration of `ARC_USAGE_WARNING_LIMIT` from `Constant` GVL to `Parameter` GVL.
 - moved `ProcessingMode` variable from ParCmd structure to FB header in `MC_ActivateNextCommandFB`.
 - Completly revised `MC_ReadCallSubprogramCyclic` function. 
 - Corrected some incorrect error code assignments.
 - Changed base FB type of `MC_ActivateConveyorTrackingFB` and adjusted implementation accordingly.
 - Changed base FB type of `MC_ForceControlFB` and adjusted implementation accordingly. 
 - Changed base FB type of `MC_ForceLimitFB` and adjusted implementation accordingly.

### Removed
 - duplicate declaration of `TOOL_MIN` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `TOOL_MAX` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `FRAME_MIN` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `FRAME_MAX` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `LOAD_MIN` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `LOAD_MAX` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `WORK_AREAS_MIN` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `WORK_AREAS_MAX` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - duplicate declaration of `SUB_PROGRAM_DATA_MAX` — originally defined in `Parameter` GVL, but redundantly declared in `Constant` GVL.
 - obsolete `OnExecRun_org` method from `MC_RobotTaskFB`.
  

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