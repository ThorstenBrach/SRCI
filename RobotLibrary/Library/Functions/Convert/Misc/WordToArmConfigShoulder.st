FUNCTION WordToArmConfigShoulder : ArmConfigShoulder
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WordToArmConfigShoulder                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-24
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
  /// Value
  Value : WORD;
END_VAR

VAR
  _tmpByte : BYTE;
END_VAR

  IF (Value.0)
  THEN
    WordToArmConfigShoulder := ArmConfigShoulder.BACK;
  ELSE
    WordToArmConfigShoulder := ArmConfigShoulder.FRONT;  
  END_IF

END_FUNCTION

