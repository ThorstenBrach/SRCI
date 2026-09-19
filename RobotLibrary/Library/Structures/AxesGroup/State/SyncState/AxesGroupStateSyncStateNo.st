{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupStateSyncStateNo                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE AxesGroupStateSyncStateNo :
STRUCT
  /// Ammount of unsynchronized tool data
  Tool     : USINT;
  /// Ammount of unsynchronized frame data
  Frame    : USINT;
  /// Ammount of unsynchronized load data
  Load     : USINT;
  /// Ammount of unsynchronized word areas
  WorkArea : USINT;    
END_STRUCT
END_TYPE


