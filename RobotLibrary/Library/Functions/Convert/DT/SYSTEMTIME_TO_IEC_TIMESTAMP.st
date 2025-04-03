FUNCTION SYSTEMTIME_TO_IEC_TIMESTAMP : IEC_TIMESTAMP
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SYSTEMTIME_TO_IEC_TIMESTAMP                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-30
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
  SystemTime : SystemTime;
END_VAR

  SYSTEMTIME_TO_IEC_TIMESTAMP.IEC_DATE := DATE_TO_IEC_DATE(SystemTime.SystemDate);
  SYSTEMTIME_TO_IEC_TIMESTAMP.IEC_TIME := TIME_TO_IEC_TIME(SystemTime.SystemTime);

END_FUNCTION

