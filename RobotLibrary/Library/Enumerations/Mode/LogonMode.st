{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LogonMode                                       
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
TYPE LogonMode :
(
  /// Password only (default)
  PASSWORD_ONLY := 0,
  /// Username and Password
  USERNAME_AND_PASSWORD := 1,
  /// Level ID and Password
  LEVEL_ID_AND_PASSWORD := 2
)SINT;
END_TYPE


