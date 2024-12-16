{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualForceSendData                                       
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
TYPE ReadActualForceSendData EXTENDS CmdHeader:   
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
  /// Index of payload data containing mass, center of gravity, orientation and inertia relative to SensorFrame.
  /// Required to calibrate system for setting up gravity compensation and sensor offset.
  CalibrationData    : USINT;
  /// Defines type of reference of Force and Torque (at least one option must be supported )
  ReferenceType      : ReferenceType;
END_STRUCT
END_TYPE


