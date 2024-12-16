{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CmdType                                       
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
TYPE CmdType :
(
  /// Handles multiple mechanisms required for operation of the interface
  RobotTask := 0, // No function code  
  /// Read robot-specific data from the RC
  ReadRobotData := 9002,  
  /// Enable/Disable robot into RA power state "Enabled"
  EnableRobot := 1000,  
  /// Acknowledgement all pending errors
  GroupReset := 1001,  
  /// Read the actual position – TCP: X…RZ + config/Turn, Joint: (J1…E6)
  ReadActualPosition := 5100,
  /// Read the actual position cyclically
  ReadActualPositionCyclic := 1, // No function code  
  /// Read D-H-parameters of robot
  ReadDHParameter := 5101,  
  /// Restart/reboot of the RC
  RestartController := 1101,  
  /// Read actual TCP velocity
  ReadActualTCPVelocity := 5111,  
  /// Login on RC from PLC
  UserLogin := 1006,  
  /// Switch language of robot teach pendant from PLC
  SwitchLanguage := 1005,  
  /// Reads and writes specific configuration parameters on RC that are required for the RI to work
  ExchangeConfiguration := 9000,  
  /// Set active sequence
  SetSequence := 1004,  
  /// Change actual speed override
  ChangeSpeedOverride := 2000,  
  /// Read error codes of pending errors and move them into user data block "RobotData"
  ReadMessages := 9001,  
  /// Read reference values of robot dynamics for path movement
  ReadRobotReferenceDynamics := 5105,  
  /// Change configuration of selected user frame number
  WriteFrameData := 5200,  
  /// Change configuration of selected tool number
  WriteToolData := 5205,  
  /// Change configuration of selected payload number
  WriteLoadData := 5201,  
  /// Write reference values of robot dynamics for path movement
  WriteRobotReferenceDynamics := 5203,  
  /// Write default values of dynamic parameters used by move commands
  WriteRobotDefaultDynamics := 5202,  
  /// Read default values of dynamic parameters used by move commands
  ReadRobotDefaultDynamics := 5104,  
  /// Read content of selected user frame number
  ReadFrameData := 5102,  
  /// Read content of selected tool number
  ReadToolData := 5107,  
  /// Read content of selected payload number
  ReadLoadData := 5103,  
  /// Read actual software limits of the axes Positive and negative Limit of Joint J1…J6, E1…E6
  ReadRobotSWLimits := 5106,  
  /// Change robot limits of robot axes (degree)
  WriteRobotSWLimits := 5204,  
  /// Switch operation mode of RC (Automatic External, T1 External, T2 External)
  SetOperationMode := 1003,  
  /// Read configuration of defined work areas
  ReadWorkArea := 7502,  
  /// Define work area
  WriteWorkArea := 7503,  
  /// Enable/Disable work areas of RC and check if TCP is inside/outside of active work area
  ActivateWorkArea := 7500,  
  /// Monitor enabled work areas
  MonitorWorkArea := 7501,  
  /// Jog robot manually
  GroupJog := 2100,  
  /// Move the TCP to an absolute cartesian position (linear interpolation)
  MoveLinearAbsolute := 2103,  
  /// Move Joints to an absolute cartesian position (Absolute cartesian PTP) (Joint interpolated movement)
  MoveDirectAbsolute := 2102,  
  /// Move all joints to an absolute joint position (Absolute Joint PTP)
  MoveAxesAbsolute := 2101,  
  /// Abort actual movement and delete buffer
  GroupStop := 2003,  
  /// Interrupt active movement, possible to continue movement
  GroupInterrupt := 2002,  
  /// Continue interrupted path
  GroupContinue := 2001,  
  /// Move the TCP relative to the actual cartesian position (linear interpolation)
  MoveLinearRelative := 2110,  
  /// Move Joints relative to relative cartesian position (Relative cartesian PTP) (Joint interpolated movement)
  MoveDirectRelative := 2108,  
  /// Move all joints relative to actual joint position (Relative Joint PTP)
  MoveAxesRelative := 2105,  
  /// Return to path left during active interrupt
  ReturnToPrimary := 2104,  
  /// Move the TCP to an absolute joint position (linear interpolation)
  MoveCircularAbsolute := 2109,  
  /// Move the TCP relative to the actual cartesian position (circular interpolation)
  MoveCircularRelative := 2106,  
  /// Move the TCP relative to a reference cartesian position (linear interpolation)
  MoveLinearOffset := 2112,  
  /// Move the TCP relative to a reference cartesian position (PTPT interpolation)
  MoveDirectOffset := 2111,  
  /// Set wait command between motion commands
  WaitTime := 7005,  
  /// Linear Move to target position through auxiliary position defined by offset in all dimensions (movement to target position linear)
  MoveApproachLinear := 2201,  
  /// Linear Move from actual position to destination through auxiliary position defined by offset in all dimensions (movement to target position linear)
  MoveDepartLinear := 2203,  
  /// Direct Move to target position through auxiliary position defined by offset in all dimensions (movement to target posi tion PTP)
  MoveApproachDirect := 2200,  
  /// Direct Move from actual position to destination through auxiliary position defined by offset in all dimensions (movement to the target position PTP)
  MoveDepartDirect := 2202,  
  /// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
  SearchHardstop := 2500,  
  /// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
  SearchHardstopJ := 2501,  
  /// Command several interpolated movement of robot arm on linear paths from actual position
  MovePickPlaceLinear := 2205,  
  /// Commands interpolated movement of robot arm on a partly undefined path from actual position
  MovePickPlaceDirect := 2204,  
  /// Activate conveyor tracking mode
  ActivateConveyorTracking := 2300,  
  /// Redefine tracking position for conveyor tracking
  RedefineTrackingPos := 2302,  
  /// Synchronize robot with conveyor
  SyncToConveyor := 2303,  
  /// Configure conveyor parameters
  ConfigureConveyor := 2301,  
  /// Activate superimposed motion of TCP to defined motion
  MoveSuperImposed := 2502,  
  /// Activate superimposed motion of TCP to defined motion
  MoveSuperImposedDynamic := 2503,  
  /// Read digital input and output group of RC
  ReadDigitalInputs := 6100,  
  /// Read digital output group of RC
  ReadDigitalOutputs := 6101,  
  /// Write digital output group of RC
  WriteDigitalOutputs := 6104,  
  /// Read integer values on RC
  ReadIntegers := 6102,  
  /// Read real values on RC
  ReadReals := 6103,  
  /// Write integer values on RC
  WriteIntegers := 6105,  
  /// Write real values on RC
  WriteReals := 6106,  
  /// Set trigger in defined position of path (L = Linear Path) (cartesian) switch periphery.
  MoveLinearCam := 2402,  
  /// Set a trigger in a defined position of a path. (PTP)
  MoveDirectCam := 2401,  
  /// Set a trigger in a defined position of a circular path
  MoveCircularCam := 2400,  
  /// Read analog input of RC
  ReadAnalogInput := 6107,  
  /// Read analog output of RC
  ReadAnalogOutput := 6108,  
  /// Write analog output of RC
  WriteAnalogOutput := 6109,  
  /// Capture trigger Position, measuring input
  MeasuringInput := 6001,  
  /// Abort triggering of Position, measuring input
  AbortMeasuringInput := 6000,  
  /// Trigger "Actions" based on I/O related events (e.g. change of DI’s state)
  SetTriggerRegister := 3004,  
  /// Trigger "Actions" based on physical events (e.g. force limit reached)
  SetTriggerLimit := 3002,  
  /// Trigger "Actions" based on physical events (e.g. force limit reached)
  SetTriggerUser := 3005,  
  /// Trigger "Actions" based on incoming error event
  SetTriggerError := 3001,  
  /// "Action" that initiates specified events when triggered
  ReactAtTrigger := 3000,  
  /// Wait to process next command in sequence until trigger signal is received
  WaitForTrigger := 3006,  
  /// Read specific parameter of the robot
  ReadSystemVariable := 5109,  
  /// Change value of specific vendor parameter
  WriteSystemVariable := 5206,  
  /// Calculate Forward Kinematic
  CalculateForwardKinematic := 7203,  
  /// Calculate Inverse Kinematic
  CalculateInverseKinematic := 7204,  
  /// Calculate cartesian position from existing cartesian position
  CalculateCartesianPosition := 7200,  
  /// Calculate tool (TCP) with four-point method
  CalculateTool := 7202,  
  /// Calculate frame with three-point method
  CalculateFrame := 7201,  
  /// Cancel currently active move command and continue with the next buffered command
  ActivateNextCommand := 7000,  
  /// Transform a defined position in space
  ShiftPosition := 7205,  
  /// Trigger an action based on a motion-related parameter (e.g. progress of trajectory)
  SetTriggerMotion := 3003,  
  /// Release robot arm’s brakes
  OpenBrake := 7100,  
  /// Call subprogram stored in RC from PLC
  CallSubprogram := 7001,  
  /// Writes cyclic data of called subprogram
  WriteCallSubprogramCyclic := 2, // No function code
  /// Reads cyclic data of called subprogram
  ReadCallSubprogramCyclic := 3, // No function code
  /// Stops an active subprogram
  StopSubprogram := 7008,  
  /// Switch path mode between high and low accuracy
  PathAccuracyMode := 7401,  
  /// Activate/Deactivate functionality to avoid singularities
  AvoidSingularity := 7400,  
  /// Enables the RC to apply user-defined force/torque through RA’s TCP movement
  ForceControl := 7301,  
  /// Commands specified reaction from RA when defined force/torque detected
  ForceLimit := 7302,  
  /// Read actual force/torque at TCP
  ReadActualForce := 5110,  
  /// Activate robot cycle brake test and give feedback to PLC
  BrakeTest := 7101,  
  /// Push robot: Robot calculates opposite vector and moves slowly in that direction
  SoftSwitchTCP := 7300,  
  /// Create spline on RC from positions stored in PLC
  CreateSpline := 2600,  
  /// Delete spline previously created on RC
  DeleteSpline := 2601,  
  /// Move spline previously created on RC
  MoveSpline := 2603,  
  /// Create and move spline on RC simultaneously
  DynamicSpline := 2602,  
  /// Automatic detection of load data
  LoadMeasurementAutomatic := 7006,  
  /// Sequential detection of load data
  LoadMeasurementSequential := 7007,  
  /// Turn on/off the collision detection
  CollisionDetection := 7003,  
  /// Move the robot axes by hand
  FreeDrive := 7002,  
  /// Measure the length of objects in the cartesian space, execution time for specified section of a job or signal output time of a specified signal
  UnitMeasurement := 7004   
)UINT;
END_TYPE


