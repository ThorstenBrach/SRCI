FUNCTION ByteToAxisJointUnit : AxisJointUnit
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToAxisJointUnit                                      
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
  AxisJointUnit : BYTE;
END_VAR

  ByteToAxisJointUnit.J2.0 := AxisJointUnit.1;
  ByteToAxisJointUnit.J2.0 := AxisJointUnit.2;
  ByteToAxisJointUnit.J3.0 := AxisJointUnit.3;
  ByteToAxisJointUnit.J4.0 := AxisJointUnit.4;
  ByteToAxisJointUnit.J5.0 := AxisJointUnit.5;
  ByteToAxisJointUnit.J6.0 := AxisJointUnit.6;

END_FUNCTION

