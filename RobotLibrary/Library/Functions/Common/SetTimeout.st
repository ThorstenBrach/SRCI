FUNCTION SetTimeout : DINT
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
  /// Timeout to be set
  PT     : TIME;
  /// Reference to TON instance
  rTimer : REFERENCE TO TON;
END_VAR

  rTimer(IN := FALSE);          // Reset timer
  rTimer(PT := PT, IN := TRUE); // Start timer
  
  // assign return value
  SetTimeout := RobotLibraryConstants.OK;

END_FUNCTION

