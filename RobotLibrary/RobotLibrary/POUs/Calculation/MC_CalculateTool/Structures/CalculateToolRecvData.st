{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateToolRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
TYPE CalculateToolRecvData EXTENDS RspHeader :
STRUCT
  /// Maximum error of deviation of the TCP position
  /// from the fix point in world coordinate system
  /// If not supported: • -1
  TCPMaxError       : REAL;
  /// Average error of TCP position from the fix point  in world coordinate system
  /// If not supported: • -1 
  TCPMeanError      : REAL;
  /// Tool data
  ToolData           : ToolData;
END_STRUCT
END_TYPE


