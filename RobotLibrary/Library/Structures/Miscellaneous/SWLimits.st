{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SWLimits                                       
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
TYPE SWLimits :
STRUCT
  /// Timestamp
  Timestamp    : IEC_TIMESTAMP;
  /// Negative software limit for Joint J1 [mm/°]
  J1LowerLimit : REAL;
  /// Positive software limit for Joint J1 [mm/°]
  J1UpperLimit : REAL;
  /// Negative software limit for Joint J2 [mm/°]
  J2LowerLimit : REAL;
  /// Positive software limit for Joint J2 [mm/°]
  J2UpperLimit : REAL;
  /// Negative software limit for Joint J3 [mm/°]
  J3LowerLimit : REAL;
  /// Positive software limit for Joint J3 [mm/°]
  J3UpperLimit : REAL;
  /// Negative software limit for Joint J4 [mm/°]
  J4LowerLimit : REAL;
  /// Positive software limit for Joint J4 [mm/°]
  J4UpperLimit : REAL;
  /// Negative software limit for Joint J5 [mm/°]
  J5LowerLimit : REAL;
  /// Positive software limit for Joint J5 [mm/°]
  J5UpperLimit : REAL;
  /// Negative software limit for Joint J6 [mm/°]
  J6LowerLimit : REAL;
  /// Positive software limit for Joint J6 [mm/°]
  J6UpperLimit : REAL;
  /// Negative software limit for axis E1 [mm/°]
  E1LowerLimit : REAL;
  /// Positive software limit for axis E1 [mm/°]
  E1UpperLimit : REAL;
  /// Negative software limit for axis E2 [mm/°]
  E2LowerLimit : REAL;
  /// Positive software limit for axis E2 [mm/°]
  E2UpperLimit : REAL;
  /// Negative software limit for axis E3 [mm/°]
  E3LowerLimit : REAL;
  /// Positive software limit for axis E3 [mm/°]
  E3UpperLimit : REAL;
  /// Negative software limit for axis E4 [mm/°]
  E4LowerLimit : REAL;
  /// Positive software limit for axis E4 [mm/°]
  E4UpperLimit : REAL;
  /// Negative software limit for axis E5 [mm/°]
  E5LowerLimit : REAL;
  /// Positive software limit for axis E5 [mm/°]
  E5UpperLimit : REAL;
  /// Negative software limit for axis E6 [mm/°]
  E6LowerLimit : REAL;
  /// Positive software limit for axis E6 [mm/°]
  E6UpperLimit : REAL;  
END_STRUCT
END_TYPE


