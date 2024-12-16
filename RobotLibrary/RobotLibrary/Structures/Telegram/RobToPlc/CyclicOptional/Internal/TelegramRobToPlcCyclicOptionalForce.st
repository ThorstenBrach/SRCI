{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramRobToPlcCyclicOptionalForce                                       
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
TYPE TelegramRobToPlcCyclicOptionalForce :
STRUCT
  /// Force on the X-Axis
  X : REAL;
  /// Force on the Y-Axis
  Y : REAL;
  /// Force on the Z-Axis
  Z : REAL;
  /// Force around the X-Axis (RX)
  Rx : REAL;
  /// Force around the Y-Axis (RY)
  Ry : REAL;
  /// Force around the Z-Axis (RZ)
  Rz : REAL;
END_STRUCT
END_TYPE


