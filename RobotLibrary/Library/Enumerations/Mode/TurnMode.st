{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TurnMode                                       
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
TYPE TurnMode :
(
  /// Use TurnNumber in position
  USE_TURN_NUMBER := 0,
  ///  Do not change TurnNumber with this movement
  SAME            := 1,
  /// TurnNumber in position is not used but the Robot is free to change TurnNumber
  FREE            := 2
)USINT;
END_TYPE


