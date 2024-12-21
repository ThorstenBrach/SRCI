{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      StepMode                                       
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
TYPE StepMode :
(
  /// StepMode is deactivated
  DEACTIVATE := 0,
  /// Blending
  /// • The robot moves on the blended trajectory
  /// • The movement is interrupted when the active segment changes
  BLENDING := 1,
  ///Exact stop
  /// • The robot moves to the defined target positions without blending
  /// • The movement is interrupted when the defined target position is reached
  EXACT_STOP := 2
)USINT;
END_TYPE


