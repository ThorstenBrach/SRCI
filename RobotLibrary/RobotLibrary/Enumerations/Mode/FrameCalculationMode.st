{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FrameCalculationMode                                       
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
TYPE FrameCalculationMode :
(
  /// 0: Three-Point-method (default)
  THREE_POINT_METHOD := 0,  
  /// 1: Four-Point-method
  FOUR_POINT_METHOD := 1,  
  /// 2: One-Point-method
  ONE_POINT_METHOD := 2
)SINT;
END_TYPE


