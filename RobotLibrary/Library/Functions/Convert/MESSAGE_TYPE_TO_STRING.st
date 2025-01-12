FUNCTION MESSAGE_TYPE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MESSAGE_TYPE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-11
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
  /// Severity
  Value     : MessageType;
  /// Fill spaces to the end, so that all values has the same length  
  AlignString : BOOL;
END_VAR

  IF (AlignString)
  THEN
    CASE Value OF
      
      MessageType.RI  : MESSAGE_TYPE_TO_STRING := 'RI ';
      MessageType.RC  : MESSAGE_TYPE_TO_STRING := 'RC ';
      MessageType.RA  : MESSAGE_TYPE_TO_STRING := 'RA ';
      MessageType.CMD : MESSAGE_TYPE_TO_STRING := 'CMD' ;
    ELSE
      MESSAGE_TYPE_TO_STRING := '???'; 
    END_CASE
  ELSE
    CASE Value OF
      
      MessageType.RI  : MESSAGE_TYPE_TO_STRING := 'RI';
      MessageType.RC  : MESSAGE_TYPE_TO_STRING := 'RC';
      MessageType.RA  : MESSAGE_TYPE_TO_STRING := 'RA';
      MessageType.CMD : MESSAGE_TYPE_TO_STRING := 'CMD' ;
    ELSE
      MESSAGE_TYPE_TO_STRING := '???'; 
    END_CASE  
  END_IF

END_FUNCTION

