{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActivateConveyorTrackingOutCmd                                       
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
TYPE ActivateConveyorTrackingOutCmd :
STRUCT
  /// Current status of "ConveyorTracking" according to Table 6-432
  TrackingStatus     : TrackingStatus;
  /// Relates to "ConnectionMode" 1 – "RC connected": Traveled distance of assigned conveyor since ConveyorTracking has been activated (offset)
  RCEncoderValue     : REAL;
END_STRUCT
END_TYPE


