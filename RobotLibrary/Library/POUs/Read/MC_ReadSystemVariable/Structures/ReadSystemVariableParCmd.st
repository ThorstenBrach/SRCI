{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadSystemVariableParCmd                                       
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
TYPE ReadSystemVariableParCmd :
STRUCT
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
  /// ID of associated trigger function:
  /// •  0: No Trigger (default)  No trigger related behavior
  /// • >0: Trigger - Start executing when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID         : SINT;  
END_STRUCT
END_TYPE


