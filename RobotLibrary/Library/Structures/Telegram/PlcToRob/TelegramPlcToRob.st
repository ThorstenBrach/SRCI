{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramPlcToRob                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE TelegramPlcToRob :
STRUCT
  /// Header
  Header         : TelegramPlcToRobHeader;
  /// Cyclic optional data
  Cyclic         : TelegramPlcToRobCyclicData;
  /// Cyclic optional data
  CyclicOptional : TelegramPlcToRobCyclicOptionalData;
  /// Sequence Data
  Sequence       : ARRAY[0..1] OF TelegramPlcToRobSequence;
  /// Footer
  Footer         : TelegramPlcToRobFooter;
END_STRUCT
END_TYPE


