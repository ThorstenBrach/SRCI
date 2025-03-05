FUNCTION MEASURING_IO_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MEASURING_IO_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-23
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
  /// MeasuringIoMode
  Value : MeasuringIoMode;
END_VAR

  CASE Value 
  OF
  
    MeasuringIoMode.MEASUREMENT_AT_NEXT_RISING_EDGE             : StrReplace('MEASUREMENT_AT_NEXT_RISING_EDGE ({0})'             ,'{0}' , USINT_TO_STRING(Value));
    MeasuringIoMode.MEASUREMENT_AT_NEXT_FALLING_EDGE            : StrReplace('MEASUREMENT_AT_NEXT_FALLING_EDGE ({0})'            ,'{0}' , USINT_TO_STRING(Value));
    MeasuringIoMode.MEASUREMENT_AT_NEXT_EDGE                    : StrReplace('MEASUREMENT_AT_NEXT_EDGE ({0})'                    ,'{0}' , USINT_TO_STRING(Value));
    MeasuringIoMode.MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_RISING  : StrReplace('MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_RISING ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    MeasuringIoMode.MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_FALLING : StrReplace('MEASUREMENT_AT_TWO_EDGES_BEGIN_WITH_FALLING ({0})' ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

