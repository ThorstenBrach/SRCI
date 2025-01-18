FUNCTION PlcOptionalCyclicToUint : UINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      PlcOptionalCyclicToUint                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-30
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
  OptionalCyclic : AxesGroupParameterPlcOptionalCyclic;
END_VAR

  PlcOptionalCyclicToUint.00 := OptionalCyclic.UseCallSubprogram;
  PlcOptionalCyclicToUint.01 := OptionalCyclic.UseCartesianPosition;
  PlcOptionalCyclicToUint.02 := OptionalCyclic.UseJointPosition;
  PlcOptionalCyclicToUint.03 := OptionalCyclic.UseForce;
  PlcOptionalCyclicToUint.04 := OptionalCyclic.Bit04;
  PlcOptionalCyclicToUint.05 := OptionalCyclic.Bit05;
  PlcOptionalCyclicToUint.06 := OptionalCyclic.Bit06;
  PlcOptionalCyclicToUint.07 := OptionalCyclic.Bit07;  
  PlcOptionalCyclicToUint.08 := OptionalCyclic.UseTwoSequences;
  PlcOptionalCyclicToUint.09 := OptionalCyclic.UseCartesianPositionExt;
  PlcOptionalCyclicToUint.10 := OptionalCyclic.UseJointPositionExt;
  PlcOptionalCyclicToUint.11 := OptionalCyclic.Bit11;
  PlcOptionalCyclicToUint.12 := OptionalCyclic.Bit12;
  PlcOptionalCyclicToUint.13 := OptionalCyclic.Bit13;
  PlcOptionalCyclicToUint.14 := OptionalCyclic.Bit14;
  PlcOptionalCyclicToUint.15 := OptionalCyclic.Bit15;

END_FUNCTION

