FUNCTION BLENDING_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BLENDING_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-23
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
  /// BlendingMode
  Value : BlendingMode;
END_VAR

  CASE Value 
  OF
    BlendingMode.EXACT_STOP           : BLENDING_MODE_TO_STRING := StrReplace('EXACT_STOP ({0})','{0}'           , USINT_TO_STRING(Value));
    BlendingMode.DEFINED_VELOCITY     : BLENDING_MODE_TO_STRING := StrReplace('DEFINED_VELOCITY ({0})','{0}'     , USINT_TO_STRING(Value));
    BlendingMode.CORNER_DISTANCE      : BLENDING_MODE_TO_STRING := StrReplace('CORNER_DISTANCE ({0})','{0}'      , USINT_TO_STRING(Value));
    BlendingMode.MAX_CORNER_DEVIATION : BLENDING_MODE_TO_STRING := StrReplace('MAX_CORNER_DEVIATION ({0})','{0}' , USINT_TO_STRING(Value));
    BlendingMode.CORNER_DISTANCE_2R   : BLENDING_MODE_TO_STRING := StrReplace('CORNER_DISTANCE_2R ({0})','{0}'   , USINT_TO_STRING(Value));
    BlendingMode.RAMP_OVERLAP         : BLENDING_MODE_TO_STRING := StrReplace('RAMP_OVERLAP ({0})','{0}'         , USINT_TO_STRING(Value));
    BlendingMode.CORNER_DISTANCE_1R   : BLENDING_MODE_TO_STRING := StrReplace('CORNER_DISTANCE_1R ({0})','{0}'   , USINT_TO_STRING(Value));
  ELSE
    BLENDING_MODE_TO_STRING := CONCAT('BLENDING_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

