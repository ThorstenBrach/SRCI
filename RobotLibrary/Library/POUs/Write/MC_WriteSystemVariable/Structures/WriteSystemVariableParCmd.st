{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteSystemVariableParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-08
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
TYPE WriteSystemVariableParCmd :
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
  /// Parameter data type as specified in Table 6-621.
  DataType           : ARRAY[0..7] OF USINT;
  /// Parameter data addressed by input values of ParameterID[0] and SubParameterID[0]
  Data_0             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[1] and SubParameterID[1]
  Data_1             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[2] and SubParameterID[2]
  Data_2             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[3] and SubParameterID[3]
  Data_3             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[4] and SubParameterID[4]
  Data_4             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[5] and SubParameterID[5]
  Data_5             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[6] and SubParameterID[6]
  Data_6             : ARRAY[0..3] OF BYTE;
  /// Parameter data addressed by input values of ParameterID[7] and SubParameterID[7]
  Data_7             : ARRAY[0..3] OF BYTE;
  /// ID of associated trigger function:
  /// •  0: No Trigger (default)  No trigger related behavior
  /// • >0: Trigger - Start executing when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID         : SINT;
END_STRUCT
END_TYPE


