/// System dependent implementation of the memory copy function 
FUNCTION SysDepMemCpy : UDINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library System Dependencies                                               
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SysDepMemCpy                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-21
//
//  Description:                                              
//    System specific implementation of the memory copy function 
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
  /// Pointer to memory address to be copied to (target)
  pDest : POINTER TO BYTE;
  /// Pointer to memory address to be copied from (source)
  pSrc  : POINTER TO BYTE;
  /// Amount of bytes to be copied
  DataLen : UDINT;  
END_VAR

  SysMemCpy( pDest := pDest, pSrc := pSrc, udiCount := DataLen );

END_FUNCTION

