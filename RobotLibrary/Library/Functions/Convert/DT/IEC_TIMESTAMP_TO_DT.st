FUNCTION IEC_TIMESTAMP_TO_DT : DT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TIME_TO_IEC_TIME                                       
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

  _date := IEC_DATE_TO_DATE(Value.IEC_DATE); 
  _time := IEC_TIME_TO_TIME(Value.IEC_TIME); 
  
  
  // Example : DATE#2025-1-5
  _dateStr := DATE_TO_STRING(_date);
  // Example : DT#2025-1-5
  _dateStr := strReplace(_dateStr, 'D#', 'DT#');
  
  // Example : TOD#15:18:4.567
  _timeStr :=  TOD_TO_STRING(_time);
  // Example : -15:18:4.567
  _timeStr := strReplace(_timeStr, 'TOD#', '-');
  
  // Example : DT#2025-1-5-15:18:4.567
  IEC_TIMESTAMP_TO_DT := STRING_TO_DT( Concat(_dateStr,_timeStr));

END_FUNCTION

