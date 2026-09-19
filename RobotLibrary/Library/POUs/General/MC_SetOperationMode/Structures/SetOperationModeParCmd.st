{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SetOperationModeParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-08-01
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
TYPE SetOperationModeParCmd :
STRUCT
  /// Limits for joints and external axes according to Table 6-180.
  OperationMode : OperationMode;
END_STRUCT
END_TYPE


