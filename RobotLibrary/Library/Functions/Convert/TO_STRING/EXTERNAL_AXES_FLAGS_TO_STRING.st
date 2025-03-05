FUNCTION EXTERNAL_AXES_FLAGS_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      EXTERNAL_AXES_FLAGS_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-26
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
  /// ExternalAxesFlags
  Value : ExternalAxesFlags;
END_VAR

VAR
 _tmpByte : BYTE;
END_VAR

  _tmpByte.0 := Value.Bit00;
  _tmpByte.1 := Value.AxisE1;
  _tmpByte.2 := Value.AxisE2;
  _tmpByte.3 := Value.AxisE3;
  _tmpByte.4 := Value.AxisE4;
  _tmpByte.5 := Value.AxisE5;
  _tmpByte.6 := Value.AxisE6;
  _tmpByte.7 := Value.Bit07;
  
  
  EXTERNAL_AXES_FLAGS_TO_STRING := BYTE_TO_STRING_BIN(_tmpByte);

END_FUNCTION

