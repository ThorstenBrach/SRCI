{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ReferenceType                                       
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
TYPE ReferenceType :
(
  /// Distance is applied in the Tool coordinate system. 
  /// The setting of the parameter FrameNo will be ignored.
  TOOL  := 0,
  /// Distance is applied in the Frame coordinate system.
  /// The settings of the ToolNo are also effective and must be considered. 
  FRAME := 1
)USINT;
END_TYPE


