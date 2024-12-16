{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualForceParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-16
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
TYPE ReadActualForceParCmd :
STRUCT
  /// Processing Mode
  ProcessingMode      : ProcessingMode;
  /// Defines type of reference of Force and Torque (at least one option must be supported )
  ReferenceType       : ReferenceType;
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Define the index number of the UCS that will be assigned to the conveyor.
  /// For more information refer to chapter 5.5.14
  FrameNo            : USINT;
  /// Index of payload data containing mass, center of gravity, orientation and inertia relative to SensorFrame.
  /// Required to calibrate system for setting up gravity compensation and sensor offset.
  CalibrationData    : USINT;
  /// ID of associated trigger function:
  /// • 0: Immediately (default) - Start executing this function immediately.
  /// • >0: Trigger -  Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID         : SINT; 
END_STRUCT
END_TYPE


