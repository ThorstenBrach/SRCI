{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ResistanceForceMode                                       
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
TYPE ResistanceForceMode :
(
  /// 0 (default): ResistanceForceTCP.
  /// Set "0" to set the resistance of the RA against the external force at the TCP.
  RESISTANCE_FORCE_TCP := 0,
  
  /// 1: ResistanceForceAxis.
  /// Set "1" to set the resistance of the RA against the external force for each axis independently.
  RESISTANCE_FORCE_AXIS := 1
)USINT;
END_TYPE


