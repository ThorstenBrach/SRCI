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

  ARM_CONFIG_TO_STRING := '';
  ARM_CONFIG_TO_STRING := CONCAT(ARM_CONFIG_TO_STRING , ARM_CONFIG_SHOULDER_TO_STRING(Value.Shoulder));
  ARM_CONFIG_TO_STRING := CONCAT(ARM_CONFIG_TO_STRING ,' ; ');
  ARM_CONFIG_TO_STRING := CONCAT(ARM_CONFIG_TO_STRING , ARM_CONFIG_ELBOW_TO_STRING(Value.Elbow));
  ARM_CONFIG_TO_STRING := CONCAT(ARM_CONFIG_TO_STRING ,' ; ');
  ARM_CONFIG_TO_STRING := CONCAT(ARM_CONFIG_TO_STRING , ARM_CONFIG_WRIST_TO_STRING(Value.Wrist));

END_FUNCTION

