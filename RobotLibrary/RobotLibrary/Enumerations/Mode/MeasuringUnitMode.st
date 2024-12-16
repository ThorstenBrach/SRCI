{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MeasuringUnitMode                                       
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
TYPE MeasuringUnitMode :
(
	/// 0: VectorLength (default)
  ///    Defines the distance in millimeter between two points in cartesian space.
  VECTOR_LENGTH  := 0,
  /// 1: SegmentLength
  ///    Defines the distance in mm covered between the two points in cartesian space
  SEGMENT_LENGTH := 1,
  /// 2: Time
  ///    Defines the duration in milliseconds between the start and end point.
  TIME_DURATION  := 2
)USINT;
END_TYPE


