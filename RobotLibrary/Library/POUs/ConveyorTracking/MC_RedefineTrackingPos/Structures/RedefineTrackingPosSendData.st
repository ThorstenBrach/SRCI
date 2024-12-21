{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RedefineTrackingPosSendData                                       
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
TYPE RedefineTrackingPosSendData EXTENDS CmdHeader:   
STRUCT
  /// EmitterID
  EmitterID              : ARRAY[0..3] OF SINT;
  /// ID of associated trigger function:
  /// • 0: No Trigger (default): No trigger related behavior
  /// • >0: Trigger: o Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID             : SINT;
  /// Reserve
  Reserve                : BYTE;
  /// Index of assigned conveyor
  ConveyorNo             : USINT;
  /// Relates to ListenerID >0
  /// Start index of real registers containing InitObjectPosition for trigger-based execution.
  StartIndexInitPosition : USINT;
  /// Relates to ListenerID = 0:
  /// Travel distance of assigned UCS between work piece detection (InitObjectPosition) and execution of this command.
  TrackingOffset         : REAL;
  /// Define the index number of the UCS that is assigned to the conveyor by the function "ConveyorTracking".
  /// For more information refer to chapter 5.5.14.
  FrameNo                : USINT;
  /// Relates to ListenerID >0
  /// Index of real register containing TrackingOffset for trigger-based execution
  IndexTrackingOffset    : USINT;
END_STRUCT
END_TYPE


