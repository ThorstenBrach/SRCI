{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupParameterPlcParameter                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-30
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
TYPE AxesGroupParameterPlcParameter :
STRUCT
  /// Manufactured ID
  ManufacturedID       : UINT;
  /// Order ID
  OrderID              : STRING(20);
  /// Serial Number
  SerialNumber         : STRING(16);
  /// Firmware Version
  FirmwareVersion      : STRING(8);
  /// Client Interface Version
  InterfaceVersion     : STRING(8);
  /// Synchronization Modes
  SynchronizationModes : SynchronizationModes;  
END_STRUCT               
END_TYPE


