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
  ///
  FatalErrorClient     : BOOL;
  ///
  Synchronized         : BOOL;
  ///
  Synchronizing        : AxesGroupStateSynchronizing;
  ///
  AliveOk              : BOOL;
  ///
  CMDsEnabled          : BOOL;
  ///
  ConfigExchanged      : BOOL;
  ///
  DataChanged          : AxesGroupStateDataChanged;
  ///
  SyncStatePlc         : AxesGroupStateSyncStatePlc;
  /// 
  SyncStateRc          : AxesGroupStateSyncStateRob;
  /// Current System Time
  SystemTime           : SystemTime;
  /// Read Robot data 
  RobotData            : ReadRobotDataOutCmd;
  /// Read configuration data
  ConfigurationData    : ExchangeConfigurationOutCmd;
  /// Robot is initialized
  Initialized          : BOOL;  
  /// Online Change detected
  OnlineChange         : BOOL;  
  /// Rising edge for Online Change detected
  OnlineChange_R       : R_TRIG;  
  /// Falling edge for Online Change detected
  OnlineChange_F       : F_TRIG;  
  /// GroupReset active
  GroupReset           : BOOL; 
  /// Rising edge for GroupReset
  GroupReset_R         : R_TRIG;  
  /// Falling edge for GroupReset
  GroupReset_F         : F_TRIG;
  /// Counter of sequences to send
  SequenceCountSend    : DINT;
  /// Counter of sequences received
  SequenceCountRecv    : DINT;
  /// Counter of fragments to send
  FragmentCountSend    : ARRAY[0..1] OF DINT;
  /// Counter of fragments received
  FragmentCountRecv    : ARRAY[0..1] OF DINT;
  /// Current Sequence ID
  CurrentSEQ           : ARRAY[0..1] OF UINT;
  /// Current acknowledge ID
  CurrentACK           : ARRAY[0..1] OF UINT;  
  /// Current Sequence ID has changed -> send new data 
  NewSEQ               : ARRAY[0..1] OF BOOL;
  /// Last received acknowledge ID
  LastACK              : ARRAY[0..1] OF UINT;    
END_STRUCT
END_TYPE


