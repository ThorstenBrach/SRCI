FUNCTION FRAME_CALCULATION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FRAME_CALCULATION_MODE_TO_STRING                                       
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
  /// FrameCalculationMode
  Value : FrameCalculationMode;
END_VAR

  CASE Value 
  OF
    FrameCalculationMode.THREE_POINT_METHOD : FRAME_CALCULATION_MODE_TO_STRING := StrReplace('THREE_POINT_METHOD ({0})','{0}' , SINT_TO_STRING(Value));
    FrameCalculationMode.FOUR_POINT_METHOD  : FRAME_CALCULATION_MODE_TO_STRING := StrReplace('FOUR_POINT_METHOD ({0})' ,'{0}' , SINT_TO_STRING(Value));
    FrameCalculationMode.ONE_POINT_METHOD   : FRAME_CALCULATION_MODE_TO_STRING := StrReplace('ONE_POINT_METHOD ({0})'  ,'{0}' , SINT_TO_STRING(Value));
  ELSE
    FRAME_CALCULATION_MODE_TO_STRING := CONCAT('FRAME_CALCULATION_MODE_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

