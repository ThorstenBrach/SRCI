{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SequenceFlag                                       
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
TYPE SequenceFlag :
(
  /// • Refers to ProcessingModes 2 to 5 and 9 (2 = Parallel, 3 = Continuous, 4 = not available, 5 = Trigger Multiple, 9 = Deactivate )
  /// • Command is not handled by any sequence
  /// • For more information on ProcessingModes refer to chapter 5.6.4.5
	NO_SEQUENCE := 0,
  /// • Command will be handled by primary sequence
  PRIMARY_SEQUENCE := 1,
  /// • Command will be handled by secondary sequence
  SECONDARY_SEQUENCE := 2
)USINT;
END_TYPE


