FUNCTION ByteToAxisJointUsed : AxisJointUsed
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToAxisJointUsed                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-23
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  AxisJointUsed : BYTE;
END_VAR

  ByteToAxisJointUsed.J1 := AxisJointUsed.1;
  ByteToAxisJointUsed.J2 := AxisJointUsed.2;
  ByteToAxisJointUsed.J3 := AxisJointUsed.3;
  ByteToAxisJointUsed.J4 := AxisJointUsed.4;
  ByteToAxisJointUsed.J5 := AxisJointUsed.5;
  ByteToAxisJointUsed.J6 := AxisJointUsed.6;

END_FUNCTION

