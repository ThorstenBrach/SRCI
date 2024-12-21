{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupAcyclicAcrEntryCmdHeader                                       
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
TYPE AxesGroupAcyclicAcrEntryCmdHeader :
STRUCT
  /// Byte 00-01 :  CMD type as per specification
  CmdType      : CmdType;
  /// Byte 02  : ExecutionMode (Bit 0..3)
  ExecMode     : ExecutionMode;  
  /// Byte 03 : CMD priority (Bit 0..3)
  Prio         : PriorityLevel;
  /// Byte 03 : Parameter Sequence (Bit 4..7 )
  ParSeq       : BYTE;
END_STRUCT
END_TYPE


