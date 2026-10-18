FUNCTION SIGN_MAGNITUDE_TO_TURN : SINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SIGN_MAGNITUDE_TO_TURN
//  Author:      Thorsten Brach                                                
//  Date:        2026-10-09
//
//  Description:                                              
//    ST-FIX F3: sign + magnitude -> turn number (spec 5.5.4.4, tables 5-24..5-26)
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
  /// Coded value
  Value : BYTE;
  /// Number of value bits (3 for J1..J6, 7 for E1), the sign is the next bit
  Bits  : USINT;
END_VAR
VAR
  /// Sign bit
  _signBit : BYTE;
  /// Mask of the value bits
  _mask    : BYTE;
END_VAR

  _signBit := SHL(BYTE#1, Bits);
  _mask    := INT_TO_BYTE(BYTE_TO_INT(_signBit) - 1);
  
  SIGN_MAGNITUDE_TO_TURN := BYTE_TO_SINT(Value AND _mask);
  
  IF ( ( Value AND _signBit ) <> 0 )
  THEN
    SIGN_MAGNITUDE_TO_TURN := -1 * SIGN_MAGNITUDE_TO_TURN;
  END_IF

END_FUNCTION

