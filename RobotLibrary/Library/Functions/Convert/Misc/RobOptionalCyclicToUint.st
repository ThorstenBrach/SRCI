FUNCTION RobOptionalCyclicToUint : UINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobOptionalCyclicToUint                                       
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
  OptionalCyclic : AxesGroupParameterRobOptionalCyclic;
END_VAR

  RobOptionalCyclicToUint.00 := OptionalCyclic.UseCallSubprogram;      
  RobOptionalCyclicToUint.01 := OptionalCyclic.UseCartesianPosition;   
  RobOptionalCyclicToUint.02 := OptionalCyclic.UseJointPosition;       
  RobOptionalCyclicToUint.03 := OptionalCyclic.UseForce;               
  RobOptionalCyclicToUint.04 := OptionalCyclic.UseCurrent;             
  RobOptionalCyclicToUint.05 := OptionalCyclic.Bit05;                  
  RobOptionalCyclicToUint.06 := OptionalCyclic.Bit06;                  
  RobOptionalCyclicToUint.07 := OptionalCyclic.Bit07;                  
  RobOptionalCyclicToUint.08 := OptionalCyclic.UseTwoSequences;        
  RobOptionalCyclicToUint.09 := OptionalCyclic.UseCartesianPositionExt;
  RobOptionalCyclicToUint.10 := OptionalCyclic.UseJointPositionExt;    
  RobOptionalCyclicToUint.11 := OptionalCyclic.UseForceExt;            
  RobOptionalCyclicToUint.12 := OptionalCyclic.UseCurrentExt;          
  RobOptionalCyclicToUint.13 := OptionalCyclic.Bit13;                  
  RobOptionalCyclicToUint.14 := OptionalCyclic.Bit14;                  
  RobOptionalCyclicToUint.15 := OptionalCyclic.Bit15;

END_FUNCTION

