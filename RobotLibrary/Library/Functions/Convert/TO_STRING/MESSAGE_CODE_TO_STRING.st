FUNCTION MESSAGE_CODE_TO_STRING : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MESSAGE_CODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-31
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// MessageCode
  MessageCode : DWORD;
END_VAR

  CASE MessageCode 
  OF
  
    /// ---------------------------------
    /// Info ID's
    /// ---------------------------------
    RobotLibraryInfoIdEnum.INFO_COLLISION_DETECTED :
  
      MESSAGE_CODE_TO_STRING :=  'Server Collision detected';
    
    RobotLibraryInfoIdEnum.INFO_MOTION_ERROR : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Error occurred during motion. Check the message buffer for more information';
  
    RobotLibraryInfoIdEnum.INFO_TARGET_POS_UNREACHABLE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Target position not reachable';
                                                                                
    RobotLibraryInfoIdEnum.INFO_SW_LIMITS_REACHED :
   
      MESSAGE_CODE_TO_STRING :=  'Server Software limits reached';
  
    RobotLibraryInfoIdEnum.INFO_ABORT_BY_GROUP_STOP :
   
      MESSAGE_CODE_TO_STRING :=  'Server Abortion of this command was requested by a GroupStop';
                                                                                
    RobotLibraryInfoIdEnum.INFO_ABORT_BY_MOTION_CMD : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Abortion of this command was requested by another motion command';
                                                                            
    RobotLibraryInfoIdEnum.INFO_READ_SW_LIMITS :
   
      MESSAGE_CODE_TO_STRING :=  'Server Reading the currently used software limits. Updated software limits are active after restart.';
                                                                                
    RobotLibraryInfoIdEnum.INFO_NO_ACTIVE_SUBPROGRAM : 
  
      MESSAGE_CODE_TO_STRING :=  'Server No SubProgram was stopped because none was active';
                                                                                
    RobotLibraryInfoIdEnum.INFO_JOBID_NOT_RUNNING : 
  
      MESSAGE_CODE_TO_STRING :=  'Server A program for the supplied JobID is not running or does not exist.';
                                                                                
    RobotLibraryInfoIdEnum.INFO_INSTANCEID_NOT_RUNNING : 
  
      MESSAGE_CODE_TO_STRING :=  'Server A program for the supplied InstanceID is not running or does not exist.';
                                                                                
    RobotLibraryInfoIdEnum.INFO_WAITING_AT_BLEND_ZONE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server The robot is waiting at the blending zone.';
                                                                                
    RobotLibraryInfoIdEnum.INFO_JOG_INTERRUPTED_BY_GROUP_STOP : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Jog motion was interrupted by GroupStop';
                                                                                
    RobotLibraryInfoIdEnum.INFO_JOG_INTERRUPTED_BY_RA_STATE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Jog motion was interrupted by RA sequence state INTERRUPTED';
    
    RobotLibraryInfoIdEnum.INFO_MANUAL_START_IGNORED_DURING_EMPTY_SEQ :
   
      MESSAGE_CODE_TO_STRING :=  'Server Manual start is ignored when the sequence is empty';
    
    RobotLibraryInfoIdEnum.INFO_PARAM_INDEX_ZERO_NOT_WRITEABLE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Invalid parameter value - A value was given for index 0. Index 0 is not writeable. Remove the value or change the index.';
    
    RobotLibraryInfoIdEnum.INFO_PARAM_OUTPUT_BITMASK_INVALID_FOR_NON_ZERO_INDEX : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Invalid parameter value OutputBitmask - No bitmask was given for a non zero index. Set the index to zero, or set a valid bitmask.';
  
    RobotLibraryInfoIdEnum.INFO_PARAM_OUTPUT_BITMASK_INVALID_FOR_ZERO_INDEX : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Invalid parameter value OutputBitmask - A bitmask was given for a zero index. Set the bitmask to zero, or set a non zero index.';
  
    RobotLibraryInfoIdEnum.INFO_CMD_INTERRUPTED_BY_RA_STATE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Command interrupted due to RA sequence state INTERRUPTED';
    
    RobotLibraryInfoIdEnum.INFO_CMD_INTERRUPTED_BY_RA_NOT_ENABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Command interrupted due to RA power state NOT_ENABLED';
    
    RobotLibraryInfoIdEnum.INFO_CMD_INTERRUPTED_BY_RA_SEQ_STATE_DURING_STEP_MODE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Command interrupted due to RA sequence state INTERRUPTED while single step mode is active';
  
    RobotLibraryInfoIdEnum.INFO_RESET_WARNINGS_BY_INTERNAL_CODE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Internal code used to reset warnings';
   
    RobotLibraryInfoIdEnum.INFO_LIFESIGN_TIMEOUT_TO_SMALL_AND_SET_TO_10MS : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Lifesign smaller than lower limit. It has been increased to 10ms.';
    
    RobotLibraryInfoIdEnum.INFO_RECV_EXT_CART_POS_NOT_USABLE_WITH_RECV_CART_POS : 
  
      MESSAGE_CODE_TO_STRING :=  'Client ReceiveExtendedCartesianPosition cannot be used without ReceiveCartesianPos. RecCarPos is automatically activated.';
    
    RobotLibraryInfoIdEnum.INFO_RECV_EXT_JOINT_POS_NOT_USABLE_WITH_RECV_JOINT_POS : 
  
      MESSAGE_CODE_TO_STRING :=  'Client ReceiveExtendedJointPosition cannot be used without ReceiveJointPosition. RecJointPos is automatically activated.';
  
    RobotLibraryInfoIdEnum.INFO_SYNC_TOOL_DATA_DISABLED :
   
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of tool data is disabled, and the data is different on the RC. Tool = "NUMBER" (Please Enter a valid SyncMode)';
  
    RobotLibraryInfoIdEnum.INFO_CHANGE_TOOL_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED :
   
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (TOOL)';
  
    RobotLibraryInfoIdEnum.INFO_SYNC_FRAME_DATA_DISABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of frame data is disabled, and the data is different on the RC. Frame = "NUMBER" (Please Enter a valid SyncMode)';
  
    RobotLibraryInfoIdEnum.INFO_CHANGE_FRAME_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (FRAME)';
    
    RobotLibraryInfoIdEnum.INFO_SYNC_LOAD_DATA_DISABLED :
   
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of load data is disabled, and the data is different on the RC. Load = "NUMBER" (Please Enter a valid SyncMode)';
  
    RobotLibraryInfoIdEnum.INFO_CHANGE_LOAD_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (LOAD)';
  
    RobotLibraryInfoIdEnum.INFO_SYNC_WORK_AREA_DISABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of work area data is disabled, and the data is different on the RC. WorkArea = "NUMBER" (Please Enter a valid SyncMode)';
  
    RobotLibraryInfoIdEnum.INFO_CHANGE_WORK_AREA_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (WORKAREA)';
  
    RobotLibraryInfoIdEnum.INFO_SYNC_SWLIMIT_DISABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of Software Limits data is disabled, and the data is different on the RC.';
    
    RobotLibraryInfoIdEnum.INFO_CHANGE_SWLIMITS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (SW LIMITS)';
    
    RobotLibraryInfoIdEnum.INFO_SYNC_DEFAULT_DYNAMICS_DISABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of default dynamics data is disabled, and the data is different on the RC.';
   
    RobotLibraryInfoIdEnum.INFO_CHANGE_DEFAULT_DYNAMIVS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (DEFAULT DYNAMICS)';
    
    RobotLibraryInfoIdEnum.INFO_SYNC_REFERENCE_DYNAMICS_DISABLED : 
  
      MESSAGE_CODE_TO_STRING :=  'Client Synchronization of reference dynamics data is disabled, and the data is different on the RC.';
    
    RobotLibraryInfoIdEnum.INFO_CHANGE_REFERENCE_DYNAMIVS_SYNC_MODE_TO_NEGATIVE_ONLY_AT_PLC_START_ALLOWED :
   
      MESSAGE_CODE_TO_STRING :=  'Client Change the Syncmode to Negative only works on Startup with PLC (REFERENCE DYNAMICS)';
  
    RobotLibraryInfoIdEnum.INFO_RA_DISABLED_BY_OPMODE_CHANGE : 
  
      MESSAGE_CODE_TO_STRING :=  'Server RA disabled due to operation mode change';
  
    RobotLibraryInfoIdEnum.INFO_OPERATION_MODE_CHANGED : 
  
      MESSAGE_CODE_TO_STRING :=  'Server Operation mode changed';
  
    RobotLibraryInfoIdEnum.INFO_SERVER_STATE_RESET_BY_CLIENT_REQUEST :
   
      MESSAGE_CODE_TO_STRING :=  'Server The server state has been reset on client request. Client restart may be a cause.';
    
    RobotLibraryInfoIdEnum.INFO_OVERRIDE_DECREASED_TO_PREVENT_EXEEDING_MONITORING_VELOCITY : 
  
      MESSAGE_CODE_TO_STRING :=  'Server The actual override has been decreased to not exceed a movements monitoring velocity.';
  
    RobotLibraryInfoIdEnum.INFO_EXCESSIVE_LOGGING :
   
      MESSAGE_CODE_TO_STRING := 'Server Excessive logging may degrade system performance.';
  
    RobotLibraryInfoIdEnum.INFO_FIRST_MOTION_REDUCED_VELOCITY :
   
      MESSAGE_CODE_TO_STRING := 'Server The first motion is executed with reduced velocity.';
     
      
    /// ---------------------------------
    /// Warning ID's
    /// ---------------------------------    
    RobotLibraryWarningIdEnum.WARN_HIGHPRIORITY_IGNORED_SEQ_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Client HighPriority Input is ignored when a sequential ProcessingMode is selected';
    
    RobotLibraryWarningIdEnum.WARN_CYCLIC_DATA_DISABLED_STILL_ACTIVE :
   
      MESSAGE_CODE_TO_STRING := 'Client Optional Cyclic data was disabled by the user but is still enabled until reinitialization of RobotTask';
    
    RobotLibraryWarningIdEnum.WARN_ACR_FREE_ENTRIES_LOW :
   
      MESSAGE_CODE_TO_STRING := 'Client Number of free entries in the ACR is running out';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_USED_IN_SEQUENCE :
   
      MESSAGE_CODE_TO_STRING := 'Server The Frame is currently used in the sequence';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_USED_IN_SEQUENCE :
   
      MESSAGE_CODE_TO_STRING := 'Server The Tool is currently used in the sequence';
  
    RobotLibraryWarningIdEnum.WARN_LOAD_USED_IN_SEQUENCE :
   
      MESSAGE_CODE_TO_STRING := 'Server The Load is currently used in the sequence';
  
    RobotLibraryWarningIdEnum.WARN_MONITORING_DOES_NOT_APPLY_TO_BUFFERED_CMDS :
   
      MESSAGE_CODE_TO_STRING := 'Server The monitoring does not apply to motion CMDs which are already buffered.';
  
    RobotLibraryWarningIdEnum.WARN_ACYCLIC_RANGE_PLC_TO_ROB_VERY_SMALL :
   
      MESSAGE_CODE_TO_STRING := 'Client Acyclic range client to server very small';
  
    RobotLibraryWarningIdEnum.WARN_ACYCLIC_RANGE_ROB_TO_PLC_VERY_SMALL :
   
      MESSAGE_CODE_TO_STRING := 'Client Acyclic range server to client very small';
    
    RobotLibraryWarningIdEnum.WARN_TELEGRAM_NO_CHANGED_DURING_OPERATION :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram number was changed during operation';
    
    RobotLibraryWarningIdEnum.WARN_SAVE_TOOL_FAILED :
   
      MESSAGE_CODE_TO_STRING := 'Client Save Tool locally failed. Index not available in user data.';
  
    RobotLibraryWarningIdEnum.WARN_SAVE_FRAME_FAILED :
   
      MESSAGE_CODE_TO_STRING := 'Client Save Frame locally failed. Index not available in user data.';
    
    RobotLibraryWarningIdEnum.WARN_SAVE_LOAD_FAILED :
   
      MESSAGE_CODE_TO_STRING := 'Client Save Load locally failed. Index not available in user data.';
    
    RobotLibraryWarningIdEnum.WARN_SAVE_WORKAREA_FAILED :
   
      MESSAGE_CODE_TO_STRING := 'Client Save WorkArea locally failed. Index not available in user data.';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_DATA_ARRAY_NOT_START_AT_ZERO : 
   
      MESSAGE_CODE_TO_STRING := 'Client Array of tool data supplied to RobotTask does not start at 0.';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_DATA_ARRAY_TOO_SHORT :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of tool data supplied to RobotTask must be longer than the number of tools on the RC.';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_DATA_SYNC_MODE_INVALID  :
   
      MESSAGE_CODE_TO_STRING := 'Client Tool data sync mode is invalid.';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_NUMBER_SYNC_ERROR  :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Tool "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Tool "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_DATA_ARRAY_NOT_START_AT_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of frame data supplied to RobotTask does not start at 0.';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_DATA_ARRAY_TOO_SHORT :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of frame data supplied to RobotTask must be longer than the number of frames on the RC.';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_DATA_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Frame data sync mode is invalid.';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_NUMBER_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Frame "NUMBER" (Please Enter a valid SyncMode)';
  
    RobotLibraryWarningIdEnum.WARN_FRAME_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Frame "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_LOAD_DATA_ARRAY_NOT_START_AT_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of load data supplied to RobotTask does not start at 0.';
    
    RobotLibraryWarningIdEnum.WARN_LOAD_DATA_ARRAY_TOO_SHORT :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of load data supplied to RobotTask must be longer than the number of tools on the RC.';
    
    RobotLibraryWarningIdEnum.WARN_LOAD_DATA_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Load data sync mode is invalid.';
  
    RobotLibraryWarningIdEnum.WARN_LOAD_NUMBER_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Load "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_LOAD_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Load "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_WORK_AREA_ARRAY_NOT_START_AT_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of workarea data supplied to RobotTask does not start at 0.';
    
    RobotLibraryWarningIdEnum.WARN_WORK_AREA_ARRAY_TOO_SHORT :
   
      MESSAGE_CODE_TO_STRING := 'Client Array of workarea data supplied to RobotTask must be longer than the number of tools on the RC.';
    
    RobotLibraryWarningIdEnum.WARN_WORK_AREA_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Workarea data sync mode is invalid.';
    
    RobotLibraryWarningIdEnum.WARN_WORK_AREA_NUMBER_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with WorkArea "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_WORK_AREA_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with WorkArea "NUMBER" (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_SW_LIMITS_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Software limits data sync mode is invalid.';
  
    RobotLibraryWarningIdEnum.WARN_SW_LIMITS_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Software Limits (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_SW_LIMITS_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Software Limits (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_DEFAULT_DYNAMICS_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Default dynamics data sync mode is invalid.';
    
    RobotLibraryWarningIdEnum.WARN_DEFAULT_DYNAMICS_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Default Dynamics (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_DEFAULT_DYNAMICS_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Default Dynamics (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_REFERENCE_DYNAMICS_SYNC_MODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Reference dynamics data sync mode is invalid.';
    
    RobotLibraryWarningIdEnum.WARN_REFERENCE_DYNAMICS_SYNC_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync with Reference Dynamics (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_REFERENCE_DYNAMICS_SYNC_BOTH_SIDES_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client Error Sync Data changed in both Sides with Reference Dynamics (Please Enter a valid SyncMode)';
    
    RobotLibraryWarningIdEnum.WARN_TOOL_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of tool is not possible due to error in the read or write tool cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_FRAME_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of frame is not possible due to error in the read or write frame cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_LOAD_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of load is not possible due to error in the read or write load cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_SW_LIMITS_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of swLimits is not possible due to error in the read or write swLimits cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_REFERENCE_DYNAMICS_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of referenceDynamics is not possible due to error in the read or write referenceDynamics cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_DEFAULT_DYNAMICS_SYNC_FAILED_BY_ERROR_OF_READ_OR_WRITE_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Client Synchronization of defaultDynamics is not possible due to error in the read or write defaultDynamics cmd. See dedicated message log entry for more information.';
    
    RobotLibraryWarningIdEnum.WARN_LEGACY_SRCI_ENCODING  :
   
      MESSAGE_CODE_TO_STRING := 'Client Using the legacy SRCI version encoding. It will not be compatible with the newest RC interpreter versions.';
    
    RobotLibraryWarningIdEnum.WARN_ACR_ALMOST_FULL :
   
      MESSAGE_CODE_TO_STRING := 'Server The ACR is almost full. Filling it completely disables the robot. Make sure to limit the number of commands in the system.';
    
    /// ---------------------------------
    /// Error ID's
    /// ---------------------------------
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PAR_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Invalid command parameter - see log file for details (LogLevel Error)';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE_0xA1 :
   
      MESSAGE_CODE_TO_STRING := 'Telegram control does not match the telegram state';
    
    RobotLibraryErrorIdEnum.ERR_INIT_LOST_UNKNOWN_0xA2 :
   
      MESSAGE_CODE_TO_STRING := 'Initialization lost for unknown reason. See message log after reinitializing';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_LENGTH_MISMATCH_0xA3 :
   
      MESSAGE_CODE_TO_STRING := 'Telegram length does not match the length provided in the communication interface.';
      
    RobotLibraryErrorIdEnum.ERR_SRCI_MAJOR_VERSION_INCOMPATIBLE_0xA4 :
   
      MESSAGE_CODE_TO_STRING := 'Incompatible major SRCI version';
    
    RobotLibraryErrorIdEnum.ERR_LIFESIGN_TIMEOUT_0xA5 :
   
      MESSAGE_CODE_TO_STRING := 'Lifesign timeout';
    
    RobotLibraryErrorIdEnum.ERR_CYCLIC_DATA_TOO_LARGE_0xA6 :
   
      MESSAGE_CODE_TO_STRING := 'The selected optional cyclic data does not fit in the given telegram size';
    
    RobotLibraryErrorIdEnum.ERR_INTERFACE_WAS_RESET_AFTER_INIT_0xA7 :
   
      MESSAGE_CODE_TO_STRING := 'The robot interface was reset after being initialized';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_SEQ_TIMEOUT_0xA8 :
   
      MESSAGE_CODE_TO_STRING := 'Telegram sequence timeout';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NO_CHANGED_AFTER_INIT_0xA9 :
   
      MESSAGE_CODE_TO_STRING := 'The telegram number changed after initialization';
      
    RobotLibraryErrorIdEnum.ERR_AXESGROUP_ID_INVALID_0xAA :
   
      MESSAGE_CODE_TO_STRING := 'Invalid AxesGroupID';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_INVALID_0xAB :
   
      MESSAGE_CODE_TO_STRING := 'Telegram number is invalid. E.g. TwoSequences is only activated in one direction';
    
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_NOT_SUPPORTED_0xAC :
   
      MESSAGE_CODE_TO_STRING := 'Telegram Number is not supported';
    
    RobotLibraryErrorIdEnum.ERR_SERVER_CONNECTION_LOST_0xAD :
   
      MESSAGE_CODE_TO_STRING := 'Server Connection to the communication partner was lost';
    
    RobotLibraryErrorIdEnum.ERR_VELOCITY_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Velocity not valid';
      
    RobotLibraryErrorIdEnum.ERR_ACCELERATION_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Acceleration not valid';
      
    RobotLibraryErrorIdEnum.ERR_DECELERATION_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Deceleration not valid';
    
    RobotLibraryErrorIdEnum.ERR_JERK_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Jerk not valid';
    
    RobotLibraryErrorIdEnum.ERR_CONFIGMODE_ELBOW_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - ConfigMode Elbow';
    
    RobotLibraryErrorIdEnum.ERR_CONFIGMODE_SHOULDER_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - ConfigMode Shoulder';
    
    RobotLibraryErrorIdEnum.ERR_CONFIGMODE_WRIST_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - ConfigMode Wrist';
    
    RobotLibraryErrorIdEnum.ERR_TRAJECTORYMODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - TrajectoryMode';
    
    RobotLibraryErrorIdEnum.ERR_OVERRIDE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - Override';
    
    RobotLibraryErrorIdEnum.ERR_ABORTINGMODE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - AbortingMode. Only 0: Buffer / 1: Abort are valid.';
        
    RobotLibraryErrorIdEnum.ERR_TOOLNO_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - ToolNo outside of the allowed range -1..254';
    
    RobotLibraryErrorIdEnum.ERR_TOOLNO_UNAVAILABLE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - ToolNo not available on RC';
    
    RobotLibraryErrorIdEnum.ERR_FRAMENO_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - FrameNo outside of the allowed range -1..254';
    
    RobotLibraryErrorIdEnum.ERR_FRAMENO_UNAVAILABLE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - FrameNo NOT available on RC';
    
    RobotLibraryErrorIdEnum.ERR_ACYCLICDATA_TOO_LARGE :
   
      MESSAGE_CODE_TO_STRING := 'Client The array specified for AcyclicData exceeds the supported maximum length of 190 bytes';
    
    RobotLibraryErrorIdEnum.ERR_RETURNACYCLICDATA_TRUNCATED :
   
      MESSAGE_CODE_TO_STRING := 'Client The array length specified for ReturnAcyclicData is not sufficient for the returned data. The data has been truncated';
    
    RobotLibraryErrorIdEnum.ERR_LOADNO_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid parameter value - LoadNo outside of the allowed range -1..254';
    
    RobotLibraryErrorIdEnum.ERR_PROCESSINGMODE_NOT_DEFINED :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified ProcessingMode not defined';
    
    RobotLibraryErrorIdEnum.ERR_PROCESSINGMODE_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified ProcessingMode not allowed';
      
    RobotLibraryErrorIdEnum.ERR_EMITTERID_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Emitter ID not allowed';
    
    RobotLibraryErrorIdEnum.ERR_LISTENERID_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Listener ID not allowed';
    
    RobotLibraryErrorIdEnum.ERR_PROCSEQFLAG_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client ProcessingMode or SequenceFlag changed during execution';
    
    RobotLibraryErrorIdEnum.ERR_COMMANDS_NOT_ENABLED :
   
      MESSAGE_CODE_TO_STRING := 'Client Commands are not Enabled (First Robot must be initialized)';
    
    RobotLibraryErrorIdEnum.ERR_ROBOT_ERROR_NO_ID :
   
      MESSAGE_CODE_TO_STRING := 'Client Error received from robot without error ID';
    
    RobotLibraryErrorIdEnum.ERR_AXESGROUP_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Client AxesGroup changed during execution';
      
    RobotLibraryErrorIdEnum.ERR_SEQFLAG_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified SEQ Flag not allowed';
    
    RobotLibraryErrorIdEnum.ERR_AXESGROUP_CLEARED :
   
      MESSAGE_CODE_TO_STRING := 'Client AxesGroup cleared during execution';
    
    RobotLibraryErrorIdEnum.ERR_NO_FREE_ACR_ENTRY :
   
      MESSAGE_CODE_TO_STRING := 'Client No free ACR entry available';
    
    RobotLibraryErrorIdEnum.ERR_SEQFLAG_INVALID_IN_PROC_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Client Sequence flag must be 0 in the selected ProcessingMode';
    
    RobotLibraryErrorIdEnum.ERR_LISTENERID_MUST_BE_GREATER_THAN_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Listener ID must be > 0 for selected trigger based ProcessingMode';
    
    RobotLibraryErrorIdEnum.ERR_EMITTERID_MUST_BE_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Emitter ID must be 0';
    
    RobotLibraryErrorIdEnum.ERR_LISTENERID_MUST_BE_POSITIVE :
   
      MESSAGE_CODE_TO_STRING := 'Client Specified Listener ID must be a positive value (>= 0)';
  
    RobotLibraryErrorIdEnum.ERROR_CONTINUE_NOT_POSSIBLE_BY_NOT_ENABLED :
   
      MESSAGE_CODE_TO_STRING := 'Server Continue not possible - robot is not enabled';
    
    RobotLibraryErrorIdEnum.ERROR_CONTINUE_NOT_POSSIBLE_BY_NOT_IN_PRIMARY_POS :
   
      MESSAGE_CODE_TO_STRING := 'Server Continue not possible - robot is not inPrimaryPosition';
    
    RobotLibraryErrorIdEnum.ERR_ROBOT_DISABLED :
   
      MESSAGE_CODE_TO_STRING := 'Server Robot disabled';
  
    RobotLibraryErrorIdEnum.ERR_ROBOT_DISABLED_BY_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Server Robot disabled due to an error';
  
    RobotLibraryErrorIdEnum.ERR_MANDATORY_CMDS_MISSING :
   
      MESSAGE_CODE_TO_STRING := 'Server Not all mandatory commands have been called yet';
  
    RobotLibraryErrorIdEnum.ERR_RI_NOT_SYNCHRONIZED :
   
      MESSAGE_CODE_TO_STRING := 'Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies enabling in this state';
  
    RobotLibraryErrorIdEnum.ERR_LIMIT_EXCEEDED_RETURN_POS :
   
      MESSAGE_CODE_TO_STRING := 'Server Limit exceeded. Move closer to return position';
  
    RobotLibraryErrorIdEnum.ERR_SET_OPMODE_T1EXT_REQUIRED :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Must switch to T1Ext when changing between AutoExt and T2Ext';
  
    RobotLibraryErrorIdEnum.ERR_WRITE_DYNAMIC_FRAME :
   
      MESSAGE_CODE_TO_STRING := 'Server Cannot write to a dynamic frame (frame used by e.g. conveyor tracking)';
  
    RobotLibraryErrorIdEnum.ERR_CONTINUE_NOT_POSSIBLE_BY_MANUAL_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Continue not possible in manual operation mode';
  
    RobotLibraryErrorIdEnum.ERR_FRAME_REFERENCING_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server It is not allowed to reference a frame which already references another frame';
  
    RobotLibraryErrorIdEnum.ERR_FRAME_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server The referenced Frame is invalid, dynamic (frame used by e.g. conveyor tracking) or does not exist';
  
    RobotLibraryErrorIdEnum.ERR_TOOLID_DIFFERS_TARGET :
   
      MESSAGE_CODE_TO_STRING := 'Server Currently used tool ID differs from the tool ID of the target position';
  
    RobotLibraryErrorIdEnum.ERR_WRITE_FRAME_DURING_MOVE :
   
      MESSAGE_CODE_TO_STRING := 'Server Writing a Frame during an active movement is not supported by this RC';
  
    RobotLibraryErrorIdEnum.ERR_WRITE_TOOL_DURING_MOVE :
   
      MESSAGE_CODE_TO_STRING := 'Server Writing a Tool during an active movement is not supported by this RC';
  
    RobotLibraryErrorIdEnum.ERR_WRITE_LOAD_DURING_MOVE :
   
      MESSAGE_CODE_TO_STRING := 'Server Writing a Load during an active movement is not supported by this RC';
  
    RobotLibraryErrorIdEnum.ERR_MANUAL_STEP_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Server ManualStep is not allowed in Automatic External';
  
    RobotLibraryErrorIdEnum.ERR_MANUAL_STEP_ONLY_IN_STEP_MODE_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Server ManualStep is only allowed when StepMode is active';
  
    RobotLibraryErrorIdEnum.ERR_TOOLDATA_DIFFERS :
   
      MESSAGE_CODE_TO_STRING := 'Server The current ToolData has changed and differs from the one when the primary position was left. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_LOADDATA_DIFFERS :
   
      MESSAGE_CODE_TO_STRING := 'Server The current LoadData has changed and differs from the one when the primary position was left. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_FRAMEDATA_DIFFERS :
   
      MESSAGE_CODE_TO_STRING := 'Server The current FrameData has changed and differs from the one when the primary position was left. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_REF_FRAMEDATA_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Server The current reference FrameData has changed and differs from the one when the primary position was left. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_TOOLNO_DIFFERS_TARGET :
   
      MESSAGE_CODE_TO_STRING := 'Server The ToolNo differs from the one in the return position. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_FRAMENO_DIFFERS_TARGET :
   
      MESSAGE_CODE_TO_STRING := 'Server The FrameNo differs from the one in the return position. Returning is not possible.';
  
    RobotLibraryErrorIdEnum.ERR_CONTINUE_WHILE_STOPPING :
   
      MESSAGE_CODE_TO_STRING := 'Server Continue is not possible while the Robot is interrupting or stopping.';
  
    RobotLibraryErrorIdEnum.ERR_SOFTWARE_LIMITS_FOR_NON_EXISTING_AXIS :
   
      MESSAGE_CODE_TO_STRING := 'Server Software limits could not be set because values were specified for non-existing axes';
  
    RobotLibraryErrorIdEnum.ERR_RI_NOT_SYNCHRONIZED_CONTINUE_DENIED :
   
      MESSAGE_CODE_TO_STRING := 'Server RI state is NOT_SYNCHRONIZED and the respective syncReaction denies continue in this state';
  
    RobotLibraryErrorIdEnum.ERR_ENABLE_SWITCH_REQUIRED :
   
      MESSAGE_CODE_TO_STRING := 'Server Enable switch must be active to enable the robot';
  
    RobotLibraryErrorIdEnum.ERR_MANUAL_STEP_WHILE_DISABLED :
   
      MESSAGE_CODE_TO_STRING := 'Server Manual step sent while robot not enabled';
  
    RobotLibraryErrorIdEnum.ERR_JOG_NOT_ALLOWED_DURING_MOVE :
   
      MESSAGE_CODE_TO_STRING := 'Server Jog not possible during active movement';
  
    RobotLibraryErrorIdEnum.ERR_TARGET_POS_FOR_NON_EXISTING_AXIS :
   
      MESSAGE_CODE_TO_STRING := 'Server Target position was commanded for an external axis which does not exist';
  
    RobotLibraryErrorIdEnum.ERR_JOG_AXIS_NOT_EXIST :
   
      MESSAGE_CODE_TO_STRING := 'Server Jog of axis is not possible. Axis does not exist';
  
    RobotLibraryErrorIdEnum.ERR_INC_JOG_ONE_AXIS_ONLY :
   
      MESSAGE_CODE_TO_STRING := 'Server Incremental jog is only possible in one axis of rotation';
  
    RobotLibraryErrorIdEnum.ERR_JOBID_NOT_EXIST :
   
      MESSAGE_CODE_TO_STRING := 'Server A program for the supplied JobID does not exist.';
  
    RobotLibraryErrorIdEnum.ERR_ONLY_ALLOWED_IN_SEQ_BUFFER :
   
      MESSAGE_CODE_TO_STRING := 'Server A program including motion commands is only allowed to be executed in a sequence buffer';
  
    RobotLibraryErrorIdEnum.ERR_JOB_ALREADY_RUNNING :
   
      MESSAGE_CODE_TO_STRING := 'Server A program with the same number is already running. Multiple instances are not supported';
  
    RobotLibraryErrorIdEnum.ERR_JOBID_CHANGE_PM3_NOT_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Server Changing the JobID in PM 3 during runtime of this CMD is not supported.';
  
    RobotLibraryErrorIdEnum.ERR_CONTINUE_DURING_STOPPING :
   
      MESSAGE_CODE_TO_STRING := 'Server Continue is not possible while the robot is stopping due to GroupInterrupt, GroupStop, SetSequence, or GroupJog';
  
    RobotLibraryErrorIdEnum.ERR_JOG_STOPPED_BY_ENABLE_RELEASED :
   
      MESSAGE_CODE_TO_STRING := 'Server GroupJog motion was stopped due to the release of the enable switch.';
  
    RobotLibraryErrorIdEnum.ERR_SWLIMITS_NOT_ALLOWED_ROBOT_IS_OUTSIDE :
   
      MESSAGE_CODE_TO_STRING := 'Server Setting the limits is not possible because the current robot position is currently outside of those limits.';
  
    RobotLibraryErrorIdEnum.ERR_SWLIMITS_NOT_ALLOWED_DURING_MOVE :
   
      MESSAGE_CODE_TO_STRING := 'Server Setting the limits is not possible while a motion is active.';
  
    RobotLibraryErrorIdEnum.ERR_OPMODE_CHANGE_NOT_POSSIBLE_BY_PLC :
   
      MESSAGE_CODE_TO_STRING := 'Server Change of operation mode by the PLC not possible. The RC must be in an "External" operation mode';
  
    RobotLibraryErrorIdEnum.ERR_AUXPOINT_IDENTICAL_WITH_OTHER_POS :
   
      MESSAGE_CODE_TO_STRING := 'Server Auxpoint must not be identical to start or end position of the motion';
  
    RobotLibraryErrorIdEnum.ERR_AUXPOINT_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Auxpoint invalid';
  
    RobotLibraryErrorIdEnum.ERR_CALC_NOT_POSSIBLE_BY_POS :
   
      MESSAGE_CODE_TO_STRING := 'Server Supplied positions must not be identical or at a larger distance apart';
  
    RobotLibraryErrorIdEnum.ERR_CALC_NOT_POSSIBLE_BY_PARA :
   
      MESSAGE_CODE_TO_STRING := 'Server Calculation not possible with the given parameters';
  
    RobotLibraryErrorIdEnum.ERR_CALC_NOT_POSSIBLE_BY_POS_ON_LINE :
   
      MESSAGE_CODE_TO_STRING := 'Server Positions must not be on one line';
  
    RobotLibraryErrorIdEnum.ERR_INV_KINEMATIC_NO_SOLUTION :
   
      MESSAGE_CODE_TO_STRING := 'Server No solution found for the given CartesianPosition';
  
    RobotLibraryErrorIdEnum.ERR_INV_KINEMATIC_SOLUTION_OUTSIDE_SWLIMITS :
   
      MESSAGE_CODE_TO_STRING := 'Server Solution is outside of the hardware limits';
  
    RobotLibraryErrorIdEnum.ERR_PARAM_WRITE_PROTECTED :
   
      MESSAGE_CODE_TO_STRING := 'Server The selected parameter is write protected and can thus not be changed';
  
    RobotLibraryErrorIdEnum.ERR_POS_INDEX_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Number of received positions exceeds the maximum expected number (index out of range)';
  
    RobotLibraryErrorIdEnum.ERR_POS_INDEX_MISMATCH :
   
      MESSAGE_CODE_TO_STRING := 'Server Number of received positions does not correspond to the required number for the selected mode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ACCELERATION_RATE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - AccelerationRate';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_BLENDING_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - BlendingMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_BLENDING_PARA :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - BlendingParameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_CONFIGMODE_ELBOW :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ConfigMode Elbow';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DECELERATION_RATE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - DecelerationRate';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_VALUE_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - No value greater than zero';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_FRAMENO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - FrameNo';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_INC_ROTATION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - IncrementalRotation';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_INC_TRANSLATION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - IncrementalTranslation';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_JERK_RATE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - JerkRate';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_JOG_POS_AND_JOG_NEG :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Control Positive and negative jog direction was active at the same time';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_JOINT_POS :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - JointPosition';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_LIFE_SIGN_TIMEOUT :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - LifesignTimeout';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SWLIMITS :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - SoftwareLimits all values must not be zero';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_LIMITVALUES :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - LimitValues';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_LOADNO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - LoadNo';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_LOG_LEVEL :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - LogLevel';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Mode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ORI_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - OriMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_OVERRIDE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Override';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_POSITION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Position';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_REF_DYNAMICS_LESS_THAN_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ReferenceDynamics all values less than zero';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ACCELERATION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Acceleration';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DECELERATION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Deceleration';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_JERK :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Jerk';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_VELOCITY :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Velocity';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_RETURN_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ReturnMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TARGET_SEQUENCE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TargetSequence';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_OPERATION_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - OperationMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SYNC_REACTION :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - SyncReaction';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TIME :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Time';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TOOLNO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ToolNo';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TRAJECTORY_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TrajectoryMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TURN_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TurnMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_VELOCITY_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - VelocityRate';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_WAIT_FOR_NR_OF_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - WaitForNrOfCmd';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_CONFIG_MODE_SHOULDER :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ConfigMode Shoulder';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_CONFIG_MODE_WRIST :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ConfigMode Wrist';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_STEP_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - StepMode';
  
    RobotLibraryErrorIdEnum.ERR_STEP_MODE_NOT_VALID :
   
      MESSAGE_CODE_TO_STRING := 'Server The supplied StopMode is not valid. Use 0, 1, or 2';
  
    RobotLibraryErrorIdEnum.ERR_STOP_MODE_2_TARGETID_NEG1 :
   
      MESSAGE_CODE_TO_STRING := 'Server When StopMode 2: (Stop all subprograms) is selected, the TargetID must be -1.';
  
    RobotLibraryErrorIdEnum.ERR_STOP_MODE_0_TARGETID_NOT_NEG1 :
   
      MESSAGE_CODE_TO_STRING := 'Server When StopMode 0: (Stop via JobID) is selected, the TargetID must NOT be -1.';
  
    RobotLibraryErrorIdEnum.ERR_STOP_MODE_1_TARGETID_NOT_NEG1 :
   
      MESSAGE_CODE_TO_STRING := 'Server When StopMode 1: (Stop via InstanceID) is selected, the TargetID must NOT be -1.';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_INDEX_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Index out of range';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SAME_INDEX_MULTIPLE_TIMES :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Same index was used multiple times';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_MASS_EXCEEDS_PAYLOAD :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Specified mass greater than the maximum RA payload.';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_AT_LEAST_ONE_INDEX_REQUIRED :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - At least one index must not be 0 and result in a read/write operation.';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_MESSAGE_LEVEL :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - MessageLevel must be between 0-28';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_CIRCPLANE_MISMATCH_CIRCMODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - CircPlane does not match CircMode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_CIRCMODE_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - CircMode outside of the allowed range 0..3';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TOLERANCE_ONLY_CIRCMODE_1 :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Tolerance must only be used for CircMode 1';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ANGLE_ONLY_CIRCMODE_2 :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Angle must only be used for CircMode 2';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_PATH_CHOICE_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - PathChoice outside of the allowed range 0..1';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SHIFT_MODE_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Mode outside of the allowed range 0..4';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ROTATION_ANGLE_ONLY_MODE_3 :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - RotationAngle only allowed in mode 3';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TRANSFORMATION_PARAM_2_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TransformationParameter_2 value does not match the selected mode';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TOOLNO_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_FRAMENO_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - FrameNo outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TARGET_TOOLNO_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TargetToolNo outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_TARGET_FRAMENO_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - TargetFrameNo outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_ERR_TOOLNO_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ToolNo outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_PARAMETER_ID_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ParameterID does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SUB_PARAMETER_ID_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - SubParameterID does not exist on the RC for the supplied ParameterID';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SUB_PARAMETER_MUST_BE_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - SubParameterID must be 0 for a parameter without subparameters';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_SUB_PARAMETER_MUST_NOT_BE_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - SubParameterID must NOT be 0 FOR a parameter with subparameters';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_TYPE_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - DataType outside of the allowed range 1..13';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_TYPE_MISMATCH :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - DataType does not match the data type of the parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_0_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_0 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_1_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_1 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_2_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_2 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_3_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_3 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_4_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_4 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_5_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_5 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_6_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_6 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_DATA_7_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Data_7 contains invalid data for the target parameter';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_REFERENCE_FRAME_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - ReferenceFrame outside of the allowed range 0..254 or does not exist on the RC';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_DECELERATION_RATE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - DecelerationRate';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_JERK_RATE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - JerkRate';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_BLENDING_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - BlendingMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_TIME_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - Time';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_POSITION_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - Position';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_ORI_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - OriMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_CONFIG_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - ConfigMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_TURN_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - TurnMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_TRAJECTORY_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - TrajectoryMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_OPERATION_MODE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value NOT supported - OperationMode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_INC_ROTATION_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - IncrementalRotation';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_INC_TRANSLATION_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - IncrementalTranslation';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_STEP_MODE_EXACT_STOP_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - StepMode Exact Stop';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_STEP_MODE_BLENDING_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - StepMode Blending';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_MODIFIED_CONVENTION_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - ModifiedConvention';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_WAIT_AT_BLENDING_POINT_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - WaitAtBlendingPoint';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_ANGLE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - Angle';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_PATH_CHOICE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - PathChoice';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_TOLERANCE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - Tolerance';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_TRANSFORMATION_PARAM2_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - TransformationParameter_2';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_ROTATION_ANGLE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - RotationAngle';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_VALUE_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter value not supported - Mode';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_EXTERNAL_TCP_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - ExternalTCP';
  
    RobotLibraryErrorIdEnum.ERR_OPTIONAL_PARAM_RELATIVE_POS_NOT_SUPPORTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Optional parameter not supported - RelativePosition';
  
    RobotLibraryErrorIdEnum.ERR_EMITTER_ID_MUST_NOT_BE_ZERO :
   
      MESSAGE_CODE_TO_STRING := 'Server Specified Emitter ID must not be 0';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_PARAM_EXECUTION_MODE :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid parameter value - Execution mode';
  
    RobotLibraryErrorIdEnum.ERR_CMD_NOT_IMPLEMENTED :
   
      MESSAGE_CODE_TO_STRING := 'Server Command not implemented';
  
    RobotLibraryErrorIdEnum.ERR_CMD_ONLY_ONE_INSTANCE_ALLOWED :
   
      MESSAGE_CODE_TO_STRING := 'Server Only one instance of this command is allowed';
  
    RobotLibraryErrorIdEnum.ERR_CMD_REQUIRES_INTERRUPT_OR_IDLE_STATE :
   
      MESSAGE_CODE_TO_STRING := 'Server Command requires an active interrupt or idle state to be executed';
  
    RobotLibraryErrorIdEnum.ERR_CMD_NOT_ALLOWED_DURING_ACTIVE_INTERRUPT :
   
      MESSAGE_CODE_TO_STRING := 'Server Command cannot be executed during active interrupt';
  
    RobotLibraryErrorIdEnum.ERR_SECONDARY_SEQUENCE_BLOCKED_BY_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Server Secondary sequence is blocked by command (e.g. GroupJog, ReturnToPrimary). No other commands may be buffered in secondary sequence';
  
    RobotLibraryErrorIdEnum.ERR_SECONDARY_SEQUENCE_NOT_ACTIVE :
   
      MESSAGE_CODE_TO_STRING := 'Server The secondary sequence is not active. Commands may only be buffered in this sequence if it is active';
  
    RobotLibraryErrorIdEnum.ERR_SECONDARY_SEQUENCE_NOT_EMPTY :
   
      MESSAGE_CODE_TO_STRING := 'Server Secondary sequence is not empty. The command requires the secondary sequence to be empty';
  
    RobotLibraryErrorIdEnum.ERR_TRANSACTION_NOT_POSSIBLE_IN_STATE_MACHINE :
   
      MESSAGE_CODE_TO_STRING := 'Server Transaction not possible in the state machine';
  
    RobotLibraryErrorIdEnum.ERR_CMD_NOT_POSSIBLE_BY_OP_MODE_LOCAL :
   
      MESSAGE_CODE_TO_STRING := 'Server Cannot execute command because current operation mode is local.';
  
    RobotLibraryErrorIdEnum.ERR_CMD_TYPE_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server Command type out of range';
  
    RobotLibraryErrorIdEnum.ERR_CMD_NOT_POSSIBLE_DURING_CALL_SUB_PROGRAM :
   
      MESSAGE_CODE_TO_STRING := 'Server Execution of this CMD is not possible while CallSubprogram is in progress in the sequence';
  
    RobotLibraryErrorIdEnum.ERR_OPERATION_NOT_POSSIBLE_SEE_LOG :
   
      MESSAGE_CODE_TO_STRING := 'Server Operation not possible. See MessageLog for further information';
  
    RobotLibraryErrorIdEnum.ERR_INTERNAL_ERROR_DURING_CMD :
   
      MESSAGE_CODE_TO_STRING := 'Server An RC internal error occurred during execution of this command. Check the message log for additional information';
    
    RobotLibraryErrorIdEnum.ERR_WRONG_TELEGRAM_STATE :
   
      MESSAGE_CODE_TO_STRING := 'Client Wrong Telegram State (Two Sequences not in both directions active)';
  
    RobotLibraryErrorIdEnum.ERR_ACYCLIC_AREA_TO_SMALL_PLC_TO_ROB :
   
      MESSAGE_CODE_TO_STRING := 'Client Acyclic area client to server too small';
  
    RobotLibraryErrorIdEnum.ERR_ACYCLIC_AREA_TO_SMALL_ROB_TO_PLC :
   
      MESSAGE_CODE_TO_STRING := 'Client Acyclic area server to client too small';
  
    RobotLibraryErrorIdEnum.ERR_LIFESIGN_TIMEOUT_0x8005 :
   
      MESSAGE_CODE_TO_STRING := 'Client Lifesign timeout';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_SEQ_TIMEOUT_0x8005 :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram sequence timeout';
  
    RobotLibraryErrorIdEnum.ERR_AXESGROUP_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Assigned AxesGroup not valid';
  
    RobotLibraryErrorIdEnum.ERR_PERIPHERY_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Client Assigned periphery not valid';
  
    RobotLibraryErrorIdEnum.ERR_INVALID_ROBOT_STATE :
   
      MESSAGE_CODE_TO_STRING := 'Client Invalid state of the robot (more than 1 CMD active)';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_CHANGED_AFTER_INIT :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram Number changed after initialization. Reinitialize by disabling and enabling the RobotTask.';
      
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE_0x80A1 :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram control does not match the telegram state';
  
    RobotLibraryErrorIdEnum.ERR_INIT_LOST_UNKNOWN_0x80A2 :
   
      MESSAGE_CODE_TO_STRING := 'Client Initialization lost for unknown reason. See message log after reinitializing';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_LENGTH_MISMATCH_0x80A3 :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram length does not match the length provided in the communication interface, or the communication interface is too small.';
  
    RobotLibraryErrorIdEnum.ERR_SRCI_MAJOR_VERSION_INCOMPATIBLE_0x80A4 :
   
      MESSAGE_CODE_TO_STRING := 'Client Incompatible major SRCI version';
  
    RobotLibraryErrorIdEnum.ERR_LIFESIGN_TIMEOUT_0x80A5 :
   
      MESSAGE_CODE_TO_STRING := 'Client Lifesign timeout';
  
    RobotLibraryErrorIdEnum.ERR_CYCLIC_DATA_TOO_LARGE_0x80A6 :
   
      MESSAGE_CODE_TO_STRING := 'Client The selected optional cyclic data does not fit in the given telegram size';
  
    RobotLibraryErrorIdEnum.ERR_INTERFACE_WAS_RESET_AFTER_INIT_0x80A7 :
   
      MESSAGE_CODE_TO_STRING := 'Client The robot interface was reset after being initialized';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_SEQ_TIMEOUT_0x80A8_0x80A8 :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram sequence timeout';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NO_CHANGED_AFTER_INIT_0x80A9 :
   
      MESSAGE_CODE_TO_STRING := 'Client The telegram number changed after initialization';
  
    RobotLibraryErrorIdEnum.ERR_AXESGROUP_ID_INVALID_0x80AA :
   
      MESSAGE_CODE_TO_STRING := 'Client Error: Invalid AxesGroupID';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_INVALID_0x80AB :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram number is invalid. E.g. TwoSequences is only activated in one direction';
  
    RobotLibraryErrorIdEnum.ERR_TELEGRAM_NUMBER_NOT_SUPPORTED_0x80AC :
   
      MESSAGE_CODE_TO_STRING := 'Client Telegram Number is not supported';
  
    RobotLibraryErrorIdEnum.ERR_ACR_REGISER_IS_FULL :
   
      MESSAGE_CODE_TO_STRING := 'Server The ACR is full. RA is disabled';
  
    RobotLibraryErrorIdEnum.ERR_MANDATORY_CMD_STOPPED :
   
      MESSAGE_CODE_TO_STRING := 'Server The execution of a mandatory command has been stopped. Exchange config must run for the system to run';
  
    RobotLibraryErrorIdEnum.ERR_INCONSISTENT_DATA_RECEIVED :
   
      MESSAGE_CODE_TO_STRING := 'Server Inconsistent data received. Make sure the complete telegram data is sent to RC in one frame.';
  
    RobotLibraryErrorIdEnum.ERR_CONNECTION_LOST :
   
      MESSAGE_CODE_TO_STRING := 'Client Connection to the communication partner was lost';
  
    RobotLibraryErrorIdEnum.ERR_FATAL_ERROR_REINIT_REQUIRED :
   
      MESSAGE_CODE_TO_STRING := 'Client Fatal Error occurred. Reinitialization of Robot_Task is required';
  
    RobotLibraryErrorIdEnum.ERR_INTERNAL_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Server Internal error';
  
    RobotLibraryErrorIdEnum.ERR_DESERIALIZE_ERROR :
   
      MESSAGE_CODE_TO_STRING := 'Server Internal error in deserialize';
  
    RobotLibraryErrorIdEnum.ERR_CMD_ID_OUT_OF_RANGE :
   
      MESSAGE_CODE_TO_STRING := 'Server CMD ID out of range 1.ACR_Length';
  
    RobotLibraryErrorIdEnum.ERR_FRAGMENT_LENGTH_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid fragment length';
  
    RobotLibraryErrorIdEnum.ERR_CMD_PRIORITY_CHANGED :
   
      MESSAGE_CODE_TO_STRING := 'Server Command priority or type changed during runtime';
  
    RobotLibraryErrorIdEnum.ERR_TRIED_TO_RESET_NONEMPTY_ACR_REGISTER :
   
      MESSAGE_CODE_TO_STRING := 'Server Tried to reset a non-empty ACR entry';
  
    RobotLibraryErrorIdEnum.ERR_SEQUENCE_PAYLOAD_INVALID_LENGTH :
   
      MESSAGE_CODE_TO_STRING := 'Server Error: Invalid Sequence payload length (e.g., sequence payload length is specified 999 even if telegram length is only 100.)';
  
    RobotLibraryErrorIdEnum.ERR_ACTION_BYTE_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid ActionByte';
  
    RobotLibraryErrorIdEnum.ERR_CMD_PAYLOAD_LENGTH_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Invalid Command payload length';
  
    RobotLibraryErrorIdEnum.ERR_CMD_PAYLOAD_POINTER_INVALID :
   
      MESSAGE_CODE_TO_STRING := 'Server Error: Invalid Command payload pointer (e.g., Out of bounds)';
  
    RobotLibraryErrorIdEnum.ERR_EXEC_MODE_CHANGE_ILLEGAL :
   
      MESSAGE_CODE_TO_STRING := 'Server Illegal Execution Mode change';
      
  ELSE
    MESSAGE_CODE_TO_STRING := StrReplace('Unkown message code : {0}', '{0}' , DWORD_TO_STRING(MessageCode));
  END_CASE

END_FUNCTION

