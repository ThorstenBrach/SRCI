FUNCTION GetHalfeByteLo : BYTE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SwapBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-18
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
VAR_INPUT
  /// Increase payload pointer 
  Value : BYTE;
END_VAR

  GetHalfeByteLo.0 := Value.0;
  GetHalfeByteLo.1 := Value.1;
  GetHalfeByteLo.2 := Value.2;
  GetHalfeByteLo.3 := Value.3;

END_FUNCTION
