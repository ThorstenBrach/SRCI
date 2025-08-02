{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReadLoadDataRecvData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-09
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
TYPE ReadLoadDataRecvData EXTENDS RspHeader :
STRUCT
  /// Tool index
  LoadNoReturn : USINT;
  /// Load data (see chapter 5.5.6.4)
  LoadData     : LoadData;
  /// The status bit "DataChanged" represents the modification state 
  DataChanged  : BOOL;
END_STRUCT
END_TYPE


