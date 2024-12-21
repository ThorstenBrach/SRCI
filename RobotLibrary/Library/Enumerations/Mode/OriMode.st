{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      OriMode                                       
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
TYPE OriMode :
(
  /// Change orientation continuously in a linear way
  LINEAR_INTERPOLATED := 1,
  /// Change orientation continuously in a joint interpolated way.
  JOINT_INTERPOLATED  := 2,
  /// No change of orientation during movement
  FIX                 := 3,
  /// No change of orientation in relation to trajectory
  PATH                := 4
)USINT;
END_TYPE


