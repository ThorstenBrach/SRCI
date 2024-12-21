{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupParameterOptionalCyclic                                       
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
TYPE AxesGroupParameterOptionalCyclic :
STRUCT
  /// Configuration of optional cyclic data send to the Robot
  PlcToRob : AxesGroupParameterOptionalCyclicPlcToRob;
  /// Configuration of optional cyclic data received from the Robot
  RobToPlc : AxesGroupParameterOptionalCyclicRobToPlc;
END_STRUCT
END_TYPE


