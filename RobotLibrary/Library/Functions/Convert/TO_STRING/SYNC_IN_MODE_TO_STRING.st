FUNCTION SYNC_IN_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SYNC_IN_MODE_TO_STRING                                       
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
  /// SyncInMode
  Value : SyncInMode;
END_VAR

  CASE Value 
  OF
  
    SyncInMode.IN_SYNC_IN_ZONE : StrReplace('IN_SYNC_IN_ZONE ({0})','{0}' , USINT_TO_STRING(Value));
    SyncInMode.AFTER_DISTANCE  : StrReplace('AFTER_DISTANCE ({0})' ,'{0}' , USINT_TO_STRING(Value));
    SyncInMode.AFTER_TIME      : StrReplace('AFTER_TIME ({0})'     ,'{0}' , USINT_TO_STRING(Value));
    SyncInMode.IMMEDIATELY     : StrReplace('IMMEDIATELY ({0})'    ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

