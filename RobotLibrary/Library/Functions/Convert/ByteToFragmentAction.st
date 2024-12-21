FUNCTION ByteToFragmentAction : FragmentAction
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FragmentActionToByte                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-11-05
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
  FragmentAction : BYTE;
END_VAR

  ByteToFragmentAction.Complete:= FragmentAction.0; 
  ByteToFragmentAction.Reset   := FragmentAction.1;   
  ByteToFragmentAction.Clear   := FragmentAction.2;   
  ByteToFragmentAction.BIT03   := FragmentAction.3;   
  ByteToFragmentAction.BIT04   := FragmentAction.4;   
  ByteToFragmentAction.BIT05   := FragmentAction.5;   
  ByteToFragmentAction.BIT06   := FragmentAction.6;   
  ByteToFragmentAction.BIT07   := FragmentAction.7;

END_FUNCTION

