{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupCyclicPlcToRob                                       
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
TYPE AxesGroupCyclicPlcToRob :
STRUCT
  /// Version of SRCI specification
  /// Bit 0-4 : Minor version = Features        (0..31)
  /// Bit 5-7 : Major version = Breaking change (0..07)
  SRCIVersion            : VersionStruct;
  /// Fast stop trigger 
  FastStop               : BYTE;
  /// Connection alive signal
  LifeSign               : BYTE;
  /// Number of Bytes of the frame to be used for the telegram of the given Axisgroup. Direction client to server
  TelegramLengthPlcToRob : UINT;
  /// Number of Bytes of the frame to be used for the telegram of the given Axisgroup. Direction server to client
  TelegramLengthRobToPlc : UINT;
  /// Control AxesGroupID Telegtam state control
  AxesGroupID            : BYTE;
  /// Telegram state control
  Control                : ControlHalfByte;
  /// Reserved for later versions
  Reserved               : BYTE;
  /// Configuration of the optional cyclic data. Direction client to server
  TelegramNumberPlcToRob : UINT;
  /// Configuration of the optional cyclic data. Direction server to client
  TelegramNumberRobToPlc : UINT;
  /// Date of the client in the format days since 1990.01.01
  ClientDate             : IEC_DATE;
  /// Time in the clients time zone in the format milliseconds since start of day
  ClientTime             : IEC_TIME;    
  ///Index of tool of returned position
  /// •     -1: Currently used tool on RC
  /// •      0: Flange (default)
  /// • 1..254: Tool frames
  ToolNo                 : INT;
  /// Index of frame of returned position
  /// •     -1: Currently used frame on RC
  /// •      0: WCS (default)
  /// • 1..254: User frames
  FrameNo                : INT;
END_STRUCT
END_TYPE


