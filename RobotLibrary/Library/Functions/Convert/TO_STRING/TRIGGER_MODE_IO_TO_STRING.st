FUNCTION TRIGGER_MODE_IO_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRIGGER_MODE_IO_TO_STRING                                       
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
  /// TriggerModeIo
  Value : TriggerModeIo;
END_VAR

  CASE Value 
  OF
    TriggerModeIo.INVALID                                                             : TRIGGER_MODE_IO_TO_STRING := StrReplace('INVALID ({0})'                                                              ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_INPUT_RISING_EDGE                                           : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_INPUT_RISING_EDGE ({0})'                                            ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_INPUT_FALLING_EDGE                                          : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_INPUT_FALLING_EDGE ({0})'                                           ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_INPUT_RISING_OR_FALLING_EDGE                                : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_INPUT_RISING_OR_FALLING_EDGE ({0})'                                 ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_INPUT_RISING_OR_FALLING_EDGE_INVERTED                       : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_INPUT_RISING_OR_FALLING_EDGE_INVERTED ({0})'                        ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_OUTPUT_RISING_EDGE                                          : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_OUTPUT_RISING_EDGE ({0})'                                           ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_OUTPUT_FALLING_EDGE                                         : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_OUTPUT_FALLING_EDGE ({0})'                                          ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_OUTPUT_RISING_OR_FALLING_EDGE                               : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_OUTPUT_RISING_OR_FALLING_EDGE ({0})'                                ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.DIGITAL_OUTPUT_RISING_OR_FALLING_EDGE_INVERTED                      : TRIGGER_MODE_IO_TO_STRING := StrReplace('DIGITAL_OUTPUT_RISING_OR_FALLING_EDGE_INVERTED ({0})'                       ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_EXCEEDING_DEFINED_THRESHOLD                            : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_EXCEEDING_DEFINED_THRESHOLD ({0})'                             ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_FALLING_BELOW_DEFINED_THRESHOLD                        : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_FALLING_BELOW_DEFINED_THRESHOLD ({0})'                         ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD           : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD ({0})'            ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED  : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_ENTERING_DEFINED_RANGE                                 : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_ENTERING_DEFINED_RANGE ({0})'                                  ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_LEAVING_DEFINED_RANGE                                  : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_LEAVING_DEFINED_RANGE ({0})'                                   ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_ENTERING_OR_LEAVING_DEFINED_RANGE                      : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_ENTERING_OR_LEAVING_DEFINED_RANGE ({0})'                       ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_INPUT_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED             : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_INPUT_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED ({0})'              ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_EXCEEDING_DEFINED_THRESHOLD                           : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_EXCEEDING_DEFINED_THRESHOLD ({0})'                            ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_FALLING_BELOW_DEFINED_THRESHOLD                       : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_FALLING_BELOW_DEFINED_THRESHOLD ({0})'                        ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD          : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD ({0})'           ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_ENTERING_DEFINED_RANGE                                : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_ENTERING_DEFINED_RANGE ({0})'                                 ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_LEAVING_DEFINED_RANGE                                 : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_LEAVING_DEFINED_RANGE ({0})'                                  ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_ENTERING_OR_LEAVING_DEFINED_RANGE                     : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_ENTERING_OR_LEAVING_DEFINED_RANGE ({0})'                      ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.ANALOG_OUTPUT_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED            : TRIGGER_MODE_IO_TO_STRING := StrReplace('ANALOG_OUTPUT_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED ({0})'             ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_EXCEEDING_DEFINED_THRESHOLD                        : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_EXCEEDING_DEFINED_THRESHOLD ({0})'                         ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_FALLING_BELOW_DEFINED_THRESHOLD                    : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_FALLING_BELOW_DEFINED_THRESHOLD ({0})'                     ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD       : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD ({0})'        ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_VALUE_INVERTED  : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_VALUE_INVERTED ({0})'   ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_ENTERING_DEFINED_RANGE                             : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_ENTERING_DEFINED_RANGE ({0})'                              ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_LEAVING_DEFINED_RANGE                              : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_LEAVING_DEFINED_RANGE ({0})'                               ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE                  : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE ({0})'                   ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.INTEGER_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED         : TRIGGER_MODE_IO_TO_STRING := StrReplace('INTEGER_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED ({0})'          ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_EXCEEDING_DEFINED_THRESHOLD                           : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_EXCEEDING_DEFINED_THRESHOLD ({0})'                            ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_FALLING_BELOW_DEFINED_THRESHOLD                       : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_FALLING_BELOW_DEFINED_THRESHOLD ({0})'                        ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD          : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD ({0})'           ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_EXCEEDING_OR_FALLING_BELOW_DEFINED_THRESHOLD_INVERTED ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_ENTERING_DEFINED_RANGE                                : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_ENTERING_DEFINED_RANGE ({0})'                                 ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_LEAVING_DEFINED_RANGE                                 : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_LEAVING_DEFINED_RANGE ({0})'                                  ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE                     : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE ({0})'                      ,'{0}' , SINT_TO_STRING(Value));
    TriggerModeIo.REAL_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED            : TRIGGER_MODE_IO_TO_STRING := StrReplace('REAL_REGISTER_ENTERING_OR_LEAVING_DEFINED_RANGE_INVERTED ({0})'             ,'{0}' , SINT_TO_STRING(Value));
  ELSE
    TRIGGER_MODE_IO_TO_STRING := CONCAT('TRIGGER_MODE_IO_TO_STRING Function: Error -> no parsing for value ', SINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

