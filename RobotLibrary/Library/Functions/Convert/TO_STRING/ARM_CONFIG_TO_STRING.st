FUNCTION ARM_CONFIG_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ARM_CONFIG_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-23
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
  /// ArmConfigParameter
  Value : ArmConfigParameter;
END_VAR

VAR
  /// temporary byte
 _tmpByte : BYTE;
END_VAR

  Value := Value;
  
  _tmpByte.0 := Value.Shoulder = ArmConfigShoulder.USE_CONFIG;
  _tmpByte.1 := Value.Elbow    = ArmConfigElbow   .USE_CONFIG;
  _tmpByte.2 := Value.Wrist    = ArmConfigWrist   .USE_CONFIG;
  
  ARM_CONFIG_TO_STRING := BYTE_TO_STRING_BIN(_tmpByte);

END_FUNCTION

