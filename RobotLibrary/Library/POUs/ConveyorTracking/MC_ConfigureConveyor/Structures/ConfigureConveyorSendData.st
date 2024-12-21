{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ConfigureConveyorSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-11
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
TYPE ConfigureConveyorSendData EXTENDS CmdHeader:   
STRUCT
  ///Define the origin coordinate system of the conveyor belt, with the X-Axis pointing in the direction of the movement of the conveyor belt.
  ConveyorOrigin          : FrameData;
  /// ConveyorOrigin available
  ConveyorOriginAvailable : BOOL;
  /// Index of assigned conveyor
  ConveyorNo              : USINT;  
  /// Define the type of the conveyor
  ConveyorType            : ConveyorType;
  /// Relates to "ConveyorType" "Circular Tracking": Define the radius of the circular conveyor
  Radius                  : REAL;
  /// Distance [mm] from the origin of the conveyor belt to the beginning of the "SyncInZone"
  StartDistance           : REAL;
  /// Distance [mm] from the origin of the conveyor belt to the end of the "SyncOutZone"
  EndDistance             : REAL;
  /// Define the length of the "SyncInZone"
  SyncInLength            : REAL;
  /// Define the length of the "SyncOutZone"
  SyncOutLength           : REAL;
END_STRUCT
END_TYPE


