{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteIntegersParCmd                                       
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
TYPE WriteIntegersParCmd :
STRUCT
  /// Specifies the desired target values that shall be written
  Index              : ARRAY[0..6] OF USINT; 
  /// Array value of integers
  Values             : ARRAY[0..6] OF INT;
  /// Set TRUE to prioritize the execution of this command in the defined target sequence.
  HighPriority       : BOOL;
  /// ID of associated trigger function:
  /// •  0: No Trigger (default)  No trigger related behavior
  /// • >0: Trigger - Start executing when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID         : SINT;
END_STRUCT
END_TYPE

