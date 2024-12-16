{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TriggerReactionMode                                       
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
TYPE TriggerReactionMode :
(
/// No reaction (default).
  NO_REACTION := 0,
  /// Interrupt: Robot movement is paused. Movement can be continued by function GroupContinue.
  INTERRUPT := 1,
  /// GroupStop: Robot stops the movement and brings all axes to a halt. Movements aborted by this command cannot be continued.
  GROUP_STOP := 2,
  /// Disable robot: The robot’s drives are disabled. This leads to the robot state "Not enabled" (see chapter 5.5.3).
  DISABLE_ROBOT := 3,
  /// Stop actual motion command: Robot movement is paused. Movement can be continued by the next motion command.
  STOP_ACTUAL_MOTION_COMMAND := 4
)SINT;
END_TYPE


