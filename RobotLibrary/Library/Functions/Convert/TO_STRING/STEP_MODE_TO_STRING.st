FUNCTION STEP_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      STEP_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-18
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
  /// StepMode
  Value : StepMode;
END_VAR

  CASE Value 
  OF
    
    StepMode.DEACTIVATE : STEP_MODE_TO_STRING := 'DEACTIVATE (0)';
    StepMode.BLENDING   : STEP_MODE_TO_STRING := 'BLENDING (1)';
    StepMode.EXACT_STOP : STEP_MODE_TO_STRING := 'EXACT_STOP (2)';
  
  END_CASE

END_FUNCTION

