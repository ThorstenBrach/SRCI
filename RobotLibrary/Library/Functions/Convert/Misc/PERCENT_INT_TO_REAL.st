FUNCTION PERCENT_INT_TO_REAL : REAL
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      PERCENT_INT_TO_REAL                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-07
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Percent value to convert 
  Value    : INT;
  /// value is an optional parameter ?  
  IsOptional : BOOL;
END_VAR

  IF ( INT_TO_WORD(Value) = 16#FFFF ) AND ( IsOptional ) // ST-FIX F10: 16#FFFF for not supported values
  THEN
    PERCENT_INT_TO_REAL := -1.0;
  ELSE
    PERCENT_INT_TO_REAL := INT_TO_REAL(Value) / RobotLibraryConstants.REAL_CONVERSION_FACTOR;   
  END_IF

END_FUNCTION

