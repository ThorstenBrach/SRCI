{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MoveSuperImposedDynamicRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE MoveSuperImposedDynamicRecvData EXTENDS RspHeader :
STRUCT
  /// Percentage of already traversed distance of current job.
  /// If not supported : • -1
  Progress          : UINT;
  /// Distance-to-go of the current job.
  /// • -1: No valid value because move command is not yet active (valid values are pending) or not supported by RC
  /// • >0: Actual distance between current and target position
  /// •  0: Target position reached
  RemainingDistance  : REAL;
  /// TRUE if the offset for superimposed positioning is reached.
  OffsetReached      : BOOL;  
END_STRUCT
END_TYPE


