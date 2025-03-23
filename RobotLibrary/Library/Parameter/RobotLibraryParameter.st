{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      Parameter                                       
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
  /// Maximal amount of input data
  ROBOT_IN_DATA_MAX                   : UINT := 255; 
  /// Maximal amount of output data
  ROBOT_OUT_DATA_MAX                  : UINT := 255;
  /// Maximal amount of tools
  TOOL_MAX                            : DINT := 16;
  /// Maximal amount of frames
  FRAME_MAX                           : DINT := 16;
  /// Maximal amount of loads
  LOAD_MAX                            : DINT := 16;  
  /// Maximal amount of work areas
  WORK_AREAS_MAX                      : DINT := 16;  
  /// Maximal amount of system logs
  SYSTEM_LOG_MAX                      : DINT := 32;  
  /// Maximal amount of message logs
  MESSAGE_LOG_MAX                     : DINT := 100;  
  /// Maximal amount of List entries 
  LIST_ENTRIES_MAX                    : DINT := 100;
  /// Maximal amount of bytes for the parameter payload
  PARAMETER_PAYLOAD_MAX               : DINT := 255;  
  /// Maximal amount of bytes for the response payload
  RESPONSE_PAYLOAD_MAX                : DINT := 255;  
  /// Maximal amount of bytes that can be exchanged with the sub program on the RC
  SUB_PROGRAM_DATA_MAX                : DINT := 189;
  /// Maximal amount of spline data
  SPLINE_DATA_MAX                     : DINT := 64;
  /// Maximal amount of entries in the Active Command Register
  ACTIVE_CMD_REGISTER_ENTRIES_MAX     : DINT := 50;
  /// Maximal amount of message codes
  MESSAGE_CODES_MAX                   : DINT := 15;
  /// Maximal amount of fragments
  FRAGMENT_MAX                        : DINT := 9;
  /// Use two sequences in telegram ?
  TWO_SEQUENCES                       : BOOL := FALSE; 
  /// Flag to indicate that the byte order must be changed
  SWAP_BYTE_ORDER                     : BOOL := TRUE; 
  /// Timeout for checking for invalid frames
  INVALID_FRAMES_CHECK_TIMEOUT        : TIME := T#60S;
END_VAR


