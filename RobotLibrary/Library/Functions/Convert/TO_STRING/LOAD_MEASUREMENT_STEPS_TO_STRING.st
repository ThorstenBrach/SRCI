FUNCTION LOAD_MEASUREMENT_STEPS_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LOAD_MEASUREMENT_STEPS_TO_STRING                                       
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
  /// LoadMeasurementSteps
  Value : LoadMeasurementSteps;
END_VAR

  CASE Value 
  OF
    LoadMeasurementSteps.RESET            : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('RESET ({0})'            ,'{0}' , USINT_TO_STRING(Value));
    LoadMeasurementSteps.FIRST_POSITION   : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('FIRST_POSITION ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    LoadMeasurementSteps.SECOND_POSITION  : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('SECOND_POSITION ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    LoadMeasurementSteps.THIRD_POSITION   : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('THIRD_POSITION ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    LoadMeasurementSteps.FOURTH_POSITION  : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('FOURTH_POSITION ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    LoadMeasurementSteps.LOAD_CALCULATION : LOAD_MEASUREMENT_STEPS_TO_STRING := StrReplace('LOAD_CALCULATION ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    LOAD_MEASUREMENT_STEPS_TO_STRING := CONCAT('LOAD_MEASUREMENT_STEPS_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

