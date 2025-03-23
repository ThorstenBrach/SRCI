FUNCTION ByteToAxisExternalUsed : AxisExternalUsed
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToAxisExternalUsed                                       
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
  AxisExternalUsed : BYTE;
END_VAR

  ByteToAxisExternalUsed.E1 := AxisExternalUsed.1;
  ByteToAxisExternalUsed.E2 := AxisExternalUsed.2;
  ByteToAxisExternalUsed.E3 := AxisExternalUsed.3;
  ByteToAxisExternalUsed.E4 := AxisExternalUsed.4;
  ByteToAxisExternalUsed.E5 := AxisExternalUsed.5;
  ByteToAxisExternalUsed.E6 := AxisExternalUsed.6;

END_FUNCTION

