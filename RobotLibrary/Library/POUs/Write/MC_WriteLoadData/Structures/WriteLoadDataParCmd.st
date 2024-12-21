{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      WriteLoadDataParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-08
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
TYPE WriteLoadDataParCmd :
STRUCT
  /// Specifies the desired target values that shall be written
  /// Load index
  /// •      0: (default) - Not possible to write
  /// • 1..254: Load data
  LoadNo             : USINT;
  /// Load data (see chapter 5.5.6.4)
  LoadData           : LoadData;
END_STRUCT
END_TYPE


