FUNCTION WORD_TO_STRING_HEX : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WORD_TO_STRING_HEX                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-13
//
//  Description:                                              
//    Converts a WORD to a STRING with hex notation  
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
 /// Value to convert
 Value : WORD; 
END_VAR
VAR
  /// high Byte
 _highByte   : BYTE;      
  /// low Byte
 _lowByte    : BYTE;      
  /// high Nibble
 _highNibble : BYTE;     
  /// low Nibble 
 _lowNibble  : BYTE;     
  /// single Hex char
  hexChar    : STRING(1);
  /// Hex chars  
  hexChars   : ARRAY[0..15] OF STRING(1) := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'];
END_VAR

  // get high and low byte from word
  _highByte := WORD_TO_BYTE(SHR(Value, 8)); 
  _lowByte  := WORD_TO_BYTE(Value AND 16#FF); 
  
  // convert highest Byte to HEX
  _highNibble := SHR(_highByte, 4);   
  _lowNibble  := (_highByte AND 16#F);
  WORD_TO_STRING_HEX := CONCAT(hexChars[_highNibble], hexChars[_lowNibble]);
  
  // convert lowest Byte to HEX
  _highNibble := SHR(_lowByte, 4); 
  _lowNibble := _lowByte AND 16#F; 
  WORD_TO_STRING_HEX := CONCAT(WORD_TO_STRING_HEX, CONCAT(hexChars[_highNibble], hexChars[_lowNibble]));

END_FUNCTION

