{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TrackingStatus                                       
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
TYPE TrackingStatus :
STRUCT
  /// TRUE, while a "ConveyorTracking" function is enabled
  ConveyorTrackingEnabled   : BOOL;  
  /// TRUE, while robot is waiting for condition defined by "SyncInMode" after "SyncToConveyor" has been executed
  WaitingForSynchronization : BOOL;
  /// TRUE, while robot is matching the TCP’s velocity to the conveyor’s velocity
  Synchronizing             : BOOL;
  /// TRUE, while TCP is moving synchronously to conveyor
  Synchronous               : BOOL;
  /// TRUE, while robot is terminating synchronous movement
  Desynchronizing           : BOOL;
  /// TRUE, while assigned UCS is within "SyncOutZone"
  SyncOutZoneEntered        : BOOL;
  /// TRUE, when assigned UCS leaves "SyncOutZone"
  /// Reset, when robot’s synchronous movement has been stopped
  SyncOutZoneLeft           : BOOL;
  /// Not used
  NotUsed                   : BOOL;   
END_STRUCT
END_TYPE


