FUNCTION ORI_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ORI_MODE_TO_STRING                                       
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
  /// OriMode
  Value : OriMode;
END_VAR

  CASE Value 
  OF
    OriMode.LINEAR_INTERPOLATED : ORI_MODE_TO_STRING := StrReplace('LINEAR_INTERPOLATED ({0})','{0}' , USINT_TO_STRING(Value));
    OriMode.JOINT_INTERPOLATED  : ORI_MODE_TO_STRING := StrReplace('JOINT_INTERPOLATED ({0})' ,'{0}' , USINT_TO_STRING(Value));
    OriMode.FIX                 : ORI_MODE_TO_STRING := StrReplace('FIX ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    OriMode.PATH                : ORI_MODE_TO_STRING := StrReplace('PATH ({0})'               ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    ORI_MODE_TO_STRING := CONCAT('ORI_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

