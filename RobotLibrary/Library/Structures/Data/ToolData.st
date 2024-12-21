{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ToolData                                       
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
TYPE ToolData :
STRUCT
  /// Timestamp
  Timestamp   : IEC_TIMESTAMP;
  /// Identification of physical tool Default: 0 
  ID          : USINT;
  /// True: Tool fixed False: Tool on flange 
  ExternalTCP : BOOL;
  /// Origin of the tool coordinate system relative to the flange coordinate system. 
  /// X value [mm]  
  X           : REAL;
  /// Origin of the tool coordinate system relative to the flange coordinate system. 
  /// Y value [mm]  
  Y           : REAL;
  /// Origin of the tool coordinate system relative to the flange coordinate system. 
  /// Z value [mm]  
  Z           : REAL;
  /// Orientation of the tool coordinate system relative to the flange coordinate system 
  /// RX value[°]
  Rx          : REAL;
  /// Orientation of the tool coordinate system relative to the flange coordinate system 
  /// RX value[°]
  Ry          : REAL;
  /// Orientation of the tool coordinate system relative to the flange coordinate system 
  /// RX value[°]
  Rz          : REAL;
  /// Index of the payload Information of tool and workpiece weight, center of gravity and inertia 
  LoadNo      : USINT;  
END_STRUCT
END_TYPE


