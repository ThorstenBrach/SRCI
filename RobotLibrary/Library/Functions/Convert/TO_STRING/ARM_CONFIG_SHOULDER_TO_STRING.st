FUNCTION ARM_CONFIG_SHOULDER_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ARM_CONFIG_SHOULDER_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-04
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
  /// ArmConfigShoulder
  Value : ArmConfigShoulder;
END_VAR

  CASE Value 
  OF
    ArmConfigShoulder.USE_CONFIG : ARM_CONFIG_SHOULDER_TO_STRING := StrReplace('Shoulder = USE_CONFIG ({0})','{0}' , INT_TO_STRING(Value));
    ArmConfigShoulder.SAME       : ARM_CONFIG_SHOULDER_TO_STRING := StrReplace('Shoulder = SAME ({0})'      ,'{0}' , INT_TO_STRING(Value));
    ArmConfigShoulder.FREE       : ARM_CONFIG_SHOULDER_TO_STRING := StrReplace('Shoulder = FREE ({0})'      ,'{0}' , INT_TO_STRING(Value));
    ArmConfigShoulder.BACK       : ARM_CONFIG_SHOULDER_TO_STRING := StrReplace('Shoulder = BACK ({0})'      ,'{0}' , INT_TO_STRING(Value));
    ArmConfigShoulder.FRONT      : ARM_CONFIG_SHOULDER_TO_STRING := StrReplace('Shoulder = FRONT ({0})'     ,'{0}' , INT_TO_STRING(Value));
  ELSE
    ARM_CONFIG_SHOULDER_TO_STRING := CONCAT('ARM_CONFIG_SHOULDER_TO_STRING Function: Error -> no parsing for value ', INT_TO_STRING(Value));
  END_CASE

END_FUNCTION

