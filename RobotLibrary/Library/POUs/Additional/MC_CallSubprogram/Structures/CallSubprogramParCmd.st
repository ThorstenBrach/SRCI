{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      CallSubprogramParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-03
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
TYPE CallSubprogramParCmd :
STRUCT
  /// Program number of the subprogram in the RC
  JobID             : UINT;
  /// ID of associated trigger function:
  /// • 0: No Trigger (default) - No trigger related behavior
  /// • >0: Triggero - Start executing when the trigger function with the identical EmitterID is triggered.
  /// Always positive.
  /// For more information, see chapter 5.5.12 Triggers
  ListenerID        : SINT;
  /// Acyclic input parameters of the subprogram Array length adjusts to transmitted data (max 190 bytes)
  Data              : ARRAY[0..RobotLibraryParameter.SUB_PROGRAM_DATA_MAX] OF BYTE;
END_STRUCT
END_TYPE


