{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerErrorSendData                                       
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
TYPE SetTriggerErrorSendData EXTENDS CmdHeader: 
STRUCT
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action  -  Stop executing the Action function with the identical ListenerID.
  /// • 0: No trigger (default)-  If no EmitterID is defined, the function will not trigger any Action during its execution
  /// For more information see section Triggers of this chapter or chapter 5.5.12.4.
  EmitterID                  : ARRAY [0..3] OF SINT;  
  /// ID of associated trigger function:
  /// • 0: Immediately (default) - Start executing this function immediately.
  /// • >0: Trigger -  Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID                 : SINT;
  /// Reserve
  Reserve                    : SINT;
  /// Defines error origin through which the associated Action will be triggered
  Mode                       : SINT;
  /// Defines if parametrization messages are included (relates to Mode 0 to 5)
  /// • FALSE (default): Do not include incorrect parametrization
  /// • TRUE: Include incorrect parametrization
  IncludeParameterValidation : BOOL;
  /// Defines message codes through which the associated Action will be triggered (relates to Mode 6 and 7)
  MessageCodes               : ARRAY [0..RobotLibraryParameter.MESSAGE_CODES_MAX] OF DWORD;  
END_STRUCT
END_TYPE


