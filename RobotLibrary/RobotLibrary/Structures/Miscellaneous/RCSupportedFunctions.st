{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RCSupportedFunctions                                       
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
TYPE RCSupportedFunctions :
STRUCT
  /// Byte 00 - Bit 0  
  Reserved                   : BOOL;
  /// Byte 00 - Bit 1 
  ReadRobotData              : BOOL;
  /// Byte 00 - Bit 2  
  EnableRobot                : BOOL;
  /// Byte 00 - Bit 3  
  GroupReset                 : BOOL;
  /// Byte 00 - Bit 4  
  ReadActualPosition         : BOOL;
  /// Byte 00 - Bit 5 
  ReadActualPositionCyclic   : BOOL;
  /// Byte 00 - Bit 6  
  ExchangeConfiguration      : BOOL;
  /// Byte 00 - Bit 7  
  SetSequence                : BOOL;
  
  /// Byte 01 - Bit 0  
  ChangeSpeedOverride        : BOOL;
  /// Byte 01 - Bit 1  
  ReadMessages               : BOOL;
  /// Byte 01 - Bit 2  
  ReadRobotReferenceDynamics : BOOL;
  /// Byte 01 - Bit 3  
  WriteFrameData             : BOOL;
  /// Byte 01 - Bit 4  
  WriteToolData              : BOOL;
  /// Byte 01 - Bit 5  
  WriteLoadData              : BOOL;
  /// Byte 01 - Bit 6  
  WriteRobotReferenceDynamics: BOOL;
  /// Byte 01 - Bit 7  
  WriteRobotDefaultDynamics  : BOOL;
  
  /// Byte 02 - Bit 0  
  ReadRobotDefaultDynamics   : BOOL;
  /// Byte 02 - Bit 1  
  ReadFrameData              : BOOL;
  /// Byte 02 - Bit 2  
  ReadToolData               : BOOL;
  /// Byte 02 - Bit 3  
  ReadLoadData               : BOOL;
  /// Byte 02 - Bit 4  
  ReadRobotSWLimits          : BOOL;
  /// Byte 02 - Bit 5  
  GroupJog                   : BOOL;
  /// Byte 02 - Bit 6  
  MoveLinearAbsolute         : BOOL;
  /// Byte 02 - Bit 7  
  MoveDirectAbsolute         : BOOL;
  
  /// Byte 03 - Bit 0  
  MoveAxesAbsolute           : BOOL;
  /// Byte 03 - Bit 1  
  GroupStop                  : BOOL;
  /// Byte 03 - Bit 2
  GroupContinue              : BOOL;
  /// Byte 03 - Bit 3
  GroupInterrupt             : BOOL;
  /// Byte 03 - Bit 4
  ReturnToPrimary            : BOOL;
  /// Byte 03 - Bit 5
  MoveLinearAbsoluteJ        : BOOL;
  /// Byte 03 - Bit 6
  MoveDirectRelative         : BOOL;
  /// Byte 03 - Bit 7
  MoveAxesRelative           : BOOL;
  
  /// Byte 04 - Bit 0
  MoveCircularAbsolute       : BOOL;
  /// Byte 04 - Bit 1
  MoveCircularRelative       : BOOL;
  /// Byte 04 - Bit 2
  MoveLinearOffset           : BOOL;
  /// Byte 04 - Bit 3
  MoveDirectOffset           : BOOL;
  /// Byte 04 - Bit 4
  WaitTime                   : BOOL;
  /// Byte 04 - Bit 5
  ReadDigitalInputs          : BOOL;
  /// Byte 04 - Bit 6
  ReadDigitalOutputs         : BOOL;
  /// Byte 04 - Bit 7
  WriteDigitalOutputs        : BOOL;
  
  /// Byte 05 - Bit 0
  ReadIntegers               : BOOL;
  /// Byte 05 - Bit 1
  ReadReals                  : BOOL;
  /// Byte 05 - Bit 2
  WriteIntegers              : BOOL;
  /// Byte 05 - Bit 3
  WriteReals                 : BOOL;
  /// Byte 05 - Bit 4
  MoveLinearCam              : BOOL;
  /// Byte 05 - Bit 5
  MoveDirectCam              : BOOL;
  /// Byte 05 - Bit 6
  MoveCircularCam            : BOOL;
  /// Byte 05 - Bit 7
  SetTriggerRegister         : BOOL;
  
  /// Byte 06 - Bit 0
  SetTriggerLimit            : BOOL;
  /// Byte 06 - Bit 1
  SetTriggerUser             : BOOL;
  /// Byte 06 - Bit 2
  SetTriggerError            : BOOL;
  /// Byte 06 - Bit 3
  ReactAtTrigger             : BOOL;
  /// Byte 06 - Bit 4
  WaitForTrigger             : BOOL;
  /// Byte 06 - Bit 5
  ReadSystemVariable         : BOOL;
  /// Byte 06 - Bit 6
  WriteSystemVariable        : BOOL;
  /// Byte 06 - Bit 7
  CalculateForwardKinematic  : BOOL;
  
  /// Byte 07 - Bit 0
  CalculateInverseKinematic  : BOOL;
  /// Byte 07 - Bit 1
  CalculateCartesianPosition : BOOL;
  /// Byte 07 - Bit 2
  CalculateTool              : BOOL;
  /// Byte 07 - Bit 3
  CalculateFrame             : BOOL;
  /// Byte 07 - Bit 4
  ActivateNextCommand        : BOOL;
  /// Byte 07 - Bit 5
  ShiftPosition              : BOOL;
  /// Byte 07 - Bit 6
  CallSubprogram             : BOOL;
  /// Byte 07 - Bit 7
  MoveLinearRelative         : BOOL;
  
  /// Byte 08 - Bit 0
  WriteCallSubprogramCyclic  : BOOL;
  /// Byte 08 - Bit 1
  ReadCallSubprogramCyclic   : BOOL;
  /// Byte 08 - Bit 2
  StopSubprogram             : BOOL;
  /// Byte 08 - Bit 3
  ReadDHParameter            : BOOL;
  /// Byte 08 - Bit 4
  RestartController          : BOOL;
  /// Byte 08 - Bit 5
  ReadActualTCPVelocity      : BOOL;
  /// Byte 08 - Bit 6
  UserLogin                  : BOOL;
  /// Byte 08 - Bit 7
  SwitchLanguage             : BOOL;
  
  /// Byte 09 - Bit 0
  WriteRobotSWLimits         : BOOL;
  /// Byte 09 - Bit 1
  SetOperationMode           : BOOL;
  /// Byte 09 - Bit 2
  ReadWorkArea               : BOOL;
  /// Byte 09 - Bit 3
  WriteWorkArea              : BOOL;
  /// Byte 09 - Bit 4
  ActivateWorkArea           : BOOL;
  /// Byte 09 - Bit 5
  MonitorWorkArea            : BOOL;
  /// Byte 09 - Bit 6
  MoveApproachLinear         : BOOL;
  /// Byte 09 - Bit 7
  MoveDepartLinear           : BOOL;
  
  /// Byte 10 - Bit 0
  MoveApproachDirect         : BOOL;
  /// Byte 10 - Bit 1
  MoveDepartDirect           : BOOL;
  /// Byte 10 - Bit 2
  SearchHardstop             : BOOL;
  /// Byte 10 - Bit 3
  SearchHardstopJ            : BOOL;
  /// Byte 10 - Bit 4
  MovePickPlaceLinear        : BOOL;
  /// Byte 10 - Bit 5
  MovePickPlaceDirect        : BOOL;
  /// Byte 10 - Bit 6
  ActivateConveyorTracking   : BOOL;
  /// Byte 10 - Bit 7
  RedefineTrackingPosition   : BOOL;

  /// Byte 11 - Bit 0
  SyncToConveyor             : BOOL;
  /// Byte 11 - Bit 1
  ConfigureConveyor          : BOOL;
  /// Byte 11 - Bit 2
  MoveSuperImposed           : BOOL;
  /// Byte 11 - Bit 3
  MoveSuperImposedDynamic    : BOOL;
  /// Byte 11 - Bit 4
  ReadAnalogInput            : BOOL;
  /// Byte 11 - Bit 5
  ReadAnalogOutput           : BOOL;
  /// Byte 11 - Bit 6
  WriteAnalogOutput          : BOOL;
  /// Byte 11 - Bit 7
  MeasuringInput             : BOOL;

  /// Byte 12 - Bit 0
  AbortMeasuringInput        : BOOL;
  /// Byte 12 - Bit 1
  SetTriggerMotion           : BOOL;
  /// Byte 12 - Bit 2
  OpenBrake                  : BOOL;
  /// Byte 12 - Bit 3
  PathAccuracyMode           : BOOL;
  /// Byte 12 - Bit 4
  AvoidSingularity           : BOOL;
  /// Byte 12 - Bit 5
  ForceControl               : BOOL;
  /// Byte 12 - Bit 6
  ForceLimit                 : BOOL;
  /// Byte 12 - Bit 7
  ReadActualForce            : BOOL;
  
  /// Byte 13 - Bit 0
  BrakeTest                  : BOOL;
  /// Byte 13 - Bit 1
  SoftSwitchTCP              : BOOL;
  /// Byte 13 - Bit 2
  CreateSpline               : BOOL;
  /// Byte 13 - Bit 3
  DeleteSpline               : BOOL;
  /// Byte 13 - Bit 4
  MoveSpline                 : BOOL;
  /// Byte 13 - Bit 5
  DynamicSpline              : BOOL;
  /// Byte 13 - Bit 6
  LoadMeasurementAutomatic   : BOOL;
  /// Byte 13 - Bit 7
  LoadMeasurementSequential  : BOOL;
  
  /// Byte 14 - Bit 0
  CollisionDetection         : BOOL;
  /// Byte 14 - Bit 1
  FreeDrive                  : BOOL;
  /// Byte 14 - Bit 2
  UnitMeasurement            : BOOL;
  /// Byte 14 - Bit 3
  Byte14Bit03                : BOOL;
  /// Byte 14 - Bit 4
  Byte14Bit04                : BOOL;
  /// Byte 14 - Bit 5
  Byte14Bit05                : BOOL;
  /// Byte 14 - Bit 6
  Byte14Bit06                : BOOL;
  /// Byte 14 - Bit 7
  Byte14Bit07                : BOOL;
  
  /// Byte 15 - Bit 0
  Byte15Bit00                : BOOL;
  /// Byte 15 - Bit 1
  Byte15Bit01                : BOOL;
  /// Byte 15 - Bit 2
  Byte15Bit02                : BOOL;
  /// Byte 15 - Bit 3
  Byte15Bit03                : BOOL;
  /// Byte 15 - Bit 4
  Byte15Bit04                : BOOL;
  /// Byte 15 - Bit 5
  Byte15Bit05                : BOOL;
  /// Byte 15 - Bit 6
  Byte15Bit06                : BOOL;
  /// Byte 15 - Bit 7
  Byte15Bit07                : BOOL;

  /// Byte 16 - Bit 0
  Byte16Bit00                : BOOL;
  /// Byte 15 - Bit 1
  Byte16Bit01                : BOOL;
  /// Byte 15 - Bit 2
  Byte16Bit02                : BOOL;
  /// Byte 15 - Bit 3
  Byte16Bit03                : BOOL;
  /// Byte 15 - Bit 4
  Byte16Bit04                : BOOL;
  /// Byte 15 - Bit 5
  Byte16Bit05                : BOOL;
  /// Byte 15 - Bit 6
  Byte16Bit06                : BOOL;
  /// Byte 15 - Bit 7
  Byte16Bit07                : BOOL;
  
  /// Byte 17 - Bit 0
  Byte17Bit00                : BOOL;
  /// Byte 17 - Bit 1
  Byte17Bit01                : BOOL;
  /// Byte 17 - Bit 2
  Byte17Bit02                : BOOL;
  /// Byte 17 - Bit 3
  Byte17Bit03                : BOOL;
  /// Byte 17 - Bit 4
  Byte17Bit04                : BOOL;
  /// Byte 17 - Bit 5
  Byte17Bit05                : BOOL;
  /// Byte 17 - Bit 6
  Byte17Bit06                : BOOL;
  /// Byte 17 - Bit 7
  Byte17Bit07                : BOOL;

  /// Byte 18 - Bit 0
  Byte18Bit00                : BOOL;
  /// Byte 18 - Bit 1
  Byte18Bit01                : BOOL;
  /// Byte 18 - Bit 2
  Byte18Bit02                : BOOL;
  /// Byte 18 - Bit 3
  Byte18Bit03                : BOOL;
  /// Byte 18 - Bit 4
  Byte18Bit04                : BOOL;
  /// Byte 18 - Bit 5
  Byte18Bit05                : BOOL;
  /// Byte 18 - Bit 6
  Byte18Bit06                : BOOL;
  /// Byte 18 - Bit 7
  Byte18Bit07                : BOOL;
END_STRUCT
END_TYPE


