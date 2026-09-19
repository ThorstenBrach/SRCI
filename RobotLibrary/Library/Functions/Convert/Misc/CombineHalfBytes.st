FUNCTION CombineHalfBytes : USINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CombineHalfBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Half-Byte to add to the upper 4 Bit
  HalfByteHi : BYTE;
  /// Half-Byte to add to the lower 4 Bit
  HalfByteLo : BYTE;
END_VAR

  // merage ParSeq and Priority to combined variable
  CombineHalfBytes.0 := HalfByteLo.0;
  CombineHalfBytes.1 := HalfByteLo.1;
  CombineHalfBytes.2 := HalfByteLo.2;
  CombineHalfBytes.3 := HalfByteLo.3;
  
  CombineHalfBytes.4 := HalfByteHi.0;
  CombineHalfBytes.5 := HalfByteHi.1;
  CombineHalfBytes.6 := HalfByteHi.2;
  CombineHalfBytes.7 := HalfByteHi.3;

END_FUNCTION

