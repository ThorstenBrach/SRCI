{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncInMode                                       
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
TYPE SyncInMode :
(
  /// • When work piece enters "SyncInZone"
  /// • Start synchronization as soon as possible within defined acceleration and velocity limits
	IN_SYNC_IN_ZONE := 0,
  /// • Start synchronization after specific distance after execution
  /// • "SynInZone" ignored
  AFTER_DISTANCE := 1,
  /// • Start synchronization after specific time after execution
  /// • "SynInZone" ignored
  AFTER_TIME := 2,
  /// • As soon as possible within defined acceleration and velocity limits
  /// • "SynInZone" ignored
  IMMEDIATELY := 3
)USINT;
END_TYPE


