{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupCyclicRobToPlc                                       
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
TYPE AxesGroupCyclicRobToPlc :
STRUCT
  /// Version of SRCI specification
  /// Bit 0-4 : Minor version = Features        (0..31)
  /// Bit 5-7 : Major version = Breaking change (0..07)
  SRCIVersion   : VersionStruct;
  /// Connection alive signal
  LifeSign      : BYTE;
  /// Reserved byte
  Reserved      : BYTE;
  /// Initialization and Telegram control state
  TelegramState : TelegramState;
  /// Combination of various RA related states.
  StatusRobotArm: RaStatusWord;
  /// Actual override in percentage encoding 
  Override      : UINT;  
END_STRUCT
END_TYPE


