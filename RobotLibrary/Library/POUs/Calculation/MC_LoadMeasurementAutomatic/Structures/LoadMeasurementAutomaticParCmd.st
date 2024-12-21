{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      LoadMeasurementAutomaticParCmd                                       
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
TYPE LoadMeasurementAutomaticParCmd :
STRUCT
  /// Define which method should be used to measure the load data
  Mode               : LoadMeasurementMode;
  /// Define which mass is expected as a result of the load measurement
  Mass               : REAL;
  /// Define the area for the allowed motion of the Joint 3. 
  /// The order of the two limit values does not matter. 
  /// Only considered with "Mode" = 0, 2.
  Area_J3            : ARRAY[0..1] OF REAL;
  /// Define the area for the allowed motion of the Joint 4. 
  /// The order of the two limit values does not matter. 
  /// Only considered with "Mode" = 0, 2.
  Area_J4            : ARRAY[0..1] OF REAL;
  /// Define the area for the allowed motion of the Joint 5. 
  /// The order of the two limit values does not matter. 
  /// Only considered with "Mode" = 0, 2.
  Area_J5            : ARRAY[0..1] OF REAL;
  /// Define the area for the allowed motion of the Joint 6. 
  /// The order of the two limit values does not matter. 
  /// Only considered with "Mode" = 0, 2.
  Area_J6            : ARRAY[0..1] OF REAL;
  /// Define the first position for the load measurement.
  /// Only considered with "Mode" = 0, 1.
  Position_1         : RobotJointPosition;
  /// Define the second position for the load measurement.
  /// Only considered with "Mode" = 3.
  Position_2         : RobotJointPosition;
  /// Define the configuration angle for the load measurement.
  /// Only considered with "Mode" = 1.
  ConfigurationAngle : REAL;
END_STRUCT
END_TYPE


