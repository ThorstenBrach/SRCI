{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TriggerModeLimit                                       
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
TYPE TriggerModeLimit :
(
	/// 0: Invalid (default)
  INVALID := 0,
  /// 1: Joint current in mA
  JOINT_CURRENT := 1,
  /// 2: Force in Nm
  FORCE := 2,
  /// 3: Following error. The distance of the robot position from the path that was calculated
  FOLLOWING_ERROR := 3,
  /// Temperature in °C
  TEMPERATURE := 4  
)SINT;
END_TYPE


