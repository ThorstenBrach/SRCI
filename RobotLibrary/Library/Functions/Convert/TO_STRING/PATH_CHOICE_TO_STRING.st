FUNCTION PATH_CHOICE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      PATH_CHOICE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-02-28
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
  /// PathChoice
  Value : PathChoice;
END_VAR

  CASE Value 
  OF
  
    PathChoice.CLOCKWISE         : StrReplace('CLOCKWISE ({0})'        ,'{0}' , BYTE_TO_STRING(Value));
    PathChoice.COUNTERCLOCKWISE  : StrReplace('COUNTERCLOCKWISE ({0})' ,'{0}' , BYTE_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

