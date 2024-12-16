{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramRobToPlcCyclicOptionalForceExt                                       
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
TYPE TelegramRobToPlcCyclicOptionalForceExt :
STRUCT
  /// Force on the external axis 1
  E1 : REAL;
  /// Force on the external axis 2
  E2 : REAL;
  /// Force on the external axis 3
  E3 : REAL;
  /// Force om the external axis 4
  E4 : REAL;
  /// Force on the external axis 5
  E5 : REAL;
  /// Force on the external axis 6
  E6 : REAL;
END_STRUCT
END_TYPE


