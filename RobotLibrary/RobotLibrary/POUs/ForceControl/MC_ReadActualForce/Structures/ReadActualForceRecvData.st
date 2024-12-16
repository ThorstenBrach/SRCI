{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualForceRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
TYPE ReadActualForceRecvData EXTENDS RspHeader :
STRUCT
  InvocationCounter : USINT;
  /// Reserve
  Reserved          : SINT;
  /// Unique system-generated ID of the "Action" when the function is triggered.
  /// • >0: The "Action" is started by the trigger funcrion with identical FollowID.
  /// • <0: The "Action" is stopped by the trigger function with identical FollowID.
  /// For more information see chapter 5.5.12.4 EmitterID, ListenerID, FollowID and OriginID
  OriginID          : INT;
  /// Currently detected force and torque according to ReferenceType, ToolNo and FrameNo.
  /// • [0]: X-Axis
  /// • [1]: Y-Axis
  /// • [2]: Z- Axis
  /// • [3]: Rotation around X-Axis (RX)
  /// • [4]: Rotation around Y-Axis (RY)
  /// • [5]: Rotation around Z- Axis (RZ)
  ActualForce       : ARRAY[0..5] OF REAL;
END_STRUCT
END_TYPE


