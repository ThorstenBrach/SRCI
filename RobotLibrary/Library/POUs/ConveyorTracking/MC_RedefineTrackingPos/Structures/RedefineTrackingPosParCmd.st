{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RedefineTrackingPosParCmd                                       
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
TYPE RedefineTrackingPosParCmd :
STRUCT
  /// Index of assigned conveyor
  ConveyorNo             : USINT;
  /// Relates to ListenerID = 0:
  /// Define initial work piece position relative to the conveyor belt origin:
  /// • Origin (X, Y, Z in mm)
  /// • Orientation (RX, RY, RZ in degree)
  /// For more information refer to chapter 5.5.14.
  InitObjectPosition     : ARRAY[0..5] OF REAL;
  /// Relates to ListenerID = 0:
  /// Travel distance of assigned UCS between work piece detection (InitObjectPosition) and execution of this command.
  TrackingOffset         : REAL;
  /// Relates to ListenerID >0
  /// Start index of real registers containing InitObjectPosition for trigger-based execution.
  StartIndexInitPosition : USINT;
  /// Define the index number of the UCS that is assigned to the conveyor by the function "ConveyorTracking".
  /// For more information refer to chapter 5.5.14.
  FrameNo                : USINT;
  /// Relates to ListenerID >0
  /// Index of real register containing TrackingOffset for trigger-based execution
  IndexTrackingOffset    : USINT;
  /// ID of associated trigger function:
  /// • 0: No Trigger (default): No trigger related behavior
  /// • >0: Trigger: o Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID             :  SINT;
END_STRUCT
END_TYPE


