{attribute 'pack_mode' := '1'} 
FUNCTION_BLOCK RobotLibraryRecvDataFB EXTENDS RobotLibraryRecvDataBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryRecvDataFB                                       
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
  /// Payload
  Payload    : POINTER TO BYTE;
  /// Size of the Payload array
  PayLoadSize : UDINT;
END_VAR


END_FUNCTION_BLOCK

METHOD GetLifeSignFooter : BYTE
VAR
  /// temporary 
  pLifeSign : POINTER TO BYTE;
END_VAR

  pLifeSign := Payload + PayLoadSize -1;
  
  
  GetLifeSignFooter := GetHalfeByteHi(pLifeSign^);

END_METHOD

METHOD UpdatePointer
VAR_INPUT
END_VAR

  pPayload := Payload;

END_METHOD

