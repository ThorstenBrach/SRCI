FUNCTION DATE_TO_IEC_DATE : IEC_DATE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DATE_TO_IEC_DATE                                       
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
VAR_INPUT
  Value    : DATE;
END_VAR

VAR
 _tmpDate1 : DWORD;
 _tmpDate2 : DWORD;
 _initDate : DATE := DATE#1990-01-01;
 END_VAR

  /// Siemens Dateformat is Day since 01.01.1990
  /// TwinCat Dateformat is seconds sinde 01.01.1970
  /// Calculation : 
  /// ( [TwinCat current date] - [ TwinCat 01.01.1970] ) / [Seconds a Day] = Days sinde 01.01.1990 (Siemens Format)
  
  /// copy date to dword
  MemCpy( ADR(_tmpDate1), ADR( Value   ), SIZEOF( Value   ));
  /// copy date to dword
  MemCpy( ADR(_tmpDate2), ADR(_initDate), SIZEOF(_initDate));
  
  /// calculate IEC Date :  
  DATE_TO_IEC_DATE := UDINT_TO_UINT((_tmpDate1 - _tmpDate2) / 86400); // 86400 Seconds = 1 day

END_FUNCTION

