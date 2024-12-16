{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupParameterOptionalCyclicRobToPlc                                       
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
TYPE AxesGroupParameterRobOptionalCyclic :
STRUCT
  /// Bit 00: 
  /// Transmit cyclic data from PLC to RC for the usage in a subprogram on the RC called via the function “CallSubprogram”
  UseCallSubprogram       : BOOL;
  /// Bit 01: 
  /// Send a short cartesian position with TCP position (X, Y,Z), rotation (RX, RY, RZ), 
  /// configuration bytes (Config, TurnNumber), position of first external axis (E1) and corresponding coordinate systems (ToolNo, FrameNo)
  UseCartesianPosition    : BOOL;
  /// Bit 02: 
  /// Send a short axes position with joint values (J1, J2, J3, J4, J5, J6) and position of first external axis (E1)
  UseJointPosition        : BOOL;
  /// Bit 03: 
  /// Send the force with the divided forces in the individual directions (X, Y, Z, RX, RY, RZ)
  UseForce                : BOOL;
  /// Bit 04:
  /// Transmit actual axes current of individual axes (J1, J2, J3, J4, J5, J6)
  UseCurrent              : BOOL;
  /// Bit 05:
  Bit05                   : BOOL;
  /// Bit 06:
  Bit06                   : BOOL;
  /// Bit 07:
  Bit07                   : BOOL;  
  /// Bit 08: 
  /// Set to 1 to define two Sequences in one Telegram. 
  /// If activated, 2 sequences also has to be activated in the ServerClient direction
  UseTwoSequences         : BOOL;
  /// Bit 09: 
  /// Send the external axis values for an extended cartesian position (E2, E3, E4, E5, E6)
  UseCartesianPositionExt : BOOL;
  /// Bit 10: 
  /// Send the external axis values for an extended joint position (E2, E3, E4, E5, E6)
  UseJointPositionExt     : BOOL;
  /// Bit 11:
  /// Transmit the current force for the external axis (E1, E2, E3, E4, E5, E6)
  UseForceExt             : BOOL;
  /// Bit 12:
  /// Transmit the actual current for the external axis (E1, E2, E3, E4, E5, E6)
  UseCurrentExt           : BOOL;
  /// Bit 13:
  Bit13                   : BOOL;
  /// Bit 14:
  Bit14                   : BOOL;
  /// Bit 15:
  Bit15                   : BOOL;  
END_STRUCT
END_TYPE


