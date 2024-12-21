/// System dependent implementation of the memory compare function 
FUNCTION SysDepMemCmp : DINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library System Dependencies                                               
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SysDepMemCmp                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-21
//
//  Description:                                              
//    System specific implementation of the memory compare function 
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
  /// Pointer to 1st memory area to be compared with the 2nd memory area
  pData1  : POINTER TO BYTE;
  /// Pointer to 2nd memory area to be compared with the 1st memory area
  pData2  : POINTER TO BYTE;
  /// Amount of bytes to be compared
  DataLen : UDINT;  
END_VAR

  SysDepMemCmp := SysMemCmp( pBuffer1 := pData1, pBuffer2 := pData2, udiCount := DataLen );

END_FUNCTION

