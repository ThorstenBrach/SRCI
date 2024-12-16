{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceLimitOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-16
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
TYPE ForceLimitOutCmd :
STRUCT
  /// Current status of ForceControl and ForceLimit (chapter 6.5.25) according to Table 6-712
  ForceStatus        : ForceStatus;
  /// Relates to EmitterID <> 0: Unique system-generated ID of the trigger function when the function is called by user.
  /// For more information see chapter 5.5.12.4.
  FollowID           : DINT;  
END_STRUCT
END_TYPE


