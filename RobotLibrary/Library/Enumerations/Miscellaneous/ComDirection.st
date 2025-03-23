{attribute 'qualified_only'}
{attribute 'strict'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ComDirection                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-23
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
TYPE ComDirection :
(
  // communication direction PLC to Robot
	PLC_TO_ROB := 0,
  // communication direction Robot to PLC
	ROB_TO_PLC := 1  
);
END_TYPE


