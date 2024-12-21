{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExternalAxesFlags                                       
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
TYPE ExternalAxesFlags :
STRUCT
  /// Bit 00 : Not used
  Bit00   : BOOL;
  /// Bit 01 : External axis E1 - property depends of usage 
  AxisE1  : BOOL;
  /// Bit 02 : External axis E2 - property depends of usage 
  AxisE2  : BOOL;
  /// Bit 03 : External axis E3 - property depends of usage 
  AxisE3  : BOOL;
  /// Bit 04 : External axis E4 - property depends of usage 
  AxisE4  : BOOL;
  /// Bit 05 : External axis E5 - property depends of usage 
  AxisE5  : BOOL;
  /// Bit 06 : External axis E6 - property depends of usage 
  AxisE6  : BOOL;
  /// Bit 00 : Not used
  Bit07   : BOOL;
END_STRUCT
END_TYPE


