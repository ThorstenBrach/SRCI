{attribute 'pack_mode' := '1'}
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ShiftPositionSendData                                       
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
TYPE ShiftPositionSendData EXTENDS CmdHeader: 
STRUCT
  /// Defines the frame data relevant for the transformation of the "Position". Relates to all "Mode" settings. 
  /// The parameter includes the Frame ID to which the origin of the shifting and rotation is relative and the cartesian position of the origin
  TransformationParameter_1 : FrameData;
  /// Relates to all "Mode" settings. Defines the enabled axis or plane as reference straight line or reference plain for the transformation
  TransformationParameter_2 : ReferenceElement;
  /// Defines the angle of rotation around the defined straight line. 
  /// Related to "Mode" with the setting "Rotate around Straight Line".
  RotationAngle             : REAL;
  /// Define which method should be used to transform the position:
  Mode                      : TransformMode;
  /// Defines the reference frame ID to which the "Position" that will be transformed is relative.
  /// • 0: WCS (default)
  /// • 1..254: User frames
  FrameNo                   : USINT;
  /// Defines the reference frame ID to which the "TransformedPosition" should be relative.
  /// • 0: WCS (default)
  /// • 1..254: User frames
  TargetFrameNo             : USINT;
  /// Absolute coordinates of the position that will be transformed in the selected coordinate systems (see input parameter CoordinateSystem).
  Position                  : RobotCartesianPosition;
END_STRUCT
END_TYPE


