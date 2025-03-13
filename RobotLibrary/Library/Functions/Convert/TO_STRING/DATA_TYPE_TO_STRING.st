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
    DataType.TYPE_BOOL       : DATA_TYPE_TO_STRING := StrReplace('BOOL ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_BYTE       : DATA_TYPE_TO_STRING := StrReplace('BYTE ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_WORD       : DATA_TYPE_TO_STRING := StrReplace('WORD ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_DWORD      : DATA_TYPE_TO_STRING := StrReplace('DWORD ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_SINT       : DATA_TYPE_TO_STRING := StrReplace('SINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_USINT      : DATA_TYPE_TO_STRING := StrReplace('USINT ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_INT        : DATA_TYPE_TO_STRING := StrReplace('INT ({0})'                 ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_UINT       : DATA_TYPE_TO_STRING := StrReplace('UINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_DINT       : DATA_TYPE_TO_STRING := StrReplace('DINT ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_UDINT      : DATA_TYPE_TO_STRING := StrReplace('UDINT ({0})'               ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_REAL       : DATA_TYPE_TO_STRING := StrReplace('REAL ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_CHAR       : DATA_TYPE_TO_STRING := StrReplace('CHAR ({0})'                ,'{0}' , USINT_TO_STRING(Value));
    DataType.TYPE_CHAR_ARRAY : DATA_TYPE_TO_STRING := StrReplace('ARRAY[0..3] OF CHAR ({0})' ,'{0}' , USINT_TO_STRING(Value));
  ELSE
    DATA_TYPE_TO_STRING := CONCAT('DATA_TYPE_TO_STRING Function: Error -> no parsing for value ', USINT_TO_STRING(Value));
  END_CASE

END_FUNCTION

