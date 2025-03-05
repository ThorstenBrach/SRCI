{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      UnitLimitAxis                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-23
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

TYPE UnitLimitAxis :
(
  /// Percentage (%) (default)
	PERCENTAGE  := 0,
  /// Newton meter (Nm)
  NEWTONMETER := 1,
  /// Milliampere (mA)
  MILLIAMPERE := 2  
)USINT;
END_TYPE


