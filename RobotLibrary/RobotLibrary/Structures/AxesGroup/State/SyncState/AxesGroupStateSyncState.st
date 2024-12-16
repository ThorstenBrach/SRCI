{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupStateSyncState                                       
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
TYPE AxesGroupStateSyncState :
STRUCT
  /// Bit 00: Tool
  Tool             : BOOL;
  /// Bit 01: Frame
  Frame            : BOOL;
  /// Bit 02: Load
  Load             : BOOL;
  /// Bit 03: WorkArea
  WorkArea         : BOOL;
  /// Bit 04: SwLimits
  SwLimits         : BOOL;
  /// Bit 05: DefaultDynamic
  DefaultDynamic   : BOOL;
  /// Bit 06: ReferenceDynamic
  ReferenceDynamic : BOOL;
  /// Bit 07:
  Bit07            : BOOL;
  /// Bit 08:
  Bit08            : BOOL;
  /// Bit 09:
  Bit09            : BOOL;
  /// Bit 10:
  Bit10            : BOOL;
  /// Bit 11:
  Bit11            : BOOL;
  /// Bit 12:
  Bit12            : BOOL;
  /// Bit 13:
  Bit13            : BOOL;
  /// Bit 14:
  Bit14            : BOOL;
  /// Bit 15:
  Bit15            : BOOL;  
END_STRUCT
END_TYPE


