{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      EnableRobotParCmd                                       
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
TYPE EnableRobotParCmd :
STRUCT
  /// The robot will move while HoldToRun is set TRUE
  HoldToRun  : BOOL;
  /// While activated the RI state switches to interrupted when a buffered command returns Done TRUE
  /// At least one of the optional modes must be supported
  StepMode   : StepMode;
  /// Relates to StepMode 1 (Blending) and 2 (Exact stop)
  /// Start the next buffered command with the rising edge in T1 External or T2 External
  ManualStep : BOOL;  
END_STRUCT
END_TYPE


