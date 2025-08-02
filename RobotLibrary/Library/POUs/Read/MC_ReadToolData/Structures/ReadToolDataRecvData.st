{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadToolDataRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadToolDataRecvData EXTENDS RspHeader :
STRUCT
  /// Reserve
  Reserve       : BYTE;
  /// Tool index
  ToolNoReturn  : USINT;
  /// Tool data (see chapter 5.5.6.3)
  ToolData      : ToolData;
  /// The status bit "DataChanged" represents the modification state 
  DataChanged   : BOOL;
END_STRUCT
END_TYPE


