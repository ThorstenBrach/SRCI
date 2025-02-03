FUNCTION SPLINE_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SPLINE_MODE_TO_STRING                                       
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
  /// SplineMode
  Value : SplineMode;
END_VAR

  CASE Value 
  OF
  
    SplineMode.DISCRETE_POINTS      : StrReplace('DISCRETE_POINTS ({0})'      ,'{0}' , UINT_TO_STRING(Value));
    SplineMode.BEZIER_SPLINE        : StrReplace('BEZIER_SPLINE ({0})'        ,'{0}' , UINT_TO_STRING(Value));
    SplineMode.B_SPLINES            : StrReplace('B_SPLINES ({0})'            ,'{0}' , UINT_TO_STRING(Value));
    SplineMode.CUBIC_HERMITE_SPLINE : StrReplace('CUBIC_HERMITE_SPLINE ({0})' ,'{0}' , UINT_TO_STRING(Value));
    SplineMode.C_SPLINES            : StrReplace('C_SPLINES ({0})'            ,'{0}' , UINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

