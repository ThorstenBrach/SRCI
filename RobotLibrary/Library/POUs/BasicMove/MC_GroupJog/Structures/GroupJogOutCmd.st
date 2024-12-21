{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      GroupJogOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-17
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
TYPE GroupJogOutCmd :
STRUCT
  /// Relates to Incremental mode ON: TRUE, when robot’s TCP or axes have traversed distance of "IncrementalTranslation" or "IncrementalRotation"
  DistanceReached : BOOL;
  /// The command takes control of the motion of the according axis group
  MotionActive    : BOOL;  
END_STRUCT
END_TYPE


