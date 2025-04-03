FUNCTION IEC_TIMESTAMP_TO_SYSTEMTIME : SystemTime
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      IEC_TIMESTAMP_TO_SYSTEMTIME                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-05
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
  Value : IEC_TIMESTAMP;
END_VAR

VAR
  /// internal date
 _date    : DATE;
  /// internal date as string
 _dateStr : STRING;
  /// internal time
 _time    : TOD;
  /// internal time as string
 _timeStr : STRING;
END_VAR

  IEC_TIMESTAMP_TO_SYSTEMTIME.SystemDate := IEC_DATE_TO_DATE(Value.IEC_DATE);
  IEC_TIMESTAMP_TO_SYSTEMTIME.SystemTime := IEC_TIME_TO_TIME(Value.IEC_TIME);

END_FUNCTION

