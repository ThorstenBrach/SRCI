{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadRealsOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadRobotDataOutCmd :
STRUCT
  /// RC manufacturer name
  RCManufacturer       : STRING(20);
  /// RC part number
  RCOrderID            : STRING(20);
  /// RC serial number
  RCSerialNumber       : STRING(16);
  /// RA serial number
  RASerialNumber       : STRING(16);
  /// Robot firmware version in manufacturer -specific format
  RCFirmwareVersion    : STRING(12);
  /// 
  RCInterpreterVersion : STRING(3);
  /// TRUE = Axis used in Robot FALSE = Axis NOT used. See Table 6-13 for bit assignment
  AxisJointUsed        : AxisJointUsed;
  /// TRUE = Axis used by Robot FALSE = Axis NOT used. See Table 6-13 for bit assignment.
  AxisExternalUsed     : AxisExternalUsed;
  /// TRUE = mm FALSE = ° See Table 6-13 for bit assignment.
  AxisJointUnit        : AxisJointUnit;
  /// TRUE = mm FALSE = ° See Table 6-13 for bit assignment
  AxisExternalUnit     : AxisExternalUnit;
  /// • TRUE: Function is supported by RC • FALSE: Function is not supported by RC See Table 6-14 for bit assignment.
  RCSupportedFunctions  : RCSupportedFunctions;
  /// Unique and unmodifiable identification of the RA.
  RobotID              : STRING(16);  
  /// Interpreter task cycle time of the RC [ms]
  InterpreterCycleTime : UINT;
END_STRUCT
END_TYPE


