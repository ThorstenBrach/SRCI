{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupAcyclicAcrEntryRspBuffer                                       
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
TYPE AxesGroupAcyclicAcrEntryRspBuffer :
STRUCT
  /// Timestamp
  Timestamp         : DT;
  ///
  State             : BufferStateRsp;
  /// Payload defined by type per CMD definition. Processed by Appl. Layer Task.
  Payload           : ARRAY[0..RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX] OF BYTE;
  /// Payload length
  PayloadLen        : UDINT;  
  /// Payload poiner   
  PayLoadPtr        : DWORD;
END_STRUCT
END_TYPE


