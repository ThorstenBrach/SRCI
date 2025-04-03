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
  Payload    : ARRAY [0..RobotLibraryParameter.ROBOT_IN_DATA_MAX] OF BYTE;
END_VAR


END_FUNCTION_BLOCK

/// Resets the payload buffer, the payload pointer and the payload length
METHOD Reset
VAR_INPUT
END_VAR

  SysDepMemSet(pDest := ADR(Payload), Value := 0 , DataLen := SIZEOF(Payload));
  PayloadLen := 0;
  PayloadPtr := 0;

END_METHOD

METHOD UpdatePointer
VAR_INPUT
END_VAR

  pPayload := ADR(Payload);

END_METHOD

