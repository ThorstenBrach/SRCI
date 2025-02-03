FUNCTION ERROR_REACTION_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ERROR_REACTION_TO_STRING                                       
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
  /// ErrorReaction
  Value : ErrorReaction;
END_VAR

  CASE Value 
  OF
  
    ErrorReaction.ABORT_AND_MOVE : StrReplace('ABORT_AND_MOVE ({0})','{0}' , USINT_TO_STRING(Value));
    ErrorReaction.ABORT          : StrReplace('ABORT ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    ErrorReaction.NO_REACTION    : StrReplace('NO_REACTION ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

