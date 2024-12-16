{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerLimitSendData                                       
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
TYPE SetTriggerLimitSendData EXTENDS CmdHeader: 
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
  /// If the tolerance limits for the respective actual data values from the RC are exceeded, the Action function that will be executed.
  /// For "TriggerMode" 1, 2 and 4 the tolerance limits must be entered as follows:
  /// • [0..5]: relates to axes 1 to 6
  /// • [6..11]: relates to external axes 1 to 6.
  /// For "TriggerMode" 3 the tolerance limits must be entered as follows:
  /// • [0]: Following Error in mm.
  /// • [1..11]: Undefined and not relevant.
  /// For all array entries default: 999999
  Data_1                 : ARRAY[0..11] OF REAL;
  /// If the respective actual data values from the RC are under the defined limit, the Action function will be stopped.
  /// For "TriggerMode" 1, 2 and 4 the tolerance limits must be entered as follows:
  /// • [0..5]: relates to axes 1 to 6.
  /// • [6..11]: relates to external axes 1 to 6.
  /// For "TriggerMode" 3 the tolerance limits must be entered as follows:
  /// • [0]: Following Error in mm.
  /// • [1..11]: Undefined and not relevant.
  /// For all array entries default: 999999
  Data_2                 : ARRAY[0..11] OF REAL;
  /// Specifies the trigger event by exceeding of the following limit values (one of the following options must be supported)
  TriggerMode            : SINT;
  /// Determines whether the start condition is evaluated or not.
  /// • FALSE: Start condition is not evaluated (default).
  /// • TRUE: Start condition is evaluated
  EvaluateStartCondition : BOOL;
END_STRUCT
END_TYPE


