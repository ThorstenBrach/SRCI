{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExecutionModeAllowed                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
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
TYPE ExecutionModeAllowed :
STRUCT
  ///
  PRIMARY_SEQ         : BOOL;
  ///
  PRIMARY_SEQ_ABORT   : BOOL;
  ///
  SECONDARY_SEQ       : BOOL;
  ///
  SECONDARY_SEQ_ABORT : BOOL;
  ///
  PAR                 : BOOL := TRUE;
  ///
  PAR_TASK            : BOOL;
  ///
  PAR_TRIGGER         : BOOL;
  ///
  PAR_TRIGGER_TASK    : BOOL;
END_STRUCT
END_TYPE


