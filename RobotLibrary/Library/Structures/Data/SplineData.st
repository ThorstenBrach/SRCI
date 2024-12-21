{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SplineData                                       
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
TYPE SplineData :
STRUCT
    /// Absolute target coordinates in the selected coordinate system (see ToolNo and FrameNo).
    Position         : RobotCartesianPosition;
    /// TCP velocity in % of nominal velocity.
    /// •  <0% : Use default velocity (default)
    /// •   0% : Use internal minimal velocity
    /// • 100% : Use maximal reference velocity
    /// • See chapter 5.5.7 Robot dynamics
    VelocityRate     : REAL;    
    /// Acceleration for movement in % of nominal acceleration.
    /// •  <0% : Use default acceleration (default)
    /// •   0% : Use internal minimal acceleration
    /// • 100% : Use maximal reference acceleration
    /// • See chapter 5.5.7 Robot dynamics
    AccelerationRate : REAL;    
    /// Deceleration for movement in % of nominal deceleration.
    /// •  <0% : Use default deceleration (default)
    /// •   0% : Use internal minimal deceleration
    /// • 100% : Use maximal reference deceleration
    /// • See chapter 5.5.7 Robot dynamics
    DecelerationRate : REAL;    
    /// Jerk of the movement in % of nominal jerk.
    /// <0% o Use default jerk (default)
    /// 0% o Use internal minimal jerk
    /// 100% o Use maximal reference jerk
    /// See chapter 5.5.7 Robot dynamics
    JerkRate         : REAL;
    /// Index of tool
    /// 0: Flange (default)
    /// 1..254: Tool frames
    ToolNo           : USINT;    
    /// Index of frame
    /// 0: WCS (default)
    /// 1..254: User frames
    FrameNo          : USINT;    
    /// [ms] Parameter is used if it is greater than 0 (default):
    /// Parameter defines the time for the movement to reach the target position
    /// Velocity input can be ignored
    /// Acceleration, Deceleration and jerk will be ignored
    /// Define two consecutive points with identical positions and specified Time to realize waiting time on spline.
    /// Error is sent by the RC, if the time cannot be kept.
    MoveTime         : TIME;  
END_STRUCT
END_TYPE


