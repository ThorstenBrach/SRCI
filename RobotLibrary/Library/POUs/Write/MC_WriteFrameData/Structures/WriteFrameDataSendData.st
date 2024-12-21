{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteFrameDataSendData                                       
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
TYPE WriteFrameDataSendData EXTENDS CmdHeader: 
STRUCT
  /// Reserve
  Reserve            : BYTE;
  /// Frame data (see chapter 5.5.6.2)
  FrameData          : FrameData;
  /// Frame index M
  /// • 0: WCS (default) O
  /// • 1..254: UCS (User frames)
  FrameNo            : USINT;
END_STRUCT
END_TYPE


