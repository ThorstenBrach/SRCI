{attribute 'qualified_only'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      TriggerModeMeasurement                                       
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
TYPE TriggerModeMeasurement :
(
  /// (default) No trigger related behavior
  NO_TRIGGER := 0,
  /// 1: Starts the measurement with the positive trigger event and stops it with the negative trigger event 
  ///    when the trigger function with the identical EmitterID is activated.
  POSITIVE_START_NEGATIVE_STOP := 1,
  /// 2: Starts and stops the measurement with the positive trigger event 
  ///    when the trigger function with the identical EmitterID is activated.
  POSITIVE_START_STOP := 2
)USINT;
END_TYPE


