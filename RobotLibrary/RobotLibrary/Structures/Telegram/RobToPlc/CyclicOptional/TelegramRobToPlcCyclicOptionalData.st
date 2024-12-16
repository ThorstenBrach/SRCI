{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramRobToPlcCyclicOptionalData                                       
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
TYPE TelegramRobToPlcCyclicOptionalData :
STRUCT
    /// Transmit cyclic data from PLC to RC for the usage in a subprogram on the RC called via the function “CallSubprogram”
  SubProgramData        :  TelegramRobToPlcCyclicOptionalSubProgramData;
  /// cartesian position with TCP position (X, Y,Z), rotation (RX, RY, RZ), configuration bytes (Config, TurnNumber), position of first external axis (E1) and corresponding coordinate systems (ToolNo, FrameNo)
  CartesianPosition     :  TelegramRobToPlcCyclicOptionalCartesianPosition;
  /// axes position with joint values (J1, J2, J3,J4, J5, J6) and position of first external axis (E1)
  JointPosition         :  TelegramRobToPlcCyclicOptionalJointPosition;
  /// force with the divided forces in the individual directions (X, Y, Z, RX, RY, RZ)
  Force                 :  TelegramRobToPlcCyclicOptionalForce;
  /// Transmit actual axes current of individual axes (J1, J2, J3, J4, J5, J6)
  Current               :  TelegramRobToPlcCyclicOptionalCurrent;
  /// Set to 1 to define two Sequences in one Telegram. If activated, 
  /// 2 sequences also has to be activated in the ClientServer direction.
  TwoSequences          : BYTE;  
  /// Transmit the external axis values for an extended cartesian position (E2, E3, E4, E5, E6)
  /// When selected, Tool and Frame will automatically cyclically be sent from client to server.
  CartesianPositionExt  :  TelegramRobToPlcCyclicOptionalCartesianPositionExt;
  /// Transmit the external axis values for an extended joint position (E2, E3, E4, E5, E6)
  JointPositionExt      :  TelegramRobToPlcCyclicOptionalJointPositionExt;
  /// Transmit actual axes force of individual axes (E1, E2, E3, E4, E5, E6)
  ForceExt              :  TelegramRobToPlcCyclicOptionalCurrentExt;
  /// Transmit actual axes current of individual axes (E1, E2, E3, E4, E5, E6)
  CurrentExt            :  TelegramRobToPlcCyclicOptionalCurrentExt;
END_STRUCT
END_TYPE


