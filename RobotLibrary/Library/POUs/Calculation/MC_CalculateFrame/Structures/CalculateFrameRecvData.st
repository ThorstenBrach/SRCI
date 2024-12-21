{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CalculateFrameRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
TYPE CalculateFrameRecvData EXTENDS RspHeader :
STRUCT
  /// Date
  IEC_Date       : IEC_DATE;
  /// Time
  IEC_TIME       : IEC_TIME;
  /// Index of frame on which the calculated frame is depending
  /// •      0: WCS (default)
  /// • 1..254: User frames
  ReferenceFrame : USINT;
  /// Reserve
  Reserve        : BYTE;
  /// Position
  Position       : RobotCartesianPositionBase;
END_STRUCT
END_TYPE


