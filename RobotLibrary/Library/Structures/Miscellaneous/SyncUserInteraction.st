{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncUserInteraction                                       
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
TYPE SyncUserInteraction :
STRUCT
 /// synchronization of tool needs user interaction
 Tool              : BOOL;
 /// synchronization of frame needs user interaction
 Frame             : BOOL;
 /// synchronization of load needs user interaction
 Load              : BOOL;
 /// synchronization of work areas needs user interaction
 WorkAreas         : BOOL;
 /// synchronization of SW limits needs user interaction
 SWLimits          : BOOL;
 /// synchronization of defaul dynamics needs user interaction
 DefaultDynamics   : BOOL;
 /// synchronization of reference dynamics needs user interaction
 ReferenceDynamics : BOOL; 
END_STRUCT
END_TYPE


