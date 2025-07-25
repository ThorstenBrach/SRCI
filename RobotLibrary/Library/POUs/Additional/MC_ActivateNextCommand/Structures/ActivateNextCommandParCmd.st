{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActivateNextCommandParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
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
TYPE ActivateNextCommandParCmd :
STRUCT
  /// ID of the trigger function that may be triggered:
  /// • 0: Immediately (default). - Start executing THIS function immediately.
  /// • >0: Triggero Start executing when the trigger function with the identical EmitterID is called.
  /// For more information see chapter 5.5.12.4.
  ListenerID     : SINT;
END_STRUCT
END_TYPE


