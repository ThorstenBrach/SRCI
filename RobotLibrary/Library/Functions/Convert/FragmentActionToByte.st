FUNCTION FragmentActionToByte : BYTE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FragmentActionToByte                                       
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
VAR_INPUT
  FragmentAction : FragmentAction;
END_VAR

  FragmentActionToByte.0 := FragmentAction.Complete;
  FragmentActionToByte.1 := FragmentAction.Reset;
  FragmentActionToByte.2 := FragmentAction.Clear;
  FragmentActionToByte.3 := FragmentAction.BIT03;
  FragmentActionToByte.4 := FragmentAction.BIT04;
  FragmentActionToByte.5 := FragmentAction.BIT05;
  FragmentActionToByte.6 := FragmentAction.BIT06;
  FragmentActionToByte.7 := FragmentAction.BIT07;

END_FUNCTION

