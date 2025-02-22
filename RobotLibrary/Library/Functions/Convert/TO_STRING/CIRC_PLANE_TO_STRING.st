FUNCTION CIRC_PLANE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CIRC_PLANE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-30
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
  /// CircPlane
  Value : CircPlane;
END_VAR

  CASE Value 
  OF
  
    CircPlane.XZ_PLANE : StrReplace('XZ_PLANE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    CircPlane.YZ_PLANE : StrReplace('YZ_PLANE ({0})' ,'{0}' , SINT_TO_STRING(Value));
    CircPlane.XY_PLANE : StrReplace('XY_PLANE ({0})' ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

