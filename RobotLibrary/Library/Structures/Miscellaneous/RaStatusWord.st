{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RaStatusWord                                       
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
TYPE RaStatusWord :
STRUCT
  /// Bit 00: 
  /// TRUE, when robot’s axes values change due to physical movement of axes
  IsMoving                 : BOOL;
  /// Bit 01: 
  /// TRUE, when move commands buffered by the primary sequence are currently not processed
  PrimarySequencePaused    : BOOL;
  /// Bit 02: 
  /// TRUE, when robot is moving in the primary sequence, FALSE when robot leaves its position by other means
  /// Switches back to TRUE in the following two scenarios:
  /// 1. During a change to the primary sequence the current TCP position is equal to
  ///    - position when the primary sequence was left
  ///    - target position of an interrupted move command of the primary sequence (see "ReturnToPrimary": "ReturnMode" "End position" chapter 6.3.11)
  /// 2. The primary sequence is active, and the buffer is empty while a new command is buffered by the primary sequence
  /// Independent of RA state
  InPrimaryPos             : BOOL;
  /// Bit 03:
  /// Secondary sequence is active, either by user selection or by implicit behavior
  SecondarySequenceActive  : BOOL;
  /// Bit 04:
  /// TRUE, when robot is currently blending between two move commands
  IsBlending               : BOOL;
  /// Bit 05:
  /// Shows that an error acknowledgement by the client is necessary
  ErrorPending             : BOOL;
  /// Bit 06:
  /// RC is restarting
  RestartInProgress        : BOOL;
  /// Bit 07:
  /// RA power state
  Enabled                  : BOOL;
  /// Bit 08:
  /// RA sequence states: Idle, Interrupt active, Axes controlled
  Executing                : BOOL;
  /// Bit 09:
  /// Interrupted
  Interrupted              : BOOL;
  /// Bit 10 - Bit 12:
  /// Operation Mode: T1 Local, T2 Local, Auto, Auto Ext, T1 Ext, T2 Ext
  OperationMode            : OperationMode;
  /// Bit 13:
  /// TRUE, while CollisionDetection is enabled (see chapter 6.5.35) 
  CollisionDetectedEnabled : BOOL;
  /// Bit 14:
  /// TRUE, when a collision was detected while CollisionDetection is enabled
  CollisionDetected        : BOOL;
  /// Bit 15:
  /// TRUE, when the RC request a restart of the RCinduced through the functions "WriteRobotSWLimits" or "WriteSystemVariable"
  RestartRequested         : BOOL;
  /// Bit 16:
  /// RA is currently accelerating. Support of this value is returned via exchangeConfig.
  Accelerating             : BOOL;
  /// Bit 17:
  /// RA is currently decelerating. Support of this value is returned via exchangeConfig.
  Decelerating             : BOOL;
  /// Bit 18:
  /// RA is currently not accelerating nor decelerating. Support of this value is returned via exchangeConfig.
  ConstantVelocity         : BOOL;
  /// Bit 19
  Bit19                    : BOOL;
  /// Bit 20
  Bit20                    : BOOL;
  /// Bit 21
  Bit21                    : BOOL;
  /// Bit 22
  Bit22                    : BOOL;
  /// Bit 23
  Bit23                    : BOOL;
  /// Bit 24
  Bit24                    : BOOL;
  /// Bit 25
  Bit25                    : BOOL;
  /// Bit 26
  Bit26                    : BOOL;
  /// Bit 27
  Bit27                    : BOOL;
  /// Bit 28
  Bit28                    : BOOL;
  /// Bit 29
  Bit29                    : BOOL;
  /// Bit 30
  Bit30                    : BOOL;
  /// Bit 31
  Bit31                    : BOOL;  
END_STRUCT
END_TYPE


