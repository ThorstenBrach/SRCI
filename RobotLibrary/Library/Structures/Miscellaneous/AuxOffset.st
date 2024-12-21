{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AuxOffset                                       
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
TYPE AuxOffset :
STRUCT
  /// Offset in X-Direction
  X  : REAL;
  /// Offset in Y-direction
  Y  : REAL;
  /// Offset in Z-direction
  Z  : REAL;
  /// Offset in Rx-Direction
  Rx : REAL;
  /// Offset in Ry-direction
  Ry : REAL;
  /// Offset in Rz-direction
  Rz : REAL;
END_STRUCT
END_TYPE


