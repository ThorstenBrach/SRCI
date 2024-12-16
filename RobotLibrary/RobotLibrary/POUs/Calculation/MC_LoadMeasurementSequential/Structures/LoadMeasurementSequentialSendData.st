{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementSequentialSendData                                       
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
TYPE LoadMeasurementSequentialSendData EXTENDS CmdHeader:   
STRUCT
    /// Define which mass is expected as a result of the load measurement
  Mass               : REAL;
  /// Define which step of the load estimation should be executed:
  Mode               : LoadMeasurementSteps;
END_STRUCT
END_TYPE


