{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WaitTimeParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-30
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
TYPE WaitTimeParCmd :
STRUCT
  /// Duration [ms] of the waiting time. The value of the parameter must be positive
  WaitTime           : UDINT;
END_STRUCT
END_TYPE


