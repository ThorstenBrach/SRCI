{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      InitializationState                                       
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
TYPE InitializationState :
(
  /// Default
  DEFAULT := 0,
  /// Error: Telegram control does not match the telegram state
  ERROR_TELEGRAM_CONTROL := 161,
  /// Error: Initialization lost for unknown reason. See message log after reinitializing
  ERROR_INIT_LOST := 162,
  /// Error: Telegram length does not match the length provided in the communication interface.
  ERROR_TELEGRAM_LENGTH := 163,
  /// Error: Incompatible major SRCI version
  ERROR_INCOMPATIBLE_SRCI := 164,
  /// Error: Lifesign timeout
  ERROR_LIFESIGN_TIMEOUT := 165,
  /// Error: The selected optional cyclic data does not fit in the given telegram size
  ERROR_CYCLIC_DATA_MISMATCH := 166,
  /// Error: The robot interface was reset after being initialized
  ERROR_INTERFACE_RESET := 167,
  /// Error: Telegram sequence timeout
  ERROR_SEQUENCE_TIMEOUT := 168,
  /// Error: The telegram number changed after initialization
  ERROR_TELEGRAM_NUMBER_CHANGED := 169,
  /// Error: Invalid AxesGroupID
  ERROR_INVALID_AXES_GROUP := 170,
  /// Error: Telegram number is invalid. E.g. TwoSequences is only activated in one direction
  ERROR_INVALID_TELEGRAM_NUMBER := 171,
  /// Error: Telegram Number is not supported
  ERROR_TELEGRAM_NUMBER_NOT_SUPPORTED := 172,
  /// Ready to resume: The RC is currently not initialized but has state in the ACR
  READY_TO_RESUME := 253,
  /// Ready for initialization: The RC is currently not initialized and has no state in the ACR
  READY_FOR_INITIALIZATION := 254,
  /// Initialized: The RC state is Initialized
  INITIALIZED := 255
);
END_TYPE


