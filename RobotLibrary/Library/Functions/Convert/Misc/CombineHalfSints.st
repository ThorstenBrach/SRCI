FUNCTION CombineHalfSints : USINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CombineHalfSints                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-02
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Half-Sint to add to the upper 4 Bit
  HalfSintHi : SINT;
  /// Half-Sint to add to the lower 4 Bit
  HalfSintLo : SINT;
END_VAR

  // ST-FIX F60: sign + magnitude nibbles (bits 0..2 value, bit 3 sign), HalfSintHi in bits 4..7
  CombineHalfSints := BYTE_TO_USINT( SHL(TURN_TO_SIGN_MAGNITUDE(Turns := HalfSintHi, Bits := 3), 4)
                                  OR     TURN_TO_SIGN_MAGNITUDE(Turns := HalfSintLo, Bits := 3) );

END_FUNCTION

