{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AreaType                                       
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
TYPE AreaType :
(
  /// 0: Axes
  AXES := 0,
  /// 1: Box (default)
  BOX := 1,
  /// 2: Cylinder
  CYLINDER := 2,
  /// 3: Sphere (only DefinitionMode 1)
  SPHERE := 3
)USINT;
END_TYPE


