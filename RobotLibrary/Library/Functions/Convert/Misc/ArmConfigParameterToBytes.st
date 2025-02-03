FUNCTION ArmConfigParameterToBytes : ARRAY[0..1] of BYTE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ArmConfigParameterToBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-30
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
 Value: ArmConfigParameter;
END_VAR

  ArmConfigParameterToBytes[0].0 := Value.Shoulder.0;
  ArmConfigParameterToBytes[0].1 := Value.Shoulder.1;
  ArmConfigParameterToBytes[0].2 := Value.Shoulder.2;
  ArmConfigParameterToBytes[0].3 := Value.Shoulder.3;
  ArmConfigParameterToBytes[0].4 := Value.Elbow.0;
  ArmConfigParameterToBytes[0].5 := Value.Elbow.1;
  ArmConfigParameterToBytes[0].6 := Value.Elbow.2;
  ArmConfigParameterToBytes[0].7 := Value.Elbow.3;
  ArmConfigParameterToBytes[1].0 := Value.Wrist.0;
  ArmConfigParameterToBytes[1].1 := Value.Wrist.1;
  ArmConfigParameterToBytes[1].2 := Value.Wrist.2;
  ArmConfigParameterToBytes[1].3 := Value.Wrist.3;
  ArmConfigParameterToBytes[1].4 := FALSE;
  ArmConfigParameterToBytes[1].5 := FALSE;
  ArmConfigParameterToBytes[1].6 := FALSE;
  ArmConfigParameterToBytes[1].7 := FALSE;

END_FUNCTION

