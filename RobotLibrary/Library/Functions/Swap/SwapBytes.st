FUNCTION SwapBytes 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SwapBytes                                       
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
  /// pointer to data type
  pValue : POINTER TO BYTE;
  /// size of data type
  Size  : UDINT;
END_VAR

VAR
  /// Pointer to low word low byte
  _pLwLb    : POINTER TO BYTE;
  /// Pointer to low word high byte
  _pLwHb    : POINTER TO BYTE;
  /// Pointer to high word low byte
  _pHwLb    : POINTER TO BYTE;
  /// Pointer to high word high byte
  _pHwHb    : POINTER TO BYTE;  
   /// temporary bytes
  _tmpBytes : ARRAY[1..4] OF BYTE;  
END_VAR

  IF ( RobotLibraryParameter.SWAP_BYTE_ORDER AND Size = 2)
  THEN
   _pLwLb := pValue + 0;
   _pLwHb := pValue + 1;
    
    // swap bytes
   _tmpBytes[1] := _pLwHb^;
   _tmpBytes[2] := _pLwLb^;
    
    // copy bytes to data type
    SysDepMemCpy(pDest := pValue, pSrc := ADR(_tmpBytes), DataLen := Size);
  END_IF
  
  
  IF ( RobotLibraryParameter.SWAP_BYTE_ORDER AND Size = 4)
  THEN
   _pLwLb := pValue + 0;
   _pLwHb := pValue + 1;
   _pHwLb := pValue + 2;
   _pHwHb := pValue + 3;
    
    // swap bytes
   _tmpBytes[1] := _pHwHb^;
   _tmpBytes[2] := _pHwLb^;
   _tmpBytes[3] := _pLwHb^;
   _tmpBytes[4] := _pLwLb^;
    
    // copy bytes to data type
    SysDepMemCpy( pDest := pValue, pSrc := ADR(_tmpBytes), DataLen := Size);  
  END_IF

END_FUNCTION

