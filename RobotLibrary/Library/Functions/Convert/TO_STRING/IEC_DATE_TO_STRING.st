FUNCTION IEC_DATE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      IEC_DATE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-01
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
  /// IEC Date
  Value : IEC_DATE;
END_VAR

VAR
  /// temporary date
 _tmpData : DATE;
END_VAR

  IEC_DATE_TO_STRING := DATE_TO_STRING(IEC_DATE_TO_DATE(Value));

END_FUNCTION

