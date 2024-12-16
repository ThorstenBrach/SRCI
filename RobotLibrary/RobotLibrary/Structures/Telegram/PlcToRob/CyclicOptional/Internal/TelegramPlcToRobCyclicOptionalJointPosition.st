{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramPlcToRobCyclicOptionalJointPosition                                       
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
TYPE TelegramPlcToRobCyclicOptionalJointPosition :
STRUCT
  /// Position of first joint of the robot
  J1 : REAL;
  /// Position of second joint of the robot
  J2 : REAL;
  /// Position of third joint of the robot
  J3 : REAL;
  /// Position of fourth joint of the robot
  J4 : REAL;
  /// Position of fifth joint of the robot
  J5 : REAL;
  /// Position of sixth joint of the robot
  J6 : REAL;
  /// Position of first external axis 
  E1 : REAL;  
END_STRUCT
END_TYPE


