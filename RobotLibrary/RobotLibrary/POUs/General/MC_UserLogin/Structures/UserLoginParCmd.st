{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UserLoginParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-30
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
TYPE UserLoginParCmd :
STRUCT
  /// Defines the logon type (at least one option must be supported)
  Mode            : LogonMode;
  /// Defines the user password.
  Password        : STRING(50);
  /// Defines the name of the operator
  Username        : STRING(50);
  /// Defines the level ID of the operator (default: 0)
  LevelID         : SINT;  
END_STRUCT
END_TYPE


