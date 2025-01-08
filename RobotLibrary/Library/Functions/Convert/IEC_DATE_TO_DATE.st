FUNCTION IEC_DATE_TO_DATE : DATE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      IEC_DATE_TO_DATE                                       
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
  Value    : IEC_DATE;
END_VAR

VAR
 _tmpDate1 : DWORD;
 _initDate : DATE := DATE#1990-01-01;
 END_VAR

  // Siemens Dateformat is Day since 01.01.1990
  // TwinCat Dateformat is seconds sinde 01.01.1970
  // Calculation : 
  // ( [ TwinCat 01.01.1990] + [IEC Date]) * [Seconds a Day] = (TwinCat Format)
  
  // copy date to dword
  SysDepMemCpy( pDest := ADR(_tmpDate1), pSrc := ADR( _initDate ), DataLen := SIZEOF( _initDate ));
  
  // calculate IEC Date :  
  IEC_DATE_TO_DATE := DWORD_TO_DATE( _tmpDate1 + ( Value * 86400)); // 86400 Seconds = 1 day

END_FUNCTION

