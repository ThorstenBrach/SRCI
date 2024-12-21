/// System dependent implementation of the memory set function 
FUNCTION SysDepMemSet : UDINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library System Dependencies                                               
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SysDepMemSet                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-21
//
//  Description:                                              
//    System specific implementation of the memory set function 
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
  /// Pointer to memory address to be filled (target)
  pDest   : POINTER TO BYTE;
  /// Value with which the memory is to be initialized
  Value   : BYTE;
  /// Amount of bytes to be initialized in the memory block
  DataLen : UDINT;  
END_VAR

  SysMemSet( pDest := pDest, udiValue := Value, udiCount := DataLen );

END_FUNCTION

