{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadSystemVariableOutCmd                                       
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
TYPE ReadSystemVariableOutCmd :
STRUCT
  /// Unique system-generated ID of the "Action" when the function is triggered.
  /// • >0: The "Action" is started by the trigger function with identical FollowID.
  /// • <0: The "Action" is stopped by the trigger function with identical FollowID.
  /// For more information see chapter 5.5.12.4 EmitterID, ListenerID, FollowID and OriginID
  OriginID           : INT;
  /// Relates to ListenerID >0
  /// Number of successful trigger -based command invocations
  /// For more information refer to chapter 5.5.12.4.
  InvocationCounter  : USINT;
  
  /// Parameter data type as specified in Table 6-613.
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
END_STRUCT
END_TYPE


