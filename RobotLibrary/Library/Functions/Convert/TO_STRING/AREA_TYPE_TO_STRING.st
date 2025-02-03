FUNCTION AREA_TYPE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AREA_TYPE_TO_STRING                                       
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
  /// AreaType
  Value : AreaType;
END_VAR

  CASE Value 
  OF
  
    AreaType.AXES     : StrReplace('AXES ({0})'     ,'{0}' , USINT_TO_STRING(Value));
    AreaType.BOX      : StrReplace('BOX ({0})'      ,'{0}' , USINT_TO_STRING(Value));
    AreaType.CYLINDER : StrReplace('CYLINDER ({0})' ,'{0}' , USINT_TO_STRING(Value));
    AreaType.SPHERE   : StrReplace('SPHERE ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

