FUNCTION TELEGRAM_STATE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramStateToString                                       
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
  /// Telegram state
  State : TelegramState;
END_VAR

  CASE State 
  OF
    TelegramState.UNDEFINED                                          : TELEGRAM_STATE_TO_STRING := StrReplace('UNDEFINED ({0})'                                          ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_161_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_161_TELEGRAM_CONTROL_MISMATCH_TELEGRAM_STATE ({0})' ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_162_INIT_LOST_UNKNOWN                        : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_162_INIT_LOST_UNKNOWN ({0})'                        ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_163_TELEGRAM_LENGTH_MISMATCH                 : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_163_TELEGRAM_LENGTH_MISMATCH ({0})'                 ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_164_SRCI_MAJOR_VERSION_INCOMPATIBLE          : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_164_SRCI_MAJOR_VERSION_INCOMPATIBLE ({0})'          ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_165_LIFESIGN_TIMEOUT                         : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_165_LIFESIGN_TIMEOUT ({0})'                         ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_166_CYCLIC_DATA_TOO_LARGE                    : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_166_CYCLIC_DATA_TOO_LARGE ({0})'                    ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_167_INTERFACE_WAS_RESET_AFTER_INIT           : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_167_INTERFACE_WAS_RESET_AFTER_INIT ({0})'           ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_168_TELEGRAM_SEQ_TIMEOUT                     : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_168_TELEGRAM_SEQ_TIMEOUT ({0})'                     ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_169_TELEGRAM_NO_CHANGED_AFTER_INIT           : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_169_TELEGRAM_NO_CHANGED_AFTER_INIT ({0})'           ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_170_AXESGROUP_ID_INVALID                     : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_170_AXESGROUP_ID_INVALID ({0})'                     ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_171_TELEGRAM_NUMBER_INVALID                  : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_171_TELEGRAM_NUMBER_INVALID ({0})'                  ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_172_TELEGRAM_NUMBER_NOT_SUPPORTED            : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_172_TELEGRAM_NUMBER_NOT_SUPPORTED ({0})'            ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_173_SERVER_CONNECTION_LOST                   : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_173_SERVER_CONNECTION_LOST ({0})'                   ,'{0}', USINT_TO_STRING(State));
    TelegramState.READY_TO_RESUME                                    : TELEGRAM_STATE_TO_STRING := StrReplace('READY_TO_RESUME ({0})'                                    ,'{0}', USINT_TO_STRING(State));
    TelegramState.READY_FOR_INITIALIZATION                           : TELEGRAM_STATE_TO_STRING := StrReplace('READY_FOR_INITIALIZATION ({0})'                           ,'{0}', USINT_TO_STRING(State));
    TelegramState.INITIALIZED                                        : TELEGRAM_STATE_TO_STRING := StrReplace('INITIALIZED ({0})'                                        ,'{0}', USINT_TO_STRING(State));  
  ELSE
    TELEGRAM_STATE_TO_STRING := CONCAT('TELEGRAM_STATE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(State));
  END_CASE

END_FUNCTION

