FUNCTION TRIGGER_CONDITION_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRIGGER_CONDITION_TO_STRING                                       
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
  /// TriggerCondition
  Value : TriggerCondition;
END_VAR

  CASE Value 
  OF
  
    TriggerCondition.TARGET_POSITION_TIME_MS                : StrReplace('TARGET_POSITION_TIME_MS ({0})'               ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.TARGET_POSITION_TCP_VELOCITY_ABSOLUTE  : StrReplace('TARGET_POSITION_TCP_VELOCITY_ABSOLUTE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.TARGET_POSITION_TCP_VELOCITY_PERCENT   : StrReplace('TARGET_POSITION_TCP_VELOCITY_PERCENT ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.TARGET_POSITION_DISTANCE_ABSOLUTE      : StrReplace('TARGET_POSITION_DISTANCE_ABSOLUTE ({0})'     ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.TARGET_POSITION_DISTANCE_PERCENT       : StrReplace('TARGET_POSITION_DISTANCE_PERCENT ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.UNDEFINED                              : StrReplace('UNDEFINED ({0})'                             ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.START_POSITION_DISTANCE_PERCENT        : StrReplace('START_POSITION_DISTANCE_PERCENT ({0})'       ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.START_POSITION_DISTANCE_ABSOLUTE       : StrReplace('START_POSITION_DISTANCE_ABSOLUTE ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.START_POSITION_TCP_VELOCITY_PERCENT    : StrReplace('START_POSITION_TCP_VELOCITY_PERCENT ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.START_POSITION_TCP_VELOCIT_ABSOLUTE    : StrReplace('START_POSITION_TCP_VELOCIT_ABSOLUTE ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    TriggerCondition.START_POSITION_TIME_MS                 : StrReplace('START_POSITION_TCP_VELOCIT_ABSOLUTE ({0})'   ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

