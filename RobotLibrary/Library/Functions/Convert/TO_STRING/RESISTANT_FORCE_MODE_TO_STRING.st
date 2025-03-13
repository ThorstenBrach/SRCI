FUNCTION RESISTANT_FORCE_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RESISTANT_FORCE_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-24
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
  /// ResistanceForceMode
  Value : ResistanceForceMode;
END_VAR

  CASE Value 
  OF
    ResistanceForceMode.RESISTANCE_FORCE_TCP  : RESISTANT_FORCE_MODE_TO_STRING := StrReplace('RESISTANCE_FORCE_TCP ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    ResistanceForceMode.RESISTANCE_FORCE_AXIS : RESISTANT_FORCE_MODE_TO_STRING := StrReplace('RESISTANCE_FORCE_AXIS ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    RESISTANT_FORCE_MODE_TO_STRING := CONCAT('RESISTANT_FORCE_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

