{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadWorkAreaRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadWorkAreaRecvData EXTENDS RspHeader :
STRUCT
  /// Reserve
  Reserve          : BYTE;
  /// Index of the robot work area
  WorkAreaNoReturn : USINT;
  /// Data specific to the work area requested by Index.
  WorkAreaData     : RobotWorkAreaData;
  /// The status bit "DataChanged" represents the modification state 
  DataChanged      : BOOL;
END_STRUCT
END_TYPE


