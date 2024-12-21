FUNCTION_BLOCK ActiveCommandRegisterFB EXTENDS RobotLibraryLogFB
// ------------------------------------------------------------------------- 
//  SRCI Robot Library                                                
// ------------------------------------------------------------------------- 
//                                                                           
//  Object:      ActiveCommandRegisterFB                                       
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
  /// Active Command Register
  Register            : ARRAY [1..RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX] OF AxesGroupAcyclicAcrEntry;
  /// System Time
  SystemTime          : DT;
END_VAR

VAR_OUTPUT
  /// Size of the register 
  Size                : UINT := DINT_TO_UINT(RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX);
  /// Execution Order List 
  ExecutionOrderList  : ARRAY [1..RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX] OF DINT;
END_VAR


VAR
  /// temporarty Active Command Register
  TmpRegister        : ARRAY [1..RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX] OF AxesGroupAcyclicAcrEntry;
  /// last used unique ID 
  LastUniqueID       : UINT;
  ///
  
END_VAR

VAR CONSTANT
  /// Active command
  ACTIVE_CMD           : UDINT := 1;
  /// Buffered command
  BUFFER_CMD           : UDINT := 2;
  /// Empty ARC entry
  EMPTY_ARC_ENTRY      : AxesGroupAcyclicAcrEntry;
  /// Empty command entry
  EMPTY_CMD_ENTRY      : AxesGroupAcyclicAcrEntryCmdBuffer;
  
  /// constant for byte index of priority in payload 
  PRIORITY_IDX         : BYTE := 3;  /// bitmask to mask the priority out of the halfbyte
  PRIORITY_BIT_MASK    : BYTE := 2#000_1111;   
END_VAR

  ManageRegister();
  
  UpdateExecutionOrderList();

END_FUNCTION_BLOCK

METHOD PUBLIC AddCmd : UDINT
VAR_INPUT
  /// Pointer to the corresponding command-FB to enable a callback mechanism
  pCommandFB   : POINTER TO RobotLibraryBaseFB;
END_VAR

VAR
  /// internal index for loops
 _regIdx     : DINT;
  /// internal command type 
 _cmdType    : CmdType;
  /// log message
 _messageLog         : AlarmMessage;  
END_VAR

  FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    IF ( Register[_regIdx].State = ActiveCommandRegisterState.IS_FREE )
    THEN
      Register[_regIdx].State                        := ActiveCommandRegisterState.IS_PROCESSING;
      Register[_regIdx].UniqueID                     := CreateUniqueID();
      Register[_regIdx].pCommandFB                   := pCommandFB;
  
      // check pointer to command FB
      IF ( Register[_regIdx].pCommandFB <> RobotLibraryConstants.XNULL )
      THEN
        Register[_regIdx].Command[RobotLibraryConstants.ACTIVE_CMD].Timestamp  := SystemTime;
        Register[_regIdx].Command[RobotLibraryConstants.ACTIVE_CMD].Payload    := pCommandFB^.CommandData.Payload;
        Register[_regIdx].Command[RobotLibraryConstants.ACTIVE_CMD].PayloadLen := pCommandFB^.CommandData.PayloadLen;
        Register[_regIdx].Command[RobotLibraryConstants.ACTIVE_CMD].PayLoadPtr := 0;
        Register[_regIdx].Command[RobotLibraryConstants.ACTIVE_CMD].State      := BufferStateCmd.CREATED;
      END_IF
    
      // return Unique ID
      AddCmd := Register[_regIdx].UniqueID;
  
      // Get CmdType from payload
      SysDepMemCpy( pDest := ADR(_cmdType), pSrc := ADR(pCommandFB^.CommandData.Payload), DataLen := SIZEOF(_cmdType));
      
      // Create log entry
      CreateLogMessagePara1 ( Timestamp   := SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.DEBUG,
                              MessageCode := 0,
                              MessageText := 'Added Cmd <{1}> to active command register',
                              Para1       :=  CmdTypeToString(SwapUint(_cmdType)));
      EXIT;
    END_IF
  END_FOR

END_METHOD

METHOD AddRsp : UDINT
VAR_INPUT
  /// Response
  Rsp : TelegramRobToPlcFragment;
END_VAR
VAR
  /// internal index for loops
 _Idx             : DINT;
  /// internal registen index
 _regIdx          : DINT;
  /// internal FragmentAction
 _fragmentAction  :  FragmentAction;
  /// internal command message state
 _cmdMessageState : CmdMessageState;
