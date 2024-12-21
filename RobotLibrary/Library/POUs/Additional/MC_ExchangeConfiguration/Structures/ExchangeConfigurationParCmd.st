{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ExchangeConfigurationParCmd                                       
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
TYPE ExchangeConfigurationParCmd :
STRUCT
  /// Defines up to which level of severity messages will be logged in the RC's server log
  LogLevel                   : LogLevel;
  /// Defines blending behavior for single move commands. One of the optional modes must be supported.
  ///  • 0 (default): Move to end position
  ///       Robot moves exactly the target position independently of the selected "BlendingMode"
  ///  • 1: Wait at blending parameter 
  ///       Robot stops its movement when the specified blending parameter is reached
  WaitAtBlendingZone         : BOOL;
  /// Allow a sequence switch from primary to secondary while a subprogram called via CallSubprogram (6.5.18) in the sequence is in progress
  AllowSecSeqWhileSubprogram : BOOL;
  /// Allows blending when CallSubprogram is called in sequence and removed afterwards. For more information see chapter 6.5.21.
  /// • 0 (default): Dynamic blending is prevented
  /// • 1: Dynamic blending is allowed
  AllowDynamicBlending       : BOOL;
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
  /// Enable datas to synchronize
  DataEnableSync             : DataEnableSync;
END_STRUCT
END_TYPE


