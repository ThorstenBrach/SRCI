{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupStateSynchronizing                                       
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
TYPE AxesGroupStateSynchronizing :
STRUCT
  /// indicates that the tooldata are synchronized
  Tool              : BOOL;
  /// indicates that the framedata are synchronized
  Frame             : BOOL;
  /// indicates that the loaddata are synchronized
  Load              : BOOL;
  /// indicates that the work areas are synchronized
  WorkAreas         : BOOL;
  /// indicates that the reference-dynamics are synchronized
  ReferenceDynamics : BOOL;
  /// indicates that the default-dynamics are synchronized
  DefaultDynamics   : BOOL;
  /// indicates that the software limits are synchronized
  SwLimits          : BOOL;
END_STRUCT
END_TYPE


