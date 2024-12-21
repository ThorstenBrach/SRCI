{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExchangeConfigurationOutCmd                                       
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
TYPE ExchangeConfigurationOutCmd :
STRUCT
  /// Returns a metric of how many CMDs it can receive and manage at the same time
  LengthACR                 : UINT;
  /// Highest index of available tools on the RC.
  HighestToolIndex          : USINT;
  /// Highest index of available frames on the RC.
  HighestFrameIndex         : USINT;
  /// Highest index of available loads on the RC.
  HighestLoadIndex          : USINT;
  /// Highest index of available work areas on the RC.
  HighestWorkAreaIndex      : USINT;
  /// Datas which are synchronized
  DataInSync                : DataInSync;
  /// Index of tool changed on RC
  ChangeIndexTool           : USINT;
  /// Index of frame changed on RC
  ChangeIndexFrame          : USINT;
  /// Index of load changed on RC
  ChangeIndexLoad           : USINT;
  ///Index of work area changed on RC
  ChangeIndexWorkArea       : USINT;
  /// Working hours of an RA connected to the RC
  RAWorkingHours            : UDINT;
  /// Signals that a brake test is required in the defined monitoring time (see chapter 6.5.27)
  BrakeTestRequired         : BOOL;
  /// StepMode is active and set to ExactStop (see chapter 6.1.3)
  StepModeExactStopActive   : BOOL;
  /// StepMode is active and set to Blending (see chapter 6.1.3)
  StepModeBlendingActive    : BOOL;
  /// PathAccuracyMode is active (see chapter 6.5.22)
  PathAccuracyMode          : BOOL;
  /// AvoidSingularity is active (see chapter 6.5.23)
  AvoidSingularity          : BOOL;
  /// CollisionDetection is active (see chapter 6.5.35)
  CollisionDetectionEnabled : BOOL;
  /// Cyclic dynamics status bit Accelerating is supported by RC (see chapter 5.5.3.2)
  AcceleratingSupported     : BOOL;
  /// Cyclic dynamics status bit Decelerating is supported by RC (see chapter 5.5.3.2)
  DecceleratingSupported    : BOOL;
  /// Cyclic dynamics status bit ConstantVelocity is supported by RC (see chapter 5.5.3.2)
  ConstantVelocitySupported : BOOL;
  /// Total system hours of an RA connected to the RC. Must not be modifiable by the user.
  /// •  0: Invalid
  /// • >1: Total system hours
  RCWorkingHours            : UDINT;
END_STRUCT
END_TYPE


