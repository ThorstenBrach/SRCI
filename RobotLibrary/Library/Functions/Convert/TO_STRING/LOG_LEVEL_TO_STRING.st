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
  
    LogLevel.DEACTIVATE  : StrReplace('DEACTIVATE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.DEBUG       : StrReplace('DEBUG ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.INFO        : StrReplace('INFO ({0})'       ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.WARNING     : StrReplace('WARNING ({0})'    ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.ERROR       : StrReplace('ERROR ({0})'      ,'{0}' , SINT_TO_STRING(Value));
    LogLevel.FATAL_ERROR : StrReplace('FATAL_ERROR ({0})','{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

