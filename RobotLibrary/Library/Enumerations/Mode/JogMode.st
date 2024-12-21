{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      JogMode                                       
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
TYPE JogMode :
(
  /// • Jog TCP manually in the given frame (WCS/UCS)
  /// • Movement on several coordinate axes simultaneously possible
  JOG_FRAME := 0,
  /// • Jog TCP manually in the given tool coordinate system
  /// • Movement on several coordinate axes simultaneously possible
  JOG_TOOL := 1,
  /// • Jog joints manually without referring to a given frame or tool
  /// • Movement of several axes simultaneously possible.
  JOG_AXES := 2
)USINT;
END_TYPE


