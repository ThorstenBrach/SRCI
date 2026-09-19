{attribute 'pack_mode' := '1'} 
FUNCTION_BLOCK RobotLibraryCommandDataFB EXTENDS RobotLibrarySendDataBaseFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotLibraryCommandDataFB                                      
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-29
//
//  Description:                                              
//    
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
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
  Payload : ARRAY [0.. RobotLibraryParameter.PARAMETER_PAYLOAD_MAX] OF BYTE;
END_VAR


END_FUNCTION_BLOCK

/// Resets the payload buffer, the payload pointer and the payload length
METHOD Reset
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  // Reset payload buffer
  SysDepMemSet(pDest := ADR(Payload), Value := 0 , DataLen := SIZEOF(Payload));

END_METHOD

METHOD UpdatePointer
VAR_INPUT
END_VAR

  pPayload := ADR(Payload);

END_METHOD

