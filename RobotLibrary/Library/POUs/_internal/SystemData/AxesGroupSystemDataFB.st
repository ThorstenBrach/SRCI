FUNCTION_BLOCK AxesGroupSystemDataFB 
{attribute 'pack_mode' := '1'} 
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      AxesGroupSystemDataFB                                       
//  Author:      Thorsten Brach                                                
//  Date:        2025-08-31
//
//  Description:                                              
//   
//                                                                           
//  Copyright: 
//    (C) 2025 Thorsten Brach. All rights reserved                                                                                                                                            
//             Licensed under the MIT License.
//                                                                           
//  Disclaimer:                                                                           
//    This project is provided without any guarantee and can be used for   
//    private and commercial purposes. Any use is at the user’s 
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Pointer to ToolData array
  ToolDataPtr       : POINTER TO Tool;
  /// Lower dimension of ToolData array 
  ToolDataMin       : DINT;
  /// Lower dimension of ToolData array
  ToolDataMax       : DINT;
  /// Amount of ToolData elements in array
  ToolDataCount     : UDINT;

  /// Pointer to LoadData array
  LoadDataPtr       : POINTER TO Load;
  /// Lower dimension of LoadData array 
  LoadDataMin       : DINT;
  /// Lower dimension of LoadData array
  LoadDataMax       : DINT;
  /// Amount of Load elements in array
  LoadDataCount     : UDINT;

  /// Pointer to FrameData array
  FrameDataPtr      : POINTER TO Frame;
  /// Lower dimension of FrameData array 
  FrameDataMin      : DINT;
  /// Lower dimension of FrameData array
  FrameDataMax      : DINT;
  /// Amount of FrameData elements in array
  FrameDataCount    : UDINT;
  
  /// Pointer to WorkAreas array
  WorkAreasPtr      : POINTER TO RobotWorkArea;
  /// Lower dimension of WorkAreas array 
  WorkAreasMin      : DINT;
  /// Lower dimension of WorkAreas array
  WorkAreasMax      : DINT;
  /// Amount of WorkAreas elements in array
  WorkAreasCount    : UDINT;
  
  /// Software limits stored on PLC
  SWLimits          : REFERENCE TO SWLimits;
  /// Default dynamics stored on PLC. For more information refer to 5.5.7
  DefaultDynamics   : REFERENCE TO DefaultDynamics;
  /// Reference dynamics stored on PLC. For more information refer to 5.5.7
  ReferenceDynamics : REFERENCE TO ReferenceDynamics;
END_VAR


END_FUNCTION_BLOCK

METHOD UpdateDefaultDynamics : DINT
VAR_INPUT
  /// Default dynamics values according to Table 6-148.
  DynamicValues : DefaultDynamics;
END_VAR

  // Check pointer is vaild ?
  IF ( NOT __ISVALIDREF(DefaultDynamics))  
  THEN
    RETURN;
  END_IF
  
  // Applay new values
  DefaultDynamics := DynamicValues;

END_METHOD

METHOD UpdateFrameData : DINT
VAR_INPUT
  /// Reference to BaseFB 
  Caller     : REFERENCE TO RobotLibraryBaseFB;
  /// Current System Time
  SystemTime : SystemTime;
  /// Frame index M
  /// • 0: WCS (default) O
  /// • 1..254: UCS (User frames)
  FrameNo    : USINT;
  /// Frame data (see chapter 5.5.6.2)
  FrameData  : FrameData;
END_VAR


VAR
  /// pointer to frame data
  pFrameData : POINTER TO Frame;  
END_VAR

  // Check pointer is vaild ?
  IF ( FrameDataPtr = RobotLibraryConstants.NULL_POINTER )
  THEN
    RETURN;
  END_IF
  
  // Check Frame number is in range ?
  IF (( FrameNo < FrameDataMin ) OR
      ( FrameNo > FrameDataMax ))
  THEN
    IF ( __ISVALIDREF( Caller ))
    THEN
     // set warning
     Caller.SetWarning( WarningID := RobotLibraryWarningIdEnum.WARN_SAVE_FRAME_FAILED, Overwrite := FALSE);
     
     // Create log entry
     Caller.CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.WARNING,
                                    MessageCode := Caller.WarningID,
                                    MessageText := 'Save FrameData failed. Index {1} not available in user defined system data',
                                    Para1       :=  USINT_TO_STRING(FrameNo));
    END_IF
  
    RETURN;
  END_IF
  
  
  // Calculate pointer address for the index of the FrameData Array
  pFrameData := FrameDataPtr + (( FrameNo - DINT_TO_UDINT(FrameDataMin)) * SIZEOF(Frame));
  // copy frame data to Array index
  pFrameData^.Available := TRUE;
  pFrameData^.Data := FrameData;

END_METHOD

METHOD UpdateLoadData : DINT
VAR_INPUT
  /// Reference to BaseFB 
  Caller     : REFERENCE TO RobotLibraryBaseFB;
  /// Current System Time
  SystemTime : SystemTime;
  /// Specifies the desired target values that shall be written
  /// Load index
  /// •      0: (default) - Not possible to write
  /// • 1..254: Load data
  LoadNo     : USINT;
  /// Load data (see chapter 5.5.6.4)
  LoadData   : LoadData;
END_VAR


VAR
  /// pointer to load data
  pLoadData : POINTER TO Load;  
