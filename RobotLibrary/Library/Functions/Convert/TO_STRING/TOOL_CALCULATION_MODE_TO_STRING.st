FUNCTION TOOL_CALCULATION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TOOL_CALCULATION_MODE_TO_STRING                                       
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
  /// ToolCalculationMode
  Value : ToolCalculationMode;
END_VAR

  CASE Value 
  OF
    ToolCalculationMode.TWO_POINT_Z_METHOD   : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('TWO_POINT_Z_METHOD ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.THREE_POINT_METHOD   : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('THREE_POINT_METHOD ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.FOUR_POINT_METHOD    : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('FOUR_POINT_METHOD ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.FIVE_POINT_METHOD    : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('FIVE_POINT_METHOD ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.SIX_POINT_METHOD     : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('SIX_POINT_METHOD ({0})'    ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.ABC_WORLD_METHOD     : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('ABC_WORLD_METHOD ({0})'    ,'{0}' , SINT_TO_STRING(Value));
    ToolCalculationMode.ABC_TWO_POINT_METHOD : TOOL_CALCULATION_MODE_TO_STRING := StrReplace('ABC_TWO_POINT_METHOD ({0})','{0}' , SINT_TO_STRING(Value));
  ELSE
    TOOL_CALCULATION_MODE_TO_STRING := CONCAT('TOOL_CALCULATION_MODE_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

