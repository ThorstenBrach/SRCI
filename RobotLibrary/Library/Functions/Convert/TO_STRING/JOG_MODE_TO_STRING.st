FUNCTION JOG_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      JOG_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-20
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
  /// JogMode
  Value : JogMode;
END_VAR

  CASE Value 
  OF
    
    JogMode.JOG_FRAME : JOG_MODE_TO_STRING := StrReplace('JOG_FRAME ({0})','{0}' , USINT_TO_STRING(Value));
    JogMode.JOG_TOOL  : JOG_MODE_TO_STRING := StrReplace('JOG_TOOL ({0})','{0}'  , USINT_TO_STRING(Value));
    JogMode.JOG_AXES  : JOG_MODE_TO_STRING := StrReplace('JOG_AXES ({0})','{0}'  , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

