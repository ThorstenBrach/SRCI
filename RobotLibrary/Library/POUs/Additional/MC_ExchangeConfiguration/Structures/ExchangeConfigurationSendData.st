{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExchangeConfigurationSendData                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-06-22
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
TYPE ExchangeConfigurationSendData EXTENDS CmdHeader: 
STRUCT
  /// Defines up to which level of severity messages will be logged in the RC's server log
  LogLevel                   : LogLevel;
  /// Miscellaneous control bits 
  CtrlByte                   : BYTE;
  /// Defines waiting time of RC between receiving a first move command when motion queue is empty and starting the first movement. See also chapter 5.6.8.
  DelayTime                  : UINT;
  /// Define number of points required to calculate the blending. See also chapter 5.6.8.
  WaitForNrOfCmd             : UINT;
  /// Maximum allowed time between incrementation of LifeSign before communication error.
  /// • <10 ms: Invalid
  /// • 50 ms: default
  /// See also chapter 5.6.6.2.
  LifeSignTimeOut            : UINT;
  /// Defines a delay time between detecting an inconsistency of configuration data between server and client and executing the defined SyncReaction. 
  /// Always positive. Default: 0 ms
  SyncDelay                  : UINT;
  /// Specifies system reaction in case inconsistency of synchronization data is detected according to Table 6-81. For more information refer to chapter 5.6.7.2
  SyncReaction               : SyncReaction;
  /// Datas which are synchronized
  DataInSync                 : DataInSync;
  /// Reserve
  Reserve1                   : BYTE;
  /// Enable datas to synchronize
  DataEnableSync             : DataEnableSync;  
  /// Reserve
  Reserve2                   : BYTE;
END_STRUCT
END_TYPE


