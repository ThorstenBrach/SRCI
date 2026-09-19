{attribute 'qualified_only'}
{attribute 'to_string'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BlendingMode                                       
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
TYPE BlendingMode :
(
  /// Appended, buffered, no blending
  EXACT_STOP := 0,
  /// Start blending when the defined velocity is reached
  DEFINED_VELOCITY := 2,
  /// Define blending sphere with radius
  CORNER_DISTANCE := 3,
  /// Define blending with deviation
  MAX_CORNER_DEVIATION := 4,
  /// Define blending sphere with 2 radiuses
  CORNER_DISTANCE_2R := 10,
  /// Define blending with percentage of overlapping of deceleration and acceleration ramp
  RAMP_OVERLAP := 11,
  /// Define blending sphere with starting radius
  CORNER_DISTANCE_1R := 12
)USINT;
END_TYPE


