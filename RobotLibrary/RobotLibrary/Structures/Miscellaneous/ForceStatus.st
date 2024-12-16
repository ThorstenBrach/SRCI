{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ForceStatus                                       
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
TYPE ForceStatus :
STRUCT
  /// TRUE, while a "ForceControl" function is enabled
  ForceControlEnabled         : BOOL;
  /// TRUE, while a "ForceLimit" function is enabled
  ForceLimitEnabled           : BOOL;
  /// TRUE, while robot is adjusting its movement to apply specified force
  ApplyingForce               : BOOL;
  /// TRUE, while maximum deviation according to input parameter "MaxDeviation" is reached
  MaxDeviationReached         : BOOL;
  /// TRUE, while currently applied force/torque is identical to specified force/torque
  SpecifiedForceTorqueReached : BOOL;
  /// TRUE, while currently detected force is identical to specified force limit
  SpecifiedForceLimitReached  : BOOL;
  /// Bit 06 Reserve
  Bit06                       : BOOL;
  /// Bit 07 Reserve
  Bit07                       : BOOL;  
END_STRUCT
END_TYPE


