{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteRobotSWLimitsSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-08
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
TYPE WriteRobotSWLimitsSendData EXTENDS CmdHeader: 
STRUCT
  /// Limits for joints and external axes according to Table 6-180.
  LimitValues            : SWLimits;
  /// Reset limits to RC specific factory settings
  ResetToFactoryDefaults : BOOL;;
END_STRUCT
END_TYPE

