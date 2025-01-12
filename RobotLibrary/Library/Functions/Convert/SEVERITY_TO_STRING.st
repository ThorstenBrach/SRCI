FUNCTION SEVERITY_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SEVERITY_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-01-11
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
  /// Severity
  Value : Severity;
  /// Fill spaces to the end, so that all values has the same length  
  AlignString : BOOL;
END_VAR

  IF (AlignString)
  THEN
    CASE Value OF
      Severity.DEBUG       : SEVERITY_TO_STRING := 'DEBUG      ';
      Severity.INFO        : SEVERITY_TO_STRING := 'INFO       ';
      Severity.WARNING     : SEVERITY_TO_STRING := 'WARNING    ';
      Severity.ERROR       : SEVERITY_TO_STRING := 'ERROR      ' ;
      Severity.FATAL_ERROR : SEVERITY_TO_STRING := 'FATAL_ERROR' ;
    ELSE
      SEVERITY_TO_STRING := 'UNKOWN     '; 
    END_CASE
  ELSE
    CASE Value OF
      Severity.DEBUG       : SEVERITY_TO_STRING := 'DEBUG';
      Severity.INFO        : SEVERITY_TO_STRING := 'INFO';
      Severity.WARNING     : SEVERITY_TO_STRING := 'WARNING';
      Severity.ERROR       : SEVERITY_TO_STRING := 'ERROR' ;
      Severity.FATAL_ERROR : SEVERITY_TO_STRING := 'FATAL_ERROR' ;
    ELSE
      SEVERITY_TO_STRING := 'UNKOWN'; 
    END_CASE
  END_IF

END_FUNCTION