END_VAR

  FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    IF ( Register[_regIdx].UniqueID = Rsp.Header.CmdID )
    THEN
      // convert to fragment action 
     _fragmentAction := ByteToFragmentAction(Rsp.Header.FragmentAction);
  
      // delete response 
      IF ( _fragmentAction.Clear )
      THEN
        SysDepMemSet( pDest := ADR(Register[_regIdx].Response[1]), Value := 0, DataLen := SIZEOF(Register[_regIdx].Response[1]));
      END_IF
                         
      // add payload to response
      FOR _idx := Rsp.Header.PayloadPointer TO  Rsp.Header.PayloadLength -1
      DO
        Register[_regIdx].Response[1].Timestamp     := SystemTime;
        Register[_regIdx].Response[1].State         := BufferStateRsp.RECEIVING;
        Register[_regIdx].Response[1].PayloadLen    := Register[_regIdx].Response[1].PayloadLen + 1;
        Register[_regIdx].Response[1].Payload[_idx] := Rsp.Command.Payload[_idx];
      END_FOR
  
      // Get current message state 
     _cmdMessageState := GetHalfeByteLo(Register[_regIdx].Response[1].Payload[0]);
  
      // Create log entry
      CreateLogMessagePara2 ( Timestamp   := SystemTime,
                              MessageType := MessageType.CMD,
                              Severity    := Severity.DEBUG,
                              MessageCode := 0,
                              MessageText := 'Added Rsp <{1}> with State = {2} to ACR',
                              Para1       :=  UINT_TO_STRING(Rsp.Header.CmdID),
                              Para2       :=  CmdMessageStateToString(_cmdMessageState));
  
      IF ( _fragmentAction.Complete )
      THEN
        // set response state
        Register[_regIdx].Response[1].State := BufferStateRsp.RECEIVED;      
       
        // Check current message state and tag the register state as IS_FINAL, if needed 
        IF ( _cmdMessageState >= CmdMessageState.DONE) 
        THEN
          Register[_regIdx].State := ActiveCommandRegisterState.IS_FINAL;
          
          // Create log entry
          CreateLogMessagePara1( Timestamp   := SystemTime,
                                 MessageType := MessageType.CMD,
                                 Severity    := Severity.DEBUG,
                                 MessageCode := 0,
                                 MessageText := 'ARC Register for Rsp <{1}> has reached Final State',
                                 Para1       :=  UINT_TO_STRING(Rsp.Header.CmdID));
          // Exit the loop
        END_IF      
      END_IF
      
      EXIT;
    END_IF
  END_FOR

END_METHOD

METHOD PRIVATE CreateUniqueID : UINT
VAR_INPUT
END_VAR

  // inc last unique ID 
  LastUniqueID := LastUniqueID + 1;
  // return unique ID
  CreateUniqueID := LastUniqueID;

END_METHOD

METHOD FB_init : BOOL
VAR_INPUT
  bInitRetains : BOOL; // if TRUE, the retain variables are initialized (warm start / cold start)
  bInCopyCode : BOOL;  // if TRUE, the instance afterwards gets moved into the copy code (online change)
END_VAR

  MyType := 'ActiveCommandRegisterFB';

END_METHOD

METHOD PRIVATE ManageRegister
VAR
  /// internal index
 _regIdx     : DINT;  
END_VAR

  FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    // Check pointer to command FB is valid ? 
    IF ( Register[_regIdx].pCommandFB = RobotLibraryConstants.XNULL)
    THEN
      RETURN;
    END_IF
  
    // Check apply Cmd parameter update ?  
    IF (( Register[_regIdx].Command[ACTIVE_CMD].State = BufferStateCmd.PROCESSED        ) AND
        ( Register[_regIdx].Command[BUFFER_CMD].State = BufferStateCmd.UPDATE_AVAILABLE ))
    THEN
      Register[_regIdx].Command[ACTIVE_CMD] := Register[_regIdx].Command[BUFFER_CMD];
      Register[_regIdx].Command[BUFFER_CMD] := EMPTY_CMD_ENTRY;
    END_IF
    
    // Check Response received ? 
    IF ( Register[_regIdx].Response[ACTIVE_CMD].State = BufferStateRsp.RECEIVED)
    THEN
      // update state
      Register[_regIdx].Response[ACTIVE_CMD].State := BufferStateRsp.PROCESSED;
      // callback CommandFB    
      Register[_regIdx].pCommandFB^.CallBack(Register[_regIdx].Response[ACTIVE_CMD]);    
    END_IF
  
    // delete entries with State.IS_Final 
    IF ( Register[_regIdx].State = ActiveCommandRegisterState.IS_FINAL )
    THEN
      // Create log entry
      CreateLogMessagePara2( Timestamp   := SystemTime,
                             MessageType := MessageType.CMD,
                             Severity    := Severity.DEBUG,
                             MessageCode := 0,
                             MessageText := 'Deleted ID <{1}> from ARC Register Idx <{2}> because of Final State was reached',
                             Para1       :=  UINT_TO_STRING(Register[_regIdx].UniqueID),  
                             Para2       :=  DINT_TO_STRING(_regIdx) );
                             
      Register[_regIdx] := EMPTY_ARC_ENTRY;                           
    END_IF
   
  END_FOR

