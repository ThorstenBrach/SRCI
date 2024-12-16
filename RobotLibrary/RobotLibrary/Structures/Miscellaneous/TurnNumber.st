{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TurnNumber                                       
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
TYPE TurnNumber :
STRUCT
  /// Turn number of J1
  J1Turns : SINT;
  /// Turn number of J2
  J2Turns : SINT;
  /// Turn number of J3
  J3Turns : SINT;
  /// Turn number of J4
  J4Turns : SINT;
  /// Turn number of J5
  J5Turns : SINT;
  /// Turn number of J6
  J6Turns : SINT;
  /// Turn number of E1
  E1Turns : SINT;  
END_STRUCT
END_TYPE


