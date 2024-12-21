{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramPlcToRobFragmentHeader                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-02
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
TYPE TelegramRobToPlcFragmentHeader :
STRUCT
  /// Command Instance Identifier used to assign the CMD payload to a specific CMD instance
  CmdID          : UINT;
  /// Empty reserve byte
  Reserve        : BYTE;
  /// Fragment Action Byte
  FragmentAction : BYTE;
  /// Append received payload in the receive buffer at this position
  PayloadPointer : UINT;
  /// Length of the CMD payload
  PayloadLength  : UINT;  
END_STRUCT
END_TYPE


