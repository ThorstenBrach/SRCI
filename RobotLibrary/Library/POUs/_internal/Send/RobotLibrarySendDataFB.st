{attribute 'pack_mode' := '1'} 
FUNCTION_BLOCK RobotLibrarySendDataFB extends RobotLibrarySendDataBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibrarySendDataFB                                      
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//    
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Payload
  Payload     : POINTER TO BYTE;
  /// Size of the Payload array
  PayLoadSize : UDINT;
END_VAR


END_FUNCTION_BLOCK

/// Resets the payload buffer, the payload pointer and the payload length
METHOD Reset
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  // Reset payload buffer
  SysDepMemSet(pDest := Payload, Value := 0 , DataLen := PayLoadSize);

END_METHOD

METHOD SetLifeSignFooter
VAR_INPUT
  /// Life sign value
  LifeSign : BYTE;
END_VAR

VAR
  /// temporary 
  pLifeSign : POINTER TO BYTE;
END_VAR

  pLifeSign := Payload + PayLoadSize -1;
  
  pLifeSign^ := LifeSign;

END_METHOD

METHOD UpdatePointer
VAR_INPUT
END_VAR

  pPayload := Payload;

END_METHOD

