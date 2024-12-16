{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DHParameter                                       
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
TYPE DHParameter :
STRUCT
   /// DH parameter α for each joint - 0 If not supported
   Alpha                  : ARRAY [0..6] OF REAL;
   /// DH parameters A for each joint - 0 If not supported
   A                      : ARRAY [0..6] OF REAL;
   /// DH parameters D for each joint - 0 If not supported
   D                      : ARRAY [0..6] OF REAL;
   /// DH parameters Theta for each joint - 0 If not supported
   Theta                  : ARRAY [0..6] OF REAL;
   /// Positive joint direction of each joint. TRUE when positive joint direction points to the right.
   /// See also Figure 6-16.
   PositiveJointDirection : ARRAY [0..6] OF BOOL;
   /// Offset of zero position of joint to zero position suggested by Figure 6-17.
   JointZeroPosition      : ARRAY [0..6] OF REAL;
END_STRUCT
END_TYPE


