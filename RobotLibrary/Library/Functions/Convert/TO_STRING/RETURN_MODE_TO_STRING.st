FUNCTION RETURN_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RETURN_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-01
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
  /// ReturnMode
  Value : ReturnMode;
END_VAR

  CASE Value 
  OF
  
    ReturnMode.INTERRUPT_POSITION : StrReplace('INTERRUPT_POSITION ({0})','{0}' , USINT_TO_STRING(Value));
    ReturnMode.END_POSITION       : StrReplace('END_POSITION ({0})'      ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

