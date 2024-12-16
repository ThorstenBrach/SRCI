{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupAcyclicAcrEntryCmdTrigger                                       
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
TYPE AxesGroupAcyclicAcrEntryCmdTrigger :
STRUCT
  /// Trigger related EmitterID
  EmitterID    : ARRAY[0..3] OF SINT;
  /// Trigger related ListenerID 
  ListenerID   : SINT;
  /// Reserver
  Reserve      : BYTE;
END_STRUCT
END_TYPE


