FUNCTION TURN_TO_SIGN_MAGNITUDE : BYTE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TURN_TO_SIGN_MAGNITUDE
//  Author:      Thorsten Brach                                                
//  Date:        2026-10-09
//
//  Description:                                              
//    ST-FIX F3: turn number -> sign + magnitude (spec 5.5.4.4, tables 5-24..5-26)
//                                                                           
//  Copyright: 
//    (C) 2026 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Turn number
  Turns : SINT;
  /// Number of value bits (3 for J1..J6, 7 for E1), the sign is the next bit
  Bits  : USINT;
END_VAR
VAR
  /// Sign bit
  _signBit : BYTE;
  /// Largest magnitude
  _max     : INT;
  /// Magnitude
  _abs     : INT;
END_VAR

  _signBit := SHL(BYTE#1, Bits);
  _max     := BYTE_TO_INT(_signBit) - 1;
  _abs     := ABS(SINT_TO_INT(Turns));
  
  // out of range -> clamp
  IF ( _abs > _max )
  THEN
    _abs := _max;
  END_IF
  
  TURN_TO_SIGN_MAGNITUDE := INT_TO_BYTE(_abs);
  
  IF ( Turns < 0 )
  THEN
    TURN_TO_SIGN_MAGNITUDE := TURN_TO_SIGN_MAGNITUDE OR _signBit;
  END_IF

END_FUNCTION

