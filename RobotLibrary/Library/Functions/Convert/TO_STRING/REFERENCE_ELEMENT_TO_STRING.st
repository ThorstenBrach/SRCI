FUNCTION REFERENCE_ELEMENT_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      REFERENCE_ELEMENT_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-24
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
  /// ReferenceElement
  Value : ReferenceElement;
END_VAR

  CASE Value 
  OF
  
    ReferenceElement.NOT_USED : StrReplace('NOT_USED ({0})' ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.X_AXIS   : StrReplace('X_AXIS ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.Y_AXIS   : StrReplace('Y_AXIS ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.Z_AXIS   : StrReplace('Z_AXIS ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.XY_PLANE : StrReplace('XY_PLANE ({0})' ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.XZ_PLANE : StrReplace('XZ_PLANE ({0})' ,'{0}' , USINT_TO_STRING(Value));
    ReferenceElement.YZ_PLANE : StrReplace('YZ_PLANE ({0})' ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

