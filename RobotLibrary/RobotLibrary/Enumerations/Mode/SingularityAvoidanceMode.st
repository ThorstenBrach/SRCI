{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SingularityAvoidanceMode                                       
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
TYPE SingularityAvoidanceMode :
(
  /// 0: NoChange (default)
  /// Allow movement of one or more joints to avoid singularities without a change of the orientation
  NO_CHANGE := 0,
  
  /// 1: Lock J4
  /// Lock the 4th joint to avoid singularities
  LOCK_J4 := 1,
  
  /// 2: ToolOrientation
  /// Allow a small movement of the tool orientation to avoid singularities
  TOOL_ORIENTATION := 2
)USINT;
END_TYPE


