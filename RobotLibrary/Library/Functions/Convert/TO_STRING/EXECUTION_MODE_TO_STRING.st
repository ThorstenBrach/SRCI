FUNCTION EXECUTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      EXECUTION_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-20
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// ExecMode
  Value : ExecutionMode;
END_VAR

  CASE Value
  OF
    ExecutionMode.SEQUENCE_PRIMARY                 : EXECUTION_MODE_TO_STRING := StrReplace('SEQUENCE_PRIMARY ({0})'                 ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.SEQUENCE_ABORT_OTHERS_PRIMARY    : EXECUTION_MODE_TO_STRING := StrReplace('SEQUENCE_ABORT_OTHERS_PRIMARY ({0})'    ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.PARALLEL                         : EXECUTION_MODE_TO_STRING := StrReplace('PARALLEL ({0})'                         ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.CONTINUOUS                       : EXECUTION_MODE_TO_STRING := StrReplace('CONTINUOUS ({0})'                       ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.TRIGGER_MULTIPLE                 : EXECUTION_MODE_TO_STRING := StrReplace('TRIGGER_MULTIPLE ({0})'                 ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.SEQUENCE_SECONDARY               : EXECUTION_MODE_TO_STRING := StrReplace('SEQUENCE_SECONDARY ({0})'               ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.SEQUENCE_ABORT_OTHERS_SECONDARY  : EXECUTION_MODE_TO_STRING := StrReplace('SEQUENCE_ABORT_OTHERS_SECONDARY ({0})'  ,'{0}', USINT_TO_STRING(Value));
    ExecutionMode.STOP_PARALLEL_CONTINUOUS_TRIGGER : EXECUTION_MODE_TO_STRING := StrReplace('STOP_PARALLEL_CONTINUOUS_TRIGGER ({0})' ,'{0}', USINT_TO_STRING(Value));
  ELSE
    EXECUTION_MODE_TO_STRING := 'UNKNOWN';
  END_CASE

END_FUNCTION

