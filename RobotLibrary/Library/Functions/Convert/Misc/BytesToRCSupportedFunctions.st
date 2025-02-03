FUNCTION BytesToRCSupportedFunctions : RCSupportedFunctions
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      BytesToRCSupportedFunctions                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-18
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
  Bytes : ARRAY [0..18] OF BYTE;
END_VAR

  // Byte 00 - Bit 0  
  BytesToRCSupportedFunctions.Reserved                   := Bytes[00].0;
  // Byte 00 - Bit 1 
  BytesToRCSupportedFunctions.ReadRobotData              := Bytes[00].1;
  // Byte 00 - Bit 2  
  BytesToRCSupportedFunctions.EnableRobot                := Bytes[00].2;
  // Byte 00 - Bit 3  
  BytesToRCSupportedFunctions.GroupReset                 := Bytes[00].3;
  // Byte 00 - Bit 4  
  BytesToRCSupportedFunctions.ReadActualPosition         := Bytes[00].4;
  // Byte 00 - Bit 5 
  BytesToRCSupportedFunctions.ReadActualPositionCyclic   := Bytes[00].5;
  // Byte 00 - Bit 6  
  BytesToRCSupportedFunctions.ExchangeConfiguration      := Bytes[00].6;
  // Byte 00 - Bit 7  
  BytesToRCSupportedFunctions.SetSequence                := Bytes[00].7;
  
  // Byte 01 - Bit 0  
  BytesToRCSupportedFunctions.ChangeSpeedOverride        := Bytes[01].0;
  // Byte 01 - Bit 1  
  BytesToRCSupportedFunctions.ReadMessages               := Bytes[01].1;
  // Byte 01 - Bit 2  
  BytesToRCSupportedFunctions.ReadRobotReferenceDynamics := Bytes[01].2;
  // Byte 01 - Bit 3  
  BytesToRCSupportedFunctions.WriteFrameData             := Bytes[01].3;
  // Byte 01 - Bit 4  
  BytesToRCSupportedFunctions.WriteToolData              := Bytes[01].4;
  // Byte 01 - Bit 5  
  BytesToRCSupportedFunctions.WriteLoadData              := Bytes[01].5;
  // Byte 01 - Bit 6  
  BytesToRCSupportedFunctions.WriteRobotReferenceDynamics:= Bytes[01].6;
  // Byte 01 - Bit 7  
  BytesToRCSupportedFunctions.WriteRobotDefaultDynamics  := Bytes[01].7;
  
  // Byte 02 - Bit 0  
  BytesToRCSupportedFunctions.ReadRobotDefaultDynamics   := Bytes[02].0;
  // Byte 02 - Bit 1  
  BytesToRCSupportedFunctions.ReadFrameData              := Bytes[02].1;
  // Byte 02 - Bit 2  
  BytesToRCSupportedFunctions.ReadToolData               := Bytes[02].2;
  // Byte 02 - Bit 3  
  BytesToRCSupportedFunctions.ReadLoadData               := Bytes[02].3;
  // Byte 02 - Bit 4  
  BytesToRCSupportedFunctions.ReadRobotSWLimits          := Bytes[02].4;
  // Byte 02 - Bit 5  
  BytesToRCSupportedFunctions.GroupJog                   := Bytes[02].5;
  // Byte 02 - Bit 6  
  BytesToRCSupportedFunctions.MoveLinearAbsolute         := Bytes[02].6;
  // Byte 02 - Bit 7  
  BytesToRCSupportedFunctions.MoveDirectAbsolute         := Bytes[02].7;
  
  // Byte 03 - Bit 0  
  BytesToRCSupportedFunctions.MoveAxesAbsolute           := Bytes[03].0;
  // Byte 03 - Bit 1  
  BytesToRCSupportedFunctions.GroupStop                  := Bytes[03].1;
  // Byte 03 - Bit 2
  BytesToRCSupportedFunctions.GroupContinue              := Bytes[03].2;
  // Byte 03 - Bit 3
  BytesToRCSupportedFunctions.GroupInterrupt             := Bytes[03].3;
  // Byte 03 - Bit 4
  BytesToRCSupportedFunctions.ReturnToPrimary            := Bytes[03].4;
  // Byte 03 - Bit 5
  BytesToRCSupportedFunctions.MoveLinearAbsoluteJ        := Bytes[03].5;
  // Byte 03 - Bit 6
  BytesToRCSupportedFunctions.MoveDirectRelative         := Bytes[03].6;
  // Byte 03 - Bit 7
  BytesToRCSupportedFunctions.MoveAxesRelative           := Bytes[03].7;
  
  // Byte 04 - Bit 0
  BytesToRCSupportedFunctions.MoveCircularAbsolute       := Bytes[04].0;
  // Byte 04 - Bit 1
  BytesToRCSupportedFunctions.MoveCircularRelative       := Bytes[04].1;
  // Byte 04 - Bit 2
  BytesToRCSupportedFunctions.MoveLinearOffset           := Bytes[04].2;
  // Byte 04 - Bit 3
  BytesToRCSupportedFunctions.MoveDirectOffset           := Bytes[04].3;
  // Byte 04 - Bit 4
  BytesToRCSupportedFunctions.WaitTime                   := Bytes[04].4;
  // Byte 04 - Bit 5
  BytesToRCSupportedFunctions.ReadDigitalInputs          := Bytes[04].5;
  // Byte 04 - Bit 6
  BytesToRCSupportedFunctions.ReadDigitalOutputs         := Bytes[04].6;
  // Byte 04 - Bit 7
  BytesToRCSupportedFunctions.WriteDigitalOutputs        := Bytes[04].7;
  
  // Byte 05 - Bit 0
  BytesToRCSupportedFunctions.ReadIntegers               := Bytes[05].0;
  // Byte 05 - Bit 1
  BytesToRCSupportedFunctions.ReadReals                  := Bytes[05].1;
  // Byte 05 - Bit 2
  BytesToRCSupportedFunctions.WriteIntegers              := Bytes[05].2;
  // Byte 05 - Bit 3
  BytesToRCSupportedFunctions.WriteReals                 := Bytes[05].3;
  // Byte 05 - Bit 4
  BytesToRCSupportedFunctions.MoveLinearCam              := Bytes[05].4;
  // Byte 05 - Bit 5
  BytesToRCSupportedFunctions.MoveDirectCam              := Bytes[05].5;
  // Byte 05 - Bit 6
  BytesToRCSupportedFunctions.MoveCircularCam            := Bytes[05].6;
  // Byte 05 - Bit 7
  BytesToRCSupportedFunctions.SetTriggerRegister         := Bytes[05].7;
  
  // Byte 06 - Bit 0
  BytesToRCSupportedFunctions.SetTriggerLimit            := Bytes[06].0;
  // Byte 06 - Bit 1
  BytesToRCSupportedFunctions.SetTriggerUser             := Bytes[06].1;
  // Byte 06 - Bit 2
  BytesToRCSupportedFunctions.SetTriggerError            := Bytes[06].2;
  // Byte 06 - Bit 3
  BytesToRCSupportedFunctions.ReactAtTrigger             := Bytes[06].3;
  // Byte 06 - Bit 4
  BytesToRCSupportedFunctions.WaitForTrigger             := Bytes[06].4;
  // Byte 06 - Bit 5
  BytesToRCSupportedFunctions.ReadSystemVariable         := Bytes[06].5;
  // Byte 06 - Bit 6
  BytesToRCSupportedFunctions.WriteSystemVariable        := Bytes[06].6;
  // Byte 06 - Bit 7
  BytesToRCSupportedFunctions.CalculateForwardKinematic  := Bytes[06].7;
  
  // Byte 07 - Bit 0
  BytesToRCSupportedFunctions.CalculateInverseKinematic  := Bytes[07].0;
  // Byte 07 - Bit 1
  BytesToRCSupportedFunctions.CalculateCartesianPosition := Bytes[07].1;
  // Byte 07 - Bit 2
  BytesToRCSupportedFunctions.CalculateTool              := Bytes[07].2;
  // Byte 07 - Bit 3
  BytesToRCSupportedFunctions.CalculateFrame             := Bytes[07].3;
  // Byte 07 - Bit 4
  BytesToRCSupportedFunctions.ActivateNextCommand        := Bytes[07].4;
  // Byte 07 - Bit 5
  BytesToRCSupportedFunctions.ShiftPosition              := Bytes[07].5;
  // Byte 07 - Bit 6
  BytesToRCSupportedFunctions.CallSubprogram             := Bytes[07].6;
  // Byte 07 - Bit 7
  BytesToRCSupportedFunctions.MoveLinearRelative         := Bytes[07].7;
  
  // Byte 08 - Bit 0
  BytesToRCSupportedFunctions.WriteCallSubprogramCyclic  := Bytes[08].0;
  // Byte 08 - Bit 1
  BytesToRCSupportedFunctions.ReadCallSubprogramCyclic   := Bytes[08].1;
  // Byte 08 - Bit 2
  BytesToRCSupportedFunctions.StopSubprogram             := Bytes[08].2;
  // Byte 08 - Bit 3
  BytesToRCSupportedFunctions.ReadDHParameter            := Bytes[08].3;
  // Byte 08 - Bit 4
  BytesToRCSupportedFunctions.RestartController          := Bytes[08].4;
  // Byte 08 - Bit 5
  BytesToRCSupportedFunctions.ReadActualTCPVelocity      := Bytes[08].5;
  // Byte 08 - Bit 6
  BytesToRCSupportedFunctions.UserLogin                  := Bytes[08].6;
  // Byte 08 - Bit 7
  BytesToRCSupportedFunctions.SwitchLanguage             := Bytes[08].7;
  
  // Byte 09 - Bit 0
  BytesToRCSupportedFunctions.WriteRobotSWLimits         := Bytes[09].0;
  // Byte 09 - Bit 1
  BytesToRCSupportedFunctions.SetOperationMode           := Bytes[09].1;
  // Byte 09 - Bit 2
  BytesToRCSupportedFunctions.ReadWorkArea               := Bytes[09].2;
  // Byte 09 - Bit 3
  BytesToRCSupportedFunctions.WriteWorkArea              := Bytes[09].3;
  // Byte 09 - Bit 4
  BytesToRCSupportedFunctions.ActivateWorkArea           := Bytes[09].4;
  // Byte 09 - Bit 5
  BytesToRCSupportedFunctions.MonitorWorkArea            := Bytes[09].5;
  // Byte 09 - Bit 6
  BytesToRCSupportedFunctions.MoveApproachLinear         := Bytes[09].6;
  // Byte 09 - Bit 7
  BytesToRCSupportedFunctions.MoveDepartLinear           := Bytes[09].7;
  
  // Byte 10 - Bit 0
  BytesToRCSupportedFunctions.MoveApproachDirect         := Bytes[10].0;
  // Byte 10 - Bit 1
  BytesToRCSupportedFunctions.MoveDepartDirect           := Bytes[10].1;
  // Byte 10 - Bit 2
  BytesToRCSupportedFunctions.SearchHardstop             := Bytes[10].2;
  // Byte 10 - Bit 3
  BytesToRCSupportedFunctions.SearchHardstopJ            := Bytes[10].3;
  // Byte 10 - Bit 4
  BytesToRCSupportedFunctions.MovePickPlaceLinear        := Bytes[10].4;
  // Byte 10 - Bit 5
  BytesToRCSupportedFunctions.MovePickPlaceDirect        := Bytes[10].5;
  // Byte 10 - Bit 6
  BytesToRCSupportedFunctions.ActivateConveyorTracking   := Bytes[10].6;
  // Byte 10 - Bit 7
  BytesToRCSupportedFunctions.RedefineTrackingPosition   := Bytes[10].7;
  
  // Byte 11 - Bit 0
  BytesToRCSupportedFunctions.SyncToConveyor             := Bytes[11].0;
  // Byte 11 - Bit 1
  BytesToRCSupportedFunctions.ConfigureConveyor          := Bytes[11].1;
  // Byte 11 - Bit 2
  BytesToRCSupportedFunctions.MoveSuperImposed           := Bytes[11].2;
  // Byte 11 - Bit 3
  BytesToRCSupportedFunctions.MoveSuperImposedDynamic    := Bytes[11].3;
  // Byte 11 - Bit 4
  BytesToRCSupportedFunctions.ReadAnalogInput            := Bytes[11].4;
  // Byte 11 - Bit 5
  BytesToRCSupportedFunctions.ReadAnalogOutput           := Bytes[11].5;
  // Byte 11 - Bit 6
  BytesToRCSupportedFunctions.WriteAnalogOutput          := Bytes[11].6;
  // Byte 11 - Bit 7
  BytesToRCSupportedFunctions.MeasuringInput             := Bytes[11].7;
  
  // Byte 12 - Bit 0
  BytesToRCSupportedFunctions.AbortMeasuringInput        := Bytes[12].0;
  // Byte 12 - Bit 1
  BytesToRCSupportedFunctions.SetTriggerMotion           := Bytes[12].1;
  // Byte 12 - Bit 2
  BytesToRCSupportedFunctions.OpenBrake                  := Bytes[12].2;
  // Byte 12 - Bit 3
  BytesToRCSupportedFunctions.PathAccuracyMode           := Bytes[12].3;
  // Byte 12 - Bit 4
  BytesToRCSupportedFunctions.AvoidSingularity           := Bytes[12].4;
  // Byte 12 - Bit 5
  BytesToRCSupportedFunctions.ForceControl               := Bytes[12].5;
  // Byte 12 - Bit 6
  BytesToRCSupportedFunctions.ForceLimit                 := Bytes[12].6;
  // Byte 12 - Bit 7
  BytesToRCSupportedFunctions.ReadActualForce            := Bytes[12].7;
  
  // Byte 13 - Bit 0
  BytesToRCSupportedFunctions.BrakeTest                  := Bytes[13].0;
  // Byte 13 - Bit 1
  BytesToRCSupportedFunctions.SoftSwitchTCP              := Bytes[13].1;
  // Byte 13 - Bit 2
  BytesToRCSupportedFunctions.CreateSpline               := Bytes[13].2;
  // Byte 13 - Bit 3
  BytesToRCSupportedFunctions.DeleteSpline               := Bytes[13].3;
  // Byte 13 - Bit 4
  BytesToRCSupportedFunctions.MoveSpline                 := Bytes[13].4;
  // Byte 13 - Bit 5
  BytesToRCSupportedFunctions.DynamicSpline              := Bytes[13].5;
  // Byte 13 - Bit 6
  BytesToRCSupportedFunctions.LoadMeasurementAutomatic   := Bytes[13].6;
  // Byte 13 - Bit 7
  BytesToRCSupportedFunctions.LoadMeasurementSequential  := Bytes[13].7;
  
  // Byte 14 - Bit 0
  BytesToRCSupportedFunctions.CollisionDetection         := Bytes[14].0;
  // Byte 14 - Bit 1
  BytesToRCSupportedFunctions.FreeDrive                  := Bytes[14].1;
  // Byte 14 - Bit 2
  BytesToRCSupportedFunctions.UnitMeasurement            := Bytes[14].2;
  // Byte 14 - Bit 3
  BytesToRCSupportedFunctions.Byte14Bit03                := Bytes[14].3;
  // Byte 14 - Bit 4
  BytesToRCSupportedFunctions.Byte14Bit04                := Bytes[14].4;
  // Byte 14 - Bit 5
  BytesToRCSupportedFunctions.Byte14Bit05                := Bytes[14].5;
  // Byte 14 - Bit 6
  BytesToRCSupportedFunctions.Byte14Bit06                := Bytes[14].6;
  // Byte 14 - Bit 7
  BytesToRCSupportedFunctions.Byte14Bit07                := Bytes[14].7;
  
  // Byte 15 - Bit 0
  BytesToRCSupportedFunctions.Byte15Bit00                := Bytes[15].0;
  // Byte 15 - Bit 1
  BytesToRCSupportedFunctions.Byte15Bit01                := Bytes[15].1;
  // Byte 15 - Bit 2
  BytesToRCSupportedFunctions.Byte15Bit02                := Bytes[15].2;
  // Byte 15 - Bit 3
  BytesToRCSupportedFunctions.Byte15Bit03                := Bytes[15].3;
  // Byte 15 - Bit 4
  BytesToRCSupportedFunctions.Byte15Bit04                := Bytes[15].4;
  // Byte 15 - Bit 5
  BytesToRCSupportedFunctions.Byte15Bit05                := Bytes[15].5;
  // Byte 15 - Bit 6
  BytesToRCSupportedFunctions.Byte15Bit06                := Bytes[15].6;
  // Byte 15 - Bit 7
  BytesToRCSupportedFunctions.Byte15Bit07                := Bytes[15].7;
  
  // Byte 16 - Bit 0
  BytesToRCSupportedFunctions.Byte16Bit00                := Bytes[16].0;
  // Byte 15 - Bit 1
  BytesToRCSupportedFunctions.Byte16Bit01                := Bytes[16].1;
  // Byte 15 - Bit 2
  BytesToRCSupportedFunctions.Byte16Bit02                := Bytes[16].2;
  // Byte 15 - Bit 3
  BytesToRCSupportedFunctions.Byte16Bit03                := Bytes[16].3;
  // Byte 15 - Bit 4
  BytesToRCSupportedFunctions.Byte16Bit04                := Bytes[16].4;
  // Byte 15 - Bit 5
  BytesToRCSupportedFunctions.Byte16Bit05                := Bytes[16].5;
  // Byte 15 - Bit 6
  BytesToRCSupportedFunctions.Byte16Bit06                := Bytes[16].6;
  // Byte 15 - Bit 7
  BytesToRCSupportedFunctions.Byte16Bit07                := Bytes[16].7;
  
  // Byte 17 - Bit 0
  BytesToRCSupportedFunctions.Byte17Bit00                := Bytes[17].0;
  // Byte 17 - Bit 1
  BytesToRCSupportedFunctions.Byte17Bit01                := Bytes[17].1;
  // Byte 17 - Bit 2
  BytesToRCSupportedFunctions.Byte17Bit02                := Bytes[17].2;
  // Byte 17 - Bit 3
  BytesToRCSupportedFunctions.Byte17Bit03                := Bytes[17].3;
  // Byte 17 - Bit 4
  BytesToRCSupportedFunctions.Byte17Bit04                := Bytes[17].4;
  // Byte 17 - Bit 5
  BytesToRCSupportedFunctions.Byte17Bit05                := Bytes[17].5;
  // Byte 17 - Bit 6
  BytesToRCSupportedFunctions.Byte17Bit06                := Bytes[17].6;
  // Byte 17 - Bit 7
  BytesToRCSupportedFunctions.Byte17Bit07                := Bytes[17].7;
  
  // Byte 18 - Bit 0
  BytesToRCSupportedFunctions.Byte18Bit00                := Bytes[18].0;
  // Byte 18 - Bit 1
  BytesToRCSupportedFunctions.Byte18Bit01                := Bytes[18].1;
  // Byte 18 - Bit 2
  BytesToRCSupportedFunctions.Byte18Bit02                := Bytes[18].2;
  // Byte 18 - Bit 3
  BytesToRCSupportedFunctions.Byte18Bit03                := Bytes[18].3;
  // Byte 18 - Bit 4
  BytesToRCSupportedFunctions.Byte18Bit04                := Bytes[18].4;
  // Byte 18 - Bit 5
  BytesToRCSupportedFunctions.Byte18Bit05                := Bytes[18].5;
  // Byte 18 - Bit 6
  BytesToRCSupportedFunctions.Byte18Bit06                := Bytes[18].6;
  // Byte 18 - Bit 7
  BytesToRCSupportedFunctions.Byte18Bit07                := Bytes[18].7;

END_FUNCTION

