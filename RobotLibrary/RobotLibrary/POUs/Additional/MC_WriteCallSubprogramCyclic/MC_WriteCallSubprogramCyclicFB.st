/// Writes cyclic data of called subprogram
FUNCTION_BLOCK MC_WriteCallSubprogramCyclicFB EXTENDS RobotLibraryBaseEnableFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteCallSubprogramCyclicFB                                       
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
  ParCmd  : WriteCallSubprogramCyclicParCmd;
END_VAR

VAR_OUTPUT
  /// command outputs
  OutCmd  : WriteCallSubprogramCyclicOutCmd;
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

  MyType := 'MC_WriteCallSubprogramCyclicFB';

END_METHOD

METHOD PROTECTED OnCall
VAR_IN_OUT
  /// Robot assignment of function
  AxesGroup : AxesGroup; 
END_VAR

  // call base implementation
  SUPER^.OnCall(AxesGroup := AxesGroup);
  
  AxesGroup.Parameter.Plc.OptionalCyclic.UseCallSubprogram := Enable;
  
  Enabled := AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Active;
  Busy    := (Enabled <> Enable); 
  
  AxesGroup.CyclicOptional.PlcToRob.SubProgramData.Data := ParCmd.Data;

END_METHOD
