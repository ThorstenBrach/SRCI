{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ErrorTriggerMode                                       
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
TYPE ErrorTriggerMode :
(
  /// Any command (default)
  ANY_COMMAND := 0,
  /// General commands
  GENERAL_COMMANDS := 1,
  /// Administrative commands
  ADMINISTRATIVE_COMMANDS := 2,
  /// Move commands
  MOVE_COMMANDS := 3,
  /// Periphery commands
  PERIPHERY_COMMANDS := 4,
  /// Extended commands
  EXTENDED_COMMANDS := 5,
  /// Specific command or RI message
  SPECIFIC_COMMAND_OR_RI_MESSAGE := 6,
  /// Specific RC or RA message code
  SPECIFIC_RC_OR_RA_MESSAGE_CODE := 7,
  /// Any RI message code
  ANY_RI_MESSAGE_CODE := 8,
  /// Any RC or RA message code
  ANY_RC_OR_RA_MESSAGE_CODE := 9
)SINT;
END_TYPE


