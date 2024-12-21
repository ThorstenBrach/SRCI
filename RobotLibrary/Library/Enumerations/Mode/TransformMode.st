{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TransformMode                                       
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
TYPE TransformMode :
(
  /// 0 (default): Mirror at Point with mirroring of the target position’s orientation
  /// Requires for the mirror Point the "TransformationParameter_1" and the "TransformationParameter_2" set to "Not used"
  MIRROR_AT_POINT := 0,  
  /// 1: Mirror at Straight Line with mirroring of the target position’s orientation
  /// Requires for the Straight Line the "TransformationParameter_1" and the "TransformationParameter_2" set to "X-Axis", "Y-Axis" or "Z-Axis"
  MIRROR_AT_STRAIGHT_LINE := 1,  
  /// 2: Mirror at Plane with mirroring of the target position’s orientation
  /// Requires for the Plane the "TransformationParameter_1" and the "TransformationParameter_2" set to "XY-Axis", "XZ-Axis" or "YZ-Axis"
  MIRROR_AT_PLANE := 2,  
  /// 3: Rotate around Straight Line with rotation of the target position’s orientation
  /// Requires for the Straight Line the "TransformationParameter_1" and the "TransformationParameter_2" set to "X-Axis", "Y-Axis" or "Z-Axis"
  /// Requires for the parameter "RotationAngle"
  ROTATE_AROUND_STRAIGHT_LINE := 3,  
  /// 4: Shift by Vector
  /// Requires for the shifting Vector defined by the Point the "TransformationParameter_1" and the "TransformationParameter_2" set to "Not used"
  /// Requires for the shifting shortest Vector to the Straight Line the "TransformationParameter_1" and the "TransformationParameter_2" set to "X-Axis", "Y-Axis" or "Z-Axis"
  /// Requires for the shifting shortest Vector to the Plane the "TransformationParameter_1" and the "TransformationParameter_2" set to "XY-Axis", "XZ-Axis" or "YZ-Axis"
  SHIFT_BY_VECTOR := 4
)SINT;
END_TYPE


