{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncTime                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-04-13
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE SyncTime :
(
  /// Synchronization during startup
	DURING_START_UP := 0,
  /// Synchronization after startup
  AFTER_START_UP := 1
)DINT;
END_TYPE


