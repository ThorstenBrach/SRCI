FUNCTION SYNC_TIME_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SYNC_TIME_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-04-13
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
  /// SyncTime
  Value : SyncTime;
END_VAR

  CASE Value 
  OF
    SyncTime.DURING_START_UP : SYNC_TIME_TO_STRING := StrReplace('DURING_START_UP ({0})','{0}' , DINT_TO_STRING(Value));
    SyncTime.AFTER_START_UP  : SYNC_TIME_TO_STRING := StrReplace('AFTER_START_UP ({0})' ,'{0}' , DINT_TO_STRING(Value));
  ELSE
    SYNC_TIME_TO_STRING := CONCAT('SYNC_TIME_TO_STRING Function: Error -> no parsing for value ', DINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

