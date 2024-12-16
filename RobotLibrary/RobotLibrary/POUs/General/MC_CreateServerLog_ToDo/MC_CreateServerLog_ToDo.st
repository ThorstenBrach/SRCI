FUNCTION_BLOCK MC_CreateServerLog_ToDo EXTENDS RobotLibraryBaseFB
VAR
END_VAR


END_FUNCTION_BLOCK

METHOD FB_init : BOOL
VAR_INPUT
  /// if TRUE, the retain variables are initialized (warm start / cold start)
	bInitRetains : BOOL; 
  /// if TRUE, the instance afterwards gets moved into the copy code (online change)
	bInCopyCode  : BOOL;  
END_VAR

  MyType := 'ToDo';

END_METHOD

