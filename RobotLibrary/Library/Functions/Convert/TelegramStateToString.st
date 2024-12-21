FUNCTION TelegramStateToString : STRING
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
  
    TelegramState.UNDEFINED                : TelegramStateToString := StrReplace('UNDEFINED ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.UNDEFINED));
    TelegramState.ERROR_161                : TelegramStateToString := StrReplace('ERROR_161 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_161));
    TelegramState.ERROR_162                : TelegramStateToString := StrReplace('ERROR_162 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_162));
    TelegramState.ERROR_163                : TelegramStateToString := StrReplace('ERROR_163 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_163));
    TelegramState.ERROR_164                : TelegramStateToString := StrReplace('ERROR_164 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_164));
    TelegramState.ERROR_165                : TelegramStateToString := StrReplace('ERROR_165 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_165));
    TelegramState.ERROR_166                : TelegramStateToString := StrReplace('ERROR_166 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_166));
    TelegramState.ERROR_167                : TelegramStateToString := StrReplace('ERROR_167 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_167));
    TelegramState.ERROR_168                : TelegramStateToString := StrReplace('ERROR_168 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_168));
    TelegramState.ERROR_169                : TelegramStateToString := StrReplace('ERROR_169 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_169));
    TelegramState.ERROR_170                : TelegramStateToString := StrReplace('ERROR_170 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_170));
    TelegramState.ERROR_171                : TelegramStateToString := StrReplace('ERROR_171 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_171));
    TelegramState.ERROR_172                : TelegramStateToString := StrReplace('ERROR_172 ({0})'               ,'{0}', USINT_TO_STRING(TelegramState.ERROR_172));
    TelegramState.READY_TO_RESUME          : TelegramStateToString := StrReplace('READY_TO_RESUME ({0})'         ,'{0}', USINT_TO_STRING(TelegramState.READY_TO_RESUME));
    TelegramState.READY_FOR_INITIALIZATION : TelegramStateToString := StrReplace('READY_FOR_INITIALIZATION ({0})','{0}', USINT_TO_STRING(TelegramState.READY_FOR_INITIALIZATION));
    TelegramState.INITIALIZED              : TelegramStateToString := StrReplace('INITIALIZED ({0})'             ,'{0}', USINT_TO_STRING(TelegramState.INITIALIZED));  
  ELSE
    TelegramStateToString := CONCAT('TelegramStateToString-Function: Error -> no parsing for value ', USINT_TO_STRING(State));
  END_CASE

END_FUNCTION

