{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SynchronizationModes                                       
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
TYPE SynchronizationModes :
STRUCT
 /// synchronization direction for tool
 Tool              : SyncMode;
 /// synchronization direction for frame
 Frame             : SyncMode;
 /// synchronization direction for load
 Load              : SyncMode;
 /// synchronization direction for work areas
 WorkAreas         : SyncMode;
 /// synchronization direction for SW limits
 SWLimits          : SyncMode;
 /// synchronization direction for defaul dynamics
 DefaultDynamics   : SyncMode;
 /// synchronization direction for reference dynamics 
 ReferenceDynamics : SyncMode; 
END_STRUCT
END_TYPE


