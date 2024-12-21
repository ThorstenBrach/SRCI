FUNCTION CheckTimeout : DINT
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SwapBytes                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-12-18
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
VAR_INPUT
  /// Reference to TON instance
  rTimer : REFERENCE TO TON;
END_VAR

  // Call timer 
  rTimer();
  
  // check if timer elapsed
  IF (rTimer.Q = TRUE)
  THEN
    // assign return value
    CheckTimeout := RobotLibraryConstants.OK;
  ELSE
    // assign return value
    CheckTimeout := RobotLibraryConstants.RUNNING;
  END_IF

END_FUNCTION

