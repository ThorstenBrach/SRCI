FUNCTION LOGON_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LOGON_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-01
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
  /// LogonMode
  Value : LogonMode;
END_VAR

  CASE Value 
  OF
  
    LogonMode.PASSWORD_ONLY         : StrReplace('PASSWORD_ONLY ({0})'         ,'{0}' , SINT_TO_STRING(Value));
    LogonMode.USERNAME_AND_PASSWORD : StrReplace('USERNAME_AND_PASSWORD ({0})' ,'{0}' , SINT_TO_STRING(Value));
    LogonMode.LEVEL_ID_AND_PASSWORD : StrReplace('LEVEL_ID_AND_PASSWORD ({0})' ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

