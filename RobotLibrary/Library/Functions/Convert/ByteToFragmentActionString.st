FUNCTION ByteToFragmentActionString : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToFragmentActionString                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-16
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
  /// Fragment action
  FragmentAction : BYTE;
END_VAR

  IF ( FragmentAction.0 )
  THEN
   ByteToFragmentActionString := CONCAT(ByteToFragmentActionString, ' Complete (Bit 0)');
  END_IF
  
  IF ( FragmentAction.1 )
  THEN
   ByteToFragmentActionString := CONCAT(ByteToFragmentActionString, ' Reset (Bit 1)');
  END_IF
  
  IF ( FragmentAction.2 )
  THEN
   ByteToFragmentActionString := CONCAT(ByteToFragmentActionString, ' Clear (Bit 2)');
  END_IF

END_FUNCTION
