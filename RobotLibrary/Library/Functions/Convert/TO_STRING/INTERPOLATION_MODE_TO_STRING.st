FUNCTION INTERPOLATION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      INTERPOLATION_MODE_TO_STRING                                       
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
  /// InterpolationMode
  Value : InterpolationMode;
END_VAR

  CASE Value 
  OF
    InterpolationMode.LINEAR_INTERPOLATION : INTERPOLATION_MODE_TO_STRING := StrReplace('LINEAR_INTERPOLATION ({0})' ,'{0}' , USINT_TO_STRING(Value));
    InterpolationMode.DIRECT_INTERPOLATION : INTERPOLATION_MODE_TO_STRING := StrReplace('DIRECT_INTERPOLATION ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    INTERPOLATION_MODE_TO_STRING := CONCAT('INTERPOLATION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

