{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupAcyclicAcrEntry                                       
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
TYPE AxesGroupAcyclicAcrEntry :
STRUCT
  /// Unique indentifier 
  UniqueID   : UINT; 
  /// State of the command entry
  State      : ActiveCommandRegisterState;  
  /// Command data ( 1 = DataToSend 2 = DataInBuffer )
  Command    : ARRAY[1..2] OF AxesGroupAcyclicAcrEntryCmdBuffer;
  /// response data ( 1 = DataRecv 2 = DataInRecvBuffer )
  Response   : ARRAY[1..2] OF AxesGroupAcyclicAcrEntryRspBuffer;
  /// Pointer to the corresponding command-FB to enable a callback mechanism
  pCommandFB : POINTER TO RobotLibraryBaseFB;
END_STRUCT
END_TYPE


