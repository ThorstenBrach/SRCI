{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      MeasuringInputParCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-21
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
TYPE MeasuringInputParCmd :
STRUCT
  /// Type of measurement (at least one option must be supported):
  MeasuringMode      : MeasuringIoMode;
  /// Specifies the desired digital input register. 
  /// More information about the different periphery register can be found in chapter 6.4
  Index              : USINT;
  ///Specifies the desired bit in the digital input register, that should be read. 
  /// More information about the different periphery register can be found in chapter 6.4.
  BitNumber          : USINT;
END_STRUCT
END_TYPE