END_METHOD

PROPERTY PUBLIC NotifyParameterChanged : UDINT


SET
VAR
  /// internal register index
 _regIdx : DINT;
END_VAR

  FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    // check unique ID found ?
    IF ( Register[_regIdx].UniqueID = NotifyParameterChanged )
    THEN  
      IF (( Register[_regIdx].Command[ACTIVE_CMD].State <> BufferStateCmd.SENDING   ) AND
          ( Register[_regIdx].Command[ACTIVE_CMD].State <> BufferStateCmd.PROCESSED ))
      THEN
        // Check pointer is valid ? 
        IF ( Register[_regIdx].pCommandFB <> RobotLibraryConstants.XNULL )
        THEN
          // add to send register
          Register[_regIdx].Command[ACTIVE_CMD].Timestamp  := SystemTime;
          Register[_regIdx].Command[ACTIVE_CMD].State      := BufferStateCmd.UPDATE_AVAILABLE;
          Register[_regIdx].Command[ACTIVE_CMD].Payload    := Register[_regIdx].pCommandFB^.CommandData.Payload;
          Register[_regIdx].Command[ACTIVE_CMD].PayloadLen := Register[_regIdx].pCommandFB^.CommandData.PayloadLen;
  
          // Create log entry
          CreateLogMessagePara2 ( Timestamp   := SystemTime,
                                  MessageType := MessageType.CMD,
                                  Severity    := Severity.DEBUG,
                                  MessageCode := 0,
                                  MessageText := 'Parameter update from {1} with CmdID <{2}> received -> written to ACTIVE_CMD Index',
                                  Para1       :=  Register[_regIdx].pCommandFB^.MyType,
                                  Para2       :=  UDINT_TO_STRING(NotifyParameterChanged));
        END_IF
      ELSE
        // Check pointer is valid ? 
        IF ( Register[_regIdx].pCommandFB <> RobotLibraryConstants.XNULL )
        THEN
          // add to buffer register
          Register[_regIdx].Command[BUFFER_CMD].Timestamp  := SystemTime;
          Register[_regIdx].Command[BUFFER_CMD].State      := BufferStateCmd.UPDATE_AVAILABLE;
          Register[_regIdx].Command[BUFFER_CMD].Payload    := Register[_regIdx].pCommandFB^.CommandData.Payload;
          Register[_regIdx].Command[BUFFER_CMD].PayloadLen := Register[_regIdx].pCommandFB^.CommandData.PayloadLen;
  
          // Create log entry
          CreateLogMessagePara2 ( Timestamp   := SystemTime,
                                  MessageType := MessageType.CMD,
                                  Severity    := Severity.DEBUG,
                                  MessageCode := 0,
                                  MessageText := 'Parameter update from {1} with CmdID <{2}> received -> written to BUFFER_CMD Index',
                                  Para1       :=  Register[_regIdx].pCommandFB^.MyType,
                                  Para2       :=  UDINT_TO_STRING(NotifyParameterChanged));
        END_IF
      END_IF
      
      
    END_IF
  END_FOR

END_SET

METHOD PUBLIC OnOnlineChange : DINT
VAR_INPUT
  /// unique ID 
  UniqueID     : UDINT;
  /// Pointer to the corresponding command-FB to enable a callback mechanism
  pCommandFB   : POINTER TO RobotLibraryBaseFB;
END_VAR

VAR
  /// internal index for loops
 _regIdx : DINT;
END_VAR

  OnOnlineChange := -1;
  
  // Check command FB pointer is valid ?
  IF ( pCommandFB <> RobotLibraryConstants.XNULL)
  THEN
    FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
    DO
      // check unique ID found ?
      IF ( Register[_regIdx].UniqueID = UniqueID ) 
      THEN  
        // update pointer to command FB
        Register[_regIdx].pCommandFB := pCommandFB;
        // Return result OK
        OnOnlineChange := RobotLibraryConstants.OK;
        EXIT;
      END_IF
    END_FOR
  END_IF

END_METHOD

