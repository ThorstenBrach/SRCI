FUNCTION COLLISION_REACTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      COLLISION_REACTION_MODE_TO_STRING                                       
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
  /// CollisionReactionMode
  Value : CollisionReactionMode;
END_VAR

  CASE Value 
  OF
    CollisionReactionMode.REVERSED_MOVEMENT : COLLISION_REACTION_MODE_TO_STRING := StrReplace('REVERSED_MOVEMENT ({0})','{0}' , USINT_TO_STRING(Value));
    CollisionReactionMode.STANDING_STILL    : COLLISION_REACTION_MODE_TO_STRING := StrReplace('STANDING_STILL ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    COLLISION_REACTION_MODE_TO_STRING := CONCAT('COLLISION_REACTION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

