FUNCTION SYNC_REACTION_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SYNC_REACTION_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-24
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
  /// SyncReaction
  Value : SyncReaction;
END_VAR

  CASE Value 
  OF
    SyncReaction.NO_REACTION     : SYNC_REACTION_TO_STRING := StrReplace('NO_REACTION ({0})'     ,'{0}' , USINT_TO_STRING(Value));
    SyncReaction.REACTION_TYPE_1 : SYNC_REACTION_TO_STRING := StrReplace('REACTION_TYPE_1 ({0})' ,'{0}' , USINT_TO_STRING(Value));
    SyncReaction.REACTION_TYPE_2 : SYNC_REACTION_TO_STRING := StrReplace('REACTION_TYPE_2 ({0})' ,'{0}' , USINT_TO_STRING(Value));
    SyncReaction.REACTION_TYPE_3 : SYNC_REACTION_TO_STRING := StrReplace('REACTION_TYPE_3 ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    SYNC_REACTION_TO_STRING := CONCAT('SYNC_REACTION_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

