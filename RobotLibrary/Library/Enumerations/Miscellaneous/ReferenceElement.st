{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReferenceElement                                       
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
TYPE ReferenceElement :
(
  /// 0 (default): Not used
  NOT_USED := 0,  
  /// 1: X-Axis
  X_AXIS := 1,
  /// 2: Y-Axis
  Y_AXIS := 2,
  /// 3: Z-Axis
  Z_AXIS := 3,
  /// 4: XY-Plane
  XY_PLANE := 4,
  /// 5: XZ-Plane
  XZ_PLANE := 5,
  /// 6: YZ-Plane
  YZ_PLANE := 6
)USINT;
END_TYPE


