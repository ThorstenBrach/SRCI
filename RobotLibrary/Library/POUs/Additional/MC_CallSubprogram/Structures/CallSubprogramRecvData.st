{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CallSubprogramRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-03
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
TYPE CallSubprogramRecvData EXTENDS RspHeader :
STRUCT
  /// Relates to ListenerID >0
  /// Number of successful trigger-based command invocations - For more information refer TO chapter 5.5.12.4
  InvocationCounter : USINT;  
  /// Reserve
  Reserve           : SINT;
  /// Unique system-generated ID of the "Action" when the function is triggered.
  /// • >0: The "Action" is started by the trigger funcrion with identical FollowID.
  /// • <0: The "Action" is stopped by the trigger function with identical FollowID.
  /// For more information see chapter 5.5.12.4 EmitterID, ListenerID, FollowID and OriginID
  OriginID          : INT;
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress          : UINT;
  /// The requested subprogram on the RC is in progress. Movement of the axes trough this subprogram is possible.
  InProgress        : BOOL;
  /// Acyclic output parameters of the subprogram Array length adjusts to transmitted data (max 190 bytes)
  ReturnData        : ARRAY[0..RobotLibraryParameter.SUB_PROGRAM_DATA_MAX] OF BYTE;  
END_STRUCT
END_TYPE


