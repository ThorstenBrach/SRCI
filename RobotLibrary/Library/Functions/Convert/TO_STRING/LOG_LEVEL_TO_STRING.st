FUNCTION LOG_LEVEL_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LOG_LEVEL_TO_STRING                                       
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
  /// LogLevel
  Value : LogLevel;
END_VAR

  CASE Value 
  OF
    LogLevel.DEACTIVATE  : LOG_LEVEL_TO_STRING := StrReplace('DEACTIVATE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.DEBUG       : LOG_LEVEL_TO_STRING := StrReplace('DEBUG ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.INFO        : LOG_LEVEL_TO_STRING := StrReplace('INFO ({0})'       ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.WARNING     : LOG_LEVEL_TO_STRING := StrReplace('WARNING ({0})'    ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.ERROR       : LOG_LEVEL_TO_STRING := StrReplace('ERROR ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.FATAL_ERROR : LOG_LEVEL_TO_STRING := StrReplace('FATAL_ERROR ({0})','{0}' , SINT_TO_STRING(Value));
  ELSE
    LOG_LEVEL_TO_STRING := CONCAT('LOG_LEVEL_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

