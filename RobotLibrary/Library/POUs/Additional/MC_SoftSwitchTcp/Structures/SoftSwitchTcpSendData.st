{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SoftSwitchTcpSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-30
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
TYPE SoftSwitchTcpSendData EXTENDS CmdHeader: 
STRUCT
  /// Defines which parameters will limit the space, where the robot complies (at least one option must be supported)
  LimitMode           : LimitMode;
  /// Relates to "LimitMode" with the setting "No limit defined". Defines for which cartesian axes the compliant motion is allowed. 
  /// If TRUE, the direction is enabled. Default value is FALSE. See Table 6-744 for bit assignment.
  CompliantAxes       : BYTE;
  /// Defines type of reference coordinate system at which the robot can be moved in a compliant manner.
  ReferenceType       : ReferenceType;  
  /// Index of tool or frame according to ReferenceType.
  /// • 0 (default): Flange/WS
  /// • 1..254: Tool/User frames
  ReferenceNo         : USINT;
  /// Relates to "ResistanceForceMode" with the setting "ResistanceForceTCP".
  /// Defines the resistance force level applied at the RA against the external force.
  /// • 0..99: Resistance is lower than robot vendor default. The lower the value, the easier the robot can be pushed away.
  /// • 100 (default): The value is aligned with the robot vendor-specific default value.
  /// • 101..200: Resistance is higher than robot vendor default. At maximum value "200" highest possible resistance against external force
  ResistanceForceTCP  : INT;
  /// Relates to "ResistanceForceMode" with the setting "ResistanceForceAxis".
  /// Defines the resistance force level of the RA at the respective cartesian axis.
  ///  0..99: Resistance is lower than robot vendor default. The lower the value, the easier the robot can be pushed away.
  /// • 100 (default): The value is aligned with the robot vendor-specific default value.
  /// • 101..200: Resistance is higher than robot vendor default. At maximum value "200" highest possible resistance against external force.
  /// Index:
  /// • [0]: X-Axis O
  /// • [1]: Y-axis O
  /// • [2]: Z-axis O
  /// • [3]: RX-Direction O
  /// • [4]: RY-direction O
  /// • [5]: RZ-direction
  ResistanceForceAxis : ARRAY[0..5] OF UINT;
  /// Relates to "LimitMode" with the setting "Limit defined". 
  /// Limit values in the selected cartesian coordinate system (see input parameters ReferenceType and ReferenceNo).
  /// "0" is (default) the origin of the vector, the TCP position, at the start position of the robot.
  /// See Table 6-742 for the parameter index assignment.
  VectorData          : ARRAY[0..5] OF REAL;
  /// Defines the type of the resistance force applied at the RA against the external force
  ResistanceForceMode : ResistanceForceMode;
END_STRUCT
END_TYPE


