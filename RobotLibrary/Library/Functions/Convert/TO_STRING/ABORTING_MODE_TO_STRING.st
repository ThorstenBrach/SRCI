FUNCTION ABORTING_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ABORTING_MODE_TO_STRING                                       
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
  /// AbortingMode
  Value : AbortingMode;
END_VAR

  CASE Value 
  OF
  
    AbortingMode.BUFFER : StrReplace('BUFFER ({0})','{0}' , SINT_TO_STRING(Value));
    AbortingMode.ABORT  : StrReplace('ABORT ({0})' ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

