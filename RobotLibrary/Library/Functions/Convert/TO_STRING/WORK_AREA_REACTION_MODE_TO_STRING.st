FUNCTION WORK_AREA_REACTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WORK_AREA_REACTION_MODE_TO_STRING                                       
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
  /// WorkAreaReactionMode
  Value : WorkAreaReactionMode;
END_VAR

  CASE Value 
  OF
    WorkAreaReactionMode.NO_REACTION : WORK_AREA_REACTION_MODE_TO_STRING := StrReplace('NO_REACTION ({0})','{0}' , USINT_TO_STRING(Value));
    WorkAreaReactionMode.ABORT       : WORK_AREA_REACTION_MODE_TO_STRING := StrReplace('ABORT ({0})'      ,'{0}' , USINT_TO_STRING(Value));
    WorkAreaReactionMode.INTERRUPT   : WORK_AREA_REACTION_MODE_TO_STRING := StrReplace('INTERRUPT ({0})'  ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    WORK_AREA_REACTION_MODE_TO_STRING := CONCAT('WORK_AREA_REACTION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

