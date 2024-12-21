{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementAutomaticOutCmd                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-20
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
TYPE LoadMeasurementAutomaticOutCmd :
STRUCT
  /// FB is returning a unique ID for the cal led measurement.
  MeasuringID       : UINT;
  /// Measured load data (see chapter 5.5.6.4)
  LoadData          : LoadData;  
  /// Load data available
  LoadDataAvailable : BOOL;
END_STRUCT
END_TYPE


