{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetTriggerMotionParCmd                                       
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
TYPE SetTriggerMotionParCmd :
STRUCT
  ///Defines the trigger condition on which the related Action function will be started:
  TriggerMode_1          : TriggerCondition;
  /// This parameter depends on the input parameter "TriggerMode_1":
  /// • 1: Distance value of trajectory in %.
  /// • 2: Distance value of trajectory in mm.
  /// • 3: TCP velocity value of reference velocity in %
  /// • 4: TCP velocity value of reference velocity in mm.
  /// • 5: Time in ms
  /// The value of the parameter must be positive  
  TriggerParameter_1     : REAL;
  ///Defines the trigger condition on which the related Action function will be started:
  TriggerMode_2          : TriggerCondition;
  /// This parameter depends on the input parameter "TriggerMode_1":
  /// • 1: Distance value of trajectory in %. 
  /// • 2: Distance value of trajectory in mm.
  /// • 3: TCP velocity value of reference velocity in %
  /// • 4: TCP velocity value of reference velocity in mm.
  /// • 5: Time in ms
  /// The value of the parameter must be positive  
  TriggerParameter_2     : REAL;
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


