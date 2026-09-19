{attribute 'qualified_only'}
// {attribute 'to_string'} // bth3ho Fanuc
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ArmConfigWrist                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE ArmConfigWrist :
(
 /// Use config in position  
 USE_CONFIG := 0,
 /// Do not change config with this movement. (default)
 SAME := 1,
 /// Configuration in position is not used but the Robot is free to change config
 FREE := 2,
 /// Set wrist configuration in position to Flip
 FLIP := 3,
 /// Set wrist configuration in position to Non-Flip
 NON_FLIP := 4
);
END_TYPE


