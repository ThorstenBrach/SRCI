{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerErrorParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-03
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
TYPE SetTriggerErrorParCmd :
STRUCT
  /// Defines error origin through which the associated Action will be triggered
  Mode                   : ErrorTriggerMode;
  /// Defines message codes through which the associated Action will be triggered (relates to Mode 6 and 7)
  MessageCodes           : ARRAY [0..RobotLibraryParameter.MESSAGE_CODES_MAX] OF DWORD;
  /// Defines if parametrization messages are included (relates to Mode 0 to 5)
  /// • FALSE (default): Do not include incorrect parametrization
  /// • TRUE: Include incorrect parametrization
  IncludeParameterValidation : BOOL;
  /// ID of associated trigger function:
  /// • 0: Immediately (default) - Start executing this function immediately.
  /// • >0: Trigger -  Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID             : SINT;
  /// ID of the Action function that will be executed when the trigger condition is met
  /// • >0: Start Action        - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action         - Stop executing the Action function with the identical ListenerID.
  /// •  0: Undefined (default) - If no EmitterID is defined, the function returns an error message
  /// For more information see chapter 5.5.12.4
  EmitterID              : SINT;  
END_STRUCT
END_TYPE


