{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SyncToConveyorParCmd                                       
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
TYPE SyncToConveyorParCmd :
STRUCT
  /// Index of assigned conveyor
  ConveyorNo      : USINT;
  /// Define the index number of the UCS that will be assigned to the conveyor.
  /// For more information refer to chapter 5.5.14
  FrameNo         : USINT;
  /// Defines when synchronization starts.
  SyncInMode      : SyncInMode;
  /// Relates to "SyncInMode" "After distance" (1) and "After time" (2):
  /// Parameter for the synchronization
  /// • "After distance" (1)
  ///    •  Distance in mm
  /// • "After time" (2)
  ////   • Time in ms
  SyncInParameter : REAL;
  /// Define the maximum adjustment velocity for the robot to catch up to the conveyor belt.
  /// The velocity must be greater than the velocity of the conveyor belt.
  /// • 0 (default): no limit
  ///       o No conveyor tracking specific limit
  ///       o RC internal limit applies
  /// • >0: use limit
  ///       o Conveyor tracking specific limit applies
  MaxVelocity     : REAL;
  /// Define the maximum adjustment acceleration for the robot to catch up to the conveyor belt.
  /// • 0 (default): no limit
  ///     o No conveyor tracking specific limit
  ///     o RC internal limit applies
  /// • >0: use limit
  ///     o Conveyor tracking specific limit applies
  MaxAcceleration : REAL;
  /// ID of associated trigger function:
  ///  •  0: No Trigger (default):
  ///        o No trigger related behavior
  ///  • >0: Trigger:
  ///        o Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID      : SINT;
END_STRUCT
END_TYPE


