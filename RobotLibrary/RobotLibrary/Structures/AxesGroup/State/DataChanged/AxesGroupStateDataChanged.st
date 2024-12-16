{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupStateDataChanged                                       
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
TYPE AxesGroupStateDataChanged :
STRUCT
  /// indicates that tool data has changed
  Tool             : ARRAY[0..255] OF BOOL;
  /// indicates that frame data has changed
  Frame            : ARRAY[0..255] OF BOOL;
  /// indicates that load data has changed
  Load             : ARRAY[0..255] OF BOOL;
  /// indicates that work area has changed
  WorkArea         : ARRAY[0..255] OF BOOL;
  /// indicates that default dynamic has changed
  DefaultDynamic   : BOOL;
  /// indicates that reference dynamic has changed
  ReferenceDynamic : BOOL;
  /// indicates that software limits has changed
  SwLimits         : BOOL;
END_STRUCT
END_TYPE


