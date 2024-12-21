FUNCTION SwapIecDate : IEC_DATE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SwapIecDate                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-09
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
VAR_INPUT
  /// Value to swap
  Value : IEC_DATE;
END_VAR

  SwapBytes(ADR(Value),SIZEOF(Value));
  
  SwapIecDate := Value;

END_FUNCTION

