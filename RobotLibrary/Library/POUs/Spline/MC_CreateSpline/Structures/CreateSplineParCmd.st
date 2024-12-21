{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CreateSplineParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE CreateSplineParCmd :
STRUCT
  /// Define the method to calculate the path trajectory for the spline movement
  Mode            : SplineMode;
  /// Index of the spline trajectory to be created
  SplineID        : SINT;
  /// Contains all data relevant to the spline trajectory
  /// • Cartesian position
  /// • Coordinate systems
  /// • Dynamic parameters
  /// For more information refer to chapter 5.5.13.3
  SplineData      : ARRAY[1..RobotLibraryParameter.SPLINE_DATA_MAX] OF SplineData;
END_STRUCT
END_TYPE


