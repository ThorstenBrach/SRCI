{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotCartesianPositionShort                                       
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
TYPE RobotCartesianPositionShort EXTENDS RobotCartesianPositionBase:
STRUCT
  /// Configuration data of the robot (Config)
  Config     : ArmConfigParameter;
  /// Turn number of the axes (TurnNumber)
  TurnNumber : TurnNumber;
  /// Position of first external axis
  E1         : REAL;
END_STRUCT
END_TYPE


