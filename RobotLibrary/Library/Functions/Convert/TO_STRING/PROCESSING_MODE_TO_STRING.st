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
  
    ProcessingMode.BUFFERED           : StrReplace('BUFFERED ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.ABORTING           : StrReplace('ABORTING ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.PARALLEL           : StrReplace('PARALLEL ({0})'           ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.CONTINUOUS         : StrReplace('CONTINUOUS ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.DEACTIVATE         : StrReplace('DEACTIVATE ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_BUFFERED   : StrReplace('TRIGGER_BUFFERED ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_ABORTING   : StrReplace('TRIGGER_ABORTING ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_ONCE       : StrReplace('TRIGGER_ONCE ({0})'       ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_CONTINUOUS : StrReplace('TRIGGER_CONTINUOUS ({0})' ,'{0}' , USINT_TO_STRING(Value));
    ProcessingMode.TRIGGER_MULTIPLE   : StrReplace('TRIGGER_MULTIPLE ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

