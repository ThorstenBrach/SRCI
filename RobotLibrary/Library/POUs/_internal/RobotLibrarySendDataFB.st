{attribute 'pack_mode' := '1'} 
FUNCTION_BLOCK RobotLibrarySendDataFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      SendData                                      
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
  /// Payload
  Payload    : ARRAY [0..RobotLibraryParameter.ROBOT_OUT_DATA_MAX] OF BYTE;
  /// Payload length
  PayloadLen : UDINT;
  /// Payload pointer
  PayloadPtr : UDINT;
END_VAR


END_FUNCTION_BLOCK

/// Adds a ArmConfigParameter to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddArmConfig : UDINT
VAR_INPUT
  /// Value to add
  Value : ArmConfigParameter;
END_VAR

VAR
  /// temporary Byte
 _tmpByte : BYTE;
END_VAR

  Value := Value;
  
  _tmpByte.0 := Value.Shoulder = ArmConfigShoulder.USE_CONFIG;
  _tmpByte.1 := Value.Elbow    = ArmConfigElbow   .USE_CONFIG;
  _tmpByte.2 := Value.Wrist    = ArmConfigWrist   .USE_CONFIG;
  
  AddByte(_tmpByte);
  AddByte(0);
  
  AddArmConfig := PayloadLen;

END_METHOD

/// Adds a BOOL to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddBool : UDINT
VAR_INPUT
  /// Value to add
  Value : BOOL;
END_VAR

VAR
  /// temporary byte
 _tmpByte : BYTE := 0;
END_VAR

  _tmpByte.0 := Value;
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(_tmpByte), DataLen := SIZEOF(_tmpByte));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(_tmpByte);
  // return payload len
  AddBool := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a BYTE to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddByte : UDINT
VAR_INPUT
  /// Value to add
  Value : BYTE;
