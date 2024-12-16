FUNCTION TelegramControlToString : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramControlToString                                       
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

  CASE Control OF
    ControlHalfByte.NONE         : TelegramControlToString := StrReplace('NONE ({0})'        ,'{0}', USINT_TO_STRING(ControlHalfByte.NONE));
    ControlHalfByte.INITIALIZE   : TelegramControlToString := StrReplace('INITIALIZE ({0})'  ,'{0}', USINT_TO_STRING(ControlHalfByte.INITIALIZE));
    ControlHalfByte.RESUME       : TelegramControlToString := StrReplace('RESUME ({0})'      ,'{0}', USINT_TO_STRING(ControlHalfByte.RESUME));
    ControlHalfByte.RESET        : TelegramControlToString := StrReplace('RESET ({0})'       ,'{0}', USINT_TO_STRING(ControlHalfByte.RESET));
    ControlHalfByte.ACK_ERROR    : TelegramControlToString := StrReplace('ACK_ERROR ({0})'   ,'{0}', USINT_TO_STRING(ControlHalfByte.ACK_ERROR));
    ControlHalfByte.CLIENT_ERROR : TelegramControlToString := StrReplace('CLIENT_ERROR ({0})','{0}', USINT_TO_STRING(ControlHalfByte.CLIENT_ERROR));  
  ELSE
    TelegramControlToString := CONCAT('TelegramControlToString-Function: Error -> no parsing for value ', BYTE_TO_STRING(Control));
  END_CASE

END_FUNCTION

