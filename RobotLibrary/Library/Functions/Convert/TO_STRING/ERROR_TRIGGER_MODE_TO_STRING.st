FUNCTION ERROR_TRIGGER_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ERROR_TRIGGER_MODE_TO_STRING                                       
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
  /// ErrorTriggerMode
  Value : ErrorTriggerMode;
END_VAR

  CASE Value 
  OF
    ErrorTriggerMode.ANY_COMMAND                    : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('ANY_COMMAND ({0})'                    ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.GENERAL_COMMANDS               : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('GENERAL_COMMANDS ({0})'               ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.ADMINISTRATIVE_COMMANDS        : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('ADMINISTRATIVE_COMMANDS ({0})'        ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.MOVE_COMMANDS                  : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('MOVE_COMMANDS ({0})'                  ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.PERIPHERY_COMMANDS             : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('PERIPHERY_COMMANDS ({0})'             ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.EXTENDED_COMMANDS              : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('EXTENDED_COMMANDS ({0})'              ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.SPECIFIC_COMMAND_OR_RI_MESSAGE : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('SPECIFIC_COMMAND_OR_RI_MESSAGE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.SPECIFIC_RC_OR_RA_MESSAGE_CODE : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('SPECIFIC_RC_OR_RA_MESSAGE_CODE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.ANY_RI_MESSAGE_CODE            : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('ANY_RI_MESSAGE_CODE ({0})'            ,'{0}' , SINT_TO_STRING(Value));
    ErrorTriggerMode.ANY_RC_OR_RA_MESSAGE_CODE      : ERROR_TRIGGER_MODE_TO_STRING := StrReplace('ANY_RC_OR_RA_MESSAGE_CODE ({0})'      ,'{0}' , SINT_TO_STRING(Value));
  ELSE
    ERROR_TRIGGER_MODE_TO_STRING := CONCAT('ERROR_TRIGGER_MODE_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