METHOD PUBLIC RemoveCmd
VAR_INPUT
 /// unique ID
 UniqueID : UDINT;  
END_VAR

VAR
  /// internal index
 _regIdx : DINT;
END_VAR

  FOR _regIdx := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    // check unique ID found and not yet sended ?
    IF (( Register[_regIdx].UniqueID         = UniqueID               ) AND
        ( Register[_regIdx].Command[1].State < BufferStateCmd.SENDING ))       
    THEN  
      // delete register entry
      SysDepMemSet(pDest := ADR(Register[_regIdx]), Value := 0 , DataLen := SIZEOF(Register[_regIdx]));
      EXIT;
    END_IF
  END_FOR

END_METHOD

METHOD PRIVATE UpdateExecutionOrderList
VAR
  /// temporary Active Command Register entry
  TmpRegisterEntry : AxesGroupAcyclicAcrEntry;
  /// temporary index
  TmpIndex         : DINT;
  /// internal index
  i                : DINT;  
  /// internal index
  j                : DINT;  
END_VAR

  // Reset temporary register
  SysDepMemSet(pDest := ADR(TmpRegister)       , Value := 0, DataLen := SIZEOF(TmpRegister));
  // Reset Execution Order List
  SysDepMemSet(pDest := ADR(ExecutionOrderList), Value := 0, DataLen := SIZEOF(ExecutionOrderList));
  // pre-set temporary register index 
  j := 1;
  
  FOR i := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    // add only entries which are not in status free  
    IF ( Register[i].State >  ActiveCommandRegisterState.IS_FREE )  
    THEN
      // copy register entry 
      TmpRegister[j] := Register[i];
      // store index of the entry from the ARC
      ExecutionOrderList[j] := i;
      // inc temporar register index
      j := j + 1; 
    END_IF
  END_FOR  
  
  // Bubble Sort to sort the priorities from the active command register
  FOR i := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    FOR j := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX - 1
    DO 
      // check list entry is not empty ? 
      IF (( TmpRegister[i  ].State = ActiveCommandRegisterState.IS_FREE ) OR
          ( TmpRegister[j+1].State = ActiveCommandRegisterState.IS_FREE ))
      THEN
        EXIT; 
      END_IF  
  
      IF (( TmpRegister[j].Command[ACTIVE_CMD].Payload[PRIORITY_IDX] AND PRIORITY_BIT_MASK ) > ( TmpRegister[j+1].Command[ACTIVE_CMD].Payload[PRIORITY_IDX] AND PRIORITY_BIT_MASK ))
      THEN    
        // swap position of register entry  
        TmpRegisterEntry := TmpRegister[j];         
        TmpRegister[j]   := TmpRegister[j+1];
        TmpRegister[j+1] := TmpRegisterEntry;
        
        // swap position of index in the Execution Order List  
        TmpIndex                := ExecutionOrderList[j];
        ExecutionOrderList[j]   := ExecutionOrderList[j+1];
        ExecutionOrderList[j+1] := TmpIndex;
      END_IF
    END_FOR 
  END_FOR
  
  // Bubble Sort to sort the Timestamp from the pre-sorted active command register
  FOR i := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX
  DO
    FOR j := 1 TO RobotLibraryParameter.ACTIVE_CMD_REGISTER_ENTRIES_MAX - 1
    DO    
      // check list entry is not empty ? 
      IF (( TmpRegister[i  ].State = ActiveCommandRegisterState.IS_FREE ) OR
          ( TmpRegister[j+1].State = ActiveCommandRegisterState.IS_FREE ))
      THEN
        EXIT; 
      END_IF  
  
      IF (( TmpRegister[j].Command[ACTIVE_CMD].Payload[PRIORITY_IDX] AND PRIORITY_BIT_MASK ) >= ( TmpRegister[j+1].Command[ACTIVE_CMD].Payload[PRIORITY_IDX] AND PRIORITY_BIT_MASK )) AND
         (( TmpRegister[j].Command[ACTIVE_CMD].Timestamp )                                   >  ( TmpRegister[j+1].Command[ACTIVE_CMD].Timestamp ))
      THEN    
        // swap position of register entry  
        TmpRegisterEntry := TmpRegister[j];         
        TmpRegister[j]   := TmpRegister[j+1];
        TmpRegister[j+1] := TmpRegisterEntry;
        
        // swap position of index in the Execution Order List  
        TmpIndex                := ExecutionOrderList[j];
        ExecutionOrderList[j]   := ExecutionOrderList[j+1];
        ExecutionOrderList[j+1] := TmpIndex;
      END_IF
    END_FOR 
  END_FOR

END_METHOD