END_VAR

  // Check pointer is vaild ?
  IF ( LoadDataPtr = RobotLibraryConstants.NULL_POINTER )
  THEN
    RETURN;
  END_IF
  
  // Check Load number is in range ?
  IF (( LoadNo < LoadDataMin ) OR
      ( LoadNo > LoadDataMax ))
  THEN
    IF ( __ISVALIDREF( Caller ))
    THEN
     // set warning
     Caller.SetWarning( WarningID := RobotLibraryWarningIdEnum.WARN_SAVE_LOAD_FAILED, Overwrite := FALSE);
     
     // Create log entry
     Caller.CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.WARNING,
                                    MessageCode := Caller.WarningID,
                                    MessageText := 'Save LoadData failed. Index {1} not available in user defined system data',
                                    Para1       :=  USINT_TO_STRING(LoadNo));
    END_IF
  
    RETURN;
  END_IF
  
  
  // Calculate pointer address for the index of the LoadData Array
  pLoadData := LoadDataPtr + (( LoadNo - DINT_TO_UDINT(LoadDataMin)) * SIZEOF(Load));
  // copy load data to Array index
  pLoadData^.Available := TRUE;
  pLoadData^.Data := LoadData;

END_METHOD

METHOD UpdateReferenceDynamics : DINT
VAR_INPUT
  /// Reference dynamics values according to Table 6-109.
  DynamicValues : ReferenceDynamics;
END_VAR

  // Check pointer is vaild ?
  IF ( NOT __ISVALIDREF(ReferenceDynamics))  
  THEN
    RETURN;
  END_IF
  
  // Applay new values
  ReferenceDynamics := DynamicValues;

END_METHOD

METHOD UpdateSWLimits : DINT
VAR_INPUT
  /// Limits for joints and external axes according to Table 6-180.
  LimitValues : SWLimits;
END_VAR

  // Check pointer is vaild ?
  IF ( NOT __ISVALIDREF(SWLimits))  
  THEN
    RETURN;
  END_IF
  
  // Applay new values
  SWLimits := LimitValues;

END_METHOD

METHOD UpdateToolData : DINT
VAR_INPUT
  /// Reference to BaseFB 
  Caller     : REFERENCE TO RobotLibraryBaseFB;
  /// Current System Time
  SystemTime : SystemTime;
  /// Tool index
  /// •      0: Flange (default) Not possible to change
  /// • 1..254: Tool Frame
  ToolNo     : USINT;
  /// Tool data (see chapter 5.5.6.3)
  ToolData   : ToolData;
END_VAR


VAR
  /// pointer to tool data
  pToolData : POINTER TO Tool;  
END_VAR

  // Check pointer is vaild ?
  IF ( ToolDataPtr = RobotLibraryConstants.NULL_POINTER )
  THEN
    RETURN;
  END_IF
  
  // Check Tool number is in range ?
  IF (( ToolNo < ToolDataMin ) OR
      ( ToolNo > ToolDataMax ))
  THEN
    IF ( __ISVALIDREF( Caller ))
    THEN
     // set warning
     Caller.SetWarning( WarningID := RobotLibraryWarningIdEnum.WARN_SAVE_TOOL_FAILED, Overwrite := FALSE);
     
     // Create log entry
     Caller.CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.WARNING,
                                    MessageCode := Caller.WarningID,
                                    MessageText := 'Save ToolData failed. Index {1} not available in user defined system data',
                                    Para1       :=  USINT_TO_STRING(ToolNo));
    END_IF
  
    RETURN;
  END_IF
  
  // ST-FIX F81: copy the tool into the ToolData array (was commented out)
  // Calculate pointer address for the index of the ToolData Array
  pToolData := ToolDataPtr + (( ToolNo - DINT_TO_UDINT(ToolDataMin)) * SIZEOF(Tool));
  // copy tool data to Array index
  pToolData^.Available := TRUE;
  pToolData^.Data := ToolData;

END_METHOD

METHOD UpdateWorAreas : DINT
VAR_INPUT
  /// Reference to BaseFB 
  Caller       : REFERENCE TO RobotLibraryBaseFB;
  /// Current System Time
  SystemTime   : SystemTime;
  /// Index of the robot work area
  /// • 0 (default)..254
  WorkAreaNo   : USINT;
  /// Data specific to the work area requested by Index.
  WorkAreaData : RobotWorkAreaData;
END_VAR
VAR
  /// pointer to WorkArea
  pWorkAreaData : POINTER TO RobotWorkArea;  
END_VAR

  // Check pointer is vaild ?
  IF ( WorkAreasPtr = RobotLibraryConstants.NULL_POINTER )
  THEN
    RETURN;
  END_IF
  
  // Check WorkArea number is in range ?
  IF (( WorkAreaNo < WorkAreasMin ) OR
      ( WorkAreaNo > WorkAreasMax ))
  THEN
    IF ( __ISVALIDREF( Caller ))
    THEN
     // set warning
     Caller.SetWarning( WarningID := RobotLibraryWarningIdEnum.WARN_SAVE_WORKAREA_FAILED, Overwrite := FALSE);
     
     // Create log entry
     Caller.CreateLogMessagePara1 ( Timestamp   := SystemTime,
                                    MessageType := MessageType.CMD,
                                    Severity    := Severity.WARNING,
                                    MessageCode := Caller.WarningID,
                                    MessageText := 'Save WorkArea failed. Index {1} not available in user defined system data',
                                    Para1       :=  USINT_TO_STRING(WorkAreaNo));
    END_IF
  
    RETURN;
  END_IF
  
  
  // Calculate pointer address for the index of the WorkArea Array
  pWorkAreaData := WorkAreasPtr + (( WorkAreaNo - DINT_TO_UDINT(WorkAreasMin)) * SIZEOF(RobotWorkArea));
  // copy WorkArea to Array index
  pWorkAreaData^.Available := TRUE;
  pWorkAreaData^.Data := WorkAreaData;

END_METHOD

