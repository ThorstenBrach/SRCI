{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RspHeader                                       
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
TYPE RspHeader :  
STRUCT
  /// Parameter Sequence, used to identify sets of CMD parameter - For more information see chapter 5.6.4
  ParSeq               : USINT;
  /// Actual state of the command - For more information and examples, see chapter 5.6.3.2
  State                : CmdMessageState;
  /// Severity of returned message according to .Table 5-47.
  AlarmMessageSeverity : Severity;
  /// Message code for error/warning/info identification reported during execution of command according to
  /// • Error: Table 7-1
  /// • Warning: Table 7-3
  /// • Info: Table 7-5
  AlarmMessageCode     : UINT;  
END_STRUCT
END_TYPE


