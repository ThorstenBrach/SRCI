FUNCTION UNIT_LIMIT_AXIS_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ORI_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-25
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
  /// UnitLimitAxis
  Value : UnitLimitAxis;
END_VAR

  CASE Value 
  OF
    UnitLimitAxis.PERCENTAGE  : UNIT_LIMIT_AXIS_TO_STRING := StrReplace('PERCENTAGE ({0})'  ,'{0}' , USINT_TO_STRING(Value));
    UnitLimitAxis.NEWTONMETER : UNIT_LIMIT_AXIS_TO_STRING := StrReplace('NEWTONMETER ({0})' ,'{0}' , USINT_TO_STRING(Value));
    UnitLimitAxis.MILLIAMPERE : UNIT_LIMIT_AXIS_TO_STRING := StrReplace('MILLIAMPERE ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    UNIT_LIMIT_AXIS_TO_STRING := CONCAT('UNIT_LIMIT_AXIS_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

