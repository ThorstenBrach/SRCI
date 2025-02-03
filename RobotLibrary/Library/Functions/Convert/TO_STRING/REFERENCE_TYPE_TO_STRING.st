FUNCTION REFERENCE_TYPE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      REFERENCE_TYPE_TO_STRING                                       
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
  /// ReferenceType
  Value : ReferenceType;
END_VAR

  CASE Value 
  OF
  
    ReferenceType.TOOL  : StrReplace('TOOL ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    ReferenceType.FRAME : StrReplace('FRAME ({0})' ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

