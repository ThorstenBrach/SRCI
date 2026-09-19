{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotTaskParCfgPlc                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-30
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
TYPE RobotTaskParCfgPlc :
STRUCT
  /// PLC cycle time
  CycleTime      : TIME := T#10MS;
  /// parameter
  Parameter      : RobotTaskParCfgPlcParameter;  
  /// Configuration of optional cyclic data send to the Robot
  OptionalCyclic : AxesGroupParameterPlcOptionalCyclic;
END_STRUCT
END_TYPE


