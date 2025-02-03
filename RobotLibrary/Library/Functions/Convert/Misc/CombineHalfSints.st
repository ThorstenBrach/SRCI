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
//             Licensed under the LGPL-3.0 license.
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

  // merage ParSeq and Priority to combined variable
  CombineHalfSints.0 := HalfSintLo.0;
  CombineHalfSints.1 := HalfSintLo.1;
  CombineHalfSints.2 := HalfSintLo.2;
  CombineHalfSints.3 := HalfSintLo.3;
  
  CombineHalfSints.4 := HalfSintHi.0;
  CombineHalfSints.5 := HalfSintHi.1;
  CombineHalfSints.6 := HalfSintHi.2;
  CombineHalfSints.7 := HalfSintHi.3;

END_FUNCTION

