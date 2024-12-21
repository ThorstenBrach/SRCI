{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupParameterCmdEntries                                       
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
TYPE AxesGroupParameterCmdEntries :
(
  /// Handles multiple mechanisms required for operation of the interface
  RobotTask := 0, // No function code  
  /// Read robot-specific data from the RC
  ReadRobotData := 9002,  
  /// Enable/Disable robot into RA power state "Enabled"
  EnableRobot := 1,  
  /// Acknowledgement all pending errors
  GroupReset := 2,  
  /// Read the actual position – TCP: X…RZ + config/Turn, Joint: (J1…E6)
  ReadActualPosition := 3,
  /// Read the actual position cyclically
  ReadActualPositionCyclic := 4,   
  /// Read D-H-parameters of robot
  ReadDHParameter := 5,  
  /// Restart/reboot of the RC
  RestartController := 6,  
  /// Read actual TCP velocity
  ReadActualTCPVelocity := 7,  
  /// Login on RC from PLC
  UserLogin := 8,  
  /// Switch language of robot teach pendant from PLC
  SwitchLanguage := 9,  
  /// Reads and writes specific configuration parameters on RC that are required for the RI to work
  ExchangeConfiguration := 10,  
  /// Set active sequence
  SetSequence := 11,  
  /// Change actual speed override
  ChangeSpeedOverride := 12,  
  /// Read error codes of pending errors and move them into user data block "RobotData"
  ReadMessages := 13,  
  /// Read reference values of robot dynamics for path movement
  ReadRobotReferenceDynamics := 14,  
  /// Change configuration of selected user frame number
  WriteFrameData := 15,  
  /// Change configuration of selected tool number
  WriteToolData := 16,  
  /// Change configuration of selected payload number
  WriteLoadData := 17,  
  /// Write reference values of robot dynamics for path movement
  WriteRobotReferenceDynamics := 18,  
  /// Write default values of dynamic parameters used by move commands
  WriteRobotDefaultDynamics := 19,  
  /// Read default values of dynamic parameters used by move commands
  ReadRobotDefaultDynamics := 20,  
  /// Read content of selected user frame number
  ReadFrameData := 21,  
  /// Read content of selected tool number
  ReadToolData := 22,  
  /// Read content of selected payload number
  ReadLoadData := 23,  
  /// Read actual software limits of the axes Positive and negative Limit of Joint J1…J6, E1…E6
  ReadRobotSWLimits := 24,  
  /// Change robot limits of robot axes (degree)
  WriteRobotSWLimits := 25,  
  /// Switch operation mode of RC (Automatic External, T1 External, T2 External)
  SetOperationMode := 26,  
  /// Read configuration of defined work areas
  ReadWorkArea := 27,  
  /// Define work area
  WriteWorkArea := 28,  
  /// Enable/Disable work areas of RC and check if TCP is inside/outside of active work area
  ActivateWorkArea := 29,  
  /// Monitor enabled work areas
  MonitorWorkArea := 30,  
  /// Jog robot manually
  GroupJog := 31,  
  /// Move the TCP to an absolute cartesian position (linear interpolation)
  MoveLinearAbsolute := 32,  
  /// Move Joints to an absolute cartesian position (Absolute cartesian PTP) (Joint interpolated movement)
  MoveDirectAbsolute := 33,  
  /// Move all joints to an absolute joint position (Absolute Joint PTP)
  MoveAxesAbsolute := 34,  
  /// Abort actual movement and delete buffer
  GroupStop := 35,  
  /// Interrupt active movement, possible to continue movement
  GroupInterrupt := 36,  
  /// Continue interrupted path
  GroupContinue := 37,  
  /// Move the TCP relative to the actual cartesian position (linear interpolation)
  MoveLinearRelative := 38,  
  /// Move Joints relative to relative cartesian position (Relative cartesian PTP) (Joint interpolated movement)
  MoveDirectRelative := 39,  
  /// Move all joints relative to actual joint position (Relative Joint PTP)
  MoveAxesRelative := 40,  
  /// Return to path left during active interrupt
  ReturnToPrimary := 41,  
  /// Move the TCP to an absolute joint position (linear interpolation)
  MoveCircularAbsolute := 42,  
  /// Move the TCP relative to the actual cartesian position (circular interpolation)
  MoveCircularRelative := 43,  
  /// Move the TCP relative to a reference cartesian position (linear interpolation)
  MoveLinearOffset := 44,  
  /// Move the TCP relative to a reference cartesian position (PTPT interpolation)
  MoveDirectOffset := 45,  
  /// Set wait command between motion commands
  WaitTime := 46,  
  /// Linear Move to target position through auxiliary position defined by offset in all dimensions (movement to target position linear)
  MoveApproachLinear := 47,  
  /// Linear Move from actual position to destination through auxiliary position defined by offset in all dimensions (movement to target position linear)
  MoveDepartLinear := 48,  
  /// Direct Move to target position through auxiliary position defined by offset in all dimensions (movement to target posi tion PTP)
  MoveApproachDirect := 49,  
  /// Direct Move from actual position to destination through auxiliary position defined by offset in all dimensions (movement to the target position PTP)
  MoveDepartDirect := 50,  
  /// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
  SearchHardstop := 51,  
  /// Move robot into contact with obstruction (mechanical Limit) and hold it in this position
  SearchHardstopJ := 52,  
  /// Command several interpolated movement of robot arm on linear paths from actual position
  MovePickPlaceLinear := 53,  
  /// Commands interpolated movement of robot arm on a partly undefined path from actual position
  MovePickPlaceDirect := 54,  
  /// Activate conveyor tracking mode
  ActivateConveyorTracking := 55,  
  /// Redefine tracking position for conveyor tracking
  RedefineTrackingPos := 56,  
  /// Synchronize robot with conveyor
  SyncToConveyor := 57,  
  /// Configure conveyor parameters
  ConfigureConveyor := 58,  
  /// Activate superimposed motion of TCP to defined motion
  MoveSuperImposed := 59,  
  /// Activate superimposed motion of TCP to defined motion
  MoveSuperImposedDynamic := 60,  
  /// Read digital input and output group of RC
  ReadDigitalInputs := 61,  
  /// Read digital output group of RC
  ReadDigitalOutputs := 62,  
  /// Write digital output group of RC
  WriteDigitalOutputs := 63,  
  /// Read integer values on RC
  ReadIntegers := 64,  
  /// Read real values on RC
  ReadReals := 65,  
  /// Write integer values on RC
  WriteIntegers := 66,  
  /// Write real values on RC
  WriteReals := 67,  
  /// Set trigger in defined position of path (L = Linear Path) (cartesian) switch periphery.
  MoveLinearCam := 68,  
  /// Set a trigger in a defined position of a path. (PTP)
  MoveDirectCam := 69,  
  /// Set a trigger in a defined position of a circular path
  MoveCircularCam := 70,  
  /// Read analog input of RC
  ReadAnalogInput := 71,  
  /// Read analog output of RC
  ReadAnalogOutput := 72,  
  /// Write analog output of RC
  WriteAnalogOutput := 73,  
  /// Capture trigger Position, measuring input
  MeasuringInput := 74,  
  /// Abort triggering of Position, measuring input
  AbortMeasuringInput := 75,  
  /// Trigger "Actions" based on I/O related events (e.g. change of DI’s state)
  SetTriggerRegister := 76,  
  /// Trigger "Actions" based on physical events (e.g. force limit reached)
  SetTriggerLimit := 77,  
  /// Trigger "Actions" based on physical events (e.g. force limit reached)
  SetTriggerUser := 78,  
  /// Trigger "Actions" based on incoming error event
  SetTriggerError := 79,  
  /// "Action" that initiates specified events when triggered
  ReactAtTrigger := 80,  
  /// Wait to process next command in sequence until trigger signal is received
  WaitForTrigger := 81,  
  /// Read specific parameter of the robot
  ReadSystemVariable := 82,  
  /// Change value of specific vendor parameter
  WriteSystemVariable := 83,  
  /// Calculate Forward Kinematic
  CalculateForwardKinematic := 84,  
  /// Calculate Inverse Kinematic
  CalculateInverseKinematic := 85,  
  /// Calculate cartesian position from existing cartesian position
  CalculateCartesianPosition := 86,  
  /// Calculate tool (TCP) with four-point method
  CalculateTool := 87,  
  /// Calculate frame with three-point method
  CalculateFrame := 88,  
  /// Cancel currently active move command and continue with the next buffered command
  ActivateNextCommand := 89,  
  /// Transform a defined position in space
  ShiftPosition := 90,  
  /// Trigger an action based on a motion-related parameter (e.g. progress of trajectory)
  SetTriggerMotion := 91,  
  /// Release robot arm’s brakes
  OpenBrake := 92,  
  /// Call subprogram stored in RC from PLC
  CallSubprogram := 93,  
  /// Writes cyclic data of called subprogram
  WriteCallSubprogramCyclic := 94,
  /// Reads cyclic data of called subprogram
  ReadCallSubprogramCyclic := 95,
  /// Stops an active subprogram
  StopSubprogram := 96,  
  /// Switch path mode between high and low accuracy
  PathAccuracyMode := 97,  
  /// Activate/Deactivate functionality to avoid singularities
  AvoidSingularity := 98,  
  /// Enables the RC to apply user-defined force/torque through RA’s TCP movement
  ForceControl := 99,  
  /// Commands specified reaction from RA when defined force/torque detected
  ForceLimit := 100,  
  /// Read actual force/torque at TCP
  ReadActualForce := 101,  
  /// Activate robot cycle brake test and give feedback to PLC
  BrakeTest := 102,  
  /// Push robot: Robot calculates opposite vector and moves slowly in that direction
  SoftSwitchTCP := 103,  
  /// Create spline on RC from positions stored in PLC
  CreateSpline := 104,  
  /// Delete spline previously created on RC
  DeleteSpline := 105,  
  /// Move spline previously created on RC
  MoveSpline := 106,  
  /// Create and move spline on RC simultaneously
  DynamicSpline := 107,  
  /// Automatic detection of load data
  LoadMeasurementAutomatic := 108,  
  /// Sequential detection of load data
  LoadMeasurementSequential := 109,  
  /// Turn on/off the collision detection
  CollisionDetection := 110,  
  /// Move the robot axes by hand
  FreeDrive := 111,  
  /// Measure the length of objects in the cartesian space, execution time for specified section of a job or signal output time of a specified signal
  UnitMeasurement := 112,
  /// Maximum entry
  MAX_ENTRY := 113   
)UINT;
END_TYPE


