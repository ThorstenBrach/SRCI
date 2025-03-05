FUNCTION JOG_CONTROL_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      JOG_CONTROL_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-01
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
  /// JogControl
  Value : JogControl;
END_VAR

  JOG_CONTROL_TO_STRING := '2#';
  
  IF (Value.E6_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E6_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E5_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E5_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1_');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0_');
  END_IF
  
  IF (Value.E4_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E4_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E3_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E3_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '_');
  
  IF (Value.E2_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E2_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E1_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.E1_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Rz_J6_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Rz_J6_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Ry_J5_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Ry_J5_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '_');
  
  IF (Value.Rx_J4_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Rx_J4_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Z_J3_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Z_J3_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Y_J2_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.Y_J2_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.X_J1_Neg)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF
  
  IF (Value.X_J1_Pos)
  THEN
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '1');
  ELSE
    JOG_CONTROL_TO_STRING := CONCAT(JOG_CONTROL_TO_STRING, '0');
  END_IF

END_FUNCTION

