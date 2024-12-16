{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MeasuringIoMode                                       
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
TYPE MeasuringIoMode :
(
  /// Measurement at next rising edge 
  /// • Output "MeasuredPosition_1" used
	MEASUREMENT_AT_NEXT_RISING_EDGE := 0,
  /// Measurement at next falling edge 
  /// • Output "MeasuredPosition_1" used
  MEASUREMENT_AT_NEXT_FALLING_EDGE := 1,
  /// Measurement at next edges, regardless of rising or falling edges.
  /// • First position stored in output "MeasuredPosition_1"
  /// • Second position stored in output "MeasuredPosition_2"
  MEASUREMENT_AT_NEXT_EDGE := 2,
  /// Measurement at two edges, beginning with the rising edge:
  /// • Rising edge = "MeasuredPosition_1 "
  /// • Falling edge = "MeasuredPosition_2 "
  MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_RISING := 3,
  /// Measurement at two edges, beginning with the falling edge:
  /// • Falling edge = " MeasuredPosition_1 "
  /// • Rising edge = "MeasuredPosition_2 "
  MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_FALLING := 4
)USINT;
END_TYPE


