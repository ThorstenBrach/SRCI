FUNCTION CmdMessageStateToString : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CmdMessageStateToString                                       
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
    CmdMessageState.EMPTY               : CmdMessageStateToString := StrReplace('EMPTY ({0})'              ,'{0}', USINT_TO_STRING(CmdMessageState.EMPTY));
    CmdMessageState.CREATED             : CmdMessageStateToString := StrReplace('CREATED ({0})'            ,'{0}', USINT_TO_STRING(CmdMessageState.CREATED));
    CmdMessageState.BUFFERED            : CmdMessageStateToString := StrReplace('BUFFERED ({0})'           ,'{0}', USINT_TO_STRING(CmdMessageState.BUFFERED));
    CmdMessageState.BUFFERED_IN_PLANNER : CmdMessageStateToString := StrReplace('BUFFERED_IN_PLANNER ({0})','{0}', USINT_TO_STRING(CmdMessageState.BUFFERED_IN_PLANNER));
    CmdMessageState.ACTIVE              : CmdMessageStateToString := StrReplace('ACTIVE ({0})'             ,'{0}', USINT_TO_STRING(CmdMessageState.ACTIVE));
    CmdMessageState.INTERRUPTED         : CmdMessageStateToString := StrReplace('INTERRUPTED ({0})'        ,'{0}', USINT_TO_STRING(CmdMessageState.INTERRUPTED));
    CmdMessageState.ABORT_REQUEST       : CmdMessageStateToString := StrReplace('ABORT_REQUEST ({0})'      ,'{0}', USINT_TO_STRING(CmdMessageState.ABORT_REQUEST));
    CmdMessageState.DONE                : CmdMessageStateToString := StrReplace('DONE ({0})'               ,'{0}', USINT_TO_STRING(CmdMessageState.DONE));
    CmdMessageState.ABORTED             : CmdMessageStateToString := StrReplace('ABORTED ({0})'            ,'{0}', USINT_TO_STRING(CmdMessageState.ABORTED));
    CmdMessageState.ERROR               : CmdMessageStateToString := StrReplace('ERROR ({0})'              ,'{0}', USINT_TO_STRING(CmdMessageState.ERROR));
  ELSE
    CmdMessageStateToString := CONCAT('CmdMessageStateToString-Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

