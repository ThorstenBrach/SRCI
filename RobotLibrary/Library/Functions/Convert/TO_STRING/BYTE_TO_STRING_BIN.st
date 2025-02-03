FUNCTION BYTE_TO_STRING_BIN : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BYTE_TO_STRING_BIN                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-20
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
 Value : BYTE; 
END_VAR

  BYTE_TO_STRING_BIN := '2#';
  
  IF (Value.7)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.6)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.5)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.4)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1_');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0_');
  END_IF
  
  IF (Value.3)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.2)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  IF (Value.1)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  
  IF (Value.0)
  THEN
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '1');
  ELSE
    BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, '0');
  END_IF
  
  
  BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, ' (');
  BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, WORD_TO_STRING(Value));
  BYTE_TO_STRING_BIN := CONCAT(BYTE_TO_STRING_BIN, ')');

END_FUNCTION

