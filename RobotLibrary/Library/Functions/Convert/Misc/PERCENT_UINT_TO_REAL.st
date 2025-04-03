FUNCTION PERCENT_UINT_TO_REAL : REAL
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      PERCENT_UINT_TO_REAL                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-04-02
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
  Value    : UINT;
  /// value is an optional parameter ?  
  IsOptional : BOOL;
END_VAR

  IF (( Value = 16#FFFF_FFFF ) AND (IsOptional)) OR // 16#FFFF_FFFF for not supported values
     (( Value = 16#0000_FFFF ) AND (IsOptional))    // 16#0000_FFFF for not supported values 
  THEN
    PERCENT_UINT_TO_REAL := -1.0;
    RETURN;
  END_IF
  
  PERCENT_UINT_TO_REAL := UINT_TO_REAL(Value) / RobotLibraryConstants.REAL_CONVERSION_FACTOR; {warning 'ToDo: check conversation is correct ?'}

END_FUNCTION

