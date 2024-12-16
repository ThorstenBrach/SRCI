{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotJointPositionExt                                       
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
TYPE RobotJointPositionExt :
STRUCT
  /// Position of second external axis
  E2: REAL;
  /// Position of third external axis
  E3: REAL;
  /// Position of fourth external axis
  E4: REAL;
  /// Position of fifth external axis
  E5: REAL;
  /// Position of sixth external axis
  E6: REAL;  
END_STRUCT
END_TYPE


