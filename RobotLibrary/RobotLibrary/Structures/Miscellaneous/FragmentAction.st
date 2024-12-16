{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      FragmentAction                                       
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
TYPE FragmentAction :
STRUCT
  /// Bit 00 : Command Message is completely received – Flag to trigger processing of the payload
  Complete : BOOL;
  /// Bit 01 :(only client->server): The first message fragment of a new CMD resets (set all ACR values of this CMD ID to 0) the ACR entry
  Reset    : BOOL;
  /// Bit 02: Clears the receiving buffer by setting all of its Bytes to 0.
  Clear    : BOOL;
  /// Bit 03
  BIT03    : BOOL;
  /// Bit 04
  BIT04    : BOOL;
  /// Bit 05
  BIT05    : BOOL;
  /// Bit 06
  BIT06    : BOOL;
  /// Bit 07
  BIT07    : BOOL;  
END_STRUCT
END_TYPE


