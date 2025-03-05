{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceLimitSendData                                       
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
TYPE ForceLimitSendData EXTENDS CmdHeader:   
STRUCT
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action        - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action         - Stop executing the Action function with the identical ListenerID.
  /// •  0: Undefined (default) - If no EmitterID is defined, the function returns an error message
  /// For more information see chapter 5.5.12.4
  EmitterID          : ARRAY [0..3] OF SINT;
  /// ListenerID
  ListenerID         : SINT; 
  /// Reserve
  Reserve            : BYTE; 
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Define the index number of the UCS that will be assigned to the conveyor.
  /// For more information refer to chapter 5.5.14
  FrameNo            : USINT;
  /// Specifies encoder connection setup according to Table 6-713 (at least one option must be supported) 
  ConnectionMode     : USINT;
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
  /// Maximal allowed force and torque detected by the sensor according to ReferenceType and ToolNo/FrameNo before robot reacts according to ReactionMode.
  /// Set value <>0 (default) to monitor coordinate axes
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z- Axis (RZ)
  ForceLimit        : ARRAY[0..5] OF REAL;  
END_STRUCT
END_TYPE


