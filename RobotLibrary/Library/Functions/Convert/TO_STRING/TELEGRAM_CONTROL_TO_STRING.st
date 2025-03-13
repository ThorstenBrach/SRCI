FUNCTION TELEGRAM_CONTROL_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TELEGRAM_CONTROL_TO_STRING                                       
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
  Control : ControlHalfByte;
END_VAR

  CASE Control 
  OF
    ControlHalfByte.NONE         : TELEGRAM_CONTROL_TO_STRING := StrReplace('NONE ({0})'        ,'{0}', USINT_TO_STRING(Control));
    ControlHalfByte.INITIALIZE   : TELEGRAM_CONTROL_TO_STRING := StrReplace('INITIALIZE ({0})'  ,'{0}', USINT_TO_STRING(Control));
    ControlHalfByte.RESUME       : TELEGRAM_CONTROL_TO_STRING := StrReplace('RESUME ({0})'      ,'{0}', USINT_TO_STRING(Control));
    ControlHalfByte.RESET        : TELEGRAM_CONTROL_TO_STRING := StrReplace('RESET ({0})'       ,'{0}', USINT_TO_STRING(Control));
    ControlHalfByte.ACK_ERROR    : TELEGRAM_CONTROL_TO_STRING := StrReplace('ACK_ERROR ({0})'   ,'{0}', USINT_TO_STRING(Control));
    ControlHalfByte.CLIENT_ERROR : TELEGRAM_CONTROL_TO_STRING := StrReplace('CLIENT_ERROR ({0})','{0}', USINT_TO_STRING(Control));  
  ELSE
    TELEGRAM_CONTROL_TO_STRING := CONCAT('TelegramControlToString-Function: Error -> no parsing for value ', USINT_TO_STRING(Control));
  END_CASE

END_FUNCTION

