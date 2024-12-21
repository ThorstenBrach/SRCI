TYPE RobotTaskParCfgRob :
STRUCT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotTaskParCfgRob                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-30
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
  /// Robot parameter
  Parameter      : RobotTaskParCfgRobParameter;
  /// Configuration of optional cyclic data received from the Robot
  OptionalCyclic : AxesGroupParameterRobOptionalCyclic;
END_STRUCT
END_TYPE


