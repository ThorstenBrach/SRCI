{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotAxesFlags                                       
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
TYPE RobotAxesFlags :
STRUCT
  /// Bit00 : Not used
  Bit00   : BOOL;
  /// Bit01 : Robot axis J1 - property depends of usage 
  AxisJ1  : BOOL;
  /// Bit02 : Robot axis J2 - property depends of usage 
  AxisJ2  : BOOL;
  /// Bit03 : Robot axis J3 - property depends of usage 
  AxisJ3  : BOOL;
  /// Bit04 : Robot axis J4 - property depends of usage 
  AxisJ4  : BOOL;
  /// Bit05 : Robot axis J5 - property depends of usage 
  AxisJ5  : BOOL;
  /// Bit06 : Robot axis J6 - property depends of usage 
  AxisJ6  : BOOL;
  /// Bit07 : Not used
  Bit07   : BOOL;
END_STRUCT
END_TYPE


