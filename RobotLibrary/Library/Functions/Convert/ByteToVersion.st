FUNCTION ByteToVersion : VersionStruct
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ByteToVersion                                       
//  Author:      Thorsten Brach                                                
//  Date:        2024-09-11
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
  Value : BYTE;
END_VAR

VAR
  _tmpByte : BYTE;
END_VAR

  // Minor version  • Features
  //                • 0..31 minor versions
  ByteToVersion.MinorVersion.0 := Value.0;
  ByteToVersion.MinorVersion.1 := Value.1;
  ByteToVersion.MinorVersion.2 := Value.2;
  ByteToVersion.MinorVersion.3 := Value.3;
  ByteToVersion.MinorVersion.4 := Value.4;
  
  // Major version  • Breaking change
  //                • 0..7 major versions
  ByteToVersion.MajorVersion.0 := Value.5;
  ByteToVersion.MajorVersion.1 := Value.6;
  ByteToVersion.MajorVersion.2 := Value.7;

END_FUNCTION

