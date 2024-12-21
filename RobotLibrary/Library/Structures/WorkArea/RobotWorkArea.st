{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      RobotWorkArea                                       
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
TYPE RobotWorkArea :
STRUCT
  /// Timestamp
  Timestamp          : IEC_TIMESTAMP;
  /// Defines type of work area 
  AreaType           : AreaType;
  /// Defines violation condition 
  /// • FALSE (default) : Robot must not leave defined area
  /// • TRUE            : Robot must not enter defined area
  AreaMode           : BOOL := FALSE;
  /// Defines RC’s and robot’s behavior when robot violates work area 
  ReactionMode       : WorkAreaReactionMode;
  /// Specifies whether an active work area can be edited by function WriteWorkArea
  ///  TRUE            : Modification of active work area possible
  ///  FALSE (default) : Modification of active work areas not possible 
  ActiveModification : BOOL;
  /// Relates to AreaType Box, Cylinder and Sphere. 
  DefinitionMode     : DefinitionMode;
  /// Relates to AreaType Box, Cylinder and Sphere.
  /// Index of reference frame
  /// • 0: WCS (default)
  /// • 1..254: User frames 
  FrameNo            : USINT;
  /// Relates to AreaType Box, Cylinder and Sphere. 
  /// X-value of reference point in specified frame - Default: 0
  ZeroPointX         : REAL := 0;
  /// Relates to AreaType Box, Cylinder and Sphere. 
  /// Y-value of reference point in specified frame - Default: 0
  ZeroPointY         : REAL := 0;
  /// Relates to AreaType Box, Cylinder and Sphere. 
  /// Z-value of reference point in specified frame - Default: 0
  ZeroPointZ         : REAL := 0;
  /// Limit for cartesian X    
  X                  : RobotWorkAreaLimitCartesian;
  /// Limit for cartesian Y    
  Y                  : RobotWorkAreaLimitCartesian;
  /// Limit for cartesian Z    
  Z                  : RobotWorkAreaLimitCartesian;
  /// Relates to AreaType Sphere. 
  /// Radius of cylinder or sphere - Default 0
  Radius             : REAL := 0;
  /// Limits for Joint J1  
  J1Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint J2  
  J2Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint J3  
  J3Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint J4  
  J4Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint J5  
  J5Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint J6  
  J6Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E1  
  E1Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E2  
  E2Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E3  
  E3Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E4  
  E4Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E5  
  E5Limit            : RobotWorkAreaLimitJoint;
  /// Limits for Joint E6  
  E6Limit            : RobotWorkAreaLimitJoint;
END_STRUCT
END_TYPE


