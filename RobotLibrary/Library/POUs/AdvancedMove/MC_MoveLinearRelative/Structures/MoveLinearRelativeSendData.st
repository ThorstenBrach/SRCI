{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveLinearRelativeSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-07-31
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
TYPE MoveLinearRelativeSendData EXTENDS CmdHeader: 
STRUCT
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action  -  Stop executing the Action function with the identical ListenerID.
  /// • 0: No trigger (default)-  If no EmitterID is defined, the function will not trigger any Action during its execution
  /// For more information see section Triggers of this chapter or chapter 5.5.12.4.
  EmitterID          : ARRAY [0..3] OF SINT;
  /// ID of the trigger function that may be triggered:
  /// • 0: Immediately (default). - Start executing THIS function immediately.
  /// • >0: Triggero Start executing when the trigger function with the identical EmitterID is called.
  /// For more information see chapter 5.5.12.4.
  ListenerID         : SINT;
  /// Reserve
  Reserve            : BYTE;
  /// TCP velocity in % of nominal velocity
  /// •  <0%: (default) - Use default velocity
  /// •   0%:           - Use internal minimal velocity
  /// • 100%:           - Use maximal reference velocity
  /// See chapter 5.5.7 Robot dynamics
  VelocityRate       : UINT;
  /// Acceleration for movement in % of nominal acceleration
  /// •  <0%: (default) - Use default acceleration
  /// •   0%:           - Use internal minimal acceleration
  /// • 100%:           - Use maximal reference acceleration
  /// See chapter 5.5.7 Robot dynamics
  AccelerationRate   : UINT;
  /// Deceleration for movement in % of nominal deceleration
  /// •  <0%: (default) - Use default deceleration 
  /// •   0%:           - Use internal minimal deceleration
  /// • 100%:           - Use maximal reference deceleration
  /// See chapter 5.5.7 Robot dynamics
  DecelerationRate   : UINT;
  /// Jerk of the movement in % of nominal jerk
  /// •  <0%: (default) - Use default jerk
  /// •   0%:           - Use internal minimal jerk
  /// • 100%:           - Use maximal reference jerk
  /// See chapter 5.5.7 Robot dynamics
  JerkRate           : UINT;
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Index of frame
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Parameter which determines the transition behavior at the end of the movement to be sent to the next command. 
  /// The user can choose a transition type between exact stop and different blend possibilities
  BlendingMode       : USINT;
  /// Parameter to describe how the orientation axes (RX, RY, RZ) will be interpolated during the movement.
  OriMode            : USINT;
  /// Additional parameter for the blending mode, to define i.e. velocity limit (%) or blending radius
  BlendingParameter  : ARRAY [0..1] OF REAL := [10,0];
  /// Relative distance and rotation from the current or last target position to the end point
  Distance           : RobotCartesianPosition;
  /// Set TRUE to allow manipulation of this move command through superimposing functions.
  /// For more information see chapter 5.5.9.5
  Manipulation       : BOOL;
  /// Defines the usage of the config byte inside the position according to Table 6-238
  ConfigMode         : ARRAY[0..1] OF BYTE;
  /// Defines type of reference coordinate system of the offset position
  ReferenceType      : USINT;
  /// Defines the usage of the TurnNumber byte inside the position.
  TurnMode           : TurnMode;
  /// Parameter is used if it is greater than 0 (default)
  /// • Velocity input is ignored
  /// • Parameter defines the time for the movement to reach the target position
  /// Error is sent by the RC if the time cannot be kept
  MoveTime           : UINT;
END_STRUCT
END_TYPE


