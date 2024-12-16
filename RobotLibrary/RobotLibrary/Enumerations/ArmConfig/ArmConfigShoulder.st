{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ArmConfigShoulder                                       
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
TYPE ArmConfigShoulder :
(
 /// Use config in position	
 USE_CONFIG := 0,
 /// Do not change config with this movement. (default)
 SAME := 1,
 /// Configuration in position is not used but the Robot is free to change config
 FREE := 2,
 /// Set shoulder configuration in position to Back
 BACK := 3,
 /// Set shoulder configuration in position to Front
 FRONT := 4
);
END_TYPE


