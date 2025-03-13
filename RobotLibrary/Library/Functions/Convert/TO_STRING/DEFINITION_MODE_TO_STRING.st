FUNCTION DEFINITION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DEFINITION_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-01
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
  /// DefinitionMode
  Value : DefinitionMode;
END_VAR

  CASE Value 
  OF
    DefinitionMode.CENTER : DEFINITION_MODE_TO_STRING := StrReplace('CENTER ({0})','{0}' , USINT_TO_STRING(Value));
    DefinitionMode.FACE   : DEFINITION_MODE_TO_STRING := StrReplace('FACE ({0})'  ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    DEFINITION_MODE_TO_STRING := CONCAT('DEFINITION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

