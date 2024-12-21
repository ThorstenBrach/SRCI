{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionCyclicOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadActualPositionCyclicOutCmd :
STRUCT
  /// TRUE, while the output CartesianPosition returns valid values
  ReadingCartesianPosition    : BOOL;
  /// TRUE, while the output ExtCartesianPosition returns valid values
  ReadingCartesianPositionExt : BOOL;
  /// TRUE, while the output JointPosition returns valid values
  ReadingJointPosition        : BOOL;
  /// TRUE, while the output ExtJointPosition returns valid values
  ReadingJointPositionExt     : BOOL;
  /// Tool and frame index of currently used tool and frame according to Table 6-40
  CurrentCoordinateSystem     : CoordinateSystem;
  /// Cyclically returned, absolute coordinates of current position in selected coordinate systems (see input parameters ToolNo and FrameNo) 
  CartesianPosition           : RobotCartesianPositionShort;
  /// Cyclically returned, absolute cartesian position of the external axes of the robot
  CartesianPositionExt        : RobotCartesianPositionExt;
  /// Tool and frame index of returned position according to Table 6-40
  CoordinateSystem            : CoordinateSystem;
  /// Cyclically returned, absolute position of the robot in Joint position
  JointPosition               : RobotJointPositionShort;
  /// Cyclically returned, absolute joint position of the external axes of the robot
  JointPositionExt            : RobotJointPositionExt;
END_STRUCT
END_TYPE


