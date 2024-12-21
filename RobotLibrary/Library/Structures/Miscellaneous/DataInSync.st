{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DataInSync                                       
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
TYPE DataInSync :
STRUCT
  /// TRUE, if no tool has been modified
  ToolsInSync             : BOOL;
  /// TRUE, if no frame has been modified
  FramesInSync            : BOOL;
  /// TRUE, if no load has been modified
  LoadsInSync             : BOOL;
  /// TRUE, if no work area has been modified
  WorkAreasInSync         : BOOL;
  /// TRUE, if no software limit has been modified
  SoftwareLimitsInSync    : BOOL;
  /// TRUE, if no default dynamic parameter has been modified
  DefaultDynamicsInSync   : BOOL;
  /// TRUE, if no reference dynamic parameter has been modified
  ReferenceDynamicsInSync : BOOL;  
END_STRUCT
END_TYPE


