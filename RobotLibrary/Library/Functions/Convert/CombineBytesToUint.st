FUNCTION CombineBytesToUint : UINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CombineBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-09-03
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
  /// Byte to add as high byte
  HiByte : BYTE;
  /// Byte to add as low byte
  LoByte : BYTE;
END_VAR

  CombineBytesToUint.0  := LoByte.0;
  CombineBytesToUint.1  := LoByte.1;
  CombineBytesToUint.2  := LoByte.2;
  CombineBytesToUint.3  := LoByte.3;
  CombineBytesToUint.4  := LoByte.4;
  CombineBytesToUint.5  := LoByte.5;
  CombineBytesToUint.6  := LoByte.6;
  CombineBytesToUint.7  := LoByte.7;
  
  CombineBytesToUint.8  := HiByte.0;
  CombineBytesToUint.9  := HiByte.1;
  CombineBytesToUint.10 := HiByte.2;
  CombineBytesToUint.11 := HiByte.3;
  CombineBytesToUint.12 := HiByte.4;
  CombineBytesToUint.13 := HiByte.5;
  CombineBytesToUint.14 := HiByte.6;
  CombineBytesToUint.15 := HiByte.7;

END_FUNCTION

