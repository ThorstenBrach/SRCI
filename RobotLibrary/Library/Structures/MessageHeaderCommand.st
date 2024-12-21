{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MessageHeaderCommand                                       
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
TYPE MessageHeaderCommand :
STRUCT
  /// Byte 00-01 :  CMD type as per specification
  CmdType      : CmdType;
  /// Byte 02  : ExecutionMode (Bit 0..3)
  ExecMode     : BYTE;  
  /// Byte 03 : CMD priority (Bit 0..3)
  Prio         : BYTE;
  /// Byte 03 : Parameter Sequence (Bit 4..7 )
  ParSeq       : BYTE;
  /// Trigger related EmitterID
  EmitterID    : ARRAY[0..3] OF SINT;
  /// Trigger related ListenerID 
  ListenerID   : SINT;
  /// Reserved
  Reserved     : BYTE;
  //// Payload length defined by type per CMD definition. Processed by Appl. Layer Task.
  Payload      : ARRAY[0..RobotLibraryParameter.TELEGRAM_PAYLOAD_MAX] OF BYTE;  
END_STRUCT
END_TYPE


