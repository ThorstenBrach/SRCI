FUNCTION WORD_TO_STRING_BIN : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WORD_TO_STRING_BIN                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-03
//
//  Description:                                              
//    Converts a BYTE to a STRING with binary notation  
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

  WORD_TO_STRING_BIN := '2#';
  
  IF (Value.15)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.14)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.13)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.12)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1_');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0_');
  END_IF
  
  IF (Value.11)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.10)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.09)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.08)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1_');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0_');
  END_IF
  
  IF (Value.7)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.6)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.5)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.4)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1_');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0_');
  END_IF
  
  IF (Value.3)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.2)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.1)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  
  IF (Value.0)
  THEN
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '1');
  ELSE
    WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, '0');
  END_IF
  
  
  WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, ' (');
  WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, WORD_TO_STRING(Value));
  WORD_TO_STRING_BIN := CONCAT(WORD_TO_STRING_BIN, ')');

END_FUNCTION

