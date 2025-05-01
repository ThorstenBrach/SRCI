FUNCTION SyncModesToDataEnableSync : DataEnableSync
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncModesToDataEnableSync                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-04-22
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
  /// Synchronization Modes
  Value : SynchronizationModes;  
END_VAR

  SyncModesToDataEnableSync.EnableSyncTool              := Value.Tool             [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.Tool             [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;                                                  
  SyncModesToDataEnableSync.EnableSyncFrame             := Value.Frame            [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.Frame            [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;
  SyncModesToDataEnableSync.EnableSyncLoad              := Value.Load             [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.Load             [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;
  SyncModesToDataEnableSync.EnableSyncWorkArea          := Value.WorkAreas        [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.WorkAreas        [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;
  SyncModesToDataEnableSync.EnableSyncSWLimits          := Value.SWLimits         [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.SWLimits         [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;
  SyncModesToDataEnableSync.EnableSyncDefaultDynamics   := Value.DefaultDynamics  [SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.DefaultDynamics  [SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;                                        
  SyncModesToDataEnableSync.EnableSyncReferenceDynamics := Value.ReferenceDynamics[SyncTime.DURING_START_UP] > SyncMode.NO_SYNCHRONIZATION OR
                                                           Value.ReferenceDynamics[SyncTime. AFTER_START_UP] > SyncMode.NO_SYNCHRONIZATION;

END_FUNCTION

