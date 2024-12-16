{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupAcyclicExecutionOrderList                                       
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
TYPE AxesGroupAcyclicExecutionOrderList :
STRUCT
  /// Command
  Command  : ARRAY [1..RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX] OF UINT;
  /// Response
  Response : ARRAY [1..RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX] OF UINT;
END_STRUCT
END_TYPE


