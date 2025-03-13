FUNCTION OPERATION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      OPERATION_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-02
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
  /// OperationMode
  Value : OperationMode;
END_VAR

  CASE Value 
  OF
    OperationMode.T1_LOCAL : OPERATION_MODE_TO_STRING := StrReplace('T1_LOCAL ({0})' ,'{0}' , USINT_TO_STRING(Value));
    OperationMode.T2_LOCAL : OPERATION_MODE_TO_STRING := StrReplace('T2_LOCAL ({0})' ,'{0}' , USINT_TO_STRING(Value));
    OperationMode.AUTO     : OPERATION_MODE_TO_STRING := StrReplace('AUTO ({0})'     ,'{0}' , USINT_TO_STRING(Value));
    OperationMode.AUTO_EXT : OPERATION_MODE_TO_STRING := StrReplace('AUTO_EXT ({0})' ,'{0}' , USINT_TO_STRING(Value));
    OperationMode.T1_EXT   : OPERATION_MODE_TO_STRING := StrReplace('T1_EXT ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    OperationMode.T2_EXT   : OPERATION_MODE_TO_STRING := StrReplace('T2_EXT ({0})'   ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    OPERATION_MODE_TO_STRING := CONCAT('OPERATION_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

