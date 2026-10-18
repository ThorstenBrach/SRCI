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
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_GLOBAL CONSTANT
  /// Maximal amount of tools
  /// SRCI_PLC_TEST: 20 like the SDK simulator (was the parameter of the library reference)
  TOOL_MAX                            : DINT := 20;
  /// Maximal amount of frames
  /// SRCI_PLC_TEST: 20 like the SDK simulator (was the parameter of the library reference)
  FRAME_MAX                           : DINT := 20;
  /// Maximal amount of loads
  /// SRCI_PLC_TEST: 20 like the SDK simulator (was the parameter of the library reference)
  LOAD_MAX                            : DINT := 20;  
  /// Maximal amount of work areas
  WORK_AREAS_MAX                      : DINT := 16;  
  /// Maximal amount of system logs
  SYSTEM_LOG_MAX                      : DINT := 32;  
  /// Maximal amount of message logs
  MESSAGE_LOG_MAX                     : DINT := 100;  
  /// Maximum string length for message texts
  MESSAGE_TEXT_LEN                    : DINT := 255;
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
  FRAGMENT_MAX                        : DINT := 31; // ST-FIX F52: 10 fragments (0..9) per telegram are too few - a 256 byte telegram holds up to 27 fragme
  /// Flag to indicate that the byte order must be changed
  SWAP_BYTE_ORDER                     : BOOL := TRUE; 
  /// Timeout for checking for invalid frames
  INVALID_FRAMES_CHECK_TIMEOUT        : TIME := T#60S;
  /// Warning limit for ACR registers running low
  ACR_USAGE_WARNING_LIMIT             : REAL := 80.0;  
END_VAR


