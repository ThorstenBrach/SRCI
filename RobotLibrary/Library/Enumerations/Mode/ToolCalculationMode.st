{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ToolCalculationMode                                       
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
TYPE ToolCalculationMode :
(
  /// 0: Two Point + Z-Method (default)
  TWO_POINT_Z_METHOD := 0,        
  /// 1: Three-Point-Method
  THREE_POINT_METHOD := 1,        
  /// 2: Four-Point-Method
  FOUR_POINT_METHOD := 2,        
  /// 3: Five-Point-Method
  FIVE_POINT_METHOD := 3,        
  /// 4: Six-Point-Method
  SIX_POINT_METHOD := 4,        
  /// 5: ABC-World-Method
  ABC_WORLD_METHOD := 5,        
  /// 6: ABC-Two-Point-Method
  ABC_TWO_POINT_METHOD := 6
)SINT;
END_TYPE


