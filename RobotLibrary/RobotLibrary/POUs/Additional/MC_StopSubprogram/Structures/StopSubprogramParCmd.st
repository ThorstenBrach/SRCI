{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      StopSubprogramParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE StopSubprogramParCmd :
STRUCT
  /// Defines how target subprogram is defined
  StopMode          : StopMode;
  /// JobID or InstanceID of target subprogram according to selected StopMode
  /// • Refers to StopMode 0 (Stop via JobID) and 1 (Stop via InstanceID).
  /// • -1: Invalid (default)
  TargetID          : UINT;
  /// Defines the target sequence in which the command will be executed
  SequenceFlag      : SequenceFlag;
  /// ID of associated trigger function:
  /// • 0: No Trigger (default) - No trigger related behavior
  /// • >0: Triggero - Start executing when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID        : SINT;
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action  -  Stop executing the Action function with the identical ListenerID.
  /// • 0: No trigger (default)-  If no EmitterID is defined, the function will not trigger any Action during its execution
  /// For more information see section Triggers of this chapter or chapter 5.5.12.4.
  EmitterID          : ARRAY [0..3] OF SINT;  
END_STRUCT
END_TYPE


