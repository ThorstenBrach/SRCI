FUNCTION ByteToAxisExternalUnit : AxisExternalUnit
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToAxisExternalUnit                                       
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
  AxisExternalUnit : BYTE;
END_VAR

  ByteToAxisExternalUnit.E1.0 := AxisExternalUnit.1;
  ByteToAxisExternalUnit.E2.0 := AxisExternalUnit.2;
  ByteToAxisExternalUnit.E3.0 := AxisExternalUnit.3;
  ByteToAxisExternalUnit.E4.0 := AxisExternalUnit.4;
  ByteToAxisExternalUnit.E5.0 := AxisExternalUnit.5;
  ByteToAxisExternalUnit.E6.0 := AxisExternalUnit.6;

END_FUNCTION

