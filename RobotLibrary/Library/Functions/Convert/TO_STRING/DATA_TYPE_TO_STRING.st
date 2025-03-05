FUNCTION DATA_TYPE_TO_STRING : STRING
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      DATA_TYPE_TO_STRING                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-03-05
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
  /// DataType
  Value : DataType;
END_VAR

  CASE Value 
  OF
  
    DataType.TYPE_BOOL       : StrReplace('BOOL ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_BYTE       : StrReplace('BYTE ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_WORD       : StrReplace('WORD ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_DWORD      : StrReplace('DWORD ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_SINT       : StrReplace('SINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_USINT      : StrReplace('USINT ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_INT        : StrReplace('INT ({0})'                 ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_UINT       : StrReplace('UINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_DINT       : StrReplace('DINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_UDINT      : StrReplace('UDINT ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_REAL       : StrReplace('REAL ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_CHAR       : StrReplace('CHAR ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_CHAR_ARRAY : StrReplace('ARRAY[0..3] OF CHAR ({0})' ,'{0}' , USINT_TO_STRING(Value));
  
  END_CASE

END_FUNCTION

