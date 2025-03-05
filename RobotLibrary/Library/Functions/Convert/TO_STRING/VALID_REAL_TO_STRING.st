FUNCTION VALID_REAL_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      VALID_REAL_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-26
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
  /// Real
  Value : REAL;
END_VAR

  IF ( SysDepIsValidReal(Value))
  THEN
    VALID_REAL_TO_STRING := REAL_TO_STRING(Value);
  ELSE
    VALID_REAL_TO_STRING := 'NaN';
  END_IF

END_FUNCTION

