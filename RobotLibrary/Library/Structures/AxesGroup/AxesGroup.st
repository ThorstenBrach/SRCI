{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroup                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-01
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2024 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
TYPE AxesGroup :
STRUCT
  /// Parameter 
  Parameter      : AxesGroupParameter;
  /// RI state information (see chapter 5.5.3) 
  State          : AxesGroupState;
  /// RC, RA, RI, and CMD warnings and errors (see chapter 5.5.11)
  MessageLog     : AxesGroupMessageLogFB;
  /// Cyclic data exchanged between server and client (see chapter 5.6.6.5) 
  Cyclic         : AxesGroupCyclic;
  /// Optional cyclic data exchanged between server and client (see chapter 5.6.6.2)
  CyclicOptional : AxesGroupCyclicOptionalData;
  /// Execution order list and ACR entries (see chapter 5.6.4.2) 
  Acyclic        : AxesGroupAcyclic;
  /// System data like ToolData, FrameData, LoadData etc.
  SystemData     : AxesGroupSystemDataFB;
END_STRUCT
END_TYPE


