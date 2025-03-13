FUNCTION SINGULARITY_AVOIDANCE_MODE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SINGULARITY_AVOIDANCE_MODE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-24
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the LGPL-3.0 license.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// SingularityAvoidanceMode
  Value : SingularityAvoidanceMode;
END_VAR

  CASE Value 
  OF
    SingularityAvoidanceMode.NO_CHANGE        : SINGULARITY_AVOIDANCE_MODE_TO_STRING := StrReplace('NO_CHANGE ({0})'        ,'{0}' , USINT_TO_STRING(Value));
    SingularityAvoidanceMode.LOCK_J4          : SINGULARITY_AVOIDANCE_MODE_TO_STRING := StrReplace('LOCK_J4 ({0})'          ,'{0}' , USINT_TO_STRING(Value));
    SingularityAvoidanceMode.TOOL_ORIENTATION : SINGULARITY_AVOIDANCE_MODE_TO_STRING := StrReplace('TOOL_ORIENTATION ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    SINGULARITY_AVOIDANCE_MODE_TO_STRING := CONCAT('SINGULARITY_AVOIDANCE_MODE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

