{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TelegramRobToPlcCyclicOptionalCartesianPosition                                       
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
TYPE TelegramRobToPlcCyclicOptionalCartesianPosition :
STRUCT
  /// TCP Position on the X-Axis
  X                    : REAL;
  /// TCP Position on the Y-Axis
  Y                    : REAL;
  /// TCP Position on the Z-Axis
  Z                    : REAL;
  /// Rotation around the X-Axis (RX)
  Rx                   : REAL;
  /// Rotation around the Y-Axis (RY)
  Ry                   : REAL;
  /// Rotation around the Z-Axis (RZ)
  Rz                   : REAL;
  /// Configuration
  Config               : WORD;
  /// Turns of J1 and J2
  Turns_J2_J1          : BYTE;
  /// Turns of J3 and J4
  Turns_J4_J3          : BYTE;
  /// Turns of J6 and J5
  Turns_J6_J5          : BYTE;
  /// Turns of E1
  Turns_E1             : BYTE;
  /// Position of first external axis
  E1                   : REAL;  
  /// Position of second external axis
  E2                   : REAL;
  /// Position of third external axis
  E3                   : REAL;
  /// Position of fourth external axis
  E4                   : REAL;
  /// Position of fifth external axis
  E5                   : REAL;
  /// Position of sixth external axis
  E6                   : REAL;      
  /// Tool Number
  ToolNo               : USINT;
  /// Frane Number
  FrameNo              : USINT;
  /// Currently used tool number
  CurrentlyUsedToolNo  : USINT;
  /// Currently used frame number
  CurrentlyUsedFrameNo : USINT;
  /// Reserve
  Reserve_1            : BYTE;
  /// Reserve
  Reserve_2            : BYTE;  
END_STRUCT
END_TYPE


