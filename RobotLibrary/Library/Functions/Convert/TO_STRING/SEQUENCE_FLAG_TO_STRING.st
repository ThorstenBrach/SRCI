FUNCTION SEQUENCE_FLAG_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SEQUENCE_FLAG_TO_STRING                                       
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
  /// SequenceFlag
  Value : SequenceFlag;
END_VAR

  CASE Value 
  OF
    SequenceFlag.NO_SEQUENCE        : SEQUENCE_FLAG_TO_STRING := StrReplace('NO_SEQUENCE ({0})'        ,'{0}' , USINT_TO_STRING(Value));
    SequenceFlag.PRIMARY_SEQUENCE   : SEQUENCE_FLAG_TO_STRING := StrReplace('PRIMARY_SEQUENCE ({0})'   ,'{0}' , USINT_TO_STRING(Value));
    SequenceFlag.SECONDARY_SEQUENCE : SEQUENCE_FLAG_TO_STRING := StrReplace('SECONDARY_SEQUENCE ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    SEQUENCE_FLAG_TO_STRING := CONCAT('SEQUENCE_FLAG_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

