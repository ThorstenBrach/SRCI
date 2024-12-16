{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadData                                       
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
TYPE LoadData :
STRUCT
  /// Timestamp
  Timestamp : IEC_TIMESTAMP;
  /// Position of the center of gravity relative to the flange.
  /// X value [mm]  
  X         : REAL := 0;
  /// Position of the center of gravity relative to the flange.
  /// Y value [mm]  
  Y         : REAL := 0;
  /// Position of the center of gravity relative to the flange.
  /// Z value [mm]  
  Z         : REAL := 0;
  /// Orientation of the principal inertia axes relative to the flange. O
  /// Rx value [°]  
  Rx        : REAL := 0;
  /// Ry value [°]  
  Ry        : REAL := 0;
  /// Rz value [°]  
  Rz        : REAL := 0;
  /// The mass of the tool and workpiece being gripped. [kg]
  Mass      : REAL := 0;
  /// The moment of inertia of the load around the resulting inertia X-Axis [kg/m²]
  Ix        : REAL := 0;
  /// The moment of inertia of the load around the resulting inertia y-axis [kg/m²]
  Iy        : REAL := 0;
  /// The moment of inertia of the load around the resulting inertia z-axis [kg/m²]
  Iz        : REAL := 0;  
END_STRUCT
END_TYPE


