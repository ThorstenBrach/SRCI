{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerUserSendData                                       
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
TYPE SetTriggerUserSendData EXTENDS CmdHeader: 
STRUCT
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action  -  Stop executing the Action function with the identical ListenerID.
  /// • 0: No trigger (default)-  If no EmitterID is defined, the function will not trigger any Action during its execution
  /// For more information see section Triggers of this chapter or chapter 5.5.12.4.
  EmitterID              : ARRAY [0..3] OF SINT;  
  /// ID of associated trigger function:
  /// • 0: Immediately (default) - Start executing this function immediately.
  /// • >0: Trigger -  Start executing, when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID             : SINT;
  /// Reserve
  Reserve                : SINT;
  /// Reference integer value, for triggering the Action function with the EmitterID.
  /// • Relates to "TriggerMode" 50-57
  IntValue               : ARRAY[1..2] OF INT;
  /// Reference real value, analog input or output value, for triggering the Action function with the EmitterID.
  /// • Relates to "TriggerMode" 30-37, 40-47,60-67
  RealValue              : ARRAY[1..2] OF REAL;
  /// Specifies the trigger event according to Table 6-574.
  /// For more information about registers on the RC see chapters 6.4.4 and 6.4.5.
  TriggerMode            : SINT;
  /// Depending on "TriggerMode":
  /// • Digital (refers to "TriggerMode" 10-13, 20-23): Specifies the desired byte address of the input or output signal that shall be read.
  /// • Analog/Integer/Real (refers to "TriggerMode" 30-37, 40-47, 50-57, 60- 67): Specifies the target values that shall be read.
  /// For more information about registers refer to Figure 6-206.
  Index                  : USINT;
  /// Depending on "TriggerMode":
  /// • Digital (refers to TriggerMode 10-13,20-23): Specifies the desired bit address of the input or output signal that shall be read.
  /// • Analog/Integer/Real (refers to TriggerMode 30-37, 40-47, 50-57, 60- 67): Not relevant and deactivated for user input.
  /// For more information about registers refer to Figure 6-206
  BitIndex               : USINT;
END_STRUCT
END_TYPE


