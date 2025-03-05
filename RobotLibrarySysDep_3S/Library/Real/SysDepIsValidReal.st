FUNCTION SysDepIsValidReal : BOOL
// ------------------------------------------------------------------------- 
//  SRCI Robot Library System Dependencies                                               
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SysDepIsValidReal                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-04
//
//  Description:                                              
//    System specific implementation of the REAL validation 
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
	/// Real value to validate
	Value: REAL;
END_VAR

  SysDepIsValidReal := FPU.IsRealNumber(Value);

END_FUNCTION

