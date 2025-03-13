FUNCTION TRAJECTORY_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TRAJECTORY_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// TrajectoryMode
  Value : TrajectoryMode;
END_VAR

  CASE Value 
  OF
    TrajectoryMode.INVALID          : TRAJECTORY_MODE_TO_STRING := StrReplace('INVALID ({0})'         ,'{0}' , USINT_TO_STRING(Value));
    TrajectoryMode.LINEAR_MOVEMENT  : TRAJECTORY_MODE_TO_STRING := StrReplace('LINEAR_MOVEMENT ({0})' ,'{0}' , USINT_TO_STRING(Value));
    TrajectoryMode.PTP_MOVEMENT     : TRAJECTORY_MODE_TO_STRING := StrReplace('PTP_MOVEMENT ({0})'    ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    TRAJECTORY_MODE_TO_STRING := CONCAT('TRAJECTORY_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

