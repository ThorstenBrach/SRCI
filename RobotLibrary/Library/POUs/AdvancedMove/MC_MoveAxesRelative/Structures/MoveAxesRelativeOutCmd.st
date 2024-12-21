{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveAxesRelativeOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-07-03
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
TYPE MoveAxesRelativeOutCmd :
STRUCT
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress           : REAL;
  /// Unique system-generated ID of the trigger function when the function is called by the user.
  /// For more information see chapter 5.5.12.4.
  FollowID           : DINT;
END_STRUCT
END_TYPE


