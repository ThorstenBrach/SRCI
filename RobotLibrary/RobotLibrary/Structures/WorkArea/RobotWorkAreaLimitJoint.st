{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotWorkAreaLimitJoint                                       
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
TYPE RobotWorkAreaLimitJoint :
STRUCT
  /// Relates to AreaType Axes. 
  /// Negative work area limit for Joint
  /// • 0 (default) : No work area restriction of joint if lower and upper limit are set to 0  
  /// • 16#FFFF_FFFF: No lower work area restrictions for Joint
  LowerLimit : REAL := 0;
  /// Relates to AreaType Axes. 
  /// positive work area limit for Joint
  /// • 0 (default) : No work area restriction of joint if lower and upper limit of are set to 0  
  /// • 16#FFFF_FFFF: No lower work area restrictions for Joint
  UpperLimit : REAL := 0;  
END_STRUCT
END_TYPE


