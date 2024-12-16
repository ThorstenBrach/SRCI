{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateFrameParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
TYPE CalculateFrameParCmd :
STRUCT
  /// Define which method should be used to calculate the tool frame
  Mode               : FrameCalculationMode;
  /// Index of target frame
  /// • 0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;  
  /// Cartesian position in the positive direction of the  X-Axis of the calculated frame coordinate system relative to the given frame
  Position_X         : RobotCartesianPosition;
  /// Cartesian position in the XY-plane of the calculated frame coordinate system relative to the given frame.
  Position_XY        : RobotCartesianPosition;
  /// Cartesian position of the origin of the calculated frame coordinate system relative to the given frame.
  Origin             : RobotCartesianPosition;
  /// Cartesian position of the postponement of the origin of the calculated frame coordinate system relative to the given frame.
  /// Auxiliary position if the origin of the can’t be reached by the robot, i.e. because it is inside an object.
  OriginShift        : RobotCartesianPosition;
  /// Index of frame on which the calculated frame is depending
  /// •      0: WCS (default)
  /// • 1..254: User frames
  ReferenceFrame     : USINT;
END_STRUCT
END_TYPE


