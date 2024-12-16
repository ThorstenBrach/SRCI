{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CollisionDetectionSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-22
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
TYPE CollisionDetectionSendData EXTENDS CmdHeader: 
STRUCT
  /// Set TRUE to activate and FALSE to deactivate "CollisionDetection".
  /// Default: TRUE
  ActivateMonitoring : BOOL;
  /// Relates to "LimitAxis". Defines the unit of the threshold.
  /// • [0]: Percentage (%) (default) O
  /// • [1]: Newton meter (Nm). O
  /// • [2] Milliampere (mA).
  UnitLimitAxis      : USINT;
  /// Defines the type of threshold setting (at least one option must be supported)
  ThresholdMode      : ThresholdMode;
  ///  Defines the robot behavior after detecting the collision (at least one option must be supported):
  ReactionMode       : CollisionReactionMode;
  /// Defines the level of sensitivity of all axes.
  /// • 0..99: Sensitivity lower than robot vendor default. 
  ///          At minimum value "0" there is no sensitivity. The lower the value, the lower the sensitivity at the collision detection.
  /// • 100 (default): The value is aligned with the robot vendor-specific default value.
  /// • 101..200: Sensitivity higher than robot vendor default. At maximum value "200" highest possible sensitivity at the collision detection.
  Sensitivity        : INT;
  /// Defines the level of sensitivity of the respective axis.
  /// Values:
  /// • 0..99: Sensitivity lower than robot vendor default. At minimum value "0" there is no sensitivity and collision detection for the respective axis. 
  ///          The lower the value, the lower the sensitivity at the collision detection.
  /// • 100 (default): The value is aligned with the robot vendor-specific default value.
  /// • 101..200: Sensitivity higher than robot vendor default. At maximum value "200" highest possible sensitivity at the collision detection.
  /// Index:
  /// • [0]: J1 First joint of the robot.
  /// • [1]: J2 Second joint of the robot.
  /// • [2] J3 Third joint of the robot.
  /// • [3] J4 Forth joint of the robot.
  /// • [4] J5 Fifth joint of the robot.
  /// • [5] J6 Six joint of the robot.
  /// • [6] J7 Seventh joint of the robot, if willbe used.
  SensitivityAxis    : ARRAY[0..6] OF INT;

  /// Relates to "ThresholdMode" Manual. Defines the threshold of the torque for each robot axis. If the threshold is exceeded, the RA stops.
  /// Index:
  /// • [0] J1 First joint of the robot.
  /// • [1] J2 Second joint of the robot.
  /// • [2] J3 Third joint of the robot.
  /// • [3] J4 Forth joint of the robot.
  /// • [4] J5 Fifth joint of the robot.
  /// • [5] J6 Six joint of the robot.
  /// • [6] J7 Seventh joint of the robot, if will be used
  LimitAxis          : ARRAY[0..6] OF REAL;
END_STRUCT
END_TYPE


