/// Read the actual position cyclically
FUNCTION_BLOCK MC_ReadActualPositionCyclicFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadActualPositionCyclicFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
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
  /// command parameter 
  ParCmd   : ReadActualPositionCyclicParCmd;
END_VAR

VAR_OUTPUT
  /// command outputs
  OutCmd   : ReadActualPositionCyclicOutCmd;       
END_VAR

VAR
  /// internal copy of command parameter 
 _parCmd   : ReadActualPositionCyclicParCmd;
END_VAR

  SUPER^(AxesGroup := AxesGroup);

END_FUNCTION_BLOCK

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'MC_ReadActualPositionCyclicFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  IF ( _enable_R.Q )  
  THEN
   _parCmd := ParCmd;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPosition    := _parCmd.ReadCartesianPosition;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPositionExt := _parCmd.ReadCartesianPositionExt;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPosition        := _parCmd.ReadJointPosition;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPositionExt     := _parCmd.ReadJointPositionExt;
  END_IF
  
  IF ( _enable_F.Q )  
  THEN
    AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPosition    := FALSE;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseCartesianPositionExt := FALSE;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPosition        := FALSE;
    AxesGroup.Parameter.Rob.OptionalCyclic.UseJointPositionExt     := FALSE;
  END_IF
  
   
  Enabled := AxesGroup.State.ConfigExchanged; {warning 'ToDo'}
  
  Busy := (Enabled <> Enable); 
  
  
  // update flags
  OutCmd.ReadingCartesianPosition    := Enabled AND _parCmd.ReadCartesianPosition;
  OutCmd.ReadingCartesianPositionExt := Enabled AND _parCmd.ReadCartesianPosition;
  OutCmd.ReadingJointPosition        := Enabled AND _parCmd.ReadCartesianPosition;
  OutCmd.ReadingJointPositionExt     := Enabled AND _parCmd.ReadCartesianPosition;
  
  // Update values
  OutCmd.CartesianPosition    := AxesGroup.CyclicOptional.RobToPlc.CartesianPosition;        
  OutCmd.CartesianPositionExt := AxesGroup.CyclicOptional.RobToPlc.CartesianPositionExt;         
  OutCmd.JointPosition        := AxesGroup.CyclicOptional.RobToPlc.JointPosition;        
  OutCmd.JointPositionExt     := AxesGroup.CyclicOptional.RobToPlc.JointPositionExt;

END_METHOD

METHOD PROTECTED Reset : DINT
VAR_INPUT
END_VAR

  SUPER^.Reset();
  
  Busy := FALSE;

END_METHOD

