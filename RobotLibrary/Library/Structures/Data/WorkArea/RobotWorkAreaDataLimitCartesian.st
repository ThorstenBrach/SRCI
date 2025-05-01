{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotWorkAreaDataLimitCartesian                                       
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
TYPE RobotWorkAreaDataLimitCartesian :
STRUCT
  /// Relates to AreaType Box, Cylinder and Sphere. 
  /// Distance in negative Direction - Default 0  
  LowerLimit : REAL := 0;
  /// Relates to AreaType Box, Cylinder and Sphere.
  /// Distance in positive Direction - Default 0  
  UpperLimit : REAL := 0;
END_STRUCT
END_TYPE


