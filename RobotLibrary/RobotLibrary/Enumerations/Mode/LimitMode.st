{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LimitMode                                       
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
TYPE LimitMode :
(
  /// 0: No limit defined (default)
  /// The robot can be moved in the direction set with the input parameter "CompliantAxes" in a compliant manner by applying an external force on it.
  /// By reaching the mechanical or software limits, the robot stops.
  NO_LIMIT_DEFINED := 0,
  
  /// 1: Limit defined
  /// The robot can be moved along the defined vector in a compliant manner by applying an external force on it.
  /// By reaching the vector limit defined by the input parameter "VectorData", the robot stops.
  LIMIT_DEFINED := 1
)USINT;
END_TYPE


