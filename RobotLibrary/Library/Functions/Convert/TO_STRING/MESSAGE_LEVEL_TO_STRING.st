FUNCTION MESSAGE_LEVEL_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MESSAGE_LEVEL_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-02
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
  /// MessageLevel
  Value : MessageLevel;
END_VAR

  CASE Value 
  OF
  
    MessageLevel.DEBUG       : StrReplace('DEBUG ({0})'      ,'{0}' , USINT_TO_STRING(Value));
    MessageLevel.INFO        : StrReplace('INFO ({0})'       ,'{0}' , USINT_TO_STRING(Value));
    MessageLevel.WARNING     : StrReplace('WARNING ({0})'    ,'{0}' , USINT_TO_STRING(Value));
    MessageLevel.ERROR       : StrReplace('ERROR ({0})'      ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

