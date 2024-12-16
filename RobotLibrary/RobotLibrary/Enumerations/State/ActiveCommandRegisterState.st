{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActiveCommandRegisterState                                       
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
TYPE ActiveCommandRegisterState :
(
  /// IS_FREE denotes not used but available resources (empty slots in the ACR).
	IS_FREE        := 0,
  /// IS_PROCESSING CMDs are actively being processed by client or server. 
  /// In terms of CMD category, IS_PROCESSING also describes commands whose tasks are not currently being executed (not ACTIVE), 
  /// but e.g. a CMD waiting in the Sequence buffer.
  IS_PROCESSING := 1,
  /// IS_FINAL states are reached on CMD termination. Execution of this Task has been finished and its results can be examined.
  IS_FINAL    := 2
);
END_TYPE


