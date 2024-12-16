{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadSystemVariableSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadSystemVariableSendData EXTENDS CmdHeader: 
STRUCT
  /// ID of Action that will be executed when this command is active
  /// • >0: Start Action - Start executing the Action function with the identical ListenerID.
  /// • <0: Stop Action  -  Stop executing the Action function with the identical ListenerID.
  /// • 0: No trigger (default)-  If no EmitterID is defined, the function will not trigger any Action during its execution
  /// For more information see section Triggers of this chapter or chapter 5.5.12.4.
  EmitterID          : ARRAY [0..3] OF SINT;
  /// ID of the trigger function that may be triggered:
  /// • 0: Immediately (default). - Start executing THIS function immediately.
  /// • >0: Triggero Start executing when the trigger function with the identical EmitterID is called.
  /// For more information see chapter 5.5.12.4.
  ListenerID         : SINT;
  /// Reserve
  Reserve            : BYTE;
  /// Defines the parameter list which should be used:
  /// • FALSE: Standardized parameter list (default):
  ///          -  Read parameters on the RC based on a standardized parameter list
  /// • TRUE: Manufacturer specific parameter list:
  ///        -  Read parameters on the RC based on robot manufacturers-specific parameter lists
  RCParameter        : BOOL;
  /// Requested parameter ID in selected parameter list.
  /// •          0: undefined (default)
  /// • 1..65 535: Parameter ID
  ParameterID        : ARRAY[0..7] OF UINT;
  /// ID of the requested sub parameter in selected parameter list.
  /// • 0: ID 0 (default) (relates only to parameters without sub parameters)
  /// • 1..255: Indices 1 to 255 (relates only to parameters with sub parameters)
  SubParameterID     : ARRAY[0..7] OF USINT;  
END_STRUCT
END_TYPE


