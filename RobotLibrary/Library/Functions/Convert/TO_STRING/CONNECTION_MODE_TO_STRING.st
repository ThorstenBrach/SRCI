FUNCTION CONNECTION_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CONNECTION_MODE_TO_STRING                                       
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
  /// ConnectionMode
  Value : ConnectionMode;
END_VAR

  CASE Value 
  OF
  
    ConnectionMode.RC_CONNECTED  : StrReplace('RC_CONNECTED ({0})'  ,'{0}' , SINT_TO_STRING(Value));
    ConnectionMode.PLC_CONNECTED : StrReplace('PLC_CONNECTED ({0})' ,'{0}' , SINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

