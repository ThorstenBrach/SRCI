{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotCartesianForceExt                                       
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
TYPE RobotCartesianForceExt :
STRUCT
  /// Force on the first external axis
  E1 : REAL;
  /// Force of second external axis
  E2 : REAL;
  /// Force of third external axis
  E3 : REAL;
  /// Force of fourth external axis
  E4 : REAL;
  /// Force of fifth external axis
  E5 : REAL;
  /// Force of sixth external axis
  E6 : REAL;  
END_STRUCT
END_TYPE


