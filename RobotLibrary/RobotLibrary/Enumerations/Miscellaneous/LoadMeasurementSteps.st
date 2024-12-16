{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementSteps                                       
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
TYPE LoadMeasurementSteps :
(
  /// • 0: Reset (default)
  /// Delete all positions saved on the RC
  RESET := 0,  
  /// • 1: First position
  /// Save the first position for the load estimation with the required data
  FIRST_POSITION := 1,  
  /// • 2: Second position
  /// Save the second position for the load estimation with the required data
  SECOND_POSITION := 2,  
  /// • 3: Third position
  /// Save the third position for the load estimation with the required data
  THIRD_POSITION := 3,  
  /// • 4: Fourth position
  /// Save the fourth position for the load estimation with the required data
  FOURTH_POSITION := 4,  
  /// • 99: Load calculation
  /// Start the load calculation with the data saved in the four positions
  LOAD_CALCULATION := 99
)USINT;
END_TYPE


