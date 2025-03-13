FUNCTION CMD_MESSAGE_STATE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CMD_MESSAGE_STATE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-16
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
  /// Command message state
  Value : CmdMessageState;
END_VAR

  CASE Value
  OF
    CmdMessageState.EMPTY               : CMD_MESSAGE_STATE_TO_STRING := StrReplace('EMPTY ({0})'              ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.CREATED             : CMD_MESSAGE_STATE_TO_STRING := StrReplace('CREATED ({0})'            ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.BUFFERED            : CMD_MESSAGE_STATE_TO_STRING := StrReplace('BUFFERED ({0})'           ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.BUFFERED_IN_PLANNER : CMD_MESSAGE_STATE_TO_STRING := StrReplace('BUFFERED_IN_PLANNER ({0})','{0}', USINT_TO_STRING(Value));
    CmdMessageState.ACTIVE              : CMD_MESSAGE_STATE_TO_STRING := StrReplace('ACTIVE ({0})'             ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.INTERRUPTED         : CMD_MESSAGE_STATE_TO_STRING := StrReplace('INTERRUPTED ({0})'        ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.ABORT_REQUEST       : CMD_MESSAGE_STATE_TO_STRING := StrReplace('ABORT_REQUEST ({0})'      ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.DONE                : CMD_MESSAGE_STATE_TO_STRING := StrReplace('DONE ({0})'               ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.ABORTED             : CMD_MESSAGE_STATE_TO_STRING := StrReplace('ABORTED ({0})'            ,'{0}', USINT_TO_STRING(Value));
    CmdMessageState.ERROR               : CMD_MESSAGE_STATE_TO_STRING := StrReplace('ERROR ({0})'              ,'{0}', USINT_TO_STRING(Value));
  ELSE
    CMD_MESSAGE_STATE_TO_STRING := CONCAT('CMD_MESSAGE_STATE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

