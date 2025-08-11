{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupState                                       
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
TYPE AxesGroupState :
STRUCT
  /// Client reports a fatal error 
  FatalErrorClient               : BOOL;
  /// Invalid frames counter
  InvalidFrames                  : UDINT;  
  /// PLC and RC are synchronized
  Synchronized                   : BOOL;
  /// Synchronizing is running
  Synchronizing                  : AxesGroupStateSynchronizing;
  /// Data exchange is running ( Liftebit toggles )
  AliveOk                        : BOOL;
  /// Bit that indicated that is possible to execute commands
  CMDsEnabled                    : BOOL;
  /// Configuration is exchanged
  ConfigExchanged                : BOOL;
  /// Highest available tool index of RC and PLC in combination
  UnifiedToolIndex               : USINT;
  /// Highest available frame index of RC and PLC in combination
  UnifiedFrameIndex              : USINT;
  /// Highest available load index of RC and PLC in combination
  UnifiedLoadIndex               : USINT;
  /// Highest available workarea index of RC and PLC in combination
  UnifiedWorkAreaIndex           : USINT;  
  /// Enable datas to synchronize
  DataEnableSync                 : DataEnableSync;
  /// Flags that indicates which element has changed
  DataChanged                    : AxesGroupStateDataChanged;
  /// Synchronization state of the PLC 
  SyncStatePlc                   : AxesGroupStateSyncStatePlc;
  /// Synchronization state of the RC 
  SyncStateRc                    : AxesGroupStateSyncStateRob;
  /// Current System Time
  SystemTime                     : SystemTime;
  /// Read Robot data 
  RobotData                      : ReadRobotDataOutCmd;
  /// Read configuration data
  ConfigurationData              : ExchangeConfigurationOutCmd;
  /// TRUE, while the CartesianPosition is returned cyclically 
  ReadingCartesianPosition       : BOOL;
  /// TRUE, while the ExtCartesianPosition is returned cyclically 
  ReadingCartesianPositionExt    : BOOL;
  /// TRUE, while the JointPosition is returned cyclically 
  ReadingJointPosition           : BOOL;
  /// TRUE, while the ExtJointPosition is returned cyclically 
  ReadingJointPositionExt        : BOOL;
  /// Robot is initialized
  Initialized                    : BOOL;  
  /// Online Change detected
  OnlineChange                   : BOOL;  
  /// Rising edge for Online Change detected
  OnlineChange_R                 : R_TRIG;  
  /// Falling edge for Online Change detected
  OnlineChange_F                 : F_TRIG;  
  /// GroupReset active
  GroupReset                     : BOOL; 
  /// Rising edge for GroupReset
  GroupReset_R                   : R_TRIG;  
  /// Falling edge for GroupReset
  GroupReset_F                   : F_TRIG;
  /// Counter of sequences to send
  SequenceCountSend              : DINT;
  /// Counter of sequences received
  SequenceCountRecv              : DINT;
  /// Counter of fragments to send
  FragmentCountSend              : ARRAY[0..1] OF DINT;
  /// Counter of fragments received
  FragmentCountRecv              : ARRAY[0..1] OF DINT;
  /// Current Sequence ID
  CurrentSEQ                     : ARRAY[0..1] OF UINT;
  /// Current acknowledge ID
  CurrentACK                     : ARRAY[0..1] OF UINT;  
  /// Current Sequence ID has changed -> send new data 
  NewSEQ                         : ARRAY[0..1] OF BOOL;
  /// Last received acknowledge ID
  LastACK                        : ARRAY[0..1] OF UINT;    
END_STRUCT
END_TYPE


