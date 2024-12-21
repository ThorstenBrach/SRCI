TYPE DataEnableSync :
{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ToDoStruct                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-22
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
STRUCT
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for tool data
  EnableSyncTool              : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for frame data
  EnableSyncFrame             : BOOL;
  ///  Set TRUE (default), to activate the synchronizationrelated comparison mechanism for load data
  EnableSyncLoad              : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for work area data
  EnableSyncWorkArea          : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for software limits
  EnableSyncSWLimits          : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for default dynamics
  EnableSyncDefaultDynamics   : BOOL;
  /// Set TRUE (default), to activate the synchronizationrelated comparison mechanism for reference dynamics
  EnableSyncReferenceDynamics : BOOL;
  /// - Allows blending when CallSubprogram is called in sequence and removed afterwards.
  /// For more information see chapter 6.5.21.
  /// • 0 (default): Dynamic blending is prevented 
  /// • 1: Dynamic blending is allowed
  AllowDynamicBlending        : BOOL ;
END_STRUCT
END_TYPE


