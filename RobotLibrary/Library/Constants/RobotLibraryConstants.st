{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryConstants                                       
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
VAR_GLOBAL CONSTANT  
  /// Version of SRCI specification
  /// Bit 0-4 : Minor version = Features        (0..31)
  /// Bit 5-7 : Major version = Breaking change (0..07)
  SRCIVersion             : VersionStruct := ( MajorVersion := 1, MinorVersion := 3, PatchVersion := 0);
  /// Version of the PLC library
  PLCLibraryVersion       : VersionStruct := ( MajorVersion := 0, MinorVersion := 0, PatchVersion := 43);
  /// Minimal axes group ID
  AXES_GROUP_ID_MIN       : BYTE := 0;  
  /// Maximal axes groups ID
  AXES_GROUP_ID_MAX       : BYTE := 15;  
  /// OK = 0
  OK                      : DINT := 0;
  /// Running = 1
  RUNNING                 : DINT := 1;
  /// Null pointer
  XNULL                   : DWORD := 0;
  /// Null pointer
  NULL_POINTER            : POINTER TO BYTE := 0;
  /// Real conversion factor ( REAL * 100 -> TO_INT )
  REAL_CONVERSION_FACTOR  : REAL := 100;
  /// Active command
  ACTIVE_CMD              : UDINT := 1;
  /// Buffered command
  BUFFER_CMD              : UDINT := 2;
  /// Maximal length of additional text 
  MAX_ADD_TEXT_LENGTH     : DINT := 40;
 END_VAR


