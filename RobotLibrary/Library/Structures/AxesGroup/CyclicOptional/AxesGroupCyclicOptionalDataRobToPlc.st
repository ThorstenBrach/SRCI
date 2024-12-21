{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupCyclicOptionalDataRobToPlc                                       
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
TYPE AxesGroupCyclicOptionalDataRobToPlc :
STRUCT
  /// Transmit cyclic data from PLC to RC for the usage in a subprogram on the RC called via the function “CallSubprogram”
  SubProgramData        :  AxesGroupCyclicOptionalDataSubProgram;
  /// short cartesian position with TCP position (X, Y,Z), rotation (RX, RY, RZ), configuration bytes (Config, TurnNumber), position of first external axis (E1) and corresponding coordinate systems (ToolNo, FrameNo)
  CartesianPosition     :  AxesGroupCyclicOptionalDataCartesianPosition;
  /// the external axis values for an extended cartesian position (E2, E3, E4, E5, E6) 
  /// When selected, Tool and Frame will automatically cyclically be sent from client to server.
  CartesianPositionExt  :  AxesGroupCyclicOptionalDataCartesianPositionExt;
  /// short axes position with joint values (J1, J2, J3,J4, J5, J6) and position of first external axis (E1)
  JointPosition         :  AxesGroupCyclicOptionalDataJointPosition;
  /// the external axis values for an extended joint position (E2, E3, E4, E5, E6)
  JointPositionExt      :  AxesGroupCyclicOptionalDataJointPositionExt;
  /// force with the divided forces in the individual directions (X, Y, Z, RX, RY, RZ)
  Force                 :  AxesGroupCyclicOptionalDataForce;
  /// current force for the external axis (E1, E2, E3, E4, E5, E6)
  ForceExt              :  AxesGroupCyclicOptionalDataForceExt;
  /// ctual axes current of individual axes (J1, J2, J3, J4, J5, J6)
  Current               :  AxesGroupCyclicOptionalDataCurrent;
  /// actual current for the external axis (E1, E2,E3, E4, E5, E6)
  CurrentExt            :  AxesGroupCyclicOptionalDataCurrentExt;  
END_STRUCT
END_TYPE


