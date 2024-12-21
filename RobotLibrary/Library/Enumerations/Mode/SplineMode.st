{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SplineMode                                       
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
TYPE SplineMode :
(
  /// 0: Discrete Points
  DISCRETE_POINTS := 0,
  /// 1: Bézier Spline
  BEZIER_SPLINE := 1,
  /// 2: B-Splines
  B_SPLINES := 2,
  /// 3: Cubic Hermite Spline
  CUBIC_HERMITE_SPLINE := 3,
  /// 4: C-Splines
  C_SPLINES := 4
)UINT;
END_TYPE


