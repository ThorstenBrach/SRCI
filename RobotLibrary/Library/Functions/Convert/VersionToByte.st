FUNCTION VersionToByte : BYTE
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      VersionToByte                                       
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
  /// Version
  Value : VersionStruct;
END_VAR

VAR
  _tmpByte : BYTE;
END_VAR

  // Minor version  • Features
  //                • 0..31 minor versions
  VersionToByte.0 := Value.MinorVersion.0;
  VersionToByte.1 := Value.MinorVersion.1;
  VersionToByte.2 := Value.MinorVersion.2;
  VersionToByte.3 := Value.MinorVersion.3;
  VersionToByte.4 := Value.MinorVersion.4;
  
  // Major version  • Breaking change
  //                • 0..7 major versions
  VersionToByte.5 := Value.MajorVersion.0;
  VersionToByte.6 := Value.MajorVersion.1;
  VersionToByte.7 := Value.MajorVersion.2;

END_FUNCTION

