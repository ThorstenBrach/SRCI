{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FrameData                                       
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
TYPE FrameData :
STRUCT
  /// Timestamp
  Timestamp      : IEC_TIMESTAMP;
  /// Frame to which the shifting and rotation is relative M
  ReferenceFrame : USINT;
  /// Origin of the coordinate system relative to the BCS/WCS/UCS 
  /// X value [mm]  
  X              : REAL := 0;
  /// Origin of the coordinate system relative to the BCS/WCS/UCS 
  /// Y value [mm]  
  Y              : REAL := 0;
  /// Origin of the coordinate system relative to the BCS/WCS/UCS 
  /// Z value [mm]  
  Z              : REAL := 0;
  /// Orientation of the coordinate system relative to the BCS/WCS/UCS
  /// Rx value [°]  
  Rx             : REAL := 0;
  /// Rx value [°]  
  Ry             : REAL := 0;
  /// Rx value [°]  
  Rz             : REAL := 0;  
END_STRUCT
END_TYPE


