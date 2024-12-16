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
  FatalErrorClient  : BOOL;
  ///
  Initialized       : BOOL;
  ///
  Synchronized      : BOOL;
  ///
  Synchronizing     : AxesGroupStateSynchronizing;
  ///
  AliveOk           : BOOL;
  ///
  CMDsEnabled       : BOOL;
  ///
  ConfigExchanged   : BOOL;
  /// 
  RobotIdent        : DT;
  ///
  DataChanged       : AxesGroupStateDataChanged;
  ///
  SyncStatePlc      : AxesGroupStateSyncStatePlc;
  /// 
  SyncStateRc       : AxesGroupStateSyncStateRob;
  ///
  ResetMsg          : AxesGroupStateResetMsg;
  ///
  IncrementFastStop : BOOL;
  /// Robot Data
  RobotData         : AxesGroupRobotData;
END_STRUCT
END_TYPE


