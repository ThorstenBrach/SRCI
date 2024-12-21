{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReturnToPrimaryOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-22
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
TYPE ReturnToPrimaryOutCmd :
STRUCT
  /// Distance-to-go of the current job.
  /// • -1: No valid value because move command is not yet active (valid values are pending) or not supported by RC
  /// • >0: Actual distance between current and target position
  /// •  0: Target position reached
  RemainingDistance  : REAL;
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress           : REAL;
  /// Tool index of target position of ReturnToPrimary
  /// • 0: Flange
  /// • 1..254: Tool frames
  PrimaryPosToolNo   : USINT;
  /// Frame index of target position of ReturnToPrimary
  /// • 0: WCS
  ///• 1..254: User frames
  PrimaryPosFrameNo  : USINT;
END_STRUCT
END_TYPE


