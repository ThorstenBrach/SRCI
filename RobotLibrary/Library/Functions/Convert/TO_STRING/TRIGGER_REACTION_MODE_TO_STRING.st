FUNCTION TRIGGER_REACTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRIGGER_REACTION_MODE_TO_STRING                                       
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
  /// TriggerReactionMode
  Value : TriggerReactionMode;
END_VAR

  CASE Value 
  OF
  
    TriggerReactionMode.NO_REACTION                : StrReplace('NO_REACTION ({0})'                 ,'{0}' , SINT_TO_STRING(Value));
    TriggerReactionMode.INTERRUPT                  : StrReplace('INTERRUPT ({0})'                   ,'{0}' , SINT_TO_STRING(Value));
    TriggerReactionMode.GROUP_STOP                 : StrReplace('GROUP_STOP ({0})'                  ,'{0}' , SINT_TO_STRING(Value));
    TriggerReactionMode.DISABLE_ROBOT              : StrReplace('DISABLE_ROBOT ({0})'               ,'{0}' , SINT_TO_STRING(Value));
    TriggerReactionMode.STOP_ACTUAL_MOTION_COMMAND : StrReplace('STOP_ACTUAL_MOTION_COMMAND ({0})'  ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

