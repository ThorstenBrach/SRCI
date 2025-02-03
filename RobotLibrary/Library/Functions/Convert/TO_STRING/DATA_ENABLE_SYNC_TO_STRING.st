FUNCTION DATA_ENABLE_SYNC_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DATA_ENABLE_SYNC_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-24
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// DataEnableSync
  Value : DataEnableSync;
END_VAR

VAR
  /// temporary byte
 _tmpByte : BYTE;
END_VAR

  _tmpByte.0 := Value.EnableSyncTool;
  _tmpByte.1 := Value.EnableSyncFrame;
  _tmpByte.2 := Value.EnableSyncLoad;
  _tmpByte.3 := Value.EnableSyncWorkArea;
  _tmpByte.4 := Value.EnableSyncSWLimits;
  _tmpByte.5 := Value.EnableSyncDefaultDynamics;
  _tmpByte.6 := Value.EnableSyncReferenceDynamics;
  _tmpByte.7 := Value.AllowDynamicBlending;
  
  DATA_ENABLE_SYNC_TO_STRING := BYTE_TO_STRING_BIN(_tmpByte);

END_FUNCTION

