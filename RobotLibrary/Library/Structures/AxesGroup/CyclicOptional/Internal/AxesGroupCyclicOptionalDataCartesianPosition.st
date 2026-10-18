{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupCyclicOptionalDataCartesianPosition                                       
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
TYPE AxesGroupCyclicOptionalDataCartesianPosition EXTENDS RobotCartesianPositionShort :
STRUCT
  /// indicates that this optional parameter will be used
  Active           : BOOL;
  /// corresponding coordinate systems
  CoordinateSystem : RobotCoordinateSystemParameters; 
  /// Tool and frame currently used by the RC (bytes 36..37 of the optional cyclic Cartesian position) (ST-FIX F59: CoordinateSystem is the tool/frame of the returned position (bytes 34..35), the currently used tool/frame needs an own field (spec table 5-89, 6.1.6))
  CurrentCoordinateSystem : RobotCoordinateSystemParameters;
END_STRUCT
END_TYPE


