FUNCTION TRANSFORM_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRANSFORM_MODE_TO_STRING                                       
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
  /// TransformMode
  Value : TransformMode;
END_VAR

  CASE Value 
  OF
  
    TransformMode.MIRROR_AT_POINT             : StrReplace('MIRROR_AT_POINT ({0})'             ,'{0}' , SINT_TO_STRING(Value));
    TransformMode.MIRROR_AT_STRAIGHT_LINE     : StrReplace('MIRROR_AT_STRAIGHT_LINE ({0})'     ,'{0}' , SINT_TO_STRING(Value));
    TransformMode.MIRROR_AT_PLANE             : StrReplace('MIRROR_AT_PLANE ({0})'             ,'{0}' , SINT_TO_STRING(Value));
    TransformMode.ROTATE_AROUND_STRAIGHT_LINE : StrReplace('ROTATE_AROUND_STRAIGHT_LINE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    TransformMode.SHIFT_BY_VECTOR             : StrReplace('SHIFT_BY_VECTOR ({0})'             ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

