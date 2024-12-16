{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE MoveSuperImposedSendData EXTENDS CmdHeader: 
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
  /// Value of the maximum velocity difference of the additional motion (not necessary reached).
  /// • > 0% Use specified value.
  /// • ≤ 0% Use the velocity defined by the move command that is superimposed. If no motion is active, use internal minimal velocity. (default)
 /// See chapter 5.5.7 Robot dynamics
  VelocityDiffRate   : UINT;
  /// Value of the maximum acceleration difference of the additional motion (not necessary reached).
  ///  •  <0% Use default acceleration (default)
  ///  •   0% Use internal minimal acceleration
  ///  • 100% Use maximal reference acceleration
  /// See chapter 5.5.7 Robot dynamics
  AccelerationDiffRate: UINT;
  /// Value of the maximum deceleration difference of the additional motion (not necessary reached).
  /// •  <0% Use default deceleration (default)
  /// •   0% Use internal minimal deceleration
  /// • 100% Use maximal reference deceleration
  /// See chapter 5.5.7 Robot dynamics
  DecelerationDiffRate: UINT;
  /// Value of the maximum jerk difference of the additional motion (not necessary reached).
  /// •  <0% Use default jerk (default) 
  /// •   0% Use internal minimal jerk
  /// • 100% Use maximal reference jerk
  /// See chapter 5.5.7 Robot dynamics
  JerkDiffRate        : UINT;
  /// Index of tool
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo             : USINT;
  /// Index of frame
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo            : USINT;
  /// Additional distance and orientation for superimposed positioning:
  Offset             : RobotCartesianPosition;
  /// Defines type of reference coordinate system of the offset position
  ReferenceType      : USINT;
  /// Reserve2
  Reserve2           : BYTE;  
END_STRUCT
END_TYPE


