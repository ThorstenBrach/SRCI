{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramRobToPlc                                       
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
TYPE TelegramRobToPlc :
STRUCT
  /// Telegram Header
  Header               : TelegramRobToPlcHeader;
  /// Cyclic optional data
  CyclicOptional       : TelegramRobToPlcCyclicOptionalData;
  /// Sequence Data
  Sequence             : ARRAY[0..1] OF TelegramRobToPlcSequence;
  /// Footer
  Footer               : TelegramRobToPlcFooter;
END_STRUCT
END_TYPE


