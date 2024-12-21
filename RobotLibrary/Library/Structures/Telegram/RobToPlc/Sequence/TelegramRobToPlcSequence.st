{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramPlcToRobSequence                                       
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
TYPE TelegramRobToPlcSequence :
STRUCT
  /// Header
  Header   : TelegramRobToPlcSequenceHeader;
  /// Fragment
  Fragment : ARRAY[0..9] OF TelegramRobToPlcFragment;
END_STRUCT
END_TYPE


