{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AbortMeasuringInputParCmd                                       
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
TYPE AbortMeasuringInputParCmd :
STRUCT
  /// Define an active measurement that is to be aborted.
  /// •  0: Abort all existing measurement
  /// • >0: Abort the measurement with the specific MeasuringID
  MeasuringID        : UINT;
END_STRUCT
END_TYPE


