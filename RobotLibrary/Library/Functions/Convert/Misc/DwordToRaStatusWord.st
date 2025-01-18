FUNCTION DwordToRaStatusWord : RaStatusWord
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DwordToRaStatusWord                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-16
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
  Value : DWORD;
END_VAR

  DwordToRaStatusWord.IsMoving                 := Value.00;
  DwordToRaStatusWord.PrimarySequencePaused    := Value.01;
  DwordToRaStatusWord.InPrimaryPos             := Value.02;
  DwordToRaStatusWord.SecondarySequenceActive  := Value.03;
  DwordToRaStatusWord.IsBlending               := Value.04;
  DwordToRaStatusWord.ErrorPending             := Value.05;
  DwordToRaStatusWord.RestartInProgress        := Value.06;
  DwordToRaStatusWord.Enabled                  := Value.07;
  DwordToRaStatusWord.RaSequenceState.0        := Value.08;
  DwordToRaStatusWord.RaSequenceState.1        := Value.09;
  DwordToRaStatusWord.OperationMode.0          := Value.10;
  DwordToRaStatusWord.OperationMode.1          := Value.11;
  DwordToRaStatusWord.OperationMode.2          := Value.12;
  DwordToRaStatusWord.CollisionDetectedEnabled := Value.13;
  DwordToRaStatusWord.CollisionDetected        := Value.14;
  DwordToRaStatusWord.RestartRequested         := Value.15;
  DwordToRaStatusWord.Accelerating             := Value.16;
  DwordToRaStatusWord.Decelerating             := Value.17;
  DwordToRaStatusWord.ConstantVelocity         := Value.18;
  DwordToRaStatusWord.Bit19                    := Value.19;
  DwordToRaStatusWord.Bit20                    := Value.20;
  DwordToRaStatusWord.Bit21                    := Value.21;
  DwordToRaStatusWord.Bit22                    := Value.22;
  DwordToRaStatusWord.Bit23                    := Value.23;
  DwordToRaStatusWord.Bit24                    := Value.24;
  DwordToRaStatusWord.Bit25                    := Value.25;
  DwordToRaStatusWord.Bit26                    := Value.26;
  DwordToRaStatusWord.Bit27                    := Value.27;
  DwordToRaStatusWord.Bit28                    := Value.28;
  DwordToRaStatusWord.Bit29                    := Value.29;
  DwordToRaStatusWord.Bit30                    := Value.30;
  DwordToRaStatusWord.Bit31                    := Value.31;

END_FUNCTION

