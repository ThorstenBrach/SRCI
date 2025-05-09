{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramPlcToRobCyclicOptionalCurrentExt                                       
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
TYPE TelegramPlcToRobCyclicOptionalCurrentExt :
STRUCT
  /// Current of first external joint of the robot
  E1 : REAL;
  /// Current of second external axis
  E2: REAL;
  /// Current of third external axis
  E3: REAL;
  /// Current of fourth external axis
  E4: REAL;
  /// Current of fifth external axis
  E5: REAL;
  /// Current of sixth external axis
  E6: REAL;  
END_STRUCT
END_TYPE


