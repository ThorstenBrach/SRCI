FUNCTION ALARM_MESSAGE_TO_STRING : STRING(RobotLibraryParameter.MESSAGE_TEXT_LEN)
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ALARM_MESSAGE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-31
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
  /// AlarmMessag
  Message : AlarmMessage;
END_VAR
VAR CONSTANT
  /// Carrage return and line feed
  CRLF       : STRING := '$R$N';
END_VAR

  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, DATE_TO_STRING(Message.Timestamp.SystemDate));
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, '-');
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, TOD_TO_STRING (Message.Timestamp.SystemTime));
  ALARM_MESSAGE_TO_STRING := StrReplace(ALARM_MESSAGE_TO_STRING, 'TOD#','' );
  ALARM_MESSAGE_TO_STRING := StrReplace(ALARM_MESSAGE_TO_STRING, 'D#', '' );
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, ':');
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, MESSAGE_TYPE_TO_STRING(Value := Message.MessageType, AlignString := TRUE));
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, ':');
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, SEVERITY_TO_STRING    ( Value := Message.Severity  , AlignString := TRUE));
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, ':');
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, DWORD_TO_STRING(Message.MessageCode));
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, ':');
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, Message.MessageText);
  ALARM_MESSAGE_TO_STRING := CONCAT    (ALARM_MESSAGE_TO_STRING, CRLF);

END_FUNCTION

