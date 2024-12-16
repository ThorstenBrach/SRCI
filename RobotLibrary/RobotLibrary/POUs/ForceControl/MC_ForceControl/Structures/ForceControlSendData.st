{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceControlSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
TYPE ForceControlSendData EXTENDS CmdHeader:   
STRUCT
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Define the index number of the UCS that will be assigned to the conveyor.
  /// For more information refer to chapter 5.5.14
  FrameNo            : USINT;
  /// Specifies encoder connection setup according to Table 6-713 (at least one option must be supported) 
  ConnectionMode     : SensorConnectionMode;
  /// Defines sensor positioning:
  /// • FALSE (default): Sensor mounted on flange
  /// • TRUE: Sensor fixed
  FixedSensor        : BYTE;
  /// Position of sensor relative to flange (FixedSensor FALSE) or relative to WCS (FixedSensor TRUE)
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z- Axis (RZ)
  SensorFrame        : ARRAY[0..5] OF REAL;
  /// Index of payload data containing mass, center of gravity, orientation and inertia relative to SensorFrame.
  /// Required to calibrate system for setting up gravity compensation and sensor offset.
  CalibrationData    : USINT;
  /// Defines type of reference of Force and Torque (at least one option must be supported)
  ReferenceType      : ReferenceType;
  /// Relates to ConnectionMode 1 and 2 (Sensor connected to PLC).
  /// Currently applied force and torque detected by sensor according to ReferenceType, ToolNo and FrameNo.
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z- Axis (RZ)
  SensorValue        : ARRAY[0..5] OF REAL;
  /// Relates to ReferenceType 0 (Tool) and 1 (Frame):
  /// Force and torque to be applied by robot arm according to ReferenceType, ToolNo and FrameNo:
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z- Axis (RZ)
  /// Set TargetValue <>-99999.9999 (default) to define setpoint
  TargetValue        : ARRAY[0..5] OF REAL;
  /// Maximum allowed TCP velocity for compliant axes in % of nominal velocity.
  /// •   0% (default): no limit - RC internal limit applies
  /// •  >0% use limit -  Specified limit applies
  /// • 100% use maximal reference velocity
  /// For more information on nominal dynamics see chapter 5.5.7 Robot dynamics 
  MaxVelocity        : UINT;
  /// Maximum allowed cartesian deviation according to ReferenceType, ToolNo and FrameNo.
  /// Set 0 (default) to not specify a limit in this axis direction.
  /// • [0]: Deviation in X-Direction in mm
  /// • [1]: Deviation in Y- direction in mm
  /// • [2]: Deviation in Z- direction in mm
  /// • [3]: Deviation in RX- direction in °
  /// • [4]: Deviation in RY- direction in °
  /// • [5]: Deviation in RZ- direction in °
  MaxDeviation       : ARRAY [0..5] OF REAL;
  /// Defines reaction in case ForceControl reports error during its execution
  /// Processing of active move command is continued without active ForceControl
  ErrorReaction      : ErrorReaction;
  /// Relates to ErrorReaction 0 (Abort and move). Defines type of reference coordinate system of ErrorVector
  ErrorReferenceType : ReferenceType;
  /// Relates to ErrorReaction 0 (Abort and move). Vector defining robot’s movement in case of
  /// incoming error according to ErrorReferenceType, ErrorToolNo and ErrorFrameNo.
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z-Axis (RZ)
  ErrorVector        : ARRAY [0..5] OF REAL;
  /// Relates to ErrorReaction 0 (Abort and move). Index of tool.
  /// • 0 (default): Flange
  /// • 1..254: Tool frames
  ErrorToolNo        : USINT;
  /// Relates to ErrorReferenceType 1 (Frame)
  /// •      0: WCS (default)
  /// • 1..254: User frames
  ErrorFrameNo       : USINT;
  /// Define axes whose position may be adjusted by the robot to apply specified force according to Table 6-711.
  CompliantAxes      : BYTE;
END_STRUCT
END_TYPE


