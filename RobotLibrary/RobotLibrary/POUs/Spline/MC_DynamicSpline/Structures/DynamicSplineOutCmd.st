{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DynamicSplineOutCmd                                       
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
TYPE DynamicSplineOutCmd :
STRUCT
  /// Distance-to-go of the current job.
  /// • -1: No valid value because move command is not yet active (valid values are pending) or not supported by RC
  /// • >0: Actual distance between current and target position
  /// •  0: Target position reached 
  RemainingDistance  : REAL;
  /// Percentage of already traversed distance of actual segment of spline trajectory.
  /// If not supported: -1
  SegmentProgress    : REAL;
  /// Number of buffered, consecutive segments of spline trajectory. 
  Buffered           : INT;
  /// Number of calculated, consecutive segments of spline trajectory. Already calculated segments can no longer be modified.
  Calculated         : INT;
  /// Index of the currently active segment of spline data set.
  ActiveIndex        : SINT;  
  /// Spline movement has been finished successfully. New SplineData will start a new spline movement.
  TrajectoryCompleted: BOOL;  
END_STRUCT
END_TYPE


