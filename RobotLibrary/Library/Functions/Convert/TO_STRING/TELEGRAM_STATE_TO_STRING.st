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

  CASE State OF
  
    TelegramState.UNDEFINED                : TELEGRAM_STATE_TO_STRING := StrReplace('UNDEFINED ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_161                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_161 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_162                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_162 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_163                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_163 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_164                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_164 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_165                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_165 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_166                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_166 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_167                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_167 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_168                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_168 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_169                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_169 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_170                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_170 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_171                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_171 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.ERROR_172                : TELEGRAM_STATE_TO_STRING := StrReplace('ERROR_172 ({0})'               ,'{0}', USINT_TO_STRING(State));
    TelegramState.READY_TO_RESUME          : TELEGRAM_STATE_TO_STRING := StrReplace('READY_TO_RESUME ({0})'         ,'{0}', USINT_TO_STRING(State));
    TelegramState.READY_FOR_INITIALIZATION : TELEGRAM_STATE_TO_STRING := StrReplace('READY_FOR_INITIALIZATION ({0})','{0}', USINT_TO_STRING(State));
    TelegramState.INITIALIZED              : TELEGRAM_STATE_TO_STRING := StrReplace('INITIALIZED ({0})'             ,'{0}', USINT_TO_STRING(State));  
  ELSE
    TELEGRAM_STATE_TO_STRING := CONCAT('TelegramStateToString-Function: Error -> no parsing for value ', USINT_TO_STRING(State));
  END_CASE

END_FUNCTION

