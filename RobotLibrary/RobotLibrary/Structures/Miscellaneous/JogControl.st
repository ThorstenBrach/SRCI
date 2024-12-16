{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      JogControl                                       
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
TYPE JogControl :
STRUCT
  /// Mode Frame : Movement in positive direction X of selected frame
  /// Mode Tool  : Movement in positive direction X of selected tool
  /// Mode Axes  : Movement in positive direction joint 1
  X_J1_Pos  : BOOL;
  /// Mode Frame : Movement in negative direction X of selected frame
  /// Mode Tool  : Movement in negative direction X of selected tool
  /// Mode Axes  : Movement in negative direction joint 1
  X_J1_Neg  : BOOL;
  /// Mode Frame : Movement in positive direction Y of selected frame
  /// Mode Tool  : Movement in positive direction Y of selected tool
  /// Mode Axes  : Movement in positive direction joint 2
  Y_J2_Pos  : BOOL;
  /// Mode Frame : Movement in negative direction Y of selected frame
  /// Mode Tool  : Movement in negative direction Y of selected tool
  /// Mode Axes  : Movement in negative direction joint 2
  Y_J2_Neg  : BOOL;
  /// Mode Frame : Movement in positive direction Z of selected frame
  /// Mode Tool  : Movement in positive direction Z of selected tool
  /// Mode Axes  : Movement in positive direction joint 3
  Z_J3_Pos  : BOOL;
  /// Mode Frame : Movement in negative direction Z of selected frame
  /// Mode Tool  : Movement in negative direction Z of selected tool
  /// Mode Axes  : Movement in negative direction joint 3
  Z_J3_Neg  : BOOL;
  /// Mode Frame : Movement in positive direction Rx of selected frame
  /// Mode Tool  : Movement in positive direction Rx of selected tool
  /// Mode Axes  : Movement in positive direction joint 4
  Rx_J4_Pos : BOOL;
  /// Mode Frame : Movement in negative direction Rx of selected frame
  /// Mode Tool  : Movement in negative direction Rx of selected tool
  /// Mode Axes  : Movement in negative direction joint 4
  Rx_J4_Neg : BOOL;
  /// Mode Frame : Movement in positive direction Ry of selected frame
  /// Mode Tool  : Movement in positive direction Ry of selected tool
  /// Mode Axes  : Movement in positive direction joint 5
  Ry_J5_Pos : BOOL;
  /// Mode Frame : Movement in negative direction Ry of selected frame
  /// Mode Tool  : Movement in negative direction Ry of selected tool
  /// Mode Axes  : Movement in negative direction joint 5
  Ry_J5_Neg : BOOL;
  /// Mode Frame : Movement in positive direction Rz of selected frame
  /// Mode Tool  : Movement in positive direction Rz of selected tool
  /// Mode Axes  : Movement in positive direction joint 6
  Rz_J6_Pos : BOOL;
  /// Mode Frame : Movement in negative direction Rz of selected frame
  /// Mode Tool  : Movement in negative direction Rz of selected tool
  /// Mode Axes  : Movement in negative direction joint 6
  Rz_J6_Neg : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction first external axis
  E1_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction first external axis
  E1_Neg    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction second external axis
  E2_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction second external axis
  E2_Neg    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction third external axis
  E3_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction third external axis
  E3_Neg    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction fourth external axis
  E4_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction fourth external axis
  E4_Neg    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction fifth external axis
  E5_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction fifth external axis
  E5_Neg    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in positive direction sixth external axis
  E6_Pos    : BOOL;
  /// Mode Frame : not supported
  /// Mode Tool  : not supported
  /// Mode Axes  : Movement in negative direction sixts external axis
  E6_Neg    : BOOL;
  
END_STRUCT
END_TYPE


