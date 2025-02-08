FUNCTION REAL_TO_PERCENT_UINT : UINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      REAL_TO_PERCENT_UINT                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-07
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
  /// Percent value to convert 
  Value      : REAL;
  /// value is an optional parameter ?  
  IsOptional : BOOL;
END_VAR

  IF ( Value = -1.0)  AND (IsOptional)// 16#FFFF for not supported values 
  THEN
    REAL_TO_PERCENT_UINT := 16#FFFF;
    RETURN;
  END_IF
  
  REAL_TO_PERCENT_UINT := REAL_TO_UINT(Value * RobotLibraryConstants.REAL_CONVERSION_FACTOR);

END_FUNCTION