END_VAR

  Value := Value;
  // copy data 
  SysDepMemCpy( pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddByte := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a DataBlock to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddDataBlock : UDINT
VAR_INPUT
  /// Value to add
  pValue : POINTER TO BYTE;
  /// Size of data block
  Size   : UDINT;
END_VAR

  IF (pValue = 0) OR (Size = 0 )
  THEN
    RETURN;
  END_IF
  
  // copy data 
  SysDepMemCpy( pDest := ADR(Payload[PayloadPtr]), pSrc := pValue, DataLen := Size);
  // inc payload pointer 
  PayloadPtr := PayloadPtr + Size;
  // return payload len
  AddDataBlock := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a DataInSync to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddDataEnableSync : UDINT
VAR_INPUT
  /// Value to add
  Value : DataEnableSync;
END_VAR

VAR
  /// temporary Byte
 _tmpByte : BYTE;
END_VAR

  Value := Value;
  
  _tmpByte.0 := Value.EnableSyncTool;
  _tmpByte.1 := Value.EnableSyncFrame;
  _tmpByte.2 := Value.EnableSyncLoad;
  _tmpByte.3 := Value.EnableSyncWorkArea;
  _tmpByte.4 := Value.EnableSyncSWLimits;
  _tmpByte.5 := Value.EnableSyncDefaultDynamics;
  _tmpByte.6 := Value.EnableSyncReferenceDynamics;
  _tmpByte.7 := Value.AllowDynamicBlending;
  
  
  
  AddByte(_tmpByte);
  
  AddDataEnableSync := PayloadLen;

END_METHOD

/// Adds a DataInSync to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddDataInSync : UDINT
VAR_INPUT
  /// Value to add
  Value : DataInSync;
END_VAR

VAR
  /// temporary Byte
 _tmpByte : BYTE;
END_VAR

  Value := Value;
  
  _tmpByte.0 := Value.ToolsInSync;
  _tmpByte.1 := Value.FramesInSync;
  _tmpByte.2 := Value.LoadsInSync;
  _tmpByte.3 := Value.WorkAreasInSync;
  _tmpByte.4 := Value.SoftwareLimitsInSync;
  _tmpByte.5 := Value.DefaultDynamicsInSync;
  _tmpByte.6 := Value.ReferenceDynamicsInSync;
  _tmpByte.7 := FALSE;
  
  AddByte(_tmpByte);
  
  AddDataInSync := PayloadLen;

END_METHOD

/// Adds a DWORD to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddDword : UDINT
VAR_INPUT
  /// Value to add
  Value : DWORD;
END_VAR

  // swap byte order
  Value := SwapDword(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddDword := PayloadLen := PayloadPtr;

END_METHOD

/// Adds two halfe BYTE to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddHalfBytes : UDINT
VAR_INPUT
  /// Value to add
  HalfByteHi : BYTE;
  /// Value to add
  HalfByteLo : BYTE;
END_VAR

VAR
  /// internal value
 _value : BYTE;
END_VAR

  _value := CombineHalfBytes( HalfByteHi := HalfByteHi, HalfByteLo := HalfByteLo);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(_value), DataLen := SIZEOF(_value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(_value);
  // return payload len
  AddHalfBytes := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a IEC_DATE to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddIecDate : UDINT
VAR_INPUT
  /// Value to add
  Value : IEC_DATE;
END_VAR

  Value := SwapIecDate(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddIecDate := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a IEC_TIME to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddIecTime : UDINT
VAR_INPUT
  /// Value to add
  Value : IEC_TIME;
END_VAR

  Value := SwapIecTime(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddIecTime := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a INT to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddInt : UDINT
VAR_INPUT
  /// Value to add
  Value : INT;
END_VAR

  // swap byte order
  Value := SwapInt(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddInt := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a REAL to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddReal : UDINT
VAR_INPUT
  /// Value to add
  Value : REAL;
END_VAR

  // swap byte order
  Value := SwapReal(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]),pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddReal := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a SINT to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddSint : UDINT
VAR_INPUT
  /// Value to add
  Value : SINT;
END_VAR

  Value := Value;
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddSint := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a String to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddString : UDINT
VAR_INPUT
  /// Value to add
  Value : STRING(255);
END_VAR

  IF ( LEN(Value) = 0 )
  THEN
    RETURN;
  END_IF
  
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := DINT_TO_UDINT(LEN(Value)));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + DINT_TO_UDINT(LEN(Value));
  // return payload len
  AddString := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a TIME to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddTime : UDINT
VAR_INPUT
  /// Value to add
  Value : TOD;
END_VAR

  // swap byte order
  Value := SwapIecTime(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddTime := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a TurnNumber to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddTurnNumber : UDINT
VAR_INPUT
  /// Value to add
  Value : TurnNumber;
END_VAR

VAR
  /// temporary Byte
 _tmpByte : BYTE;
END_VAR

  Value := Value;
  
  AddHalfBytes( HalfByteHi := SINT_TO_BYTE(Value.J2Turns) , HalfByteLo := SINT_TO_BYTE(Value.J1Turns));
  AddHalfBytes( HalfByteHi := SINT_TO_BYTE(Value.J4Turns) , HalfByteLo := SINT_TO_BYTE(Value.J3Turns));
  AddHalfBytes( HalfByteHi := SINT_TO_BYTE(Value.J6Turns) , HalfByteLo := SINT_TO_BYTE(Value.J5Turns));
  AddByte(SINT_TO_BYTE(Value.E1Turns));
  
  AddTurnNumber := PayloadLen;

END_METHOD

/// Adds a UDINT to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddUdint : UDINT
VAR_INPUT
  /// Value to add
  Value : UDINT;
END_VAR

  // swap byte order
  Value := SwapUdint(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddUdint := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a UINT to the payload buffer , increase the payload pointer and returns the payload lenght
METHOD AddUint : UDINT
VAR_INPUT
  /// Value to add
  Value : UINT;
END_VAR

  // swap byte order
  Value := SwapUint(Value);
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc data index 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddUint := PayloadLen := PayloadPtr;

END_METHOD

/// Adds a USINT to the payload buffer, increase the payload pointer and returns the payload lenght
METHOD AddUsint : UDINT
VAR_INPUT
  /// Value to add
  Value : USINT;
END_VAR

  Value := Value;
  // copy data 
  SysDepMemCpy(pDest := ADR(Payload[PayloadPtr]), pSrc := ADR(Value), DataLen := SIZEOF(Value));
  // inc payload pointer 
  PayloadPtr := PayloadPtr + SIZEOF(Value);
  // return payload len
  AddUsint := PayloadLen := PayloadPtr;

END_METHOD

/// Resets the payload buffer, the payload pointer and the payload length
METHOD Reset
VAR_INPUT
END_VAR

  SysDepMemSet(pDest := ADR(Payload), Value := 0 , DataLen := SIZEOF(Payload));
  PayloadLen := 0;
  PayloadPtr := 0;

END_METHOD

