{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CircMode                                       
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
TYPE CircMode :
(
  /// "AuxPoint" defines a point on the circle crossed on the path from the starting to the end point.
  BORDER := 0,
  /// "AuxPoint" defines the center point of the circle.
  CENTER := 1,
  /// "AuxPoint" defines the center point of the circle, "Angle" defines the end position of the circular motion, and "CircPlane" defines the circle’s plane.
  CENTER_WITH_ANGLE := 2,
  /// "AuxPoint" defines a vector which length is the radius of the circle. The plane of the circle is defined by the rule of right thumb while the "AuxPoint" defines the spearhead point of the perpendicular.
  RADIUS := 3
)SINT;
END_TYPE


