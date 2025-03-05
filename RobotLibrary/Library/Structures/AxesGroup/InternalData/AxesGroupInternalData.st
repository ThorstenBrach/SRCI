{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroup                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-28
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
TYPE AxesGroupInternalData :
STRUCT
  /// Current System Time
  SystemTime           : SystemTime;
    /// • TRUE: Function is supported by RC • FALSE: Function is not supported by RC See Table 6-14 for bit assignment.
  //RCSupportedFunctions : RCSupportedFunctions;
  
  RobotData            : ReadRobotDataOutCmd;
  
  /// Online Change detected
  OnlineChange         : BOOL;  
  /// Rising edge for Online Change detected
  OnlineChange_R       : R_TRIG;  
  /// Falling edge for Online Change detected
  OnlineChange_F       : F_TRIG;  
  /// GroupReset active
  GroupReset           : BOOL; 
  /// Rising edge for GroupReset
  GroupReset_R         : R_TRIG;  
  /// Falling edge for GroupReset
  GroupReset_F         : F_TRIG;
  /// Counter of sequences to send
  SequenceCountSend    : DINT;
  /// Counter of sequences received
  SequenceCountRecv    : DINT;
  /// Counter of fragments to send
  FragmentCountSend    : ARRAY[0..1] OF DINT;
  /// Counter of fragments received
  FragmentCountRecv    : ARRAY[0..1] OF DINT;
  /// Current Sequence ID
  CurrentSEQ           : ARRAY[0..1] OF UINT;
  /// Current acknowledge ID
  CurrentACK           : ARRAY[0..1] OF UINT;  
  /// Current Sequence ID has changed -> send new data 
  NewSEQ               : ARRAY[0..1] OF BOOL;
  /// Last received acknowledge ID
  LastACK              : ARRAY[0..1] OF UINT;  
END_STRUCT
END_TYPE


