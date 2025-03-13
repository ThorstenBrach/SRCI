FUNCTION PROCESSING_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      PROCESSING_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-23
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
  /// ProcessingMode
  Value : ProcessingMode;
END_VAR

  CASE Value 
  OF
    ProcessingMode.BUFFERED           : PROCESSING_MODE_TO_STRING := StrReplace('BUFFERED ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.ABORTING           : PROCESSING_MODE_TO_STRING := StrReplace('ABORTING ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.PARALLEL           : PROCESSING_MODE_TO_STRING := StrReplace('PARALLEL ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.CONTINUOUS         : PROCESSING_MODE_TO_STRING := StrReplace('CONTINUOUS ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.DEACTIVATE         : PROCESSING_MODE_TO_STRING := StrReplace('DEACTIVATE ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_BUFFERED   : PROCESSING_MODE_TO_STRING := StrReplace('TRIGGER_BUFFERED ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_ABORTING   : PROCESSING_MODE_TO_STRING := StrReplace('TRIGGER_ABORTING ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_ONCE       : PROCESSING_MODE_TO_STRING := StrReplace('TRIGGER_ONCE ({0})'       ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_CONTINUOUS : PROCESSING_MODE_TO_STRING := StrReplace('TRIGGER_CONTINUOUS ({0})' ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_MULTIPLE   : PROCESSING_MODE_TO_STRING := StrReplace('TRIGGER_MULTIPLE ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    PROCESSING_MODE_TO_STRING := CONCAT('PROCESSING_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

