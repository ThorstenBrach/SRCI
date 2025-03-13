FUNCTION CIRC_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CIRC_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-30
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
  /// CircMode
  Value : CircMode;
END_VAR

  CASE Value 
  OF
    CircMode.BORDER            : CIRC_MODE_TO_STRING := StrReplace('BORDER ({0})'            ,'{0}' , SINT_TO_STRING(Value));
    CircMode.CENTER            : CIRC_MODE_TO_STRING := StrReplace('CENTER ({0})'            ,'{0}' , SINT_TO_STRING(Value));
    CircMode.CENTER_WITH_ANGLE : CIRC_MODE_TO_STRING := StrReplace('CENTER_WITH_ANGLE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    CircMode.RADIUS            : CIRC_MODE_TO_STRING := StrReplace('RADIUS ({0})'            ,'{0}' , SINT_TO_STRING(Value));
  ELSE
    CIRC_MODE_TO_STRING := CONCAT('CIRC_MODE_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

